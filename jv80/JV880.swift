
public enum JV880 {
  
  static let editorTruss = JV8X.editorTruss("JV-880", global: Global.patchWerk, perf: Perf.patchWerk, voice: Voice.patchWerk, rhythm: Rhythm.patchWerk, voiceBank: Voice.bankWerk, perfBank: Perf.bankWerk, rhythmBank: Rhythm.bankWerk)

  static let sections = JV8X.sections(global: Global.Controller.ctrlr(), perf: Perf.Controller.ctrlr(), hideOut: false)
  public static let moduleTruss = JV8X.moduleTruss(editorTruss, subid: "jv880", sections: sections)
  
}
