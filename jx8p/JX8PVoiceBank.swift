
class JX8PVoiceBank : TypicalTypedSysexPatchBank<JX8PVoicePatch>, VoiceBank {
  
  // 77 * 32
  override class var fileDataCount: Int { 2464 }
  override class var patchCount: Int { 32 }
  override class var initFileName: String { "jx8p-voice-bank-init" }
  
  override class func isValid(fileSize: Int) -> Bool {
    fileSize == fileDataCount || fileSize == 2496
  }
  
  // data should be 32 pairs of sysex msgs:
  // either: tone, then write to location (this is what we write to)
  // or: patch param to indicate location, then tone (this is fetch via pressing buttons)
  required init(data: Data) {
    let sysex = SysexData(data: data)
    var p = [Patch](repeating: Patch(), count: Self.patchCount)
    (0..<(sysex.count / 2)).forEach { i in
      let msg1 = sysex[i * 2]
      let msg2 = sysex[i * 2 + 1]
      let toneMsg = msg1.count == 67 ? msg1 : msg2
      let writeMsg = msg1.count == 67 ? msg2 : msg1

      let nextP = Patch(data: toneMsg)
      let location = writeMsg.count >= 9 ? writeMsg[8] : 0
      p[Int(location)] = nextP
    }
    
    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  func sysexData(channel: Int) -> [Data] {
    let msgs = (0..<Self.patchCount).map {
      patches[$0].writeData(channel: channel, location: $0)
    }
    return [Data](msgs.joined())
  }
  
  // put here bc TypicalTypedRolandAddressableBank has same impl, but calls protocol version of
  // sysexData(deviceId: for some reason
  override func fileData() -> Data {
    Data(sysexData(channel: 0).joined())
  }

}
