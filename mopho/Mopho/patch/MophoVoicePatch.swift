
struct MophoVoicePatch : MophoVoiceTypePatch {
  
  static var relatedBankType: SysexPatchBank.Type? = FnSingleBank<MophoVoiceBank>.self
        
  static let idByte: UInt8 = 0x25
  static let initFileName = "Mopho-init"
  
  static func randomize(patch: ByteBackedSysexPatch) {
    patch.randomizeAllParams()
    tamedRandomVoice().forEach { patch[$0.key] = $0.value }
  }
  
  static let paramOptions: [ParamOptions] =
    osc()
    <<< inc(b: 12) { [
      o([.sync], p: 10, max: 1),
      o([.glide], p: 11, opts: glideOptions),
      o([.slop], p: 12, max: 5),
      o([.bend], p: 93, max: 12),
      o([.keyAssign], p: 96, opts: keyAssignOptions),
      o([.mix], p: 13, dispOff: -64, isoS: mixIso),
      o([.noise], p: 14),
      o([.extAudio], p: 116),
    ] }
    <<< filter()
    <<< ampEnv()
    <<< [
      o([.volume], 40, p: 29)
    ]
    <<< lfo(b: 41)
    <<< env3(b: 61, repB: 69)
    <<< mods(b: 70)
    <<< ctrls(b: 82)
    <<< pushIt(b: 92)
    <<< tempoArpSeq(b: 95)
    <<< prefix([.seq], count: 4, bx: 1, px: 1) { _ in
      [
        o([.dest], 101, p: 77, opts: modDestOptions),
      ]
    }
    <<< seqSteps()
    <<< prefix([.knob], count: 4, bx: 1) { _ in
      [
        o([], 105, opts: knobAssignOptions),
      ]
    }
  
  static let params: SynthPathParam = paramsFromOpts(paramOptions)

  static let waveOptions = OptionsParam.makeOptions(["Off","Saw","Tri","Saw/Tri","Square"])
  
  static let glideOptions = OptionsParam.makeOptions(["Fixed Rate", "Fixed Rate Auto","Fixed Time","Fixed Time Auto"])
  
  static let mixIso = Miso.switcher([
    .range(0...63, Miso.m(-1) >>> Miso.a(64) >>> Miso.str("O1 +%g")),
    .int(64, "Bal"),
    .range(65...127, Miso.a(-64) >>> Miso.str("O2 +%g")),
  ])
  
  static let keyAssignOptions = OptionsParam.makeOptions(["Low Note","Low Note w/ retrig","High Note","High Note w/ retrig","Last Note","Last Note w/ retrig"])
  
  static let lfoFreqOptions = OptionsParam.makeOptions(["Unsynced","32 steps","16 steps","8 steps","6 steps","4 steps","3 steps","2 steps","1.5 steps","1 step","2/3 step","1/2 step","1/3 step","1/4 step","1/6 step","1/8 step","1/16 step"])
  
  static let lfoWaveOptions = OptionsParam.makeOptions(["Tri","Rev Saw","Saw","Square","Random"])
  
  static let pushItModeOptions = OptionsParam.makeOptions(["Normal","Toggle","Audio In"])
  
  static let clockDivOptions = OptionsParam.makeOptions(["1/2","1/4","1/8","1/8 half swing","1/8 full swing","1/8 triplets","1/16","1/16 half swing","1/16 full swing","1/16 triplets","1/32","1/32 triplets","1/64 triplets"])
  
  static let arpModeOptions = OptionsParam.makeOptions(["Up","Down","Up/Down","Assign"])
  
  static let seqTrigOptions = OptionsParam.makeOptions(["Normal","Normal no reset","No Gate","No Gate no reset","Key Step","Audio In"])
  
  static let modDestOptions = OptionsParam.makeOptions(["Off", "Osc 1 Freq", "Osc 2 Freq", "Osc 1/2 Freq", "Osc Mix", "Noise Level", "Osc 1 PW", "Osc 2 PW", "Osc 1/2 PW", "Filter Cutoff", "Resonance", "Filter Audio Mod", "VCA Level", "Pan Spread", "LFO 1 Freq", "LFO 2 Freq", "LFO 3 Freq", "LFO 4 Freq", "All LFO Freq", "LFO 1 Amt", "LFO 2 Amt", "LFO 3 Amt", "LFO 4 Amt", "All LFO Amt", "Filter Env Amt", "Amp Env Amt", "Env 3 Amt", "All Env Amts", "Env 1 Attack", "Env 2 Attack", "Env 3 Attack", "All Env Attacks", "Env 1 Decay", "Env 2 Decay", "Env 3 Decay", "All Env Decays", "Env 1 Release", "Env 2 Release", "Env 3 Release", "All Env Releases", "Mod 1 Amt", "Mod 2 Amt", "Mod 3 Amt", "Mod 4 Amt", "Ext Audio Level", "Sub Osc 1 Level", "Sub Osc 2 Level"])
  
  static let modSrcOptions = OptionsParam.makeOptions(["Off", "Seq Track 1", "Seq Track 2", "Seq Track 3", "Seq Track 4", "LFO 1", "LFO 2", "LFO 3", "LFO 4", "Filter Env", "Amp Env", "Env 3", "Pitch Bend", "Mod Wheel", "Pressure", "MIDI Breath", "MIDI Foot", "MIDI Expression", "Velocity", "Note Number", "Noise", "Audio In Env Follow", "Audio In Peak Hold"])
  
  static let unisonModeOptions: [Int : String] = [:]

  
  static let knobAssignOptions = OptionsParam.makeOptions(["Osc 1 Freq", "Osc 1 Fine", "Osc 1 Shape", "Osc 1 Glide", "Osc 1 Key", "Sub Osc 1 Level", "Osc 2 Freq", "Osc 2 Fine", "Osc 2 Shape", "Osc 2 Glide", "Osc 2 Key", "Sub Osc 2 Level", "Sync", "Glide Mode", "Osc Slop", "Bend Range", "Key Assign Mode", "Osc Mix", "Noise Level", "Ext Aud In Level", "Filter Freq", "Resonance", "Filter Key Amt", "Filter Aud Mod", "Filter 4-pole", "Filter Env Amt", "Filter Env Velo", "Filter Env Delay", "Filter Env Attack", "Filter Env Decay", "Filter Env Sustain", "Filter Env Release", "VCA Initial Level", "VCA Env Amt", "VCA Env Velo Amt", "VCA Env Delay", "VCA Env Attack", "VCA Env Decay", "VCA Env Sustain", "VCA Env Release", "Voice Volume", "LFO 1 Freq", "LFO 1 Shape", "LFO 1 Amount", "LFO 1 Mod Dest", "LFO 1 Key Sync", "LFO 2 Freq", "LFO 2 Shape", "LFO 2 Amount", "LFO 2 Mod Dest", "LFO 2 Key Sync", "LFO 3 Freq", "LFO 3 Shape", "LFO 3 Amount", "LFO 3 Mod Dest", "LFO 3 Key Sync", "LFO 4 Freq", "LFO 4 Shape", "LFO 4 Amount", "LFO 4 Mod Dest", "LFO 4 Key Sync", "Env 3 Mod Destination", "Env 3 Amt", "Env 3 Velo Amt", "Env 3 Delay", "Env 3 Attack", "Env 3 Decay", "Env 3 Sustain", "Env 3 Release", "Env 3 Repeat", "Mod 1 Source", "Mod 1 Amount", "Mod 1 Destination", "Mod 2 Source", "Mod 2 Amount", "Mod 2 Destination", "Mod 3 Source", "Mod 3 Amount", "Mod 3 Destination", "Mod 4 Source", "Mod 4 Amount", "Mod 4 Destination", "Mod Wheel Amt", "Mod Wheel Destination", "Pressure Amt", "Pressure Destination", "Breath Amt", "Breath Destination", "Velocity Amt", "Velocity Destination", "Foot Amt", "Foot Destination", "Push It Note", "Push It Velo", "Push It Mode", "Tempo", "Clock Divide", "Arp Mode", "Arp On/Off", "Seq Trigger", "Seq On/Off", "Seq 1 Destination", "Seq 2 Destination", "Seq 3 Destination", "Seq 4 Destination"])
}

