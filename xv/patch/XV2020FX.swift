
extension XV2020 {
  
  enum FX {
    static let patchWerk = XV.FX.patchWerk(params: parms.params())

    static let parms = XV3080.FX.parms + [
      .p([.type], 0x00, .options(fxTypeOptions)),
      .p([.out], 0x04, .options(outOptions)),
    ]
    
    static let fxTypeOptions: [Int:String] = 41.dict {
      [$0 : XV.FX.fxDisplayName($0)]
    }

    static let outOptions: [Int:String] = OptionsParam.makeOptions(["A"])
  }

  enum Chorus {
    static let patchWerk = XV.Chorus.patchWerk(params: parms.params())

    static let parms = XV5050.Chorus.parms + [
      .p([.type], 0x00, .opts(["Off", "Chorus"])),
      .p([.out, .assign], 0x02, .options(FX.outOptions)),
    ]
  }

  enum Reverb {
    static let patchWerk = XV.Reverb.patchWerk(params: parms.params())

    static let parms = XV5050.Reverb.parms + [
      .p([.type], 0x00, .opts(["Off", "Reverb"])),
      .p([.out, .assign], 0x02, .options(FX.outOptions)),
    ]

  }
}


