
// Note that although voice patches are semi-compact (tones are compacted, common is not),
//   the bank itself is just saved as all of the patches one after another, like a non-compact bank.
class JD990Bank<Patch:JD990MultiPatch & BankablePatch> : TypicalTypedRolandAddressableBank<Patch> {
  
  override class func offsetAddress(location: Int) -> RolandAddress {
    return RolandAddress([UInt8(location), 0, 0])
  }
  
}

class JD990VoiceBank: JD990Bank<JD990VoicePatch>, VoiceBank {

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    // internal, or card
    return path?.endex == 0 ? 0x06000000 : 0x0a000000
  }
  
  override class var patchCount: Int { return 64 }
  override class var initFileName: String { return "jd990-voice-bank-init" }

  
  override class func isValid(fileSize: Int) -> Bool {
    return fileSize == 33216 || fileSize == fileDataCount
  }

}

class JD990PerfBank: JD990Bank<JD990PerfPatch>, PerfBank {

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    // internal, or card
    return path?.endex == 0 ? 0x05000000 : 0x09000000
  }
  
  override class var patchCount: Int { return 16 }
  override class var initFileName: String { return "jd990-perf-bank-init" }
  
  override class func isValid(fileSize: Int) -> Bool {
    return fileSize == 2656 || fileSize == fileDataCount
  }

}

class JD990RhythmBank : JD990Bank<JD990RhythmPatch>, RhythmBank {

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    // internal, or card
    return path?.endex == 0 ? 0x07000000 : 0x0b000000
  }
  
  override class var patchCount: Int { return 1 }
  override class var initFileName: String { return "jd990-rhythm-bank-init" }
  
  override class func isValid(fileSize: Int) -> Bool {
    return fileSize == 7206 || fileSize == fileDataCount
  }

}

