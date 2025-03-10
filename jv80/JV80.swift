
public enum JV80 {
  
  static let editorTruss = JV8X.editorTruss("JV-80", global: Global.patchWerk, perf: Perf.patchWerk, voice: Voice.patchWerk, rhythm: Rhythm.patchWerk, voiceBank: Voice.bankWerk, perfBank: Perf.bankWerk, rhythmBank: Rhythm.bankWerk)
  
  static let sections = JV8X.sections(global: Global.Controller.ctrlr(), perf: Perf.Controller.ctrlr(), hideOut: true)
  public static let moduleTruss = JV8X.moduleTruss(editorTruss, subid: "jv80", sections: sections)
  
}
