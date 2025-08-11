

const deviceId = ['e', 'global', 'deviceId', 0]

const sysexHeader = [0xf0, 0x3e, 0x10, deviceId]

/// dumpByte: cmd byte for what kind of dump.
function sysexData(dumpByte, bank, location) {
  return [sysexHeader dumpByte, bank, location, 'b', 0x7f, 0xf7]
}

// devID=127 is OMNI, but a PDF I read said 0 is default for sound designers
function fileData(dumpByte) {
  return sysexData(dumpByte, 0x20, 0x00)
}

function fxParams(b) {
  return { prefix: "fx", count: 2, bx: 16, block: i => [
    { inc: 1, b: b, block: [
      ["type", {opts: i == 0 ? MicroQVoicePatch.fxTypes : MicroQVoicePatch.fx2Types}],
      ["mix"],
    ] },
    { prefix: "param", count: 14, bx: 1, block: [
      ['', {b: b + 2}],
    ] },
  ] }
}

function arpParams(b) {
  return { prefix: "arp", block: [
    { inc: 1, b: b, block: [
      ["mode", {opts: Blofeld.Voice.arpModes}],
      ["pattern", {max: 16, iso: ['switch', [[0, "Off"], [1, "User"]], ['>', ['-', 1],  'str']] }],
      ["note", {max: 15, dispOff: 1}],
      ["clock", {dispOff: 3}],
      ["length", {iso: ['switch', [[127, "Legato"]], ['>', ['+', 1], 'str']] }],
      ["octave", {max: 9, dispOff: 1}],
      ["direction", {opts: Blofeld.Voice.arpDirections}],
      ["sortOrder", {opts: Blofeld.Voice.arpSortOptions}],
      ["velo", {opts: ["Each Note", "First Note", "Last Note"]}],
      ["timingFactor"],
      ["legato", {max: 1}],
      ["pattern/reset", {max: 1}],
      ["pattern/length", {max: 15, dispOff: 1}],
    ] },
    ["tempo", {b: b + 15, iso: MicroQVoicePatch.tempoIso}],
    { prefix: '', count: 16, bx: 1, block: [
      ["step", {b: b + 16, bits: [4, 7], dispOff: -4, opts: Blofeld.Voice.arpStepOptions}],
      ["glide", {b: b + 16, bit: 3}],
      ["accent", {b: b + 16, bits: [0, 3], max: 7, dispOff: -4, iso: MicroQVoicePatch.arpAccentIso}],
      ["length", {b: b + 32, bits: [4, 7], max: 7, dispOff: -4, iso: MicroQVoicePatch.arpLenIso}],
      ["timing", {b: b + 32, bits: [0, 3], max: 7, dispOff: -4, iso: MicroQVoicePatch.arpTimingIso}],
    ] },
  ] }
}

extension SingleBankTemplate where Template: MicroQPatch {
  static func patchArray(fromData data: Data) -> [Patch] {
    patchArray(fromData: data) { location($0, fromByte: 6) }
  }
  
  static func fileData(_ patches  : [Patch]) -> [UInt8] {
    sysexData(patches: patches) {
      Template.sysexData($0.bytes, deviceId: 0, bank: 0x40, location: UInt8($1)).bytes()
    }
  }
}