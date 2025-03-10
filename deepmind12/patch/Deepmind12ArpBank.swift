
class Deepmind12ArpBank : TypicalTypedSysexPatchBank<Deepmind12ArpPatch> {

  override class var fileDataCount: Int { return 32 * 90 }
  override class var patchCount: Int { return 32 }
  override class var initFileName: String { return "deepmind12-arp-bank-init" }

  required init(data: Data) {
    super.init(patches: Self.patchArray(fromData: data, namePrefix: "Arp"))
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  
  func sysexData(deviceId: Int) -> Data {
    return sysexData { (patch, location) -> Data in
      patch.sysexData(channel: deviceId, program: location)
    }
  }
  
  override func fileData() -> Data {
    return sysexData(deviceId: 0)
  }
    
}
