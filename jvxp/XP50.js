
public enum XP50 {
  
  enum Editor {
    
    static let truss = JVXP.editorTruss("XP-50", global: Global.patchWerk, perf: Perf.patchWerk, voice: Voice.patchWerk, rhythm: JV1080.Rhythm.patchWerk, voiceBank: Voice.bankWerk, perfBank: Perf.bankWerk, rhythmBank: JV1080.Rhythm.bankWerk)
  }
  
  public enum Module {
    
    public static let truss = JVXP.moduleTruss(Editor.truss, subid: "xp50", sections: sections)
    
    static let sections = JVXP.sections(perf: perf, clkSrc: true, cat: false)
    
    static let perf = JV1080.Perf.Controller.controller(showXP: true, show2080: false, config: JV1080.Perf.Part.config)

  }
}
