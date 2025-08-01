
extension XV5080 {
  
  enum Global {
    
    static let patchWerk = XV.sysexWerk.multiPatchWerk("Global", [
      ([.common], 0x0000, XV3080.Global.Common.patchWerk),
      ([.eq], 0x0200, Eq.patchWerk),
    ] + 32.map {
      ([.part, .i($0)], 0x1000 + ($0 * 0x100), XV3080.Global.Part.patchWerk)
    }, start: 0x00000000, initFile: "xv5080-global-init")

    enum Eq {
      
      static let patchWerk = try! XV.sysexWerk.singlePatchWerk("Global Eq", parms.params(), size: 0x21, start: 0x0200)
      
      static let parms: [Parm] = [
        .p([.on], 0x00, .max(1)),
      ] + .prefix([], count: 8, bx: 4, block: { index, offset in
        [
          .p([.lo, .freq], 0x01, .opts(["200", "400"])),
          .p([.lo, .gain], 0x02, .max(30, dispOff: -15)),
          .p([.hi, .freq], 0x03, .opts(["2000", "4000", "8000"])),
          .p([.hi, .gain], 0x04, .max(30, dispOff: -15)),
        ]
      })
      
    }
  }
  
}
