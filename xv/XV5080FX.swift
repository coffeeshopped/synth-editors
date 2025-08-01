
extension XV5080 {
  
  enum FX {
    static let patchWerk = XV.FX.patchWerk(params: parms.params())

    static let fxTypeOptions: [Int : String] = XV5050.FX.fxTypeOptions
    
    static let parms = XV5050.FX.parms + [
      .p([.out], 0x04, .options(outOptions)),
    ]
    
    static let outOptions: [Int:String] = OptionsParam.makeOptions(["A","B","C","D"])
  }

  enum Chorus {
    static let patchWerk = XV.Chorus.patchWerk(params: parms.params())

    static let parms = XV5050.Chorus.parms + [
      .p([.out, .assign], 0x02, .options(FX.outOptions)),
    ]
  }

  enum Reverb {
    static let patchWerk = XV.Reverb.patchWerk(params: parms.params())

    static let parms = XV5050.Reverb.parms + [
      .p([.out, .assign], 0x02, .options(FX.outOptions)),
    ]
  }
}

