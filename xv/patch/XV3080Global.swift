
extension XV3080 {
  
  enum Global {
    
    static let patchWerk = XV.sysexWerk.multiPatchWerk("Global", [
      ([.common], 0x0000, Common.patchWerk),
    ] + 32.map {
      ([.part, .i($0)], 0x1000 + ($0 * 0x100), Part.patchWerk)
    }, start: 0x00000000, initFile: "xv3080-global-init")

    enum Common {
      
      static let patchWerk = try! XV.sysexWerk.singlePatchWerk("Global Common", params, size: 0x1e, start: 0x0000)
      
      static let parms: [Parm] = [
        .p([.mode], 0x00, .opts(["Perform","Patch","GM1","GM2","GS"])),
        .p([.tune], 0x01, packIso: XV.multiPack4(0x01), .rng(24...2024, dispOff: -1024)),
        .p([.key, .shift], 0x05, .rng(40...88, dispOff: -64)),
        .p([.level], 0x06),
        .p([.scale, .tune], 0x07, .max(1)),
        .p([.patch, .remain], 0x08, .max(1)),
        .p([.mix], 0x09, .opts(["Mix","Parallel"])),
        .p([.fx], 0x0a, .max(1)),
        .p([.chorus], 0x0b, .max(1)),
        .p([.reverb], 0x0c, .max(1)),
        .p([.perf, .channel], 0x0d, .opts(17.map { $0 == 16 ? "Off" : "\($0 + 1)" })),
        .p([.perf, .bank, .hi], 0x0e),
        .p([.perf, .bank, .lo], 0x0f),
        .p([.perf, .pgm, .number], 0x10),
        .p([.patch, .channel], 0x11, .rng(0...15, dispOff: 1)),
        .p([.patch, .bank, .hi], 0x12),
        .p([.patch, .bank, .lo], 0x13),
        .p([.patch, .pgm, .number], 0x14),
        .p([.clock, .src], 0x15, .opts(["Int", "MIDI"])),
        .p([.tempo], 0x16, packIso: XV.multiPack2(0x16), .rng(20...250)),
      ] + .prefix([.ctrl], count: 4, bx: 1, block: { index, offset in
        [
          .p([.src], 0x18, .options(XV5050.Global.Common.ctrlSrcOptions)),
        ]
      }) + [
        .p([.rcv, .pgmChange], 0x1c, .max(1)),
        .p([.rcv, .bank], 0x1d, .max(1)),
      ]

      static let params = parms.params()
    }

    enum Part {
      static let patchWerk = try! XV.sysexWerk.singlePatchWerk("Global Part", params, size: 0x0c, start: 0x1000)
      
      static let parms: [Parm] = .prefix([.scale, .tune], count: 12, bx: 1) { index, offset in
        [.p([], 0, .rng(dispOff: -64))]
      }

      static let params = parms.params()
    }
  }
}
