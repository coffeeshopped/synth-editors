
extension JV880 {
  
  enum Perf {
    
    static let patchWerk = JV8X.Perf.patchWerk(part: Part.patchWerk)
    static let bankWerk = JV8X.Perf.bankWerk(patchWerk)

    enum Part {
      static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Perf Part", parms.params(), size: 0x23, start: 0x0800)
      
      static let parms = JV80.Perf.Part.parms + [
        .p([.out, .assign], 0x22, .opts(["Main", "Sub", "Patch"])),
      ]
    }

  }
  
}

