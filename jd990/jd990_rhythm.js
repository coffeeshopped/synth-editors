



const commonParms = [
  ["level", { b: 0x10, max: 100, dispOff: -50 }],
  ["pan", { b: 0x11, max: 100, dispOff: -50 }],
  ["analogFeel", { b: 0x12, max: 100 }],
  ["bend/down", { b: 0x13, max: 48 }],
  ["bend/up", { b: 0x14, max: 12 }],
  ["ctrl/src/0", { b: 0x15, opts: JD990CommonPatch.ctrlSrcOptions }],
  ["ctrl/src/1", { b: 0x16, opts: JD990CommonPatch.ctrlSrcOptions }],
  ["lo/freq", { b: 0x17, opts: JD800CommonPatch.loFreqOptions }],
  ["lo/gain", { b: 0x18, max: 30, dispOff: -15 }],
  ["mid/freq", { b: 0x19, opts: JD800CommonPatch.midFreqOptions }],
  ["mid/q", { b: 0x1a, opts: JD800CommonPatch.midQOptions }],
  ["mid/gain", { b: 0x1b, max: 30, dispOff: -15 }],
  ["hi/freq", { b: 0x1c, opts: JD800CommonPatch.hiFreqOptions }],
  ["hi/gain", { b: 0x1d, max: 30, dispOff: -15 }],
  
  ["fx/ctrl/src/0", { b: 0x1e, opts: JD990CommonPatch.ctrlSrcOptions }],
  ["fx/ctrl/dest/0", { b: 0x1f, opts: JD990CommonPatch.ctrlDestOptions }],
  ["fx/ctrl/depth/0", { b: 0x20, max: 100, dispOff: -50 }],
  ["fx/ctrl/src/1", { b: 0x21, opts: JD990CommonPatch.ctrlSrcOptions }],
  ["fx/ctrl/dest/1", { b: 0x22, opts: JD990CommonPatch.ctrlDestOptions }],
  ["fx/ctrl/depth/1", { b: 0x23, max: 100, dispOff: -50 }],
  
  ["chorus/rate", { b: 0x24, max: 99, iso: JD990CommonPatch.chorusRateMiso }],
  ["chorus/depth", { b: 0x25, max: 100 }],
  ["chorus/delay", { b: 0x26, max: 99, iso: JD990CommonPatch.chorusDelayIso }],
  ["chorus/feedback", { b: 0x27, max: 98, iso: JD990CommonPatch.feedBackIso }],
  ["chorus/level", { b: 0x28, max: 100 }],
  
  ["delay/mode", { b: 0x29, opts: JD990CommonPatch.delayModeOptions }],
  ["delay/mid/time", { p: 2, b: 0x2a, max: 255, iso: JD990CommonPatch.delayTimeIso }],
  ["delay/mid/level", { b: 0x2c, max: 100 }],
  ["delay/left/time", { p: 2, b: 0x2d, max: 255, iso: JD990CommonPatch.delayTimeIso }],
  ["delay/left/level", { b: 0x2f, max: 100 }],
  ["delay/right/time", { p: 2, b: 0x30, max: 255, iso: JD990CommonPatch.delayTimeIso }],
  ["delay/right/level", { b: 0x32, max: 100 }],
  ["delay/feedback", { b: 0x33, max: 98, iso:  JD990CommonPatch.feedBackIso }],
  
  ["reverb/type", { b: 0x34, opts: JD800FXPatch.reverbTypeOptions }],
  ["reverb/pre", { b: 0x35, max: 120 }],
  ["reverb/early", { b: 0x36, max: 100 }],
  ["reverb/hi/cutoff", { b: 0x37, opts: JD800FXPatch.reverbHiCutoffOptions }],
  ["reverb/time", { b: 0x38, iso: JD990CommonPatch.reverbTimeIso }],
  ["reverb/level", { b: 0x39, max: 100 }],
]

const commonWerk = {
  single: 'rhythm.common',
  parms: commonParms,
  namePack: [0, 0x0f],
  size: 0x3a,
}

const toneParms = [
  ["env/mode", { b: 0x0a, opts: ["Sustain", "No Sus"] }],
  ["mute/group", { b: 0x0b, max: 26, formatter: {
    return $0 == 0 ? "Off" : String(UnicodeScalar(UInt8(64 + $0)))
  }],
  ["fx/mode", { b: 0x0c, opts: ["EQ:Mix", "EQ+R:Mix", "EQ+C+R:Mix", "EQ+D+R:Mix", "Dir 1", "Dir 2", "Dir 3"] }],
  ["fx/level", { b: 0x0d, max: 100 }],
  // pull in normal tone params and add 0x0e to every byte value.
  { b: 0x0e, offset: Voice.toneParms },
]

const toneWerk = {
  single: 'rhythm.tone',
  parms: toneParms,
  namePack: [0, 0x09],
  size: 0x6a,
}

// class JD990RhythmKeyTonePatch : JD990TonePatch {
  // 
  // override class func startAddress(_ path: SynthPath?) -> RolandAddress {
  //   return 0x000e
  // }
// 
// }

static func location(forData data: Data) -> Int { return 0 }

static func addressables(forData data: Data) -> [SynthPath:RolandSingleAddressable] {
  if data.count == 6821 {
    return addressables(forCompactData: data)
  }
}

// Synth saves this as common + 1 msg per tone
// note this is not what a typical "compact" patch would be, hence we define below
func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
  // save common as one sysex msg
  var data = [Data]()
  if let common = addressables["common"] {
    data.append(contentsOf: common.sysexData(deviceId: deviceId, address: address))
  }

  // then parts as 1 more sysex msg, compacted
  (0..<61).forEach {
    let path: SynthPath = "tone/$0"
    guard let a = type(of: self).subpatchAddresses[path],
      let tone = addressables[path] else { return }
    data.append(contentsOf: tone.sysexData(deviceId: deviceId, address: a + address))
  }

  return data
}
const patchWerk = {
  multi: 'rhythm',
  map: ([
    ['common', 0x0000, commonWerk],
  ]).concat((8).map(i => 
    [['tone', i], 0x3a + i * 0x6a, toneWerk]
  )),
  initFile: "jd990-rhythm-init",
  // 6821 is compacted form (267-byte msgs)
  validSizes: [7206, 'auto', 6821],
}

class JD990RhythmBank : JD990Bank<JD990RhythmPatch>, RhythmBank {

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    // internal, or card
    return path?.endex == 0 ? 0x07000000 : 0x0b000000
  }
  
  override class var patchCount: Int { return 1 }
  override class var initFileName: String { return "jd990-rhythm-bank-init" }
  
  override class func isValid(fileSize: Int) -> Bool {
    return fileSize == 7206 || fileSize == fileDataCount
  }

}

