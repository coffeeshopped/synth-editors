
const modelId = 0x62

// VOICE COMMON1

  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
  return 0x100000
}

static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
  return RolandAddress([0x20, UInt8(index), 0x00])
}
  
const dataByteCount: Int = 0x29

func randomize() {
  randomizeAllParams()
  self["voice/level"] = 127
  self["filter/gain"] = ([60, 65]).random()!
  self["eq/lo/gain"] = 64
  self["eq/mid/gain"] = 64
  self["amp/env/attack"] = 64
  self["amp/env/decay"] = 64
  self["amp/env/sustain"] = 64
  self["amp/env/release"] = 64

  
  switch self["filter/type"] {
  case 0, 1, 2: // lopass
    self["cutoff"] = ([25, 127]).random()!
    self["filter/env/amt"] = ([56, 127]).random()!
  case 4: // hipass
    self["cutoff"] = ([0, 90]).random()!
    self["filter/env/amt"] = ([0, 110]).random()!
  default:
    self["filter/env/amt"] = ([54, 74]).random()!
  }
}

const filterOptions = ["LPF 24", "LPF 18", "LPF 12", "BPF", "HPF 12", "BEF"]

const distCutoffOptions = Array(freqOptions[[34, 60]])

const loFreqOptions = Array(freqOptions[[4, 40]])

const midFreqOptions = Array(freqOptions[[14, 54]])

const freqOptions = ["0", "0", "0", "0", "32", "39", "46", "53", "60", "67", "74", "81", "88", "95", "100", "115", "125", "140", "190", "240", "290", "340", "390", "440", "490", "540", "590", "640", "690", "740", "790", "840", "890", "940", "1000", "1175", "1350", "1525", "1700", "1875", "2000", "2350", "2700", "3050", "3400", "3750", "4100", "4450", "5000", "5750", "6500", "7250", "8000", "8750", "10k", "12k", "14k", "16k", "18k", "20k", "Thru"]

const midQOptions = ([10, 120]).map { String(format: "%.1f", Double($0) / 10) }

const noiseOptions = ["White", "Pink", "Up Slow", "Up Mid", "Up High", "Down Slow", "Down Mid", "Down High", "Pitch Scale 1", "Pitch Scale 2", "Pitch Scale 3", "Pitch Scale 4", "Variation 1", "Variation 2", "Variation 3", "Variation 4"]

const voiceCommon1Parms = [
  ["dist/on", { b: 0x00, max: 1 }],
  ["dist/drive", { b: 0x01, max: 64 }],
  ["dist/type", { b: 0x02, opts: ["Off","Stack", "Combo", "Tube"] }],
  ["dist/cutoff", { b: 0x03, opts: distCutoffOptions }],
  ["dist/level", { b: 0x04, max: 100 }],
  ["dist/amt", { b: 0x05 }],
  ["eq/lo/freq", { b: 0x06, opts: loFreqOptions }],
  ["eq/lo/gain", { b: 0x07, rng: 0x[34, 0]x4c, dispOff: -64 }],
  ["eq/mid/freq", { b: 0x08, opts: midFreqOptions }],
  ["eq/mid/gain", { b: 0x09, rng: 0x[34, 0]x4c, dispOff: -64 }],
  ["eq/mid/q", { b: 0x0a, opts: midQOptions }],
  
  ["cutoff", { b: 0x0c }],
  ["reson", { b: 0x0d, rng: [0, 116], dispOff: -16 }],
  ["filter/type", { b: 0x0e, opts: filterOptions }],
  ["filter/cutoff/scale/amt", { b: 0x0f, dispOff: -64 }],
  ["filter/cutoff/mod/amt", { b: 0x10, max: 99 }],
  ["filter/gain", { b: 0x11, rng: 0x[34, 0]x4c, dispOff: -64 }],
  ["filter/env/attack", { b: 0x12 }],
  ["filter/env/decay", { b: 0x13 }],
  ["filter/env/sustain", { b: 0x14 }],
  ["filter/env/release", { b: 0x15 }],
  ["filter/env/amt", { b: 0x16, dispOff: -64 }],
  ["filter/env/velo", { b: 0x17, dispOff: -64 }],
  
  ["noise/type", { b: 0x19, opts: noiseOptions }],
  ["voice/level", { b: 0x1a }],
  ["noise/level", { b: 0x1b }],
  ["mod/0/harmonic", { b: 0x1c, dispOff: -64 }],
  ["mod/1/harmonic", { b: 0x1d, dispOff: -64 }],
  ["mod/2/harmonic", { b: 0x1e, dispOff: -64 }],
  ["mod/0/fm/amt", { b: 0x1f, dispOff: -64 }],
  ["mod/1/fm/amt", { b: 0x20, dispOff: -64 }],
  ["mod/2/fm/amt", { b: 0x21, dispOff: -64 }],
  ["mod/0/env/decay", { b: 0x22, dispOff: -64 }],
  ["mod/1/env/decay", { b: 0x23, dispOff: -64 }],
  ["mod/2/env/decay", { b: 0x24, dispOff: -64 }],
  ["amp/env/attack", { b: 0x25, dispOff: -64 }],
  ["amp/env/decay", { b: 0x26, dispOff: -64 }],
  ["amp/env/sustain", { b: 0x27, dispOff: -64 }],
  ["amp/env/release", { b: 0x28, dispOff: -64 }],
]

// VOICE COMMON

  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
  return 0x100100
}

static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
  return RolandAddress([0x21, UInt8(index), 0x00])
}

const dataByteCount: Int = 0x05

func randomize() {
  self["tempo"] = ([60, 150]).random()!
}


const voiceCommonParms = [
  ["mod/select", { b: 0x00 }],
  ["scene", { b: 0x01 }],
  ["tempo", { p: 2, b: 0x02, rng: [20, 300] }],
  ["swing", { b: 0x04, rng: [50, 83] }],
]

// VOICE SCENE

  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
  let index = synthPath.i(1) ?? 0
  return RolandAddress([0x10, 0x03 + UInt8(index), 0x00])
}

static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
  let subIndex = synthPath.i(1) ?? 0
  return RolandAddress([0x40 + UInt8(subIndex), UInt8(index), 0x00])
}

const dataByteCount: Int = 0x1c


const voiceSceneParms = [
  ["cutoff", { b: 0x00 }],
  ["reson", { b: 0x01 }],
  ["filter/env/attack", { b: 0x02 }],
  ["filter/env/decay", { b: 0x03 }],
  ["filter/env/sustain", { b: 0x04 }],
  ["filter/env/release", { b: 0x05 }],
  ["filter/env/amt", { b: 0x06, dispOff: -64 }],
  ["filter/type", { b: 0x07, opts: DX200VoiceCommon1Patch.filterOptions }],
  ["voice/lfo/speed", { b: 0x08 }],
  ["extra/porta/time", { b: 0x09 }],
  ["noise/level", { b: 0x0a }],
  ["mod/0/harmonic", { b: 0x0b, dispOff: -64 }],
  ["mod/1/harmonic", { b: 0x0c, dispOff: -64 }],
  ["mod/2/harmonic", { b: 0x0d, dispOff: -64 }],
  ["mod/0/fm/amt", { b: 0x0e, dispOff: -64 }],
  ["mod/1/fm/amt", { b: 0x0f, dispOff: -64 }],
  ["mod/2/fm/amt", { b: 0x10, dispOff: -64 }],
  ["mod/0/env/decay", { b: 0x11, dispOff: -64 }],
  ["mod/1/env/decay", { b: 0x12, dispOff: -64 }],
  ["mod/2/env/decay", { b: 0x13, dispOff: -64 }],
  ["amp/env/attack", { b: 0x14, dispOff: -64 }],
  ["amp/env/decay", { b: 0x15, dispOff: -64 }],
  ["amp/env/sustain", { b: 0x16, dispOff: -64 }],
  ["amp/env/release", { b: 0x17, dispOff: -64 }],
  ["volume", { b: 0x18) // corresponds to part volume (not voice common }],
  ["pan", { b: 0x19, dispOff: -64 }],
  ["fx/send", { b: 0x1a }],
  ["param", { b: 0x1b }], // this is fx param. short like this for auto sync-mapping
]


// VOICE FREE ENV

static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
  return 0x100200
}

static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
  return RolandAddress([0x30 + UInt8(index >> 3), UInt8(index & 0b111) << 4, 0x00])
}

const dataByteCount: Int = 0x60c

const triggerOptions = ["Free", "MIDI In Notes", "All Notes", "Seq Start"]

const loopTypeOptions = ["Off", "Forward", "Forward 1/2", "Alternate", "Alternate 1/2"]

const lengthOptions = {
  var map = [
    2 : "1/2 bar",
    3 : "1 bar",
    4 : "3/2 bars",
    5 : "2 bars",
    6 : "3 bars",
    7 : "4 bars",
    8 : "6 bars",
    9 : "8 bars",
  ]
  (0xa..<0x50).forEach { map[$0] = String(format: "%.1f sec", Double($0) / 10) }
  (0x[50, 0]x60).forEach { map[$0] = String(format: "%.1f sec", Double($0 - 0x50) * 0.5 + 8) }
  return map
}()

const paramOptions = ["Off", "Porta Time", "LFO Speed", "Mod 1 Harmonic", "Mod 2 Harmonic", "Mod 3 Harmonic", "Mod All Harmonic", "Mod 1 FM Depth", "Mod 2 FM Depth", "Mod 3 FM Depth", "Mod All FM Depth", "Mod 1 EG Decay", "Mod 2 EG Decay", "Mod 3 EG Decay", "Mod All EG Decay", "Noise Level", "Filter Type", "Filter Cutoff", "Filter Reson", "FEG Attack", "FEG Decay", "FEG Sustain", "FEG Release", "FEG Depth", "AEG Attack", "AEG Decay", "AEG Sustain", "AEG Release", "FX Param", "FX Wet Level", "Track Pan", "Track Level"]

const freeEnvParms = [
  ["trigger", { b: 0x00, opts: triggerOptions }],
  ["loop/type", { b: 0x01, opts: loopTypeOptions }],
  ["length", { b: 0x02, opts: lengthOptions }],
  ["keyTrk", { b: 0x03, dispOff: -64 }],
  { prefix: 'trk', count: 4, bx: 2, block: [
    ["param", { b: 0x04, opts: paramOptions }],
    ["scene/on", { b: 0x05, max: 1 }],
    (0..<192).forEach { step in
      ["trk/trk/data/step", { p: 2, b: RolandAddress(intValue: 0x0c + (step * 2) + (trk * 384)).value, max: 255 }],
    }

  ] },
]


// VOICE SEQ

  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
  return 0x104000
}

static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
  return RolandAddress([0x50, UInt8(index), 0x00])
}

const dataByteCount: Int = 0x66

func randomize() {
  randomizeAllParams()
  
  (0..<16).forEach { step in
    let stepWhole: Int
    let stepPart: Int // [0, 63]
    switch ([0, 2]).random() {
    case 0:
      stepWhole = 0
      stepPart = ([0, 63]).random()!
    case 1:
      stepWhole = ([1, 3]).random()!
      stepPart = 0
    default:
      stepWhole = ([1, 8]).random()!
      stepPart = 0
    }
    let gateBytes = (stepWhole << 6) | stepPart
    self["step/gate/lo"] = gateBytes & 0x7f
    self["step/note"] = ([35, 90]).random()!
    self["step/gate/hi"] = (gateBytes >> 7)
  }
}

const voiceSeqParms = [
  ["step/scale", { b: 0x00 }],
  ["length", { b: 0x01 }],
  { prefix: '', count: 16, bx: 1, block: [
    ["note", { b: 0x06, opts: ParamHelper.midiNoteOptions }],
    ["velo", { b: 0x16 }],
    ["gate/lo", { b: 0x26 }],
    ["ctrl", { b: 0x36 }],
    ["gate/hi", { b: 0x46 }],
    ["mute", { b: 0x56, max: 1 }],
  ] },
]