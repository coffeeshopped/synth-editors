

const nameByteRange = [363, 379]
const initFileName = "microq-voice-init"
const fileDataCount = 392

const phaseIso = Miso.switcher([
  .int(0, "Free")
], default: Miso.lerp(in: [1, 128], out: 0...360) >>> Miso.round() >>> Miso.unitFormat("°"))

const tempoIso = Miso.switcher([
  .range(0...25, Miso.lerp(in: 0...25, out: 40...90)),
  .range(26...100, Miso.lerp(in: 26...100, out: 91...165)),
  .range(101...127, Miso.lerp(in: 101...127, out: 170...300))
]) >>> Miso.round()

const arpAccentIso = ["❌", "↓↓↓", "↓↓", "↓", "-", "↑", "↑↑", "↑↑↑"]

const arpTimingIso = ["Random", "-3", "-2", "-1", "0", "1", "2", "3"]

const arpLenIso = ["Legato", "-3", "-2", "-1", "0", "1", "2", "3"]

const waveOptions: [Int:String] = ["Off", "Pulse", "Saw", "Triangle", "Sine", "Alt 1", "Alt 2"]

const lfoRateIso = Miso.m(0.5) >>> Miso.floor() >>> Miso.options(["256", "192", "160", "144", "128", "120", "96", "80", "72", "64", "48", "40", "36", "32", "24", "20", "18", "16", "15", "14", "12", "10", "9", "8", "7", "6", "5", "4", "3.5", "3", "2.66", "2.4", "2", "1.75", "1.5", "1.33", "1.2", "1", "7/8", "1/2.", "1/2T", "5/8", "1/2", "7/16", "1/4.", "1/4T", "5/16", "1/4", "7/32", "1/8.", "1/8T", "5/32", "1/8", "7/64", "1/16.", "1/16T", "5/64", "1/16", "1/32.", "1/32T", "1/32", "1/64T", "1/64", "1/96"])

const fastModSource = ["Off", "LFO 1", "LFO1*MW", "LFO 2", "LFO2*Prs", "LFO 3", "FilterEnv", "AmpEnv", "Env3", "Env4", "Velocity", "Mod Wheel", "Pitchbend", "Pressure"]

const stdModStrings = ["Off", "LFO 1", "LFO1*MW", "LFO 2", "LFO2*Press", "LFO 3", "FilterEnv", "AmpEnv", "Env3", "Env4", "Keytrack", "Velocity", "Rel. Velo", "Pressure", "Poly Press", "Pitch Bend", "Mod Wheel", "Sustain", "Foot Ctrl", "BreathCtrl", "Control W", "Control X", "Control Y", "Control Z", "Ctrl Delay", "Modif 1", "Modif 2", "Modif 3", "Modif 4", "min", "MAX", "Voice Num", "Voice%16", "Voice%8", "Voice%4", "Voice%2", "Unisono Vc", "U. Detune", "U De-Pan", "U De-Oct"]
const stdModSrc = stdModStrings
const modifSrc2 = ["Const"] + stdModStrings.suffix(from: 1)

const fastModDestStrings = ["Pitch", "O1 Pitch", "O1 FM", "O1 PW", "O2 Pitch", "O2 FM", "O2 PW", "O3 Pitch", "O3 FM", "O3 PW", "O1 Level", "O1 Balance", "O2 Level", "O2 Balance", "O3 Level", "O3 Balance", "Ring Level", "Ring Bal.", "N/E Level", "N/E Bal.", "F1 Cutoff", "F1 Reson", "F1 FM", "F1 Drive", "F1 Pan", "F2 Cutoff", "F2 Reson", "F2 FM", "F2 Drive", "F2 Pan", "Volume"]
const fastModDest = fastModDestStrings

const stdModDest = fastModDestStrings + ["LFO1Speed", "LFO2Speed", "LFO3Speed", "FE Attack", "FE Decay", "FE Sustain", "FE Release", "AE Attack", "AE Decay", "AE Sustain", "AE Release", "E3 Attack", "E3 Decay", "E3 Sustain", "E3 Release", "E4 Attack", "E4 Decay", "E4 Sustain", "E4 Release", "M1F Amount", "M2F Amount", "M1S Amount", "M2S Amount", "O1 Sub Div", "O1 Sub Vol", "O2 Sub Div", "O2 Sub Vol"]


const keytrackIso = Blofeld.Voice.keytrackIso

const noiseSelect = ["Noise", "Ext L", "Ext R", "Ext L+R"]

const filterTypes = ["Bypass", "LP 24dB", "LP 12dB", "BP 24dB", "BP 12dB", "HP 24dB", "HP 12dB", "Notch24dB", "Notch12dB", "Comb+", "Comb-"]

const fxTypes = ["Bypass", "Chorus", "Flanger", "Phaser", "Overdrive", "Five FX", "Vocoder"]

const fx2Types = fxTypes + ["Delay", "Reverb", "5.1 Delay", "5.1 D.Clk"]

const categories = ["-custom-", "Arp", "Atmo", "Bass", "Bell", "Drum", "Ext", "FX", "Init", "Keys", "Lead", "Orgn", "Pad", "Perc", "Pluk", "Poly", "RAND", "Seq", "Strg", "Synt", "Voc", "Wave"]
const categoryOptions = categories


function bytes(data) { return data.safeBytes(7..<390) }

function getValue(_ bytes: [UInt8], path: SynthPath) -> Int? {
  guard path == "category" else { return defaultGetValue(bytes, path: path) }
  let cat = [UInt8](bytes[379..<383]).cleanString()
  return categories.firstIndex(of: cat) ?? 0
}

function setValue(_ bytes: inout [UInt8], _ value: Int, path: SynthPath) {
  guard path == "category" else { return defaultSetValue(&bytes, value, path: path) }
  guard value > 0 && value < categories.count else { return }
  let cat = categories[value].bytes(forCount: 4)
  (0..<4).forEach {
    bytes[379 + $0] = cat[$0]
  }
}

function sysexData(_ bytes: [UInt8], deviceId: UInt8, bank: UInt8, location: UInt8) -> MidiMessage {
  sysexData(bytes, deviceId: deviceId, dumpByte: 0x10, bank: bank, location: location)
}

function randomize(patch: ByteBackedSysexPatch) {
  let filterPres: [SynthPath] = [
    "fx", "modif", "hi/mod", "lo/mod",
    "arp/mode", "mono",
  ] + (0..<3).map { ["keyTrk"].prefixed("osc/$0") }.reduce([], +)
  type(of: patch).params.forEach { path, param in
    guard filterPres.map({ !path.starts(with: $0) }).reduce(true, { $0 && $1 }) else { return }
    patch[path] = param.randomize()
  }
}

const parms = [
  { prefix: "osc", count: 3, bx: 16, block: i => (
    { inc: true, b: 1, block: ([
      ["octave", {opts: Blofeld.Voice.oscOctaveOptions}],
      ["coarse", {range: [52, 77], dispOff: -64}],
      ["fine", {dispOff: -64}],
      ["bend", {range: [40, 89], dispOff: -64}],
      ["keyTrk", {isoS: keytrackIso}],
      ["fm/src", {opts: Blofeld.Voice.fmSourceOptions}],
      ["fm/amt"],
      ["shape", {opts: waveOpts = i == 2 ? Blofeld.Voice.osc3WaveformOptions : waveOptions}],
      ["pw"],
      ["pw/src", {opts: fastModSource}],
      ["pw/amt", {dispOff: -64}],
    ]).concat(i == 2 ? [] : [
      ["sub/freq/divide", {max: 31, dispOff: 1}],
      ["sub/volume"],
    ]) }
  },
  { inc: true, b: 49, block: [
    ["osc/1/sync", {max: 1}],
    ["pitch/src", {opts: fastModSource}],
    ["pitch/amt", {dispOff: -64}],
  ] },
  [
    ["glide/on", {b: 53, max: 1}],
    ["glide/mode", {b: 56, opts: Blofeld.Voice.glideModeOptions}],
    ["glide/rate", {b: 57}],
    ["mono", {b: 58, bit: 0}],
    ["unison", {b: 58, bits: [4, 7], opts: Blofeld.Voice.unisonModeOptions}],
    ["unison/detune", {b: 59}],
  ],
  { prefix: "osc", count: 3, bx: 2, block: 
    { inc: true, b: 61, block: [
      ["level"],
      ["balance", {isoS: Blofeld.Voice.filterBalanceIso}],
    ] }
  },
  [
    ["noise/level", {b: 67}],
    ["noise/balance", {b: 68, isoS: Blofeld.Voice.filterBalanceIso}],
    ["ringMod/level", {b: 71}],
    ["ringMod/balance", {b: 72, isoS: Blofeld.Voice.filterBalanceIso}],
    ["noise/select/0", {b: 75, opts: noiseSelect}],
    ["noise/select/1", {b: 76, opts: noiseSelect}],
  ],
  { prefix: "filter", count: 2, bx: 20, block: [
    ["type", {b: 77, optArray: filterTypes}],
    ["cutoff", {b: 78}],
    ["reson", {b: 80}],
    ["drive", {b: 81}],
    ["keyTrk", {b: 86, isoS: keytrackIso}],
    ["env/amt", {b: 87, dispOff: -64}],
    ["velo", {b: 88, dispOff: -64}],
    ["cutoff/src", {b: 89, opts: fastModSource}],
    ["cutoff/amt", {b: 90, dispOff: -64}],
    ["fm/src", {b: 91, opts: Blofeld.Voice.fmSourceOptions}],
    ["fm/amt", {b: 92}],
    ["pan", {b: 93, dispOff: -64}],
    ["pan/src", {b: 94, opts: fastModSource}],
    ["pan/amt", {b: 95, dispOff: -64}],
  ] },
  [
    ["filter/routing", {b: 117, optArray: ["Para", "Serial"]}],
    ["volume", {b: 121}],
    ["amp/velo", {b: 122, dispOff: -64}],
    ["amp/mod/src", {b: 123, opts: fastModSource}],
    ["amp/mod/amt", {b: 124, dispOff: -64}],
  ],
  fxParams(128),
  { prefix: "lfo", count: 3, bx: 12, block: [
    ["shape", {b: 160, opts: Blofeld.Voice.lfoShapeOptions}],
    ["speed", {b: 161}],
    ["sync", {b: 163, max: 1}],
    ["clock", {b: 164, max: 1}],
    ["phase", {b: 165, isoS: phaseIso}],
    ["delay", {b: 166}],
    ["fade", {b: 167, dispOff: -64}],
    ["keyTrk", {b: 170, isoS: keytrackIso}],
  ] },
  { prefix: "env", count: 4, bx: 12, block: [
    ["mode", {b: 196, bits: [0, 3], opts: Blofeld.Voice.envelopeModeOptions}],
    ["trigger", {b: 196, p: -1, bit: 5, opts: Blofeld.Voice.envelopeTriggerOptions}],
    ["attack", {b: 199}],
    ["attack/level", {b: 200}],
    ["decay", {b: 201}],
    ["sustain", {b: 202}],
    ["decay2", {b: 203}],
    ["sustain2", {b: 204}],
    ["release", {b: 205}],
  ] },
  { prefix: "modif", count: 4, bx: 4, block:
    { inc: true, b: 245, block: [
      ["src/0", {opts: stdModSrc}],
      ["src/1", {opts: modifSrc2}],
      ["op", {opts: Blofeld.Voice.modOperatorOptions}],
      ["const", {dispOff: -64}],
    ] }
  },
  { prefix: "hi/mod", count: 8, bx: 3, block:
    { inc: true, b: 261, block: [
      ["src", {opts: fastModSource}],
      ["dest", {opts: fastModDest}],
      ["amt", {dispOff: -64}],
    ] }
  },
  { prefix: "lo/mod", count: 8, bx: 3, block:
    { inc: true, b: 285, block: [
      ["src", {opts: stdModSrc}],
      ["dest", {opts: stdModDest}],
      ["amt", {dispOff: -64}],
    ] }
  },
  arpParams(311),
  [
    ["category", {b: 379, opts: categoryOptions}],
  ],
]
  // TODO: Category as ASCII?



const fxMap = [
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

const polarityOptions = [
  0:"+",
  1:"-"
]

// these are for effect 2. for effect 1, subtract 16 from parm
const chorusParams  = [
  o("146", l: "Speed"),
  o("147", l: "Depth"),
  o("149", l: "Delay"),
]

const flangerParams  = [
  o("146", l: "Speed"), // 0..127 0..127
  o("147", l: "Depth"), // 0..127 0..127
  o("150", l: "Feedback"), // 0..127 0..127
  o("154", l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
]

const phaserParams  = [
  o("146", l: "Speed"), // 0..127 0..127
  o("147", l: "Depth"), // 0..127 0..127
  o("151", l: "Center"), // 0..127 0..127
  o("152", l: "Spacing"), // 0..127 0..127
  o("150", l: "Feedback"), // 0..127 0..127
  o("154", l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
]

const overdriveParams  = [
  o("147", l: "Drive"), // 0..127 0..127
  o("148", l: "Post Gain"), // 0..127 0..127
  o("151", l: "Cutoff"), // 0..127 0..127
]

const freqFormatIso = Miso.switcher([
  .range(0...1000, Miso.round(1) >>> Miso.unitFormat("Hz")),
  .range(1000...10000, Miso.m(1/1000) >>> Miso.round(2) >>> Miso.unitFormat("k"))
], default: Miso.m(1/1000) >>> Miso.round(1) >>> Miso.unitFormat("k"))

const shFreqIso = Miso.quadReg(a: 2.6915979097009197, b: -689.0545153869274, c: 44099.76187350981, neg: true) >>> freqFormatIso

const fiveFXParams  = [
  o("150", l: "S&H", isoS: shFreqIso),
  o("151", l: "Overdrive"), // 0..127 0..127
  o("153", l: "Ring Mod"),
  o("152", l: "←Src", opts: vocSrc),
  o("149", l: "Chrs/Dly"), // 0..127 0..127
  o("146", l: "←Speed"), // 0..127 0..127
  o("147", l: "←Depth"), // 0..127 0..127
  o("148", l: "←Delay"), // 0..127 0..127
]

const vocSrc = ["Ext", "Aux", "Inst 1 FX", "Inst 2 FX", "Inst 3 FX", "Inst 4 FX", "Main In", "Sub 1 In", "Sub 2 In"]

const vocOffIso = Miso.lerp(in: 127, out: -128...128) >>> Miso.round()
const vocFreqIso = Miso.exponReg(a: 10.924085542005335, b: 0.05774863315179796, c: -0.06151331566783524) >>> freqFormatIso

const vocoderParams  = [
  o("146", l: "Bands", max: 23, dispOff: 2),
  o("147", l: "Ana Sig", opts: vocSrc),
  o("148", l: "A Lo Frq", isoS: vocFreqIso),
  o("149", l: "A Hi Frq", isoS: vocFreqIso),
  o("150", l: "S Offset", isoF: vocOffIso),
  o("151", l: "Hi Offset", isoF: vocOffIso),
  o("152", l: "Bwid", dispOff: -64),
  o("153", l: "Reson", dispOff: -64),
  o("154", l: "Attack"),
  o("155", l: "Decay"),
  o("156", l: "EQ Lo", dispOff: -64),
  o("157", l: "EQ Mid Band", max: 24, dispOff: 1),
  o("158", l: "EQ Mid", dispOff: -64),
  o("159", l: "EQ High", dispOff: -64),
]

const delayTempoIso = Miso.switcher([
  .int(0, "Internal"),
], default: tempoIso >>> Miso.str())

const delayLenIso = Miso.quadReg(a: 0.09205458275935607, b: -2.7201779383867475e-05, c: 1.4159673877757628) >>> Miso.round(1)

const delayParams  = [
  o("153", l: "Clocked", max: 1),
  o("149", l: "Length", isoF: delayLenIso), // non-Clocked len
  o("156", l: "Clk Len", opts: clockedDelayLengthOptions), // Clocked len
  o("148", l: "Tempo", isoS: delayTempoIso),
  o("150", l: "Feedback"), // 0..127 0..127
  o("154", l: "Polarity", opts: polarityOptions), // 0..1 positive,negative
  o("151", l: "Cutoff"), // 0..127 0..127
  o("155", l: "Autopan", optArray: ["Off", "On"]),
]

const clockedDelayLengthOptions = ["1/128", "1/64", "1/32", "1/16", "1/8", "1/4", "2/4", "3/4", "4/4", "8/4"].map { ["\($0)", "\($0)T", "\($0)."] }.reduce([], +)
const delayFeedIso = Miso.piecewise(breaks: [
  (0, 0),
  (32, 25),
  (64, 50),
  (96, 75),
  (126, 98.4),
  (127, 100),
]) >>> Miso.round(1) >>> Miso.unitFormat("%")

const delayPercIso = Miso.piecewise(breaks: [
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


const clockedDelayParams  = [
  o("146", l: "Length", opts: clockedDelayLengthOptions),
  o("147", l: "Feedback", isoS: delayFeedIso),
  o("148", l: "LFE LP", isoS: vocFreqIso), // 0..127 0..127
  o("149", l: "Input HP", isoS: vocFreqIso), // 0..127 0..127
  o("151", l: "FSL V"), // 0..127 0..127
  o("150", l: "Delay ML", isoS: delayPercIso), // 0..127 0..127
  o("153", l: "FSR V"), // 0..127 0..127
  o("152", l: "Delay MR", isoS: delayPercIso), // 0..127 0..127
  o("155", l: "CntrS V"), // 0..127 -64..+63
  o("154", l: "Delay S2L", isoS: delayPercIso), // 0..1 positive,negative
  o("157", l: "RearSL V"), // 0..127 0..127
  o("156", l: "Delay S1L", isoS: delayPercIso), // 0..127 0..127
  o("159", l: "RearSR V"), // 0..127 0..127
  o("158", l: "Delay S1R", isoS: delayPercIso), // 0..127 0..127
]

const preDelayIso = Miso.lerp(in: 127, out: 0...300) >>> Miso.round(1)
const sizeIso = Miso.lerp(in: 127, out: 3...20) >>> Miso.round(1) >>> Miso.unitFormat("m")
const reverbParams  = [
  o("152", l: "Highpass"),
  o("151", l: "Lowpass"),
  o("149", l: "Pre-Delay", isoF: preDelayIso),
  o("153", l: "Diffusion"),
  o("146", l: "Size", isoS: sizeIso),
  o("147", l: "Shape"),
  o("148", l: "Decay"),
  o("154", l: "Damping"),
]

const delay51Params  = [
  o("146", l: "Delay", isoF: delayLenIso),
] + clockedDelayParams.suffix(from: 1)

