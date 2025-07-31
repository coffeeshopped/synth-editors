
extension D10 {
  
  enum Patch {
    
    static let patchWerk = try! DXX.sysexWerk.singlePatchWerk("Patch", parms.params(), size: 0x26, start: 0x030400, name: .basic(0x15..<0x25))
    
    static let bankWerk = DXX.compactSingleBankWerk(patchWerk: patchWerk, start: 0x070000, patchCount: 128, validSizes: [5054])
    
    static let parms: [Parm] = [
      .p([.key, .mode], 0x00, .opts(["Whole","Dual","Split"])),
      .p([.split, .pt], 0x01, .iso(Miso.noteName(zeroNote: "C2"), 0...61)),
      .p([.lo, .tone, .group], 0x02, .opts(toneGroupOptions)),
      .p([.lo, .tone, .number], 0x03, .opts(toneNumberOptions)),
      .p([.hi, .tone, .group], 0x04, .opts(toneGroupOptions)),
      .p([.hi, .tone, .number], 0x05, .opts(toneNumberOptions)),
      .p([.lo, .tune], 0x06, .max(48, dispOff: -24)),
      .p([.hi, .tune], 0x07, .max(48, dispOff: -24)),
      .p([.lo, .fine], 0x08, .max(100, dispOff: -50)),
      .p([.hi, .fine], 0x09, .max(100, dispOff: -50)),
      .p([.lo, .bend], 0x0a, .max(24)),
      .p([.hi, .bend], 0x0b, .max(24)),
      .p([.lo, .assign, .mode], 0x0c, .opts(assignModeOptions)),
      .p([.hi, .assign, .mode], 0x0d, .opts(assignModeOptions)),
      .p([.lo, .out, .assign], 0x0e, .max(1)),
      .p([.hi, .out, .assign], 0x0f, .max(1)),
      .p([.reverb, .type], 0x10, .opts(D110.System.reverbTypeOptions)),
      .p([.reverb, .time], 0x11, .max(7, dispOff: 1)),
      .p([.reverb, .level], 0x12, .max(7)),
      .p([.balance], 0x13, .max(100, dispOff: -50)),
      .p([.level], 0x14, .max(100)),
    ]
    
    static let toneGroupOptions = ["A","B","Int","Rhythm"]
    
    static let toneNumberOptions = (0...63).map { "\($0+1)" }
    
    static let assignModeOptions = ["Poly 1","Poly 2","Poly 3","Poly 4"]
    
  }
  
}
