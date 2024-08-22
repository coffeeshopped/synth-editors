
public enum JV2080 {
  
  enum Editor {
    
    static let truss = JVXP.editorTruss("JV-2080", global: Global.patchWerk, perf: Perf.patchWerk, voice: Voice.patchWerk, rhythm: JV1080.Rhythm.patchWerk, voiceBank: Voice.bankWerk, perfBank: Perf.bankWerk, rhythmBank: JV1080.Rhythm.bankWerk)

  }
  
  public enum Module {
    
    public static let truss = JVXP.moduleTruss(Editor.truss, subid: "jv2080", sections: sections)
    
    static let sections = JVXP.sections(perf: perf, clkSrc: true, cat: true)
    
    static let perf = JV1080.Perf.Controller.controller(showXP: false, show2080: true, config: Perf.Part.config)

  }
}
