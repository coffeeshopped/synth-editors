
extension XV5080 {
  
  enum Voice {
    
    const patchWerk = XV.Voice.patchWerk(common: Common.patchWerk, tone: Tone.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, initFile: "xv5050-voice-init")
    
    const bankWerk = XV.Voice.bankWerk(patchWerk)
    
    enum Common {
      const patchWerk = XV.Voice.Common.patchWerk(params)
      
      const parms = XV3080.Voice.Common.parms + [
        ['out/assign', { b: 0x27, opts: outAssignOptions }]
      ]
      const params = parms.params()

      const outAssignOptions = XV5080.Voice.Tone.outAssignOptions <<<
        [13 : "Tone"]
    }
    
    enum Tone {
      const patchWerk = XV.Voice.Tone.patchWerk(params: params)
      
      const parms = XV3080.Voice.Tone.parms + [
        ['out/assign', { b: 0x11, opts: outAssignOptions }]
      ]
      const params = parms.params()
      
      const waveGroupOptions = XV3080.Voice.Tone.waveGroupOptions
      
      const outAssignOptions = [
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

