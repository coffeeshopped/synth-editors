
class VirusCMultiBank : TypicalTypedSysexPatchBank<VirusCMultiPatch>, PerfBank {
  
  override class var patchCount: Int { return 128 }
  override class var initFileName: String { return "virusc-multi-bank-init" }

  func sysexData(deviceId: UInt8) -> Data {
    return sysexData { $0.sysexData(deviceId: deviceId, bank: 1, part: UInt8($1)) }
  }
  
  override func fileData() -> Data {
    return sysexData(deviceId: 16)
  }
}

