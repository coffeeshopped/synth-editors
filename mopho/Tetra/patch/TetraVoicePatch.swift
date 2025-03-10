
struct TetraVoicePatch : MophoVoiceTypePatch {
  
  static var relatedBankType: SysexPatchBank.Type? = FnSingleBank<TetraVoiceBank>.self

  static let idByte: UInt8 = 0x26
  static let initFileName = "tetra-voice-init"
  static let fileDataCount = 444
  static var bodyCount: Int { return 384 }
  
  static func randomize(patch: ByteBackedSysexPatch) {
    patch.randomizeAllParams()
    (0..<2).forEach { layer in
      tamedRandomVoice().prefixed([.layer, .i(layer)]).forEach {
        patch[$0.key] = $0.value
      }
    }
  }

  static let layerParamOptions: [ParamOptions] =
    osc()
    <<< inc(b: 12) {[
      o([.sync], p: 10, max: 1),
      o([.glide], p: 11, opts: MophoVoicePatch.glideOptions),
      o([.slop], p: 12, max: 5),
      o([.bend], p: 93, max: 12),
      o([.mix], p: 13, dispOff: -64, isoS: MophoVoicePatch.mixIso),
      o([.noise], p: 14),
      o([.extAudio], p: 116),
      o([.extAudio, .gain], p: 110),
    ]}
    <<< filter()
    <<< ampEnv()
    <<< [
      o([.pan], 40, p: 28), // NEW
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
      o([.seq, .i(0), .dest], opts: modDestOptions),
      o([.seq, .i(1), .dest], opts: modDestSeq24Options),
      o([.seq, .i(2), .dest], opts: modDestOptions),
      o([.seq, .i(3), .dest], opts: modDestSeq24Options),
    ]}
    <<< [
      o([.osc, .i(0), .reset], 115, p: 102, max: 1),
      o([.osc, .i(1), .reset], 116, p: 103, max: 1),
    ]
    <<< seqSteps()
  
  static let paramOptions: [ParamOptions] =
    prefix([.layer], count: 2, bx: 200, px: 200) { _ in layerParamOptions }
    <<< prefix([.knob], count: 4, bx: 1) { _ in
      [
        o([], 111, p: 105, opts: knobAssignOptions),
      ]
    }
    <<< [
      o([.split, .pt], 99, p: 118, isoS: Miso.noteName(zeroNote: "C0")), // NEW
      o([.key, .mode], 100, p: 119, opts: ["Normal", "Stack", "Split"]), // NEW
    ]

  
  static let params: SynthPathParam = paramsFromOpts(paramOptions)
          
  static let keyAssignOptions = MophoVoicePatch.keyAssignOptions
  
  static let lfoFreqOptions = MophoVoicePatch.lfoFreqOptions
  
  static let lfoWaveOptions = MophoVoicePatch.lfoWaveOptions
  
  static let pushItModeOptions = OptionsParam.makeOptions(["Normal","Toggle"])
  
  static let clockDivOptions = MophoVoicePatch.clockDivOptions
  
  static let arpModeOptions = MophoKeyVoicePatch.arpModeOptions
  
  static let seqTrigOptions: [Int:String] = MophoVoicePatch.seqTrigOptions --- [5]
  
  static let modDestOptions: [Int:String] = MophoVoicePatch.modDestOptions <<< [
    44 : "Feedbk Vol",
    47 : "Feedbk Gain",
  ]

  static let unisonModeOptions = MophoKeyVoicePatch.unisonModeOptions

  static let modDestSeq24Options: [Int:String] = modDestOptions <<< [48 : "Slew"]
  
  static let modSrcOptions: [Int:String] = MophoVoicePatch.modSrcOptions --- [21, 22]
  
  static let knobAssignOptions = OptionsParam.makeOptions(["Osc 1 Freq", "Osc 1 Fine", "Osc 1 Shape", "Osc 1 Glide", "Osc 1 Key", "Sub Osc 1 Level", "Osc 2 Freq", "Osc 2 Fine", "Osc 2 Shape", "Osc 2 Glide", "Osc 2 Key", "Sub Osc 2 Level", "Sync", "Glide Mode", "Osc Slop", "Bend Range", "Osc Mix", "Noise Level", "Feedbk Vol", "Feedbk Gain", "Filter Freq", "Resonance", "Filter Key Amt", "Filter Aud Mod", "Filter 4-pole", "Filter Env Amt", "Filter Env Velo", "Filter Env Delay", "Filter Env Attack", "Filter Env Decay", "Filter Env Sustain", "Filter Env Release", "VCA Initial Level", "VCA Env Amt", "VCA Env Velo Amt", "VCA Env Delay", "VCA Env Attack", "VCA Env Decay", "VCA Env Sustain", "VCA Env Release", "Pan Spread", "Voice Volume", "LFO 1 Freq", "LFO 1 Shape", "LFO 1 Amount", "LFO 1 Mod Dest", "LFO 1 Key Sync", "LFO 2 Freq", "LFO 2 Shape", "LFO 2 Amount", "LFO 2 Mod Dest", "LFO 2 Key Sync", "LFO 3 Freq", "LFO 3 Shape", "LFO 3 Amount", "LFO 3 Mod Dest", "LFO 3 Key Sync", "LFO 4 Freq", "LFO 4 Shape", "LFO 4 Amount", "LFO 4 Mod Dest", "LFO 4 Key Sync", "Env 3 Mod Destination", "Env 3 Amt", "Env 3 Velo Amt", "Env 3 Delay", "Env 3 Attack", "Env 3 Decay", "Env 3 Sustain", "Env 3 Release", "Env 3 Repeat", "Mod 1 Source", "Mod 1 Amount", "Mod 1 Destination", "Mod 2 Source", "Mod 2 Amount", "Mod 2 Destination", "Mod 3 Source", "Mod 3 Amount", "Mod 3 Destination", "Mod 4 Source", "Mod 4 Amount", "Mod 4 Destination", "Mod Wheel Amt", "Mod Wheel Destination", "Pressure Amt", "Pressure Destination", "Breath Amt", "Breath Destination", "Velocity Amt", "Velocity Destination", "Foot Amt", "Foot Destination", "Unison Mode", "Unison Assign", "Unison On", "Push It Note", "Push It Velo", "Push It Mode", "Split Pt", "Key Mode", "Tempo", "Clock Divide", "Arp Mode", "Arp On/Off", "Seq Trigger", "Seq On/Off", "Seq 1 Destination", "Seq 2 Destination", "Seq 3 Destination", "Seq 4 Destination"]
  )
}

