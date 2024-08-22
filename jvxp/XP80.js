
public enum XP80 {
  
  enum Editor {
    
    static let truss = JVXP.editorTruss("XP-80", global: Global.patchWerk, perf: XP50.Perf.patchWerk, voice: XP50.Voice.patchWerk, rhythm: JV1080.Rhythm.patchWerk, voiceBank: XP50.Voice.bankWerk, perfBank: XP50.Perf.bankWerk, rhythmBank: JV1080.Rhythm.bankWerk)

  }
  
  public enum Module {
    
    public static let truss = JVXP.moduleTruss(Editor.truss, subid: "xp80", sections: sections)
    
    static let sections = JVXP.sections(perf: perf, clkSrc: true, cat: false)
    
    static let perf = JV1080.Perf.Controller.controller(showXP: true, show2080: false, config: JV1080.Perf.Part.config)


  }
    
}
