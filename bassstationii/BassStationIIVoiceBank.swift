
class BassStationIIVoiceBank : TypicalTypedSysexPatchBank<BassStationIIVoicePatch> {
  
  override class var patchCount: Int { return 128 }
  // TODO: need actual init file
  override class var initFileName: String { return "bassstationii-voice-bank-init" }
  
  required public init(data: Data) {
    if data.count > 6 && data[6] == 0x00 {
      // cmd = set temp patch -> this is from a fetch
      let sysex = SysexData(data: data)
      if sysex.count == 128 {
        super.init(patches: sysex.map { Patch(data: $0) })
        return
      }
    }
    super.init(data: data)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  override func fileData() -> Data {
    return sysexData { $0.sysexData(save: true, location: $1) }
  }

}
