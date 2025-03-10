
class VirusTIMultiPatch : VirusMultiPatch {
  
//  static func location(forData data: Data) -> Int {
//    guard data.count > 8 else { return 0 }
//    return Int(data[8])
//  }

  class var initFileName: String { return "virusti-multi-init" }
  
  var bytes: [UInt8]

  required init(data: Data) {
    bytes = [UInt8](data.safeBytes(9..<265))
  }
  
//  subscript(path: SynthPath) -> Int? {
//    get {
//      guard let v = rawValue(path: path) else { return nil }
//      switch path {
//      case [.i(0), .wave], [.i(1), .wave]:
//        let inst = v.bits(0...7)
//        let set = v.bits(8...12)
//        return Self.reverseInstMap[set]?[inst] ?? 0
//      default:
//        return v
//      }
//    }
//    set {
//      guard let param = type(of: self).params[path],
//        let newValue = newValue else { return }
//      let off = param.parm * 2
//      switch path {
//      case [.i(0), .wave], [.i(1), .wave]:
//        guard newValue < Self.instMap.count else { return }
//        let item = Self.instMap[newValue]
//        let v = 0.set(bits: 0...7, value: item.inst).set(bits: 8...12, value: item.set)
//        bytes[off] = UInt8(v.bits(0...6))
//        bytes[off + 1] = UInt8(v.bits(7...13))
//      default:
//        bytes[off] = UInt8(newValue.bits(0...6))
//        bytes[off + 1] = UInt8(newValue.bits(7...13))
//      }
//    }
//  }
  
  
  // TODO
  func randomize() {
    randomizeAllParams()
//    (0..<3).forEach {
//      self[[.link, .i($0)]] = -1
//    }
//    (0..<4).forEach {
//      self[[.key, .lo, .i($0)]] = 0
//      self[[.key, .hi, .i($0)]] = 127
//    }
//    (0..<2).forEach {
//      self[[.i($0), .key, .lo]] = 0
//      self[[.i($0), .key, .hi]] = 127
//    }
//    self[[.i(0), .volume]] = 127
//    self[[.i(0), .delay]] = 0
//    self[[.i(0), .start]] = 0
//    self[[.i(1), .delay]] = (0...10).random()!
//
//    self[[.mix]] = 0
  }

  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()

    p[[.clock]] = RangeParam(parm: 0x0f, byte: 15, displayOffset: 63)
    
    (0..<16).forEach { part in
      let pre: SynthPath = [.part, .i(part)]
      let boff = part
      p[pre + [.channel]] = RangeParam(parm: 0x22, byte: boff + 64, maxVal: 15, displayOffset: 1)
      p[pre + [.key, .lo]] = MisoParam.make(parm: 0x23, byte: boff + 80, iso: Miso.noteName(zeroNote: "C-1"))
      p[pre + [.key, .hi]] = MisoParam.make(parm: 0x24, byte: boff + 96, iso: Miso.noteName(zeroNote: "C-1"))
      p[pre + [.transpose]] = RangeParam(parm: 0x25, byte: boff + 112, range: 16...112, displayOffset: -64)
      p[pre + [.detune]] = RangeParam(parm: 0x26, byte: boff + 128, displayOffset: -64)
      p[pre + [.volume]] = RangeParam(parm: 0x27, byte: boff + 144, displayOffset: -64)
      p[pre + [.innit, .volume]] = MisoParam.make(parm: 0x28, byte: boff + 160, iso: volIso)
      p[pre + [.out]] = MisoParam.make(parm: 0x29, byte: boff + 176, options: outOptions)
      p[pre + [.pan]] = MisoParam.make(parm: 0x2b, byte: boff + 208, iso: panIso)
      p[pre + [.on]] = RangeParam(parm: 0x48, byte: boff + 240, bit: 0)
      p[pre + [.rcv, .volume]] = RangeParam(parm: 0x49, byte: boff + 240, bit: 1)
      p[pre + [.hold]] = RangeParam(parm: 0x4a, byte: boff + 240, bit: 2)
      p[pre + [.priority]] = OptionsParam(parm: 0x4d, byte: boff + 240, bit: 5, options: ["Low", "High"])
      p[pre + [.rcv, .pgmChange]] = RangeParam(parm: 0x4e, byte: boff + 240, bit: 6)
    }
    
    return p
  }()
  
  class var params: SynthPathParam { return _params }
  
  private static let outOptions = ["Out1 L", "Out1 L+R", "Out1 R", "Out2 L", "Out2 L+R", "Out2 R", "Out3 L", "Out3 L+R", "Out3 R"]
  
  static let volIso = Miso.switcher([
    .int(0, "Off")
  ], default: Miso.str())
  
  static let panIso = Miso.switcher([
    .int(0, "Patch")
  ], default: Miso.a(-64) >>> Miso.str())

}
