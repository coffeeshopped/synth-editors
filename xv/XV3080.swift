
public enum XV3080 {
  
  static let rhythmPatchWerk = XV.Rhythm.patchWerk(commonOuts: Voice.Common.outAssignOptions, toneOuts: Voice.Tone.outAssignOptions, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk)

  static let rhythmBankWerk = XV.Rhythm.bankWerk(rhythmPatchWerk)

  static let partCount = 16
  static let editorTruss = XV.editorTruss("XV-3080", global: Global.patchWerk, perf: Perf.patchWerk, partCount: partCount, voice: Voice.patchWerk, rhythm: rhythmPatchWerk, voiceBank: Voice.bankWerk, perfBank: Perf.bankWerk, rhythmBank: rhythmBankWerk, fx: FX.patchWerk)

  static let config = XV.CtrlConfig(waveGroupOptions: Voice.Tone.waveGroupOptions, partConfig: Perf.Part.config, perfTruss: Perf.patchWerk.truss, voiceTruss: Voice.patchWerk.truss, fxTruss: FX.patchWerk.truss, partCount: partCount)
  
  static let sections = XV.sections(config: config, global: XV.Global.Controller.controller3080())
  public static let moduleTruss = XV.moduleTruss(editorTruss, subid: "xv3080", sections: sections, config: config)
  
}
