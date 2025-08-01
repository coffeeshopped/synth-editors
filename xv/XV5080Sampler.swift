
//class XV5080SamplerPatch : XVMultiPatch {
//  
////  override class var bankType: SysexPatchBank.Type { return XV5080VoiceBank.self }
//  
//  static func location(forData data: Data) -> Int {
//    return Int(addressBytes(forSysex: data)[1])
//  }
//  
//  static func startAddress(_ path: SynthPath?) -> RolandAddress {
//    if (path?.count ?? 0) > 1 {
//      return RolandAddress(0x11000000) + (path!.endex * RolandAddress(0x200000))
//    }
//    else {
//      return 0x1f000000
//    }
//  }
//
//  class var initFileName: String { return "xv5080-sampler-init" }
//  
//  var addressables: [SynthPath:RolandSingleAddressable]
//  
//  required init(data: Data) {
//    addressables = type(of: self).addressables(forData: data)
//  }
//  
//  private static let _addressableTypes: [SynthPath:RolandSingleAddressable.Type] = {
//    var map: [SynthPath:RolandSingleAddressable.Type] = [
//      [.common]      : XV5050CommonPatch.self,
//      [.fx]          : XV5050FXPatch.self,
//      [.chorus]      : XV5050ChorusPatch.self,
//      [.reverb]      : XV5050ReverbPatch.self,
//      [.mix]         : XV5050ToneMixPatch.self,
//      ]
//    (0..<88).forEach {
//      map[[.split, .i($0)]] = XV5080VoiceSplitPatch.self
//    }
//    return map
//  }()
//  class var addressableTypes: [SynthPath:RolandSingleAddressable.Type] {
//    return _addressableTypes
//  }
//  
//  private static let _subpatchAddresses: [SynthPath:RolandAddress] = {
//    var map: [SynthPath:RolandAddress] = [
//      [.common]      : 0x0000,
//      [.fx]          : 0x0200,
//      [.chorus]      : 0x0400,
//      [.reverb]      : 0x0600,
//      [.mix]         : 0x1000,
//      ]
//    (0..<88).forEach {
//      map[[.split, .i($0)]] = RolandAddress(0x3000) + ($0 * RolandAddress(0x20))
//    }
//    return map
//  }()
//  class var subpatchAddresses: [SynthPath:RolandAddress] {
//    return _subpatchAddresses
//  }
//  
//}
//
//class XV5080VoiceSplitPatch : XVPatch {
//  
//  static let initFileName = ""
//  class var size: RolandAddress { return 0xc }
//  
//  static func startAddress(_ path: SynthPath?) -> RolandAddress {
//    return RolandAddress(0x3000) + ((path?.endex ?? 0) * RolandAddress(0x20))
//  }
//  
//  var bytes: [UInt8]
//  
//  required init(data: Data) {
//    bytes = type(of: self).contentBytes(forData: data)
//  }
//  
//  private static let _params: SynthPathParam = {
//    var p = SynthPathParam()
//    
//    p[[.partial]] = OptionsParam(parm: 4, byte: 0x0, options: OptionsParam.makeOptions({
//      (0...4096).map { $0 == 0 ? "Off" : "\($0)" }
//    }()))
//    p[[.assign, .type]] = OptionsParam(byte: 0x04, options: ["Multi", "Single"])
//    p[[.mute, .group]] = OptionsParam(byte: 0x05, options: OptionsParam.makeOptions({
//      (0...31).map { $0 == 0 ? "Off" : "\($0)" }
//      }()))
//    p[[.dry]] = RangeParam(byte: 0x06)
//    p[[.chorus, .fx]] = RangeParam(byte: 0x7)
//    p[[.reverb, .fx]] = RangeParam(byte: 0x8)
//    p[[.chorus]] = RangeParam(byte: 0x9)
//    p[[.reverb]] = RangeParam(byte: 0xa)
//    p[[.out, .assign]] = OptionsParam(byte: 0xb, options: outAssignOptions)
//    
//    return p
//  }()
//  
//  class var params: SynthPathParam { return _params }
//  
//  static let outAssignOptions: [Int:String] = [
//    0 : "MFX",
//    1 : "A",
//    2 : "B",
//    3 : "C",
//    4 : "D",
//    5 : "1",
//    6 : "2",
//    7 : "3",
//    8 : "4",
//    9 : "5",
//    10 : "6",
//    11 : "7",
//    12 : "8",
//    13 : "Tone",
//    ]
//
//}
