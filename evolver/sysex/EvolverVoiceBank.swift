
class EvolverTypeVoiceBank<T:EvolverVoicePatch> : TypicalTypedSysexPatchBank<T> {
  
  override class var patchCount: Int { return 128 }
  override class var initFileName: String { return "evolver-voice-bank-init" }
  override class var fileDataCount: Int { return patchCount * 252 }
  
  override class func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, 29184].contains(fileSize)
  }

  override func fileData() -> Data {
    return sysexData(transform: { (patch, location) -> Data in
      return Data(patch.sysexData(bank: 0, location: location).joined())
    })
  }
}

class EvolverVoiceBank : EvolverTypeVoiceBank<EvolverVoicePatch> { }
