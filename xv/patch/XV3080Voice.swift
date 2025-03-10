
extension XV3080 {
  
  enum Voice {
    
    static let patchWerk = XV.Voice.patchWerk(common: Common.patchWerk, tone: Tone.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, initFile: "xv5050-voice-init")
    
    static let bankWerk = XV.Voice.bankWerk(patchWerk)
    
    enum Common {
      static let patchWerk = XV.Voice.Common.patchWerk(params)
      
      static let parms = XV5050.Voice.Common.parms + [
        .p([.out, .assign], 0x27, .options(outAssignOptions))
      ]
      static let params = parms.params()
      
      static let outAssignOptions = [
        0 : "MFX",
        1 : "A",
        2 : "B",
        3 : "C",
        5 : "1",
        6 : "2",
        7 : "3",
        8 : "4",
        9 : "5",
        10 : "6",
        13 : "Tone",
        ]
    }
    
    enum Tone {
      
      static let patchWerk = XV.Voice.Tone.patchWerk(params: params)
      
      static let parms = XV5050.Voice.Tone.parms + [
        .p([.out, .assign], 0x11, .options(outAssignOptions))
      ]
      static let params = parms.params()

      static let outAssignOptions = [
        0 : "MFX",
        1 : "A",
        2 : "B",
        3 : "C",
        5 : "1",
        6 : "2",
        7 : "3",
        8 : "4",
        9 : "5",
        10 : "6",
        ]
      
      public static let waveGroupOptions =
        XV5050.Voice.Tone.internalWaveGroupOptions <<<
        XV5050.Voice.Tone.srxWaveGroupOptions <<<
        XV5050.Voice.Tone.srjvWaveGroupOptions
    }
  }
}
