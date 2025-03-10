
//open class TX802VoicePatch : YamahaMultiPatch, Algorithmic, BankablePatch, VoicePatch {
//
//  open class var bankType: SysexPatchBank.Type { return TX802VoiceBank.self }
//  
//  private static let _subpatchTypes: [SynthPath : SysexPatch.Type] = [
//    [.voice] : DX7Patch.self,
//    [.extra] : TX802ACEDPatch.self,
//    ]
//  open class var subpatchTypes: [SynthPath : SysexPatch.Type] { return _subpatchTypes }
//  
//  public var ySubpatches: [SynthPath:YamahaPatch]
//  
//  public static func isValid(fileSize: Int) -> Bool {
//    // 163: A DX7 (mkI) patch
//    return fileSize == fileDataCount || fileSize == 163
//  }
//
//  required public init(data: Data) {
//    ySubpatches = type(of: self).ySubpatches(forData: data)
//  }
//  
//  required public init(vced: DX7Patch, aced: TX802ACEDPatch) {
//    ySubpatches = [
//      [.voice] : vced,
//      [.extra] : aced,
//    ]
//  }
//    
//  public static let initFileName = "tx802-voice-init"
//    
//  public func sysexData(channel: Int) -> Data {
//    // ACED, then VCED
//    var data = ySubpatches[[.extra]]?.sysexData(channel: channel) ?? Data()
//    data += ySubpatches[[.voice]]?.sysexData(channel: channel) ?? Data()
//    return data
//  }
//  
//  public class func algorithms() -> [DXAlgorithm] {
//    return DX7Patch.algorithms()
//  }
//}
//
//open class TX802ACEDPatch : YamahaSinglePatch, BankablePatch {
//  
//  public class var bankType: SysexPatchBank.Type { TX802ACEDBank.self }
//  
//  public static let fileDataCount = 57
//  public class var initFileName: String { return "tx802-aced-init" }
//  
//  public var bytes: [UInt8]
//  
//  required public init(data: Data) {
//    bytes = [UInt8](data[6..<(6+49)])
//  }
//  
//  required public init(bankData: Data) {
//    // create empty bytes to pack into
//    bytes = [UInt8](repeating: 0, count: 49)
//    let b = [UInt8](bankData)
//    type(of: self).bankParams.forEach {
//      self[$0.key] = type(of: self).defaultUnpack(param: $0.value, forBytes: b)
//    }
//  }
//  
//  func bankSysexData() -> Data {
//    var b = [UInt8](repeating: 0, count: 35)
//    // pack the params
//    type(of: self).bankParams.forEach {
//      let param = $0.value
//      b[param.byte] = type(of: self).defaultPackedByte(value: self[$0.key] ?? 0, forParam: param, byte: b[param.byte])
//    }
//    return Data(b)
//  }
//  
//  public func sysexData(channel: Int) -> Data {
//    var data = Data([0xf0, 0x043, UInt8(channel), 0x05, 0x00, 0x31])
//    data.append(contentsOf: bytes)
//    data.append(type(of: self).checksum(bytes: bytes))
//    data.append(0xf7)
//    return data
//  }
//  
//  public func fileData() -> Data {
//    return sysexData(channel: 0)
//  }
//  
////  func randomize() {
////    randomizeAllParams()
////
////    self[[.partial, .i(0), .mute]] = 1
////
////    // find the output ops and set level 4 to 0
////    let algos = DXAlgorithm.algorithms()
////    let algoIndex = self[[.algo]] ?? 0
////
////    let algo = algos[algoIndex]
////
////    for outputId in algo.outputOps {
////      let op: SynthPath = [.op, .i(outputId)]
////      self[op + [.level, .i(0)]] = 90+(0...9).random()!
////      self[op + [.rate, .i(0)]] = 80+(0...19).random()!
////      self[op + [.level, .i(2)]] = 80+(0...19).random()!
////      self[op + [.level, .i(3)]] = 0
////      self[op + [.rate, .i(3)]] = 30+(0...69).random()!
////      self[op + [.level]] = 90+(0...9).random()!
////      self[op + [.level, .scale, .left, .depth]] = (0...9).random()!
////      self[op + [.level, .scale, .right, .depth]] = (0...9).random()!
////    }
////
////    // for one out, make it harmonic and louder
////    let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
////    let op: SynthPath = [.op, .i(randomOut)]
////    self[op + [.osc, .mode]] = 0
////    self[op + [.fine]] = 0
////    self[op + [.coarse]] = 1
////
////    // flat pitch env
////    for i in 0..<4 {
////      self[[.pitch, .env, .level, .i(i)]] = 50
////    }
////
////    // all ops on
////    for op in 0..<6 { self[[.op, .i(op), .on]] = 1 }
////  }
//  
//  
//  private static let _params: SynthPathParam = {
//    var p = SynthPathParam()
//    
//    for op in stride(from: 5, through: 0, by: -1) {
//      let pre: SynthPath = [.op, .i(op)]
//      p[pre + [.scale, .mode]] = OptionsParam(byte: 5-op, options: ["Normal","Frac"])
//      p[pre + [.amp, .mod]] = RangeParam(byte: (5-op)+6, maxVal: 7)
//    }
//    
//    p[[.pitch, .env, .range]] = OptionsParam(byte: 12, options: pitchEnvRangeOptions)
//    p[[.lfo, .trigger, .mode]] = OptionsParam(byte: 13, options: ["Single","Multi"])
//    p[[.velo, .pitch, .sens]] = RangeParam(byte: 14, maxVal: 1)
//    p[[.mono]] = OptionsParam(byte: 15, options: ["Poly","Mono"])
//    p[[.bend, .range]] = RangeParam(byte: 16, maxVal: 12)
//    p[[.bend, .step]] = RangeParam(byte: 17, maxVal: 12)
//    p[[.bend, .mode]] = RangeParam(byte: 18, maxVal: 2)
//    p[[.random, .pitch]] = RangeParam(byte: 19, maxVal: 7)
//    p[[.porta, .mode]] = OptionsParam(byte: 20, options: ["Retain","Follow"])
//    p[[.porta, .step]] = RangeParam(byte: 21, maxVal: 12)
//    p[[.porta, .time]] = RangeParam(byte: 22, maxVal: 99)
//    p[[.modWheel, .pitch]] = RangeParam(byte: 23, maxVal: 99)
//    p[[.modWheel, .amp]] = RangeParam(byte: 24, maxVal: 99)
//    p[[.modWheel, .env, .bias]] = RangeParam(byte: 25, maxVal: 99)
//    p[[.foot, .pitch]] = RangeParam(byte: 26, maxVal: 99)
//    p[[.foot, .amp]] = RangeParam(byte: 27, maxVal: 99)
//    p[[.foot, .env, .bias]] = RangeParam(byte: 28, maxVal: 99)
//    p[[.foot, .volume]] = RangeParam(byte: 29, maxVal: 99)
//    p[[.breath, .pitch]] = RangeParam(byte: 30, maxVal: 99)
//    p[[.breath, .amp]] = RangeParam(byte: 31, maxVal: 99)
//    p[[.breath, .env, .bias]] = RangeParam(byte: 32, maxVal: 99)
//    p[[.breath, .pitch, .bias]] = RangeParam(byte: 33, maxVal: 100)
//    p[[.aftertouch, .pitch]] = RangeParam(byte: 34, maxVal: 99)
//    p[[.aftertouch, .amp]] = RangeParam(byte: 35, maxVal: 99)
//    p[[.aftertouch, .env, .bias]] = RangeParam(byte: 36, maxVal: 99)
//    p[[.aftertouch, .pitch, .bias]] = RangeParam(byte: 37, maxVal: 100)
//    p[[.pitch, .env, .rate, .scale]] = RangeParam(byte: 38, maxVal: 7)
//    
//    // Not used on TX-802, but on DX7ii/S
//    p[[.foot, .i(1), .pitch]] = RangeParam(parm: 64, byte: 39, maxVal: 99)
//    p[[.foot, .i(1), .amp]] = RangeParam(parm: 65, byte: 40, maxVal: 99)
//    p[[.foot, .i(1), .env, .bias]] = RangeParam(parm: 66, byte: 41, maxVal: 99)
//    p[[.foot, .i(1), .volume]] = RangeParam(parm: 67, byte: 42, maxVal: 99)
//    p[[.midi, .ctrl, .pitch]] = RangeParam(parm: 68, byte: 43, maxVal: 99)
//    p[[.midi, .ctrl, .amp]] = RangeParam(parm: 69, byte: 44, maxVal: 99)
//    p[[.midi, .ctrl, .env, .bias]] = RangeParam(parm: 70, byte: 45, maxVal: 99)
//    p[[.midi, .ctrl, .volume]] = RangeParam(parm: 71, byte: 46, maxVal: 99)
//    // TODO: DX7s manual gave me the parm (72) here. I think I guessed on the byte # (47, originally).
//    //   The DX200 lists unison detune as byte 48 though. So that might be right.
//    //   So I swapped byte # for these next 2. Need to test with hardware...
//    p[[.unison, .detune]] = RangeParam(parm: 72, byte: 48, maxVal: 7)
//    p[[.foot, .slider]] = RangeParam(parm: 73, byte: 47, maxVal: 1)
//
//    return p
//  }()
//  
//  open class var params: SynthPathParam { return _params }
//  
//  static let pitchEnvRangeOptions = OptionsParam.makeOptions(["8 oct", "2 oct", "1 oct", "1/2 oct"])
//  
//  // params for reading from a bank
//  private static let bankParams: SynthPathParam = {
//    var p = SynthPathParam()
//    
//    for op in stride(from: 5, through: 0, by: -1) {
//      p[[.op, .i(op), .scale, .mode]] = RangeParam(byte: 0, bit: 5-op)
//    }
//
//    p[[.op, .i(5), .amp, .mod]] = RangeParam(byte: 1, bits: 0...2)
//    p[[.op, .i(4), .amp, .mod]] = RangeParam(byte: 1, bits: 3...5)
//    p[[.op, .i(3), .amp, .mod]] = RangeParam(byte: 2, bits: 0...2)
//    p[[.op, .i(2), .amp, .mod]] = RangeParam(byte: 2, bits: 3...5)
//    p[[.op, .i(1), .amp, .mod]] = RangeParam(byte: 3, bits: 0...2)
//    p[[.op, .i(0), .amp, .mod]] = RangeParam(byte: 3, bits: 3...5)
//
//    p[[.pitch, .env, .range]] = RangeParam(byte: 4, bits: 0...1)
//    p[[.lfo, .trigger, .mode]] = RangeParam(byte: 4, bit: 2)
//    p[[.velo, .pitch, .sens]] = RangeParam(byte: 4, bit: 3)
//    p[[.mono]] = RangeParam(byte: 5, bits: 0...1)
//    p[[.bend, .range]] = RangeParam(byte: 5, bits: 2...5) // This was wrong in the Yamaha docs.
//    p[[.bend, .step]] = RangeParam(byte: 6, bits: 0...3)
//    p[[.bend, .mode]] = RangeParam(byte: 6, bits: 4...5)
//    p[[.random, .pitch]] = RangeParam(byte: 4, bits: 4...6)
//    p[[.porta, .mode]] = RangeParam(byte: 7, bit: 0)
//    p[[.porta, .step]] = RangeParam(byte: 7, bits: 1...4)
//    p[[.porta, .time]] = RangeParam(byte: 8)
//    p[[.modWheel, .pitch]] = RangeParam(byte: 9)
//    p[[.modWheel, .amp]] = RangeParam(byte: 10)
//    p[[.modWheel, .env, .bias]] = RangeParam(byte: 11)
//    p[[.foot, .pitch]] = RangeParam(byte: 12)
//    p[[.foot, .amp]] = RangeParam(byte: 13)
//    p[[.foot, .env, .bias]] = RangeParam(byte: 14)
//    p[[.foot, .volume]] = RangeParam(byte: 15)
//    p[[.breath, .pitch]] = RangeParam(byte: 16)
//    p[[.breath, .amp]] = RangeParam(byte: 17)
//    p[[.breath, .env, .bias]] = RangeParam(byte: 18)
//    p[[.breath, .pitch, .bias]] = RangeParam(byte: 19)
//    p[[.aftertouch, .pitch]] = RangeParam(byte: 20)
//    p[[.aftertouch, .amp]] = RangeParam(byte: 21)
//    p[[.aftertouch, .env, .bias]] = RangeParam(byte: 22)
//    p[[.aftertouch, .pitch, .bias]] = RangeParam(byte: 23)
//    p[[.pitch, .env, .rate, .scale]] = RangeParam(byte: 24)
//    
//    // Not used on TX-802, but on DX7ii/S
//    p[[.foot, .i(1), .pitch]] = RangeParam(byte: 26)
//    p[[.foot, .i(1), .amp]] = RangeParam(byte: 27)
//    p[[.foot, .i(1), .env, .bias]] = RangeParam(byte: 28)
//    p[[.foot, .i(1), .volume]] = RangeParam(byte: 29)
//    p[[.midi, .ctrl, .pitch]] = RangeParam(byte: 30)
//    p[[.midi, .ctrl, .amp]] = RangeParam(byte: 31)
//    p[[.midi, .ctrl, .env, .bias]] = RangeParam(byte: 32)
//    p[[.midi, .ctrl, .volume]] = RangeParam(byte: 33)
//    p[[.unison, .detune]] = RangeParam(byte: 34, bits: 0...2)
//    p[[.foot, .slider]] = RangeParam(byte: 34, bit: 3)
//    
//    return p
//  }()
//}
