
class NordLead2VoiceBank : TypicalTypedSysexPatchBank<NordLead2VoicePatch> {
  
  override class var patchCount: Int { return 99 }
  // TODO: need actual init file
  override class var initFileName: String { return "nl2-voice-bank-init" }
  
  override func fileData() -> Data {
    return sysexData { $0.sysexData(deviceId: 0, bank: 1, location: $1) }
  }
  
}
