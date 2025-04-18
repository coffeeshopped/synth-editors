
protocol Minilogue10BitParam : Param {
  var byte2: Int { get }
}

struct Minilogue10BitRangeParam : ParamWithRange, Minilogue10BitParam {
  let range: ClosedRange<Int> = 0...1023
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
  
  func randomize() -> Int {
    return (0...1023).random()!
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
  
  func randomize() -> Int {
    return (0...1023).random()!
  }
}

enum MinilogueVoiceMode: Int {
  case poly = 0, duo, unison, mono, chord, delay, arp, sidechain
}



class MiniloguePatch : ByteBackedSysexPatch, BankablePatch {

  static let bankType: SysexPatchBank.Type = MinilogueBank.self
  static func location(forData data: Data) -> Int {
    return Int(data[7]) + (Int(data[8]) << 7)
  }

  
  static let nameByteRange = 4..<16
  static let fileDataCount = 520
  static let initFileName = "minilogue-init"

  var bytes: [UInt8]
  
  required init(data: Data) {
    // unpack the bytes
    // data range is different for temp patches vs memory patches
    let dataRange: Range<Int> = data.count == 520 ? 7..<519 : 9..<521
    bytes = data.unpack87(count: 448, inRange: dataRange)
    
    // these should always be 0xff
    bytes[110] = 0xff
    bytes[111] = 0xff
  }

  // 520: temp patch
  // 522: bank patch
  static func isValid(sysex: Data) -> Bool {
    return [520,522].contains(sysex.count)
  }

  
  func sysexData(channel: Int) -> Data {
    return sysexData(channel: channel, address: [0x40])
  }
  
  func sysexData(channel: Int, location: Int) -> Data {
    return sysexData(channel: channel, address: [0x4c,
                                                 UInt8(location & 0x7f),
                                                 UInt8((location >> 7) & 0x1)])
  }

  private func sysexData(channel: Int, address: [UInt8]) -> Data {
    var data = Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x00, 0x01, 0x2c] + address)
    data.append78(bytes: bytes, count: 512)
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
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
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.osc, .i(0), .pitch]] = Minilogue10BitOptionsParam(parm: 34, bigByte: 20, littleByte: 52, bits: 0...1, options: pitchOptions)
    p[[.osc, .i(0), .shape]] = Minilogue10BitRangeParam(parm: 36, bigByte: 21, littleByte: 52, bits: 2...3)
    p[[.osc, .i(1), .pitch]] = Minilogue10BitOptionsParam(parm: 35, bigByte: 22, littleByte: 53, bits: 0...1, options: pitchOptions)
    p[[.osc, .i(1), .shape]] = Minilogue10BitRangeParam(parm: 37, bigByte: 23, littleByte: 53, bits: 2...3)
    p[[.cross, .mod, .depth]] = Minilogue10BitRangeParam(parm: 41, bigByte: 24, littleByte: 54, bits: 0...1)
    p[[.osc, .i(1), .pitch, .env, .amt]] = Minilogue10BitOptionsParam(parm: 42, bigByte: 25, littleByte: 54, bits: 2...3, options: pitchEGOptions)
    p[[.osc, .i(0), .level]] = Minilogue10BitRangeParam(parm: 39, bigByte: 26, littleByte: 54, bits: 4...5)
    p[[.osc, .i(1), .level]] = Minilogue10BitRangeParam(parm: 40, bigByte: 27, littleByte: 54, bits: 6...7)
    p[[.noise, .level]] = Minilogue10BitRangeParam(parm: 33, bigByte: 28, littleByte: 55, bits: 2...3)
    p[[.cutoff]] = Minilogue10BitOptionsParam(parm: 43, bigByte: 29, littleByte: 55, bits: 4...5, options: cutoffOptions)
    p[[.reson]] = Minilogue10BitRangeParam(parm: 44, bigByte: 30, littleByte: 55, bits: 6...7)
    p[[.cutoff, .env, .amt]] = Minilogue10BitRangeParam(parm: 45, bigByte: 31, littleByte: 56, bits: 0...1)
    
    p[[.amp, .velo]] = RangeParam(byte: 33)
    p[[.amp, .env, .attack]] = Minilogue10BitRangeParam(parm: 16, bigByte: 34, littleByte: 57, bits: 0...1)
    p[[.amp, .env, .decay]] = Minilogue10BitRangeParam(parm: 17, bigByte: 35, littleByte: 57, bits: 2...3)
    p[[.amp, .env, .sustain]] = Minilogue10BitRangeParam(parm: 18, bigByte: 36, littleByte: 57, bits: 4...5)
    p[[.amp, .env, .release]] = Minilogue10BitRangeParam(parm: 19, bigByte: 37, littleByte: 57, bits: 6...7)
    p[[.env, .attack]] = Minilogue10BitRangeParam(parm: 20, bigByte: 38, littleByte: 58, bits: 0...1)
    p[[.env, .decay]] = Minilogue10BitRangeParam(parm: 21, bigByte: 39, littleByte: 58, bits: 2...3)
    p[[.env, .sustain]] = Minilogue10BitRangeParam(parm: 22, bigByte: 40, littleByte: 58, bits: 4...5)
    p[[.env, .release]] = Minilogue10BitRangeParam(parm: 23, bigByte: 41, littleByte: 58, bits: 6...7)
    p[[.lfo, .rate]] = Minilogue10BitRangeParam(parm: 24, bigByte: 42, littleByte: 59, bits: 0...1)
    p[[.lfo, .amt]] = Minilogue10BitRangeParam(parm: 26, bigByte: 43, littleByte: 59, bits: 2...3)
    p[[.delay, .hi, .pass]] = Minilogue10BitRangeParam(parm: 29, bigByte: 49, littleByte: 62, bits: 2...3)
    p[[.delay, .time]] = Minilogue10BitRangeParam(parm: 30, bigByte: 50, littleByte: 62, bits: 4...5)
    p[[.delay, .feedback]] = Minilogue10BitRangeParam(parm: 31, bigByte: 51, littleByte: 62, bits: 6...7)
    
    let octaveOptions = OptionsParam.makeOptions(["16'", "8'", "4'", "2'"])
    let waveOptions = OptionsParam.makeOptions(["Square", "Triangle", "Saw"])
    // set range on these for CC scaling
    p[[.osc, .i(0), .octave]] = OptionsParam(parm: 48, byte: 52, bits: 4...5, options: octaveOptions)
    p[[.osc, .i(0), .wave]] = OptionsParam(parm: 50, byte: 52, bits: 6...7, options: waveOptions)
    p[[.osc, .i(1), .octave]] = OptionsParam(parm: 49, byte: 53, bits: 4...5, options: octaveOptions)
    p[[.osc, .i(1), .wave]] = OptionsParam(parm: 51, byte: 53, bits: 6...7, options: waveOptions)
    
    p[[.sync]] = RangeParam(parm: 80, byte: 55, bit: 0)
    p[[.ringMod]] = RangeParam(parm: 81, byte: 55, bit: 1)
    
    let cutoffPercOptions = OptionsParam.makeOptions(["0%", "50%", "100%"])
    p[[.cutoff, .velo]] = OptionsParam(parm: 82, byte: 56, bits: 2...3, options: cutoffPercOptions)
    p[[.cutoff, .key, .trk]] = OptionsParam(parm: 83, byte: 56, bits: 4...5, options: cutoffPercOptions)
    p[[.cutoff, .type]] = RangeParam(parm: 84, byte: 56, bit: 6)
    
    p[[.lfo, .dest]] = OptionsParam(parm: 56, byte: 59, bits: 4...5, options: ["Cutoff", "Shape", "Pitch"])
    p[[.lfo, .env]] = OptionsParam(parm: 57, byte: 59, bits: 6...7, options: ["Off", "Rate", "Int"])
    p[[.lfo, .wave]] = OptionsParam(parm: 58, byte: 60, bits: 0...1, options: waveOptions)
    p[[.delay, .out]] = OptionsParam(parm: 88, byte: 60, bits: 6...7, options: ["Bypass", "Pre-filter", "Post-filter"])
    p[[.porta, .time]] = OptionsParam(byte: 61, options: OptionsParam.makeOptions(
      (0...128).map { $0 == 0 ? "Off" : "\($0-1)"}
    ))
    
    p[[.voice, .mode]] = OptionsParam(byte: 64, bits: 0...2, options: ["Poly", "Duo", "Unison", "Mono", "Chord", "Delay", "Arp", "Sidechain"])
    p[[.voice, .mode, .depth]] = Minilogue10BitRangeParam(parm: 27, bigByte: 70, littleByte: 64, bits: 4...5)
    p[[.bend, .up]] = RangeParam(byte: 66, bits: 0...3, range: 1...12)
    p[[.bend, .down]] = RangeParam(byte: 66, bits: 4...7, range: 1...12)
    p[[.lfo, .key, .sync]] = RangeParam(byte: 69, bit: 0)
    p[[.lfo, .tempo, .sync]] = RangeParam(byte: 69, bit: 1)
    p[[.lfo, .voice, .sync]] = RangeParam(byte: 69, bit: 2)
    p[[.porta, .tempo]] = RangeParam(byte: 69, bit: 3)
    p[[.porta, .mode]] = OptionsParam(byte: 69, bit: 4, options: ["Auto","On"])
    p[[.pgm, .level]] = RangeParam(byte: 71, range: 77...127, displayOffset: -102)
    
    p[[.slider]] = OptionsParam(byte: 72, options: sliderDestOptions)
    p[[.key, .octave]] = RangeParam(byte: 73, range: 0...4, displayOffset: -2)
    
    p[[.tempo]] = RangeParam(byte: 100, range: 100...3000)
    
    p[[.step, .length]] = RangeParam(byte: 103, range: 1...16)
    p[[.swing]] = RangeParam(byte: 104, range: -75...75)
    p[[.gate, .time]] = RangeParam(byte: 105)
    p[[.step, .resolution]] = OptionsParam(byte: 106, options: ["1/16", "1/8", "1/4", "1/2", "1/1"])
    
    for i in 0..<16 {
      let bit = i % 8
      p[[.step, .i(i), .on]] = RangeParam(byte: (i < 8 ? 108 : 109), bit: bit)
      
      for seq in 0..<4 {
        let pre: SynthPath = [.seq, .i(seq), .step, .i(i)]
        let off = i * 20
        p[pre + [.motion, .on]] = RangeParam(byte: (i < 8 ? 120+(seq*2) : 121+(seq*2)), bit: bit)
        p[pre + [.note]] = RangeParam(byte: 128 + seq + off)
        p[pre + [.velo]] = RangeParam(byte: 132 + seq + off)
        p[pre + [.gate]] = OptionsParam(byte: 136 + seq + off, bits: 0...6, options: gateOptions)
        p[pre + [.trigger]] = RangeParam(byte: 136 + seq + off, bit: 7)

        p[pre + [.motion, .data, .i(0)]] = RangeParam(byte: 140+(seq*2) + off, range: 0...255)
        p[pre + [.motion, .data, .i(1)]] = RangeParam(byte: 141+(seq*2) + off, range: 0...255)
      }
    }
    
    for i in 0..<4 {
      let pre: SynthPath = [.seq, .i(i), .motion]
      p[pre + [.on]] = RangeParam(byte: 112+(2*i), bit: 0)
      p[pre + [.smooth]] = RangeParam(byte: 112+(2*i), bit: 1)
      p[pre + [.dest]] = OptionsParam(byte: 113+(2*i), options: motionDestOptions)
    }
    
    return p
  }()
  
  
  static let chordModeOptions = OptionsParam.makeOptions(["5th", "sus2", "m", "Maj", "sus4", "m7", "7", "7sus4", "Maj7", "aug", "dim", "m7b5", "mMaj7", "Maj7b5"])
  static let delayModeOptions = OptionsParam.makeOptions(["1/192", "1/128", "1/64", "1/48", "1/32", "1/24", "1/16", "1/12", "1/8", "1/6", "3/16", "1/4"])
  static let arpModeOptions = OptionsParam.makeOptions(["Manual 1", "Manual 2", "Rise 1", "Rise 2", "Fall 1", "Fall 2", "Rise Fall 1", "Rise Fall 2", "Poly 1", "Poly 2", "Random 1", "Random 2", "Random 3"])

  static let gateOptions = OptionsParam.makeOptions((0...72).map {
    "\(Int((100*(Float($0)/72)).rounded()))%"
  } + ["Tie"])
  
  static let pitchOptions = OptionsParam.makeOptions((0...1023).map {
    let value: Int
    switch $0 {
    case 0...3:
      value = -1200
    case 4...355:
      value = -1 * ((((356-$0) * 25)/8) + 100)
    case 356...475:
      value = -1 * ((((476-$0) * 98)/125) + 7)
    case 476...491:
      value = -1 * ((((492-$0) * 183)/500) + 1)
    case 492...531:
      value = 0
    case 532...547:
      value = ((($0-532) * 183) / 500) + 1
    case 548...667:
      value = ((($0-548) * 98) / 125) + 7
    case 668...1019:
      value = ((($0-668) * 25) / 8) + 100
    default:
      value = 1200
    }
    return "\(value)"
  })
  
  static let cutoffOptions = OptionsParam.makeOptions((0...1023).map {
    let perc: Int
    switch $0 {
    case 0...10:
      perc = -100
    case 11...491:
      let toSq = 492 - $0
      let knobSq = toSq * toSq
      // this old way crashes on 32-bit devices bc of huge numbers
//      let div: Int = 0x40000000
//      perc = (-1 * (knobSq * 464100) / div) - 1
      perc = (-1 * knobSq / 2313) - 1
    case 492...531:
      perc = 0
    case 532...1012:
      let toSq = $0 - 532
      let knobSq = toSq * toSq
//      let div: Int = 0x40000000
//      perc = ((knobSq * 464100) / div) + 1
      perc = (knobSq / 2313) + 1
    default:
      perc = 100
    }
    return "\(perc)%"
  })

  static let pitchEGOptions = OptionsParam.makeOptions((0...1023).map {
    let value: Int
    switch $0 {
    case 0...3:
      value = -4800
    case 4...355:
      value = $0.map(inRange: 4...356, outRange: -4800 ... -400)
    case 356...475:
      value = $0.map(inRange: 356...476, outRange: -400 ... -26)
    case 476...491:
      value = $0.map(inRange: 476...492, outRange: -26 ... 0)
    case 492...531:
      value = 0
    case 532...547:
      value = $0.map(inRange: 532...548, outRange: 0 ... 26)
    case 548...667:
      value = $0.map(inRange: 548...668, outRange: 26 ... 400)
    case 668...1019:
      value = $0.map(inRange: 668...1020, outRange: 400 ... 4800)
    default:
      value = 4800
    }
    return "\(value)"
  })

  static let sliderDestOptions = [
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
  
  static let motionDestOptions = [
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

