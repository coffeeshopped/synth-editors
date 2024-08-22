
extension XP50 {
  
  enum Perf {
    
    static let patchWerk = JVXP.Perf.patchWerk(common: Common.patchWerk, part: Part.patchWerk, initFile: "")
    
    static let bankWerk = JVXP.Perf.bankWerk(patchWerk)
    
    enum Common {
      
      static let patchWerk = JVXP.Perf.Common.patchWerk(parms.params(), 0x42)

      static let parms = JV1080.Perf.Common.parms + [
        .p([.key, .mode], 0x40, .opts(["Layer","Single"])),
        .p([.clock, .src], 0x41, .opts(["Perform","Seq"])),
      ]
    }

    enum Part {
      
      static let patchWerk = JVXP.Perf.Part.patchWerk(parms.params(), 0x19)

      static let parms = JV1080.Perf.Part.parms + [
        .p([.octave, .shift], 0x13, .max(6, dispOff: -3)),
        .p([.local], 0x014, .max(1)),
        .p([.send], 0x015, .max(1)),
        .p([.send, .bank, .select, .group], 0x16, .opts(8.map {
          $0 == 0 ? "Patch" : "Group \($0)"
        })),
        .p([.send, .volume], 0x17, packIso: JVXP.multiPack(0x17), .opts(129.map {
          $0 == 128 ? "Off" : "\($0)"
        })),
      ]
    }


  }
  
}


