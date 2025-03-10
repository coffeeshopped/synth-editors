
class VirusCVoiceBank : TypicalTypedSysexPatchBank<VirusCVoicePatch>, VoiceBank {
  
  override class var patchCount: Int { return 128 }
  override class var initFileName: String { return "virusc-voice-bank-init" }

  func sysexData(deviceId: UInt8, bank: UInt8) -> Data {
    return sysexData { $0.sysexData(deviceId: deviceId, bank: bank, part: UInt8($1)) }
  }
  
  override func fileData() -> Data {
    return sysexData(deviceId: 16, bank: 1)
  }
}

