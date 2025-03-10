
extension XV5050 {
  
  enum Global {
    
    static let patchWerk = XV.sysexWerk.multiPatchWerk("Global", [
      ([.common], 0x0000, Common.patchWerk),
      ([.eq], 0x0200, Eq.patchWerk),
    ], start: 0x02000000, initFile: "xv5050-global-init")
    
    
    enum Common {
      
      static let patchWerk = try! XV.sysexWerk.singlePatchWerk("Global Common", parms.params(), size: 0x21, start: 0x0000)
            
      static let parms: [Parm] = [
        .p([.tune], 0x00, p: 4, .rng(24...2024, dispOff: -1024)),
      ]
      <<< .inc(b: 0x04) { [
        .p([.key, .shift], .rng(40...88, dispOff: -64)),
        .p([.level]),
        .p([.scale, .tune], .max(1)),
        .p([.patch, .remain], .max(1)),
        .p([.mix], .opts(["Mix","Parallel"])),
        .p([.perf, .channel], .opts(17.map { $0 == 16 ? "Off" : "\($0 + 1)" })),
      ] }
      <<< [
        .p([.patch, .channel], 0x0b, .rng(0...15, dispOff: 1)),
      ]
      <<< .prefix([.scale, .tune], count: 12, bx: 1) { _ in [
        .p([], 0x0c, .rng(dispOff: -64))
      ] }
      <<< .prefix([.ctrl], count: 4, bx: 1) { _ in [
        .p([.src], 0x18, .options(ctrlSrcOptions)),
      ]}
      <<< .inc(b: 0x1c) {[
        .p([.rcv, .pgmChange], .max(1)),
        .p([.rcv, .bank], .max(1)),
        .p([.clock, .src], .opts(["Int", "MIDI", "USB"])),
        .p([.tempo], p: 2, .rng(20...250)),
      ]}
      
      static let ctrlSrcOptions: [Int:String] = {
        var opts = [
          0 : "Off",
          96 : "Bend",
          97 : "Aftertouch",
          ]
        (1...31).forEach { opts[$0] = "CC \($0)" }
        (33...95).forEach { opts[$0] = "CC \($0)" }
        return opts
      }()
    }

    enum Eq {
      
      static let patchWerk = try! XV.sysexWerk.singlePatchWerk("Global Eq", params, size: 0x11, start: 0x0200)
      
      static let parms: [Parm] = [
        .p([.on], 0x00, .max(1)),
      ] + .prefix([], count: 4, bx: 4, block: { index, offset in
        [
          .p([.lo, .freq], 0x01, .opts(["200", "400"])),
          .p([.lo, .gain], 0x02, .max(30, dispOff: -15)),
          .p([.hi, .freq], 0x03, .opts(["2000", "4000", "8000"])),
          .p([.hi, .gain], 0x04, .max(30, dispOff: -15)),
        ]
      })
      
      static let params = parms.params()
    }
  }
  
}
