
extension JV880 {
  
  enum Global {
    
    static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Global", parms.params(), size: 0x110, start: 0x00000000, initFile: "jv880-global")
    
    static let parms = JV80.Global.parms + [
      .p([.out, .mode], 0x21, .opts(["Out2","Out4"])),
      .p([.rhythm, .edit, .key], 0x22, .opts(["MIDI & Int", "Int"])),
      .p([.scale, .tune], 0x23, .max(1)),
    ] + .prefix([.scale, .tune], count: 8, bx: 12, block: { index, offset in
      .prefix([.note], count: 8, bx: 1, block: { index, offset in
        [.p([], 0x24, .rng(dispOff: -64))]
      })
    }) + .prefix([.scale, .tune, .patch, .note], count: 12, bx: 1, block: { index, offset in
      [.p([], 0x0104, .rng(dispOff: -64))]
    })
    
  }
  
}
