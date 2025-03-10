
class VirusTIEmbeddedMultiBank : TypicalTypedSysexPatchBank<VirusTIEmbeddedMultiPatch>, PerfBank {
  
  override class var patchCount: Int { return 16 }
  override class var initFileName: String { return "virusti-embedded-multi-bank-init" }

  func sysexData(deviceId: UInt8) -> Data {
    return sysexData { Data($0.sysexData(deviceId: deviceId, location: $1).joined()) }
  }
  
  override func fileData() -> Data {
    return sysexData(deviceId: 16)
  }
}

