
public enum JV1010 {
  
  enum Editor {    
    // hard-coded deviceId
    static let truss = JVXP.editorTruss("JV-1010", deviceId: .constant(16), global: Global.patchWerk, perf: XP50.Perf.patchWerk, voice: JV2080.Voice.patchWerk, rhythm: JV1080.Rhythm.patchWerk, voiceBank: JV2080.Voice.bankWerk, perfBank: XP50.Perf.bankWerk, rhythmBank: JV1080.Rhythm.bankWerk)
  }
  
  public enum Module {
    
    public static let truss = JVXP.moduleTruss(Editor.truss, subid: "jv1010", sections: sections)
    
    static let sections = JVXP.sections(perf: perf, clkSrc: true, cat: true)
    
    static let perf = JV1080.Perf.Controller.controller(showXP: false, show2080: false, config: Perf.Part.config)
  }
  
}
