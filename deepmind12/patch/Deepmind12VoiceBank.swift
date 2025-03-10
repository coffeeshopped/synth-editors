
class Deepmind12VoiceBank : TypicalTypedSysexPatchBank<Deepmind12VoicePatch> {

  override class var fileDataCount: Int { return 128 * 291 }
  override class var patchCount: Int { return 128 }
  override class var initFileName: String { return "deepmind12-voice-bank-init" }

  static func bankLetter(_ index: Int) -> String {
    let letters = ["A","B","C","D","E","F","G","H"]
    return letters[index]
  }
  
  func sysexData(deviceId: Int, bank: Int) -> Data {
    return sysexData { (patch, location) -> Data in
      patch.sysexData(channel: deviceId, bank: bank, program: location)
    }
  }
  
  override func fileData() -> Data {
    return sysexData(deviceId: 0, bank: 0)
  }
    
}
