
public enum XP30 {
  
  enum Editor {
    // hard-coded deviceId
    static let truss = JVXP.editorTruss("XP-30", deviceId: .constant(16), global: JV1010.Global.patchWerk, perf: XP50.Perf.patchWerk, voice: JV2080.Voice.patchWerk, rhythm: JV1080.Rhythm.patchWerk, voiceBank: JV2080.Voice.bankWerk, perfBank: XP50.Perf.bankWerk, rhythmBank: JV1080.Rhythm.bankWerk)
  }

  
  public enum Module {
    
    public static let truss = JVXP.moduleTruss(Editor.truss, subid: "xp30", sections: sections)
    
    static let sections = JVXP.sections(perf: perf, clkSrc: true, cat: true)
    
    static let perf = JV1080.Perf.Controller.controller(showXP: true, show2080: false, config: JV1010.Perf.Part.config)

  }
  
}
