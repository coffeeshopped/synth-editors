const fxGainParam = RangeParam(range: 0...30, displayOffset: -15)
const fxHFDampParam = OptionsParam(options: reverbHFDampOptions)
const fx200to8kParam = OptionsParam(options: ["200", "250", "315", "400", "500", "630", "800", "1000", "1250", "1600", "2000", "2500", "3150", "4000", "5000", "6300", "8000"])
const fxQParam = OptionsParam(options: ["0.5", "1.0", "2.0", "4.0", "9.0" ])
const fxPanParam = RangeParam(displayOffset: -64)
const fxAmpParam = OptionsParam(options: ["Small","Built-in","2-Stack","3-Stack"])
const fxRateParam = OptionsParam(options: {
  var options = (0..<100).map { "\(Float($0+1) * 0.05)" }
  options += (100..<120).map { "\(5.0 + Float($0-99) * 0.1)" }
  options += (120..<126).map { "\(7.0 + Float($0-119) * 0.5)" }
  return options
}())
const fxCoarseParam = RangeParam(range: 0...36, displayOffset: -24)
const fxFineParam = OptionsParam(options: (0...100).map {"\($0*2 - 100)"})
const fxFdbkParam = OptionsParam(options: (0...98).map {"\($0*2 - 98)"})
const fxBalanceParam = OptionsParam(options: (0...100).map {"D\(100-$0):\($0)E"})
const fxDelayTime500Param = OptionsParam(options: {
  var options = (0..<50).map { "\(Float($0) * 0.1)" }
  options += (50..<60).map { "\(5.0 + Float($0-50) * 0.5)" }
  options += (60..<90).map { "\(10 + Float($0-60) * 1)" }
  options += (90..<116).map { "\(40 + Float($0-90) * 10)" }
  options += (116..<127).map { "\(300 + Float($0-116) * 20)" }
  return options
}())
const fxDelayTime100Param = OptionsParam(options: {
  var options = (0..<50).map { "\(Float($0) * 0.1)" }
  options += (50..<60).map { "\(5.0 + Float($0-50) * 0.5)" }
  options += (60..<100).map { "\(10 + Float($0-60) * 1)" }
  options += (100..<126).map { "\(50 + Float($0-90) * 2)" }
  return options
}())

// 200...1000ms, note
const fxDelayTime1000NoteParam = RangeParam(maxVal: 125, formatter: {
  switch $0 {
  case 0...69:
    return "\(200 + $0 * 5)"
  case 70...115:
    return "\(550 + ($0 - 70) * 10)"
  case 116...125:
    return ["16th", "8th trip", "Dot 16th", "8th", "1/4 trip", "Dot 8th", "1/4", "1/2 trip", "Dot 1/4", "1/2"][$0-116]
  default:
    return ""
  }
})

// 200...1000ms (no note)
const fxDelayTime1000Param = RangeParam(maxVal: 120, formatter: {
  switch $0 {
  case 0...79:
    return "\(200 + $0 * 5)"
  case 80...120:
    return "\(600 + ($0 - 80) * 10)"
  default:
    return ""
  }
})


const Pairs = {
  loFreq: ("Low-Freq", OptionsParam(options: ["200","400"]))
  hiFreq: ("High-Freq", OptionsParam(options: ["4000","8000"]))
  loGain: ("Low-Gain", fxGainParam)
  hiGain: ("High-Gain", fxGainParam)

  level: ("Level", RangeParam())
  drive: ("Drive", RangeParam())
  pan: ("Pan", fxPanParam)
  
  lfoRate: ("LFO-Rate", fxRateParam)
  lfoDepth: ("LFO-Depth", RangeParam())
  chorusRate: ("Cho-Rate", fxRateParam)
  chorusDepth: ("Cho-Depth", RangeParam())
  phaserRate: ("Pha-Rate", fxRateParam)
  phaserDepth: ("Pha-Depth", RangeParam())

  feedback: ("Feedback", fxFdbkParam)
  balance: ("Balance", fxBalanceParam)
  hfDamp: ("HF-Damp", fxHFDampParam)
  
  filterType: ("Filter-Type", OptionsParam(options: ["Off","LPF","HPF"]))
}

const fxParams: [[Int:(String,Param)]] = [
  eqParams,
  overdriveParams,
  distortionParams,
  phaserParams,
  spectrumParams,
  enhancerParams,
  autowahParams,
  rotaryParams,
  compressorParams,
  limiterParams,
  hexaChorusParams,
  tremChorusParams,
  spaceDParams,
  chorusParams,
  flangerParams,
  stepFlangerParams,
  stDelayParams,
  modDelayParams,
  tripleDelayParams,
  quadDelayParams,
  timeCtrlDelayParams,
  duoPitchShiftParams,
  feedbackPitchShiftParams,
  reverbParams,
  gateVerbParams,
  odChorusParams,
  odFlangerParams,
  odDelayParams,
  distChorusParams,
  distFlangerParams,
  distDelayParams,
  enhanceChorusParams,
  enhanceFlangerParams,
  enhanceDelayParams,
  chorusDelayParams,
  flangerDelayParams,
  chorusFlangerParams,
  chorusAndDelayParams,
  flangerAndDelayParams,
  chorusAndFlangerParams,
  ]

const eqParams = [
  Pairs.loFreq,
  Pairs.loGain,
  Pairs.hiFreq,
  Pairs.hiGain,
  ("P1-Freq", fx200to8kParam),
  ("P1-Q", fxQParam),
  ("P1-Gain", fxGainParam),
  ("P2-Freq", fx200to8kParam),
  ("P2-Q", fxQParam),
  ("P2-Gain", fxGainParam),
  ("Level", RangeParam())
]

const overdriveParams = [
  Pairs.drive,
  Pairs.pan,
  ("Amp-Type", fxAmpParam),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const distortionParams = [
  Pairs.drive,
  Pairs.pan,
  ("Amp-Type", fxAmpParam),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const phaserParams = [
  ("Manual", RangeParam()),
  Pairs.phaserRate,
  Pairs.phaserDepth,
  ("Resonance", RangeParam()),
  ("Mix", RangeParam()),
  Pairs.pan,
  Pairs.level
]
const spectrumParams = [
  ("Band-1", fxGainParam),
  ("Band-2", fxGainParam),
  ("Band-3", fxGainParam),
  ("Band-4", fxGainParam),
  ("Band-5", fxGainParam),
  ("Band-6", fxGainParam),
  ("Band-7", fxGainParam),
  ("Band-8", fxGainParam),
  ("Width", RangeParam(maxVal: 4, displayOffset: 1)),
  Pairs.pan,
  Pairs.level
]
const enhancerParams = [
  ("Sens", RangeParam()),
  ("Mix", RangeParam()),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const autowahParams = [
  ("Filter-Type", OptionsParam(options: ["LPF","BPF"])),
  Pairs.lfoRate,
  Pairs.lfoDepth,
  ("Sens", RangeParam()),
  ("Manual", RangeParam()),
  ("Peak", RangeParam()),
  Pairs.level
]
const rotaryParams = [
  ("Hi-Slow", fxRateParam),
  ("Low-Slow", fxRateParam),
  ("Hi-Fast", fxRateParam),
  ("Low-Fast", fxRateParam),
  ("Speed", OptionsParam(options: ["Slow","Fast"])),
  ("Hi-Accl", RangeParam(maxVal: 15)),
  ("Low-Accl", RangeParam(maxVal: 15)),
  ("Hi-Level", RangeParam()),
  ("Low-Level", RangeParam()),
  ("Separation", RangeParam()),
  Pairs.level
]
const compressorParams = [
  ("Sustain", RangeParam()),
  ("Attack", RangeParam()),
  Pairs.pan,
  ("Post-Gain", OptionsParam(options: ["x1","x2","x4","x8"])),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const limiterParams = [
  ("Threshold", RangeParam()),
  ("Release", RangeParam()),
  ("Ratio", OptionsParam(options: ["1.5:1","2:1","4:1","100:1"])),
  Pairs.pan,
  ("Post-Gain", OptionsParam(options: ["x1","x2","x4","x8"])),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const hexaChorusParams = [
  ("Pre-Delay", fxDelayTime100Param),
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ("PreDelay-Dev", RangeParam()),
  ("Depth-Dev", RangeParam()),
  ("Pan-Dev", RangeParam()),
  Pairs.balance,
  Pairs.level
]
const tremChorusParams = [
  ("Pre-Delay", fxDelayTime100Param),
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ("Tremolo-Rate", fxRateParam),
  ("Tremolo-Sep", RangeParam()),
  ("Phase", RangeParam()),
  Pairs.balance,
  Pairs.level
]
const spaceDParams = [
  ("Pre-Delay", fxDelayTime100Param),
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ("Phase", RangeParam()),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const chorusParams = [
  Pairs.filterType,
  ("Cutoff", RangeParam()),
  ("Pre-Delay", fxDelayTime100Param),
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ("Phase", RangeParam()),
  (),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const flangerParams = [
  Pairs.filterType,
  ("Cutoff", RangeParam()),
  ("Pre-Delay", fxDelayTime100Param),
  Pairs.lfoRate,
  Pairs.lfoDepth,
  ("Phase", RangeParam()),
  Pairs.feedback,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const stepFlangerParams = [
  ("Pre-Delay", fxDelayTime100Param),
  Pairs.lfoRate,
  Pairs.lfoDepth,
  Pairs.feedback,
  ("Step-Rate", RangeParam()),
  ("Phase", RangeParam()),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const stDelayParams = [
  ("FBK-Mode", RangeParam()),
  ("Delay-Time-L", fxDelayTime500Param),
  ("Delay-Time-R", fxDelayTime500Param),
  ("Phase-L", RangeParam()),
  ("Phase-R", RangeParam()),
  Pairs.feedback,
  Pairs.hfDamp,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const modDelayParams = [
  ("FBK-Mode", RangeParam()),
  ("Delay-Time-L", fxDelayTime500Param),
  ("Delay-Time-R", fxDelayTime500Param),
  Pairs.feedback,
  Pairs.hfDamp,
  ("Mod-Rate", fxRateParam),
  ("Mod-Depth", RangeParam()),
  ("Phase", RangeParam()),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const tripleDelayParams = [
  ("Delay-Time-L", fxDelayTime1000NoteParam),
  ("Delay-Time-R", fxDelayTime1000NoteParam),
  ("Delay-C", fxDelayTime1000NoteParam),
  Pairs.feedback,
  Pairs.hfDamp,
  ("Level-L", RangeParam()),
  ("Level-R", RangeParam()),
  ("Level-C", RangeParam()),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
coquadDelayParams = [
  ("Delay-1", fxDelayTime1000NoteParam),
  ("Delay-2", fxDelayTime1000NoteParam),
  ("Delay-3", fxDelayTime1000NoteParam),
  ("Delay-4", fxDelayTime1000NoteParam),
  ("Level-1", RangeParam()),
  ("Level-2", RangeParam()),
  ("Level-3", RangeParam()),
  ("Level-4", RangeParam()),
  Pairs.feedback,
  Pairs.hfDamp,
  Pairs.balance,
  Pairs.level
]
const timeCtrlDelayParams = [
  ("Delay", fxDelayTime1000Param),
  Pairs.feedback,
  ("Accel", RangeParam()),
  Pairs.hfDamp,
  Pairs.pan,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const duoPitchShiftParams = [
  ("Mode", RangeParam(maxVal: 4, displayOffset: 1)),
  ("Coarse-A", fxCoarseParam),
  ("Coarse-B", fxCoarseParam),
  ("Fine-A", fxFineParam),
  ("Fine-B", fxFineParam),
  ("Pre-Delay-A", fxDelayTime500Param),
  ("Pre-Delay-B", fxDelayTime500Param),
  ("Pan-A", fxPanParam),
  ("Pan-B", fxPanParam),
  ("Level-Balance", RangeParam()),
  Pairs.balance,
  Pairs.level
]
const feedbackPitchShiftParams = [
  ("Mode", RangeParam(maxVal: 4, displayOffset: 1)),
  ("Coarse", fxCoarseParam),
  ("Fine", fxFineParam),
  ("Pre-Delay", fxDelayTime500Param),
  Pairs.feedback,
  Pairs.pan,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const reverbParams = [
  ("Type", RangeParam()),
  ("Pre-Delay", fxDelayTime100Param),
  ("Reverb-Time", RangeParam()),
  Pairs.hfDamp,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const gateVerbParams = [
  ("Type", RangeParam()),
  ("Pre-Delay", fxDelayTime100Param),
  ("Gate-Time", RangeParam()),
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const odChorusParams = [
  Pairs.drive,
  Pairs.pan,
  ("Pre-Delay", fxDelayTime100Param),
  ("Rate", fxRateParam),
  ("Depth", RangeParam()),
  (),
  Pairs.balance,
  Pairs.level
]
const odFlangerParams = [
  Pairs.drive,
  Pairs.pan,
  ("Pre-Delay", fxDelayTime100Param),
  ("Rate", fxRateParam),
  ("Depth", RangeParam()),
  Pairs.feedback,
  Pairs.balance,
  Pairs.level
]
const odDelayParams = [
  Pairs.drive,
  Pairs.pan,
  ("Delay", fxDelayTime500Param),
  Pairs.feedback,
  Pairs.hfDamp,
  Pairs.balance,
  Pairs.level
]
const distChorusParams = odChorusParams
const distFlangerParams = odFlangerParams
const distDelayParams = odDelayParams
const enhanceChorusParams = [
  ("Sens", RangeParam()),
  ("Mix", RangeParam()),
  ("Pre-Delay", fxDelayTime100Param),
  ("Rate", fxRateParam),
  ("Depth", RangeParam()),
  (),
  Pairs.balance,
  Pairs.level
]
const enhanceFlangerParams = [
  ("Sens", RangeParam()),
  ("Mix", RangeParam()),
  ("Pre-Delay", fxDelayTime100Param),
  ("Rate", fxRateParam),
  ("Depth", RangeParam()),
  Pairs.feedback,
  Pairs.balance,
  Pairs.level
]
const enhanceDelayParams = [
  ("Sens", RangeParam()),
  ("Mix", RangeParam()),
  ("Delay", fxDelayTime500Param),
  Pairs.feedback,
  Pairs.hfDamp,
  (),
  Pairs.balance,
  Pairs.level
]
const chorusDelayParams = [
  ("Cho-Delay", fxDelayTime100Param),
  Pairs.chorusRate,
  Pairs.chorusDepth,
  (),
  ("Cho-Balance", fxBalanceParam),
  ("Delay", fxDelayTime500Param),
  ("Delay-Fbk", fxFdbkParam),
  Pairs.hfDamp,
  ("Delay-Blc", fxBalanceParam),
  Pairs.level
]
const flangerDelayParams = [
  ("Flg-Delay", fxDelayTime100Param),
  ("Flg-Rate", fxRateParam),
  ("Flg-Depth", RangeParam()),
  ("Flg-Feedback", fxFdbkParam),
  ("Flg-Balance", fxBalanceParam),
  ("Delay", fxDelayTime500Param),
  ("Delay-Fbk", fxFdbkParam),
  Pairs.hfDamp,
  ("Delay-Blc", fxBalanceParam),
  Pairs.level
]
const chorusFlangerParams = [
  ("Cho-Delay", fxDelayTime100Param),
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ("Cho-Bal", fxBalanceParam),
  ("Flg-Delay", fxDelayTime100Param),
  ("Flg-Rate", fxRateParam),
  ("Flg-Depth", RangeParam()),
  ("Flg-Feedback", fxFdbkParam),
  ("Flg-Blc", fxBalanceParam),
  Pairs.level
]
const chorusAndDelayParams = chorusDelayParams
const flangerAndDelayParams = flangerDelayParams
const chorusAndFlangerParams = chorusFlangerParams