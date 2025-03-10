
public enum XV5080 {
  
  static let rhythmPatchWerk = XV.Rhythm.patchWerk(commonOuts: Voice.Common.outAssignOptions, toneOuts: Voice.Tone.outAssignOptions, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk)

  static let rhythmBankWerk = XV.Rhythm.bankWerk(rhythmPatchWerk)

  static let partCount = 32
  static let editorTruss = XV.editorTruss("XV-5080", global: Global.patchWerk, perf: Perf.patchWerk, partCount: partCount, voice: Voice.patchWerk, rhythm: rhythmPatchWerk, voiceBank: Voice.bankWerk, perfBank: Perf.bankWerk, rhythmBank: rhythmBankWerk, fx: FX.patchWerk)

  static let config = XV.CtrlConfig(waveGroupOptions: Voice.Tone.waveGroupOptions, partConfig: Perf.Part.config, perfTruss: Perf.patchWerk.truss, voiceTruss: Voice.patchWerk.truss, fxTruss: FX.patchWerk.truss, partCount: partCount)
  
  static let sections = XV.sections(config: config, global: XV.Global.Controller.controller5080())
  public static let moduleTruss = XV.moduleTruss(editorTruss, subid: "xv5080", sections: sections, config: config)
  
}
