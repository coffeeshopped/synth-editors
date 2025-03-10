
class JD800VoicePartPatch : JD800MultiPatch, VoicePatch {
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    let i = path?.endex ?? 0
    return RolandAddress(0x1000) + (i * RolandAddress(0x0252))
  }
  
  class var initFileName: String { return "jd800-voice-init" }
  
  var addressables: [SynthPath:RolandSingleAddressable]
  
  required init(data: Data) {
    addressables = type(of: self).addressables(forData: data)
  }
  
  private static let _addressableTypes: [SynthPath:RolandSingleAddressable.Type] = [
    [.common]      : JD800CommonPatch.self,
    [.tone, .i(0)] : JD800TonePatch.self,
    [.tone, .i(1)] : JD800TonePatch.self,
    [.tone, .i(2)] : JD800TonePatch.self,
    [.tone, .i(3)] : JD800TonePatch.self,
    ]
  class var addressableTypes: [SynthPath:RolandSingleAddressable.Type] {
    return _addressableTypes
  }
  
  private static let _subpatchAddresses: [SynthPath:RolandAddress] = [
    [.common]      : 0x0000,
    [.tone, .i(0)] : 0x0032,
    [.tone, .i(1)] : 0x007a,
    [.tone, .i(2)] : 0x0142,
    [.tone, .i(3)] : 0x020a,
    ]
  class var subpatchAddresses: [SynthPath:RolandAddress] {
    return _subpatchAddresses
  }

}
