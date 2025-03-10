
class DW8KVoiceBank : TypicalTypedSysexPatchBank<DW8KVoicePatch>, VoiceBank {
  
  override class var patchCount: Int { return 64 }
  override class var fileDataCount: Int { return patchCount * 64 } // larger patch file size
  // TODO: need actual init file
  override class var initFileName: String { return "dw8k-voice-bank-init" }

  // 3648 is data from fetch (no write requests)
  // 4096 is file data with write requests
  // 4224 is a proprietary format that we can still parse...
  //    https://www.pallium.com/bryan/dwpatches.php
  override open class func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, 3648, 4224].contains(fileSize)
  }

  required public init(data: Data) {
    let sysex = SysexData(data: data)
    super.init(patches: (0..<64).map {
      let p: Patch
      switch sysex.count {
      case 64:
        p = Patch(data: sysex[$0])
      case 128:
        // assumes bank file is 64 patches, in order, with every other msg being the write request
        p = Patch(data: sysex[$0 * 2])
      default:
        p = Patch()
      }
      p.name = "Patch \(($0 / 8) + 1)\(($0 % 8) + 1)"
      return p
    })
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  override func fileData() -> Data {
    return sysexData { (patch, location) -> Data in
      Data(patch.sysexData(channel: 0, location: location).joined())
    }
  }

}

