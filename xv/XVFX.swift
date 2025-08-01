
extension XV {
  
  struct FX {
    
    static func patchWerk(params: SynthPathParam) -> RolandSinglePatchTrussWerk {
      try! XV.sysexWerk.singlePatchWerk("FX", params, size: 0x111, start: 0x0200, randomize: {
        let t = (0...63).rand()
        let fx = allFx[t]
        return [
          [.out] : 0,
          [.dry] : (64...127).rand(),
          [.chorus] : (64...127).rand(),
          [.reverb] : (64...127).rand(),
          [.type] : t,
        ] <<< 4.dict {
          [[.ctrl, .i($0), .amt] : 64]
        } <<< 32.dict {
          guard let param = fx.params[$0]?.1 as? ParamWithRange else {
            return [[.param, .i($0)] : 32768]
          }
          return [[.param, .i($0)] : param.range.rand()]
        }
      })
    }
    
    static func fxDisplayName(_ index: Int) -> String {
      "\(index): \(allFx[index].name)"
    }

    
    let name: String
    let params: [Int:(String,Param)]
    let dests: [Int] // map destination index to param name
    let destOptions: [Int:String]
    
    init(name: String, params: [Int:(String,Param)], dests: [Int]) {
      self.name = name
      self.params = params
      self.dests = dests
      var opts = [Int:String]()
      opts[0] = "Off"
      dests.enumerated().forEach { opts[$0.offset + 1] = params[$0.element]?.0 ?? "?" }
      self.destOptions = opts
    }
    
    static let noteOptions: [String] = [
      "64th trp",
      "64th",
      "32nd trp",
      "32nd",
      "16th trp",
      "Dot 32nd",
      "16th",
      "8th trp",
      "Dot 16th",
      "8th",
      "1/4 trp",
      "Dot 8th",
      "1/4",
      "1/2 trp",
      "Dot 1/4",
      "1/2",
      "Whole trp",
      "Dot 1/2",
      "Whole",
      "Double trp",
      "Dot whole",
      "Double",
      ]
    
    
    static let gainParam = xvrange(-15...15)
    static let fx200to8kOptions = ["200", "250", "315", "400", "500", "630", "800", "1000", "1250", "1600", "2000", "2500", "3150", "4000", "5000", "6300", "8000"]
    static let fx200to8kParam = xvoptions(fx200to8kOptions)
    static let fx200to8kBypassParam = xvoptions(fx200to8kOptions + ["Bypass"])
    static let eqQParam = xvoptions(["0.5", "1.0", "2.0", "4.0", "9.0" ])
    static let panParam = xvrange(-64...63)
    static let rateParam = xvmiso(0...125, Miso.piecewise(breaks: [
      (0, 0.05),
      (99, 5.0),
      (119, 7.0),
      (125, 10)
    ]) >>> Miso.round(2))

    static let filterTypeParam = xvoptions(["Off","LPF","HPF"])
    static let coarseParam = xvrange(-24...12)
    static let fineParam = xvoptions(101.map {"\($0*2 - 100)"})
    static let fdbkParam = xvoptions(99.map {"\($0*2 - 98)"})
    static let balanceParam = xvoptions(101.map {"D\(100-$0):\($0)W"})
    static let phaseParam = xvoptions(91.map {"\($0 * 2)"})
    static let delayTime500Param = xvmiso(0...126, Miso.piecewise(breaks: [
      (0, 0),
      (50, 5),
      (60, 10),
      (90, 40),
      (116, 300),
      (126, 500),
    ]) >>> Miso.round(2))
    static let delayTime100Param = xvmiso(0...125, Miso.piecewise(breaks: [
      (0, 0),
      (50, 5),
      (60, 10),
      (100, 50),
      (125, 100),
    ]) >>> Miso.round(2))

    static let fxPhaserManualOptions = xvoptions({
      var options = (0..<20).map { "\(100 + ($0 * 10))" }
      options += (20..<55).map { "\(300 + ($0-20) * 20)" }
      options += (55...125).map { "\(1000 + ($0-55) * 100)" }
      return options
    }())

    static let offOnParam = xvoptions(["Off","On"])
    static let vowelParam = xvoptions(["a","e","i","o","u"])
    static let postGainParam = xvoptions(["0","+6","+12","+18"])
    static let limitRatioParam = xvoptions(["1.5:1","2:1","4:1","100:1"])
    static let threeDOutParam = xvoptions(["Speaker","Phones"])
    static let modWaveParam = xvoptions(["Tri","Squ","Sin","Saw 1","Saw 2"])
    static let accelParam =  xvrange(0...15)
    static let midQParam = xvoptions(["0.5","1.0","2.0","4.0","8.0"])
    static let speakerSimParam = xvoptions(["Small 1","Small 2","Middle","JC-120","Built In 1", "Built In 2", "Built In 3", "Built In 4", "Built In 5","BG Stack 1", "BG Stack 2", "MS Stack 1", "MS Stack 2", "Metal Stack", "2-Stack", "3-Stack"])
    static let ampSimpleParam = xvoptions(["Small", "Built-in", "2 Stack", "3 Stack"])
    static let ampSimParam = xvoptions(["JC-120", "Clean Twin", "Match Drive", "BG Lead", "MS1959I", "MS1959II", "MS1959I+II", "SLDN Lead", "Metal 5150", "Metal Lead", "OD-1", "OD-2 Turbo", "Distortion", "Fuzz"])
    static let odDistParam = xvoptions(["OD", "Dist"])
    static let choFlgParam = xvoptions(["Chorus", "Flanger"])
    static let isolatorGainParam = xvrange(-60...4)
    static let defaultRangeParam = xvrange()
    
    static let stepRateOptions = xvmiso(0...125, Miso.switcher([
      .range(0...115, Miso.piecewise(breaks: [
        (0, 0.1),
        (79, 8),
        (109, 14),
        (115, 20),
      ]) >>> Miso.round(2) >>> Miso.str()),
      .range(116...125, Miso.a(-110) >>> Miso.options(noteOptions))
    ]))
    static let phaserRateOptions = xvmiso(1...(200 + noteOptions.count), Miso.switcher([
      .range(1...200, Miso.m(0.05) >>> Miso.round(2) >>> Miso.str()),
      .range(201...Float((200 + noteOptions.count)), Miso.options(noteOptions, startIndex: 201))
    ]))
    static let phaserStepRateOptions = xvmiso(1...(200 + noteOptions.count), Miso.switcher([
      .range(1...200, Miso.m(0.1) >>> Miso.round(2) >>> Miso.str()),
      .range(201...Float((200 + noteOptions.count)), Miso.options(noteOptions, startIndex: 201))
    ]))
    static let delayTime1000Param = xvoptions({
      var options = (0..<70).map { "\(200 + $0 * 5)" }
      options += (0...45).map { "\(550 + $0 * 10)" }
      options += noteOptions[6..<16]
      return options
      }())
    static let delayTime1000NoNoteParam = xvoptions({
      var options = (0..<70).map { "\(200 + $0 * 5)" }
      options += (0...45).map { "\(550 + $0 * 10)" }
      return options
      }())
    static let gateTimeParam = xvoptions({
      var options = (1...100).map { "\($0 * 5)" }
      return options
      }())
    static let delayTime1800Param = xvoptions({
      var options = (0...1800).map { "\($0)" }
      options += noteOptions
      return options
      }())
    static let delayTime900Param = xvoptions({
      var options = (0...900).map { "\($0)" }
      options += noteOptions
      return options
      }())
    static let delayTime3000Param = xvoptions({
      var options = (0...3000).map { "\($0)" }
      options += noteOptions
      return options
      }())
    static let delayTime1500Param = xvoptions({
      var options = (0...1500).map { "\($0)" }
      options += noteOptions
      return options
      }())
    static let azimuthParam = xvoptions({
      var options = (0...14).map { "L\(12 * (15-$0))" }
      options += ["0"]
      options += (1...15).map { "R\(12 * $0)" }
      return options
      }())

    static let fxTypeOptions: [Int:String] = {
      var map = [Int:String]()
      allFx.enumerated().forEach { map[$0.offset] = "\($0.offset): \($0.element.name)" }
      return map
    }()
    
    static let allFx: [Self] = [
      off,
      eq,
      overdrive,
      distortion,
      phaser,
      spectrum,
      enhancer,
      autowah,
      rotary,
      compressor,
      limiter,
      hexaChorus,
      tremChorus,
      spaceD,
      chorus,
      flanger,
      stepFlanger,
      stDelay,
      modDelay,
      tripleDelay,
      quadDelay,
      timeCtrlDelay,
      duoPitchShift,
      feedbackPitchShift,
      reverb,
      gateVerb,
      odChorus,
      odFlanger,
      odDelay,
      distChorus,
      distFlanger,
      distDelay,
      enhanceChorus,
      enhanceFlanger,
      enhanceDelay,
      chorusDelay,
      flangerDelay,
      chorusFlanger,
      chorusAndDelay,
      flangerAndDelay,
      chorusAndFlanger,
      stPhaser,
      keySyncFlanger,
      formantFilter,
      ringMod,
      multiTapDelay,
      reverseDelay,
      shuffleDelay,
      threeDDelay,
      threeVoicePitchShift,
      lofiComp,
      lofiNoise,
      speakerSim,
      overdrive2,
      distortion2,
      stComp,
      stLimit,
      gate,
      slicer,
      isolator,
      threeDChorus,
      threeDFlanger,
      tremolo,
      autoPan,
      stPhaser2,
      stAutoWah,
      stFormantFilter,
      multiTapDelay2,
      reverseDelay2,
      shuffleDelay2,
      threeDDelay2,
      rotary2,
      rotaryMulti,
      keyMulti,
      rhodesMulti,
      jdMulti,
      stLofiComp,
      stLofiNoise,
      gtrAmpSim,
      stOverdrive,
      stDistortion,
      gtrMultiA,
      gtrMultiB,
      gtrMultiC,
      clGtrMltA,
      clGtrMltB,
      bassMulti,
      isolator2,
      stSpectrum,
      threeDAutoSpin,
      threeDManual,
      ]
      
    static let off = Self.init(name: "Through", params: [:], dests: [])
    static let eq = Self.init(name: "Stereo Eq", params: [
      0 : ("Low Freq", xvoptions(["200","400"])),
      1 : ("Low Gain", gainParam),
      2 : ("High Freq", xvoptions(["4000","8000"])),
      3 : ("High Gain", gainParam),
      4 : ("Mid1 Freq", fx200to8kParam),
      5 : ("Mid1 Q", eqQParam),
      6 : ("Mid1 Gain", gainParam),
      7 : ("Mid2 Freq", fx200to8kParam),
      8 : ("Mid2 Q", eqQParam),
      9 : ("Mid2 Gain", gainParam),
      10 : ("Level", defaultRangeParam)
      ], dests: [10])
    static let overdrive = Self.init(name: "Overdrive", params: [
      0 : ("Drive", defaultRangeParam),
      1 : ("Pan", panParam),
      2 : ("Amp Type", ampSimpleParam),
      3 : ("Low Gain", gainParam),
      4 : ("High Gain", gainParam),
      5 : ("Level", defaultRangeParam)
      ], dests: [0,1])
    static let distortion = Self.init(name: "Distortion", params: overdrive.params, dests: overdrive.dests)
    static let phaser = Self.init(name: "Phaser", params: [
      0 : ("Manual", fxPhaserManualOptions),
      1 : ("Rate", rateParam),
      2 : ("Depth", defaultRangeParam),
      3 : ("Resonance", defaultRangeParam),
      4 : ("Mix", defaultRangeParam),
      5 : ("Pan", panParam),
      6 : ("Level", defaultRangeParam)
      ], dests: [0,1])
    static let spectrum = Self.init(name: "Spectrum", params: [
      0 : ("250Hz", gainParam),
      1 : ("500Hz", gainParam),
      2 : ("1000Hz", gainParam),
      3 : ("1250Hz", gainParam),
      4 : ("2000Hz", gainParam),
      5 : ("3150Hz", gainParam),
      6 : ("4000Hz", gainParam),
      7 : ("8000Hz", gainParam),
      8 : ("Width", midQParam),
      9 : ("Pan", panParam),
      10 : ("Level", defaultRangeParam)
      ], dests: [9,10])
    static let enhancer = Self.init(name: "Enhancer", params: [
      0 : ("Sens", defaultRangeParam),
      1 : ("Mix", defaultRangeParam),
      2 : ("Low Gain", gainParam),
      3 : ("High Gain", gainParam),
      4 : ("Level", defaultRangeParam)
      ], dests: [0,1])
    static let autowah = Self.init(name: "Auto Wah", params: [
      0 : ("Filter", xvoptions(["LPF","BPF"])),
      1 : ("Rate", rateParam),
      2 : ("Depth", defaultRangeParam),
      3 : ("Sens", defaultRangeParam),
      4 : ("Manual", defaultRangeParam),
      5 : ("Peak", defaultRangeParam),
      6 : ("Level", defaultRangeParam)
      ], dests: [1,4])
    static let rotary = Self.init(name: "Rotary", params: [
      0 : ("Hi Slow", rateParam),
      1 : ("Low Slow", rateParam),
      2 : ("Hi Fast", rateParam),
      3 : ("Low Fast", rateParam),
      4 : ("Speed", xvoptions(["Slow","Fast"])),
      5 : ("Hi Accel", xvrange(0...15)),
      6 : ("Low Accel", xvrange(0...15)),
      7 : ("Hi Level", defaultRangeParam),
      8 : ("Low Level", defaultRangeParam),
      9 : ("Separation", defaultRangeParam),
      10 : ("Level", defaultRangeParam)
      ], dests: [4,10])
    static let compressor = Self.init(name: "Compressor", params: [
      0 : ("Sustain", defaultRangeParam),
      1 : ("Attack", defaultRangeParam),
      2 : ("Pan", panParam),
      3 : ("Post Gain", postGainParam),
      4 : ("Low Gain", gainParam),
      5 : ("High Gain", gainParam),
      6 : ("Level", defaultRangeParam)
      ], dests: [2,6])
    static let limiter = Self.init(name: "Limiter", params: [
      0 : ("Threshold", defaultRangeParam),
      1 : ("Release", defaultRangeParam),
      2 : ("Ratio", limitRatioParam),
      3 : ("Pan", panParam),
      4 : ("Post Gain", postGainParam),
      5 : ("Low Gain", gainParam),
      6 : ("High Gain", gainParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [3,7])
    static let hexaChorus = Self.init(name: "Hexa-chorus", params: [
      0 : ("Pre Delay", delayTime100Param),
      1 : ("Rate", rateParam),
      2 : ("Depth", defaultRangeParam),
      3 : ("Delay Dev", xvrange(0...20)),
      4 : ("Depth Dev", xvrange(-20...20)),
      5 : ("Pan Dev", xvrange(0...20)),
      6 : ("Balance", balanceParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [1,6])
    static let tremChorus = Self.init(name: "Tremolo Cho", params: [
      0 : ("Pre Delay", delayTime100Param),
      1 : ("Cho Rate", rateParam),
      2 : ("Cho Depth", defaultRangeParam),
      3 : ("Trem Rate", rateParam),
      4 : ("Trem Sep", defaultRangeParam),
      5 : ("Phase", phaseParam),
      6 : ("Balance", balanceParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [3,6])
    static let spaceD = Self.init(name: "Space-D", params: [
      0 : ("Pre Delay", delayTime100Param),
      1 : ("Cho Rate", rateParam),
      2 : ("Cho Depth", defaultRangeParam),
      3 : ("Cho Phase", phaseParam),
      4 : ("Low Gain", gainParam),
      5 : ("High Gain", gainParam),
      6 : ("Balance", balanceParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [1,6])
    static let chorus = Self.init(name: "St Chorus", params: [
      0 : ("Filter", filterTypeParam),
      1 : ("Cutoff", fx200to8kParam),
      2 : ("Pre Delay", delayTime100Param),
      3 : ("Rate", rateParam),
      4 : ("Depth", defaultRangeParam),
      5 : ("Phase", phaseParam),
      7 : ("Low Gain", gainParam),
      8 : ("High Gain", gainParam),
      9 : ("Balance", balanceParam),
      10 : ("Level", defaultRangeParam)
      ], dests: [3,9])
    static let flanger = Self.init(name: "Stereo Flanger", params: [
      0 : ("Filter", filterTypeParam),
      1 : ("Cutoff", fx200to8kParam),
      2 : ("Pre Delay", delayTime100Param),
      3 : ("Rate", rateParam),
      4 : ("Depth", defaultRangeParam),
      5 : ("Phase", phaseParam),
      6 : ("Feedback", fdbkParam),
      7 : ("Low Gain", gainParam),
      8 : ("High Gain", gainParam),
      9 : ("Balance", balanceParam),
      10 : ("Level", defaultRangeParam)
      ], dests: [3,6])
    static let stepFlanger = Self.init(name: "Step Flanger", params: [
      0 : ("Pre Delay", delayTime100Param),
      1 : ("Rate", rateParam),
      2 : ("Depth", defaultRangeParam),
      3 : ("Feedback", fdbkParam),
      4 : ("Step Rate", stepRateOptions),
      5 : ("Phase", phaseParam),
      6 : ("Low Gain", gainParam),
      7 : ("High Gain", gainParam),
      8 : ("Balance", balanceParam),
      9 : ("Level", defaultRangeParam)
      ], dests: [4,3])
    static let stDelay = Self.init(name: "Stereo Delay", params: [
      0 : ("Mode", xvoptions(["Normal","Cross"])),
      1 : ("Delay L", delayTime500Param),
      2 : ("Delay R", delayTime500Param),
      3 : ("Phase L", xvoptions(["Normal","Invert"])),
      4 : ("Phase R", xvoptions(["Normal","Invert"])),
      5 : ("Feedback", fdbkParam),
      6 : ("HF Damp", fx200to8kBypassParam),
      7 : ("Low Gain", gainParam),
      8 : ("High Gain", gainParam),
      9 : ("Balance", balanceParam),
      10 : ("Level", defaultRangeParam)
      ], dests: [5,9])
    static let modDelay = Self.init(name: "Mod Delay", params: [
      0 : ("Mode", xvoptions(["Normal","Cross"])),
      1 : ("Delay L", delayTime500Param),
      2 : ("Delay R", delayTime500Param),
      3 : ("Feedback", fdbkParam),
      4 : ("HF Damp", fx200to8kBypassParam),
      5 : ("Rate", rateParam),
      6 : ("Depth", defaultRangeParam),
      7 : ("Phase", phaseParam),
      8 : ("Low Gain", gainParam),
      9 : ("High Gain", gainParam),
      10 : ("Balance", balanceParam),
      11 : ("Level", defaultRangeParam)
      ], dests: [5,10])
    static let tripleDelay = Self.init(name: "3 Tap Delay", params: [
      0 : ("Delay L", delayTime1000Param),
      1 : ("Delay R", delayTime1000Param),
      2 : ("Delay C", delayTime1000Param),
      3 : ("Feedback", fdbkParam),
      4 : ("HF Damp", fx200to8kBypassParam),
      5 : ("Level L", defaultRangeParam),
      6 : ("Level R", defaultRangeParam),
      7 : ("Level C", defaultRangeParam),
      8 : ("Low Gain", gainParam),
      9 : ("High Gain", gainParam),
      10 : ("Balance", balanceParam),
      11 : ("Level", defaultRangeParam)
      ], dests: [3,10])
    static let quadDelay = Self.init(name: "4 Tap Delay", params: [
      0 : ("Delay 1", delayTime1000Param),
      1 : ("Delay 2", delayTime1000Param),
      2 : ("Delay 3", delayTime1000Param),
      3 : ("Delay 4", delayTime1000Param),
      4 : ("Level 1", defaultRangeParam),
      5 : ("Level 2", defaultRangeParam),
      6 : ("Level 3", defaultRangeParam),
      7 : ("Level 4", defaultRangeParam),
      8 : ("Feedback", fdbkParam),
      9 : ("HF Damp", fx200to8kBypassParam),
      10 : ("Balance", balanceParam),
      11 : ("Level", defaultRangeParam)
      ], dests: [8,10])
    static let timeCtrlDelay = Self.init(name: "Tm Ctrl Dly", params: [
      0 : ("Delay", delayTime1000NoNoteParam),
      1 : ("Feedback", fdbkParam),
      2 : ("Accel", accelParam),
      3 : ("HF Damp", fx200to8kBypassParam),
      4 : ("Pan", panParam),
      5 : ("Low Gain", gainParam),
      6 : ("High Gain", gainParam),
      7 : ("Balance", balanceParam),
      8 : ("Level", defaultRangeParam)
      ], dests: [0,1])
    static let duoPitchShift = Self.init(name: "2V pch Shift", params: [
      0 : ("Mode", xvrange(1...5)),
      1 : ("Coarse A", coarseParam),
      2 : ("Coarse B", coarseParam),
      3 : ("Fine A", fineParam),
      4 : ("Fine B", fineParam),
      5 : ("Pre Delay A", delayTime500Param),
      6 : ("Pre Delay B", delayTime500Param),
      7 : ("Pan A", panParam),
      8 : ("Pan B", panParam),
      9 : ("A/B Bal", xvrange(0...100)),
      10 : ("Balance", balanceParam),
      11 : ("Level", defaultRangeParam)
      ], dests: [1,2])
    static let feedbackPitchShift = Self.init(name: "Fb pch Shift", params: [
      0 : ("Mode", xvrange(1...5)),
      1 : ("Coarse", coarseParam),
      2 : ("Fine", fineParam),
      3 : ("Pre Delay", delayTime500Param),
      4 : ("Feedback", fdbkParam),
      5 : ("Pan", panParam),
      6 : ("Low Gain", gainParam),
      7 : ("High Gain", gainParam),
      8 : ("Balance", balanceParam),
      9 : ("Level", defaultRangeParam)
      ], dests: [1,4])
    static let reverb = Self.init(name: "Reverb", params: [
      0 : ("Type", xvoptions(["Room 1","Room 2","Stage 1","Stage 2","Hall 1","Hall 2"])),
      1 : ("Pre Delay", delayTime100Param),
      2 : ("Time", defaultRangeParam),
      3 : ("HF Damp", fx200to8kBypassParam),
      4 : ("Low Gain", gainParam),
      5 : ("High Gain", gainParam),
      6 : ("Balance", balanceParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [2,6])
    static let gateVerb = Self.init(name: "Gated Reverb", params: [
      0 : ("Type", xvoptions(["Normal","Reverse","Sweep 1","Sweep 2"])),
      1 : ("Pre Delay", delayTime100Param),
      2 : ("Gate Time", gateTimeParam),
      3 : ("Low Gain", gainParam),
      4 : ("High Gain", gainParam),
      5 : ("Balance", balanceParam),
      6 : ("Level", defaultRangeParam)
      ], dests: [5,6])
    static let odChorus = Self.init(name: "OD → Chorus", params: [
      0 : ("Drive", defaultRangeParam),
      1 : ("OD Pan", panParam),
      2 : ("Pre Delay", delayTime100Param),
      3 : ("Rate", rateParam),
      4 : ("Depth", defaultRangeParam),
      6 : ("Cho Bal", balanceParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [1,6])
    static let odFlanger = Self.init(name: "OD → Flanger", params: [
      0 : ("Drive", defaultRangeParam),
      1 : ("OD Pan", panParam),
      2 : ("Pre Delay", delayTime100Param),
      3 : ("Rate", rateParam),
      4 : ("Depth", defaultRangeParam),
      5 : ("Feedback", fdbkParam),
      6 : ("Flg Bal", balanceParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [1,6])
    static let odDelay = Self.init(name: "OD → Delay", params: [
      0 : ("Drive", defaultRangeParam),
      1 : ("OD Pan", panParam),
      2 : ("Delay", delayTime500Param),
      3 : ("Feedback", fdbkParam),
      4 : ("HF Damp", fx200to8kBypassParam),
      5 : ("Dly Bal", balanceParam),
      6 : ("Level", defaultRangeParam)
      ], dests: [1,5])
    static let distChorus = Self.init(name: "Dist → Chorus", params: odChorus.params, dests: odChorus.dests)
    static let distFlanger = Self.init(name: "Dist → Flanger", params: odFlanger.params, dests: odFlanger.dests)
    static let distDelay = Self.init(name: "Dist → Delay", params: odDelay.params, dests: odDelay.dests)
    static let enhanceChorus = Self.init(name: "Enh → Chorus", params: [
      0 : ("Sens", defaultRangeParam),
      1 : ("Mix", defaultRangeParam),
      2 : ("Pre Delay", delayTime100Param),
      3 : ("Rate", rateParam),
      4 : ("Depth", defaultRangeParam),
      6 : ("Balance", balanceParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [0,6])
    static let enhanceFlanger = Self.init(name: "Enh → Flanger", params: [
      0 : ("Sens", defaultRangeParam),
      1 : ("Mix", defaultRangeParam),
      2 : ("Pre Delay", delayTime100Param),
      3 : ("Rate", rateParam),
      4 : ("Depth", defaultRangeParam),
      5 : ("Feedback", fdbkParam),
      6 : ("Balance", balanceParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [0,6])
    static let enhanceDelay = Self.init(name: "Enh → Delay", params: [
      0 : ("Sens", defaultRangeParam),
      1 : ("Mix", defaultRangeParam),
      2 : ("Delay", delayTime500Param),
      3 : ("Feedback", fdbkParam),
      4 : ("HF Damp", fx200to8kBypassParam),
      6 : ("Balance", balanceParam),
      7 : ("Level", defaultRangeParam)
      ], dests: [0,6])
    static let chorusDelay = Self.init(name: "Chorus → Delay", params: [
      0 : ("Cho Delay", delayTime100Param),
      1 : ("Cho Rate", rateParam),
      2 : ("Cho Depth", defaultRangeParam),
      4 : ("Cho Balance", balanceParam),
      5 : ("Delay", delayTime500Param),
      6 : ("Delay Fbk", fdbkParam),
      7 : ("HF Damp", fx200to8kBypassParam),
      8 : ("Delay Bal", balanceParam),
      9 : ("Level", defaultRangeParam)
      ], dests: [4,8])
    static let flangerDelay = Self.init(name: "Flg → Delay", params: [
      0 : ("Flg Delay", delayTime100Param),
      1 : ("Flg Rate", rateParam),
      2 : ("Flg Depth", defaultRangeParam),
      3 : ("Flg Feedback", fdbkParam),
      4 : ("Flg Balance", balanceParam),
      5 : ("Delay", delayTime500Param),
      6 : ("Delay Fbk", fdbkParam),
      7 : ("HF Damp", fx200to8kBypassParam),
      8 : ("Delay Bal", balanceParam),
      9 : ("Level", defaultRangeParam)
      ], dests: [4,8])
    static let chorusFlanger = Self.init(name: "Cho → Flanger", params: [
      0 : ("Cho Delay", delayTime100Param),
      1 : ("Cho Rate", rateParam),
      2 : ("Cho Depth", defaultRangeParam),
      3 : ("Cho Bal", balanceParam),
      4 : ("Flg Delay", delayTime100Param),
      5 : ("Flg Rate", rateParam),
      6 : ("Flg Depth", defaultRangeParam),
      7 : ("Flg Feedback", fdbkParam),
      8 : ("Flg Bal", balanceParam),
      9 : ("Level", defaultRangeParam)
      ], dests: [3,8])
    static let chorusAndDelay = Self.init(name: "Chorus/Delay", params: chorusDelay.params, dests: chorusDelay.dests)
    static let flangerAndDelay = Self.init(name: "Flg/Delay", params: flangerDelay.params, dests: flangerDelay.dests)
    static let chorusAndFlanger = Self.init(name: "Cho/Flanger", params: chorusFlanger.params, dests: chorusFlanger.dests)
    static let stPhaser = Self.init(name: "St Phaser", params: [
      0 : ("Type", xvoptions(["1","2"])),
      1 : ("Mode", xvoptions(["4-stage","8-stage"])),
      2 : ("Polarity", xvoptions(["Inverse","Synchro"])),
      3 : ("Rate", phaserRateOptions),
      4 : ("Depth", defaultRangeParam),
      5 : ("Manual", defaultRangeParam),
      6 : ("Resonance", defaultRangeParam),
      7 : ("X-Feedback", fdbkParam),
      8 : ("Step Switch", xvoptions(["Off","On"])),
      9 : ("Step Rate", phaserStepRateOptions),
      10 : ("Mix", defaultRangeParam),
      11 : ("Low Gain", gainParam),
      12 : ("High Gain", gainParam),
      13 :("Level", defaultRangeParam)
      ], dests: [3,5,9])
    static let keySyncFlanger = Self.init(name: "Keysync Flg", params: [
      0 : ("Filter", filterTypeParam),
      1 : ("Cutoff", fx200to8kParam),
      2 : ("Pre Delay", delayTime100Param),
      3 : ("LFO Rate", phaserRateOptions),
      4 : ("LFO Depth", defaultRangeParam),
      5 : ("Feedback", fdbkParam),
      6 : ("Step Switch", offOnParam),
      7 : ("Step Rate", phaserStepRateOptions),
      8 : ("Phase", phaseParam),
      9 : ("Keysync", offOnParam),
      10 : ("Threshold", defaultRangeParam),
      11 : ("Ksync Phase", xvoptions(181.map { "\($0 * 2)" })),
      12 : ("Low Gain", gainParam),
      13 : ("High Gain", gainParam),
      14 : ("Balance", balanceParam),
      15 : ("Level", defaultRangeParam),
      ], dests: [3,5,7,14])
    static let formantFilter = Self.init(name: "Formant Fltr", params: [
      0 : ("Drive", offOnParam),
      1 : ("Drive", defaultRangeParam),
      2 : ("Vowel1", vowelParam),
      3 : ("Vowel2", vowelParam),
      4 : ("Rate", phaserRateOptions),
      5 : ("Depth", defaultRangeParam),
      6 : ("Keysync", offOnParam),
      7 : ("Threshold", defaultRangeParam),
      8 : ("Manual", xvrange(0...100)),
      9 : ("Low Gain", gainParam),
      10 : ("High Gain", gainParam),
      11 : ("Pan", panParam),
      12 : ("Level", defaultRangeParam),
      ], dests: [1,4,5,8])
    static let ringMod = Self.init(name: "Ring Mod", params: [
      0 : ("Frequency", defaultRangeParam),
      1 : ("Modulator", xvoptions(["Off","Src","A","B","C","D"])),
      2 : ("Monitor", offOnParam),
      3 : ("Sens", defaultRangeParam),
      4 : ("Polarity", xvoptions(["Up","Down"])),
      5 : ("Low Gain", gainParam),
      6 : ("High Gain", gainParam),
      7 : ("Balance", balanceParam),
      8 : ("Level", defaultRangeParam)
      ], dests: [0,3,7])
    static let multiTapDelay = Self.init(name: "Mlt tap Dly", params: [
      0 : ("Delay 1", delayTime1800Param),
      1 : ("Delay 2", delayTime1800Param),
      2 : ("Delay 3", delayTime1800Param),
      3 : ("Delay 4", delayTime1800Param),
      4 : ("Dly Pan 1", panParam),
      5 : ("Dly Pan 2", panParam),
      6 : ("Dly Pan 3", panParam),
      7 : ("Dly Pan 4", panParam),
      8 : ("Dly Level 1", defaultRangeParam),
      9 : ("Dly Level 2", defaultRangeParam),
      10 : ("Dly Level 3", defaultRangeParam),
      11 : ("Dly Level 4", defaultRangeParam),
      12 : ("Feedback", fdbkParam),
      13 : ("HF Damp", fx200to8kBypassParam),
      14 : ("Low Gain", gainParam),
      15 : ("High Gain", gainParam),
      16 : ("Balance", balanceParam),
      17 : ("Level", defaultRangeParam)
      ], dests: [12,16])
    static let reverseDelay = Self.init(name: "Reverse Dly", params: [
      0: ("Threshold", defaultRangeParam),
      1 : ("Delay 1", delayTime900Param),
      2 : ("Delay 2", delayTime900Param),
      3 : ("Delay 3", delayTime900Param),
      4 : ("Delay 4", delayTime900Param),
      5 : ("Feedback 1", fdbkParam),
      6 : ("Feedback 4", fdbkParam),
      7 : ("HF Damp 1", fx200to8kBypassParam),
      8 : ("HF Damp 4", fx200to8kBypassParam),
      9 : ("Dly Pan 1", panParam),
      10 : ("Dly Pan 2", panParam),
      11 : ("Dly Pan 3", panParam),
      12 : ("Dly Level 1", defaultRangeParam),
      13 : ("Dly Level 2", defaultRangeParam),
      14 : ("Dly Level 3", defaultRangeParam),
      15 : ("Balance", balanceParam),
      16 : ("Low Gain", gainParam),
      17 : ("High Gain", gainParam),
      18 : ("Level", defaultRangeParam),
      ], dests: [5,6,15])
    static let shuffleDelay = Self.init(name: "Shuffle Dly", params: [
      0 : ("Delay", delayTime1800Param),
      1 : ("Shuffle Rate", xvrange(0...100)),
      2 : ("Pan A", panParam),
      3 : ("Pan B", panParam),
      4 : ("Level Bal", xvrange(0...100)),
      5 : ("Feedback", fdbkParam),
      6 : ("Acceleration", accelParam),
      7 : ("HF Damp", fx200to8kBypassParam),
      8 : ("Low Gain", gainParam),
      9 : ("High Gain", gainParam),
      10 : ("Balance", balanceParam),
      11 : ("Level", defaultRangeParam)
      ], dests: [0,1,5,10])
    static let threeDDelay = Self.init(name: "3D Delay", params: [
      0 : ("Delay L", delayTime1800Param),
      1 : ("Delay R", delayTime1800Param),
      2 : ("Delay C", delayTime1800Param),
      3 : ("Level L", defaultRangeParam),
      4 : ("Level R", defaultRangeParam),
      5 : ("Level C", defaultRangeParam),
      6 : ("Feedback", fdbkParam),
      7 : ("HF Damp", fx200to8kBypassParam),
      8 : ("Output Mode", xvoptions(["Speaker","Phones"])),
      9 : ("Low Gain", gainParam),
      10 : ("High Gain", gainParam),
      11 : ("Balance", balanceParam),
      12 : ("Level", defaultRangeParam)
      ], dests: [6,11])
    static let threeVoicePitchShift = Self.init(name: "3V pch Shift", params: [
      0 : ("Mode", xvrange(1...5)),
      1 : ("Coarse 1", coarseParam),
      2 : ("Coarse 2", coarseParam),
      3 : ("Coarse 3", coarseParam),
      4 : ("Fine 1", fineParam),
      5 : ("Fine 2", fineParam),
      6 : ("Fine 3", fineParam),
      7 : ("Pre Dly 1", delayTime500Param),
      8 : ("Pre Dly 2", delayTime500Param),
      9 : ("Pre Dly 3", delayTime500Param),
      10 : ("Feedback 1", fdbkParam),
      11 : ("Feedback 2", fdbkParam),
      12 : ("Feedback 3", fdbkParam),
      13 : ("Pan 1", panParam),
      14 : ("Pan 2", panParam),
      15 : ("Pan 3", panParam),
      16 : ("Level 1", defaultRangeParam),
      17 : ("Level 2", defaultRangeParam),
      18 : ("Level 3", defaultRangeParam),
      19 : ("Balance", balanceParam),
      20 : ("Level", defaultRangeParam)
      ], dests: [1,2,3,10,11,12])
    static let lofiComp = Self.init(name: "Lofi Comp", params: [
      0 : ("Pre Filter", xvrange(1...6)),
      1 : ("LoFi Type", xvrange(1...9)),
      2 : ("Post Filter 1", xvrange(1...6)),
      3 : ("Post Filter 2", filterTypeParam),
      4 : ("Post Cutoff", fx200to8kParam),
      5 : ("Balance", balanceParam),
      6 : ("Low Gain", gainParam),
      7 : ("High Gain", gainParam),
      8 : ("Pan", panParam),
      9 : ("Level", defaultRangeParam),
      ], dests: [5])
    static let lofiNoise = Self.init(name: "Lofi Noise", params: [
      0 : ("LoFi Type", xvrange(1...9)),
      1 : ("Post Filter", filterTypeParam),
      2 : ("Cutoff", fx200to8kParam),
      3 : ("Radio Detune", defaultRangeParam),
      4 : ("Radio N Level", defaultRangeParam),
      5 : ("Disc Noise", xvoptions(["LP","EP","SP","RND"])),
      6 : ("Disc N LPF", fx200to8kBypassParam),
      7 : ("Disc N Level", defaultRangeParam),
      8 : ("Balance", balanceParam),
      9 : ("Low Gain", gainParam),
      10 : ("High Gain", gainParam),
      11 : ("Pan", panParam),
      12 : ("Level", defaultRangeParam),
      ], dests: [3,8])
    static let speakerSim = Self.init(name: "Speaker Sim", params: [
      0 : ("Type", speakerSimParam),
      1 : ("Mic Setting", xvrange(1...3)),
      2 : ("Mic Level", defaultRangeParam),
      3 : ("Direct Level", defaultRangeParam),
      4 : ("Level", defaultRangeParam)
      ], dests: [2,3,4])
    static let overdrive2 = Self.init(name: "Overdrive 2", params: [
      0 : ("Drive", defaultRangeParam),
      1 : ("Tone", defaultRangeParam),
      2 : ("Pan", panParam),
      3 : ("Amp Simulator", offOnParam),
      4 : ("Amp Type", ampSimpleParam),
      5 : ("Low Gain", gainParam),
      6 : ("High Gain", gainParam),
      7 : ("Level", defaultRangeParam),
      ], dests: [0,2])
    static let distortion2 = Self.init(name: "Distortion 2", params: overdrive2.params, dests: overdrive2.dests)
    static let stComp = Self.init(name: "Stereo Comp", params: [
      0 : ("Sustain", defaultRangeParam),
      1 : ("Attack", defaultRangeParam),
      2 : ("Post Gain", postGainParam),
      3 : ("Low Gain", gainParam),
      4 : ("High Gain", gainParam),
      5 : ("Level", defaultRangeParam)
      ], dests: [5])
    static let stLimit = Self.init(name: "St Limiter", params: [
      0 : ("Threshold", defaultRangeParam),
      1 : ("Release", defaultRangeParam),
      2 : ("Ratio", limitRatioParam),
      3 : ("Post Gain", postGainParam),
      4 : ("Low Gain", gainParam),
      5 : ("High Gain", gainParam),
      6 : ("Level", defaultRangeParam)
      ], dests: [6])
    static let gate = Self.init(name: "Gate", params: [
      0 : ("Key", xvoptions(["Source","A","B","C","D"])),
      1 : ("Threshold", defaultRangeParam),
      2 : ("Monitor", offOnParam),
      3 : ("Mode", xvoptions(["Gate","Duck"])),
      4 : ("Balance", balanceParam),
      5 : ("Attack", defaultRangeParam),
      6 : ("Hold", defaultRangeParam),
      7 : ("Release", defaultRangeParam),
      8 : ("Level", defaultRangeParam)
      ], dests: [4])
    static let slicer = Self.init(name: "Slicer", params: [
      0 : ("Level Beat 1-1", defaultRangeParam),
      1 : ("Beat 1-2", defaultRangeParam),
      2 : ("Beat 1-3", defaultRangeParam),
      3 : ("Beat 1-4", defaultRangeParam),
      4 : ("Level Beat 2-1", defaultRangeParam),
      5 : ("Beat 2-2", defaultRangeParam),
      6 : ("Beat 2-3", defaultRangeParam),
      7 : ("Beat 2-4", defaultRangeParam),
      8 : ("Level Beat 3-1", defaultRangeParam),
      9 : ("Beat 3-2", defaultRangeParam),
      10 : ("Beat 3-3", defaultRangeParam),
      11 : ("Beat 3-4", defaultRangeParam),
      12 : ("Level Beat 4-1", defaultRangeParam),
      13 : ("Beat 4-2", defaultRangeParam),
      14 : ("Beat 4-3", defaultRangeParam),
      15 : ("Beat 4-4", defaultRangeParam),
      16 : ("Rate", phaserRateOptions),
      17 : ("Attack", defaultRangeParam),
      18 : ("Reset Trigger", xvoptions(["Off","Src","A","B","C","D"])),
      19 : ("Reset Threshold", defaultRangeParam),
      20 : ("Reset Monitor", offOnParam),
      21 : ("Beat Chg Mode", xvoptions(["Legato","Slash"])),
      22 : ("Shuffle", defaultRangeParam),
      23 : ("Level", defaultRangeParam)
      ], dests: [18,16,22])
    static let isolator = Self.init(name: "Isolator", params: [
      0 : ("High", isolatorGainParam),
      1 : ("Mid", isolatorGainParam),
      2 : ("Low", isolatorGainParam),
      3 : ("AntiPhase Mid", offOnParam),
      4 : ("AntiPhase MidLev", defaultRangeParam),
      5 : ("AntiPhase Low", offOnParam),
      6 : ("AntiPhase LowLev", defaultRangeParam),
      7 : ("Low Boost", offOnParam),
      8 : ("Low Boost Level", defaultRangeParam),
      9 : ("Level", defaultRangeParam)
      ], dests: [0,1,2])
    static let threeDChorus = Self.init(name: "3D Chorus", params: [
      0 : ("Filter", filterTypeParam),
      1 : ("Cutoff", fx200to8kParam),
      2 : ("Pre Delay", delayTime100Param),
      3 : ("LFO Rate", phaserRateOptions),
      4 : ("LFO Depth", defaultRangeParam),
      5 : ("Phase", phaseParam),
      6 : ("Output Mode", threeDOutParam),
      7 : ("Low Gain", gainParam),
      8 : ("High Gain", gainParam),
      9 : ("Balance", balanceParam),
      10 : ("Level", defaultRangeParam)
      ], dests: [3,9])
    static let threeDFlanger = Self.init(name: "3D Flanger", params: [
      0 : ("Filter", filterTypeParam),
      1 : ("Cutoff", fx200to8kParam),
      2 : ("Pre Delay", delayTime100Param),
      3 : ("LFO Rate", phaserRateOptions),
      4 : ("LFO Depth", defaultRangeParam),
      5 : ("Feedback", fdbkParam),
      6 : ("Step", offOnParam),
      7 : ("Step Rate", phaserStepRateOptions),
      8 : ("Phase", phaseParam),
      9 : ("Output Mode", threeDOutParam),
      10 : ("Low Gain", gainParam),
      11 : ("High Gain", gainParam),
      12 : ("Balance", balanceParam),
      13 : ("Level", defaultRangeParam)
      ], dests: [3,5,7,12])
    static let tremolo = Self.init(name: "Tremolo", params: [
      0 : ("Mod Wave", modWaveParam),
      1 : ("Rate", phaserRateOptions),
      2 : ("Depth", defaultRangeParam),
      3 : ("Low Gain", gainParam),
      4 : ("High Gain", gainParam),
      5 : ("Level", defaultRangeParam)
      ], dests: [1,2])
    static let autoPan = Self.init(name: "Auto Pan", params: [
      0 : ("Mod Wave", modWaveParam),
      1 : ("Rate", phaserRateOptions),
      2 : ("Depth", defaultRangeParam),
      3 : ("Low Gain", gainParam),
      4 : ("High Gain", gainParam),
      5 : ("Level", defaultRangeParam)
      ], dests: [1,2])
    static let stPhaser2 = Self.init(name: "St Phaser 2", params: [
      0 : ("Type", xvoptions(["1","2"])),
      1 : ("Mode", xvoptions(["4 Stage", "8 Stage", "12 Stage", "16 Stage"])),
      2 : ("Polarity", xvoptions(["Inverse", "Synchro"])),
      3 : ("Rate", phaserRateOptions),
      4 : ("Depth", defaultRangeParam),
      5 : ("Manual", defaultRangeParam),
      6 : ("Resonance", defaultRangeParam),
      7 : ("X-Feedback", fdbkParam),
      8 : ("Step", offOnParam),
      9 : ("Step Rate", phaserStepRateOptions),
      10 : ("Mix Level", defaultRangeParam),
      11 : ("Low Gain", gainParam),
      12 : ("High Gain", gainParam),
      13 : ("Level", defaultRangeParam)
      ], dests: [3,5,9])
    static let stAutoWah = Self.init(name: "St Auto Wah", params: [
      0 : ("Filter", xvoptions(["LPF","BPF"])),
      1 : ("Rate", phaserRateOptions),
      2 : ("Depth", defaultRangeParam),
      3 : ("Sens", defaultRangeParam),
      4 : ("Manual", defaultRangeParam),
      5 : ("Peak", defaultRangeParam),
      6 : ("Polarity", xvoptions(["Up", "Down"])),
      7 : ("Phase", phaseParam),
      8 : ("Low Gain", gainParam),
      9 : ("High Gain", gainParam),
      10 : ("Level", defaultRangeParam)
      ], dests: [1,2,3,4,7])
    static let stFormantFilter = Self.init(name: "St Formn Flt", params: [
      0 : ("Drive", offOnParam),
      1 : ("Drive", defaultRangeParam),
      2 : ("Vowel 1", vowelParam),
      3 : ("Vowel 2", vowelParam),
      4 : ("Rate", phaserRateOptions),
      5 : ("Depth", defaultRangeParam),
      6 : ("Phase", phaseParam),
      7 : ("Keysync", offOnParam),
      8 : ("Keysync Thresh", defaultRangeParam),
      9 : ("Manual", xvrange(0...100)),
      10 : ("Low Gain", gainParam),
      11 : ("High Gain", gainParam),
      12 : ("Level", defaultRangeParam)
      ], dests: [1,4,5,6,9])
    static let multiTapDelay2 = Self.init(name: "Mlt tap Dly2", params: [
      0 : ("Delay 1", delayTime3000Param),
      1 : ("Delay 2", delayTime3000Param),
      2 : ("Delay 3", delayTime3000Param),
      3 : ("Delay 4", delayTime3000Param),
      4 : ("Delay Pan 1", panParam),
      5 : ("Delay Pan 2", panParam),
      6 : ("Delay Pan 3", panParam),
      7 : ("Delay Pan 4", panParam),
      8 : ("Delay Level 1", defaultRangeParam),
      9 : ("Delay Level 2", defaultRangeParam),
      10 : ("Delay Level 3", defaultRangeParam),
      11 : ("Delay Level 4", defaultRangeParam),
      12 : ("Feedback", fdbkParam),
      13 : ("HF Damp", fx200to8kBypassParam),
      14 : ("Low Gain", gainParam),
      15 : ("High Gain", gainParam),
      16 : ("Balance", balanceParam),
      17 : ("Level", defaultRangeParam)
      ], dests: [12,16])
    static let reverseDelay2 = Self.init(name: "Reverse Dly2", params: [
      0 : ("Threshold", defaultRangeParam),
      1 : ("Delay 1", delayTime1500Param),
      2 : ("Delay 2", delayTime1500Param),
      3 : ("Delay 3", delayTime1500Param),
      4 : ("Delay 4", delayTime1500Param),
      5 : ("Feedback 1", fdbkParam),
      6 : ("Feedback 4", fdbkParam),
      7 : ("HF Damp 1", fx200to8kBypassParam),
      8 : ("HF Damp 4", fx200to8kBypassParam),
      9 : ("Delay Pan 1", panParam),
      10 : ("Delay Pan 2", panParam),
      11 : ("Delay Pan 3", panParam),
      12 : ("Delay Level 1", defaultRangeParam),
      13 : ("Delay Level 2", defaultRangeParam),
      14 : ("Delay Level 3", defaultRangeParam),
      15 : ("Balance", balanceParam),
      16 : ("Low Gain", gainParam),
      17 : ("High Gain", gainParam),
      18 : ("Level", defaultRangeParam)
      ], dests: [5,6,15])
    static let shuffleDelay2 = Self.init(name: "Shuffle Dly2", params: [
      0 : ("Delay", delayTime3000Param),
      1 : ("Shuffle Rate", xvrange(0...100)),
      2 : ("Pan A", panParam),
      3 : ("Pan B", panParam),
      4 : ("Level Bal", xvrange(0...100)),
      5 : ("Feedback", fdbkParam),
      6 : ("Acceleration", accelParam),
      7 : ("HF Damp", fx200to8kBypassParam),
      8 : ("Low Gain", gainParam),
      9 : ("High Gain", gainParam),
      10 : ("Balance", balanceParam),
      11 : ("Level", defaultRangeParam)
      ], dests: [0,1,5,10])
    static let threeDDelay2 = Self.init(name: "3D Delay 2", params: [
      0 : ("Delay L", delayTime3000Param),
      1 : ("Delay R", delayTime3000Param),
      2 : ("Delay C", delayTime3000Param),
      3 : ("Level L", defaultRangeParam),
      4 : ("Level R", defaultRangeParam),
      5 : ("Level C", defaultRangeParam),
      6 : ("Feedback", fdbkParam),
      7 : ("HF Damp", fx200to8kBypassParam),
      8 : ("Output Mode", threeDOutParam),
      9 : ("Low Gain", gainParam),
      10 : ("High Gain", gainParam),
      11 : ("Balance", balanceParam),
      12 : ("Level", defaultRangeParam)
      ], dests: [6,11])
    static let rotary2 = Self.init(name: "Rotary 2", params: [
      0 : ("Low Slow", phaserRateOptions),
      1 : ("Low Fast", phaserRateOptions),
      2 : ("Low Trans Up", defaultRangeParam),
      3 : ("Low Trans Down", defaultRangeParam),
      4 : ("Low Level", defaultRangeParam),
      5 : ("High Slow", phaserRateOptions),
      6 : ("High Fast", phaserRateOptions),
      7 : ("High Trans Up", defaultRangeParam),
      8 : ("High Trans Down", defaultRangeParam),
      9 : ("High Level", defaultRangeParam),
      10 : ("Speed", xvoptions(["Slow", "Fast"])),
      11 : ("Brake", offOnParam),
      12 : ("Spread", xvrange(0...10)),
      13 : ("Low Gain", gainParam),
      14 : ("High Gain", gainParam),
      15 : ("Level", defaultRangeParam)
      ], dests: [10,11,15])
    static let rotaryMulti = Self.init(name: "Rotary Multi", params: [
      0 : ("OD/Dist", offOnParam),
      1 : ("Type", xvoptions(["OD","Dist"])),
      2 : ("Drive", defaultRangeParam),
      3 : ("Tone", defaultRangeParam),
      4 : ("Level", defaultRangeParam),
      5 : ("Amp Sim", offOnParam),
      6 : ("Amp Type", ampSimpleParam),
      7 : ("EQ", offOnParam),
      8 : ("Low Gain", gainParam),
      9 : ("Mid Freq", fx200to8kParam),
      10 : ("Mid Q", midQParam),
      11 : ("Mid Gain", gainParam),
      12 : ("High Gain", gainParam),
      13 : ("Rotary", offOnParam),
      14 : ("High Freq Slow", phaserRateOptions),
      15 : ("Low Freq Slow", phaserRateOptions),
      16 : ("High Freq Fast", phaserRateOptions),
      17 : ("Low Freq Fast", phaserRateOptions),
      18 : ("Speed", xvoptions(["Slow","Fast"])),
      19 : ("High Freq Accel", accelParam),
      20 : ("Low Freq Accel", accelParam),
      21 : ("High Freq Level", defaultRangeParam),
      22 : ("Low Freq Level", defaultRangeParam),
      23 : ("Separation", defaultRangeParam),
      24 : ("Pan", panParam),
      25 : ("Out Level", defaultRangeParam),
      ], dests: [2,18])
    static let keyMulti = Self.init(name: "Keybd Multi", params: [
      0 : ("Ring Mod", offOnParam),
      1 : ("Freq", defaultRangeParam),
      2 : ("RM Bal", balanceParam),
      3 : ("EQ", offOnParam),
      4 : ("Low Gain", gainParam),
      5 : ("Mid Freq", fx200to8kParam),
      6 : ("Mid Q", midQParam),
      7 : ("Mid Gain", gainParam),
      8 : ("High Gain", gainParam),
      9 : ("Pitch Shift", offOnParam),
      10 : ("Mode", xvrange(1...5)),
      11 : ("Coarse", coarseParam),
      12 : ("Fine", fineParam),
      13 : ("Dly", delayTime500Param),
      14 : ("Feedback", fdbkParam),
      15 : ("Balance", balanceParam),
      16 : ("Phaser", offOnParam),
      17 : ("Mode", xvoptions(["4 Stage","8 Stage"])),
      18 : ("Manual", defaultRangeParam),
      19 : ("Ph Rate", phaserRateOptions),
      20 : ("Depth", defaultRangeParam),
      21 : ("Resonance", defaultRangeParam),
      22 : ("Mix", defaultRangeParam),
      23 : ("Delay", offOnParam),
      24 : ("Time L", delayTime3000Param),
      25 : ("Time R", delayTime3000Param),
      26 : ("Feedback", fdbkParam),
      27 : ("HF Damp", fx200to8kBypassParam),
      28 : ("Dly Bal", balanceParam),
      29 : ("Out Level", defaultRangeParam)
      ], dests: [1,2,11,14,18,19,28])
    static let rhodesMulti = Self.init(name: "Rhodes Multi", params: [
      0 : ("Enhancer", offOnParam),
      1 : ("Sens", defaultRangeParam),
      2 : ("Mix", defaultRangeParam),
      3 : ("Phaser", offOnParam),
      4 : ("Mode", xvoptions(["4 Stage","8 Stage"])),
      5 : ("Manual", defaultRangeParam),
      6 : ("Rate", defaultRangeParam),
      7 : ("Depth", defaultRangeParam),
      8 : ("Resonance", defaultRangeParam),
      9 : ("Mix", defaultRangeParam),
      10 : ("Cho/Flg", offOnParam),
      11 : ("Type", choFlgParam),
      12 : ("Pre Dly", delayTime100Param),
      13 : ("Rate", phaserRateOptions),
      14 : ("Depth", defaultRangeParam),
      15 : ("Feedback", fdbkParam),
      16 : ("Filter", filterTypeParam),
      17 : ("Cutoff", fx200to8kParam),
      18 : ("C/F Bal", balanceParam),
      19 : ("Tre/Pan", offOnParam),
      20 : ("Type", xvoptions(["Tremolo", "Pan"])),
      21 : ("Mod Wave", modWaveParam),
      22 : ("T/P Rate", phaserRateOptions),
      23 : ("T/P Depth", defaultRangeParam),
      24 : ("Out Level", defaultRangeParam)
      ], dests: [1,5,6,18,22,23])
    static let jdMulti = Self.init(name: "Jd Multi", params: [
      0 : ("Sequence", xvoptions(["DS-PH-SP-EN", "DS-PH-EN-SP", "DS-SP-PH-EN", "DS-SP-EN-PH", "DS-EN-PH-SP", "DS-EN-SP-PH", "PH-DS-SP-EN", "PH-DS-EN-SP", "PH-SP-DS-EN", "PH-SP-EN-DS", "PH-EN-DS-SP", "PH-EN-SP-DS", "SP-DS-PH-EN", "SP-DS-EN-PH", "SP-PH-DS-EN", "SP-PH-EN-DS", "SP-EN-DS-PH", "SP-EN-PH-DS", "EN-DS-PH-SP", "EN-DS-SP-PH", "EN-PH-DS-SP", "EN-PH-SP-DS", "EN-SP-DS-PH", "EN-SP-PH-DS"])),
      1 : ("Dist", offOnParam),
      2 : ("Type", xvoptions(["Mellow Drive", "Overdrive", "Cry Drive", "Mellow Dist", "Light Dist", "Fat Dist", "Fuzz Dist"])),
      3 : ("Drive", xvrange(0...100)),
      4 : ("Level", xvrange(0...100)),
      5 : ("Phaser", offOnParam),
      6 : ("Manual", xvoptions({
        var options = (0...25).map { "\(50 + $0 * 10)" }
        options += (0...23).map { "\(320 + $0 * 30)" }
        options += (0...35).map { "\(1100 + $0 * 200)" }
        options += (0...13).map { "\(8500 + $0 * 500)" }
        return options
        }())),
      7 : ("Rate", xvmiso(1...100, Miso.m(0.1) >>> Miso.round(1))),
      8 : ("Depth", xvrange(0...100)),
      9 : ("Resonance", xvrange(0...100)),
      10 : ("Ph Mix", xvrange(0...100)),
      11 : ("Spectrum", offOnParam),
      12 : ("250Hz", gainParam),
      13 : ("500Hz", gainParam),
      14 : ("1kHz", gainParam),
      15 : ("2kHz", gainParam),
      16 : ("4kHz", gainParam),
      17 : ("8kHz", gainParam),
      18 : ("Width", xvrange(1...5)),
      19 : ("Enhancer", offOnParam),
      20 : ("Sens", xvrange(0...100)),
      21 : ("Enh Mix", xvrange(0...100)),
      22 : ("Pan", panParam),
      23 : ("Out Level", defaultRangeParam),
      ], dests: [3,6,7,8,9,10,21])
    static let stLofiComp = Self.init(name: "St Lofi Comp", params: [
      0 : ("Pre Filter", xvrange(1...6)),
      1 : ("LoFi Type", xvrange(1...9)),
      2 : ("Post Filter 1", xvrange(1...6)),
      3 : ("Post Filter 2", filterTypeParam),
      4 : ("Post Cutoff", fx200to8kParam),
      5 : ("Balance", balanceParam),
      6 : ("Low Gain", gainParam),
      7 : ("High Gain", gainParam),
      8 : ("Level", defaultRangeParam)
      ], dests: [5])
    static let stLofiNoise = Self.init(name: "St Lofi Noiz", params: [
      0 : ("LoFi Type", xvrange(1...9)),
      1 : ("Post Filter", filterTypeParam),
      2 : ("Cutoff", fx200to8kParam),
      3 : ("Radio Detune", defaultRangeParam),
      4 : ("RadioNoise Level", defaultRangeParam),
      5 : ("Noise Type", xvoptions(["White","Pink"])),
      6 : ("W/P LPF", fx200to8kBypassParam),
      7 : ("White/Pink Level", defaultRangeParam),
      8 : ("Disc N Type", xvoptions(["LP","EP","SP","RND"])),
      9 : ("Disc N LPF", fx200to8kBypassParam),
      10 : ("Disc N Level", defaultRangeParam),
      11 : ("Hum N Type", xvoptions(["50","60"])),
      12 : ("Hum N LPF", fx200to8kBypassParam),
      13 : ("Hum N Level", defaultRangeParam),
      14 : ("Balance", balanceParam),
      15 : ("Low Gain", gainParam),
      16 : ("High Gain", gainParam),
      17 : ("Level", defaultRangeParam)
      ], dests: [3,14])
    static let gtrAmpSim = Self.init(name: "Gtr amp Sim", params: [
      0 : ("Amp Simulator", offOnParam),
      1 : ("Amp Type", ampSimParam),
      2 : ("Amp Volume", defaultRangeParam),
      3 : ("Amp Master Vol", defaultRangeParam),
      4 : ("Amp Gain", xvoptions(["Low", "Middle", "High"])),
      5 : ("Amp Bass", defaultRangeParam),
      6 : ("Amp Middle", defaultRangeParam),
      7 : ("Amp Treble", defaultRangeParam),
      8 : ("Amp Presence", defaultRangeParam),
      9 : ("Amp Bright", offOnParam),
      10 : ("Speaker", offOnParam),
      11 : ("Sp Type", speakerSimParam),
      12 : ("Mic Setting", xvrange(1...3)),
      13 : ("Mic Level", defaultRangeParam),
      14 : ("Direct Level", defaultRangeParam),
      15 : ("Pan", panParam),
      16 : ("Level", defaultRangeParam),
      ], dests: [2,3,15,16])
    static let stOverdrive = Self.init(name: "Stereo OD", params: [
      0 : ("Drive", defaultRangeParam),
      1 : ("Tone", defaultRangeParam),
      2 : ("Amp", offOnParam),
      3 : ("Amp Type", ampSimpleParam),
      4 : ("Low Gain", gainParam),
      5 : ("High Gain", gainParam),
      6 : ("Level", defaultRangeParam)
      ], dests: [0])
    static let stDistortion = Self.init(name: "Stereo Dist", params: stOverdrive.params, dests: stOverdrive.dests)
    static let gtrMultiA = Self.init(name: "Gtr Multi A", params: [
      0 : ("Compressor", offOnParam),
      1 : ("Attack", defaultRangeParam),
      2 : ("Sustain", defaultRangeParam),
      3 : ("Cmp Level", defaultRangeParam),
      4 : ("OD/Dist", offOnParam),
      5 : ("Type", odDistParam),
      6 : ("Drive", defaultRangeParam),
      7 : ("Tone", defaultRangeParam),
      8 : ("Level", defaultRangeParam),
      9 : ("Amp Simulator", offOnParam),
      10 : ("Type", ampSimpleParam),
      11 : ("Delay", offOnParam),
      12 : ("Time L", delayTime3000Param),
      13 : ("Time R", delayTime3000Param),
      14 : ("Feedback", fdbkParam),
      15 : ("HF Damp", fx200to8kBypassParam),
      16 : ("Dly Balance", balanceParam),
      17 : ("Cho/Flg", offOnParam),
      18 : ("Type", choFlgParam),
      19 : ("PreDly", delayTime100Param),
      20 : ("Rate", phaserRateOptions),
      21 : ("Depth", defaultRangeParam),
      22 : ("Feedback", fdbkParam),
      23 : ("Filter", filterTypeParam),
      24 : ("Cutoff", fx200to8kParam),
      25 : ("C/F Balance", balanceParam),
      26 : ("Pan", panParam),
      27 : ("Out Level", defaultRangeParam),
      ], dests: [3,6,16,25])
    static let gtrMultiB = Self.init(name: "Gtr Multi B", params: [
      0 : ("Compressor", offOnParam),
      1 : ("Attack", defaultRangeParam),
      2 : ("Sustain", defaultRangeParam),
      3 : ("Cmp Level", defaultRangeParam),
      4 : ("OD/Dist", offOnParam),
      5 : ("Type", odDistParam),
      6 : ("Drive", defaultRangeParam),
      7 : ("Tone", defaultRangeParam),
      8 : ("Level", defaultRangeParam),
      9 : ("Amp Simulator", offOnParam),
      10 : ("Type", ampSimpleParam),
      11 : ("EQ", offOnParam),
      12 : ("Low Gain", gainParam),
      13 : ("Mid Freq", fx200to8kParam),
      14 : ("Mid Q", midQParam),
      15 : ("Mid Gain", gainParam),
      16 : ("High Gain", gainParam),
      17 : ("Cho/Flg", offOnParam),
      18 : ("Type", choFlgParam),
      19 : ("PreDly", defaultRangeParam),
      20 : ("Rate", phaserRateOptions),
      21 : ("Depth", defaultRangeParam),
      22 : ("Feedback", fdbkParam),
      23 : ("Filter", filterTypeParam),
      24 : ("Cutoff", fx200to8kParam),
      25 : ("C/F Balance", balanceParam),
      26 : ("Pan", panParam),
      27 : ("Out Level", defaultRangeParam),
      ], dests: [3,6,25])
    static let gtrMultiC = Self.init(name: "Gtr Multi C", params: [
      0 : ("OD/Dist", offOnParam),
      1 : ("Type", odDistParam),
      2 : ("Drive", defaultRangeParam),
      3 : ("Tone", defaultRangeParam),
      4 : ("Level", defaultRangeParam),
      5 : ("Wah", offOnParam),
      6 : ("Wah Filter", xvoptions(["LPF", "BPF"])),
      7 : ("Rate", phaserRateOptions),
      8 : ("Depth", defaultRangeParam),
      9 : ("Sens", defaultRangeParam),
      10 : ("Manual", defaultRangeParam),
      11 : ("Peak", defaultRangeParam),
      12 : ("Amp Simulator", offOnParam),
      13 : ("Type", ampSimpleParam),
      14 : ("Delay", offOnParam),
      15 : ("Time L", delayTime3000Param),
      16 : ("Time R", delayTime3000Param),
      17 : ("Feedback", fdbkParam),
      18 : ("HF Damp", fx200to8kBypassParam),
      19 : ("Dly Bal", balanceParam),
      20 : ("Cho/Flg", offOnParam),
      21 : ("Type", choFlgParam),
      22 : ("PreDly", delayTime100Param),
      23 : ("Rate", phaserRateOptions),
      24 : ("Depth", defaultRangeParam),
      25 : ("Feedback", fdbkParam),
      26 : ("Filter", filterTypeParam),
      27 : ("Cutoff", fx200to8kParam),
      28 : ("C/F Balance", balanceParam),
      29 : ("Pan", panParam),
      30 : ("Out Level", defaultRangeParam),
      ], dests: [2,10,19,28])
    static let clGtrMltA = Self.init(name: "Cl Gtr Mlt A", params: [
      0 : ("Compressor", offOnParam),
      1 : ("Attack", defaultRangeParam),
      2 : ("Sustain", defaultRangeParam),
      3 : ("Cmp Level", defaultRangeParam),
      4 : ("EQ", offOnParam),
      5 : ("Low Gain", gainParam),
      6 : ("Mid Freq", fx200to8kParam),
      7 : ("Mid Q", midQParam),
      8 : ("Mid Gain", gainParam),
      9 : ("High Gain", gainParam),
      10 : ("Delay", offOnParam),
      11 : ("Time L", delayTime3000Param),
      12 : ("Time R", delayTime3000Param),
      13 : ("Feedback", fdbkParam),
      14 : ("HF Damp", fx200to8kBypassParam),
      15 : ("Dly Balance", balanceParam),
      16 : ("Cho/Flg", offOnParam),
      17 : ("Type", choFlgParam),
      18 : ("PreDly", delayTime100Param),
      19 : ("Rate", phaserRateOptions),
      20 : ("Depth", defaultRangeParam),
      21 : ("Feedback", fdbkParam),
      22 : ("Filter", filterTypeParam),
      23 : ("Cutoff", fx200to8kParam),
      24 : ("C/F Balance", balanceParam),
      25 : ("Pan", panParam),
      26 : ("Out Level", defaultRangeParam),
      ], dests: [3,15,24])
    static let clGtrMltB = Self.init(name: "Cl Gtr Mlt B", params: [
      0 : ("Wah", offOnParam),
      1 : ("Wah Filter", xvoptions(["LPF", "BPF"])),
      2 : ("Rate", phaserRateOptions),
      3 : ("Depth", defaultRangeParam),
      4 : ("Sens", defaultRangeParam),
      5 : ("Manual", defaultRangeParam),
      6 : ("Peak", defaultRangeParam),
      7 : ("EQ", offOnParam),
      8 : ("Low Gain", gainParam),
      9 : ("Mid Freq", fx200to8kParam),
      10 : ("Mid Q", midQParam),
      11 : ("Mid Gain", gainParam),
      12 : ("High Gain", gainParam),
      13 : ("Delay", offOnParam),
      14 : ("Time L", delayTime3000Param),
      15 : ("Time R", delayTime3000Param),
      16 : ("Feedback", fdbkParam),
      17 : ("HF Damp", fx200to8kBypassParam),
      18 : ("Dly Balance", balanceParam),
      19 : ("Cho/Flg", offOnParam),
      20 : ("Type", choFlgParam),
      21 : ("PreDly", delayTime100Param),
      22 : ("Rate", phaserRateOptions),
      23 : ("Depth", defaultRangeParam),
      24 : ("Feedback", fdbkParam),
      25 : ("Filter", filterTypeParam),
      26 : ("Cutoff", fx200to8kParam),
      27 : ("C/F Balance", balanceParam),
      28 : ("Pan", panParam),
      29 : ("Out Level", defaultRangeParam),
      ], dests: [5,18,27])
    static let bassMulti = Self.init(name: "Bass Multi", params: [
      0 : ("Compressor", offOnParam),
      1 : ("Attack", defaultRangeParam),
      2 : ("Sustain", defaultRangeParam),
      3 : ("Cmp Level", defaultRangeParam),
      4 : ("OD/Dist", offOnParam),
      5 : ("Type", odDistParam),
      6 : ("Drive", defaultRangeParam),
      7 : ("Level", defaultRangeParam),
      8 : ("Amp Simulator", offOnParam),
      9 : ("Type", xvoptions(["Small", "Built-in", "2 Stack"])),
      10 : ("EQ", offOnParam),
      11 : ("Low Gain", gainParam),
      12 : ("Mid Freq", fx200to8kParam),
      13 : ("Mid Q", midQParam),
      14 : ("Mid Gain", gainParam),
      15 : ("High Gain", gainParam),
      16 : ("Cho/Flg", offOnParam),
      17 : ("Type", choFlgParam),
      18 : ("PreDly", delayTime100Param),
      19 : ("Rate", phaserRateOptions),
      20 : ("Depth", defaultRangeParam),
      21 : ("Feedback", fdbkParam),
      22 : ("Filter", filterTypeParam),
      23 : ("Cutoff", fx200to8kParam),
      24 : ("C/F Balance", balanceParam),
      25 : ("Pan", panParam),
      26 : ("Out Level", defaultRangeParam),
      ], dests: [3,6,24])
    static let isolator2 = Self.init(name: "Isolator 2", params: [
      0 : ("Level High", isolatorGainParam),
      1 : ("Level Middle", isolatorGainParam),
      2 : ("Level Low", isolatorGainParam),
      3 : ("AntiPhase Mid", offOnParam),
      4 : ("AntiPhase MidLev", defaultRangeParam),
      5 : ("AntiPhase Low", offOnParam),
      6 : ("AntiPhase Lo Lev", defaultRangeParam),
      7 : ("Filter Switch", offOnParam),
      8 : ("Filter", xvoptions(["LPF","BPF","HPF","Notch"])),
      9 : ("Filter Slope", xvoptions(["-12","-24"])),
      10 : ("Cutoff", defaultRangeParam),
      11 : ("Resonance", defaultRangeParam),
      12 : ("Filter Gain", xvrange(0...24)),
      13 : ("Low Boost", offOnParam),
      14 : ("Low Boost Level", defaultRangeParam),
      15 : ("Level", defaultRangeParam)
      ], dests: [0,1,2])
    static let stSpectrum = Self.init(name: "St Spectrum", params: [
      0 : ("250Hz", gainParam),
      1 : ("500Hz", gainParam),
      2 : ("1000Hz", gainParam),
      3 : ("1250Hz", gainParam),
      4 : ("2000Hz", gainParam),
      5 : ("3150Hz", gainParam),
      6 : ("4000Hz", gainParam),
      7 : ("8000Hz", gainParam),
      8 : ("Band Width Q", midQParam),
      9 : ("Level", defaultRangeParam)
      ], dests: [9])
    static let threeDAutoSpin = Self.init(name: "3D Auto Spin", params: [
      0 : ("Azimuth", azimuthParam),
      1 : ("Speed", phaserRateOptions),
      2 : ("Clockwise", xvoptions(["-","+"])),
      3 : ("Turn", offOnParam),
      4 : ("Output Mode", threeDOutParam),
      5 : ("Level", defaultRangeParam)
      ], dests: [1,3])
    static let threeDManual = Self.init(name: "3D Manual", params: [
      0 : ("Azimuth", azimuthParam),
      1 : ("Output Mode", threeDOutParam),
      2 : ("Level", defaultRangeParam)
      ], dests: [0])

    
  }
  
  enum Chorus {
    
    static func patchWerk(params: SynthPathParam) -> RolandSinglePatchTrussWerk {
      try! XV.sysexWerk.singlePatchWerk("Chorus", params, size: 0x34, start: 0x0400, randomize: { [
        [.level] : 127,
        [.out, .assign] : 0,
      ] })
    }
        
    static let chorusParams: [Int:(String,Param)] = [
      0 : ("Rate", FX.rateParam),
      1 : ("Depth", xvrange()),
      2 : ("PreDly", FX.delayTime100Param),
      3 : ("Feedback", xvrange()),
      4 : ("Filter", FX.filterTypeParam),
      5 : ("Cutoff", FX.fx200to8kParam),
      6 : ("Phase", FX.phaseParam),
    ]
    
    static let delayParams: [Int:(String,Param)] = [
      0 : ("Delay L", delayTimeParam),
      1 : ("Delay R", delayTimeParam),
      2 : ("Delay C", delayTimeParam),
      3 : ("Feedback", FX.fdbkParam),
      4 : ("HF Damp", FX.fx200to8kBypassParam),
      5 : ("L Level", xvrange()),
      6 : ("R Level", xvrange()),
      7 : ("C Level", xvrange()),
      ]
    
    static let gm2Params: [Int:(String,Param)] = [
      0 : ("Level", xvrange()),
      1 : ("Feedback", xvrange()),
      2 : ("Pre-LPF", xvrange(0...127)),
      3 : ("Delay", xvrange()),
      4 : ("Rate", xvrange()),
      5 : ("Depth", xvrange()),
      6 : ("Reverb Send", xvrange()),
      ]
    
    static let paramMap: [[Int:(String,Param)]] = [
      [:],
      chorusParams,
      delayParams,
      gm2Params
    ]

    static let delayTimeParam = xvoptions(1001.map { "\($0)" } + FX.noteOptions)
  }

  enum Reverb {
    
    static func patchWerk(params: SynthPathParam) -> RolandSinglePatchTrussWerk {
      try! XV.sysexWerk.singlePatchWerk("Reverb", params, size: 0x53, start: 0x0600, randomize: { [
        [.level] : 127,
        [.out, .assign] : 0,
      ] })
    }
        
    static let reverbParams: [Int:(String,Param)] = [
      0 : ("Type", xvoptions(["Room 1","Room 2","Stage 1","Stage 2","Hall 1","Hall 2","Delay","Pan-Delay"])),
      1 : ("Time", xvrange()),
      2 : ("HF Damp", FX.fx200to8kBypassParam),
      3 : ("Feedback", xvrange()),
      ]
    
    static let srvParams: [Int:(String,Param)] = [
      0 : ("Pre Delay", FX.delayTime100Param),
      1 : ("Time", xvrange()),
      2 : ("Size", xvrange(1...8)),
      3 : ("High Cut", xvoptions(["160","200","250","320","400","500","640", "800","1000","1250","1600","2000","2500","3200","4000","5000","6400","8000","10000","12500","Bypass"])),
      4 : ("Density", xvrange()),
      5 : ("Diffusion", xvrange()),
      6 : ("LF Damp", xvoptions(["50","64","80","100","125","160", "200","250","320","400","500","640", "800","1000","1250","1600","2000","2500","3200","4000","Bypass"])),
      7 : ("LF Damp Gain", xvrange(-36...0)),
      8 : ("HF Damp", xvoptions(["4000","5000","6400","8000","10000","12500","Bypass"])),
      9 : ("HF Damp Gain", xvrange(-36...0)),
      ]

    static let gm2Params: [Int:(String,Param)] = [
      0 : ("Level", xvrange()),
      1 : ("Character", xvrange(0...7)),
      2 : ("Pre-LPF", xvrange(0...7)),
      3 : ("Time", xvrange()),
      4 : ("Dly Feedback", xvrange()),
      ]

    static let paramMap: [[Int:(String,Param)]] = [
      [:],
      reverbParams,
      srvParams,
      srvParams,
      srvParams,
      gm2Params
    ]
  }
  
}


func xvrange(_ r: ClosedRange<Int> = 0...127) -> RangeParam {
  let displayOffset = r.lowerBound - 32768
  let range = r.upperBound - r.lowerBound
  return RangeParam(range: 32768...(32768 + range), displayOffset: displayOffset)
}

func xvoptions(_ opts: [String]) -> RangeParam {
//  var o = [Int:String]()
//  opts.forEach { o[$0.key + 32768] = $0.value }
//  return OptionsParam(options: o)
  let rr = 32768...(opts.count + 32768 - 1)
  return MisoParam.make(range: rr, iso: Miso.options(opts, startIndex: 32768))
}

func xvmiso(_ r: ClosedRange<Int> = 0...127, _ iso: Iso<Float, Float>) -> RangeParam {
  let rr = (r.lowerBound + 32768)...(r.upperBound + 32768)
  return MisoParam.make(range: rr, iso: Miso.a(-32768) >>> iso)
}

func xvmiso(_ r: ClosedRange<Int> = 0...127, _ iso: Iso<Float, String>) -> RangeParam {
  let rr = (r.lowerBound + 32768)...(r.upperBound + 32768)
  return MisoParam.make(range: rr, iso: Miso.a(-32768) >>> iso)
}
