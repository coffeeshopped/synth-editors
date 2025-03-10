
extension D110 {
  
  enum Timbre {
    
    // size used to be 0x08. why? is that for D-10?
    // ah, because in MEMORY they're only 08. But temporary area is 0x10 and includes extra params (level, pan)
    static let patchWerk = try! DXX.sysexWerk.singlePatchWerk("Timbre", parms.params(), size: 0x10, start: 0x030000)
    
//    static func startAddress(_ path: SynthPath?) -> RolandAddress {
//      let endex = path?.endex ?? 0
//      return 0x030000 + (endex * RolandAddress(0x10))
//    }
      
    static let parms: [Parm] = [
      .p([.tone, .group], 0x00, .opts(D10.Patch.toneGroupOptions)),
      .p([.tone, .number], 0x01, .opts(D10.Patch.toneNumberOptions)),
      .p([.tune], 0x02, .max(48, dispOff: -24)),
      .p([.fine], 0x03, .max(100, dispOff: -50)),
      .p([.bend], 0x04, .max(24)),
      .p([.assign, .mode], 0x05, .opts(D10.Patch.assignModeOptions)),
      .p([.out, .assign], 0x06, .opts(["Mix","Mix","Multi 1","Multi 2","Multi 3","Multi 4","Multi 5","Multi 6"])),
      .p([.out, .level], 0x08, .max(100)),
      .p([.pan], 0x09, .max(14, dispOff: -7)),
      .p([.key, .lo], 0x0a, .iso(Miso.noteName(zeroNote: "C-1"))),
      .p([.key, .hi], 0x0b, .iso(Miso.noteName(zeroNote: "C-1"))),
    ]
  }
  
}
