
extension Blofeld {

  enum Voice {
    typealias P = PatchTrussWerk

    static let patchTruss = createPatchTruss("Voice", 383, initFile: "blofeld-init", namePack: .basic(363..<379), params: paramOptions, parseOffset: 7, dumpByte: dumpByte)

    static let dumpByte: UInt8 = 0x10

    static func paramData(_ deviceId: Int, bodyData: [UInt8], location: UInt8, paramIndex parm: Int) -> MidiMessage {
      Blofeld.paramData(deviceId, bodyData: bodyData, bufferBytes: [0x20, location], forParamIndex: parm)
    }

    static func patchChange(_ throttle: Int, location: UInt8) -> MidiTransform {
      .single(throttle: throttle, deviceId, .patch(param: { v, bodyData, path, value in
        guard let param = patchTruss.params[path] else { return nil }
        let msg = paramData(v, bodyData: bodyData, location: location, paramIndex: param.byte)
        return [(msg, 10)]
      }, patch: wholePatch(dumpByte: dumpByte, bank: 0x7f, location: location), name: { v, bodyData, path, name in
        return patchTruss.namePackIso?.byteRange.map {
          let msg = paramData(v, bodyData: bodyData, location: location, paramIndex: $0)
          return (msg, 10)
        }
    }))
    }
    
    static let bankTruss: SingleBankTruss = createBankTruss(dumpByte: dumpByte, patchTruss: Voice.patchTruss, initFile: "blofeld-bank-init")

  //  static let tempBankIndex = 0x7f
    
    static func bankLetter(_ index: Int) -> String {
      guard index < 8 else { return "?" }
      return ["A","B","C","D","E","F","G","H"][index]
    }
    
    
    static let paramOptions: [ParamOptions] =
      P.prefix([.osc], count: 3, bx: 16) { i in
        P.inc(b: 1) {
          [
            P.o([.octave], opts: oscOctaveOptions),
            P.o([.coarse], range: 52...76, dispOff: -64),
            P.o([.fine], dispOff: -64),
            P.o([.bend], range: 40...88, dispOff: -64),
            P.o([.keyTrk], isoS: keytrackIso),
            P.o([.fm, .src], opts: fmSourceOptions),
            P.o([.fm, .amt]),
            P.o([.shape], opts: i == 2 ? osc3WaveformOptions : waveformOptions),
            P.o([.pw]),
            P.o([.pw, .src], optArray: modSourceOptions),
            P.o([.pw, .amt], dispOff: -64),
          ]
        }
      }
    <<< P.prefix([.osc], count: 2, bx: 16) { i in
      P.inc(b: 14) {
          [
            P.o([.limitWT], optArray: ["On", "Off"]),
            P.o([.sample], optArray: ["WT","Sample"]),
            P.o([.brilliance]),
          ]
        }
      }
    <<< P.inc(b: 48) {
        [
          P.o([.osc, .i(2), .brilliance]),
          P.o([.osc, .i(2), .sync], max: 1),
          P.o([.pitch, .src], optArray: modSourceOptions),
          P.o([.pitch, .amt], dispOff: -64),
        ]
      }
      <<< [
        P.o([.glide, .on], 53, max: 1),
        P.o([.glide, .mode], 56, opts: glideModeOptions),
        P.o([.glide, .rate], 57),
        P.o([.mono], 58, bit: 0),
        P.o([.unison], 58, bits: 4...6, opts: unisonModeOptions),
        P.o([.unison, .detune], 59),
      ]
    <<< P.prefix([.osc], count: 3, bx: 2) { i in
      P.inc(b: 61) { [
        P.o([.level]),
        P.o([.balance], isoS: filterBalanceIso),
        ] }
      }
      <<< [
        P.o([.noise, .level], 67),
        P.o([.noise, .balance], 68, isoS: filterBalanceIso),
        P.o([.noise, .color], 69, dispOff: -64),
        P.o([.ringMod, .level], 71),
        P.o([.ringMod, .balance], 72, isoS: filterBalanceIso),
      ]
    <<< P.prefix([.filter], count: 2, bx: 20) { i in
        [
          P.o([.type], 77, opts: filterTypeOptions),
          P.o([.cutoff], 78),
          P.o([.reson], 80),
          P.o([.drive], 81),
          P.o([.drive, .curve], 82, opts: driveCurveOptions),
          P.o([.keyTrk], 86, isoS: keytrackIso),
          P.o([.env, .amt], 87, dispOff: -64),
          P.o([.velo], 88, dispOff: -64),
          P.o([.cutoff, .src], 89, optArray: modSourceOptions),
          P.o([.cutoff, .amt], 90, dispOff: -64),
          P.o([.fm, .src], 91, opts: fmSourceOptions),
          P.o([.fm, .amt], 92),
          P.o([.pan], 93, dispOff: -64),
          P.o([.pan, .src], 94, optArray: modSourceOptions),
          P.o([.pan, .amt], 95, dispOff: -64),
        ]
      }
      <<< [
        P.o([.filter, .routing], 117, optArray: ["Para", "Serial"]),
        P.o([.volume], 121),
        P.o([.amp, .velo], 122, dispOff: -64),
        P.o([.amp, .mod, .src], 123, optArray: modSourceOptions),
        P.o([.amp, .mod, .amt], 124, dispOff: -64),
      ]
    <<< P.prefix([.fx], count: 2, bx: 16) { i in
      P.inc(b: 128) { [
        P.o([.type], opts: i == 0 ? effectTypeOptions : effect2TypeOptions),
        P.o([.mix]),
        ] }
      <<< P.prefix([.param], count: 14, bx: 1) { fx in
        [P.o([], 130)]
        }
      }
    <<< P.prefix([.lfo], count: 3, bx: 12) { i in
        [
          P.o([.shape], 160, opts: lfoShapeOptions),
          P.o([.speed], 161),
          P.o([.sync], 163, max: 1),
          P.o([.clock], 164, max: 1),
          P.o([.phase], 165, isoS: MicroQVoicePatch.phaseIso),
          P.o([.delay], 166),
          P.o([.fade], 167, dispOff: -64),
          P.o([.keyTrk], 170, isoS: keytrackIso),
        ]
      }
    <<< P.prefix([.env], count: 4, bx: 12) { i in
        [
          P.o([.mode], 196, bits: 0...2, opts: envelopeModeOptions),
          P.o([.trigger], 196, p: -1, bit: 5, opts: envelopeTriggerOptions),
          P.o([.attack], 199),
          P.o([.attack, .level], 200),
          P.o([.decay], 201),
          P.o([.sustain], 202),
          P.o([.decay2], 203),
          P.o([.sustain2], 204),
          P.o([.release], 205),
        ]
      }
    <<< P.prefix([.modif], count: 4, bx: 4) { i in
        P.inc(b: 245) {[
          P.o([.src, .i(0)], optArray: modSourceOptions),
          P.o([.src, .i(1)], optArray: ["Const"] + modSourceOptions.suffix(from: 1)),
          P.o([.op], opts: modOperatorOptions),
          P.o([.const], dispOff: -64),
        ]}
      }
    <<< P.prefix([.mod], count: 16, bx: 3) { i in
        P.inc(b: 261) {[
          P.o([.src], optArray: modSourceOptions),
          P.o([.dest], opts: modDestinationOptions),
          P.o([.amt], dispOff: -64),
        ]}
      }
    <<< P.prefix([.arp]) {
        [
          P.o([.mode], 311, opts: arpModes),
          P.o([.pattern], 312, max: 16, isoS: Miso.switcher([
            .int(0, "Off"),
            .int(1, "User"),
          ], default: Miso.a(-1) >>> Miso.str())),
          P.o([.clock], 314, opts: arpClockOptions),
          P.o([.length], 315, opts: arpLengthOptions),
          P.o([.octave], 316, max: 9, dispOff: 1),
          P.o([.direction], 317, opts: arpDirections),
          P.o([.sortOrder], 318, opts: arpSortOptions),
          P.o([.velo], 319, opts: arpVeloModeOptions),
          P.o([.timingFactor], 320),
          P.o([.pattern, .reset], 322, max: 1),
          P.o([.pattern, .length], 323, max: 15, dispOff: 1),
          P.o([.tempo], 326, isoF: MicroQVoicePatch.tempoIso),
        ]
      <<< P.prefix([], count: 16, bx: 1) { i in
          [
            P.o([.step], 327, bits: 4...6, dispOff: -4, opts: arpStepOptions),
            P.o([.glide], 327, bit: 3),
            P.o([.accent], 327, bits: 0...2, max: 7, dispOff: -4, isoS: MicroQVoicePatch.arpAccentIso),
            P.o([.length], 343, bits: 4...6, max: 7, dispOff: -4, isoS: MicroQVoicePatch.arpLenIso),
            P.o([.timing], 343, bits: 0...2, max: 7, dispOff: -4, isoS: MicroQVoicePatch.arpTimingIso),
          ]
        }
      }
      <<< [
        P.o([.category], 379, opts: categoryOptions),
      ]
    
    static let waveformOptions: [Int:String] = {
      let opts = ["off", "Pulse", "Saw", "Triangle", "Sine", "Alt 1", "Alt 2", "Resonant", "Resonant2", "MalletSyn", "Sqr-Sweep", "Bellish", "Pul-Sweep", "Saw-Sweep", "MellowSaw", "Feedback", "Add Harm", "Reso 3 HP", "Wind Syn", "High Harm", "Clipper", "Organ Syn", "SquareSaw", "Formant 1", "Polated", "Transient", "ElectricP", "Robotic", "StrongHrm", "PercOrgan", "ClipSweep", "ResoHarms", "2 Echoes", "Formant 2", "FmntVocal", "MicroSync", "Micro PWM", "Glassy", "Square HP", "SawSync 1", "SawSync 2", "SawSync 3", "PulSync 1", "PulSync 2", "PulSync 3", "SinSync 1", "SinSync 2", "SinSync 3", "PWM Pulse", "PWM Saw", "Fuzz Wave", "Distorted", "HeavyFuzz", "Fuzz Sync", "K+Strong1", "K+Strong2", "K+Strong3", "1-2-3-4-5", "19/twenty", "Wavetrip1", "Wavetrip2", "Wavetrip3", "Wavetrip4", "MaleVoice", "Low Piano", "ResoSweep", "Xmas Bell", "FM Piano", "Fat Organ", "Vibes", "Chorus 2", "True PWM", "UpperWaves"]
      + (67...79).map { "Rsrvd \($0)" }
      + (80...118).map { "User WT \($0)" }
      return OptionsParam.makeOptions(opts)
    }()
    
    static let sampleOptions: [Int:String] = OptionsParam.makeOptions(128.map { "Sample \($0 + 1)" })
    
    static let oscOctaveOptions: [Int:String] = [
      16:"128'",
      28:"64'",
      40:"32'",
      52:"16'",
      64:"8'",
      76:"4'",
      88:"2'",
      100:"1'",
      112:"1/2'"
      ]
    
    static let osc3WaveformOptions = OptionsParam.makeOptions(["off","Pulse","Saw","Triangle","Sine"])
    
    static let keytrackIso = Miso.m(396/127) >>> Miso.round() >>> Miso.a(-200) >>> Miso.switcher([
      .int(99, Float(100))
    ], default: Miso.a(0)) >>> Miso.unitFormat("%")
    
    static let fmSourceOptions = OptionsParam.makeOptions(["off", "Osc 1", "Osc 2", "Osc 3", "Noise", "LFO 1", "LFO 2", "LFO 3", "FilterEnv", "AmpEnv", "Env3", "Env4"])
    
    static let glideModeOptions = OptionsParam.makeOptions(["Portamento","fingered P","Glissando","fingered G"])
    
    static let filterBalanceIso = Miso.switcher([
      .range(0...63, Miso.m(-1) >>> Miso.a(64) >>> Miso.unitFormat(" F1")),
      .int(64, "Bal"),
      .range(65...127, Miso.a(-64) >>> Miso.unitFormat(" F2")),
    ])
    
    static let filterTypeOptions = OptionsParam.makeOptions([
      "Bypass",
      "LP 24dB",
      "LP 12dB",
      "BP 24dB",
      "BP 12dB",
      "HP 24dB",
      "HP 12dB",
      "Notch24dB",
      "Notch12dB",
      "Comb+",
      "Comb-",
      "PPG LP"
    ])
    
    static let filterRoutingOptions = OptionsParam.makeOptions([
      "Parallel",
      "Serial"
    ])
    
    static let lfoShapeOptions = OptionsParam.makeOptions([
      "Sine",
      "Triangle",
      "Square",
      "Saw",
      "Random",
      "S&H"
    ])
    
    static let lfoRateIso = Miso.m(0.5) >>> Miso.floor() >>> Miso.switcher([
      .range(0...46, Miso.lookupFunction([1280, 1152, 1024, 896, 768, 640, 576, 512, 448, 384, 320, 288, 256, 224, 192, 160, 144, 128, 112, 96, 80, 72, 64, 56, 48, 40, 36, 32, 28, 24, 20, 18, 16, 14, 12, 10, 9, 8, 7, 6, 5, 4, 3.5, 3, 2.5, 2, 1.5]) >>> Miso.unitFormat("bars")),
      .range(47...47, Miso.a(-46) >>> Miso.unitFormat("bar")),
      .range(48...63, Miso.options(["1/2.", "1/1T", "1/2 ", "1/4.", "1/2T", "1/4 ", "1/8.", "1/4T", "1/8 ", "1/16.", "1/8T", "1/16 ", "1/32.", "1/16T", "1/32 ", "1/48"], startIndex: 48)),
    ])
      
    static let modSourceOptions = ["Off", "LFO 1", "LFO1*MW", "LFO 2", "LFO2*Press", "LFO 3", "FilterEnv", "AmpEnv", "Env3", "Env4", "Keytrack", "Velocity", "Rel. Velo", "Pressure", "Poly Press", "Pitch Bend", "Mod Wheel", "Sustain", "Foot Ctrl", "BreathCtrl", "Control W", "Control X", "Control Y", "Control Z", "Unisono V.", "Modifier 1", "Modifier 2", "Modifier 3", "Modifier 4", "minimum", "MAXIMUM"]
    
    static let modDestinationOptions = OptionsParam.makeOptions(["Pitch", "O1 Pitch", "O1 FM", "O1 PW/Wave", "O2 Pitch", "O2 FM", "O2 PW/Wave", "O3 Pitch", "O3 FM", "O3 PW", "O1 Level", "O1 Balance", "O2 Level", "O2 Balance", "O3 Level", "O3 Balance", "RMod Level", "RMod Bal.", "NoiseLevel", "Noise Bal.", "F1 Cutoff", "F1 Reson.", "F1 FM", "F1 Drive", "F1 Pan", "F2 Cutoff", "F2 Reson.", "F2 FM", "F2 Drive", "F2 Pan", "Volume", "LFO1Speed", "LFO2Speed", "LFO3Speed", "FE Attack", "FE Decay", "FE Sustain", "FE Release", "AE Attack", "AE Decay", "AE Sustain", "AE Release", "E3 Attack", "E3 Decay", "E3 Sustain", "E3 Release", "E4 Attack", "E4 Decay", "E4 Sustain", "E4 Release", "M1 Amount", "M2 Amount", "M3 Amount", "M4 Amount", "O1 WT/Smp", "O2 WT/Smp",])
    
    static let modOperatorOptions = OptionsParam.makeOptions([
      "+",
      "-",
      "*",
      "AND",
      "OR",
      "XOR",
      "MAX",
      "min"
    ])
    
    static let unisonModeOptions = OptionsParam.makeOptions([
      "off",
      "dual",
      "3",
      "4",
      "5",
      "6"
    ])

    static let allocationOptions = OptionsParam.makeOptions(["Poly","Mono"])
    
    static let driveCurveOptions = OptionsParam.makeOptions(["Clipping", "Tube", "Hard", "Medium", "Soft", "Pickup 1", "Pickup 2", "Rectifier", "Square", "Binary", "Overflow", "Sine Shaper", "Osc 1 Mod"])
    
    static let envelopeTriggerOptions = OptionsParam.makeOptions(["normal","single"])
    
    enum EnvelopeMode: Int {
      case ADSR = 0
      case ADS1DS2R = 1
      case OneShot = 2
      case LoopS1S2 = 3
      case LoopAll = 4
    }

    static let envelopeModeOptions = [
      EnvelopeMode.ADSR.rawValue : "ADSR",
      EnvelopeMode.ADS1DS2R.rawValue : "ADS1DS2R",
      EnvelopeMode.OneShot.rawValue : "One Shot",
      EnvelopeMode.LoopS1S2.rawValue : "Loop S1S2",
      EnvelopeMode.LoopAll.rawValue : "Loop All"
    ]
    
    static let arpModes = OptionsParam.makeOptions(["Off", "On", "One Shot", "Hold"])
    
    static let arpDirections = OptionsParam.makeOptions(["Up", "Down", "Alt Up", "Alt Down"])
    
    static let arpClockOptions = OptionsParam.makeOptions(["1/96", "1/48", "1/32 ", "1/16T", "1/32.", "1/16 ", "1/8T", "1/16.", "1/8 ", "1/4T", "1/8.", "1/4 ", "1/2T", "1/4.", "1/2 ", "1/1T", "1/2.", "1 bar", "1.5 bars", "2 bars", "2.5 bars", "3 bars", "3.5 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars", "9 bars", "10 bars", "12 bars", "14 bars", "16 bars", "18 bars", "20 bars", "24 bars", "28 bars", "32 bars", "36 bars", "40 bars", "48 bars", "56 bars", "64 bars"])
    
    static let arpSortOptions = OptionsParam.makeOptions(["as played", "reversed", "Key Lo>Hi", "Key Hi>Lo", "Vel Lo>Hi", "Vel Hi>Lo"])
    
    static let arpVeloModeOptions = OptionsParam.makeOptions(["Each Note", "First Note", "Last Note", "fix 32", "fix 64", "fix 100", "fix 127"])
    
    static let arpStepOptions = OptionsParam.makeOptions(["Normal", "Pause", "Previous", "First", "Last", "First+Last", "Chord", "Random"])
    
    static let arpStepLengthOptions = OptionsParam.makeOptions(["Legato", "-3", "-2", "-1", "0", "1", "2", "3"])
    
    static let arpStepTimingOptions = OptionsParam.makeOptions(["Random", "-3", "-2", "-1", "0", "1", "2", "3"])
    
    static let arpAccentOptions = OptionsParam.makeOptions(["Silent", "/4", "/3", "/2", "*1", "*2", "*3", "*4"])
    
    static let arpPatternOptions = OptionsParam.makeOptions(["Off", "User", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"])
    
    static let arpLengthOptions = OptionsParam.makeOptions(["1/96", "1/48", "1/32", "1/16T", "1/32.", "1/16", "1/8T", "1/16.", "1/8", "1/4T", "1/8.", "1/4", "1/2T", "1/4.", "1/2", "1/1T", "1/2.", "1 bar", "1.5 bars", "2 bars", "2.5 bars", "3 bars", "3.5 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars", "9 bars", "10 bars", "12 bars", "14 bars", "16 bars", "18 bars", "20 bars", "24 bars", "28 bars", "32 bars", "36 bars", "40 bars", "48 bars", "56 bars", "64 bars", "legato"])
    
    static let arpTempoOptions: [Int:String] = {
      var options = [String]()
      // 40...90 by 2
      stride(from: 40, to: 90, by: 2).forEach { options.append("\($0)") }
      //91...165 by 1
      stride(from: 90, to: 165, by: 1).forEach { options.append("\($0)") }
      // 170...300 by 5
      stride(from: 165, to: 301, by: 5).forEach { options.append("\($0)") }
      return OptionsParam.makeOptions(options)
    }()
    
    static let categoryOptions = OptionsParam.makeOptions(["Init", "Arp ", "Atmo", "Bass", "Drum", "FX  ", "Keys", "Lead", "Mono", "Pad ", "Perc", "Poly", "Seq"])
    
    static let effectTypeOptions = OptionsParam.makeOptions(["Bypass", "Chorus", "Flanger", "Phaser", "Overdrive", "Triple FX"])
    
    static let effect2TypeOptions = OptionsParam.makeOptions(["Bypass", "Chorus", "Flanger", "Phaser", "Overdrive", "Triple FX", "Delay", "Clk.Delay", "Reverb"])
    
    static let polarityOptions = [
      0:"+",
      1:"-"
    ]
    
    static let fxMap = [
      [],
      chorusParams,
      flangerParams,
      phaserParams,
      overdriveParams,
      tripleFXParams,
      delayParams,
      clockedDelayParams,
      reverbParams
      ]
    
      
    static let overdriveCurveOptions = OptionsParam.makeOptions(["Clipping","Tube","Hard","Medium","Soft","Pickup 1","Pickup 2","Rectifier","Square","Binary","Overflow","Sine Shaper"])
        
    static let clockedDelayLengthOptions = OptionsParam.makeOptions(["1/96", "1/48", "1/32 ", "1/16T", "1/32.", "1/16 ", "1/8T", "1/16.", "1/8 ", "1/4T", "1/8.", "1/4 ", "1/2T", "1/4.", "1/2 ", "1/1T", "1/2.", "1 bar", "1.5 bars", "2 bars", "2.5 bars", "3 bars", "3.5 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars", "9 bars", "10 bars"])

    
    // these are for effect 2. for effect 1, subtract 16 from parm
    static let chorusParams : [ParamOptions] = [
      P.o([.i(146)], l: "Speed"),
      P.o([.i(147)], l: "Depth"),
    ]
    
    static let flangerParams : [ParamOptions] = [
      P.o([.i(146)], l: "Speed"), // 0..127 0..127
      P.o([.i(147)], l: "Depth"), // 0..127 0..127
      P.o([.i(150)], l: "Feedback"), // 0..127 0..127
      P.o([.i(154)], l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
    ]
    
    static let phaserParams : [ParamOptions] = [
      P.o([.i(146)], l: "Speed"), // 0..127 0..127
      P.o([.i(147)], l: "Depth"), // 0..127 0..127
      P.o([.i(151)], l: "Center"), // 0..127 0..127
      P.o([.i(152)], l: "Spacing"), // 0..127 0..127
      P.o([.i(150)], l: "Feedback"), // 0..127 0..127
      P.o([.i(154)], l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
    ]
    
    static let overdriveParams : [ParamOptions] = [
      P.o([.i(147)], l: "Drive"), // 0..127 0..127
      P.o([.i(148)], l: "Post Gain"), // 0..127 0..127
      P.o([.i(151)], l: "Cutoff"), // 0..127 0..127
      P.o([.i(155)], l: "Curve", opts: overdriveCurveOptions), // 0..11 Clipping..Sine Shaper
    ]
    
    static let freqFormatIso = Miso.switcher([
      .range(0...1000, Miso.round(1) >>> Miso.unitFormat("Hz")),
      .range(1000...10000, Miso.m(1/1000) >>> Miso.round(2) >>> Miso.unitFormat("k"))
    ], default: Miso.m(1/1000) >>> Miso.round(1) >>> Miso.unitFormat("k"))

    static let tripleFXParams : [ParamOptions] = [
      P.o([.i(150)], l: "S&H"),
      P.o([.i(151)], l: "Overdrive"), // 0..127 0..127
      P.o([.i(149)], l: "Chorus Mix"), // 0..127 0..127
      P.o([.i(146)], l: "←Speed"), // 0..127 0..127
      P.o([.i(147)], l: "←Depth"), // 0..127 0..127
    ]
        
    static let delayParams : [ParamOptions] = [
      P.o([.i(149)], l: "Length"), // non-Clocked len
      P.o([.i(150)], l: "Feedback"), // 0..127 0..127
      P.o([.i(154)], l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
      P.o([.i(151)], l: "Cutoff"), // 0..127 0..127
      P.o([.i(155)], l: "Spread", dispOff: -64),
    ]
    
    static let clockedDelayParams : [ParamOptions] = [
      P.o([.i(150)], l: "Feedback"), // 0..127 0..127
      P.o([.i(151)], l: "Cutoff"), // 0..127 0..127
      P.o([.i(154)], l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
      P.o([.i(155)], l: "Spread", dispOff: -64), // 0..127 -64..+63
      P.o([.i(156)], l: "Length", opts: clockedDelayLengthOptions) // 0..29 1/96..10 bars
    ]
    
    static let reverbParams : [ParamOptions] = [
      P.o([.i(152)], l: "Highpass"),
      P.o([.i(151)], l: "Lowpass"),
      P.o([.i(153)], l: "Diffusion"),
      P.o([.i(146)], l: "Size"),
      P.o([.i(147)], l: "Shape"),
      P.o([.i(148)], l: "Decay"),
      P.o([.i(154)], l: "Damping"),
    ]
    
  }

}
