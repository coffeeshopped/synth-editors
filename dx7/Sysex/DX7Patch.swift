
//enum DXLevelScalingCurve: Int {
//  case negativeLinear = 0
//  case negativeExponential = 1
//  case positiveExponential = 2
//  case positiveLinear = 3
//}
//
//open class DX7Patch : DXPatch, Algorithmic, CompactBankablePatch {
//  
//  open class var bankType: SysexPatchBank.Type { return DX7VoiceBank.self }
//
//  public static let fileDataCount = 163
//  open class var initFileName: String { return "DX-init" }
//  public static let nameByteRange = 145..<155
//  
//  public var bytes: [UInt8]
//  public var opOns = [Int](repeating: 1, count: 6)
//
//  required public init(data: Data) {
//    bytes = [UInt8](data[6..<(6+155)])
//  }
//
//  required public init(bankData: Data) {
//    // create empty bytes to pack into
//    bytes = [UInt8](repeating: 0, count: 155)
//
//    let b = [UInt8](bankData)
//
//    // unpack the name
//    name = type(of: self).name(forRange: type(of: self).bankNameByteRange, bytes: b)
//
//    type(of: self).bankParams.forEach {
//      self[$0.key] = type(of: self).defaultUnpack(param: $0.value, forBytes: b)
//    }
//  }
//  
//  public func bankSysexData() -> Data {
//    var b = [UInt8](repeating: 0, count: 128)
//    
//    // pack the name
//    let nameByteRange = type(of: self).bankNameByteRange
//    let n = nameSetFilter(name) as NSString
//    let nameBytes = (0..<nameByteRange.count).map { $0 < n.length ? UInt8(n.character(at: $0)) : 32 }
//    b.replaceSubrange(nameByteRange, with: nameBytes)
//
//    // pack the params
//    type(of: self).bankParams.forEach {
//      let param = $0.value
//      b[param.byte] = type(of: self).defaultPackedByte(value: self[$0.key] ?? 0, forParam: param, byte: b[param.byte])
//    }
//    
//    return Data(b)
//  }
//  
//  // channel should be 0-15
//  open func sysexData(channel: Int) -> Data {
//    var data = Data([0xf0, 0x043, UInt8(channel), 0x00, 0x01, 0x1b])
//    data.append(contentsOf: bytes)
//    data.append(type(of: self).checksum(bytes: bytes))
//    data.append(0xf7)
//    return data
//  }
//  
//  open func fileData() -> Data {
//    return sysexData(channel: 0)
//  }
//  
//  open class func algorithms() -> [DXAlgorithm] {
//    return DXAlgorithm.algorithmsFromPlist("Algorithms")
//  }
//
//  public static func freqRatio(fixedMode: Bool, coarse: Int, fine: Int) -> String {
//    if fixedMode {
//      let freq = powf(10, Float(coarse % 4)) * exp(Float(M_LN10)*(Float(fine)/100))
//      return String(format:"%.4g", freq)
//    }
//    else {
//      // ratio mode
//      let c = coarse == 0 ? 0.5 : Float(coarse)
//      let f = (Float(fine) * c) / 100
//      return String(format:"%.2f", c + f)
//    }
//  }
//  
//  open func randomize() {
//    randomizeAllParams()
//
//    self[[.partial, .i(0), .mute]] = 1
//
//    // find the output ops and set level 4 to 0
//    let algos = Self.algorithms()
//    let algoIndex = self[[.algo]] ?? 0
//
//    let algo = algos[algoIndex]
//
//    for outputId in algo.outputOps {
//      let op: SynthPath = [.op, .i(outputId)]
//      self[op + [.level, .i(0)]] = 90+(0...9).random()!
//      self[op + [.rate, .i(0)]] = 80+(0...19).random()!
//      self[op + [.level, .i(2)]] = 80+(0...19).random()!
//      self[op + [.level, .i(3)]] = 0
//      self[op + [.rate, .i(3)]] = 30+(0...69).random()!
//      self[op + [.level]] = 90+(0...9).random()!
//      self[op + [.level, .scale, .left, .depth]] = (0...9).random()!
//      self[op + [.level, .scale, .right, .depth]] = (0...9).random()!
//    }
//
//    // for one out, make it harmonic and louder
//    let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
//    let op: SynthPath = [.op, .i(randomOut)]
//    self[op + [.osc, .mode]] = 0
//    self[op + [.fine]] = 0
//    self[op + [.coarse]] = 1
//
//    // flat pitch env
//    for i in 0..<4 {
//      self[[.pitch, .env, .level, .i(i)]] = 50
//    }
//
//    // all ops on
//    for op in 0..<6 { self[[.op, .i(op), .on]] = 1 }
//  }
//  
//
//  private static let _params: SynthPathParam = {
//    var p = SynthPathParam()
//
//    for op in stride(from: 5, through: 0, by: -1) {
//      let opOffset = 21 * (5 - op)
//      let pre: SynthPath = [.op, .i(op)]
//      for i in 0..<4 {
//        p[pre + [.rate, .i(i)]] = RangeParam(byte: opOffset+i, maxVal: 99)
//        p[pre + [.level, .i(i)]] = RangeParam(byte: opOffset+(4+i), maxVal: 99)
//      }
//      p[pre + [.level, .scale, .brk, .pt]] = OptionsParam(byte: opOffset + 8, options: breakOptions)
//      p[pre + [.level, .scale, .left, .depth]] = RangeParam(byte: opOffset + 9, maxVal: 99)
//      p[pre + [.level, .scale, .right, .depth]] = RangeParam(byte: opOffset + 10, maxVal: 99)
//      p[pre + [.level, .scale, .left, .curve]] = OptionsParam(byte: opOffset + 11, options: curveOptions)
//      p[pre + [.level, .scale, .right, .curve]] = OptionsParam(byte: opOffset + 12, options: curveOptions)
//      p[pre + [.rate, .scale]] = RangeParam(byte: opOffset+13, maxVal: 7)
//      p[pre + [.amp, .mod]] = RangeParam(byte: opOffset+14, maxVal: 3)
//      p[pre + [.velo]] = RangeParam(byte: opOffset+15, maxVal: 7)
//      p[pre + [.level]] = RangeParam(byte: opOffset+16, maxVal: 99)
//      p[pre + [.osc, .mode]] = RangeParam(byte: opOffset+17, maxVal: 1)
//      p[pre + [.coarse]] = RangeParam(byte: opOffset+18, maxVal: 31)
//      p[pre + [.fine]] = RangeParam(byte: opOffset+19, maxVal: 99)
//      p[pre + [.detune]] = RangeParam(byte: opOffset+20, maxVal: 14, displayOffset: -7)
//      
//      p[pre + [.on]] = RangeParam(parm: 155, bit: 5-op)
//    }
//    
//    for i in 0..<4 {
//      p[[.pitch, .env, .rate, .i(i)]] = RangeParam(byte: 126+i, maxVal: 99)
//      p[[.pitch, .env, .level, .i(i)]] = RangeParam(byte: 130+i, maxVal: 99)
//    }
//    
//    p[[.algo]] = RangeParam(byte: 134, maxVal: 31, displayOffset: 1)
//    p[[.feedback]] = RangeParam(byte: 135, maxVal: 7)
//    p[[.osc, .sync]] = RangeParam(byte: 136, maxVal: 1)
//    p[[.lfo, .speed]] = RangeParam(byte: 137, maxVal: 99)
//    p[[.lfo, .delay]] = RangeParam(byte: 138, maxVal: 99)
//    p[[.lfo, .pitch, .mod, .depth]] = RangeParam(byte: 139, maxVal: 99)
//    p[[.lfo, .amp, .mod, .depth]] = RangeParam(byte: 140, maxVal: 99)
//    p[[.lfo, .sync]] = RangeParam(byte: 141, maxVal: 1)
//    p[[.lfo, .wave]] = OptionsParam(byte: 142, options: lfoWaveOptions)
//    p[[.lfo, .pitch, .mod]] = RangeParam(byte: 143, maxVal: 7)
//    p[[.transpose]] = OptionsParam(byte: 144, options: transposeOptions)
//    return p
//  }()
//  
//  open class var params: SynthPathParam { return _params }
//  
//  static let curveOptions = OptionsParam.makeOptions(["- Lin","- Exp","+ Exp","+ Lin"])
//  
//  static let lfoWaveOptions = OptionsParam.makeOptions(["Triangle","Saw Down","Saw Up","Square","Sine","Sample/Hold"])
//  
//  static let breakOptions = OptionsParam.makeOptions(["A-1", "A#-1", "B-1", "C0", "C#0", "D0", "D#0", "E0", "F0", "F#0", "G0", "G#0", "A0", "A#0", "B0", "C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1", "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5", "C6", "C#6", "D6", "D#6", "E6", "F6", "F#6", "G6", "G#6", "A6", "A#6", "B6", "C7", "C#7", "D7", "D#7", "E7", "F7", "F#7", "G7", "G#7", "A7", "A#7", "B7", "C8"])
//
//  static let transposeOptions = OptionsParam.makeOptions(["C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1", "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5"])
//  
//  
//  private static let bankNameByteRange = 118..<128
//
//  // params for reading from a bank
//  private static let bankParams: SynthPathParam = {
//    var p = SynthPathParam()
//
//    for op in stride(from: 5, through: 0, by: -1) {
//      let opOffset = 17*(5-op)
//      let pre: SynthPath = [.op, .i(op)]
//      for i in 0..<4 {
//        p[pre + [.rate, .i(i)]] = RangeParam(byte: opOffset+i)
//        p[pre + [.level, .i(i)]] = RangeParam(byte: opOffset+(4+i))
//      }
//      p[pre + [.level, .scale, .brk, .pt]] = RangeParam(byte: opOffset+8)
//      p[pre + [.level, .scale, .left, .depth]] = RangeParam(byte: opOffset+9)
//      p[pre + [.level, .scale, .right, .depth]] = RangeParam(byte: opOffset+10)
//      p[pre + [.level, .scale, .left, .curve]] = RangeParam(byte: opOffset + 11, bits: 0...1)
//      p[pre + [.level, .scale, .right, .curve]] = RangeParam(byte: opOffset + 11, bits: 2...3)
//      p[pre + [.rate, .scale]] = RangeParam(byte: opOffset+12, bits: 0...2)
//      p[pre + [.amp, .mod]] = RangeParam(byte: opOffset+13, bits: 0...1)
//      p[pre + [.velo]] = RangeParam(byte: opOffset+13, bits: 2...4)
//      p[pre + [.level]] = RangeParam(byte: opOffset+14)
//      p[pre + [.osc, .mode]] = RangeParam(byte: opOffset+15, bit: 0)
//      p[pre + [.coarse]] = RangeParam(byte: opOffset+15, bits: 1...6)
//      p[pre + [.fine]] = RangeParam(byte: opOffset+16)
//      p[pre + [.detune]] = RangeParam(byte: opOffset+12, bits: 3...6)
//    }
//    
//    for i in 0..<4 {
//      p[[.pitch, .env, .rate, .i(i)]] = RangeParam(byte: 102+i)
//      p[[.pitch, .env, .level, .i(i)]] = RangeParam(byte: 106+i)
//    }
//    
//    p[[.algo]] = RangeParam(byte: 110)
//    p[[.feedback]] = RangeParam(byte: 111, bits: 0...2)
//    p[[.osc, .sync]] = RangeParam(byte: 111, bit: 3)
//    p[[.lfo, .speed]] = RangeParam(byte: 112)
//    p[[.lfo, .delay]] = RangeParam(byte: 113)
//    p[[.lfo, .pitch, .mod, .depth]] = RangeParam(byte: 114)
//    p[[.lfo, .amp, .mod, .depth]] = RangeParam(byte: 115)
//    p[[.lfo, .sync]] = RangeParam(byte: 116, bit: 0)
//    p[[.lfo, .wave]] = RangeParam(byte: 116, bits: 1...3)
//    p[[.lfo, .pitch, .mod]] = RangeParam(byte: 116, bits: 4...6)
//    p[[.transpose]] = RangeParam(byte: 117)
//    
//    return p
//  }()
//
//}
