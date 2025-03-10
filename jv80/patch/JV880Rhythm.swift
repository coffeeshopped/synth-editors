
extension JV880 {
  
  enum Rhythm {
   
    static let patchWerk = JV8X.Rhythm.patchWerk(note: Note.patchWerk)
    static let bankWerk = JV8X.Rhythm.bankWerk(patchWerk)

    enum Note {
      static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Rhythm Note", parms.params(), size: 0x34, start: 0x0000)
      
      static let parms = JV80.Rhythm.Note.parms + [
        .p([.out, .assign], 0x33, .opts(["Main","Sub"])),
      ]
    }

  }
  
}
