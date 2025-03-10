
class JD800PartsPatch : JD800MultiPatch, PerfPatch {
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x030000
  }
  
  class var initFileName: String { return "jd800-parts-init" }
  
  var addressables: [SynthPath:RolandSingleAddressable]
  var name = ""
  
  required init(data: Data) {
    addressables = type(of: self).addressables(forData: data)
  }
  
  private static let _addressableTypes: [SynthPath:RolandSingleAddressable.Type] = {
    var types: [SynthPath:RolandSingleAddressable.Type] =  [
      [.part, .i(5)] : SpecialPartPatch.self,
    ]
    (0..<5).forEach {
      types[[.part, .i($0)]] = PartPatch.self
    }
    return types
  }()
  class var addressableTypes: [SynthPath:RolandSingleAddressable.Type] {
    return _addressableTypes
  }
  
  private static let _subpatchAddresses: [SynthPath:RolandAddress] = {
    var adds: [SynthPath:RolandAddress] = [
      [.part, .i(5)] : 0x001e,
    ]
    (0..<5).forEach {
      adds[[.part, .i($0)]] = $0 * RolandAddress(0x6)
    }
    return adds
  }()
  class var subpatchAddresses: [SynthPath:RolandAddress] {
    return _subpatchAddresses
  }

  
  class PartPatch : JD800Patch {
    
    static let initFileName = ""
    class var size: RolandAddress { return 0x6 }
    
    static func startAddress(_ path: SynthPath?) -> RolandAddress {
      let index = path?.endex ?? 0
      return RolandAddress([0x6]) * index
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
      p[[.level]] = RangeParam(byte: 0x00, maxVal: 100)
      p[[.pan]] = RangeParam(byte: 0x01, maxVal: 60, displayOffset: -30)
      p[[.channel]] = RangeParam(byte: 0x02, maxVal: 16, formatter: {
        return $0 == 16 ? "Off" : "\($0 + 1)"
      })
      p[[.out]] = OptionsParam(byte: 0x04, options: ["Mix", "Dir"])
      p[[.fx, .mode]] = OptionsParam(byte: 0x04, options: ["DRY", "REV", "CHO+REV", "DLY+REV"])
      p[[.fx, .level]] = RangeParam(byte: 0x05, maxVal: 100)
      return p
    }()
    class var params: SynthPathParam { return _params }
  }

  class SpecialPartPatch : JD800Patch {
    
    static let initFileName = ""
    class var size: RolandAddress { return 0x4 }
    
    static func startAddress(_ path: SynthPath?) -> RolandAddress {
      return 0x1e
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
      p[[.level]] = RangeParam(byte: 0x00, maxVal: 100)
      p[[.channel]] = RangeParam(byte: 0x01, maxVal: 16, formatter: {
        return $0 == 16 ? "Off" : "\($0 + 1)"
      })
      p[[.out]] = OptionsParam(byte: 0x02, options: ["Mix", "Dir"])
      return p
    }()
    class var params: SynthPathParam { return _params }
  }
}
