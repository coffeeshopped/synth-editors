
class EvolverWaveBank : TypicalTypedSysexPatchBank<EvolverWavePatch> {
  
  override class var patchCount: Int { return 32 }
  override class var initFileName: String { return "evolver-wave-bank-init" }

  override func fileData() -> Data {
    return sysexData(transform: { (patch, location) -> Data in
      return patch.sysexData(location: location)
    })
  }

}
