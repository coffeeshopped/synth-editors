
extension XP50 {
  
  enum Voice {
    
    static let patchWerk = JVXP.Voice.patchWerk(common: Common.patchWerk, tone: JV1080.Voice.Tone.patchWerk, initFile: "xp80-init")

    static let bankWerk = JVXP.Voice.bankWerk(patchWerk)
        
    enum Common {
      
      static let patchWerk = JVXP.Perf.Common.patchWerk(parms.params(), 0x49)
            
      static let parms = JV1080.Voice.Common.parms + [
        .p([.clock, .src], 0x48, .opts(["Patch","Sequencer"])),
      ]
    }
  }
  
}
