
extension D10 {
  
  enum Timbre {
    
    // rep's Timbre memory.
    static let patchSize: RolandAddress = 0x08
    static let patchWerk = try! DXX.sysexWerk.singlePatchWerk("Timbre", parms.params(), size: patchSize, start: 0x030000, defaultName: "Timbre")
    
    static let bankWerk = DXX.compactSingleBankWerk(patchWerk: patchWerk, start: 0x050000, patchCount: 128, validSizes: [1064])

    static let parms: [Parm] = [
      .p([.tone, .group], 0x00, .opts(Patch.toneGroupOptions)),
      .p([.tone, .number], 0x01, .opts(Patch.toneNumberOptions)),
      .p([.tune], 0x02, .max(48, dispOff: -24)),
      .p([.fine], 0x03, .max(100, dispOff: -50)),
      .p([.bend], 0x04, .max(24)),
      .p([.assign, .mode], 0x05, .opts(Patch.assignModeOptions)),
      .p([.out, .assign], 0x06, .max(1)), // reverb on/off
    ]

  }
    
}
