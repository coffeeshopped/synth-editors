

struct MicroQVoicePatch : MicroQPatch, VoicePatch {
    
  static let relatedBankType: SysexPatchBank.Type? = FnSingleBank<MicroQVoiceBank>.self
  static let nameByteRange: CountableRange<Int>? = 363..<379
  static let initFileName: String = "microq-voice-init"
  static let fileDataCount: Int = 392
  
  static func bytes(data: Data) -> [UInt8] { data.safeBytes(7..<390) }
  
  static func getValue(_ bytes: [UInt8], path: SynthPath) -> Int? {
    guard path == [.category] else { return defaultGetValue(bytes, path: path) }
    let cat = [UInt8](bytes[379..<383]).cleanString()
    return categories.firstIndex(of: cat) ?? 0
  }
  
  static func setValue(_ bytes: inout [UInt8], _ value: Int, path: SynthPath) {
    guard path == [.category] else { return defaultSetValue(&bytes, value, path: path) }
    guard value > 0 && value < categories.count else { return }
    let cat = categories[value].bytes(forCount: 4)
    (0..<4).forEach {
      bytes[379 + $0] = cat[$0]
    }
  }
  
  static func sysexData(_ bytes: [UInt8], deviceId: UInt8, bank: UInt8, location: UInt8) -> MidiMessage {
    sysexData(bytes, deviceId: deviceId, dumpByte: 0x10, bank: bank, location: location)
  }
  
  static func randomize(patch: ByteBackedSysexPatch) {
    let filterPres: [SynthPath] = [
      [.fx], [.modif], [.hi, .mod], [.lo, .mod],
      [.arp, .mode], [.mono],
    ] + (0..<3).map { [[.keyTrk]].prefixed([.osc, .i($0)]) }.reduce([], +)
    type(of: patch).params.forEach { path, param in
      guard filterPres.map({ !path.starts(with: $0) }).reduce(true, { $0 && $1 }) else { return }
      patch[path] = param.randomize()
    }
  }
  
  static let paramOptions: [ParamOptions] =
    prefix([.osc], count: 3, bx: 16) { i in
      inc(b: 1) {
        let waveOpts = i == 2 ? Blofeld.Voice.osc3WaveformOptions : waveOptions
        return [
          o([.octave], opts: Blofeld.Voice.oscOctaveOptions),
          o([.coarse], range: 52...76, dispOff: -64),
          o([.fine], dispOff: -64),
          o([.bend], range: 40...88, dispOff: -64),
          o([.keyTrk], isoS: keytrackIso),
          o([.fm, .src], opts: Blofeld.Voice.fmSourceOptions),
          o([.fm, .amt]),
          o([.shape], opts: waveOpts),
          o([.pw]),
          o([.pw, .src], opts: fastModSource),
          o([.pw, .amt], dispOff: -64),
        ] + (i == 2 ? [] : [
          o([.sub, .freq, .divide], max: 31, dispOff: 1),
          o([.sub, .volume]),
        ])
      }
    }
    <<< inc(b: 49) {
      [
        o([.osc, .i(1), .sync], max: 1),
        o([.pitch, .src], opts: fastModSource),
        o([.pitch, .amt], dispOff: -64),
      ]
    }
    <<< [
      o([.glide, .on], 53, max: 1),
      o([.glide, .mode], 56, opts: Blofeld.Voice.glideModeOptions),
      o([.glide, .rate], 57),
      o([.mono], 58, bit: 0),
      o([.unison], 58, bits: 4...6, opts: Blofeld.Voice.unisonModeOptions),
      o([.unison, .detune], 59),
    ]
    <<< prefix([.osc], count: 3, bx: 2) { i in
      inc(b: 61) { [
        o([.level]),
        o([.balance], isoS: Blofeld.Voice.filterBalanceIso),
      ] }
    }
    <<< [
      o([.noise, .level], 67),
      o([.noise, .balance], 68, isoS: Blofeld.Voice.filterBalanceIso),
      o([.ringMod, .level], 71),
      o([.ringMod, .balance], 72, isoS: Blofeld.Voice.filterBalanceIso),
      o([.noise, .select, .i(0)], 75, opts: noiseSelect),
      o([.noise, .select, .i(1)], 76, opts: noiseSelect),
    ]
    <<< prefix([.filter], count: 2, bx: 20) { i in
      [
        o([.type], 77, optArray: filterTypes),
        o([.cutoff], 78),
        o([.reson], 80),
        o([.drive], 81),
        o([.keyTrk], 86, isoS: keytrackIso),
        o([.env, .amt], 87, dispOff: -64),
        o([.velo], 88, dispOff: -64),
        o([.cutoff, .src], 89, opts: fastModSource),
        o([.cutoff, .amt], 90, dispOff: -64),
        o([.fm, .src], 91, opts: Blofeld.Voice.fmSourceOptions),
        o([.fm, .amt], 92),
        o([.pan], 93, dispOff: -64),
        o([.pan, .src], 94, opts: fastModSource),
        o([.pan, .amt], 95, dispOff: -64),
      ]
    }
    <<< [
      o([.filter, .routing], 117, optArray: ["Para", "Serial"]),
      o([.volume], 121),
      o([.amp, .velo], 122, dispOff: -64),
      o([.amp, .mod, .src], 123, opts: fastModSource),
      o([.amp, .mod, .amt], 124, dispOff: -64),
    ]
    <<< fxParams(128)
    <<< prefix([.lfo], count: 3, bx: 12) { i in
      [
        o([.shape], 160, opts: Blofeld.Voice.lfoShapeOptions),
        o([.speed], 161),
        o([.sync], 163, max: 1),
        o([.clock], 164, max: 1),
        o([.phase], 165, isoS: phaseIso),
        o([.delay], 166),
        o([.fade], 167, dispOff: -64),
        o([.keyTrk], 170, isoS: keytrackIso),
      ]
    }
    <<< prefix([.env], count: 4, bx: 12) { i in
      [
        o([.mode], 196, bits: 0...2, opts: Blofeld.Voice.envelopeModeOptions),
        o([.trigger], 196, p: -1, bit: 5, opts: Blofeld.Voice.envelopeTriggerOptions),
        o([.attack], 199),
        o([.attack, .level], 200),
        o([.decay], 201),
        o([.sustain], 202),
        o([.decay2], 203),
        o([.sustain2], 204),
        o([.release], 205),
      ]
    }
    <<< prefix([.modif], count: 4, bx: 4) { i in
      inc(b: 245) {[
        o([.src, .i(0)], opts: stdModSrc),
        o([.src, .i(1)], opts: modifSrc2),
        o([.op], opts: Blofeld.Voice.modOperatorOptions),
        o([.const], dispOff: -64),
      ]}
    }
    <<< prefix([.hi, .mod], count: 8, bx: 3) { i in
      inc(b: 261) {[
        o([.src], opts: fastModSource),
        o([.dest], opts: fastModDest),
        o([.amt], dispOff: -64),
      ]}
    }
    <<< prefix([.lo, .mod], count: 8, bx: 3) { i in
      inc(b: 285) {[
        o([.src], opts: stdModSrc),
        o([.dest], opts: stdModDest),
        o([.amt], dispOff: -64),
      ]}
    }
    <<< arpParams(311)
    <<< [
      o([.category], 379, opts: categoryOptions),
    ]
    // TODO: Category as ASCII?
  
  static let phaseIso = Miso.switcher([
    .int(0, "Free")
  ], default: Miso.lerp(in: 1...127, out: 0...360) >>> Miso.round() >>> Miso.unitFormat("°"))

  static let tempoIso = Miso.switcher([
    .range(0...25, Miso.lerp(in: 0...25, out: 40...90)),
    .range(26...100, Miso.lerp(in: 26...100, out: 91...165)),
    .range(101...127, Miso.lerp(in: 101...127, out: 170...300))
  ]) >>> Miso.round()
  
  static let arpAccentIso = Miso.options(["❌", "↓↓↓", "↓↓", "↓", "-", "↑", "↑↑", "↑↑↑"])
  
  static let arpTimingIso = Miso.options(["Random", "-3", "-2", "-1", "0", "1", "2", "3"])
  
  static let arpLenIso = Miso.options(["Legato", "-3", "-2", "-1", "0", "1", "2", "3"])
  
  static let params: SynthPathParam = paramsFromOpts(paramOptions)

  static let waveOptions: [Int:String] = OptionsParam.makeOptions(["Off", "Pulse", "Saw", "Triangle", "Sine", "Alt 1", "Alt 2"])
  
  static let lfoRateIso = Miso.m(0.5) >>> Miso.floor() >>> Miso.options(["256", "192", "160", "144", "128", "120", "96", "80", "72", "64", "48", "40", "36", "32", "24", "20", "18", "16", "15", "14", "12", "10", "9", "8", "7", "6", "5", "4", "3.5", "3", "2.66", "2.4", "2", "1.75", "1.5", "1.33", "1.2", "1", "7/8", "1/2.", "1/2T", "5/8", "1/2", "7/16", "1/4.", "1/4T", "5/16", "1/4", "7/32", "1/8.", "1/8T", "5/32", "1/8", "7/64", "1/16.", "1/16T", "5/64", "1/16", "1/32.", "1/32T", "1/32", "1/64T", "1/64", "1/96"])
  
  static let fastModSource = OptionsParam.makeOptions(["Off", "LFO 1", "LFO1*MW", "LFO 2", "LFO2*Prs", "LFO 3", "FilterEnv", "AmpEnv", "Env3", "Env4", "Velocity", "Mod Wheel", "Pitchbend", "Pressure"])
  
  static let stdModStrings = ["Off", "LFO 1", "LFO1*MW", "LFO 2", "LFO2*Press", "LFO 3", "FilterEnv", "AmpEnv", "Env3", "Env4", "Keytrack", "Velocity", "Rel. Velo", "Pressure", "Poly Press", "Pitch Bend", "Mod Wheel", "Sustain", "Foot Ctrl", "BreathCtrl", "Control W", "Control X", "Control Y", "Control Z", "Ctrl Delay", "Modif 1", "Modif 2", "Modif 3", "Modif 4", "min", "MAX", "Voice Num", "Voice%16", "Voice%8", "Voice%4", "Voice%2", "Unisono Vc", "U. Detune", "U De-Pan", "U De-Oct"]
  static let stdModSrc = OptionsParam.makeOptions(stdModStrings)
  static let modifSrc2 = OptionsParam.makeOptions(["Const"] + stdModStrings.suffix(from: 1))
  
  static let fastModDestStrings = ["Pitch", "O1 Pitch", "O1 FM", "O1 PW", "O2 Pitch", "O2 FM", "O2 PW", "O3 Pitch", "O3 FM", "O3 PW", "O1 Level", "O1 Balance", "O2 Level", "O2 Balance", "O3 Level", "O3 Balance", "Ring Level", "Ring Bal.", "N/E Level", "N/E Bal.", "F1 Cutoff", "F1 Reson", "F1 FM", "F1 Drive", "F1 Pan", "F2 Cutoff", "F2 Reson", "F2 FM", "F2 Drive", "F2 Pan", "Volume"]
  static let fastModDest = OptionsParam.makeOptions(fastModDestStrings)
  
  static let stdModDest = OptionsParam.makeOptions(fastModDestStrings + ["LFO1Speed", "LFO2Speed", "LFO3Speed", "FE Attack", "FE Decay", "FE Sustain", "FE Release", "AE Attack", "AE Decay", "AE Sustain", "AE Release", "E3 Attack", "E3 Decay", "E3 Sustain", "E3 Release", "E4 Attack", "E4 Decay", "E4 Sustain", "E4 Release", "M1F Amount", "M2F Amount", "M1S Amount", "M2S Amount", "O1 Sub Div", "O1 Sub Vol", "O2 Sub Div", "O2 Sub Vol"])

  
  static let keytrackIso = Blofeld.Voice.keytrackIso
  
  static let noiseSelect = OptionsParam.makeOptions(["Noise", "Ext L", "Ext R", "Ext L+R"])
  
  static let filterTypes = ["Bypass", "LP 24dB", "LP 12dB", "BP 24dB", "BP 12dB", "HP 24dB", "HP 12dB", "Notch24dB", "Notch12dB", "Comb+", "Comb-"]
  
  static let fxTypes = ["Bypass", "Chorus", "Flanger", "Phaser", "Overdrive", "Five FX", "Vocoder"]
  
  static let fx2Types = fxTypes + ["Delay", "Reverb", "5.1 Delay", "5.1 D.Clk"]

  static let categories = ["-custom-", "Arp", "Atmo", "Bass", "Bell", "Drum", "Ext", "FX", "Init", "Keys", "Lead", "Orgn", "Pad", "Perc", "Pluk", "Poly", "RAND", "Seq", "Strg", "Synt", "Voc", "Wave"]
  static let categoryOptions = OptionsParam.makeOptions(categories)
  
  
  static let fxMap = [
    [],
    chorusParams,
    flangerParams,
    phaserParams,
    overdriveParams,
    fiveFXParams,
    vocoderParams,
    delayParams,
    reverbParams,
    delay51Params,
    clockedDelayParams,
    ]
  
  static let polarityOptions = [
    0:"+",
    1:"-"
  ]

  // these are for effect 2. for effect 1, subtract 16 from parm
  static let chorusParams : [ParamOptions] = [
    o([.i(146)], l: "Speed"),
    o([.i(147)], l: "Depth"),
    o([.i(149)], l: "Delay"),
  ]
  
  static let flangerParams : [ParamOptions] = [
    o([.i(146)], l: "Speed"), // 0..127 0..127
    o([.i(147)], l: "Depth"), // 0..127 0..127
    o([.i(150)], l: "Feedback"), // 0..127 0..127
    o([.i(154)], l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
  ]
  
  static let phaserParams : [ParamOptions] = [
    o([.i(146)], l: "Speed"), // 0..127 0..127
    o([.i(147)], l: "Depth"), // 0..127 0..127
    o([.i(151)], l: "Center"), // 0..127 0..127
    o([.i(152)], l: "Spacing"), // 0..127 0..127
    o([.i(150)], l: "Feedback"), // 0..127 0..127
    o([.i(154)], l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
  ]
  
  static let overdriveParams : [ParamOptions] = [
    o([.i(147)], l: "Drive"), // 0..127 0..127
    o([.i(148)], l: "Post Gain"), // 0..127 0..127
    o([.i(151)], l: "Cutoff"), // 0..127 0..127
  ]
  
  static let freqFormatIso = Miso.switcher([
    .range(0...1000, Miso.round(1) >>> Miso.unitFormat("Hz")),
    .range(1000...10000, Miso.m(1/1000) >>> Miso.round(2) >>> Miso.unitFormat("k"))
  ], default: Miso.m(1/1000) >>> Miso.round(1) >>> Miso.unitFormat("k"))

  static let shFreqIso = Miso.quadReg(a: 2.6915979097009197, b: -689.0545153869274, c: 44099.76187350981, neg: true) >>> freqFormatIso
  
  static let fiveFXParams : [ParamOptions] = [
    o([.i(150)], l: "S&H", isoS: shFreqIso),
    o([.i(151)], l: "Overdrive"), // 0..127 0..127
    o([.i(153)], l: "Ring Mod"),
    o([.i(152)], l: "←Src", opts: vocSrc),
    o([.i(149)], l: "Chrs/Dly"), // 0..127 0..127
    o([.i(146)], l: "←Speed"), // 0..127 0..127
    o([.i(147)], l: "←Depth"), // 0..127 0..127
    o([.i(148)], l: "←Delay"), // 0..127 0..127
  ]
  
  static let vocSrc = OptionsParam.makeOptions(["Ext", "Aux", "Inst 1 FX", "Inst 2 FX", "Inst 3 FX", "Inst 4 FX", "Main In", "Sub 1 In", "Sub 2 In"])
  
  static let vocOffIso = Miso.lerp(in: 127, out: -128...128) >>> Miso.round()
  static let vocFreqIso = Miso.exponReg(a: 10.924085542005335, b: 0.05774863315179796, c: -0.06151331566783524) >>> freqFormatIso
  
  static let vocoderParams : [ParamOptions] = [
    o([.i(146)], l: "Bands", max: 23, dispOff: 2),
    o([.i(147)], l: "Ana Sig", opts: vocSrc),
    o([.i(148)], l: "A Lo Frq", isoS: vocFreqIso),
    o([.i(149)], l: "A Hi Frq", isoS: vocFreqIso),
    o([.i(150)], l: "S Offset", isoF: vocOffIso),
    o([.i(151)], l: "Hi Offset", isoF: vocOffIso),
    o([.i(152)], l: "Bwid", dispOff: -64),
    o([.i(153)], l: "Reson", dispOff: -64),
    o([.i(154)], l: "Attack"),
    o([.i(155)], l: "Decay"),
    o([.i(156)], l: "EQ Lo", dispOff: -64),
    o([.i(157)], l: "EQ Mid Band", max: 24, dispOff: 1),
    o([.i(158)], l: "EQ Mid", dispOff: -64),
    o([.i(159)], l: "EQ High", dispOff: -64),
  ]
  
  static let delayTempoIso = Miso.switcher([
    .int(0, "Internal"),
  ], default: tempoIso >>> Miso.str())
  
  static let delayLenIso = Miso.quadReg(a: 0.09205458275935607, b: -2.7201779383867475e-05, c: 1.4159673877757628) >>> Miso.round(1)

  static let delayParams : [ParamOptions] = [
    o([.i(153)], l: "Clocked", max: 1),
    o([.i(149)], l: "Length", isoF: delayLenIso), // non-Clocked len
    o([.i(156)], l: "Clk Len", opts: clockedDelayLengthOptions), // Clocked len
    o([.i(148)], l: "Tempo", isoS: delayTempoIso),
    o([.i(150)], l: "Feedback"), // 0..127 0..127
    o([.i(154)], l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
    o([.i(151)], l: "Cutoff"), // 0..127 0..127
    o([.i(155)], l: "Autopan", optArray: ["Off", "On"]),
  ]
  
  static let clockedDelayLengthOptions = OptionsParam.makeOptions(["1/128", "1/64", "1/32", "1/16", "1/8", "1/4", "2/4", "3/4", "4/4", "8/4"].map { ["\($0)", "\($0)T", "\($0)."] }.reduce([], +))
  static let delayFeedIso = Miso.piecewise(breaks: [
    (0, 0),
    (32, 25),
    (64, 50),
    (96, 75),
    (126, 98.4),
    (127, 100),
  ]) >>> Miso.round(1) >>> Miso.unitFormat("%")

  static let delayPercIso = Miso.piecewise(breaks: [
    (0, 0),
    (12, 6),
    (13, 6.2),
    (14, 6.5),
    (17, 8),
    (18, 8.3),
    (19, 8.5),
    (35, 16.5),
    (36, 16.6),
    (37, 17),
    (43, 20),
    (56, 33),
    (57, 33.3),
    (58, 34),
    (74, 50),
    (82, 66),
    (83, 66.6),
    (84, 68),
    (87, 74),
    (88, 75),
    (89, 76),
    (96, 90),
    (116, 110),
    (120, 150),
    (124, 250),
    (127, 400),
  ]) >>> Miso.unitFormat("%")

  
  static let clockedDelayParams : [ParamOptions] = [
    o([.i(146)], l: "Length", opts: clockedDelayLengthOptions),
    o([.i(147)], l: "Feedback", isoS: delayFeedIso),
    o([.i(148)], l: "LFE LP", isoS: vocFreqIso), // 0..127 0..127
    o([.i(149)], l: "Input HP", isoS: vocFreqIso), // 0..127 0..127
    o([.i(151)], l: "FSL V"), // 0..127 0..127
    o([.i(150)], l: "Delay ML", isoS: delayPercIso), // 0..127 0..127
    o([.i(153)], l: "FSR V"), // 0..127 0..127
    o([.i(152)], l: "Delay MR", isoS: delayPercIso), // 0..127 0..127
    o([.i(155)], l: "CntrS V"), // 0..127 -64..+63
    o([.i(154)], l: "Delay S2L", isoS: delayPercIso), // 0..1 positive,negative
    o([.i(157)], l: "RearSL V"), // 0..127 0..127
    o([.i(156)], l: "Delay S1L", isoS: delayPercIso), // 0..127 0..127
    o([.i(159)], l: "RearSR V"), // 0..127 0..127
    o([.i(158)], l: "Delay S1R", isoS: delayPercIso), // 0..127 0..127
  ]
  
  static let preDelayIso = Miso.lerp(in: 127, out: 0...300) >>> Miso.round(1)
  static let sizeIso = Miso.lerp(in: 127, out: 3...20) >>> Miso.round(1) >>> Miso.unitFormat("m")
  static let reverbParams : [ParamOptions] = [
    o([.i(152)], l: "Highpass"),
    o([.i(151)], l: "Lowpass"),
    o([.i(149)], l: "Pre-Delay", isoF: preDelayIso),
    o([.i(153)], l: "Diffusion"),
    o([.i(146)], l: "Size", isoS: sizeIso),
    o([.i(147)], l: "Shape"),
    o([.i(148)], l: "Decay"),
    o([.i(154)], l: "Damping"),
  ]
  
  static let delay51Params : [ParamOptions] = [
    o([.i(146)], l: "Delay", isoF: delayLenIso),
  ] + clockedDelayParams.suffix(from: 1)
}
