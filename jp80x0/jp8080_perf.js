

function commonParms(isJP8080) {
  return [
    { inc: 1, b: 0x10, block: [
      ["key/mode", { opts: ["Single", "Dual", "Split"] }],
      ["split/pt", { iso: ['noteName', "C-1"] }],
      ["panel/select", { opts: ["Upper", "Lower", "Upper&Lower"] }],
      ["part/detune", { max: 100, dispOff: -50 }],
      ["out/assign", { opts: ["Mix", "Parallel"] }],
      ["arp/dest", { opts: ["Lower&Upper", "Lower", "Upper"] }],
      ["voice/assign", { opts: (isJP8080
          ? ["8-2", "7-3", "5-5", "3-7", "2-8", "6-4", "4-6"]
          : ["6-2", "5-3", "4-4", "3-5", "2-6"]
      ) }],
      { prefix: 'arp', block: [
          ["on", { max: 1 }],
          ["mode", { opts: ["Up", "Down", "Up&Down", "Random", "RPS"] }],
          ["pattern", { opts: ["1/4", "1/6", "1/8", "1/12", "1/16", "1/32", "PORTA-A1", "PORTA-A2", "PORTA-A3", "PORTA-A4", "PORTA-A5", "PORTA-A6", "PORTA-A7", "PORTA-A8", "PORTA-A9", "PORTA-A10", "PORTA-A11", "PORTA-B1", "PORTA-B2", "PORTA-B3", "PORTA-B4", "PORTA-B5", "PORTA-B6", "PORTA-B7", "PORTA-B8", "PORTA-B9", "PORTA-B10", "PORTA-B11", "PORTA-B12", "PORTA-B13", "PORTA-B14", "PORTA-B15", "SEQUENCE-A1", "SEQUENCE-A2", "SEQUENCE-A3", "SEQUENCE-A4", "SEQUENCE-A5", "SEQUENCE-A6", "SEQUENCE-A7", "SEQUENCE-B1", "SEQUENCE-B2", "SEQUENCE-B3", "SEQUENCE-B4", "SEQUENCE-B5", "SEQUENCE-C1", "SEQUENCE-C2", "SEQUENCE-D1", "SEQUENCE-D2", "SEQUENCE-D3", "SEQUENCE-D4", "SEQUENCE-D5", "SEQUENCE-D6", "SEQUENCE-D7", "SEQUENCE-D8", "ECHO1", "ECHO2", "ECHO3", "MUTE1", "MUTE2", "MUTE3", "MUTE4", "MUTE5", "MUTE6", "MUTE7", "MUTE8", "MUTE9", "MUTE10", "MUTE11", "MUTE12", "MUTE13", "MUTE14", "MUTE15", "MUTE16", "STRUMMING1", "STRUMMING2", "STRUMMING3", "STRUMMING4", "STRUMMING5", "STRUMMING6", "STRUMMING7", "STRUMMING8", "REFRAIN1", "REFRAIN2", "PERCUSSION1", "PERCUSSION2", "PERCUSSION3", "PERCUSSION4", "WALKING BASS", "HARP", "RANDOM"] }],
          ["range", { max: 3, dispOff: 1 }],
          ["hold", { max: 1 }],
      ] },
    ] },
    (isJP8080 ? [] : ["pedal", 0x1c, max: 0x2d]), // TODO: Options.
    { inc: 1, b: 0x1d, block: 
      { prefix: "trigger", block: [
        ["on", { max: 1 }],
        ["dest", { opts: ["Filter Env", "Amp Env", "F&A Envs"] }],
        ["src/channel", { max: 15, dispOff: 1 }],
        o2("src/note", { max: 128, isoS: ['switch', [
          [128, "All"],
        ], ['noteName', "C-1"]] }),
      ] },
    },
    o2("tempo", 0x22, rng: [20, 250]),
    (isJP8080 ? [o("input", 0x24, opts: ["Rear", "Front"])] : [])
  ]
}

const commonWerk = {
  single: 'perf.common',
  initFile: "jp8080-perf-common-init",
  size: 0x25
  namePack: [0, 0x0f],
}
 

const ctrlOptions = ["Ensmbl Lvl", "V Delay Time", "V Delay Feedbk", "V Delay Lvl", "Vocal Mix", "V Reson", "V Release", "V Pan", "V Level", "V Nz Cutoff", "V Nz Lvl", "Gate Thresh", "Robot Pitch", "Robot Ctrl", "Robot Lvl"] + 12.map { "Char \($0 + 1)"}

const voiceModParms = [
  { inc: 1, b: 0x00, block: [
    ["on", {max: 1}],
    ["panel", {max: 1}],
    ["algo", {opts: ["Solid", "Smooth", "Wide", "F Bank Wide", "F Bank Narw"]}],
    ["delay/type", {opts: JP8080VoicePatch.delayTypes}],
    ["chorus/type", {opts: ["Ens Mild", "Ens Clean", "Ens Fast"] + JP8080VoicePatch.fxTypes.dropLast(1)}], // ensemble
    ["ext/instr", {max: 1}],
    ["ext/voice", {max: 1}],
    ["morph/ctrl", {max: 1}],
    ["morph/threshold", { }],
    ["morph/sens", {dispOff: -64}],
    ["ctrl/0/assign", {opts: ctrlOptions}],
    ["ctrl/1/assign", {opts: ctrlOptions}],
    { prefix: "character", count: 12, block: [
      ['', { }],
    ] },
    ["voice/mix", { }],
    ["release", { }],
    ["reson", { }],
    ["pan", {dispOff: -64}],
    ["level", { }],
    ["noise/cutoff", { }],
    ["noise/level", { }],
    ["gate/threshold", { }],
    ["robot/pitch", { }],
    ["robot/ctrl", { }],
    ["robot/level", { }],
    ["chorus/level", { }],
    ["delay/time", { }],
    ["delay/feedback", { }],
    ["delay/level", { }],
    ["chorus/sync", { }], // TODO
    ["delay/sync", { }], // TODO
  ] },
]

const voiceModWerk = { 
  single: 'perf.voicemod',
  initFile: "jp8080-perf-voicemod-init",
  size: 0x29,
  parms: voiceModParms,
}


const chorusSyncOptions = ["Off", "1/16", "1/8t", "1/16.", "1/8", "1/4t", "1/8.", "1/4", "1/2t", "1/4.", "1/2", "1/1t", "1/2.", "1/1", "2/1t", "1/1.", "2/1", "3 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars", "LFO1"]

const delaySyncOptions = ["Off", "1/16", "1/8t", "1/16.", "1/8", "1/4t", "1/8.", "1/4", "1/2t", "1/4.", "1/2"]
 
const lfoSyncOptions = ["Off", "1/16", "1/8t", "1/16.", "1/8", "1/4t", "1/8.", "1/4", "1/2t", "1/4.", "1/2", "1/1t", "1/2.", "1/1", "2/1t", "1/1.", "2/1", "3 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars"]

function partParms(isJP8080) {
  return [
    { inc: 1, b: 0x00, block: ([
      ["bank", {opts: ["In Perf", "User", "Preset"].concat(isJP8080 ? ["Card"] : []) }],
      ["number"],
      ["channel", {max: 16, iso: ['switch', [[16, "Off"]], ['+', 1]]}],
      ["transpose", {max: 48, dispOff: -24}],
      ["delay/sync", {opts: delaySyncOptions}],
      ["lfo/sync", {opts: lfoSyncOptions}],
      ["chorus/sync", {opts: chorusSyncOptions}],
    ]).concat(isJP8080 ? [["group", { max: 63 }]] : []) },
  ]
}

const partWerk = {
  single: 'perf.part',
  initFile: "jp8080-perf-part-init",
  size: 0x08,
}


 // altered from RolandMultiPatchTemplate to accommodate voices broken into multiple sysex msgs
 static func mapIndex(address: RolandAddress, sysex: Data) -> Int? {
   rolandMap.enumerated().compactMap { i, item in
     switch item.patch {
     case is JP8080VoicePatch.Type:
       // hacky hard-code approach.
       guard address == item.address || address == item.address + 0x0172 else { return nil }
       return i
     case let template as RolandSinglePatchTemplate.Type:
       guard address == item.address,
             template.isValid(sysex: sysex) else { return nil }
       return i
     case let template as RolandMultiPatchTemplate.Type:
       guard template.mapIndex(address: address - item.address, sysex: sysex) != nil else { return nil }
       return i
     default:
       return nil
     }
   }.first
   
const patchWerk = {
  multi: 'perf', 
  map: [
    ["common", 0x0000, commonWerk],
    ["voice/mod", 0x0800, voiceModWerk],
    ["part/0", 0x1000, partWerk],
    ["part/1", 0x1100, partWerk],
    ["patch/0", 0x4000, Voice.patchWerk],
    ["patch/1", 0x4200, Voice.patchWerk],
  ],
  initFile: "jp8080-perf-init",
  validSizes: ['auto', 686],
}



struct JP8080PerfBank : RolandMultiBankTemplate, PerfBank {
 typealias Template = JP8080PerfPatch
 static let patchCount: Int = 64
 static let initFileName: String = "jp8080-perf-bank-init"
 
 static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x03000000 }
 static func offsetAddress(location: UInt8) -> RolandAddress { 0x010000 * Int(location) }

 static func patchArray(fromData data: Data) -> [FnMultiPatch<Template>] {
   patches(fromData: data) {
     Int(Template.addressBytes(forSysex: $0)[1])
   }
 }
 
 static func isValid(fileSize: Int) -> Bool {
   [fileDataCount, 686 * patchCount].contains(fileSize)
 }
}

