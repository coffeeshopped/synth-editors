
public enum XV2020 {
  
  static let rhythmPatchWerk = XV.Rhythm.patchWerk(commonOuts: Voice.Common.outAssignOptions, toneOuts: Voice.Tone.outAssignOptions, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk)

  static let rhythmBankWerk = XV.Rhythm.bankWerk(rhythmPatchWerk)

  static let partCount = 16
  // TODO: Request for perf (like all) is a single request with start address and size.
  //   But the XV-2020 responds to this by sending as much data as an XV-5050 Performance.
  //   So, 2 extra FX sub-patches that don't really exist(?)
  static let editorTruss = XV.editorTruss("XV-2020", global: Global.patchWerk, perf: Perf.patchWerk, partCount: partCount, voice: Voice.patchWerk, rhythm: rhythmPatchWerk, voiceBank: Voice.bankWerk, perfBank: Perf.bankWerk, rhythmBank: rhythmBankWerk, fx: FX.patchWerk)

  static let config = XV.CtrlConfig(waveGroupOptions: Voice.Tone.waveGroupOptions, partConfig: Perf.Part.config, perfTruss: Perf.patchWerk.truss, voiceTruss: Voice.patchWerk.truss, fxTruss: FX.patchWerk.truss, partCount: partCount)
  
  static let sections = XV.sections(config: config, global: XV.Global.Controller.controller2020())
  public static let moduleTruss = XV.moduleTruss(editorTruss, subid: "xv2020", sections: sections, config: config)

}
