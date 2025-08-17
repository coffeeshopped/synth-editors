

//  override class func random() -> Patch {
//
//    let p = self.init()
//
//    p.name = self.randomName()
//
//    for (key, param) in template.params {
//      // initialize values dict for every param, because some won't get filled in by init data
//      // ie a vocoder patch won't init all of the synth voice values
//      p.values[key] = NSNumber(value: param.randomize() as Int)
//    }
//
//    // make all the midi channels global
//    p.values["TimbreChannel-1"] = NSNumber(value: -1 as Int)
//    p.values["TimbreChannel-2"] = NSNumber(value: -1 as Int)
//    p.values["TimbreChannel-V"] = NSNumber(value: -1 as Int)
//
//    // make the pans center
//    p.values["Pan-1"] = NSNumber(value: 0 as Int)
//    p.values["Pan-2"] = NSNumber(value: 0 as Int)
//
//    return p
//  }

// LFO options
const lfo1WaveOptions = ["Saw", "Square", "Tri", "S/H"]
const lfo2WaveOptions = ["Saw", "Square (+)", "Sine", "S/H"]
const keySyncOptions = ["Off", "Timbre", "Voice"]
const syncNoteOptions = ["1/1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"]

// common options
const voiceAssignOptions = ["Mono", "Poly", "Unison"]
const triggerOptions = ["Single", "Multi"]

const hiFreqOptions = ["1000", "1250", "1500", "1750", "2000", "2250", "2500", "2750", "3000", "3250", "3500", "3750", "4000", "4250", "4500", "4750", "5000", "5250", "5500", "5750", "6000", "7000", "8000", "9000", "10k", "11k", "12k", "14k", "16k", "18k"]

const loFreqOptions = ["40", "50", "60", "80", "100", "120", "140", "160", "180", "200", "220", "240", "260", "280", "300", "320", "340", "360", "380", "400", "420", "440", "460", "480", "500", "600", "700", "800", "900", "1000"]

// oscillator options
const osc1WaveOptions = ["Saw", "Pulse", "Tri", "Sin (Cross)", "Vox Wave", "DWGS", "Noise", "Audio In"]
const dwgsWaveOptions = ["SynSine1", "SynSine2", "SynSine3", "SynSine4", "SynSine5", "SynSine6", "SynSine7", "SynBass1", "SynBass2", "SynBass3", "SynBass4", "SynBass5", "SynBass6", "SynBass7", "SynWave1", "SynWave2", "SynWave3", "SynWave4", "SynWave5", "SynWave6", "SynWave7", "SynWave8", "SynWave9", "5thWave1", "5thWave2", "5thWave3", "Digi1", "Digi2", "Digi3", "Digi4", "Digi5", "Digi6", "Digi7", "Digi8", "Endless", "E.Piano1", "E.Piano2", "E.Piano3", "E.Piano4", "Organ1", "Organ2", "Organ3", "Organ4", "Organ5", "Organ6", "Organ7", "Clav1", "Clav2", "Guitar1", "Guitar2", "Guitar3", "Bass1", "Bass2", "Bass3", "Bass4", "Bass5", "Bell1", "Bell2", "Bell3", "Bell4", "Voice1", "Voice2", "Voice3", "Voice4"]


// patch source/dest
const mkSources = OptionsParam.makeOptions(["Filter Env", "Amp Env", "LFO1", "LFO2", "Velocity", "Key Track",
                                                 "Pitch", "Mod"])

const destinations = ["Pitch", "Osc2 Pitch", "Osc1 Ctrl 1", "Noise Level", "Cutoff", "Amp", "Pan", "LFO2 Freq"]

// shift the bipolar range
function rangeShift(parm) {
  parm.dispOff = -64
  parm.rng = [parm.rng[0] + 64, parm.rng[1] + 64]
}

const parms = [
  ["trigger/length", { b: 14, bits: [0, 2], max: 7, dispOff: 1 }],
  { prefix: 'trigger', count: 8, block: (i) => [
    ["trigger/$0", { b: 15, bit: i }],
  ] },
  ["voice/mode", { b: 16, bits: [4, 5], opts: Array.sparse([
    [0, "Single"],
    [2, "Layer"],
    [3, "Vocoder"],
    ]) }],
  ["delay/sync/note", { b: 19, bits: [0, 3], opts: ["1/32", "1/24", "1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1/1"] }],
  ["delay/tempo/sync", { b: 19, bit: 7 }],
  ["delay/time", { p: -40, b: 20 }],
  ["delay/depth", { p: -41, b: 21 }],
  ["delay/type", { b: 22, opts: ["Stereo", "Cross ", "Left/Right"] }],
  ["mod/speed", { p: -38, b: 23 }],
  ["mod/depth", { p: -39, b: 24 }],
  ["mod/type", { b: 25, opts: ["Cho/Flg", "Ensemble", "Phaser"] }],
  ["hi/freq", { b: 26, opts: hiFreqOptions }],
  ["hi/gain", rangeShift({ b: 27, rng: [-12, 12] })],
  ["lo/freq", { b: 28, opts: loFreqOptions }],
  ["lo/gain", rangeShift({ b: 29, rng: [-12, 12] })],
  ["arp/tempo", { b: 30, rng: [20, 300] }],
  ["arp/key/sync", { b: 32, bit: 0 }],
  ["arp/dest", { b: 32, bits: [4, 5], opts: ["Both", "Timbre 1", "Timbre 2"] }],
  ["arp/latch", { p: 0x0004, b: 32, bit: 6 }],
  ["arp/on", { p: 0x0002, b: 32, bit: 7 }],
  ["arp/type", { p: 0x0007, b: 33, bits: [0, 3], opts: ["Up", "Down", "Alt1", "Alt2", "Random", "Trigger"] }],
  ["arp/range", { p: 0x0003, b: 33, bits: [4, 7], max: 3, dispOff: 1 }],
  ["arp/gate/time", { p: 0x000a, b: 34, max: 100 }],
  ["arp/resolution", { b: 35, opts: ["1/24", "1/16", "1/12", "1/8", "1/6", "1/4"] }],
  ["arp/swing", { b: 36, rng: [-100, 100] }],
  ["key/octave", rangeShift({ b: 37, rng: [-3, 3] })],
  
  
  // timbre mode
  { prefix: 'tone', count: 2, bx: 108, block: [
    { b: 38, offset: [
      ["voice/assign", { b: 1, bits: [6, 7], opts: voiceAssignOptions }],
      ["trigger/mode", { b: 1, bit: 3, opts: triggerOptions }],
      ["unison/tune", { b: 2, max: 99 }],
      ["tune", rangeShift({ b: 3, rng: [-50, 50] })],
      ["porta", { p: -1, b: 15 }],
      ["bend", rangeShift({ b: 4, rng: [-12, 12] })],
      ["transpose", rangeShift({ b: 5, rng: [-24, 24] })],
      ["vib/amt", rangeShift({ b: 6, rng: [-63, 63] })],
      
      ["osc/0/wave/mode", { p: -2, b: 7, opts: osc1WaveOptions }],
      ["osc/0/ctrl/0", { p: -3, b: 8 }],
      ["osc/0/ctrl/1", { p: -4, b: 9 }],
      ["osc/0/wave", { p: -4, b: 10, opts: dwgsWaveOptions }], // PARM SAME AS CTRL 2
      
      ["mod/select", { p: -6, b: 12, bits: [4, 5], opts: ["Off", "Ring", "Sync", "Ring/Sync"] }],
      ["osc/1/wave", { p: -5, b: 12, bits: [0, 1], opts: ["Saw", "Square", "Tri"] }],
      ["osc/1/semitone", rangeShift({ p: -7, b: 13, rng: [-24, 24] })],
      ["osc/1/tune", rangeShift({ p: -8, b: 14, rng: [-63, 63] })],
      
      ["osc/0/level", { p: -9, b: 16 }],
      ["osc/1/level", { p: -10, b: 17 }],
      ["noise/level", { p: -11, b: 18 }],
      
      ["filter/type", { p: -12, b: 19, opts: ["24LPF", "12LPF", "12BPF", "12HPF"] }],
      ["cutoff", { p: -13, b: 20 }],
      ["reson", { p: -14, b: 21 }],
      ["filter/env/amt", rangeShift({ p: -15, b: 22, rng: [-63, 63] })],
      ["filter/velo", rangeShift({ b: 23, rng: [-63, 63] })],
      ["filter/key/trk", rangeShift({ p: -16, b: 24, rng: [-63, 63] })],
      
      ["amp/level", { p: -17, b: 25 }],
      ["pan", rangeShift({ p: -18, b: 26, rng: [-63, 63] })],
      ["amp/mode", { p: -19, b: 27, bit: 6, opts: ["EG2", "Gate"] }],
      ["dist", { p: -20, b: 27, bit: 0 }],
      ["amp/velo", rangeShift({ b: 28, rng: [-63, 63] })],
      ["amp/key/trk", rangeShift({ b: 29, rng: [-63, 63] })],
      
      ["env/0/attack", { p: -21, b: 30 }],
      ["env/0/decay", { p: -22, b: 31 }],
      ["env/0/sustain", { p: -23, b: 32 }],
      ["env/0/release", { p: -24, b: 33 }],
      ["env/0/reset", { b: 1, bit: 4 }],
      
      ["env/1/attack", { p: -25, b: 34 }],
      ["env/1/decay", { p: -26, b: 35 }],
      ["env/1/sustain", { p: -27, b: 36 }],
      ["env/1/release", { p: -28, b: 37 }],
      ["env/1/reset", { b: 1, bit: 5 }],
      
      ["lfo/0/key/sync", { b: 38, bits: [4, 5], opts: keySyncOptions }],
      ["lfo/0/wave", { p: -29, b: 38, bits: [0, 1], opts: lfo1WaveOptions }],
      ["lfo/0/freq", { p: -30, b: 39 }],
      ["lfo/0/tempo/sync", { b: 40, bit: 7 }],
      ["lfo/0/sync/note", { p: -30, b: 40, bits: [0, 4], opts: syncNoteOptions }],
      
      ["lfo/1/key/sync", { b: 41, bits: [4, 5], opts: keySyncOptions }],
      ["lfo/1/wave", { p: -31, b: 41, bits: [0, 1], opts: lfo2WaveOptions }],
      ["lfo/1/freq", { p: -32, b: 42 }],
      ["lfo/1/tempo/sync", { b: 43, bit: 7 }],
      ["lfo/1/sync/note", { p: -32, b: 43, bits: [0, 4], opts: syncNoteOptions }],
      
      { prefix: 'patch', count: 4, bx: 2, block: (i) => [
        ["src", { p: 0x0400 + i, b: 44, bits: [0, 3], opts: mkSources }],
        ["amt", rangeShift({ p: -33 - i, b: 45, rng: [-63, 63] })],
        ["dest", { p: 0x0408 + i, b: 44, bits: [4, 7], opts: destinations }],
      ] },
    ] },
  },
  
  /**
   * VOCODER MODE
   */
  { prefix: 'vocoder', block: [
    { b: 38, offset: block: [
      ["voice/assign", { b: 1, bits: [6, 7], opts: voiceAssignOptions }],
      ["trigger/mode", { b: 1, bit: 3, opts: triggerOptions }],
      ["unison/tune", { b: 2, max: 99 }],
      ["tune", rangeShift({ b: 3, rng: [-50, 50] })],
      ["bend", rangeShift({ b: 4, rng: [-12, 12] })],
      ["transpose", rangeShift({ b: 5, rng: [-24, 24] })],
      ["vib/amt", rangeShift({ b: 6, rng: [-63, 63] })],
      
      ["osc/0/wave/mode", { p: -2, b: 7, opts: osc1WaveOptions }],
      ["osc/0/ctrl/0", { p: -3, b: 8 }],
      ["osc/0/ctrl/1", { p: -4, b: 9 }],
      ["osc/0/wave", { b: 10, opts: dwgsWaveOptions }],
      ["porta", { p: -1, b: 14 }],
      
      ["osc/0/level", { p: -9, b: 15 }],
      ["extAudio/level", { p: -10, b: 16 }],
      ["noise/level", { p: -11, b: 17 }],
      
      ["hi/pass/level", { p: -7, b: 18 }],
      ["extAudio/gate/sens", { b: 19 }],
      ["extAudio/threshold", { p: -8, b: 20 }],
      ["hi/pass/gate", { b: 12, bit: 0 }],
      
      ["formant/shift", { p: -12, b: 21, opts: ["0", "+1", "+2", "-1", "-2"] }],
      ["cutoff", rangeShift({ p: -13, b: 22, rng: [-63, 63] })],
      ["reson", { p: -14, b: 23 }],
      ["filter/mod/src", { p: 0x0400, b: 24, opts: Array.sparse([
        [1, "Amp Env"],
        [2, "LFO1"],
        [3, "LFO2"],
        [4, "Velocity"],
        [5, "Key Track"],
        [6, "Pitch Bend"],
        [7, "Mod"],
      ]) }],
      
      ["filter/mod/amt", rangeShift({ p: -15, b: 25, rng: [-63, 63] })],
      ["env/follow/sens", { p: -16, b: 26, iso: ['switch', [
        [[0, 126], []],
        [127, 'Hold'],
      ]] }],
      
      ["amp/level", { p: -17, b: 27 }],
      ["direct/level", { p: -18, b: 28 }],
      ["dist", { p: -20, b: 29, bit: 0 }],
      ["amp/velo", rangeShift({ b: 30, rng: [-63, 63] })],
      ["amp/key/trk", rangeShift({ b: 31, rng: [-63, 63] })],
      
      ["env/1/attack", { p: -25, b: 36 }],
      ["env/1/decay", { p: -26, b: 37 }],
      ["env/1/sustain", { p: -27, b: 38 }],
      ["env/1/release", { p: -28, b: 39 }],
      ["env/1/reset", { b: 1, bit: 5 }], // parm # is made up
      
      ["lfo/0/wave", { p: -29, b: 40, bits: [0, 1], opts: lfo1WaveOptions }],
      ["lfo/0/freq", { p: -30, b: 41 }],
      ["lfo/0/tempo/sync", { b: 42, bit: 7 }],
      ["lfo/0/sync/note", { b: 42, bits: [0, 4], opts: syncNoteOptions }],
      ["lfo/0/key/sync", { b: 40, bits: [4, 5], opts: keySyncOptions }],
      
      ["lfo/1/wave", { p: -31, b: 43, bits: [0, 1], opts: lfo2WaveOptions }],
      ["lfo/1/freq", { p: -32, b: 44 }],
      ["lfo/1/tempo/sync", { b: 45, bit: 7 }],
      ["lfo/1/sync/note", { b: 45, bits: [0, 4], opts: syncNoteOptions }],
      ["lfo/1/key/sync", { b: 43, bits: [4, 5], opts: keySyncOptions }],
      
      // each pair of channels is same value
      { prefix: 'level', count: 8, bx: 2, px: 2, block: [
        ["", { p: 0x0410, b: 46 }],
      ] },
      { prefix: 'pan', count: 8, bx: 2, px: 2, block: [
        ["pan/step", rangeShift({ p: 0x0420, b: 62, rng: [-63, 63] })],
      ] },
      { prefix: 'env/follow/hold', count: 16, bx: 4, block: [
        ["", { b: 78 }],
      ] },
    ] },
  ] }
]

  subscript(path: SynthPath) -> Int? {
  get {
    guard let param = type(of: self).params[path] else { return nil }
    switch path {
    case "arp/tempo":
      return (Int(bytes[30]) << 8) + Int(bytes[31])
    case "tone/0/channel", "tone/1/channel", "vocoder/channel", "arp/swing":
      return Int(Int8(bitPattern: bytes[param.byte]))
    case "trigger/0", "trigger/1", "trigger/2", "trigger/3", "trigger/4", "trigger/5", "trigger/6", "trigger/7":
      return 1 - (unpack(param: param) ?? 0)
    default:
      return unpack(param: param)
    }
  }
  set {
    guard let param = type(of: self).params[path],
      let newValue = newValue else { return }
    if path.starts(with: "vocoder/level") {
      bytes[param.byte] = UInt8(newValue)
      bytes[param.byte+1] = UInt8(newValue)
    }
    else if path.starts(with: "vocoder/pan") {
      bytes[param.byte] = UInt8(newValue)
      bytes[param.byte+1] = UInt8(newValue)
    }
    else if path.starts(with: "vocoder/env/follow/hold") {
      // rough setting for this very high-res value
      bytes[param.byte] = UInt8(newValue)
      bytes[param.byte+1] = UInt8(newValue)
      bytes[param.byte+2] = UInt8(newValue)
      bytes[param.byte+3] = UInt8(newValue)
    }
    else {
      switch path {
      case "arp/tempo":
        bytes[param.byte] = UInt8(newValue >> 8)
        bytes[param.byte+1] = UInt8(newValue & 0xff)
      case "tone/0/channel", "tone/1/channel", "vocoder/channel", "arp/swing":
        bytes[param.byte] = UInt8(bitPattern: Int8(newValue))
      case "trigger/0", "trigger/1", "trigger/2", "trigger/3", "trigger/4", "trigger/5", "trigger/6", "trigger/7":
        pack(value: 1 - newValue, forParam: param)
      default:
        pack(value: newValue, forParam: param)
      }
    }
  }
}

const sysexData = [0xf0, 0x42, ['+', 0x30, 'channel'], 0x58, 0x40, ['pack78', {count: 291}], 0xf7]

const patchTruss = {
  single: 'voice',
  namePack: [0, 11],
  initFile: "mk-init",
  parseBody: ['>', ['bytes', { start: 5, count: 291 }], ['unpack87']]
}




const bankSysex = [0xf0, 0x42, ['+', 0x30, 'channel'], 0x58, 0x4c]
  let bytesToPack = [UInt8](patches.map { $0.bytes }.joined())
  data.append(Data.pack78(bytes: bytesToPack, count: type(of: self).contentByteCount))
  data.append(0xf7)
}

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 128, 
  initFile: "ms2k-bank-init",
  // 37163: size as documented
  // 37392: a bank from Korg. wtf.
  validSizes: ['auto', 37392],
}

static var fileDataCount: Int { return 37163 }
static var contentByteCount: Int { return 37157 }


static func korgPatches(fromData data: Data) -> [Patch] {
  let bytesPerPatch = 254
  let rawBytes = data.unpack87(count: bytesPerPatch * patchCount, inRange: 5..<(5+contentByteCount))
  return (0..<patchCount).map {
    let offset = $0 * bytesPerPatch
    guard offset + bytesPerPatch <= rawBytes.count else { return Patch.init() }
    let p = Patch.init(rawBytes: [UInt8](rawBytes[offset..<(offset + bytesPerPatch)]))
    if p.name == "" {
      p.name = "Patch \($0+1)"
    }
    return p
  }
}
class MicrokorgBank : KorgMBank {
  
  required init(data: Data) {
    let bytesPerPatch = 254
    let rawBytes = data.unpack87(count: bytesPerPatch * Self.patchCount, inRange: 5..<(5+Self.contentByteCount))
    patches = (0..<Self.patchCount).map {
      let offset = $0 * bytesPerPatch
      guard offset + bytesPerPatch <= rawBytes.count else { return Patch() }
      let p = Patch(rawBytes: [UInt8](rawBytes[offset..<(offset + bytesPerPatch)]))
      if p.name == "" {
        let letter = $0 < 64 ? "A" : "B"
        let bank = ($0 % 64) / 8 + 1
        let slot = $0 % 8 + 1
        p.name = "Patch \(letter)\(bank)\(slot)"
      }
      return p
    }
  }

}
