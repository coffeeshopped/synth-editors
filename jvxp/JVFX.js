require('./utils.js')

const reverbHFDamps = ["200", "250", "315", "400", "500", "630", "800", "1000", "1250", "1600", "2000", "2500", "3150", "4000", "5000", "6300", "8000", "Bypass"]
const fxGainParam = { max: 30, dispOff: -15 }
const fxHFDampParam = { opts: reverbHFDamps }
const fx200to8kParam = { opts: ["200", "250", "315", "400", "500", "630", "800", "1000", "1250", "1600", "2000", "2500", "3150", "4000", "5000", "6300", "8000"] }
const fxQParam = { opts: ["0.5", "1.0", "2.0", "4.0", "9.0" ] }
const fxPanParam = { dispOff: -64 }
const fxAmpParam = { opts: ["Small","Built-in","2-Stack","3-Stack"] }
const fxRateParam = (() => {
  var options = ([0, 100]).rangeMap(i => `${(i+1) * 0.05}` )
  options += ([100, 120]).rangeMap(i => `${5.0 + (i-99) * 0.1}` )
  options += ([120, 126]).rangeMap(i => `${7.0 + (i-119) * 0.5}` )
  return options
})()
const fxCoarseParam = { max: 36, dispOff: -24 }
const fxFineParam = { opts: (101).map(i => `${i*2 - 100}`) }
const fxFdbkParam = { opts: (99).map(i => `${i*2 - 98}`) }
const fxBalanceParam = { opts: (101).map(i => `D${100-i}:${i}E`) }
// "baseSwitch" is switcher but arg passed to iso fns is 0-based (adjusted based on range start)
const fxDelayTime500Param = { max: 126, iso: ['baseSwitch', [
  ['rng', 0, 50, ["*0.1"]],
  ['rng', 50, 60, ["*0.5", "+5"]],
  ['rng', 60, 90, ["*1", "+10"]],
  ['rng', 90, 116, ["*10", "+40"]],
  ['rng', 116, 127, ["*20", "+300"]],
]] }
const fxDelayTime100Param = { max: 125, iso: ['baseSwitch', [
  ['rng', 0, 50, ["*0.1"]],
  ['rng', 50, 60, ["*0.5", "+5"]],
  ['rng', 60, 100, ["*1", "+10"]],
  ['rng', 100, 126, ["*2", "+50"]],
]] }

// 200...1000ms, note
const fxDelayTime1000NoteParam = { max: 125, iso: ['switcher', [
  ['rng', 0, 70, ["*5", "+200"]],
  ['rng', 70, 116, ["-70", "*10", "+550"]],
  ['rng', 116, 126, ["-116", ["@", ["16th", "8th trip", "Dot 16th", "8th", "1/4 trip", "Dot 8th", "1/4", "1/2 trip", "Dot 1/4", "1/2"]]]],
], ""] }

// 200...1000ms (no note)
const fxDelayTime1000Param = { max: 120, iso: ['switcher', [
  ['rng', 0, 80, ["*5", "+200"]],
  ['rng', 80, 121, ["-80", "*10", "+600"]],
], ""] }


const Pairs = {
  loFreq: ["Low-Freq", { opts: ["200","400"] }],
  hiFreq: ["High-Freq", { opts: ["4000","8000"] }],
  loGain: ["Low-Gain", fxGainParam],
  hiGain: ["High-Gain", fxGainParam],

  level: ["Level", { }],
  drive: ["Drive", { }],
  pan: ["Pan", fxPanParam],
  
  lfoRate: ["LFO-Rate", fxRateParam],
  lfoDepth: ["LFO-Depth", { }],
  chorusRate: ["Cho-Rate", fxRateParam],
  chorusDepth: ["Cho-Depth", { }],
  phaserRate: ["Pha-Rate", fxRateParam],
  phaserDepth: ["Pha-Depth", { }],

  feedback: ["Feedback", fxFdbkParam],
  balance: ["Balance", fxBalanceParam],
  hfDamp: ["HF-Damp", fxHFDampParam],
  
  filterType: ["Filter-Type", { opts: ["Off","LPF","HPF"] }],
}

const eqParams = [
  Pairs.loFreq,
  Pairs.loGain,
  Pairs.hiFreq,
  Pairs.hiGain,
  ["P1-Freq", fx200to8kParam],
  ["P1-Q", fxQParam],
  ["P1-Gain", fxGainParam],
  ["P2-Freq", fx200to8kParam],
  ["P2-Q", fxQParam],
  ["P2-Gain", fxGainParam],
  ["Level", { }],
]

const overdriveParams = [
  Pairs.drive,
  Pairs.pan,
  ["Amp-Type", fxAmpParam],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const distortionParams = [
  Pairs.drive,
  Pairs.pan,
  ["Amp-Type", fxAmpParam],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const phaserParams = [
  ["Manual", { }],
  Pairs.phaserRate,
  Pairs.phaserDepth,
  ["Resonance", { }],
  ["Mix", { }],
  Pairs.pan,
  Pairs.level
]
const spectrumParams = [
  ["Band-1", fxGainParam],
  ["Band-2", fxGainParam],
  ["Band-3", fxGainParam],
  ["Band-4", fxGainParam],
  ["Band-5", fxGainParam],
  ["Band-6", fxGainParam],
  ["Band-7", fxGainParam],
  ["Band-8", fxGainParam],
  ["Width", { max: 4, dispOff: 1 }],
  Pairs.pan,
  Pairs.level
]
const enhancerParams = [
  ["Sens", { }],
  ["Mix", { }],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const autowahParams = [
  ["Filter-Type", { opts: ["LPF","BPF"] }],
  Pairs.lfoRate,
  Pairs.lfoDepth,
  ["Sens", { }],
  ["Manual", { }],
  ["Peak", { }],
  Pairs.level
]
const rotaryParams = [
  ["Hi-Slow", fxRateParam],
  ["Low-Slow", fxRateParam],
  ["Hi-Fast", fxRateParam],
  ["Low-Fast", fxRateParam],
  ["Speed", { opts: ["Slow","Fast"] }],
  ["Hi-Accl", { max: 15 }],
  ["Low-Accl", { max: 15 }],
  ["Hi-Level", { }],
  ["Low-Level", { }],
  ["Separation", { }],
  Pairs.level
]
const compressorParams = [
  ["Sustain", { }],
  ["Attack", { }],
  Pairs.pan,
  ["Post-Gain", { opts: ["x1","x2","x4","x8"] }],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const limiterParams = [
  ["Threshold", { }],
  ["Release", { }],
  ["Ratio", { opts: ["1.5:1","2:1","4:1","100:1"] }],
  Pairs.pan,
  ["Post-Gain", { opts: ["x1","x2","x4","x8"] }],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.level
]
const hexaChorusParams = [
  ["Pre-Delay", fxDelayTime100Param],
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ["PreDelay-Dev", { }],
  ["Depth-Dev", { }],
  ["Pan-Dev", { }],
  Pairs.balance,
  Pairs.level
]
const tremChorusParams = [
  ["Pre-Delay", fxDelayTime100Param],
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ["Tremolo-Rate", fxRateParam],
  ["Tremolo-Sep", { }],
  ["Phase", { }],
  Pairs.balance,
  Pairs.level
]
const spaceDParams = [
  ["Pre-Delay", fxDelayTime100Param],
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ["Phase", { }],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const chorusParams = [
  Pairs.filterType,
  ["Cutoff", { }],
  ["Pre-Delay", fxDelayTime100Param],
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ["Phase", { }],
  null,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const flangerParams = [
  Pairs.filterType,
  ["Cutoff", { }],
  ["Pre-Delay", fxDelayTime100Param],
  Pairs.lfoRate,
  Pairs.lfoDepth,
  ["Phase", { }],
  Pairs.feedback,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const stepFlangerParams = [
  ["Pre-Delay", fxDelayTime100Param],
  Pairs.lfoRate,
  Pairs.lfoDepth,
  Pairs.feedback,
  ["Step-Rate", { }],
  ["Phase", { }],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const stDelayParams = [
  ["FBK-Mode", { }],
  ["Delay-Time-L", fxDelayTime500Param],
  ["Delay-Time-R", fxDelayTime500Param],
  ["Phase-L", { }],
  ["Phase-R", { }],
  Pairs.feedback,
  Pairs.hfDamp,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const modDelayParams = [
  ["FBK-Mode", { }],
  ["Delay-Time-L", fxDelayTime500Param],
  ["Delay-Time-R", fxDelayTime500Param],
  Pairs.feedback,
  Pairs.hfDamp,
  ["Mod-Rate", fxRateParam],
  ["Mod-Depth", { }],
  ["Phase", { }],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const tripleDelayParams = [
  ["Delay-Time-L", fxDelayTime1000NoteParam],
  ["Delay-Time-R", fxDelayTime1000NoteParam],
  ["Delay-C", fxDelayTime1000NoteParam],
  Pairs.feedback,
  Pairs.hfDamp,
  ["Level-L", { }],
  ["Level-R", { }],
  ["Level-C", { }],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const quadDelayParams = [
  ["Delay-1", fxDelayTime1000NoteParam],
  ["Delay-2", fxDelayTime1000NoteParam],
  ["Delay-3", fxDelayTime1000NoteParam],
  ["Delay-4", fxDelayTime1000NoteParam],
  ["Level-1", { }],
  ["Level-2", { }],
  ["Level-3", { }],
  ["Level-4", { }],
  Pairs.feedback,
  Pairs.hfDamp,
  Pairs.balance,
  Pairs.level
]
const timeCtrlDelayParams = [
  ["Delay", fxDelayTime1000Param],
  Pairs.feedback,
  ["Accel", { }],
  Pairs.hfDamp,
  Pairs.pan,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const duoPitchShiftParams = [
  ["Mode", { max: 4, dispOff: 1 }],
  ["Coarse-A", fxCoarseParam],
  ["Coarse-B", fxCoarseParam],
  ["Fine-A", fxFineParam],
  ["Fine-B", fxFineParam],
  ["Pre-Delay-A", fxDelayTime500Param],
  ["Pre-Delay-B", fxDelayTime500Param],
  ["Pan-A", fxPanParam],
  ["Pan-B", fxPanParam],
  ["Level-Balance", { }],
  Pairs.balance,
  Pairs.level,
]
const feedbackPitchShiftParams = [
  ["Mode", { max: 4, dispOff: 1}],
  ["Coarse", fxCoarseParam],
  ["Fine", fxFineParam],
  ["Pre-Delay", fxDelayTime500Param],
  Pairs.feedback,
  Pairs.pan,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level,
]
const reverbParams = [
  ["Type", { }],
  ["Pre-Delay", fxDelayTime100Param],
  ["Reverb-Time", { }],
  Pairs.hfDamp,
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const gateVerbParams = [
  ["Type", { }],
  ["Pre-Delay", fxDelayTime100Param],
  ["Gate-Time", { }],
  Pairs.loGain,
  Pairs.hiGain,
  Pairs.balance,
  Pairs.level
]
const odChorusParams = [
  Pairs.drive,
  Pairs.pan,
  ["Pre-Delay", fxDelayTime100Param],
  ["Rate", fxRateParam],
  ["Depth", { }],
  null,
  Pairs.balance,
  Pairs.level
]
const odFlangerParams = [
  Pairs.drive,
  Pairs.pan,
  ["Pre-Delay", fxDelayTime100Param],
  ["Rate", fxRateParam],
  ["Depth", { }],
  Pairs.feedback,
  Pairs.balance,
  Pairs.level
]
const odDelayParams = [
  Pairs.drive,
  Pairs.pan,
  ["Delay", fxDelayTime500Param],
  Pairs.feedback,
  Pairs.hfDamp,
  Pairs.balance,
  Pairs.level
]
const distChorusParams = odChorusParams
const distFlangerParams = odFlangerParams
const distDelayParams = odDelayParams
const enhanceChorusParams = [
  ["Sens", { }],
  ["Mix", { }],
  ["Pre-Delay", fxDelayTime100Param],
  ["Rate", fxRateParam],
  ["Depth", { }],
  null,
  Pairs.balance,
  Pairs.level
]
const enhanceFlangerParams = [
  ["Sens", { }],
  ["Mix", { }],
  ["Pre-Delay", fxDelayTime100Param],
  ["Rate", fxRateParam],
  ["Depth", { }],
  Pairs.feedback,
  Pairs.balance,
  Pairs.level
]
const enhanceDelayParams = [
  ["Sens", { }],
  ["Mix", { }],
  ["Delay", fxDelayTime500Param],
  Pairs.feedback,
  Pairs.hfDamp,
  null,
  Pairs.balance,
  Pairs.level
]
const chorusDelayParams = [
  ["Cho-Delay", fxDelayTime100Param],
  Pairs.chorusRate,
  Pairs.chorusDepth,
  null,
  ["Cho-Balance", fxBalanceParam],
  ["Delay", fxDelayTime500Param],
  ["Delay-Fbk", fxFdbkParam],
  Pairs.hfDamp,
  ["Delay-Blc", fxBalanceParam],
  Pairs.level
]
const flangerDelayParams = [
  ["Flg-Delay", fxDelayTime100Param],
  ["Flg-Rate", fxRateParam],
  ["Flg-Depth", { }],
  ["Flg-Feedback", fxFdbkParam],
  ["Flg-Balance", fxBalanceParam],
  ["Delay", fxDelayTime500Param],
  ["Delay-Fbk", fxFdbkParam],
  Pairs.hfDamp,
  ["Delay-Blc", fxBalanceParam],
  Pairs.level
]
const chorusFlangerParams = [
  ["Cho-Delay", fxDelayTime100Param],
  Pairs.chorusRate,
  Pairs.chorusDepth,
  ["Cho-Bal", fxBalanceParam],
  ["Flg-Delay", fxDelayTime100Param],
  ["Flg-Rate", fxRateParam],
  ["Flg-Depth", { }],
  ["Flg-Feedback", fxFdbkParam],
  ["Flg-Blc", fxBalanceParam],
  Pairs.level
]
const chorusAndDelayParams = chorusDelayParams
const flangerAndDelayParams = flangerDelayParams
const chorusAndFlangerParams = chorusFlangerParams

const fxParams = [
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

module.exports = {
  fxParams: fxParams,
}