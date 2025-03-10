
struct MophoKeyVoicePatch : MophoVoiceTypePatch {
  
  static var relatedBankType: SysexPatchBank.Type? = FnSingleBank<MophoKeyVoiceBank>.self

  static let idByte: UInt8 = 0x27
  static let initFileName: String = "mopho-key-voice-init"
  
  static func randomize(patch: ByteBackedSysexPatch) {
    patch.randomizeAllParams()
    tamedRandomVoice().forEach { patch[$0.key] = $0.value }
  }

  static let paramOptions: [ParamOptions] =
    inc(b: 16) {[
      o([.mix], p: 13, dispOff: -64, isoS: MophoVoicePatch.mixIso),
      o([.noise], p: 14),
      o([.extAudio], p: 116),
      o([.extAudio, .gain], p: 110), // NEW
    ]}
    <<< [
      o([.volume], 41, p: 29),
    ]
    <<< lfo(b: 42)
    <<< env3(b: 62, repB: 70)
    <<< mods(b: 71)
    <<< ctrls(b: 83)
    <<< unison(b: 93)
    <<< pushIt(b: 96)
    <<< tempoArpSeq(b: 101)
    <<< inc(b: 107, p: 77) {[
      o([.seq, .i(0), .dest], opts: keyModDestSeq13Options),
      o([.seq, .i(1), .dest], opts: modDestOptions),
      o([.seq, .i(2), .dest], opts: keyModDestSeq13Options),
      o([.seq, .i(3), .dest], opts: modDestOptions),
    ]}
      
  // TODO: parm is wrong for unison or key assign
  static let params: SynthPathParam =
    paramsFromOpts(MophoVoicePatch.paramOptions <<< paramOptions)
      --- (0..<4).map { [.knob, .i($0)] } // no knobs on keyboard)
  
  static let arpModeOptions = OptionsParam.makeOptions(["Up","Down","Up/Down","Assign", "Random", "Up 2 Oct", "Down 2 Oct", "Up/Down 2 Oct", "Assign 2 Oct", "Random 2 Oct", "Up 3 Oct", "Down 3 Oct", "Up/Down 3 Oct", "Assign 3 Oct", "Random 3 Oct"])
  
  static let keyModDestSeq13Options: [Int:String] = MophoVoicePatch.modDestOptions <<< [47:"Feedbk Gain"]

  // only for seq 2 & 4
  static let modDestOptions: [Int:String] = keyModDestSeq13Options <<< [48:"Slew"]
  
  static let unisonModeOptions = OptionsParam.makeOptions(["1 voice", "All", "All detune 1", "All detune 2", "All detune 3"])
  
  static let keyAssignOptions = MophoVoicePatch.keyAssignOptions

  static let lfoWaveOptions = MophoVoicePatch.lfoWaveOptions
  
  static let modSrcOptions = MophoVoicePatch.lfoWaveOptions
  
  static let pushItModeOptions = MophoVoicePatch.lfoWaveOptions
  
  static let clockDivOptions = MophoVoicePatch.lfoWaveOptions
  
  static let seqTrigOptions = MophoVoicePatch.lfoWaveOptions


}
