
class JD800VoiceBank : TypicalTypedRolandCompactAddressableBank<JD800VoicePatch>, VoiceBank {
  
  override class func offsetAddress(location: Int) -> RolandAddress {
    return RolandAddress(0x0300) * location
  }

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x050000
  }
  
  override class var initFileName: String { return "jd800-voice-bank-init" }
  override class var patchCount: Int { return 64 }

  required init(data: Data) {
    let p = Self.patchArray(fromCompactData: data)
    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
}
