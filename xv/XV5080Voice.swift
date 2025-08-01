
extension XV5080 {
  
  enum Voice {
    
    static let patchWerk = XV.Voice.patchWerk(common: Common.patchWerk, tone: Tone.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, initFile: "xv5050-voice-init")
    
    static let bankWerk = XV.Voice.bankWerk(patchWerk)
    
    enum Common {
      static let patchWerk = XV.Voice.Common.patchWerk(params)
      
      static let parms = XV3080.Voice.Common.parms + [
        .p([.out, .assign], 0x27, .options(outAssignOptions))
      ]
      static let params = parms.params()

      static let outAssignOptions = XV5080.Voice.Tone.outAssignOptions <<<
        [13 : "Tone"]
    }
    
    enum Tone {
      static let patchWerk = XV.Voice.Tone.patchWerk(params: params)
      
      static let parms = XV3080.Voice.Tone.parms + [
        .p([.out, .assign], 0x11, .options(outAssignOptions))
      ]
      static let params = parms.params()
      
      static let waveGroupOptions = XV3080.Voice.Tone.waveGroupOptions
      
      static let outAssignOptions = [
        0 : "MFX",
        1 : "A",
        2 : "B",
        3 : "C",
        4 : "D",
        5 : "1",
        6 : "2",
        7 : "3",
        8 : "4",
        9 : "5",
        10 : "6",
        11 : "7",
        12 : "8"
      ]
    }
    
  }
}

