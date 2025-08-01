
extension XV5080 {
  
  enum Global {
    
    const patchWerk = XV.sysexWerk.multiPatchWerk("Global", [
      ("common", 0x0000, XV3080.Global.Common.patchWerk),
      ("eq", 0x0200, Eq.patchWerk),
    ] + 32.map {
      ("part/$0", 0x1000 + ($0 * 0x100), XV3080.Global.Part.patchWerk)
    }, start: 0x00000000, initFile: "xv5080-global-init")

    enum Eq {
      
      const patchWerk = try! XV.sysexWerk.singlePatchWerk("Global Eq", parms.params(), size: 0x21, start: 0x0200)
      
      const parms: [Parm] = [
        ['on', { b: 0x00, max: 1 }],
      ] + .prefix([], count: 8, bx: 4, block: { index, offset in
        [
          ['lo/freq', { b: 0x01, opts: ["200", "400"] }],
          ['lo/gain', { b: 0x02, max: 30, dispOff: -15 }],
          ['hi/freq', { b: 0x03, opts: ["2000", "4000", "8000"] }],
          ['hi/gain', { b: 0x04, max: 30, dispOff: -15 }],
        ]
      })
      
    }
  }
  
}
