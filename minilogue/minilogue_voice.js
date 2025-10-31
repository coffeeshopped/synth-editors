
protocol Minilogue10BitParam : Param {
  var byte2: Int { get }
}

struct Minilogue10BitRangeParam : ParamWithRange, Minilogue10BitParam {
  let range: ClosedRange<Int> = [0, 1023]
  let displayOffset = 0
  let byte: Int
  let byte2: Int
  let bits: ClosedRange<Int>?
  let parm: Int
  let extra: [Int:Int]
  let formatter: ParamValueFormatter? = nil
  let parser: ParamValueParser? = nil
  let packIso: PackIso? = nil

  init(parm p: Int = 0, bigByte: Int, littleByte: Int, bits bts: ClosedRange<Int>) {
    parm = p
    byte = bigByte
    byte2 = littleByte
    bits = bts
    extra = [:]
  }
  
}

struct Minilogue10BitOptionsParam : ParamWithOptions, Minilogue10BitParam {
  
  var options: [Int : String]
  let displayOffset = 0
  let byte: Int
  let byte2: Int
  let bits: ClosedRange<Int>?
  let parm: Int
  let extra: [Int:Int]
  let formatter: ParamValueFormatter? = nil
  let packIso: PackIso? = nil

  init(parm p: Int = 0, bigByte: Int, littleByte: Int, bits bts: ClosedRange<Int>, options: [Int:String]) {
    parm = p
    byte = bigByte
    byte2 = littleByte
    bits = bts
    extra = [:]
    self.options = options
  }
  
}

enum MinilogueVoiceMode: Int {
  case poly = 0, duo, unison, mono, chord, delay, arp, sidechain
}


  
const tempData = sysexData([0x40])

function bankSysexData(location) {
  return sysexData([0x4c, ['bits', location, [0, 6]], ['bit', location, 7]])
}

function sysexData(address) {
  return [0xf0, 0x42, ['+', 0x30, 'channel'], 0x00, 0x01, 0x2c, address, ['append78', 'b', { count: 512 }], 0xf7]
}

const patchTruss = {
  single: 'voice',
  parms: parms,
  initFile: "minilogue-init", 
  namePack: [4, 15],
  // 520: temp patch
  // 522: bank patch
  validSizes: [520, 522],
  createFile: tempData,
}

class MiniloguePatch : ByteBackedSysexPatch, BankablePatch {

  
  const fileDataCount = 520
  
  required init(data: Data) {
    // unpack the bytes
    // data range is different for temp patches vs memory patches
    let dataRange: Range<Int> = data.count == 520 ? 7..<519 : 9..<521
    bytes = data.unpack87(count: 448, inRange: dataRange)
    
    // these should always be 0xff
    bytes[110] = 0xff
    bytes[111] = 0xff
  }

  
  
  func unpack(param: Param) -> Int? {
    if let param = param as? Minilogue10BitParam {
      return (Int(bytes[param.byte]) << 2) + Int(bytes[param.byte2].bits(param.bits!))
    }
    else if param.byte == 100 {
      return (Int(bytes[param.byte+1]) << 8) + Int(bytes[param.byte])
    }
    else {
      return defaultUnpack(param: param)
    }
  }
  
  func pack(value: Int, forParam param: Param) {
    if let param = param as? Minilogue10BitParam {
      bytes[param.byte] = UInt8(0xff & (value >> 2))
      bytes[param.byte2] = bytes[param.byte2].set(bits: param.bits!, value: value)
    }
    else if param.byte == 100 {
      bytes[param.byte] = UInt8(0xff & value)
      bytes[param.byte+1] = UInt8(0xf & (value >> 8))
    }
    else {
      defaultPack(value: value, forParam: param)
    }
  }
    
  const chordModeOptions = ["5th", "sus2", "m", "Maj", "sus4", "m7", "7", "7sus4", "Maj7", "aug", "dim", "m7b5", "mMaj7", "Maj7b5"]
  const delayModeOptions = ["1/192", "1/128", "1/64", "1/48", "1/32", "1/24", "1/16", "1/12", "1/8", "1/6", "3/16", "1/4"]
  const arpModeOptions = ["Manual 1", "Manual 2", "Rise 1", "Rise 2", "Fall 1", "Fall 2", "Rise Fall 1", "Rise Fall 2", "Poly 1", "Poly 2", "Random 1", "Random 2", "Random 3"]

const gateIso = ['switch', [
  [[0, 72], ['>', ['*', 100.0/72.0], 'round', ['s', '%']]],
  [73, "Tie"],
]]
  
  const pitchOptions = ([0, 1023].map {
    let value: Int
    switch $0 {
    case [0, 3]:
      value = -1200
    case [4, 355]:
      value = -1 * ((((356-$0) * 25)/8) + 100)
    case [356, 475]:
      value = -1 * ((((476-$0) * 98)/125) + 7)
    case [476, 491]:
      value = -1 * ((((492-$0) * 183)/500) + 1)
    case [492, 531]:
      value = 0
    case [532, 547]:
      value = ((($0-532) * 183) / 500) + 1
    case [548, 667]:
      value = ((($0-548) * 98) / 125) + 7
    case [668, 1019]:
      value = ((($0-668) * 25) / 8) + 100
    default:
      value = 1200
    }
    return `${value}`
  })
  
  const cutoffOptions = ([0, 1023].map {
    let perc: Int
    switch $0 {
    case [0, 10]:
      perc = -100
    case [11, 491]:
      let toSq = 492 - $0
      let knobSq = toSq * toSq
      // this old way crashes on 32-bit devices bc of huge numbers
//      let div: Int = 0x40000000
//      perc = (-1 * (knobSq * 464100) / div) - 1
      perc = (-1 * knobSq / 2313) - 1
    case [492, 531]:
      perc = 0
    case [532, 1012]:
      let toSq = $0 - 532
      let knobSq = toSq * toSq
//      let div: Int = 0x40000000
//      perc = ((knobSq * 464100) / div) + 1
      perc = (knobSq / 2313) + 1
    default:
      perc = 100
    }
    return `${perc}%`
  })

  const pitchEGOptions = ([0, 1023].map {
    let value: Int
    switch $0 {
    case [0, 3]:
      value = -4800
    case [4, 355]:
      value = $0.map(inRange: [4, 356], outRange: -4800 ... -400)
    case [356, 475]:
      value = $0.map(inRange: [356, 476], outRange: -400 ... -26)
    case [476, 491]:
      value = $0.map(inRange: [476, 492], outRange: -26 ... 0)
    case [492, 531]:
      value = 0
    case [532, 547]:
      value = $0.map(inRange: [532, 548], outRange: 0 ... 26)
    case [548, 667]:
      value = $0.map(inRange: [548, 668], outRange: 26 ... 400)
    case [668, 1019]:
      value = $0.map(inRange: [668, 1020], outRange: 400 ... 4800)
    default:
      value = 4800
    }
    return `${value}`
  })

  const sliderDestOptions = [
    77 : "Pitch Bend",
    78 : "Gate Time",
    17 : "VCO 1 Pitch",
    18 : "VCO 1 Shape",
    21 : "VCO 2 Pitch",
    22 : "VCO 2 Shape",
    25 : "Cross Mod Depth",
    26 : "VCO 2 Pitch EG Int",
    29 : "VCO 1 Level",
    30 : "VCO 2 Level",
    31 : "Noise Level",
    32 : "Cutoff",
    33 : "Resonance",
    34 : "Filter EG Int",
    40 : "Amp EG Attack",
    41 : "Amp EG Decay",
    42 : "Amp EG Sustain",
    43 : "Amp EG Release",
    44 : "EG Attack",
    45 : "EG Decay",
    46 : "EG Sustain",
    47 : "EG Release",
    48 : "LFO Rate",
    49 : "LFO Int",
    56 : "Delay Hi Pass Cutoff",
    57 : "Delay Time",
    58 : "Delay Feedback",
    59 : "Portamento Time",
    71 : "Voice Mode Depth",
    ]
  
  const motionDestOptions = [
    0 : "None",
    17 : "Vco 1 Pitch",
    18 : "Vco 1 Shape",
    19 : "Vco 1 Octave",
    20 : "Vco 1 Wave",
    21 : "Vco 2 Pitch",
    22 : "Vco 2 Shape",
    23 : "Vco 2 Octave",
    24 : "Vco 2 Wave",
    25 : "Cross Mod",
    26 : "Pitch EG Int",
    27 : "Sync",
    28 : "Ring",
    29 : "Vco 1 Level",
    30 : "Vco 2 Level",
    31 : "Noise Level",
    32 : "Cutoff",
    33 : "Resonance",
    34 : "Cutoff env, . Int",
    35 : "Cutoff Velocity Track",
    36 : "Cutoff Keyboard Track",
    37 : "Cutoff Type",
    40 : "Amp EG Attack",
    41 : "Amp EG Decay",
    42 : "Amp EG Sustain",
    43 : "Amp EG Release",
    44 : "Eg Attack",
    45 : "Eg Decay",
    46 : "Eg Sustain",
    47 : "Eg Release",
    48 : "Lfo Rate",
    49 : "Lfo Int",
    50 : "Lfo Target",
    51 : "Lfo Eg",
    52 : "Lfo Type",
    53 : "Delay Output Routing",
    55 : "Drive",
    56 : "Delay Hi Pass Cutoff",
    57 : "Delay Time",
    58 : "Delay Feedback",
    
    //61 : "Voice Mode???",
    59 : "Portamento",
    71 : "Voice Depth",
    
    //72 : "Voice Depth",
    77 : "Pitch Bend",
    78 : "Gate Time",
    
    // 81+ -> ???
    ]
}

let octaveOptions = ["16'", "8'", "4'", "2'"]
let waveOptions = ["Square", "Triangle", "Saw"]
let cutoffPercOptions = ["0%", "50%", "100%"]

const parms = [
  ["osc/0/pitch", { p: 34, bigByte: 20, littleByte: 52, bits: [0, 1], options: pitchOptions }],
  ["osc/0/shape", { p: 36, bigByte: 21, littleByte: 52, bits: [2, 3] }],
  ["osc/1/pitch", { p: 35, bigByte: 22, littleByte: 53, bits: [0, 1], options: pitchOptions }],
  ["osc/1/shape", { p: 37, bigByte: 23, littleByte: 53, bits: [2, 3] }],
  ["cross/mod/depth", { p: 41, bigByte: 24, littleByte: 54, bits: [0, 1] }],
  ["osc/1/pitch/env/amt", { p: 42, bigByte: 25, littleByte: 54, bits: [2, 3], options: pitchEGOptions }],
  ["osc/0/level", { p: 39, bigByte: 26, littleByte: 54, bits: [4, 5] }],
  ["osc/1/level", { p: 40, bigByte: 27, littleByte: 54, bits: [6, 7] }],
  ["noise/level", { p: 33, bigByte: 28, littleByte: 55, bits: [2, 3] }],
  ["cutoff", { p: 43, bigByte: 29, littleByte: 55, bits: [4, 5], options: cutoffOptions }],
  ["reson", { p: 44, bigByte: 30, littleByte: 55, bits: [6, 7] }],
  ["cutoff/env/amt", { p: 45, bigByte: 31, littleByte: 56, bits: [0, 1] }],
  
  ["amp/velo", { b: 33 }],
  
  ["amp/env/attack", { p: 16, bigByte: 34, littleByte: 57, bits: [0, 1] }],
  ["amp/env/decay", { p: 17, bigByte: 35, littleByte: 57, bits: [2, 3] }],
  ["amp/env/sustain", { p: 18, bigByte: 36, littleByte: 57, bits: [4, 5] }],
  ["amp/env/release", { p: 19, bigByte: 37, littleByte: 57, bits: [6, 7] }],
  ["env/attack", { p: 20, bigByte: 38, littleByte: 58, bits: [0, 1] }],
  ["env/decay", { p: 21, bigByte: 39, littleByte: 58, bits: [2, 3] }],
  ["env/sustain", { p: 22, bigByte: 40, littleByte: 58, bits: [4, 5] }],
  ["env/release", { p: 23, bigByte: 41, littleByte: 58, bits: [6, 7] }],
  ["lfo/rate", { p: 24, bigByte: 42, littleByte: 59, bits: [0, 1] }],
  ["lfo/amt", { p: 26, bigByte: 43, littleByte: 59, bits: [2, 3] }],
  ["delay/hi/pass", { p: 29, bigByte: 49, littleByte: 62, bits: [2, 3] }],
  ["delay/time", { p: 30, bigByte: 50, littleByte: 62, bits: [4, 5] }],
  ["delay/feedback", { p: 31, bigByte: 51, littleByte: 62, bits: [6, 7] }],
  
  // set range on these for CC scaling
  ["osc/0/octave", { p: 48, b: 52, bits: [4, 5], opts: octaveOptions }],
  ["osc/0/wave", { p: 50, b: 52, bits: [6, 7], opts: waveOptions }],
  ["osc/1/octave", { p: 49, b: 53, bits: [4, 5], opts: octaveOptions }],
  ["osc/1/wave", { p: 51, b: 53, bits: [6, 7], opts: waveOptions }],
  
  ["sync", { p: 80, b: 55, bit: 0 }],
  ["ringMod", { p: 81, b: 55, bit: 1 }],
  
  ["cutoff/velo", { p: 82, b: 56, bits: [2, 3], opts: cutoffPercOptions }],
  ["cutoff/key/trk", { p: 83, b: 56, bits: [4, 5], opts: cutoffPercOptions }],
  ["cutoff/type", { p: 84, b: 56, bit: 6 }],
  
  ["lfo/dest", { p: 56, b: 59, bits: [4, 5], opts: ["Cutoff", "Shape", "Pitch"] }],
  ["lfo/env", { p: 57, b: 59, bits: [6, 7], opts: ["Off", "Rate", "Int"] }],
  ["lfo/wave", { p: 58, b: 60, bits: [0, 1], opts: waveOptions }],
  ["delay/out", { p: 88, b: 60, bits: [6, 7], opts: ["Bypass", "Pre-filter", "Post-filter"] }],
  ["porta/time", { b: 61, max: 128, iso: ['switch', [[0, "Off"]], ['-', 1]] }],
  
  ["voice/mode", { b: 64, bits: [0, 2], opts: ["Poly", "Duo", "Unison", "Mono", "Chord", "Delay", "Arp", "Sidechain"] }],
  ["voice/mode/depth", { p: 27, bigByte: 70, littleByte: 64, bits: [4, 5] }],
  ["bend/up", { b: 66, bits: [0, 3], rng: [1, 12] }],
  ["bend/down", { b: 66, bits: [4, 7], rng: [1, 12] }],
  ["lfo/key/sync", { b: 69, bit: 0 }],
  ["lfo/tempo/sync", { b: 69, bit: 1 }],
  ["lfo/voice/sync", { b: 69, bit: 2 }],
  ["porta/tempo", { b: 69, bit: 3 }],
  ["porta/mode", { b: 69, bit: 4, opts: ["Auto","On"] }],
  ["pgm/level", { b: 71, rng: [77, 127], dispOff: -102 }],
  
  ["slider", { b: 72, opts: sliderDestOptions }],
  ["key/octave", { b: 73, rng: [0, 4], dispOff: -2 }],
  
  ["tempo", { b: 100, rng: [100, 3000] }],
  
  ["step/length", { b: 103, rng: [1, 16] }],
  ["swing", { b: 104, rng: [-75, 75] }],
  ["gate/time", { b: 105 }],
  ["step/resolution", { b: 106, opts: ["1/16", "1/8", "1/4", "1/2", "1/1"] }],
  
  // TODO: check the math on these.
  { prefix: 'step', count: 16, block: (i) => {
    const bit = i % 8
    return [
      ["on", { b: (i < 8 ? 108 : 109), bit: bit }],
      { prefix: 'seq', count: 4, bx: 2, block: [
        ["motion/on", { b: (i < 8 ? 120 : 121), bit: bit }],
      ] },
    ]
  } },
  
  { prefix: 'seq', count: 4, bx: 1, block: [
    { prefix: 'step', count: 16, bx: 20, block: [
      ["note", { b: 128 }],
      ["velo", { b: 132 }],
      ["gate", { b: 136, bits: [0, 6], iso: gateIso }],
      ["trigger", { b: 136, bit: 7 }],
    ] },
  ] },
  
  { prefix: 'seq', count: 4, bx: 2, block: [
    { prefix: 'step', count: 16, bx: 20, block: [
      ["motion/data/0", { b: 140, rng: [0, 255] }],
      ["motion/data/1", { b: 141, rng: [0, 255] }],
    ] },
    ["motion/on", { b: 112, bit: 0 }],
    ["motion/smooth", { b: 112, bit: 1 }],
    ["motion/dest", { b: 113, opts: motionDestOptions }],
  ] },
]

const patchTransform = {
  throttle: 100,
  param: (path, parm, value) => {
    guard param.parm > 0 else { return [patch.sysexData(channel: self.channel)] }
    // look for a CC number we can use
    // TODO: value is going to be way out of range for many params (up to 1023)
    // find a way to scale. maybe based on param type
    //        let outV = Int((127*Float(value)/Float(1+ param.maxVal - param.minVal)).rounded())
    let outV: Int
    if param is Minilogue10BitParam {
      outV = value.map(inRange: 0...1023, outRange: 0...127)
    }
    else if let param = param as? ParamWithRange {
      let range = param.range
      outV = Int( 128 * Float(value) / Float(1 + range.upperBound - range.lowerBound) ) + 1
    }
    else { outV = value }
    
    return [Data(Midi.cc(param.parm, value: outV, channel: self.channel))]


  },
  singlePatch: [[sysexData, 10]],
  name: [[sysexData, 10]],
}

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 200,
  initFile: "minilogue-bank-init",
}

const bankTransform = {
  throttle: 0,
  singleBank: (location) => sysexData(location),
}

class MinilogueBank : TypedSysexPatchBank {
  
    static let fileDataCount = 104400 // extra bytes for locations
  
  static func location(forData data: Data) -> Int {
    return Int(data[7]) + (Int(data[8]) << 7)
  }  
  
}

