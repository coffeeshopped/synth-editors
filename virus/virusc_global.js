
const keyDests = ["Off"] + (1..<128).map { `${$0}` }

const keyPressIso = Miso.switcher([
  .int(0, "Off")
], default: Miso.str())

const tuneModeIso = Miso.switcher([
  .int(0, "Temper"),
  .int(64, "Natural"),
  .int(127, "Pure")
], default: Miso.str())

const parms = [
  ["alt/out", { b: 45, opts: ["Off"] + VirusCMulti.outOptions }],
  ["key/transpose/ctrl", { b: 63, opts: ["Patch", "Keyb"] }],
  ["key/local", { b: 64, max: 1 }],
  ["key/mode", { b: 65, opts: ["1 Chan", "Multi Chan"] }],
  ["key/transpose", { b: 66, dispOff: -64 }],
  ["key/modWheel", { b: 67, opts: keyDests }],
  ["key/pedal/0", { b: 68, opts: keyDests }],
  ["key/pedal/1", { b: 69, opts: keyDests }],
  ["key/pressure/sens", { b: 70, iso: keyPressIso }],
  ["tune/mode", { b: 76, iso: tuneModeIso }],
  ["global/pgmChange/on", { b: 85, max: 1 }],
  ["multi/pgmChange/on", { b: 86, max: 1 }],
  ["global/volume/on", { b: 87, max: 1 }], // global midi volume ena
  ["input/level", { b: 90 }],
  ["input/booster", { b: 91 }],
  ["tune", { b: 92, dispOff: -64 }],
  ["deviceId", { b: 93, max: 15, dispOff: 1 }], // 16 = Omni but ctrl shouldn't allow selecting that
  ["midi/part/lo", { b: 94, opts: ["Sysex", "Ctrl"] }],
  ["midi/part/hi", { b: 95, opts: ["Sysex", "PolyPrs"] }],
  ["midi/arp", { b: 96, max: 1 }],
  p["knob/vib"] = OptionsParam(byte: 97, options: [
                                    0: "Off",
                                    7: "Short",
                                    66: "Long",
                                    127: "On"]) // knob display
//    ["multi/pgmChange", { b: 0 }],
  ["midi/clock/rcv", { b: 106, opts: ["Disable", "Auto", "Send"] }],
  ["knob/0/mode", { b: 110, opts: ["Single", "Global", "MIDI"] }],
  ["knob/1/mode", { b: 111, opts: ["Single", "Global", "MIDI"] }],
  ["knob/0/global", { b: 112, opts: VirusCVoice.knobOptions }],
  ["knob/1/global", { b: 113, opts: VirusCVoice.knobOptions }],
  ["knob/0/midi", { b: 114 }],
  ["knob/1/midi", { b: 115 }],
  ["extra/mode", { b: 116, opts: ["Off", "On", "All"] }], // expert mode
  ["knob/mode", { b: 117, opts: ["Off", "Jump", "iSnap", "Snap", "iRel", "Rel"] }],
  ["memory/protect", { b: 118, opts: ["Off", "On", "Warn"] }],
  ["thru", { b: 120, max: 1 }],
  ["ctrl/dest", { b: 121, opts: ["Int", "Int+MIDI", "MIDI"] }], // panel dest

  ["play/mode", { b: 122, opts: ["Single", "MultiSing", "Multi"] }],
  ["channel", { b: 124, max: 15, dispOff: 1 }],
  ["light/mode", { b: 125, opts: ["LFO", "Input", "Auto"] }],
  ["contrast", { b: 126 }],
  ["volume", { b: 127 }],
]

const patchTruss = {
  single: 'global',
  parms: parms,
  initFile: "virusc-global-init",
  parseBody: ['bytes', { start: 9, count: 256 }],
}

const fileDataCount = 267

func sysexData(deviceId: UInt8) -> Data {
  var data = Data(VirusTI.sysexHeader)
  // the 01 66 are just in the dump I got from the synth... dunno if they're right
  var b1 = [deviceId, 0x12, 0x01, 0x66] // these are included in checksum
  b1.append(contentsOf: bytes)
  data.append(contentsOf: b1)
  
  let checksum = b1.map{ Int($0) }.reduce(0, +) & 0x7f
  data.append(UInt8(checksum))
  
  data.append(0xf7)
  return data
}

func fileData() -> Data { return sysexData(deviceId: 16) }
