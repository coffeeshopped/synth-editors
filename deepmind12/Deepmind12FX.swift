
struct Deepmind12FX {
  
  static let routingLevels = [
    (max: [0, 0, 0, 150], defaults: [0, 0, 0, 100]), // 1
    (max: [150, 150, 0, 150], defaults: [50, 50, 0, 100]), // 2
    (max: [0, 150, 0, 150], defaults: [0, 50, 0, 50]), // 3
    (max: [150, 150, 150, 150], defaults: [25, 25, 25, 25]), // 4
    (max: [150, 150, 150, 150], defaults: [33, 33, 33, 100]), // 5
    (max: [0, 0, 150, 150], defaults: [0, 0, 50, 50]), // 6
    (max: [0, 150, 150, 150], defaults: [0, 33, 33, 33]), // 7
    (max: [0, 0, 150, 150], defaults: [0, 0, 50, 50]), // 8
    (max: [0, 85, 0, 150], defaults: [0, 1, 0, 100]), // 9
    (max: [0, 0, 85, 150], defaults: [0, 0, 1, 100]), // 10
  ]
  
  // MARK: FX Params
  
  static let params = [
    nilParams,
    hallParams,
    plateParams,
    richPlateParams,
    ambientParams,
    gatedParams,
    reverseParams,
    rackParams,
    moodParams,
    phaserParams,
    chorusParams,
    flangerParams,
    modDelayParams,
    delayParams,
    tap3Params,
    tap4Params,
    rotaryParams,
    chorusDParams,
    enhancerParams,
    edisonParams,
    panParams,
    tRayParams,
    deepParams,
    fVerbParams,
    cVerbParams,
    dVerbParams,
    chamVerbParams,
    roomParams,
    vintageParams,
    dualParams,
    midasParams,
    fairParams,
    multiBandParams,
    noiseParams,
    decimParams,
    vPitchParams
  ]
 

  static let paramDefaults: [[Int]] = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [10, 25, 30, 10, 25, 50, 10, 35, 25, 25, 25, 10],
    [32, 29, 49, 23, 25, 50, 13, 48, 30, 30, 20, 3],
    [5, 25, 27, 15, 25, 50, 20, 30, 20, 9, 13, 10],
    [8, 10, 28, 10, 25, 50, 10, 30, 10, 25, 13, 10],
    [4, 15, 6, 22, 30, 50, 15, 30, 24, 25, 13, 10],
    [15, 40, 14, 25, 34, 50, 15, 15, 36, 25, 13, 10],
    [20, 20, 20, 20, 20, 20, 20, 20, 1, 25, 13, 10],
    [55, 21, 10, 40, 2, 50, 1, 45, 2, 20, 38, 1],
    [50, 26, 22, 14, 2, 50, 5, 0, 20, 10, 15, 15],
    [50, 12, 12, 30, 28, 50, 15, 30, 20, 20, 20, 15],
    [60, 15, 15, 11, 11, 50, 20, 40, 36, 15, 40, 29],
    [80, 0, 25, 35, 5, 82, 1, 1, 10, 30, 20, 50],
    [50, 80, 1, 4, 4, 100, 0, 50, 10, 15, 15, 50],
    [13, 38, 20, 0, 7, 35, 39, 8, 32, 2, 0, 50],
    [90, 50, 15, 5, 4, 25, 7, 25, 8, 25, 0, 50],
    [30, 60, 17, 0, 12, 50, 0, 0, 8, 25, 0, 50],
    [1, 1, 50, 1, 0, 1, 0, 0, 8, 25, 0, 50],
    [24, 11, 8, 11, 8, 25, 6, 40, 0, 25, 0, 50],
    [1, 0, 0, 25, 25, 25, 25, 24, 0, 25, 0, 50],
    [40, 36, 10, 10, 0, 0, 10, 10, 40, 25, 0, 50],
    [50, 36, 50, 10, 25, 0, 10, 10, 40, 25, 0, 50],
    [1, 30, 50, 25, 50, 0, 10, 10, 40, 25, 0, 50],
    [50, 15, 25, 25, 32, 18, 14, 35, 24, 40, 15, 50],
    [40, 15, 30, 36, 20, 25, 10, 35, 40, 40, 20, 50],
    [80, 5, 30, 20, 20, 20, 50, 20, 26, 40, 20, 50],
    [28, 25, 30, 10, 25, 50, 15, 25, 26, 33, 20, 10],
    [0, 25, 36, 10, 25, 50, 15, 25, 26, 33, 20, 10],
    [5, 50, 20, 50, 50, 20, 20, 50, 20, 50, 50, 0],
    [19, 50, 25, 50, 10, 50, 0, 50, 25, 50, 30, 40],
    [32, 51, 32, 51, 25, 32, 51, 25, 32, 51, 1, 40],
    [1, 24, 50, 2, 25, 20, 30, 24, 50, 2, 25, 20],
    [50, 1, 25, 17, 29, 22, 25, 38, 30, 12, 3, 25],
    [0, 0, 25, 37, 10, 6, 0, 0, 30, 12, 3, 25],
    [50, 80, 34, 4, 4, 0, 100, 30, 0, 15, 15, 1],
    [19, 50, 25, 0, 10, 50, 0, 50, 25, 0, 30, 40],
  ]
    
  // label, param, maps to mod, default value
  static let nilParams : [(String, Param, Bool)] =  []

  
  static let preDelayParam = MisoParam.make(maxVal: 100, iso: Miso.m(2) >>> Miso.unitFormat("ms"))
  static let sizeParam = MisoParam.make(maxVal: 49, iso: Miso.a(1) >>> Miso.m(2))
  static let diffuseParam = MisoParam.make(maxVal: 29, iso: Miso.lerp(in: 0...29, out: 0...100) >>> Miso.round(1) >>> Miso.unitFormat("%"))
  
  static let damp24Param = MisoParam.make(maxVal: 24, iso: Miso.exponReg(a: 999.9892075660891, b: 0.1248226469679754, c: -0.006134322692897399) >>> Miso.round())
  // 10...500hz
  static let lo50Param = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 9.995678061950098, b: 0.07824961331340263, c: -0.012710474545541207) >>> Miso.round())
  // 200...20000hz
  static let hi50Param = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 199.99977063268878, b: 0.0921034481697637, c: -0.021820445695600318) >>> Miso.round())
  static let bassMultParam = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 0.43324008581542467, b: 0.029858978551987388, c: 0.06773936848474907) >>> Miso.round(1))
  
  
//  "HallRev"
  static let hallParams : [(String, Param, Bool)] =  [
    ("PreDelay", preDelayParam, false),
    ("Decay", MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 0.21390803, b: 0.06302105, c: -0.07538552) >>> Miso.round(1)), true),
    ("Size", sizeParam, false),
    ("Damping", damp24Param, true),
    ("Diffusion", diffuseParam, false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiCut", hi50Param, true),
    ("BassMult", bassMultParam, true),
    ("Spread", RangeParam(maxVal: 50), false),
    ("Shape", MisoParam.make(maxVal: 50, iso: Miso.m(5)), true),
    ("ModSpeed", MisoParam.make(maxVal: 20, iso: Miso.m(5)), false),
    ]
  
//  "PlateRev"
  static let plateParams : [(String, Param, Bool)] =  [
    ("PreDelay", preDelayParam, false),
    ("Decay", MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 0.4780798703874736, b: 0.06076763905116021, c: 0.023568315397179306) >>> Miso.round(1)), true),
    ("Size", sizeParam, false),
    ("Damping", damp24Param, true),
    ("Diffusion", diffuseParam, false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiCut", hi50Param, true),
    ("BassMult", bassMultParam, true),
    ("Xover", MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 9.988558586101, b: 0.07826311235823254, c: 0.011293376924562143) >>> Miso.round()), true),
    ("ModDepth", RangeParam(maxVal: 49, displayOffset: 1), false),
    ("ModSpeed", MisoParam.make(maxVal: 20, iso: Miso.m(5)), false),
    ]

  //  "RichPltRev"
  
  static let bassMult52Param = MisoParam.make(maxVal: 52, iso: Miso.exponReg(a: 0.21808123931702258, b: 0.05597102273162451, c: -0.008499224771133695) >>> Miso.round(1))
  static let expon03_28Param = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 0.29325690687658246, b: 0.09182758777171601, c: -0.008822275106450856) >>> Miso.round(1))
  
  static let richPlateParams : [(String, Param, Bool)] =  [
    ("PreDelay", preDelayParam, false),
    ("Decay", expon03_28Param, true),
    ("Size", RangeParam(maxVal: 35, displayOffset: 4), false),
    ("Damping", damp24Param, true),
    ("Diffusion", MisoParam.make(maxVal: 25, iso: Miso.m(4)), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiCut", hi50Param, true),
    ("BassMult", bassMult52Param, true),
    ("Spread", RangeParam(maxVal: 50), false),
    ("Attack", MisoParam.make(maxVal: 50, iso: Miso.m(2)), true),
    ("Spin", MisoParam.make(maxVal: 20, iso: Miso.m(5)), true),
    ]

//  "AmbVerb"
  static let ambientParams : [(String, Param, Bool)] =  [
    ("PreDelay", preDelayParam, false),
    ("Decay", MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 0.17007953744642032, b: 0.07502358057103246, c: 0.047469226562471344) >>> Miso.round(1)), true),
    ("Size", sizeParam, false),
    ("Damping", damp24Param, true),
    ("Diffusion", diffuseParam, false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiCut", hi50Param, true),
    ("Mod", MisoParam.make(maxVal: 50, iso: Miso.m(2)), false),
    ("TailGain", MisoParam.make(maxVal: 50, iso: Miso.m(2)), true),
    ]

  static let hiSvGainParam = MisoParam.make(maxVal: 60, iso: Miso.lerp(in: 0...60, out: -30...0) >>> Miso.round(1))
  
  static let gateDecayParam = MisoParam.make(maxVal: 50, iso: Miso.lerp(in: 50, out: 140...1000) >>> Miso.round())
//  "GatedRev"
  static let gatedParams : [(String, Param, Bool)] =  [
    ("PreDelay", preDelayParam, false),
    ("Decay", gateDecayParam, false),
    ("Attack", RangeParam(maxVal: 30), true),
    ("Density", RangeParam(maxVal: 49, displayOffset: 1), true),
    ("Spread", MisoParam.make(maxVal: 50, iso: Miso.m(2)), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiSvFreq", hi50Param, true),
    ("HiSvGain", hiSvGainParam, true),
    ("Diffusion", MisoParam.make(maxVal: 29, iso: Miso.lerp(in: 0...29, out: 0...100) >>> Miso.round(1)), false),
    ]

//  "Reverse"
  static let reverseParams : [(String, Param, Bool)] =  [
    ("PreDelay", preDelayParam, false),
    ("Decay", gateDecayParam, false),
    ("Rise", RangeParam(maxVal: 50), true),
    ("Diffusion", diffuseParam, false),
    ("Spread", MisoParam.make(maxVal: 50, iso: Miso.m(2)), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiSvFreq", hi50Param, true),
    ("HiSvGain", hiSvGainParam, true),
    ]

  static let amp10Param = MisoParam.make(maxVal: 40, iso: Miso.m(0.25))
  static let onOffParam = MisoParam.make(maxVal: 1, iso: Miso.options(["Off", "On"]))
  
//  "RackAmp"
  static let rackParams : [(String, Param, Bool)] =  [
    ("PreAmp", amp10Param, true),
    ("Buzz", amp10Param, true),
    ("Punch", amp10Param, true),
    ("Crunch", amp10Param, true),
    ("Drive", amp10Param, true),
    ("Level", amp10Param, true),
    ("Low", amp10Param, true),
    ("High", amp10Param, true),
    ("Cabinet", onOffParam, false),
    ]

  static let speedBarIso = Miso.options(["4", "3", "2", "1", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "3/64", "1/24", "1/32", "3/128", "1/48", "1/64"])

  static func speedParam(exponIso: Iso<Float,Float>) -> RangeParam {
    return MisoParam.make(maxVal: 100, iso: Miso.switcher([
      .range(0...19, speedBarIso)
    ], default: exponIso >>> Miso.round(1) >>> Miso.unitFormat("Hz")))
  }
  
  static let phaserSpeedParam = speedParam(exponIso: Miso.exponReg(a: 0.015032450831939622, b: 0.05813837521273746, c: -0.0390531046028622))
  
//  "MoodFilter"
  static let moodParams : [(String, Param, Bool)] =  [
    ("Speed", speedParam(exponIso: Miso.exponReg(a: 0.010912833281357448, b: 0.0751381593215924, c: -0.019294956077091825)), false),
    ("Depth", MisoParam.make(maxVal: 50, iso: Miso.m(2)), true),
    ("Reson", MisoParam.make(maxVal: 20, iso: Miso.m(5)), true),
    ("Base Freq", MisoParam.make(maxVal: 100, iso: Miso.exponReg(a: 19.99899940804816, b: 0.06620124127712469, c: -0.008998640763936621) >>> Miso.round()), true),
    ("Type LP", OptionsParam(options: ["LP", "HP", "BP", "Notch"]), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("Wave", OptionsParam(options: ["Tri", "Sin", "Saw", "Saw-", "Ramp", "Sqr", "Rand"]), false),
    ("EnvMod", MisoParam.make(maxVal: 100, iso: Miso.lerp(in: 0...100, out: -100...100)), true),
    ("Attack", MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 9.98538478146448, b: 0.06440020157759492, c: -0.007670822042129593) >>> Miso.round(1)), true),
    ("Release", MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 9.9904367683595, b: 0.07825895507382523, c: 0.015076079332917713) >>> Miso.round(1)), true),
    ("Drive", MisoParam.make(maxVal: 50, iso: Miso.m(2)), true),
    ("Poles", OptionsParam(options: ["2P", "4P"]), false),
    ]

  static let percBy2Param = MisoParam.make(maxVal: 50, iso: Miso.m(2))
  static let percBy5Param = MisoParam.make(maxVal: 20, iso: Miso.m(5))

  static let phaseBy5Param = MisoParam.make(maxVal: 36, iso: Miso.m(5))
  
  // 10...1000
  static let exp10_1000Param = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 9.992804291875888, b: 0.09211747539862251, c: 0.01354973415835738) >>> Miso.round())
  static let exp1_2000Param = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 0.9999385962384656, b: 0.1520196199510182, c: -0.04011821745428053) >>> Miso.round(1))

//  "Phaser"
  static let phaserParams : [(String, Param, Bool)] =  [
    ("Speed", phaserSpeedParam, true),
    ("Depth", percBy2Param, true),
    ("Reson", MisoParam.make(maxVal: 40, iso: Miso.m(2)), true),
    ("Base Freq", MisoParam.make(maxVal: 25, iso: Miso.m(2)), true),
    ("Stages", RangeParam(maxVal: 10, displayOffset: 2), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("Wave", MisoParam.make(maxVal: 20, iso: Miso.lerp(in: 0...20, out: -50...50)), false),
    ("Phase", phaseBy5Param, false),
    ("EnvMod", MisoParam.make(maxVal: 40, iso: Miso.lerp(in: 0...40, out: -100...100)), true),
    ("Attack", exp10_1000Param, true),
    ("Hold", exp1_2000Param, true),
    ("Release", exp10_1000Param, true),
    ]

  static let exp05_50Param = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 0.4976573653672561, b: 0.09220235763833738, c: -0.018822708946795802) >>> Miso.round(1))
  
//  "Chorus"
  static let chorusParams : [(String, Param, Bool)] =  [
    ("Speed", phaserSpeedParam, true),
    ("WidthL", percBy5Param, true),
    ("WidthR", percBy5Param, true),
    ("DelayL", exp05_50Param, false),
    ("DelayR", exp05_50Param, false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiCut", hi50Param, true),
    ("Phase", phaseBy5Param, false),
    ("Wave", percBy5Param, false),
    ("Spread", percBy5Param, true),
    ]

  static let exp05_20Param = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 0.4898886498391159, b: 0.07419714330563737, c: -0.01047168388352473) >>> Miso.round(1))

//  "Flanger"
  static let flangerParams : [(String, Param, Bool)] =  [
    ("Speed", phaserSpeedParam, true),
    ("WidthL", percBy5Param, true),
    ("WidthR", percBy5Param, true),
    ("DelayL", exp05_20Param, false),
    ("DelayR", exp05_20Param, false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiCut", hi50Param, true),
    ("Phase", phaseBy5Param, false),
    ("FeedLC", lo50Param, true),
    ("FeedHC", hi50Param, true),
    ("Feed", MisoParam.make(maxVal: 36, iso: Miso.lerp(in: 0...36, out: -90...90)), true),
    ]

  static let time1500Param =  MisoParam.make(maxVal: 254, iso: Miso.switcher([
    .range(0...19, speedBarIso)
  ], default: Miso.lerp(in: 254, out: 1...1500) >>> Miso.round(1) >>> Miso.unitFormat("ms")))

  static let expon0_10HzParam = MisoParam.make(maxVal: 100, iso: Miso.exponReg(a: 0.046854873770971285, b: 0.0536228098280779, c: -0.007421968798031462) >>> Miso.round(1) >>> Miso.unitFormat("Hz"))
  static let expon1k_20kParam = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 999.9846694138073, b: 0.05991491518041261, c: 0.01581246261940027) >>> Miso.round())
  
//  "ModDlyRev"
  static let modDelayParams : [(String, Param, Bool)] =  [
    ("Time", time1500Param, false),
    ("Factor", MisoParam.make(options: ["1", "1/2", "2/3", "3/2"]), false),
    ("Feedback", percBy2Param, true),
    ("FeedHC", hi50Param, true),
    ("Depth", percBy5Param, true),
    ("Speed", expon0_10HzParam, true),
    ("Mode", MisoParam.make(options: ["Para", "Serial"]), false),
    ("Rtype", MisoParam.make(options: ["Ambi", "Club", "Hall"]), false),
    ("Decay", MisoParam.make(maxVal: 18, iso: Miso.lerp(in: 0...18, out: 1...10)), true),
    ("Damping", expon1k_20kParam, true),
    ("Balance", MisoParam.make(maxVal: 40, iso: Miso.lerp(in: 0...40, out: -100...100)), true),
    ("Mix", RangeParam(maxVal: 100), true),
    ]

  static let delayFactorParam = MisoParam.make(options: ["1/4", "3/8", "1/2", "2/3", "1", "4/3", "3/2", "2", "3"])
  
//  "Delay"
  static let delayParams : [(String, Param, Bool)] =  [
    ("Mix", RangeParam(maxVal: 100), true),
    ("Time", time1500Param, false),
    ("Mode", MisoParam.make(options: ["Stereo", "Cross", "Mono", "P/P"]), false),
    ("FactorL", delayFactorParam, false),
    ("FactorR", delayFactorParam, false),
    ("Offset", MisoParam.make(maxVal: 200, iso: Miso.lerp(in: 0...200, out: -100...100)), false),
    ("LC", lo50Param, true),
    ("HC", hi50Param, true),
    ("FeedLC", lo50Param, true),
    ("FeedL", percBy2Param, true),
    ("FeedR", percBy2Param, true),
    ("FeedHC", hi50Param, true),
    ]

  static let bipolarPercBy5Param = MisoParam.make(maxVal: 40, iso: Miso.lerp(in: 0...40, out: -100...100))
  
//  "3TapDelay"
  static let tap3Params : [(String, Param, Bool)] =  [
    ("Time", time1500Param, false),
    ("GainT", percBy2Param, true),
    ("PanT", bipolarPercBy5Param, true),
    ("Feedback", percBy2Param, true),
    ("FactorA", delayFactorParam, false),
    ("GainA", percBy2Param, true),
    ("PanA", bipolarPercBy5Param, true),
    ("FactorB", delayFactorParam, false),
    ("GainB", percBy2Param, true),
    ("PanB", bipolarPercBy5Param, true),
    ("X-Feed", onOffParam, false),
    ("Mix", RangeParam(maxVal: 100), true),
    ]

//  "4TapDelay"
  static let tap4Params : [(String, Param, Bool)] =  [
    ("Time", time1500Param, false),
    ("Gain", percBy2Param, true),
    ("Feedback", percBy2Param, true),
    ("Spread", RangeParam(maxVal: 6), false),
    ("FactorA", delayFactorParam, false),
    ("GainA", percBy2Param, true),
    ("FactorB", delayFactorParam, false),
    ("GainB", percBy2Param, true),
    ("FactorC", delayFactorParam, false),
    ("GainC", percBy2Param, true),
    ("X-Feed", onOffParam, false),
    ("Mix", RangeParam(maxVal: 100), true),
    ]

  
//  "RotarySpkr"
  static let rotaryParams : [(String, Param, Bool)] =  [
    ("LoSpeed", MisoParam.make(maxVal: 100, iso: Miso.exponReg(a: 0.09529795318949884, b: 0.03736653500389512, c: -0.012422978186783762) >>> Miso.round(1)), true),
    ("HiSpeed", MisoParam.make(maxVal: 100, iso: Miso.exponReg(a: 1.9549073442480336, b: 0.016251581998578835, c: 0.009975351117979004) >>> Miso.round(1)), true),
    ("Accel", percBy2Param, true),
    ("Distance", percBy2Param, true),
    ("Balance", bipolarPercBy5Param, true),
    ("Mix", RangeParam(maxVal: 100), true),
    ("Motor", MisoParam.make(options: ["Run", "Stop"]), true),
    ("Speed", MisoParam.make(options: ["Slow", "Fast"]), true),
    ]

//  "Chorus-D"
  static let chorusDParams : [(String, Param, Bool)] =  [
    ("On", onOffParam, false),
    ("Mode", MisoParam.make(options: ["Mono", "Ster"]), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("Sw1", onOffParam, false),
    ("Sw2", onOffParam, false),
    ("Sw3", onOffParam, false),
    ("Sw4", onOffParam, false),
    ]

//  "Enhancer"
  static let enhancerParams : [(String, Param, Bool)] =  [
    ("OutGain", MisoParam.make(maxVal: 48, iso: Miso.lerp(in: 48, out: -12...12)), true),
    ("Spread", percBy2Param, true),
    ("BassGain", percBy2Param, true),
    ("BassFreq", RangeParam(maxVal: 49, displayOffset: 1), true),
    ("MidGain", percBy2Param, true),
    ("MidQ", RangeParam(maxVal: 49, displayOffset: 1), true),
    ("HiGain", percBy2Param, true),
    ("HiFreq", RangeParam(maxVal: 49, displayOffset: 1), true),
    ("Solo", onOffParam, false),
    ]

  static let sterMSParam = MisoParam.make(options: ["Stereo", "M/S"])
  
  static let ed50Param = MisoParam.make(maxVal: 50, iso: Miso.lerp(in: 50, out: -50...50))
  
//  "EdisonEX1"
  static let edisonParams : [(String, Param, Bool)] =  [
    ("On", onOffParam, false),
    ("InMode", sterMSParam, false),
    ("OutMode", sterMSParam, false),
    ("StSpread", ed50Param, true),
    ("LMFSpread", ed50Param, true),
    ("Balance", ed50Param, true),
    ("CntrDist", ed50Param, true),
    ("Gain", MisoParam.make(maxVal: 48, iso: Miso.lerp(in: 48, out: -12...12)), true),
    ]

//  "Auto Pan"
  static let panParams : [(String, Param, Bool)] =  [
    ("Speed", phaserSpeedParam, true),
    ("Phase", phaseBy5Param, true),
    ("Wave", MisoParam.make(maxVal: 20, iso: Miso.lerp(in: 20, out: -50...50)), true),
    ("Depth", percBy5Param, true),
    ("EnvSpd", percBy5Param, true),
    ("EnvDepth", percBy5Param, true),
    ("Attack", exp10_1000Param, true),
    ("Hold", exp1_2000Param, true),
    ("Release", exp10_1000Param, true),
    ]

//  "T-RayDelay"
  static let tRayParams : [(String, Param, Bool)] =  [
    ("Mix", RangeParam(maxVal: 100), true),
    ("Delay", RangeParam(maxVal: 100), true),
    ("Sustain", RangeParam(maxVal: 100), true),
    ("Wobble", percBy2Param, true),
    ("Tone", percBy2Param, true),
    ]

//  "TC-DeepVRB"
  static let deepParams : [(String, Param, Bool)] =  [
    ("Preset", MisoParam.make(options: ["Ambi", "Church", "Gate", "Hall", "LoFi", "Mod", "Plate", "Room", "Spring", "Tile", "Deflt"]), false),
    ("Decay", MisoParam.make(maxVal: 100, iso: Miso.lerp(in: 100, out: 0...6)), true),
    ("Tone", RangeParam(maxVal: 100, displayOffset: -50), true),
    ("PreDelay", RangeParam(maxVal: 200), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ]
  
  static let fVerbSpeedParam = speedParam(exponIso: Miso.exponReg(a: 0.016528297544525984, b: 0.054939955609975444, c: -0.05206285150084605))

  static let exp01_5Param = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 0.08192868983453448, b: 0.08202474752263009, c: 0.036893303323509985) >>> Miso.round(1))

//  "FlangVerb"
  static let fVerbParams : [(String, Param, Bool)] =  [
    ("Speed", fVerbSpeedParam, true),
    ("Depth", percBy5Param, true),
    ("Delay", exp05_20Param, false),
    ("Phase", phaseBy5Param, true),
    ("Feed", MisoParam.make(maxVal: 36, iso: Miso.lerp(in: 36, out: -90...90)), true),
    ("Balance", bipolarPercBy5Param, true),
    ("PreDelay", MisoParam.make(maxVal: 100, iso: Miso.m(2)), false),
    ("Decay", exp01_5Param, true),
    ("Size", MisoParam.make(maxVal: 73, iso: Miso.lerp(in: 73, out: 2...100) >>> Miso.round(1)), false),
    ("Damping", expon1k_20kParam, true),
    ("LoCut", lo50Param, true),
    ("Mix", RangeParam(maxVal: 100), true),
    ]

//  "ChorusVerb"
  static let cVerbParams : [(String, Param, Bool)] =  [
    ("Speed", fVerbSpeedParam, true),
    ("Depth", percBy5Param, true),
    ("Delay", exp05_50Param, false),
    ("Phase", phaseBy5Param, true),
    ("Wave", percBy5Param, false),
    ("Balance", bipolarPercBy5Param, true),
    ("PreDelay", MisoParam.make(maxVal: 100, iso: Miso.m(2)), false),
    ("Decay", exp01_5Param, true),
    ("Size", MisoParam.make(maxVal: 49, iso: Miso.a(1) >>> Miso.m(2)), false),
    ("Damping", expon1k_20kParam, true),
    ("LoCut", lo50Param, true),
    ("Mix", RangeParam(maxVal: 100), true),
    ]

//  "DelayVerb"
  static let dVerbParams : [(String, Param, Bool)] =  [
    ("Time", time1500Param, false),
    ("Pattern", MisoParam.make(options: ["1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1", "1/4X", "1/3X", "3/8X", "1/2X", "2/3X", "3/4X", "1X"]), false),
    ("FeedHC", expon1k_20kParam, true),
    ("Feedback", percBy2Param, true),
    ("X-Feed", percBy2Param, true),
    ("Balance", bipolarPercBy5Param, true),
    ("PreDelay", MisoParam.make(maxVal: 100, iso: Miso.m(2)), false),
    ("Decay", exp01_5Param, true),
    ("Size", MisoParam.make(maxVal: 49, iso: Miso.a(1) >>> Miso.m(2)), false),
    ("Damping", expon1k_20kParam, true),
    ("LoCut", lo50Param, true),
    ("Mix", RangeParam(maxVal: 100), true),
    ]

  static let size76Param = MisoParam.make(maxVal: 36, iso: Miso.m(2) >>> Miso.a(4))
  
//  "ChamberRev"
  static let chamVerbParams : [(String, Param, Bool)] =  [
    ("PreDelay", MisoParam.make(maxVal: 254, iso: Miso.lerp(in: 254, out: 0...200)), false),
    ("Decay", expon03_28Param, true),
    ("Size", size76Param, false),
    ("Damping", damp24Param, true),
    ("Diffusion", MisoParam.make(maxVal: 25, iso: Miso.m(4)), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiCut", hi50Param, true),
    ("BassMult", bassMult52Param, true),
    ("Spread", RangeParam(maxVal: 50), false),
    ("Shape", MisoParam.make(maxVal: 50, iso: Miso.m(5)), true),
    ("Spin", percBy5Param, false),
    ]

//  "RoomRev"
  static let roomParams : [(String, Param, Bool)] =  [
    ("PreDelay", MisoParam.make(maxVal: 254, iso: Miso.lerp(in: 254, out: 0...200)), false),
    ("Decay", expon03_28Param, true),
    ("Size", size76Param, false),
    ("Damping", damp24Param, true),
    ("Diffusion", MisoParam.make(maxVal: 25, iso: Miso.m(4)), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("LoCut", lo50Param, true),
    ("HiCut", hi50Param, true),
    ("BassMult", bassMult52Param, true),
    ("Spread", RangeParam(maxVal: 50), false),
    ("Shape", MisoParam.make(maxVal: 50, iso: Miso.m(5)), true),
    ("Spin", percBy5Param, false),
    ]

  static let expon01_5Param = MisoParam.make(maxVal: 100, iso: Miso.exponReg(a: 0.08568530588457053, b: 0.04106685423440133, c: 0.010703237745041876) >>> Miso.round(1))
  static let exp01_10Param = MisoParam.make(maxVal: 100, iso: Miso.exponReg(a: 0.09304458146712752, b: 0.04676364046628023, c: 0.008466931203922933) >>> Miso.round(1))

//  "VintageRev"
  static let vintageParams : [(String, Param, Bool)] =  [
    ("PreDelay", MisoParam.make(maxVal: 100, iso: Miso.m(2)), false),
    ("Size", MisoParam.make(maxVal: 100, iso: Miso.lerp(in: 100, out: 1...100) >>> Miso.round(1)), false),
    ("Decay", expon01_5Param, true),
    ("LoMult", exp01_10Param, true),
    ("HiMult", exp01_10Param, true),
    ("Density", percBy2Param, true),
    ("LoCut", lo50Param, true),
    ("HiCut", hi50Param, true),
    ("ER Level", percBy2Param, true),
    ("ER Delay", MisoParam.make(maxVal: 100, iso: Miso.m(2)), false),
    ("Mix", RangeParam(maxVal: 100), true),
    ("Freeze", onOffParam, true),
    ]

  static let time1000Param =  MisoParam.make(maxVal: 100, iso: Miso.switcher([
    .range(0...19, speedBarIso)
  ], default: Miso.exponReg(a: 0.21138808854980815, b: 0.07768748458981915, c: -0.0393093095516102) >>> Miso.round(1) >>> Miso.str()))
  static let expon2k_20kParam = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 1999.9358201289442, b: 0.04605226917727954, c: 0.06430463896849212) >>> Miso.round())

//  "DualPitch"
  static let dualParams : [(String, Param, Bool)] =  [
    ("Semi1", RangeParam(maxVal: 24, displayOffset: -12), true),
    ("Cent1", RangeParam(maxVal: 100, displayOffset: -50), true),
    ("Delay1", time1000Param, false),
    ("Gain1", percBy2Param, true),
    ("Pan1", bipolarPercBy5Param, true),
    ("Mix", RangeParam(maxVal: 100), true),
    ("Semi2", RangeParam(maxVal: 24, displayOffset: -12), true),
    ("Cent2", RangeParam(maxVal: 100, displayOffset: -50), true),
    ("Delay2", time1000Param, false),
    ("Gain2", percBy2Param, true),
    ("Pan2", bipolarPercBy5Param, true),
    ("HiCut", expon2k_20kParam, true),
    ]

  static let midasGainParam = MisoParam.make(maxVal: 64, iso: Miso.lerp(in: 64, out: -16...16))
  
//  "MidasEQ"
  static let midasParams : [(String, Param, Bool)] =  [
    ("LoGain", midasGainParam, true),
    ("LoFreq", RangeParam(maxVal: 100), true),
    ("LoMidGain", midasGainParam, true),
    ("LoMidFreq", RangeParam(maxVal: 100), true),
    ("LoMidQ", RangeParam(maxVal: 100), true),
    ("HiMidGain", midasGainParam, true),
    ("HiMidFreq", RangeParam(maxVal: 100), true),
    ("HiMidQ", MisoParam.make(maxVal: 100, iso: Miso.lerp(in: 100, out: 0.3...5) >>> Miso.round(1)), true),
    ("HiGain", midasGainParam, true),
    ("HiFreq", RangeParam(maxVal: 100), true),
    ("EQ", MisoParam.make(options: ["Out", "In"]), true),
    ]

  static let fairGainParam = MisoParam.make(maxVal: 60, iso: Miso.lerp(in: 60, out: -20...10) >>> Miso.round(1))
  static let fairThreshParam = MisoParam.make(maxVal: 100, iso: Miso.m(0.1))
  static let fairOutGainParam = MisoParam.make(maxVal: 48, iso: Miso.lerp(in: 48, out: -18...6) >>> Miso.round(1))
  
//  "FairComp"
  static let fairParams : [(String, Param, Bool)] =  [
    ("Mode", MisoParam.make(options: ["Off", "Stereo", "Dual", "M/S"]), false),
    ("InGain L/M", fairGainParam, true),
    ("ThreshL/M", fairThreshParam, true),
    ("TimeL/M", RangeParam(maxVal: 5, displayOffset: 1), false),
    ("DCBiasL/M", percBy2Param, true),
    ("OutGainL/M", fairOutGainParam, true),
    ("Bias Bal", bipolarPercBy5Param, true),
    ("InGainR/S", fairGainParam, true),
    ("ThreshR/S", fairThreshParam, true),
    ("TimeR/S", RangeParam(maxVal: 5, displayOffset: 1), false),
    ("DCBiasR/S", percBy2Param, true),
    ("OutGainR/S", fairOutGainParam, true),
    ]

  static let multiBandLevelParam = MisoParam.make(maxVal: 50, iso: Miso.lerp(in: 100, out: -12...12) >>> Miso.round(1))
//  "MulBndDist"
  static let expon30_9kParam = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 29.99696531729295, b: 0.11407769243156143, c: 0.0018896466866326262) >>> Miso.round())
  
  static let multiBandParams : [(String, Param, Bool)] =  [
    ("InputGain", MisoParam.make(maxVal: 100, iso: Miso.lerp(in: 100, out: -24...24) >>> Miso.round(1)), true),
    ("DistType", MisoParam.make(options: ["Valve", "Satur", "Tube", "PostFiltV", "PostFiltS", "PostFiltT"]), false),
    ("Low Level", multiBandLevelParam, true),
    ("Low Drive", percBy2Param, true),
    ("Xover Freq 1", expon30_9kParam, true),
    ("Mid Level", multiBandLevelParam, true),
    ("Mid Drive", percBy2Param, true),
    ("Xover Freq 2", expon30_9kParam, true),
    ("High Level", multiBandLevelParam, true),
    ("High Drive", percBy2Param, true),
    ("Cabinet", MisoParam.make(options: ["V-Tweed", "V-Bass", "C-A10", "Mid-Cmb", "Blkfc", "Brt-60", "V-30", "Std-78", "Off-Ax", "C-A12", "Rack"]), false),
    ("Output Gain", multiBandLevelParam, true),
    ]

  static let expon2_2kParam = MisoParam.make(maxVal: 50, iso: Miso.exponReg(a: 1.9991419972335405, b: 0.1381629664637893, c: -0.02047297812039835) >>> Miso.round(1))
  
//  "NoiseGate"
  static let noiseParams : [(String, Param, Bool)] =  [
    ("Threshold", MisoParam.make(maxVal: 100, iso: Miso.lerp(in: 100, out: -50...0)), true),
    ("Range", RangeParam(maxVal: 100, displayOffset: -100), true),
    ("Attack", MisoParam.make(maxVal: 50, iso: Miso.lerp(in: 50, out: 0...20)), true),
    ("Release", expon2_2kParam, true),
    ("Hold", expon2_2kParam, true),
    ("Punch", RangeParam(maxVal: 12, displayOffset: -6), true),
    ("Mode", MisoParam.make(options: ["Gate", "Trans", "Duck"]), false),
    ("Power", MisoParam.make(options: ["On", "Off"]), false),
    ]

//  "DecimDelay"
  static let decimParams : [(String, Param, Bool)] =  [
    ("Mix", RangeParam(maxVal: 100), true),
    ("Time", time1500Param, false),
    ("Downsample", MisoParam.make(maxVal: 200, iso: Miso.lerp(in: 200, out: 0...100)), true),
    ("FactorL", delayFactorParam, false),
    ("FactorR", delayFactorParam, false),
    ("BitReduce", MisoParam.make(maxVal: 95, iso: Miso.lerp(in: 95, out: -24...(-1)) >>> Miso.m(-1) >>> Miso.round(1)), false),
    ("Cutoff", MisoParam.make(maxVal: 100, iso: Miso.exponReg(a: 29.999610654166837, b: 0.06502304711956343, c: -0.02937744979916914) >>> Miso.round()), true),
    ("Reson", RangeParam(maxVal: 100), true),
    ("Type", MisoParam.make(options: ["LP", "HP", "BP", "Notch"]), false),
    ("FeedL", percBy2Param, true),
    ("FeedR", percBy2Param, true),
    ("Decimate", MisoParam.make(options: ["Pre", "Post"]), false),
    ]

  static let time500Param =  MisoParam.make(maxVal: 100, iso: Miso.switcher([
    .range(0...19, speedBarIso)
  ], default: Miso.exponReg(a: 0.21138808854980815, b: 0.07768748458981915, c: -0.0393093095516102) >>> Miso.round(1) >>> Miso.str()))

//  "Vintage Pitch"
  static let vPitchParams : [(String, Param, Bool)] =  [
    ("Semi1", RangeParam(maxVal: 24, displayOffset: -12), true),
    ("Cent1", RangeParam(maxVal: 100, displayOffset: -50), true),
    ("Delay1", time500Param, false),
    ("Feedback1", RangeParam(maxVal: 100), true),
    ("Pan1", bipolarPercBy5Param, true),
    ("Mix", RangeParam(maxVal: 100), true),
    ("Semi2", RangeParam(maxVal: 24, displayOffset: -12), true),
    ("Cent2", RangeParam(maxVal: 100, displayOffset: -50), true),
    ("Delay2", time500Param, false),
    ("Feedback2", RangeParam(maxVal: 100), true),
    ("Pan2", bipolarPercBy5Param, true),
    ("HiCut", expon2k_20kParam, true),
    ]

}
