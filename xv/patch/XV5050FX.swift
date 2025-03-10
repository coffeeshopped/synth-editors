
extension XV5050 {
  
  enum FX {
    
    static let patchWerk = XV.FX.patchWerk(params: params)

    static let parms: [Parm] = [
      .p([.type], 0x00, .options(fxTypeOptions)),
      .p([.dry], 0x01),
      .p([.chorus], 0x02),
      .p([.reverb], 0x03),
      .p([.out], 0x04, .opts(["A","B"])),
    ] + .prefix([.ctrl], count: 4, bx: 2, block: { index, offset in
      [
        .p([.src], 0x05, .options(ctrlSrcOptions)),
        .p([.amt], 0x06, .rng(1...127, dispOff: -64)),
      ]
    }) + .prefix([.ctrl], count: 4, bx: 1, block: { index, offset in
      [
        .p([.assign], 0x0d, .options(ctrlAssignOptions)),
      ]
    }) + .prefix([.param], count: 32, bx: 4, block: { index, offset in
      [
        .p([], 0x11, packIso: XV.multiPack4(0x11 + offset), .rng(12768...52768, dispOff: -32768)),
      ]
    })

    static let params = parms.params()
    
    static let fxTypeOptions: [Int:String] = XV.FX.allFx.enumerated().dict {
      [$0.offset : XV.FX.fxDisplayName($0.offset)]
    }
    
    static let aTypeOptions = fxTypeOptions.dict {
      [$0.key : $0.value + (isBCFX(index: $0.key) ? " ♢" : "")]
    }
    
    static let bcTypeOptions = fxTypeOptions.filter { isBCFX(index: $0.key) }
    
    static func isBCFX(index: Int) -> Bool {
      return (0...23).contains(index) || (26...41).contains(index) || (44...45).contains(index) || (52...58).contains(index) || (62...63).contains(index)
    }
    

    static let ctrlSrcOptions: [Int:String] = {
      var opts = [
        0 : "Off",
        96 : "Bend",
        97 : "Aftertouch",
        98 : "System 1",
        99 : "System 2",
        100 : "System 3",
        101 : "System 4",
        ]
      (1...31).forEach { opts[$0] = "CC \($0)" }
      (33...95).forEach { opts[$0] = "CC \($0)" }
      return opts
    }()
    
    static let ctrlAssignOptions: [Int:String] = OptionsParam.makeOptions(17.map { $0 == 0 ? "Off" : "\($0)" })
  }
  
  enum Chorus {
    static let patchWerk = XV.Chorus.patchWerk(params: params)
    
    static let parms: [Parm] = [
      .p([.type], 0x00, .opts(["Off", "Chorus", "Delay", "GM2 Chorus"])),
      .p([.level], 0x01),
      .p([.out, .assign], 0x02, .opts(["A","B"])),
      .p([.out, .select], 0x03, .opts(["Main", "Reverb", "Main+Rev"])),
    ] + .prefix([.param], count: 12, bx: 4, block: { index, offset in
      [
        .p([], 0x04, packIso: XV.multiPack4(0x04 + offset), .rng(12768...52768, dispOff: -32768)),
      ]
    })

    static let params = parms.params()
  }
  
  enum Reverb {
    static let patchWerk = XV.Reverb.patchWerk(params: params)
    
    static let parms: [Parm] = [
      .p([.type], 0x00, .opts(["Off", "Reverb", "SRV Room", "SRV Hall", "SRV Plate", "GM2 Reverb"])),
      .p([.level], 0x01),
      .p([.out, .assign], 0x02, .opts(["A","B"])),
    ] + .prefix([.param], count: 20, bx: 4, block: { index, offset in
      [
        .p([], 0x03, packIso: XV.multiPack4(0x03 + offset), .rng(12768...52768, dispOff: -32768)),
      ]
    })

    static let params = parms.params()
  }

  
  
}

