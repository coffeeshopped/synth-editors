
extension JV880 {
  
  enum Voice {
    
    static let patchWerk = JV8X.Voice.patchWerk(tone: Tone.patchWerk)
    static let bankWerk = JV8X.Voice.bankWerk(patchWerk)

    enum Tone {
      
      static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Voice Tone", parms.params(), size: 0x74, start: 0x0800, randomize: {
        JV80.Voice.Tone.patchWerk.truss.randomize() <<< [
          [.out, .assign] : 0,
        ]
      })
            
      static let parms = JV80.Voice.Tone.parms + [
        .p([.out, .assign], 0x73, .opts(["Mix","Sub"])),
      ]
    }

  }
  
}
