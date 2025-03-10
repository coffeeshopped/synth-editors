
class MicronVoiceBank : TypicalTypedSysexPatchBank<MicronVoicePatch> {
  
  override class var patchCount: Int { return 128 }
  // TODO: need actual init file
  override class var initFileName: String { return "micron-voice-bank-init" }
  
  // Micron returns all fetched data with same location indexes
  // So just go off the order of the messages
  required public init(data: Data) {
    let sysex = SysexData(data: data)
    var p: [Patch] = sysex.compactMap {
      guard Patch.isValid(sysex: $0) else { return nil }
      return Patch(data: $0)
    }
    let patchesLeft = type(of: self).patchCount - p.count
    // Add in any missing patches
    p.append(contentsOf: (0..<patchesLeft).map { _ in Patch() })
    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  override func fileData() -> Data {
    return sysexData { (patch, location) -> Data in
      patch.sysexData(bank: 0, location: UInt8(location))
    }
  }

}
