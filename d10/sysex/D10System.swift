
extension D10 {
  
  enum System {
    
    static let patchWerk = try! DXX.sysexWerk.singlePatchWerk("System", parms.params(), size: 0x32, start: 0x100000, initFile: "d10-system-init")

    static let parms: [Parm] = D110.System.parms + [
    ] + .prefix([.part], count: 8, bx: 1, block: { i, off in
      [
        .p([.level], 0x21, .max(100)),
        .p([.pan], 0x2a, .max(14, dispOff: -7)),
      ]
    }) + [
      .p([.part, .rhythm, .level], 0x29, .max(100)),
    ]

  }
  
}
