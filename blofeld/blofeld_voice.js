require('./utils.js')
const Blofeld = require('./blofeld.js')

//  const tempBankIndex = 0x7f
    

const waveforms = (["off", "Pulse", "Saw", "Triangle", "Sine", "Alt 1", "Alt 2", "Resonant", "Resonant2", "MalletSyn", "Sqr-Sweep", "Bellish", "Pul-Sweep", "Saw-Sweep", "MellowSaw", "Feedback", "Add Harm", "Reso 3 HP", "Wind Syn", "High Harm", "Clipper", "Organ Syn", "SquareSaw", "Formant 1", "Polated", "Transient", "ElectricP", "Robotic", "StrongHrm", "PercOrgan", "ClipSweep", "ResoHarms", "2 Echoes", "Formant 2", "FmntVocal", "MicroSync", "Micro PWM", "Glassy", "Square HP", "SawSync 1", "SawSync 2", "SawSync 3", "PulSync 1", "PulSync 2", "PulSync 3", "SinSync 1", "SinSync 2", "SinSync 3", "PWM Pulse", "PWM Saw", "Fuzz Wave", "Distorted", "HeavyFuzz", "Fuzz Sync", "K+Strong1", "K+Strong2", "K+Strong3", "1-2-3-4-5", "19/twenty", "Wavetrip1", "Wavetrip2", "Wavetrip3", "Wavetrip4", "MaleVoice", "Low Piano", "ResoSweep", "Xmas Bell", "FM Piano", "Fat Organ", "Vibes", "Chorus 2", "True PWM", "UpperWaves"]).concat(
  (13).map(i => `Rsrvd ${i + 67}`),
  (39).map(i => `User WT ${i + 80}`)
)
  
const samples = (128).map(i => `Sample ${i + 1}`)
  
const oscOctaves = Array.sparse([
  [16, "128'"],
  [28, "64'"],
  [40, "32'"],
  [52, "16'"],
  [64, "8'"],
  [76, "4'"],
  [88, "2'"],
  [100, "1'"],
  [112, "1/2'"],
])
  
  const osc3Waveforms = ["off","Pulse","Saw","Triangle","Sine"]
  
  const keytrackIso = ['>', ['*', 396.0/127], 'round', ['-', 200], ['switch', [
    [99, 100],
  ], '='], ['units', "%"]]
  
  const fmSources = ["off", "Osc 1", "Osc 2", "Osc 3", "Noise", "LFO 1", "LFO 2", "LFO 3", "FilterEnv", "AmpEnv", "Env3", "Env4"]
  
  const glideModes = ["Portamento","fingered P","Glissando","fingered G"]
  
  const filterBalanceIso = ['switch', [
    [[0, 64], ['>', ['*', -1], ['+', 64], ['units', " F1"]]],
    [64, "Bal"],
    [[65, 128], ['>', ['-', 64], ['units', " F2"]]],
  ]]
  
  const filterTypes = [
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
  ]
  
  const filterRoutings = ["Parallel", "Serial"]
  
  const lfoShapes = [
    "Sine",
    "Triangle",
    "Square",
    "Saw",
    "Random",
    "S&H",
  ]
  
  const lfoRateIso = ['>', ['*', 0.5], 'floor', ['switch', [
    [[0, 47], ['>', ['@', [1280, 1152, 1024, 896, 768, 640, 576, 512, 448, 384, 320, 288, 256, 224, 192, 160, 144, 128, 112, 96, 80, 72, 64, 56, 48, 40, 36, 32, 28, 24, 20, 18, 16, 14, 12, 10, 9, 8, 7, 6, 5, 4, 3.5, 3, 2.5, 2, 1.5]], ['units', "bars"]]],
    [47, ['>', ['-', 46], ['units', "bar"]]],
    [[48, 64], ['options', ["1/2.", "1/1T", "1/2 ", "1/4.", "1/2T", "1/4 ", "1/8.", "1/4T", "1/8 ", "1/16.", "1/8T", "1/16 ", "1/32.", "1/16T", "1/32 ", "1/48"], {startIndex: 48}]],
  ]]]
    
  const modSources = ["Off", "LFO 1", "LFO1*MW", "LFO 2", "LFO2*Press", "LFO 3", "FilterEnv", "AmpEnv", "Env3", "Env4", "Keytrack", "Velocity", "Rel. Velo", "Pressure", "Poly Press", "Pitch Bend", "Mod Wheel", "Sustain", "Foot Ctrl", "BreathCtrl", "Control W", "Control X", "Control Y", "Control Z", "Unisono V.", "Modifier 1", "Modifier 2", "Modifier 3", "Modifier 4", "minimum", "MAXIMUM"]
  
  const modDestinations = ["Pitch", "O1 Pitch", "O1 FM", "O1 PW/Wave", "O2 Pitch", "O2 FM", "O2 PW/Wave", "O3 Pitch", "O3 FM", "O3 PW", "O1 Level", "O1 Balance", "O2 Level", "O2 Balance", "O3 Level", "O3 Balance", "RMod Level", "RMod Bal.", "NoiseLevel", "Noise Bal.", "F1 Cutoff", "F1 Reson.", "F1 FM", "F1 Drive", "F1 Pan", "F2 Cutoff", "F2 Reson.", "F2 FM", "F2 Drive", "F2 Pan", "Volume", "LFO1Speed", "LFO2Speed", "LFO3Speed", "FE Attack", "FE Decay", "FE Sustain", "FE Release", "AE Attack", "AE Decay", "AE Sustain", "AE Release", "E3 Attack", "E3 Decay", "E3 Sustain", "E3 Release", "E4 Attack", "E4 Decay", "E4 Sustain", "E4 Release", "M1 Amount", "M2 Amount", "M3 Amount", "M4 Amount", "O1 WT/Smp", "O2 WT/Smp",]
  
const modOperators = ["+", "-", "*", "AND", "OR", "XOR", "MAX", "min"]
  
const unisonModes = ["off", "dual", "3", "4", "5", "6"]

const allocations = ["Poly","Mono"]
  
const driveCurves = ["Clipping", "Tube", "Hard", "Medium", "Soft", "Pickup 1", "Pickup 2", "Rectifier", "Square", "Binary", "Overflow", "Sine Shaper", "Osc 1 Mod"]
  
const envelopeTriggers = ["normal", "single"]
  
  // case ADSR = 0
  // case ADS1DS2R = 1
  // case OneShot = 2
  // case LoopS1S2 = 3
  // case LoopAll = 4

const envelopeModes = [
  "ADSR",
  "ADS1DS2R",
  "One Shot",
  "Loop S1S2",
  "Loop All"
]

const arpModes = ["Off", "On", "One Shot", "Hold"]

const arpDirections = ["Up", "Down", "Alt Up", "Alt Down"]

const arpClocks = ["1/96", "1/48", "1/32 ", "1/16T", "1/32.", "1/16 ", "1/8T", "1/16.", "1/8 ", "1/4T", "1/8.", "1/4 ", "1/2T", "1/4.", "1/2 ", "1/1T", "1/2.", "1 bar", "1.5 bars", "2 bars", "2.5 bars", "3 bars", "3.5 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars", "9 bars", "10 bars", "12 bars", "14 bars", "16 bars", "18 bars", "20 bars", "24 bars", "28 bars", "32 bars", "36 bars", "40 bars", "48 bars", "56 bars", "64 bars"]
  
const arpSorts = ["as played", "reversed", "Key Lo>Hi", "Key Hi>Lo", "Vel Lo>Hi", "Vel Hi>Lo"]

const arpVeloModes = ["Each Note", "First Note", "Last Note", "fix 32", "fix 64", "fix 100", "fix 127"]

const arpSteps = ["Normal", "Pause", "Previous", "First", "Last", "First+Last", "Chord", "Random"]

const arpStepLengths = ["Legato", "-3", "-2", "-1", "0", "1", "2", "3"]

const arpStepTimings = ["Random", "-3", "-2", "-1", "0", "1", "2", "3"]

const tempoIso = ['>', ['switch', ([
  [[0, 26], ['lerp', [0, 25], [40, 90]]],
  [[26, 101], ['lerp', [26, 100], [91, 165]]],
  [[101, 128], ['lerp', [101, 127], [170, 300]]],
])], 'round']

const arpAccentIso = ["❌", "↓↓↓", "↓↓", "↓", "-", "↑", "↑↑", "↑↑↑"]

const arpTimingIso = ["Random", "-3", "-2", "-1", "0", "1", "2", "3"]

const arpLenIso = ["Legato", "-3", "-2", "-1", "0", "1", "2", "3"]


const arpPatterns = ["Off", "User", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]

const arpLengths = ["1/96", "1/48", "1/32", "1/16T", "1/32.", "1/16", "1/8T", "1/16.", "1/8", "1/4T", "1/8.", "1/4", "1/2T", "1/4.", "1/2", "1/1T", "1/2.", "1 bar", "1.5 bars", "2 bars", "2.5 bars", "3 bars", "3.5 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars", "9 bars", "10 bars", "12 bars", "14 bars", "16 bars", "18 bars", "20 bars", "24 bars", "28 bars", "32 bars", "36 bars", "40 bars", "48 bars", "56 bars", "64 bars", "legato"]
  
// const arpTempos = {
// var options = [String]()
// // 40...90 by 2
// stride(from: 40, to: 90, by: 2).forEach { options.append("\($0)") }
// //91...165 by 1
// stride(from: 90, to: 165, by: 1).forEach { options.append("\($0)") }
// // 170...300 by 5
// stride(from: 165, to: 301, by: 5).forEach { options.append("\($0)") }
// return options
// }()

const phaseIso = ['switch', [
  [0, "Free"],
], ['>', ['lerp', [1, 128], [0, 361]], 'round', ['units', "°"]]]


const categorys = ["Init", "Arp ", "Atmo", "Bass", "Drum", "FX  ", "Keys", "Lead", "Mono", "Pad ", "Perc", "Poly", "Seq"]

const effectTypes = ["Bypass", "Chorus", "Flanger", "Phaser", "Overdrive", "Triple FX"]

const effect2Types = ["Bypass", "Chorus", "Flanger", "Phaser", "Overdrive", "Triple FX", "Delay", "Clk.Delay", "Reverb"]

const polarities = ["+","-"]
    
const overdriveCurves = ["Clipping","Tube","Hard","Medium","Soft","Pickup 1","Pickup 2","Rectifier","Square","Binary","Overflow","Sine Shaper"]
      
const clockedDelayLengths = ["1/96", "1/48", "1/32 ", "1/16T", "1/32.", "1/16 ", "1/8T", "1/16.", "1/8 ", "1/4T", "1/8.", "1/4 ", "1/2T", "1/4.", "1/2 ", "1/1T", "1/2.", "1 bar", "1.5 bars", "2 bars", "2.5 bars", "3 bars", "3.5 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars", "9 bars", "10 bars"]

  
// these are for effect 2. for effect 1, subtract 16 from parm
const chorusParams = [
  {b: 146, l: "Speed"},
  {b: 147, l: "Depth"},
]

const flangerParams = [
  {b: 146, l: "Speed"}, // 0..127 0..127
  {b: 147, l: "Depth"}, // 0..127 0..127
  {b: 150, l: "Feedback"}, // 0..127 0..127
  {b: 154, l: "Polarity", opts: polarities}, // 0..1 positive,negative
]

const phaserParams = [
  {b: 146 , l: "Speed"}, // 0..127 0..127
  {b: 147 , l: "Depth"}, // 0..127 0..127
  {b: 151 , l: "Center"}, // 0..127 0..127
  {b: 152 , l: "Spacing"}, // 0..127 0..127
  {b: 150 , l: "Feedback"}, // 0..127 0..127
  {b: 154 , l: "Polarity", opts: polarities}, // 0..1 positive,negative
]

const overdriveParams = [
  {b: 147, l: "Drive"}, // 0..127 0..127
  {b: 148, l: "Post Gain"}, // 0..127 0..127
  {b: 151, l: "Cutoff"}, // 0..127 0..127
  {b: 155, l: "Curve", opts: overdriveCurves}, // 0..11 Clipping..Sine Shaper
]

const freqFormatIso = [['switch', [
  [[0, 1000], ['>', ['round', 1], ['units', "Hz"]]],
  [[1000, 10001], ['>', ['*', 0.001], ['round', 2], ['units',"k"]]],
], ['>', ['*', 0.001], ['round', 1], ['units', "k"]]]]

const tripleFXParams = [
  {b: 150, l: "S&H"},
  {b: 151, l: "Overdrive"}, // 0..127 0..127
  {b: 149, l: "Chorus Mix"}, // 0..127 0..127
  {b: 146, l: "←Speed"}, // 0..127 0..127
  {b: 147, l: "←Depth"}, // 0..127 0..127
]
    
const delayParams = [
  {b: 149, l: "Length"}, // non-Clocked len
  {b: 150, l: "Feedback"}, // 0..127 0..127
  {b: 154, l: "Polarity", opts: polarities}, // 0..1 positive,negative
  {b: 151, l: "Cutoff"}, // 0..127 0..127
  {b: 155, l: "Spread", dispOff: -64},
]

const clockedDelayParams = [
  {b: 150, l: "Feedback"}, // 0..127 0..127
  {b: 151, l: "Cutoff"}, // 0..127 0..127
  {b: 154, l: "Polarity", opts: polarities}, // 0..1 positive,negative
  {b: 155, l: "Spread", dispOff: -64}, // 0..127 -64..+63
  {b: 156, l: "Length", opts: clockedDelayLengths} // 0..29 1/96..10 bars
]

const reverbParams = [
  {b: 152, l: "Highpass"},
  {b: 151, l: "Lowpass"},
  {b: 153, l: "Diffusion"},
  {b: 146, l: "Size"},
  {b: 147, l: "Shape"},
  {b: 148, l: "Decay"},
  {b: 154, l: "Damping"},
]


const parms = [
  { prefix: "osc", count: 3, bx: 16, block: i => (
    { inc: 1, b: 1, block: [
      ["octave", {opts: oscOctaves}],
      ["coarse", { rng: [52, 77], dispOff: -64 }],
      ["fine", { dispOff: -64}],
      ["bend", { rng: [40, 89], dispOff: -64}],
      ["keyTrk", { iso: keytrackIso }],
      ["fm/src", { opts: fmSources}],
      ["fm/amt", {}],
      ["shape", { opts: i == 2 ? osc3Waveforms : waveforms}],
      ["pw", {}],
      ["pw/src", { opts: modSources}],
      ["pw/amt", { dispOff: -64}],
    ] }
  ) },
  { prefix: "osc", count: 2, bx: 16, block:
    { inc: 1, b: 14, block: [
      ["limitWT", {opts: ["On", "Off"]}],
      ["sample", {opts: ["WT","Sample"]}],
      ["brilliance", {}],
    ] }
  },
  { inc: 1, b: 48, block: [
    ["osc/2/brilliance", {}],
    ["osc/2/sync", {max: 1}],
    ["pitch/src", {opts: modSources}],
    ["pitch/amt", {dispOff: -64}],
  ] },
  ["glide/on", {b: 53, max: 1}],
  ["glide/mode", {b: 56, opts: glideModes}],
  ["glide/rate", {b: 57}],
  ["mono", {b: 58, bit: 0}],
  ["unison", {b: 58, bits: [4, 7], opts: unisonModes}],
  ["unison/detune", {b: 59}],
  { prefix: "osc", count: 3, bx: 2, block:
    { inc: 1, b: 61, block: [
      ["level", {}],
      ["balance", {iso: filterBalanceIso}],
    ] }
  },
  ["noise/level", {b: 67}],
  ["noise/balance", {b: 68, iso: filterBalanceIso}],
  ["noise/color", {b: 69, dispOff: -64}],
  ["ringMod/level", {b: 71}],
  ["ringMod/balance", {b: 72, iso: filterBalanceIso}],
  { prefix: "filter", count: 2, bx: 20, block: [
    ["type", {b: 77, opts: filterTypes}],
    ["cutoff", {b: 78}],
    ["reson", {b: 80}],
    ["drive", {b: 81}],
    ["drive/curve", {b: 82, opts: driveCurves}],
    ["keyTrk", {b: 86, iso: keytrackIso}],
    ["env/amt", {b: 87, dispOff: -64}],
    ["velo", {b: 88, dispOff: -64}],
    ["cutoff/src", {b: 89, opts: modSources}],
    ["cutoff/amt", {b: 90, dispOff: -64}],
    ["fm/src", {b: 91, opts: fmSources}],
    ["fm/amt", {b: 92}],
    ["pan", {b: 93, dispOff: -64}],
    ["pan/src", {b: 94, opts: modSources}],
    ["pan/amt", {b: 95, dispOff: -64}],
  ] },
  ["filter/routing", {b: 117, opts: ["Para", "Serial"]}],
  ["volume", {b: 121}],
  ["amp/velo", {b: 122, dispOff: -64}],
  ["amp/mod/src", {b: 123, opts: modSources}],
  ["amp/mod/amt", {b: 124, dispOff: -64}],
  { prefix: "fx", count: 2, bx: 16, block: i => (
    { inc: 1, b: 128, block: [
      ["type", {opts: i == 0 ? effectTypes : effect2Types}],
      ["mix", {}],
    ] }
  )} ,
  { prefix: "param", count: 14, bx: 1, block: [
    ['', {b: 130}]
  ] },
  { prefix: "lfo", count: 3, bx: 12, block: [
    ["shape", {b: 160, opts: lfoShapes}],
    ["speed", {b: 161}],
    ["sync", {b: 163, max: 1}],
    ["clock", {b: 164, max: 1}],
    ["phase", {b: 165, iso: phaseIso}],
    ["delay", {b: 166}],
    ["fade", {b: 167, dispOff: -64}],
    ["keyTrk", {b: 170, iso: keytrackIso}],
  ] },
  { prefix: "env", count: 4, bx: 12, block: [
    ["mode", {b: 196, bits: [0, 3], opts: envelopeModes}],
    ["trigger", {b: 196, p: -1, bit: 5, opts: envelopeTriggers}],
    ["attack", {b: 199}],
    ["attack/level", {b: 200}],
    ["decay", {b: 201}],
    ["sustain", {b: 202}],
    ["decay2", {b: 203}],
    ["sustain2", {b: 204}],
    ["release", {b: 205}],
  ] },
  { prefix: "modif", count: 4, bx: 4, block:
    { inc: 1, b: 245, block: [
      ["src/0", {opts: modSources}],
      ["src/1", {opts: ["Const"].concat(modSources.slice(1))}],
      ["op", {opts: modOperators}],
      ["const", {dispOff: -64}],
    ] }
  },
  { prefix: "mod", count: 16, bx: 3, block:
    { inc: 1, b: 261, block: [
      ["src", {opts: modSources}],
      ["dest", {opts: modDestinations}],
      ["amt", {dispOff: -64}],
    ] }
  },
  { prefix: "arp", block: [
    ["mode", {b: 311, opts: arpModes}],
    ["pattern", {b: 312, max: 16, iso: ['switch', [
      [0, "Off"],
      [1, "User"],
    ], ['-', 1]] }],
    ["clock", {b: 314, opts: arpClocks}],
    ["length", {b: 315, opts: arpLengths}],
    ["octave", {b: 316, max: 9, dispOff: 1}],
    ["direction", {b: 317, opts: arpDirections}],
    ["sortOrder", {b: 318, opts: arpSorts}],
    ["velo", {b: 319, opts: arpVeloModes}],
    ["timingFactor", {b: 320}],
    ["pattern/reset", {b: 322, max: 1}],
    ["pattern/length", {b: 323, max: 15, dispOff: 1}],
    ["tempo", {b: 326, iso: tempoIso}],
  ] },
  { prefix: '', count: 16, bx: 1, block: [
    ["step", {b: 327, bits: [4, 7], dispOff: -4, opts: arpSteps}],
    ["glide", {b: 327, bit: 3}],
    ["accent", {b: 327, bits: [0, 3], max: 7, dispOff: -4, opts: arpAccentIso}],
    ["length", {b: 343, bits: [4, 7], max: 7, dispOff: -4, opts: arpLenIso}],
    ["timing", {b: 343, bits: [0, 3], max: 7, dispOff: -4, opts: arpTimingIso}],
  ] },
  ["category", {b: 379, opts: categorys}],
]

const dumpByte = 0x10

const patchTruss = Blofeld.createPatchTruss("Voice", 383, "blofeld-init", [363, 379], parms, 7, dumpByte, true)
  
module.exports = {
  dumpByte,
  patchTruss,
  bankTruss: Blofeld.createBankTruss(dumpByte, patchTruss, "blofeld-bank-init"),
  tempoIso,
  lfoRateIso,
  samples,
  waveforms,
  fxMap: [
    [],
    chorusParams,
    flangerParams,
    phaserParams,
    overdriveParams,
    tripleFXParams,
    delayParams,
    clockedDelayParams,
    reverbParams,
  ],
}