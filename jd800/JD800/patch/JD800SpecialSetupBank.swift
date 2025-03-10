
class JD800SpecialSetupBank : TypicalTypedRolandCompactAddressableBank<JD800SpecialSetupPatch>, RhythmBank {
  
  override class func offsetAddress(location: Int) -> RolandAddress {
    return RolandAddress(0)
  }

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x040000
  }
  
  override class var initFileName: String { return "jd800-special-setup-bank-init" }
  override class var patchCount: Int { return 1 }

  required init(data: Data) {
    let p = Self.patchArray(fromCompactData: data)
    super.init(patches: p)
  }
  
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
}

