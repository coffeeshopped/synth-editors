
// shift the bipolar range
function rangeShift(parm) {
  parm.dispOff = -64
  parm.rng = [parm.rng[0] + 64, parm.rng[1] + 64]
}


// LFO options
const lfo1Waves = ["Saw", "Square", "Tri", "S/H"]
const lfo2Waves = ["Saw", "Square (+)", "Sine", "S/H"]
const keySyncs = ["Off", "Timbre", "Voice"]
const syncNotes = ["1/1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"]

// common options
const voiceAssigns = ["Mono", "Poly", "Unison"]
const voicePrioritys = ["Last", "Low", "High"]
const triggers = ["Single", "Multi"]

const hiFreqs = ["1000", "1250", "1500", "1750", "2000", "2250", "2500", "2750", "3000", "3250", "3500", "3750", "4000", "4250", "4500", "4750", "5000", "5250", "5500", "5750", "6000", "7000", "8000", "9000", "10k", "11k", "12k", "14k", "16k", "18k"]

const loFreqs = ["40", "50", "60", "80", "100", "120", "140", "160", "180", "200", "220", "240", "260", "280", "300", "320", "340", "360", "380", "400", "420", "440", "460", "480", "500", "600", "700", "800", "900", "1000"]

// oscillator options
const osc1Waves = ["Saw", "Pulse", "Tri", "Sin (Cross)", "Vox Wave", "DWGS", "Noise", "Audio In"]
const dwgsWaves = ["SynSine1", "SynSine2", "SynSine3", "SynSine4", "SynSine5", "SynSine6", "SynSine7", "SynBass1", "SynBass2", "SynBass3", "SynBass4", "SynBass5", "SynBass6", "SynBass7", "SynWave1", "SynWave2", "SynWave3", "SynWave4", "SynWave5", "SynWave6", "SynWave7", "SynWave8", "SynWave9", "5thWave1", "5thWave2", "5thWave3", "Digi1", "Digi2", "Digi3", "Digi4", "Digi5", "Digi6", "Digi7", "Digi8", "Endless", "E.Piano1", "E.Piano2", "E.Piano3", "E.Piano4", "Organ1", "Organ2", "Organ3", "Organ4", "Organ5", "Organ6", "Organ7", "Clav1", "Clav2", "Guitar1", "Guitar2", "Guitar3", "Bass1", "Bass2", "Bass3", "Bass4", "Bass5", "Bell1", "Bell2", "Bell3", "Bell4", "Voice1", "Voice2", "Voice3", "Voice4"]


// patch source/dest
const sources = ["EG1", "EG2", "LFO1", "LFO2", "Velocity", "Key Track", "MIDI 1" , "MIDI 2"]

const destinations = ["Pitch", "Osc2 Pitch", "Osc1 Ctrl 1", "Noise Level", "Cutoff", "Amp", "Pan", "LFO2 Freq"]
const parms = [
  { inc: 1, p: 16, block: [
    ["voice/mode", { b: 16, bits: [4, 5], opts: ["Single", "Split", "Dual", "Vocoder"] }],
    ["split/pt", { b: 18 }],
    ["timbre/voice", { b: 16, bits: [6, 7], opts: ["1+3", "2+2", "3+1"] }],
    ["scale/type", { b: 17, bits: [0, 3], opts: ["Equal Temp", "Pure Major", "Pure Minor", "Arabic", "Pythagorea", "Werckmeist", "Kirnberger", "Slendoro", "Pelog", "User Scale"] }],
    ["scale/key", { b: 17, bits: [4, 7], max: 11 }],
    ["delay/type", { b: 22, opts: ["Stereo", "Cross ", "Left/Right"] }],
    ["delay/time", { b: 20 }],
    ["delay/depth", { b: 21 }],
    ["mod/type", { b: 25, opts: ["Cho/Flg", "Ensemble", "Phaser"] }],
    ["mod/speed", { b: 23 }],
    ["mod/depth", { b: 24 }],
    ["arp/on", { b: 32, bit: 7 }],
    ["arp/type", { b: 33, bits: [0, 3], opts: ["Up", "Down", "Alt1", "Alt2", "Random", "Trigger"] }],
    ["arp/range", { b: 33, bits: [4, 7], max: 3, dispOff: 1 }],
    ["arp/latch", { b: 32, bit: 6 }],
    ["arp/tempo", { b: 30, rng: [20, 300] }],
    ["arp/gate/time", { b: 34, max: 100 }],
    ["arp/dest", { b: 32, bits: [4, 5], opts: ["Both", "Timbre 1", "Timbre 2"] }],
    ["arp/key/sync", { b: 32, bit: 0 }],
    ["arp/resolution", { b: 35, opts: ["1/24", "1/16", "1/12", "1/8", "1/6", "1/4"] }],
    ["arp/swing", { b: 36, rng: [-100, 100] }],
    ["hi/freq", { b: 26, opts: hiFreqs }],
    ["hi/gain", rangeShift({ p: 0x26, b: 27, rng: [-12, 12] })],
    ["lo/freq", { b: 28, opts: loFreqs }],
    ["lo/gain", rangeShift({ p: 0x28, b: 29, rng: [-12, 12] })],
    ["delay/tempo/sync", { b: 19, bit: 7 }],
    ["delay/sync/note", { b: 19, bits: [0, 3], opts: ["1/32", "1/24", "1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1/1"] }],
  ] },
  
  // timbre mode
  { prefix: 'tone', count: 2, bx: 108, px: 0x90, block: [
    { b: 38, p: 0x40, offset: [
      // this param is signed, hence the custom pack/unpack
      ["channel", { p: 3, b: 0, rng: [-1, 15], dispOff: 1 }],
      ["voice/assign", { p: 0, b: 1, bits: [6, 7], opts: voiceAssigns }],
      ["trigger/mode", { p: 1, b: 1, bit: 3, opts: triggers }],
      ["voice/priority", { p: 0x3e, b: 1, bits: [0, 1], opts: voicePrioritys }],
      ["unison/tune", { p: 2, b: 2, max: 99 }],
      ["tune", rangeShift({ p: 5, b: 3, rng: [-50, 50] })],
      ["porta", { p: 7, b: 15 }],
      ["bend", rangeShift({ p: 8, b: 4, rng: [-12, 12] })],
      ["transpose", rangeShift({ p: 4, b: 5, rng: [-24, 24] })],
      ["vib/amt", rangeShift({ p: 6, b: 6, rng: [-63, 63] })],
      
      ["osc/0/wave/mode", { p: 9, b: 7, opts: osc1Waves }],
      ["osc/0/ctrl/0", { p: 0xa, b: 8 }],
      ["osc/0/ctrl/1", { p: 0xb, b: 9 }],
      ["osc/0/wave", { p: 0xc, b: 10, opts: dwgsWaves }],
      
      ["mod/select", { p: 0xe, b: 12, bits: [4, 5], opts: ["Off", "Ring", "Sync", "Ring/Sync"] }],
      ["osc/1/wave", { p: 0xd, b: 12, bits: [0, 1], opts: ["Saw", "Square", "Tri"] }],
      ["osc/1/semitone", rangeShift({ p: 0xf, b: 13, rng: [-24, 24] })],
      ["osc/1/tune", rangeShift({ p: 0x10, b: 14, rng: [-63, 63] })],
      
      ["osc/0/level", { p: 0x11, b: 16 }],
      ["osc/1/level", { p: 0x12, b: 17 }],
      ["noise/level", { p: 0x13, b: 18 }],
      
      ["filter/type", { p: 0x14, b: 19, opts: ["24LPF", "12LPF", "12BPF", "12HPF"]
    }],
      ["cutoff", { p: 0x15, b: 20 }],
      ["reson", { p: 0x16, b: 21 }],
      ["filter/env/amt", rangeShift({ p: 0x17, b: 22, rng: [-63, 63] })],
      ["filter/velo", rangeShift({ p: 0x22, b: 23, rng: [-63, 63] })],
      ["filter/key/trk", rangeShift({ p: 0x18, b: 24, rng: [-63, 63] })],
      
      ["amp/level", { p: 0x19, b: 25 }],
      ["pan", rangeShift({ p: 0x1a, b: 26, rng: [-63, 63] })],
      ["amp/mode", { p: 0x1b, b: 27, bit: 6, opts: ["EG2", "Gate"] }],
      ["dist", { p: 0x1c, b: 27, bit: 0 }],
      ["amp/velo", rangeShift({ p: 0x27, b: 28, rng: [-63, 63] })],
      ["amp/key/trk", rangeShift({ p: 0x1d, b: 29, rng: [-63, 63] })],
      
      ["env/0/attack", { p: 0x1e, b: 30 }],
      ["env/0/decay", { p: 0x1f, b: 31 }],
      ["env/0/sustain", { p: 0x20, b: 32 }],
      ["env/0/release", { p: 0x21, b: 33 }],
      ["env/0/reset", { p: 0x7c, b: 1, bit: 4 }],
      
      ["env/1/attack", { p: 0x23, b: 34 }],
      ["env/1/decay", { p: 0x24, b: 35 }],
      ["env/1/sustain", { p: 0x25, b: 36 }],
      ["env/1/release", { p: 0x26, b: 37 }],
      ["env/1/reset", { p: 0x7d, b: 1, bit: 5 }],
      
      ["lfo/0/key/sync", { p: 0x2c, b: 38, bits: [4, 5], opts: keySyncs }],
      ["lfo/0/wave", { p: 0x28, b: 38, bits: [0, 1], opts: lfo1Waves }],
      ["lfo/0/freq", { p: 0x29, b: 39 }],
      ["lfo/0/tempo/sync", { p: 0x2b, b: 40, bit: 7 }],
      ["lfo/0/sync/note", { p: 0x2a, b: 40, bits: [0, 4], opts: syncNotes }],
      
      ["lfo/1/key/sync", { p: 0x31, b: 41, bits: [4, 5], opts: keySyncs }],
      ["lfo/1/wave", { p: 0x2d, b: 41, bits: [0, 1], opts: lfo2Waves }],
      ["lfo/1/freq", { p: 0x2e, b: 42 }],
      ["lfo/1/tempo/sync", { p: 0x30, b: 43, bit: 7 }],
      ["lfo/1/sync/note", { p: 0x2f, b: 43, bits: [0, 4], opts: syncNotes }],
      
      { prefix: 'patch', count: 4, bx: 2, px: 3, block: [
        ["src", { p: 0x32, b: 44, bits: [0, 3], opts: sources }],
        ["amt", rangeShift({ p: 0x34, b: 45, rng: [-63, 63] })],
        ["dest", { p: 0x33, b: 44, bits: [4, 7], opts: destinations }],
      ] },
      
      ["seq/on", { p: 0x40, b: 52, bit: 7 }],
      ["run/mode", { p: 0x43, b: 52, bit: 6 }],
      ["seq/resolution", { p: 0x45, b: 52, bits: [0, 4], opts: ["1/48", "1/32", "1/24", "1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1/1"] }],
      ["seq/last/step", { p: 0x41, b: 53, bits: [4, 7], max: 15, dispOff: 1 }],
      ["seq/type", { p: 0x42, b: 53, bits: [2, 3], opts: ["Forward", "Reverse", "Alt1", "Alt2"] }],
      ["seq/key/sync", { p: 0x44, b: 53, bits: [0, 1], opts: keySyncs }],
      { prefix: 'seq', count: 3, bx: 18, px: 0x12, block: [
        ["knob", { p: 0x46, b: 54, opts: ["None", "Pitch", "Step Length", "Portamento", "Osc1 Ctrl 1", "Osc1 Ctrl 2", "Osc2 Semi", "Osc2 Tune", "Osc1 Level", "Osc2 Level", "Noise Level", "Cutoff", "Resonance", "EG1 Int", "Filter Key Trk", "Amp Level", "Pan", "EG1 Attack", "EG1 Decay", "EG1 Sustain", "EG1 Release", "EG2 Attack", "EG2 Decay", "EG2 Sustain", "EG2 Release", "LFO1 Freq", "LFO2 Freq", "Patch1 Int", "Patch2 Int", "Patch3 Int", "Patch4 Int"] }],
        ["motion/type", { p: 0x47, b: 55, opts: ["Smooth","Step"] }],
        { prefix: 'step', count: 16, bx: 1, px: 1, block: [
          ["", rangeShift({ p: 0x48, b: 56, rng: [-63, 63] })],
        ] },
      ] },
    },
  },
  
  /**
   * VOCODER MODE
   */
  { prefix: 'vocoder', block: [
    { b: 38, p: 0x160, offset: block: [
      // this param is signed, hence the custom pack/unpack
      ["channel", { p: 0x3, b: 0, rng: [-1, 15], dispOff: 1 }],
      ["voice/assign", { p: 0x0, b: 1, bits: [6, 7], opts: voiceAssigns }],
      ["trigger/mode", { p: 0x1, b: 1, bit: 3, opts: triggers }],
      ["voice/priority", { p: 0x4, b: 1, bits: [0, 1], opts: voicePrioritys }],
      ["unison/tune", { p: 0x2, b: 2, max: 99 }],
      ["tune", rangeShift({ p: 0x9, b: 3, rng: [-50, 50] })],
      ["bend", rangeShift({ p: 0xc, b: 4, rng: [-12, 12] })],
      ["transpose", rangeShift({ p: 0x8, b: 5, rng: [-24, 24] })],
      ["vib/amt", rangeShift({ p: 0xa, b: 6, rng: [-63, 63] })],
      
      ["osc/0/wave/mode", { p: 0x10, b: 7, opts: osc1Waves }],
      ["osc/0/ctrl/0", { p: 0x11, b: 8 }],
      ["osc/0/ctrl/1", { p: 0x12, b: 9 }],
      ["osc/0/wave", { p: 0x13, b: 10, opts: dwgsWaves }],
      ["porta", { p: 0xb, b: 14 }],
      
      ["osc/0/level", { p: 0x18, b: 15 }],
      ["extAudio/level", { p: 0x19, b: 16 }],
      ["noise/level", { p: 0x1a, b: 17 }],
      
      ["hi/pass/level", { p: 0x1b, b: 18 }],
      ["extAudio/gate/sens", { p: 0x1c, b: 19 }],
      ["extAudio/threshold", { p: 0x1d, b: 20 }],
      ["hi/pass/gate", { p: 0x1e, b: 12, bit: 0 }],
      
      ["formant/shift", { p: 0x20, b: 21, opts: ["0", "+1", "+2", "-1", "-2"] }],
      ["cutoff", rangeShift({ p: 0x21, b: 22, rng: [-63, 63] })],
      ["reson", { p: 0x22, b: 23 }],
      ["filter/mod/src", { p: 0x23, b: 24, opts: sources }],
      ["filter/mod/amt", rangeShift({ p: 0x24, b: 25, rng: [-63, 63] })],
      ["env/follow/sens", { p: 0x25, b: 26 }],
      
      ["amp/level", { p: 0x28, b: 27 }],
      ["direct/level", { p: 0x29, b: 28 }],
      ["dist", { p: 0x2a, b: 29, bit: 0 }],
      ["amp/velo", rangeShift({ p: 0x2b, b: 30, rng: [-63, 63] })],
      ["amp/key/trk", rangeShift({ p: 0x2c, b: 31, rng: [-63, 63] })],
      
      ["env/0/attack", { p: 0x34, b: 32 }],
      ["env/0/decay", { p: 0x35, b: 33 }],
      ["env/0/sustain", { p: 0x36, b: 34 }],
      ["env/0/release", { p: 0x37, b: 35 }],
      ["env/0/reset", { p: 0x6, b: 1, bit: 4 }], // parm # is made up
      
      ["env/1/attack", { p: 0x30, b: 36 }],
      ["env/1/decay", { p: 0x31, b: 37 }],
      ["env/1/sustain", { p: 0x32, b: 38 }],
      ["env/1/release", { p: 0x33, b: 39 }],
      ["env/1/reset", { p: 0x7, b: 1, bit: 5 }], // parm # is made up
      
      ["lfo/0/wave", { p: 0x38, b: 40, bits: [0, 1], opts: lfo1Waves }],
      ["lfo/0/freq", { p: 0x39, b: 41 }],
      ["lfo/0/tempo/sync", { p: 0x3b, b: 42, bit: 7 }],
      ["lfo/0/sync/note", { p: 0x3a, b: 42, bits: [0, 4], opts: syncNotes }],
      ["lfo/0/key/sync", { p: 0x3c, b: 40, bits: [4, 5], opts: keySyncs }],
      
      ["lfo/1/wave", { p: 0x40, b: 43, bits: [0, 1], opts: lfo2Waves }],
      ["lfo/1/freq", { p: 0x41, b: 44 }],
      ["lfo/1/tempo/sync", { p: 0x43, b: 45, bit: 7 }],
      ["lfo/1/sync/note", { p: 0x42, b: 45, bits: [0, 4], opts: syncNotes }],
      ["lfo/1/key/sync", { p: 0x44, b: 43, bits: [4, 5], opts: keySyncs }],
      
      { prefix: 'level', count: 16, bx: 1, px: 1, block: [
        ["", { p: 0x50, b: 46 }],
      ] },
      { prefix: 'pan', count: 16, bx: 1, px: 1, block: [
        ["", rangeShift({ p: 0x60, b: 62, rng: [-63, 63] })],
      ] },
    }
  }
]

  
const sysexData = [0xf0, 0x42, ['+', 0x30, 'channel'], 0x58, 0x40, ['pack78'], 0xf7]

const patchTruss = {
  single: 'voice',
  namePack: [0, 11],
  initFile: "ms2k-init",
  parseBody: ['>', ['bytes', { start: 5, count: 291 }], ['unpack87']]
}

  
//  override class func random() -> Patch {
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
//
//    return p
//  }
  
  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      switch path {
      case "arp/tempo":
        return (Int(bytes[30]) << 8) + Int(bytes[31])
      case "tone/0/channel", "tone/1/channel", "vocoder/channel", "arp/swing":
        return Int(Int8(bitPattern: bytes[param.byte]))
      default:
        return unpack(param: param)
      }
    }
    set {
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      switch path {
      case "arp/tempo":
        bytes[param.byte] = UInt8(newValue >> 8)
        bytes[param.byte+1] = UInt8(newValue & 0xff)
      case "tone/0/channel", "tone/1/channel", "vocoder/channel", "arp/swing":
        bytes[param.byte] = UInt8(bitPattern: Int8(newValue))
      default:
        pack(value: newValue, forParam: param)
      }
    }
  }
  

const bankSysex = [0xf0, 0x42, ['+', 0x30, 'channel'], 0x58, 0x4c]
  let bytesToPack = [UInt8](patches.map { $0.bytes }.joined())
  data.append(Data.pack78(bytes: bytesToPack, count: type(of: self).contentByteCount))
  data.append(0xf7)
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
  
  }
  
const bankTruss = {
  singleBank: patchTruss,
  patchCount: 128, 
  initFile: "ms2k-bank-init",
  // 37163: size as documented
  // 37392: a bank from Korg. wtf.
  validSizes: ['auto', 37392],
}

