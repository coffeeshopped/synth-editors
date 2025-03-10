
class JD800SpecialSetupPatch : JD800MultiPatch, RhythmPatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = JD800SpecialSetupBank.self
  
  static func location(forData data: Data) -> Int {
    return 0 // just 1 per bank
  }

  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x010000
  }
  
  class var initFileName: String { return "jd800-special-setup-init" }
  
  var addressables: [SynthPath:RolandSingleAddressable]
  var name = "Special Setup"
  
  required init(data: Data) {
    addressables = type(of: self).addressables(forData: data)
  }
  
  private static let _addressableTypes: [SynthPath:RolandSingleAddressable.Type] = {
    var types: [SynthPath:RolandSingleAddressable.Type] =  [
      [.common] : JD800SpecialSetupCommonPatch.self,
    ]
    (0..<61).forEach {
      types[[.note, .i($0)]] = JD800SpecialSetupKeyPatch.self
    }
    return types
  }()
  class var addressableTypes: [SynthPath:RolandSingleAddressable.Type] {
    return _addressableTypes
  }
  
  private static let _subpatchAddresses: [SynthPath:RolandAddress] = {
    var adds: [SynthPath:RolandAddress] = [
      [.common] : 0x0000,
    ]
    (0..<61).forEach {
      adds[[.note, .i($0)]] = RolandAddress(0x0a) + ($0 * RolandAddress(0x58))
    }
    return adds
  }()
  class var subpatchAddresses: [SynthPath:RolandAddress] {
    return _subpatchAddresses
  }

}

class JD800SpecialSetupCommonPatch : JD800Patch {

  static let initFileName = ""
  class var size: RolandAddress { return 0x0a }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x0000
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
//    self[.level] = 127
//    self[[.out, .assign]] = 13
  }

  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.lo, .freq]] = OptionsParam(byte: 0x0, options: ["200", "400"])
    p[[.lo, .gain]] = RangeParam(byte: 0x1, maxVal: 30, displayOffset: -15)
    p[[.mid, .freq]] = OptionsParam(byte: 0x2, options: ["200", "250", "315", "400", "500", "630", "800", "1k", "1.25k", "1.6k", "2k", "2.5k", "3.15k", "4k", "5k", "6.3k", "8kHz"])
    p[[.mid, .q]] = OptionsParam(byte: 0x3, options: ["0.5", "1.0", "2.0", "4.0", "9.0"])
    p[[.mid, .gain]] = RangeParam(byte: 0x4, maxVal: 30, displayOffset: -15)
    p[[.hi, .freq]] = OptionsParam(byte: 0x5, options: ["4k", "8k"])
    p[[.hi, .gain]] = RangeParam(byte: 0x6, maxVal: 30, displayOffset: -15)
    p[[.bend, .down]] = RangeParam(byte: 0x7, maxVal: 48)
    p[[.bend, .up]] = RangeParam(byte: 0x8, maxVal: 12)
    p[[.aftertouch, .bend]] = RangeParam(byte: 0x9, maxVal: 26, formatter: {
      switch $0 {
      case 0:
        return "-36"
      case 1:
        return "-24"
      default:
        return "\($0 - 14)"
      }
    })
    
    return p
  }()
  class var params: SynthPathParam { return _params }
}

class JD800SpecialSetupKeyPatch : JD800Patch {
  
  static let initFileName = ""
  static let nameByteRange = 0..<0xa
  class var size: RolandAddress { return 0x58 }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    let index = path?.endex ?? 0
    return RolandAddress([0x0a]) + (RolandAddress([0x58]) * index)
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
//    self[.level] = 127
//    self[[.out, .assign]] = 13
  }

  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.mute, .group]] = OptionsParam(byte: 0x0A, options: ["OFF", "A", "B", "C", "D", "E", "F", "G", "H"])
    p[[.env, .mode]] = OptionsParam(byte: 0x0B, options: ["SUSTAIN", "NO SUSTAIN"])
    p[[.pan]] = RangeParam(byte: 0x0C, maxVal: 60, displayOffset: -30)
    p[[.fx, .mode]] = OptionsParam(byte: 0x0D, options: ["DRY", "REV", "CHO+REV", "DLY+REV"])
    p[[.fx, .level]] = RangeParam(byte: 0x0E, maxVal: 100)
    
    JD800TonePatch.params.forEach {
      let param: Param
      let offset = 0x10
      if let orig = $0.value as? RangeParam {
        param = RangeParam(parm: orig.parm, byte: orig.byte + offset, range: orig.range, displayOffset: orig.displayOffset, formatter: orig.formatter)
      }
      else if let orig = $0.value as? OptionsParam {
        param = OptionsParam(parm: orig.parm, byte: orig.byte + offset, options: orig.options)
      }
      else {
        return
      }
      p[$0.key] = param
    }

    return p
  }()
  class var params: SynthPathParam { return _params }
}
