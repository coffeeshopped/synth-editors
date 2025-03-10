
class CircuitSynthBank : TypicalTypedSysexPatchBank<CircuitSynthPatch> {
  
  override class var patchCount: Int { return 64 }
  // TODO: need actual init file
  override class var initFileName: String { return "circuit-synth-bank-init" }
  
  required public init(data: Data) {
    if data.count > 6 && data[6] == 0x00 {
      // cmd = set temp patch -> this is from a fetch
      let sysex = SysexData(data: data)
      if sysex.count == 64 {
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
    return sysexData { (patch, location) -> Data in
      patch.sysexData(location: location)
    }
  }

}
