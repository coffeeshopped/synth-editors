
const noteOptions = [
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


const gain = xvrange([-15, 15])
const fx200to8kOptions = ["200", "250", "315", "400", "500", "630", "800", "1000", "1250", "1600", "2000", "2500", "3150", "4000", "5000", "6300", "8000"]
const fx200to8kParam = xvopts(fx200to8kOptions)
const fx200to8kBypassParam = xvopts(fx200to8kOptions + ["Bypass"])
const eqQ = xvopts(["0.5", "1.0", "2.0", "4.0", "9.0" ])
const panParam = xvrange([-64, 63])
const rateParam = xvmiso([0, 125], Miso.piecewise(breaks: [
  (0, 0.05),
  (99, 5.0),
  (119, 7.0),
  (125, 10)
]) >>> Miso.round(2))

const filterType = xvopts(["Off","LPF","HPF"])
const coarse = xvrange([-24, 12])
const fineParam = xvopts(101.map {"\($0*2 - 100)"})
const fdbk = xvopts(99.map {"\($0*2 - 98)"})
const balance = xvopts(101.map {"D\(100-$0):\($0)W"})
const phaseParam = xvopts(91.map {"\($0 * 2)"})
const delayTime500 = xvmiso([0, 126], Miso.piecewise(breaks: [
  (0, 0),
  (50, 5),
  (60, 10),
  (90, 40),
  (116, 300),
  (126, 500),
]) >>> Miso.round(2))
const delayTime100 = xvmiso([0, 125], Miso.piecewise(breaks: [
  (0, 0),
  (50, 5),
  (60, 10),
  (100, 50),
  (125, 100),
]) >>> Miso.round(2))

const fxPhaserManual = xvopts({
  var options = (0..<20).map { "\(100 + ($0 * 10))" }
  options += (20..<55).map { "\(300 + ($0-20) * 20)" }
  options += ([55, 125]).map { "\(1000 + ($0-55) * 100)" }
  return options
}())

const offOnParam = xvopts(["Off","On"])
const vowelParam = xvopts(["a","e","i","o","u"])
const postGainParam = xvopts(["0","+6","+12","+18"])
const limitRatioParam = xvopts(["1.5:1","2:1","4:1","100:1"])
const threeDOutParam = xvopts(["Speaker","Phones"])
const modWaveParam = xvopts(["Tri","Squ","Sin","Saw 1","Saw 2"])
const accelParam =  xvrange([0, 15])
const midQParam = xvopts(["0.5","1.0","2.0","4.0","8.0"])
const speakerSimParam = xvopts(["Small 1","Small 2","Middle","JC-120","Built In 1", "Built In 2", "Built In 3", "Built In 4", "Built In 5","BG Stack 1", "BG Stack 2", "MS Stack 1", "MS Stack 2", "Metal Stack", "2-Stack", "3-Stack"])
const ampSimpleParam = xvopts(["Small", "Built-in", "2 Stack", "3 Stack"])
const ampSimParam = xvopts(["JC-120", "Clean Twin", "Match Drive", "BG Lead", "MS1959I", "MS1959II", "MS1959I+II", "SLDN Lead", "Metal 5150", "Metal Lead", "OD-1", "OD-2 Turbo", "Distortion", "Fuzz"])
const odDistParam = xvopts(["OD", "Dist"])
const choFlgParam = xvopts(["Chorus", "Flanger"])
const isolatorGainParam = xvrange([-60, 4])
const defRng = xvrange()

const stepRateOptions = xvmiso([0, 125], Miso.switcher([
  .range([0, 115], Miso.piecewise(breaks: [
    (0, 0.1),
    (79, 8),
    (109, 14),
    (115, 20),
  ]) >>> Miso.round(2) >>> Miso.str()),
  .range([116, 125], Miso.a(-110) >>> Miso.options(noteOptions))
]))
const phaserRate = xvmiso(1...(200 + noteOptions.count), Miso.switcher([
  .range([1, 200], Miso.m(0.05) >>> Miso.round(2) >>> Miso.str()),
  .range(201...Float((200 + noteOptions.count)), Miso.options(noteOptions, startIndex: 201))
]))
const phaserStepRateOptions = xvmiso(1...(200 + noteOptions.count), Miso.switcher([
  .range([1, 200], Miso.m(0.1) >>> Miso.round(2) >>> Miso.str()),
  .range(201...Float((200 + noteOptions.count)), Miso.options(noteOptions, startIndex: 201))
]))
const delayTime1000Param = xvopts({
  var options = (0..<70).map { "\(200 + $0 * 5)" }
  options += ([0, 45]).map { "\(550 + $0 * 10)" }
  options += noteOptions[6..<16]
  return options
  }())
const delayTime1000NoNoteParam = xvopts({
  var options = (0..<70).map { "\(200 + $0 * 5)" }
  options += ([0, 45]).map { "\(550 + $0 * 10)" }
  return options
  }())
const gateTimeParam = xvopts({
  var options = ([1, 100]).map { "\($0 * 5)" }
  return options
  }())
const delayTime1800Param = xvopts({
  var options = ([0, 1800]).map { "\($0)" }
  options += noteOptions
  return options
  }())
const delayTime900Param = xvopts({
  var options = ([0, 900]).map { "\($0)" }
  options += noteOptions
  return options
  }())
const delayTime3000Param = xvopts({
  var options = ([0, 3000]).map { "\($0)" }
  options += noteOptions
  return options
  }())
const delayTime1500Param = xvopts({
  var options = ([0, 1500]).map { "\($0)" }
  options += noteOptions
  return options
  }())
const azimuthParam = xvopts({
  var options = ([0, 14]).map { "L\(12 * (15-$0))" }
  options += ["0"]
  options += ([1, 15]).map { "R\(12 * $0)" }
  return options
  }())

const fxTypeOptions: [Int:String] = {
  var map = [Int:String]()
  allFx.enumerated().forEach { map[$0.offset] = "\($0.offset): \($0.element.name)" }
  return map
}()

const allFx: [Self] = [
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
  
const off = fxInit("Through", [], [])
const eq = fxInit("Stereo Eq", [
  [0, ["Low Freq", xvopts(["200","400"])]],
  [1, ["Low Gain", gain]],
  [2, ["High Freq", xvopts(["4000","8000"])]],
  [3, ["High Gain", gain]],
  [4, ["Mid1 Freq", fx200to8kParam]],
  [5, ["Mid1 Q", eqQ]],
  [6, ["Mid1 Gain", gain]],
  [7, ["Mid2 Freq", fx200to8kParam]],
  [8, ["Mid2 Q", eqQ]],
  [9, ["Mid2 Gain", gain]],
  [10, ["Level", defRng]],
  ], [10])
const overdrive = fxInit("Overdrive", [
  [0, ["Drive", defRng]],
  [1, ["Pan", panParam]],
  [2, ["Amp Type", ampSimpleParam]],
  [3, ["Low Gain", gain]],
  [4, ["High Gain", gain]],
  [5, ["Level", defRng]],
  ], [0,1])
const distortion = fxInit("Distortion", overdrive.params, overdrive.dests)
const phaser = fxInit("Phaser", [
  [0, ["Manual", fxPhaserManual]],
  [1, ["Rate", rateParam]],
  [2, ["Depth", defRng]],
  [3, ["Resonance", defRng]],
  [4, ["Mix", defRng]],
  [5, ["Pan", panParam]],
  [6, ["Level", defRng]],
  ], [0,1])
const spectrum = fxInit("Spectrum", [
  [0, ["250Hz", gain]],
  [1, ["500Hz", gain]],
  [2, ["1000Hz", gain]],
  [3, ["1250Hz", gain]],
  [4, ["2000Hz", gain]],
  [5, ["3150Hz", gain]],
  [6, ["4000Hz", gain]],
  [7, ["8000Hz", gain]],
  [8, ["Width", midQParam]],
  [9, ["Pan", panParam]],
  [10, ["Level", defRng]],
  ], [9,10])
const enhancer = fxInit("Enhancer", [
  [0, ["Sens", defRng]],
  [1, ["Mix", defRng]],
  [2, ["Low Gain", gain]],
  [3, ["High Gain", gain]],
  [4, ["Level", defRng]],
  ], [0,1])
const autowah = fxInit("Auto Wah", [
  [0, ["Filter", xvopts(["LPF","BPF"])]],
  [1, ["Rate", rateParam]],
  [2, ["Depth", defRng]],
  [3, ["Sens", defRng]],
  [4, ["Manual", defRng]],
  [5, ["Peak", defRng]],
  [6, ["Level", defRng]],
  ], [1,4])
const rotary = fxInit("Rotary", [
  [0, ["Hi Slow", rateParam]],
  [1, ["Low Slow", rateParam]],
  [2, ["Hi Fast", rateParam]],
  [3, ["Low Fast", rateParam]],
  [4, ["Speed", xvopts(["Slow","Fast"])]],
  [5, ["Hi Accel", xvrange([0, 15])]],
  [6, ["Low Accel", xvrange([0, 15])]],
  [7, ["Hi Level", defRng]],
  [8, ["Low Level", defRng]],
  [9, ["Separation", defRng]],
  [10, ["Level", defRng]],
  ], [4,10])
const compressor = fxInit("Compressor", [
  [0, ["Sustain", defRng]],
  [1, ["Attack", defRng]],
  [2, ["Pan", panParam]],
  [3, ["Post Gain", postGainParam]],
  [4, ["Low Gain", gain]],
  [5, ["High Gain", gain]],
  [6, ["Level", defRng]],
  ], [2,6])
const limiter = fxInit("Limiter", [
  [0, ["Threshold", defRng]],
  [1, ["Release", defRng]],
  [2, ["Ratio", limitRatioParam]],
  [3, ["Pan", panParam]],
  [4, ["Post Gain", postGainParam]],
  [5, ["Low Gain", gain]],
  [6, ["High Gain", gain]],
  [7, ["Level", defRng]],
  ], [3,7])
const hexaChorus = fxInit("Hexa-chorus", [
  [0, ["Pre Delay", delayTime100]],
  [1, ["Rate", rateParam]],
  [2, ["Depth", defRng]],
  [3, ["Delay Dev", xvrange([0, 20])]],
  [4, ["Depth Dev", xvrange([-20, 20])]],
  [5, ["Pan Dev", xvrange([0, 20])]],
  [6, ["Balance", balance]],
  [7, ["Level", defRng]],
  ], [1,6])
const tremChorus = fxInit("Tremolo Cho", [
  [0, ["Pre Delay", delayTime100]],
  [1, ["Cho Rate", rateParam]],
  [2, ["Cho Depth", defRng]],
  [3, ["Trem Rate", rateParam]],
  [4, ["Trem Sep", defRng]],
  [5, ["Phase", phaseParam]],
  [6, ["Balance", balance]],
  [7, ["Level", defRng]],
  ], [3,6])
const spaceD = fxInit("Space-D", [
  [0, ["Pre Delay", delayTime100]],
  [1, ["Cho Rate", rateParam]],
  [2, ["Cho Depth", defRng]],
  [3, ["Cho Phase", phaseParam]],
  [4, ["Low Gain", gain]],
  [5, ["High Gain", gain]],
  [6, ["Balance", balance]],
  [7, ["Level", defRng]],
  ], [1,6])
const chorus = fxInit("St Chorus", [
  [0, ["Filter", filterType]],
  [1, ["Cutoff", fx200to8kParam]],
  [2, ["Pre Delay", delayTime100]],
  [3, ["Rate", rateParam]],
  [4, ["Depth", defRng]],
  [5, ["Phase", phaseParam]],
  [7, ["Low Gain", gain]],
  [8, ["High Gain", gain]],
  [9, ["Balance", balance]],
  [10, ["Level", defRng]],
  ], [3,9])
const flanger = fxInit("Stereo Flanger", [
  [0, ["Filter", filterType]],
  [1, ["Cutoff", fx200to8kParam]],
  [2, ["Pre Delay", delayTime100]],
  [3, ["Rate", rateParam]],
  [4, ["Depth", defRng]],
  [5, ["Phase", phaseParam]],
  [6, ["Feedback", fdbk]],
  [7, ["Low Gain", gain]],
  [8, ["High Gain", gain]],
  [9, ["Balance", balance]],
  [10, ["Level", defRng]],
  ], [3,6])
const stepFlanger = fxInit("Step Flanger", [
  [0, ["Pre Delay", delayTime100]],
  [1, ["Rate", rateParam]],
  [2, ["Depth", defRng]],
  [3, ["Feedback", fdbk]],
  [4, ["Step Rate", stepRateOptions]],
  [5, ["Phase", phaseParam]],
  [6, ["Low Gain", gain]],
  [7, ["High Gain", gain]],
  [8, ["Balance", balance]],
  [9, ["Level", defRng]],
  ], [4,3])
const stDelay = fxInit("Stereo Delay", [
  [0, ["Mode", xvopts(["Normal","Cross"])]],
  [1, ["Delay L", delayTime500]],
  [2, ["Delay R", delayTime500]],
  [3, ["Phase L", xvopts(["Normal","Invert"])]],
  [4, ["Phase R", xvopts(["Normal","Invert"])]],
  [5, ["Feedback", fdbk]],
  [6, ["HF Damp", fx200to8kBypassParam]],
  [7, ["Low Gain", gain]],
  [8, ["High Gain", gain]],
  [9, ["Balance", balance]],
  [10, ["Level", defRng]],
  ], [5,9])
const modDelay = fxInit("Mod Delay", [
  [0, ["Mode", xvopts(["Normal","Cross"])]],
  [1, ["Delay L", delayTime500]],
  [2, ["Delay R", delayTime500]],
  [3, ["Feedback", fdbk]],
  [4, ["HF Damp", fx200to8kBypassParam]],
  [5, ["Rate", rateParam]],
  [6, ["Depth", defRng]],
  [7, ["Phase", phaseParam]],
  [8, ["Low Gain", gain]],
  [9, ["High Gain", gain]],
  [10, ["Balance", balance]],
  [11, ["Level", defRng]],
  ], [5,10])
const tripleDelay = fxInit("3 Tap Delay", [
  [0, ["Delay L", delayTime1000Param]],
  [1, ["Delay R", delayTime1000Param]],
  [2, ["Delay C", delayTime1000Param]],
  [3, ["Feedback", fdbk]],
  [4, ["HF Damp", fx200to8kBypassParam]],
  [5, ["Level L", defRng]],
  [6, ["Level R", defRng]],
  [7, ["Level C", defRng]],
  [8, ["Low Gain", gain]],
  [9, ["High Gain", gain]],
  [10, ["Balance", balance]],
  [11, ["Level", defRng]],
  ], [3,10])
const quadDelay = fxInit("4 Tap Delay", [
  [0, ["Delay 1", delayTime1000Param]],
  [1, ["Delay 2", delayTime1000Param]],
  [2, ["Delay 3", delayTime1000Param]],
  [3, ["Delay 4", delayTime1000Param]],
  [4, ["Level 1", defRng]],
  [5, ["Level 2", defRng]],
  [6, ["Level 3", defRng]],
  [7, ["Level 4", defRng]],
  [8, ["Feedback", fdbk]],
  [9, ["HF Damp", fx200to8kBypassParam]],
  [10, ["Balance", balance]],
  [11, ["Level", defRng]],
  ], [8,10])
const timeCtrlDelay = fxInit("Tm Ctrl Dly", [
  [0, ["Delay", delayTime1000NoNoteParam]],
  [1, ["Feedback", fdbk]],
  [2, ["Accel", accelParam]],
  [3, ["HF Damp", fx200to8kBypassParam]],
  [4, ["Pan", panParam]],
  [5, ["Low Gain", gain]],
  [6, ["High Gain", gain]],
  [7, ["Balance", balance]],
  [8, ["Level", defRng]],
  ], [0,1])
const duoPitchShift = fxInit("2V pch Shift", [
  [0, ["Mode", xvrange([1, 5])]],
  [1, ["Coarse A", coarse]],
  [2, ["Coarse B", coarse]],
  [3, ["Fine A", fineParam]],
  [4, ["Fine B", fineParam]],
  [5, ["Pre Delay A", delayTime500]],
  [6, ["Pre Delay B", delayTime500]],
  [7, ["Pan A", panParam]],
  [8, ["Pan B", panParam]],
  [9, ["A/B Bal", xvrange([0, 100])]],
  [10, ["Balance", balance]],
  [11, ["Level", defRng]],
  ], [1,2])
const feedbackPitchShift = fxInit("Fb pch Shift", [
  [0, ["Mode", xvrange([1, 5])]],
  [1, ["Coarse", coarse]],
  [2, ["Fine", fineParam]],
  [3, ["Pre Delay", delayTime500]],
  [4, ["Feedback", fdbk]],
  [5, ["Pan", panParam]],
  [6, ["Low Gain", gain]],
  [7, ["High Gain", gain]],
  [8, ["Balance", balance]],
  [9, ["Level", defRng]],
  ], [1,4])
const reverb = fxInit("Reverb", [
  [0, ["Type", xvopts(["Room 1","Room 2","Stage 1","Stage 2","Hall 1","Hall 2"])]],
  [1, ["Pre Delay", delayTime100]],
  [2, ["Time", defRng]],
  [3, ["HF Damp", fx200to8kBypassParam]],
  [4, ["Low Gain", gain]],
  [5, ["High Gain", gain]],
  [6, ["Balance", balance]],
  [7, ["Level", defRng]],
  ], [2,6])
const gateVerb = fxInit("Gated Reverb", [
  [0, ["Type", xvopts(["Normal","Reverse","Sweep 1","Sweep 2"])]],
  [1, ["Pre Delay", delayTime100]],
  [2, ["Gate Time", gateTimeParam]],
  [3, ["Low Gain", gain]],
  [4, ["High Gain", gain]],
  [5, ["Balance", balance]],
  [6, ["Level", defRng]],
  ], [5,6])
const odChorus = fxInit("OD → Chorus", [
  [0, ["Drive", defRng]],
  [1, ["OD Pan", panParam]],
  [2, ["Pre Delay", delayTime100]],
  [3, ["Rate", rateParam]],
  [4, ["Depth", defRng]],
  [6, ["Cho Bal", balance]],
  [7, ["Level", defRng]],
  ], [1,6])
const odFlanger = fxInit("OD → Flanger", [
  [0, ["Drive", defRng]],
  [1, ["OD Pan", panParam]],
  [2, ["Pre Delay", delayTime100]],
  [3, ["Rate", rateParam]],
  [4, ["Depth", defRng]],
  [5, ["Feedback", fdbk]],
  [6, ["Flg Bal", balance]],
  [7, ["Level", defRng]],
  ], [1,6])
const odDelay = fxInit("OD → Delay", [
  [0, ["Drive", defRng]],
  [1, ["OD Pan", panParam]],
  [2, ["Delay", delayTime500]],
  [3, ["Feedback", fdbk]],
  [4, ["HF Damp", fx200to8kBypassParam]],
  [5, ["Dly Bal", balance]],
  [6, ["Level", defRng]],
  ], [1,5])
const distChorus = fxInit("Dist → Chorus", odChorus.params, odChorus.dests)
const distFlanger = fxInit("Dist → Flanger", odFlanger.params, odFlanger.dests)
const distDelay = fxInit("Dist → Delay", odDelay.params, odDelay.dests)
const enhanceChorus = fxInit("Enh → Chorus", [
  [0, ["Sens", defRng]],
  [1, ["Mix", defRng]],
  [2, ["Pre Delay", delayTime100]],
  [3, ["Rate", rateParam]],
  [4, ["Depth", defRng]],
  [6, ["Balance", balance]],
  [7, ["Level", defRng]],
  ], [0,6])
const enhanceFlanger = fxInit("Enh → Flanger", [
  [0, ["Sens", defRng]],
  [1, ["Mix", defRng]],
  [2, ["Pre Delay", delayTime100]],
  [3, ["Rate", rateParam]],
  [4, ["Depth", defRng]],
  [5, ["Feedback", fdbk]],
  [6, ["Balance", balance]],
  [7, ["Level", defRng]],
  ], [0,6])
const enhanceDelay = fxInit("Enh → Delay", [
  [0, ["Sens", defRng]],
  [1, ["Mix", defRng]],
  [2, ["Delay", delayTime500]],
  [3, ["Feedback", fdbk]],
  [4, ["HF Damp", fx200to8kBypassParam]],
  [6, ["Balance", balance]],
  [7, ["Level", defRng]],
  ], [0,6])
const chorusDelay = fxInit("Chorus → Delay", [
  [0, ["Cho Delay", delayTime100]],
  [1, ["Cho Rate", rateParam]],
  [2, ["Cho Depth", defRng]],
  [4, ["Cho Balance", balance]],
  [5, ["Delay", delayTime500]],
  [6, ["Delay Fbk", fdbk]],
  [7, ["HF Damp", fx200to8kBypassParam]],
  [8, ["Delay Bal", balance]],
  [9, ["Level", defRng]],
  ], [4,8])
const flangerDelay = fxInit("Flg → Delay", [
  [0, ["Flg Delay", delayTime100]],
  [1, ["Flg Rate", rateParam]],
  [2, ["Flg Depth", defRng]],
  [3, ["Flg Feedback", fdbk]],
  [4, ["Flg Balance", balance]],
  [5, ["Delay", delayTime500]],
  [6, ["Delay Fbk", fdbk]],
  [7, ["HF Damp", fx200to8kBypassParam]],
  [8, ["Delay Bal", balance]],
  [9, ["Level", defRng]],
  ], [4,8])
const chorusFlanger = fxInit("Cho → Flanger", [
  [0, ["Cho Delay", delayTime100]],
  [1, ["Cho Rate", rateParam]],
  [2, ["Cho Depth", defRng]],
  [3, ["Cho Bal", balance]],
  [4, ["Flg Delay", delayTime100]],
  [5, ["Flg Rate", rateParam]],
  [6, ["Flg Depth", defRng]],
  [7, ["Flg Feedback", fdbk]],
  [8, ["Flg Bal", balance]],
  [9, ["Level", defRng]],
  ], [3,8])
const chorusAndDelay = fxInit("Chorus/Delay", chorusDelay.params, chorusDelay.dests)
const flangerAndDelay = fxInit("Flg/Delay", flangerDelay.params, flangerDelay.dests)
const chorusAndFlanger = fxInit("Cho/Flanger", chorusFlanger.params, chorusFlanger.dests)
const stPhaser = fxInit("St Phaser", [
  [0, ["Type", xvopts(["1","2"])]],
  [1, ["Mode", xvopts(["4-stage","8-stage"])]],
  [2, ["Polarity", xvopts(["Inverse","Synchro"])]],
  [3, ["Rate", phaserRate]],
  [4, ["Depth", defRng]],
  [5, ["Manual", defRng]],
  [6, ["Resonance", defRng]],
  [7, ["X-Feedback", fdbk]],
  [8, ["Step Switch", xvopts(["Off","On"])]],
  [9, ["Step Rate", phaserStepRateOptions]],
  [10, ["Mix", defRng]],
  [11, ["Low Gain", gain]],
  [12, ["High Gain", gain]],
  [13, ["Level", defRng]],
  ], [3,5,9])
const keySyncFlanger = fxInit("Keysync Flg", [
  [0, ["Filter", filterType]],
  [1, ["Cutoff", fx200to8kParam]],
  [2, ["Pre Delay", delayTime100]],
  [3, ["LFO Rate", phaserRate]],
  [4, ["LFO Depth", defRng]],
  [5, ["Feedback", fdbk]],
  [6, ["Step Switch", offOnParam]],
  [7, ["Step Rate", phaserStepRateOptions]],
  [8, ["Phase", phaseParam]],
  [9, ["Keysync", offOnParam]],
  [10, ["Threshold", defRng]],
  [11, ["Ksync Phase", xvopts(181.map { "\($0 * 2]]," })),
  [12, ["Low Gain", gain]],
  [13, ["High Gain", gain]],
  [14, ["Balance", balance]],
  [15, ["Level", defRng]],
  ], [3,5,7,14])
const formantFilter = fxInit("Formant Fltr", [
  [0, ["Drive", offOnParam]],
  [1, ["Drive", defRng]],
  [2, ["Vowel1", vowelParam]],
  [3, ["Vowel2", vowelParam]],
  [4, ["Rate", phaserRate]],
  [5, ["Depth", defRng]],
  [6, ["Keysync", offOnParam]],
  [7, ["Threshold", defRng]],
  [8, ["Manual", xvrange([0, 100])]],
  [9, ["Low Gain", gain]],
  [10, ["High Gain", gain]],
  [11, ["Pan", panParam]],
  [12, ["Level", defRng]],
  ], [1,4,5,8])
const ringMod = fxInit("Ring Mod", [
  [0, ["Frequency", defRng]],
  [1, ["Modulator", xvopts(["Off","Src","A","B","C","D"])]],
  [2, ["Monitor", offOnParam]],
  [3, ["Sens", defRng]],
  [4, ["Polarity", xvopts(["Up","Down"])]],
  [5, ["Low Gain", gain]],
  [6, ["High Gain", gain]],
  [7, ["Balance", balance]],
  [8, ["Level", defRng]],
  ], [0,3,7])
const multiTapDelay = fxInit("Mlt tap Dly", [
  [0, ["Delay 1", delayTime1800Param]],
  [1, ["Delay 2", delayTime1800Param]],
  [2, ["Delay 3", delayTime1800Param]],
  [3, ["Delay 4", delayTime1800Param]],
  [4, ["Dly Pan 1", panParam]],
  [5, ["Dly Pan 2", panParam]],
  [6, ["Dly Pan 3", panParam]],
  [7, ["Dly Pan 4", panParam]],
  [8, ["Dly Level 1", defRng]],
  [9, ["Dly Level 2", defRng]],
  [10, ["Dly Level 3", defRng]],
  [11, ["Dly Level 4", defRng]],
  [12, ["Feedback", fdbk]],
  [13, ["HF Damp", fx200to8kBypassParam]],
  [14, ["Low Gain", gain]],
  [15, ["High Gain", gain]],
  [16, ["Balance", balance]],
  [17, ["Level", defRng]],
  ], [12,16])
const reverseDelay = fxInit("Reverse Dly", [
  0: ("Threshold", defRng),
  [1, ["Delay 1", delayTime900Param]],
  [2, ["Delay 2", delayTime900Param]],
  [3, ["Delay 3", delayTime900Param]],
  [4, ["Delay 4", delayTime900Param]],
  [5, ["Feedback 1", fdbk]],
  [6, ["Feedback 4", fdbk]],
  [7, ["HF Damp 1", fx200to8kBypassParam]],
  [8, ["HF Damp 4", fx200to8kBypassParam]],
  [9, ["Dly Pan 1", panParam]],
  [10, ["Dly Pan 2", panParam]],
  [11, ["Dly Pan 3", panParam]],
  [12, ["Dly Level 1", defRng]],
  [13, ["Dly Level 2", defRng]],
  [14, ["Dly Level 3", defRng]],
  [15, ["Balance", balance]],
  [16, ["Low Gain", gain]],
  [17, ["High Gain", gain]],
  [18, ["Level", defRng]],
  ], [5,6,15])
const shuffleDelay = fxInit("Shuffle Dly", [
  [0, ["Delay", delayTime1800Param]],
  [1, ["Shuffle Rate", xvrange([0, 100])]],
  [2, ["Pan A", panParam]],
  [3, ["Pan B", panParam]],
  [4, ["Level Bal", xvrange([0, 100])]],
  [5, ["Feedback", fdbk]],
  [6, ["Acceleration", accelParam]],
  [7, ["HF Damp", fx200to8kBypassParam]],
  [8, ["Low Gain", gain]],
  [9, ["High Gain", gain]],
  [10, ["Balance", balance]],
  [11, ["Level", defRng]],
  ], [0,1,5,10])
const threeDDelay = fxInit("3D Delay", [
  [0, ["Delay L", delayTime1800Param]],
  [1, ["Delay R", delayTime1800Param]],
  [2, ["Delay C", delayTime1800Param]],
  [3, ["Level L", defRng]],
  [4, ["Level R", defRng]],
  [5, ["Level C", defRng]],
  [6, ["Feedback", fdbk]],
  [7, ["HF Damp", fx200to8kBypassParam]],
  [8, ["Output Mode", xvopts(["Speaker","Phones"])]],
  [9, ["Low Gain", gain]],
  [10, ["High Gain", gain]],
  [11, ["Balance", balance]],
  [12, ["Level", defRng]],
  ], [6,11])
const threeVoicePitchShift = fxInit("3V pch Shift", [
  [0, ["Mode", xvrange([1, 5])]],
  [1, ["Coarse 1", coarse]],
  [2, ["Coarse 2", coarse]],
  [3, ["Coarse 3", coarse]],
  [4, ["Fine 1", fineParam]],
  [5, ["Fine 2", fineParam]],
  [6, ["Fine 3", fineParam]],
  [7, ["Pre Dly 1", delayTime500]],
  [8, ["Pre Dly 2", delayTime500]],
  [9, ["Pre Dly 3", delayTime500]],
  [10, ["Feedback 1", fdbk]],
  [11, ["Feedback 2", fdbk]],
  [12, ["Feedback 3", fdbk]],
  [13, ["Pan 1", panParam]],
  [14, ["Pan 2", panParam]],
  [15, ["Pan 3", panParam]],
  [16, ["Level 1", defRng]],
  [17, ["Level 2", defRng]],
  [18, ["Level 3", defRng]],
  [19, ["Balance", balance]],
  [20, ["Level", defRng]],
  ], [1,2,3,10,11,12])
const lofiComp = fxInit("Lofi Comp", [
  [0, ["Pre Filter", xvrange([1, 6])]],
  [1, ["LoFi Type", xvrange([1, 9])]],
  [2, ["Post Filter 1", xvrange([1, 6])]],
  [3, ["Post Filter 2", filterType]],
  [4, ["Post Cutoff", fx200to8kParam]],
  [5, ["Balance", balance]],
  [6, ["Low Gain", gain]],
  [7, ["High Gain", gain]],
  [8, ["Pan", panParam]],
  [9, ["Level", defRng]],
  ], [5])
const lofiNoise = fxInit("Lofi Noise", [
  [0, ["LoFi Type", xvrange([1, 9])]],
  [1, ["Post Filter", filterType]],
  [2, ["Cutoff", fx200to8kParam]],
  [3, ["Radio Detune", defRng]],
  [4, ["Radio N Level", defRng]],
  [5, ["Disc Noise", xvopts(["LP","EP","SP","RND"])]],
  [6, ["Disc N LPF", fx200to8kBypassParam]],
  [7, ["Disc N Level", defRng]],
  [8, ["Balance", balance]],
  [9, ["Low Gain", gain]],
  [10, ["High Gain", gain]],
  [11, ["Pan", panParam]],
  [12, ["Level", defRng]],
  ], [3,8])
const speakerSim = fxInit("Speaker Sim", [
  [0, ["Type", speakerSimParam]],
  [1, ["Mic Setting", xvrange([1, 3])]],
  [2, ["Mic Level", defRng]],
  [3, ["Direct Level", defRng]],
  [4, ["Level", defRng]],
  ], [2,3,4])
const overdrive2 = fxInit("Overdrive 2", [
  [0, ["Drive", defRng]],
  [1, ["Tone", defRng]],
  [2, ["Pan", panParam]],
  [3, ["Amp Simulator", offOnParam]],
  [4, ["Amp Type", ampSimpleParam]],
  [5, ["Low Gain", gain]],
  [6, ["High Gain", gain]],
  [7, ["Level", defRng]],
  ], [0,2])
const distortion2 = fxInit("Distortion 2", overdrive2.params, overdrive2.dests)
const stComp = fxInit("Stereo Comp", [
  [0, ["Sustain", defRng]],
  [1, ["Attack", defRng]],
  [2, ["Post Gain", postGainParam]],
  [3, ["Low Gain", gain]],
  [4, ["High Gain", gain]],
  [5, ["Level", defRng]],
  ], [5])
const stLimit = fxInit("St Limiter", [
  [0, ["Threshold", defRng]],
  [1, ["Release", defRng]],
  [2, ["Ratio", limitRatioParam]],
  [3, ["Post Gain", postGainParam]],
  [4, ["Low Gain", gain]],
  [5, ["High Gain", gain]],
  [6, ["Level", defRng]],
  ], [6])
const gate = fxInit("Gate", [
  [0, ["Key", xvopts(["Source","A","B","C","D"])]],
  [1, ["Threshold", defRng]],
  [2, ["Monitor", offOnParam]],
  [3, ["Mode", xvopts(["Gate","Duck"])]],
  [4, ["Balance", balance]],
  [5, ["Attack", defRng]],
  [6, ["Hold", defRng]],
  [7, ["Release", defRng]],
  [8, ["Level", defRng]],
  ], [4])
const slicer = fxInit("Slicer", [
  [0, ["Level Beat 1-1", defRng]],
  [1, ["Beat 1-2", defRng]],
  [2, ["Beat 1-3", defRng]],
  [3, ["Beat 1-4", defRng]],
  [4, ["Level Beat 2-1", defRng]],
  [5, ["Beat 2-2", defRng]],
  [6, ["Beat 2-3", defRng]],
  [7, ["Beat 2-4", defRng]],
  [8, ["Level Beat 3-1", defRng]],
  [9, ["Beat 3-2", defRng]],
  [10, ["Beat 3-3", defRng]],
  [11, ["Beat 3-4", defRng]],
  [12, ["Level Beat 4-1", defRng]],
  [13, ["Beat 4-2", defRng]],
  [14, ["Beat 4-3", defRng]],
  [15, ["Beat 4-4", defRng]],
  [16, ["Rate", phaserRate]],
  [17, ["Attack", defRng]],
  [18, ["Reset Trigger", xvopts(["Off","Src","A","B","C","D"])]],
  [19, ["Reset Threshold", defRng]],
  [20, ["Reset Monitor", offOnParam]],
  [21, ["Beat Chg Mode", xvopts(["Legato","Slash"])]],
  [22, ["Shuffle", defRng]],
  [23, ["Level", defRng]],
  ], [18,16,22])
const isolator = fxInit("Isolator", [
  [0, ["High", isolatorGainParam]],
  [1, ["Mid", isolatorGainParam]],
  [2, ["Low", isolatorGainParam]],
  [3, ["AntiPhase Mid", offOnParam]],
  [4, ["AntiPhase MidLev", defRng]],
  [5, ["AntiPhase Low", offOnParam]],
  [6, ["AntiPhase LowLev", defRng]],
  [7, ["Low Boost", offOnParam]],
  [8, ["Low Boost Level", defRng]],
  [9, ["Level", defRng]],
  ], [0,1,2])
const threeDChorus = fxInit("3D Chorus", [
  [0, ["Filter", filterType]],
  [1, ["Cutoff", fx200to8kParam]],
  [2, ["Pre Delay", delayTime100]],
  [3, ["LFO Rate", phaserRate]],
  [4, ["LFO Depth", defRng]],
  [5, ["Phase", phaseParam]],
  [6, ["Output Mode", threeDOutParam]],
  [7, ["Low Gain", gain]],
  [8, ["High Gain", gain]],
  [9, ["Balance", balance]],
  [10, ["Level", defRng]],
  ], [3,9])
const threeDFlanger = fxInit("3D Flanger", [
  [0, ["Filter", filterType]],
  [1, ["Cutoff", fx200to8kParam]],
  [2, ["Pre Delay", delayTime100]],
  [3, ["LFO Rate", phaserRate]],
  [4, ["LFO Depth", defRng]],
  [5, ["Feedback", fdbk]],
  [6, ["Step", offOnParam]],
  [7, ["Step Rate", phaserStepRateOptions]],
  [8, ["Phase", phaseParam]],
  [9, ["Output Mode", threeDOutParam]],
  [10, ["Low Gain", gain]],
  [11, ["High Gain", gain]],
  [12, ["Balance", balance]],
  [13, ["Level", defRng]],
  ], [3,5,7,12])
const tremolo = fxInit("Tremolo", [
  [0, ["Mod Wave", modWaveParam]],
  [1, ["Rate", phaserRate]],
  [2, ["Depth", defRng]],
  [3, ["Low Gain", gain]],
  [4, ["High Gain", gain]],
  [5, ["Level", defRng]],
  ], [1,2])
const autoPan = fxInit("Auto Pan", [
  [0, ["Mod Wave", modWaveParam]],
  [1, ["Rate", phaserRate]],
  [2, ["Depth", defRng]],
  [3, ["Low Gain", gain]],
  [4, ["High Gain", gain]],
  [5, ["Level", defRng]],
  ], [1,2])
const stPhaser2 = fxInit("St Phaser 2", [
  [0, ["Type", xvopts(["1","2"])]],
  [1, ["Mode", xvopts(["4 Stage", "8 Stage", "12 Stage", "16 Stage"])]],
  [2, ["Polarity", xvopts(["Inverse", "Synchro"])]],
  [3, ["Rate", phaserRate]],
  [4, ["Depth", defRng]],
  [5, ["Manual", defRng]],
  [6, ["Resonance", defRng]],
  [7, ["X-Feedback", fdbk]],
  [8, ["Step", offOnParam]],
  [9, ["Step Rate", phaserStepRateOptions]],
  [10, ["Mix Level", defRng]],
  [11, ["Low Gain", gain]],
  [12, ["High Gain", gain]],
  [13, ["Level", defRng]],
  ], [3,5,9])
const stAutoWah = fxInit("St Auto Wah", [
  [0, ["Filter", xvopts(["LPF","BPF"])]],
  [1, ["Rate", phaserRate]],
  [2, ["Depth", defRng]],
  [3, ["Sens", defRng]],
  [4, ["Manual", defRng]],
  [5, ["Peak", defRng]],
  [6, ["Polarity", xvopts(["Up", "Down"])]],
  [7, ["Phase", phaseParam]],
  [8, ["Low Gain", gain]],
  [9, ["High Gain", gain]],
  [10, ["Level", defRng]],
  ], [1,2,3,4,7])
const stFormantFilter = fxInit("St Formn Flt", [
  [0, ["Drive", offOnParam]],
  [1, ["Drive", defRng]],
  [2, ["Vowel 1", vowelParam]],
  [3, ["Vowel 2", vowelParam]],
  [4, ["Rate", phaserRate]],
  [5, ["Depth", defRng]],
  [6, ["Phase", phaseParam]],
  [7, ["Keysync", offOnParam]],
  [8, ["Keysync Thresh", defRng]],
  [9, ["Manual", xvrange([0, 100])]],
  [10, ["Low Gain", gain]],
  [11, ["High Gain", gain]],
  [12, ["Level", defRng]],
  ], [1,4,5,6,9])
const multiTapDelay2 = fxInit("Mlt tap Dly2", [
  [0, ["Delay 1", delayTime3000Param]],
  [1, ["Delay 2", delayTime3000Param]],
  [2, ["Delay 3", delayTime3000Param]],
  [3, ["Delay 4", delayTime3000Param]],
  [4, ["Delay Pan 1", panParam]],
  [5, ["Delay Pan 2", panParam]],
  [6, ["Delay Pan 3", panParam]],
  [7, ["Delay Pan 4", panParam]],
  [8, ["Delay Level 1", defRng]],
  [9, ["Delay Level 2", defRng]],
  [10, ["Delay Level 3", defRng]],
  [11, ["Delay Level 4", defRng]],
  [12, ["Feedback", fdbk]],
  [13, ["HF Damp", fx200to8kBypassParam]],
  [14, ["Low Gain", gain]],
  [15, ["High Gain", gain]],
  [16, ["Balance", balance]],
  [17, ["Level", defRng]],
  ], [12,16])
const reverseDelay2 = fxInit("Reverse Dly2", [
  [0, ["Threshold", defRng]],
  [1, ["Delay 1", delayTime1500Param]],
  [2, ["Delay 2", delayTime1500Param]],
  [3, ["Delay 3", delayTime1500Param]],
  [4, ["Delay 4", delayTime1500Param]],
  [5, ["Feedback 1", fdbk]],
  [6, ["Feedback 4", fdbk]],
  [7, ["HF Damp 1", fx200to8kBypassParam]],
  [8, ["HF Damp 4", fx200to8kBypassParam]],
  [9, ["Delay Pan 1", panParam]],
  [10, ["Delay Pan 2", panParam]],
  [11, ["Delay Pan 3", panParam]],
  [12, ["Delay Level 1", defRng]],
  [13, ["Delay Level 2", defRng]],
  [14, ["Delay Level 3", defRng]],
  [15, ["Balance", balance]],
  [16, ["Low Gain", gain]],
  [17, ["High Gain", gain]],
  [18, ["Level", defRng]],
  ], [5,6,15])
const shuffleDelay2 = fxInit("Shuffle Dly2", [
  [0, ["Delay", delayTime3000Param]],
  [1, ["Shuffle Rate", xvrange([0, 100])]],
  [2, ["Pan A", panParam]],
  [3, ["Pan B", panParam]],
  [4, ["Level Bal", xvrange([0, 100])]],
  [5, ["Feedback", fdbk]],
  [6, ["Acceleration", accelParam]],
  [7, ["HF Damp", fx200to8kBypassParam]],
  [8, ["Low Gain", gain]],
  [9, ["High Gain", gain]],
  [10, ["Balance", balance]],
  [11, ["Level", defRng]],
  ], [0,1,5,10])
const threeDDelay2 = fxInit("3D Delay 2", [
  [0, ["Delay L", delayTime3000Param]],
  [1, ["Delay R", delayTime3000Param]],
  [2, ["Delay C", delayTime3000Param]],
  [3, ["Level L", defRng]],
  [4, ["Level R", defRng]],
  [5, ["Level C", defRng]],
  [6, ["Feedback", fdbk]],
  [7, ["HF Damp", fx200to8kBypassParam]],
  [8, ["Output Mode", threeDOutParam]],
  [9, ["Low Gain", gain]],
  [10, ["High Gain", gain]],
  [11, ["Balance", balance]],
  [12, ["Level", defRng]],
  ], [6,11])
const rotary2 = fxInit("Rotary 2", [
  [0, ["Low Slow", phaserRate]],
  [1, ["Low Fast", phaserRate]],
  [2, ["Low Trans Up", defRng]],
  [3, ["Low Trans Down", defRng]],
  [4, ["Low Level", defRng]],
  [5, ["High Slow", phaserRate]],
  [6, ["High Fast", phaserRate]],
  [7, ["High Trans Up", defRng]],
  [8, ["High Trans Down", defRng]],
  [9, ["High Level", defRng]],
  [10, ["Speed", xvopts(["Slow", "Fast"])]],
  [11, ["Brake", offOnParam]],
  [12, ["Spread", xvrange([0, 10])]],
  [13, ["Low Gain", gain]],
  [14, ["High Gain", gain]],
  [15, ["Level", defRng]],
  ], [10,11,15])
const rotaryMulti = fxInit("Rotary Multi", [
  [0, ["OD/Dist", offOnParam]],
  [1, ["Type", xvopts(["OD","Dist"])]],
  [2, ["Drive", defRng]],
  [3, ["Tone", defRng]],
  [4, ["Level", defRng]],
  [5, ["Amp Sim", offOnParam]],
  [6, ["Amp Type", ampSimpleParam]],
  [7, ["EQ", offOnParam]],
  [8, ["Low Gain", gain]],
  [9, ["Mid Freq", fx200to8kParam]],
  [10, ["Mid Q", midQParam]],
  [11, ["Mid Gain", gain]],
  [12, ["High Gain", gain]],
  [13, ["Rotary", offOnParam]],
  [14, ["High Freq Slow", phaserRate]],
  [15, ["Low Freq Slow", phaserRate]],
  [16, ["High Freq Fast", phaserRate]],
  [17, ["Low Freq Fast", phaserRate]],
  [18, ["Speed", xvopts(["Slow","Fast"])]],
  [19, ["High Freq Accel", accelParam]],
  [20, ["Low Freq Accel", accelParam]],
  [21, ["High Freq Level", defRng]],
  [22, ["Low Freq Level", defRng]],
  [23, ["Separation", defRng]],
  [24, ["Pan", panParam]],
  [25, ["Out Level", defRng]],
  ], [2,18])
const keyMulti = fxInit("Keybd Multi", [
  [0, ["Ring Mod", offOnParam]],
  [1, ["Freq", defRng]],
  [2, ["RM Bal", balance]],
  [3, ["EQ", offOnParam]],
  [4, ["Low Gain", gain]],
  [5, ["Mid Freq", fx200to8kParam]],
  [6, ["Mid Q", midQParam]],
  [7, ["Mid Gain", gain]],
  [8, ["High Gain", gain]],
  [9, ["Pitch Shift", offOnParam]],
  [10, ["Mode", xvrange([1, 5])]],
  [11, ["Coarse", coarse]],
  [12, ["Fine", fineParam]],
  [13, ["Dly", delayTime500]],
  [14, ["Feedback", fdbk]],
  [15, ["Balance", balance]],
  [16, ["Phaser", offOnParam]],
  [17, ["Mode", xvopts(["4 Stage","8 Stage"])]],
  [18, ["Manual", defRng]],
  [19, ["Ph Rate", phaserRate]],
  [20, ["Depth", defRng]],
  [21, ["Resonance", defRng]],
  [22, ["Mix", defRng]],
  [23, ["Delay", offOnParam]],
  [24, ["Time L", delayTime3000Param]],
  [25, ["Time R", delayTime3000Param]],
  [26, ["Feedback", fdbk]],
  [27, ["HF Damp", fx200to8kBypassParam]],
  [28, ["Dly Bal", balance]],
  [29, ["Out Level", defRng]],
  ], [1,2,11,14,18,19,28])
const rhodesMulti = fxInit("Rhodes Multi", [
  [0, ["Enhancer", offOnParam]],
  [1, ["Sens", defRng]],
  [2, ["Mix", defRng]],
  [3, ["Phaser", offOnParam]],
  [4, ["Mode", xvopts(["4 Stage","8 Stage"])]],
  [5, ["Manual", defRng]],
  [6, ["Rate", defRng]],
  [7, ["Depth", defRng]],
  [8, ["Resonance", defRng]],
  [9, ["Mix", defRng]],
  [10, ["Cho/Flg", offOnParam]],
  [11, ["Type", choFlgParam]],
  [12, ["Pre Dly", delayTime100]],
  [13, ["Rate", phaserRate]],
  [14, ["Depth", defRng]],
  [15, ["Feedback", fdbk]],
  [16, ["Filter", filterType]],
  [17, ["Cutoff", fx200to8kParam]],
  [18, ["C/F Bal", balance]],
  [19, ["Tre/Pan", offOnParam]],
  [20, ["Type", xvopts(["Tremolo", "Pan"])]],
  [21, ["Mod Wave", modWaveParam]],
  [22, ["T/P Rate", phaserRate]],
  [23, ["T/P Depth", defRng]],
  [24, ["Out Level", defRng]],
  ], [1,5,6,18,22,23])
const jdMulti = fxInit("Jd Multi", [
  [0, ["Sequence", xvopts(["DS-PH-SP-EN", "DS-PH-EN-SP", "DS-SP-PH-EN", "DS-SP-EN-PH", "DS-EN-PH-SP", "DS-EN-SP-PH", "PH-DS-SP-EN", "PH-DS-EN-SP", "PH-SP-DS-EN", "PH-SP-EN-DS", "PH-EN-DS-SP", "PH-EN-SP-DS", "SP-DS-PH-EN", "SP-DS-EN-PH", "SP-PH-DS-EN", "SP-PH-EN-DS", "SP-EN-DS-PH", "SP-EN-PH-DS", "EN-DS-PH-SP", "EN-DS-SP-PH", "EN-PH-DS-SP", "EN-PH-SP-DS", "EN-SP-DS-PH", "EN-SP-PH-DS"])]],
  [1, ["Dist", offOnParam]],
  [2, ["Type", xvopts(["Mellow Drive", "Overdrive", "Cry Drive", "Mellow Dist", "Light Dist", "Fat Dist", "Fuzz Dist"])]],
  [3, ["Drive", xvrange([0, 100])]],
  [4, ["Level", xvrange([0, 100])]],
  [5, ["Phaser", offOnParam]],
  [6, ["Manual", xvopts({
    var options = ([0, 25]).map { "\(50 + $0 * 10)" }
    options += ([0, 23]).map { "\(320 + $0 * 30)" }
    options += ([0, 35]).map { "\(1100 + $0 * 200)" }
    options += ([0, 13]).map { "\(8500 + $0 * 500)" }
    return options
    }())]],
  [7, ["Rate", xvmiso([1, 100], Miso.m(0.1]], >>> Miso.round(1))),
  [8, ["Depth", xvrange([0, 100])]],
  [9, ["Resonance", xvrange([0, 100])]],
  [10, ["Ph Mix", xvrange([0, 100])]],
  [11, ["Spectrum", offOnParam]],
  [12, ["250Hz", gain]],
  [13, ["500Hz", gain]],
  [14, ["1kHz", gain]],
  [15, ["2kHz", gain]],
  [16, ["4kHz", gain]],
  [17, ["8kHz", gain]],
  [18, ["Width", xvrange([1, 5])]],
  [19, ["Enhancer", offOnParam]],
  [20, ["Sens", xvrange([0, 100])]],
  [21, ["Enh Mix", xvrange([0, 100])]],
  [22, ["Pan", panParam]],
  [23, ["Out Level", defRng]],
  ], [3,6,7,8,9,10,21])
const stLofiComp = fxInit("St Lofi Comp", [
  [0, ["Pre Filter", xvrange([1, 6])]],
  [1, ["LoFi Type", xvrange([1, 9])]],
  [2, ["Post Filter 1", xvrange([1, 6])]],
  [3, ["Post Filter 2", filterType]],
  [4, ["Post Cutoff", fx200to8kParam]],
  [5, ["Balance", balance]],
  [6, ["Low Gain", gain]],
  [7, ["High Gain", gain]],
  [8, ["Level", defRng]],
  ], [5])
const stLofiNoise = fxInit("St Lofi Noiz", [
  [0, ["LoFi Type", xvrange([1, 9])]],
  [1, ["Post Filter", filterType]],
  [2, ["Cutoff", fx200to8kParam]],
  [3, ["Radio Detune", defRng]],
  [4, ["RadioNoise Level", defRng]],
  [5, ["Noise Type", xvopts(["White","Pink"])]],
  [6, ["W/P LPF", fx200to8kBypassParam]],
  [7, ["White/Pink Level", defRng]],
  [8, ["Disc N Type", xvopts(["LP","EP","SP","RND"])]],
  [9, ["Disc N LPF", fx200to8kBypassParam]],
  [10, ["Disc N Level", defRng]],
  [11, ["Hum N Type", xvopts(["50","60"])]],
  [12, ["Hum N LPF", fx200to8kBypassParam]],
  [13, ["Hum N Level", defRng]],
  [14, ["Balance", balance]],
  [15, ["Low Gain", gain]],
  [16, ["High Gain", gain]],
  [17, ["Level", defRng]],
  ], [3,14])
const gtrAmpSim = fxInit("Gtr amp Sim", [
  [0, ["Amp Simulator", offOnParam]],
  [1, ["Amp Type", ampSimParam]],
  [2, ["Amp Volume", defRng]],
  [3, ["Amp Master Vol", defRng]],
  [4, ["Amp Gain", xvopts(["Low", "Middle", "High"])]],
  [5, ["Amp Bass", defRng]],
  [6, ["Amp Middle", defRng]],
  [7, ["Amp Treble", defRng]],
  [8, ["Amp Presence", defRng]],
  [9, ["Amp Bright", offOnParam]],
  [10, ["Speaker", offOnParam]],
  [11, ["Sp Type", speakerSimParam]],
  [12, ["Mic Setting", xvrange([1, 3])]],
  [13, ["Mic Level", defRng]],
  [14, ["Direct Level", defRng]],
  [15, ["Pan", panParam]],
  [16, ["Level", defRng]],
  ], [2,3,15,16])
const stOverdrive = fxInit("Stereo OD", [
  [0, ["Drive", defRng]],
  [1, ["Tone", defRng]],
  [2, ["Amp", offOnParam]],
  [3, ["Amp Type", ampSimpleParam]],
  [4, ["Low Gain", gain]],
  [5, ["High Gain", gain]],
  [6, ["Level", defRng]],
  ], [0])
const stDistortion = fxInit("Stereo Dist", stOverdrive.params, stOverdrive.dests)
const gtrMultiA = fxInit("Gtr Multi A", [
  [0, ["Compressor", offOnParam]],
  [1, ["Attack", defRng]],
  [2, ["Sustain", defRng]],
  [3, ["Cmp Level", defRng]],
  [4, ["OD/Dist", offOnParam]],
  [5, ["Type", odDistParam]],
  [6, ["Drive", defRng]],
  [7, ["Tone", defRng]],
  [8, ["Level", defRng]],
  [9, ["Amp Simulator", offOnParam]],
  [10, ["Type", ampSimpleParam]],
  [11, ["Delay", offOnParam]],
  [12, ["Time L", delayTime3000Param]],
  [13, ["Time R", delayTime3000Param]],
  [14, ["Feedback", fdbk]],
  [15, ["HF Damp", fx200to8kBypassParam]],
  [16, ["Dly Balance", balance]],
  [17, ["Cho/Flg", offOnParam]],
  [18, ["Type", choFlgParam]],
  [19, ["PreDly", delayTime100]],
  [20, ["Rate", phaserRate]],
  [21, ["Depth", defRng]],
  [22, ["Feedback", fdbk]],
  [23, ["Filter", filterType]],
  [24, ["Cutoff", fx200to8kParam]],
  [25, ["C/F Balance", balance]],
  [26, ["Pan", panParam]],
  [27, ["Out Level", defRng]],
  ], [3,6,16,25])
const gtrMultiB = fxInit("Gtr Multi B", [
  [0, ["Compressor", offOnParam]],
  [1, ["Attack", defRng]],
  [2, ["Sustain", defRng]],
  [3, ["Cmp Level", defRng]],
  [4, ["OD/Dist", offOnParam]],
  [5, ["Type", odDistParam]],
  [6, ["Drive", defRng]],
  [7, ["Tone", defRng]],
  [8, ["Level", defRng]],
  [9, ["Amp Simulator", offOnParam]],
  [10, ["Type", ampSimpleParam]],
  [11, ["EQ", offOnParam]],
  [12, ["Low Gain", gain]],
  [13, ["Mid Freq", fx200to8kParam]],
  [14, ["Mid Q", midQParam]],
  [15, ["Mid Gain", gain]],
  [16, ["High Gain", gain]],
  [17, ["Cho/Flg", offOnParam]],
  [18, ["Type", choFlgParam]],
  [19, ["PreDly", defRng]],
  [20, ["Rate", phaserRate]],
  [21, ["Depth", defRng]],
  [22, ["Feedback", fdbk]],
  [23, ["Filter", filterType]],
  [24, ["Cutoff", fx200to8kParam]],
  [25, ["C/F Balance", balance]],
  [26, ["Pan", panParam]],
  [27, ["Out Level", defRng]],
  ], [3,6,25])
const gtrMultiC = fxInit("Gtr Multi C", [
  [0, ["OD/Dist", offOnParam]],
  [1, ["Type", odDistParam]],
  [2, ["Drive", defRng]],
  [3, ["Tone", defRng]],
  [4, ["Level", defRng]],
  [5, ["Wah", offOnParam]],
  [6, ["Wah Filter", xvopts(["LPF", "BPF"])]],
  [7, ["Rate", phaserRate]],
  [8, ["Depth", defRng]],
  [9, ["Sens", defRng]],
  [10, ["Manual", defRng]],
  [11, ["Peak", defRng]],
  [12, ["Amp Simulator", offOnParam]],
  [13, ["Type", ampSimpleParam]],
  [14, ["Delay", offOnParam]],
  [15, ["Time L", delayTime3000Param]],
  [16, ["Time R", delayTime3000Param]],
  [17, ["Feedback", fdbk]],
  [18, ["HF Damp", fx200to8kBypassParam]],
  [19, ["Dly Bal", balance]],
  [20, ["Cho/Flg", offOnParam]],
  [21, ["Type", choFlgParam]],
  [22, ["PreDly", delayTime100]],
  [23, ["Rate", phaserRate]],
  [24, ["Depth", defRng]],
  [25, ["Feedback", fdbk]],
  [26, ["Filter", filterType]],
  [27, ["Cutoff", fx200to8kParam]],
  [28, ["C/F Balance", balance]],
  [29, ["Pan", panParam]],
  [30, ["Out Level", defRng]],
  ], [2,10,19,28])
const clGtrMltA = fxInit("Cl Gtr Mlt A", [
  [0, ["Compressor", offOnParam]],
  [1, ["Attack", defRng]],
  [2, ["Sustain", defRng]],
  [3, ["Cmp Level", defRng]],
  [4, ["EQ", offOnParam]],
  [5, ["Low Gain", gain]],
  [6, ["Mid Freq", fx200to8kParam]],
  [7, ["Mid Q", midQParam]],
  [8, ["Mid Gain", gain]],
  [9, ["High Gain", gain]],
  [10, ["Delay", offOnParam]],
  [11, ["Time L", delayTime3000Param]],
  [12, ["Time R", delayTime3000Param]],
  [13, ["Feedback", fdbk]],
  [14, ["HF Damp", fx200to8kBypassParam]],
  [15, ["Dly Balance", balance]],
  [16, ["Cho/Flg", offOnParam]],
  [17, ["Type", choFlgParam]],
  [18, ["PreDly", delayTime100]],
  [19, ["Rate", phaserRate]],
  [20, ["Depth", defRng]],
  [21, ["Feedback", fdbk]],
  [22, ["Filter", filterType]],
  [23, ["Cutoff", fx200to8kParam]],
  [24, ["C/F Balance", balance]],
  [25, ["Pan", panParam]],
  [26, ["Out Level", defRng]],
  ], [3,15,24])
const clGtrMltB = fxInit("Cl Gtr Mlt B", [
  [0, ["Wah", offOnParam]],
  [1, ["Wah Filter", xvopts(["LPF", "BPF"])]],
  [2, ["Rate", phaserRate]],
  [3, ["Depth", defRng]],
  [4, ["Sens", defRng]],
  [5, ["Manual", defRng]],
  [6, ["Peak", defRng]],
  [7, ["EQ", offOnParam]],
  [8, ["Low Gain", gain]],
  [9, ["Mid Freq", fx200to8kParam]],
  [10, ["Mid Q", midQParam]],
  [11, ["Mid Gain", gain]],
  [12, ["High Gain", gain]],
  [13, ["Delay", offOnParam]],
  [14, ["Time L", delayTime3000Param]],
  [15, ["Time R", delayTime3000Param]],
  [16, ["Feedback", fdbk]],
  [17, ["HF Damp", fx200to8kBypassParam]],
  [18, ["Dly Balance", balance]],
  [19, ["Cho/Flg", offOnParam]],
  [20, ["Type", choFlgParam]],
  [21, ["PreDly", delayTime100]],
  [22, ["Rate", phaserRate]],
  [23, ["Depth", defRng]],
  [24, ["Feedback", fdbk]],
  [25, ["Filter", filterType]],
  [26, ["Cutoff", fx200to8kParam]],
  [27, ["C/F Balance", balance]],
  [28, ["Pan", panParam]],
  [29, ["Out Level", defRng]],
  ], [5,18,27])
const bassMulti = fxInit("Bass Multi", [
  [0, ["Compressor", offOnParam]],
  [1, ["Attack", defRng]],
  [2, ["Sustain", defRng]],
  [3, ["Cmp Level", defRng]],
  [4, ["OD/Dist", offOnParam]],
  [5, ["Type", odDistParam]],
  [6, ["Drive", defRng]],
  [7, ["Level", defRng]],
  [8, ["Amp Simulator", offOnParam]],
  [9, ["Type", xvopts(["Small", "Built-in", "2 Stack"])]],
  [10, ["EQ", offOnParam]],
  [11, ["Low Gain", gain]],
  [12, ["Mid Freq", fx200to8kParam]],
  [13, ["Mid Q", midQParam]],
  [14, ["Mid Gain", gain]],
  [15, ["High Gain", gain]],
  [16, ["Cho/Flg", offOnParam]],
  [17, ["Type", choFlgParam]],
  [18, ["PreDly", delayTime100]],
  [19, ["Rate", phaserRate]],
  [20, ["Depth", defRng]],
  [21, ["Feedback", fdbk]],
  [22, ["Filter", filterType]],
  [23, ["Cutoff", fx200to8kParam]],
  [24, ["C/F Balance", balance]],
  [25, ["Pan", panParam]],
  [26, ["Out Level", defRng]],
  ], [3,6,24])
const isolator2 = fxInit("Isolator 2", [
  [0, ["Level High", isolatorGainParam]],
  [1, ["Level Middle", isolatorGainParam]],
  [2, ["Level Low", isolatorGainParam]],
  [3, ["AntiPhase Mid", offOnParam]],
  [4, ["AntiPhase MidLev", defRng]],
  [5, ["AntiPhase Low", offOnParam]],
  [6, ["AntiPhase Lo Lev", defRng]],
  [7, ["Filter Switch", offOnParam]],
  [8, ["Filter", xvopts(["LPF","BPF","HPF","Notch"])]],
  [9, ["Filter Slope", xvopts(["-12","-24"])]],
  [10, ["Cutoff", defRng]],
  [11, ["Resonance", defRng]],
  [12, ["Filter Gain", xvrange([0, 24])]],
  [13, ["Low Boost", offOnParam]],
  [14, ["Low Boost Level", defRng]],
  [15, ["Level", defRng]],
  ], [0,1,2])
const stSpectrum = fxInit("St Spectrum", [
  [0, ["250Hz", gain]],
  [1, ["500Hz", gain]],
  [2, ["1000Hz", gain]],
  [3, ["1250Hz", gain]],
  [4, ["2000Hz", gain]],
  [5, ["3150Hz", gain]],
  [6, ["4000Hz", gain]],
  [7, ["8000Hz", gain]],
  [8, ["Band Width Q", midQParam]],
  [9, ["Level", defRng]],
  ], [9])
const threeDAutoSpin = fxInit("3D Auto Spin", [
  [0, ["Azimuth", azimuthParam]],
  [1, ["Speed", phaserRate]],
  [2, ["Clockwise", xvopts(["-","+"])]],
  [3, ["Turn", offOnParam]],
  [4, ["Output Mode", threeDOutParam]],
  [5, ["Level", defRng]],
  ], [1,3])
const threeDManual = fxInit("3D Manual", [
  [0, ["Azimuth", azimuthParam]],
  [1, ["Output Mode", threeDOutParam]],
  [2, ["Level", defRng]],
  ], [0])


function xvrange(r = [0,127]) {
  return {
    rng: [32768, (32768 + (r[1] - r[0]))], 
    dispOff: r[0] - 32768,
  }
}

function xvopts(opts) {
  return {
    rng: [32768, (opts.length + 32768 - 1)], 
    iso: Miso.options(opts, startIndex: 32768),
  }
}

function xvmiso(r = [0, 127], iso) {
  return {
    rng: [(r[0] + 32768), (r[1] + 32768)], 
    iso: ['>', ['-', 32768], iso],
  }
}


function reverbPatchWerk(parms) {
  return {
    single: "Reverb", 
    parms: parms, 
    size: 0x53,
    // randomize: { [
    //   "level" : 127,
    //   "out/assign" : 0,
    // ] },
  }
}
    
const reverbParams = [
  [0, ["Type", xvopts(["Room 1","Room 2","Stage 1","Stage 2","Hall 1","Hall 2","Delay","Pan-Delay"])]],
  [1, ["Time", xvrange()]],
  [2, ["HF Damp", FX.fx200to8kBypassParam]],
  [3, ["Feedback", xvrange()]],
]

const srvParams = [
  [0, ["Pre Delay", FX.delayTime100]],
  [1, ["Time", xvrange()]],
  [2, ["Size", xvrange([1, 8])]],
  [3, ["High Cut", xvopts(["160","200","250","320","400","500","640", "800","1000","1250","1600","2000","2500","3200","4000","5000","6400","8000","10000","12500","Bypass"])]],
  [4, ["Density", xvrange()]],
  [5, ["Diffusion", xvrange()]],
  [6, ["LF Damp", xvopts(["50","64","80","100","125","160", "200","250","320","400","500","640", "800","1000","1250","1600","2000","2500","3200","4000","Bypass"])]],
  [7, ["LF Damp Gain", xvrange([-36, 0])]],
  [8, ["HF Damp", xvopts(["4000","5000","6400","8000","10000","12500","Bypass"])]],
  [9, ["HF Damp Gain", xvrange([-36, 0])]],
]

const gm2Params = [
  [0, ["Level", xvrange()]],
  [1, ["Character", xvrange([0, 7])]],
  [2, ["Pre-LPF", xvrange([0, 7])]],
  [3, ["Time", xvrange()]],
  [4, ["Dly Feedback", xvrange()]],
]

const reverbParamMap = [
  [],
  reverbParams,
  srvParams,
  srvParams,
  srvParams,
  gm2Params
]


// CHORUS

const delayTimeParam = xvopts(1001.map { "\($0)" } + FX.noteOptions)

function chorusPatchWerk(parms) {
  return {
    single: "Chorus",
    parms: parms, 
    size: 0x34, 
    // randomize: { [
    //   "level" : 127,
    //   "out/assign" : 0,
    // ] },
  }
}

const chorusParams = [
  [0, ["Rate", FX.rateParam]],
  [1, ["Depth", xvrange()]],
  [2, ["PreDly", FX.delayTime100]],
  [3, ["Feedback", xvrange()]],
  [4, ["Filter", FX.filterType]],
  [5, ["Cutoff", FX.fx200to8kParam]],
  [6, ["Phase", FX.phaseParam]],
]

const delayParams = [
  [0, ["Delay L", delayTimeParam]],
  [1, ["Delay R", delayTimeParam]],
  [2, ["Delay C", delayTimeParam]],
  [3, ["Feedback", FX.fdbk]],
  [4, ["HF Damp", FX.fx200to8kBypassParam]],
  [5, ["L Level", xvrange()]],
  [6, ["R Level", xvrange()]],
  [7, ["C Level", xvrange()]],
  ]

const gm2Params = [
  [0, ["Level", xvrange()]],
  [1, ["Feedback", xvrange()]],
  [2, ["Pre-LPF", xvrange([0, 127])]],
  [3, ["Delay", xvrange()]],
  [4, ["Rate", xvrange()]],
  [5, ["Depth", xvrange()]],
  [6, ["Reverb Send", xvrange()]],
  ]

const chorusParamMap = [
  [],
  chorusParams,
  delayParams,
  gm2Params
]


function fxInit(name, parms, dests) {
  var opts = [Int:String]()
  opts[0] = "Off"
  dests.enumerated().forEach { opts[$0.offset + 1] = params[$0.element]?.0 ?? "?" }
  return {
    name: name,
    parms: Array.sparse(parms),
    dests: dests,
    destOptions: opts,
  }
}

function patchWerk(parms) {
  return {
    single: "FX",
    parms: parms, 
    size: 0x111, 
    // randomize: {
    //   let t = ([0, 63]).rand()
    //   let fx = allFx[t]
    //   return [
    //     "out" : 0,
    //     "dry" : ([64, 127]).rand(),
    //     "chorus" : ([64, 127]).rand(),
    //     "reverb" : ([64, 127]).rand(),
    //     "type" : t,
    //   ] <<< 4.dict {
    //     ["ctrl/$0/amt" : 64]
    //   } <<< 32.dict {
    //     guard let param = fx.params[$0]?.1 as? ParamWithRange else {
    //       return ["param/$0" : 32768]
    //     }
    //     return ["param/$0" : param.range.rand()]
    //   }
    // }
  }
}

functions fxDisplayName(index) {
  return `${index}: ${allFx[index].name}`
}
