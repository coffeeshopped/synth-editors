const waveOptions = ["1: Saw", "2: Square", "3: Ac Piano", "4: Elec Piano", "5: Elec Piano 2", "6: Clavi", "7: Organ", "8: Brass", "9: Sax", "10: Violin", "11: Ac Guitar", "12: Dist Guitar", "13: Elec Bass", "14: Digi Bass", "15: Bell", "16: Sine"]

const parms = [
  ["osc/0/octave", { p: 11, b: 0, opts: ["16'", "8'", "4'"] }],
  ["osc/0/wave", { p: 12, b: 1, opts: waveOptions }],
  ["osc/0/level", { p: 13, b: 2, max: 31 }],
  ["auto/bend/select", { p: 14, b: 3, opts: ["Off", "Osc 1", "Osc 2", "Both"] }],
  ["auto/bend/mode", { p: 15, b: 4, opts: ["Up", "Down"] }],
  ["auto/bend/time", { p: 16, b: 5, max: 31 }],
  ["auto/bend/amt", { p: 17, b: 6, max: 31 }],
  ["osc/1/octave", { p: 21, b: 7, opts: ["16'", "8'", "4'"] }],
  ["osc/1/wave", { p: 22, b: 8, opts: waveOptions }],
  ["osc/1/level", { p: 23, b: 9, max: 31 }],
  ["interval", { p: 24, b: 10, opts: ["Unison", "Minor 3rd", "Major 3rd", "4th", "5th"] }],
  ["detune", { p: 25, b: 11, max: 6 }],
  ["noise", { p: 26, b: 12, max: 31 }],
  ["assign/mode", { p: 0, b: 13, opts: ["Poly", "Poly 2", "Unison", "Unison 2"] }],
  ["param/number", { p: 0, b: 14 }],
  ["cutoff", { p: 31, b: 15, max: 63 }],
  ["reson", { p: 32, b: 16, max: 31 }],
  ["filter/keyTrk", { p: 33, b: 17, opts: ["Off", "1/4", "1/2", "Full"] }],
  ["filter/env/polarity", { p: 34, b: 18, opts: ["Normal", "Invert"] }],
  ["filter/env/amt", { p: 35, b: 19, max: 31 }],
  ["filter/env/attack", { p: 41, b: 20, max: 31 }],
  ["filter/env/decay", { p: 42, b: 21, max: 31 }],
  ["filter/env/brk", { p: 43, b: 22, max: 31 }],
  ["filter/env/slop", { p: 44, b: 23, max: 31 }],
  ["filter/env/sustain", { p: 45, b: 24, max: 31 }],
  ["filter/env/release", { p: 46, b: 25, max: 31 }],
  ["filter/velo", { p: 47, b: 26, max: 7 }],
  ["amp/env/attack", { p: 51, b: 27, max: 31 }],
  ["amp/env/decay", { p: 52, b: 28, max: 31 }],
  ["amp/env/brk", { p: 53, b: 29, max: 31 }],
  ["amp/env/slop", { p: 54, b: 30, max: 31 }],
  ["amp/env/sustain", { p: 55, b: 31, max: 31 }],
  ["amp/env/release", { p: 56, b: 32, max: 31 }],
  ["amp/velo", { p: 57, b: 33, max: 7 }],
  ["lfo/wave", { p: 61, b: 34, opts: ["Tri", "Saw", "Rev Saw", "Square"] }],
  ["lfo/freq", { p: 62, b: 35, max: 31 }],
  ["lfo/delay", { p: 63, b: 36, max: 31 }],
  ["lfo/pitch", { p: 64, b: 37, max: 31 }],
  ["lfo/filter", { p: 65, b: 38, max: 31 }],
  ["bend/pitch", { p: 66, b: 39, max: 12 }],
  ["bend/filter", { p: 67, b: 40, max: 1 }],
  ["delay/time", { p: 71, b: 41, max: 7 }],
  ["delay/scale", { p: 72, b: 42, max: 15 }],
  ["delay/feedback", { p: 73, b: 43, max: 15 }],
  ["delay/mod/freq", { p: 74, b: 44, max: 31 }],
  ["delay/mod/amt", { p: 75, b: 45, max: 31 }],
  ["delay/level", { p: 76, b: 46, max: 15 }],
  ["porta", { p: 77, b: 47, max: 31 }],
  ["aftertouch/vib", { p: 81, b: 48, max: 3 }],
  ["aftertouch/filter", { p: 82, b: 49, max: 3 }],
  ["aftertouch/amp", { p: 83, b: 50, max: 3 }],
]

const sysexData = [0xf0, 0x42, ['+', 'channel', 0x30], 0x03, 0x40, 'b', 0xf7]

const patchTruss = {
  single: 'voice',
  parms: parms,
  initFile: "dw8k-voice-init",
  parseBody: ['bytes', { start: 5, count: 51 }],
  // normal, or with write request
  validSizes: ['auto', 64],
  createFile: sysexData,
}

class DW8KVoicePatch : ByteBackedSysexPatch, BankablePatch, VoicePatch {

  static func location(forData data: Data) -> Int { return Int(data[62] & 0x3f) }
    

}

function bankSysexData(location) {
  return [
    // patch data
    ['syx', sysexData],
    // write request
    ['syx', [0xf0, 0x42, ['+', 0x30, 'channel'], 0x03, 0x11, location, 0xf7]],
  ]
}

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 64,
  initFile: "dw8k-voice-bank-init",
  createFile: {
    locationMap: bankSysexData,
  },
  // 3648 is data from fetch (no write requests)
  // 4096 is file data with write requests
  // 4224 is a proprietary format that we can still parse...
  //    https://www.pallium.com/bryan/dwpatches.php
  validSizes: ['auto', 3648, 4224],
}

class DW8KVoiceBank : TypicalTypedSysexPatchBank<DW8KVoicePatch>, VoiceBank {
  
  override class var fileDataCount: Int { return patchCount * 64 } // larger patch file size

  required public init(data: Data) {
    let sysex = SysexData(data: data)
    super.init(patches: (0..<64).map {
      let p: Patch
      switch sysex.count {
      case 64:
        p = Patch(data: sysex[$0])
      case 128:
        // assumes bank file is 64 patches, in order, with every other msg being the write request
        p = Patch(data: sysex[$0 * 2])
      default:
        p = Patch()
      }
      p.name = "Patch \(($0 / 8) + 1)\(($0 % 8) + 1)"
      return p
    })
  }
  
}

