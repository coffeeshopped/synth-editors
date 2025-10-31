

subscript(path: SynthPath) -> Int? {
  get {
    switch path {
    case "arp/mode":
        // first look at TI arp mode byte. if 0, return C arp mode byte
      let ti = Int(bytes[143])
      let c = Int(bytes[129])
      return ti == 0 ? c : ti
    default:
      guard let param = Self.params[path] else { return nil }
      return unpack(param: param)
    }
  }
  set {
    guard let param = Self.params[path],
      let newValue = newValue else { return }
    switch path {
    case "arp/mode":
        // first look at TI arp mode byte. if 0, return C arp mode byte
      bytes[143] = UInt8(newValue)
      bytes[129] = 0 // zero-out the C arp mode byte
    default:
      pack(value: newValue, forParam: param)
    }
  }
}

//  subscript(path: SynthPath) -> Int? {
//    get {
//      guard let v = rawValue(path: path) else { return nil }
//      switch path {
//      case "0/wave", "1/wave":
//        let inst = v.bits([0, 7])
//        let set = v.bits([8, 12])
//        return Self.reverseInstMap[set]?[inst] ?? 0
//      default:
//        return v
//      }
//    }
//    set {
//      guard let param = type(of: self).params[path],
//        let newValue = newValue else { return }
//      let off = param.parm * 2
//      switch path {
//      case "0/wave", "1/wave":
//        guard newValue < Self.instMap.count else { return }
//        let item = Self.instMap[newValue]
//        let v = 0.set(bits: [0, 7], value: item.inst).set(bits: [8, 12], value: item.set)
//        bytes[off] = UInt8(v.bits([0, 6]))
//        bytes[off + 1] = UInt8(v.bits([7, 13]))
//      default:
//        bytes[off] = UInt8(newValue.bits([0, 6]))
//        bytes[off + 1] = UInt8(newValue.bits([7, 13]))
//      }
//    }
//  }


// TODO
func randomize() {
//    randomizeAllParams()
//
//    self["vocoder/mode"] = 0
//    self["volume"] = 127
//    self["osc/0/keyTrk"] = 96
//    self["osc/1/keyTrk"] = 96
//    self["arp/mode"] = 0
//
//    self["loop"] = 0 // atomizer off
  
  let keys: [SynthPath] = [
    "osc/0/shape",
    "osc/0/pw",
    "osc/0/wave",
    "osc/1/shape",
    "osc/1/pw",
    "osc/1/wave",
    "osc/1/semitone",
    "osc/1/detune",
    "fm/amt",
    "osc/0/sync",
    "filter/env/pitch",
    "filter/env/fm",
    "osc/balance",
    "sub/level",
    "sub/shape",
//      "osc/level",
    "noise/level",
    "noise/color",
    "filter/0/cutoff",
    "filter/1/cutoff",
    "filter/reson",
    "filter/reson/extra",
    "filter/env/amt",
    "filter/env/extra",
    "filter/keyTrk",
    "filter/keyTrk/extra",
    "filter/balance",
    "saturation/type",
    "ringMod/level",
    "filter/0/mode",
    "filter/1/mode",
    "filter/routing",
    "filter/env/attack",
    "filter/env/decay",
    "filter/env/sustain",
    "filter/env/sustain/slop",
    "filter/env/release",
    "amp/env/attack",
    "amp/env/decay",
    "amp/env/sustain",
    "amp/env/sustain/slop",
    "amp/env/release",

    "lfo/0/rate",
    "lfo/0/shape",
    "lfo/0/env/mode",
    "lfo/0/mode",
    "lfo/0/curve",
    "lfo/0/keyTrk",
    "lfo/0/trigger",
    "lfo/0/osc",
    "lfo/0/osc/1",
    "lfo/0/pw",
    "lfo/0/filter/reson",
    "lfo/0/filter/env",
    "lfo/1/rate",
    "lfo/1/shape",
    "lfo/1/env/mode",
    "lfo/1/mode",
    "lfo/1/curve",
    "lfo/1/keyTrk",
    "lfo/1/trigger",
    "lfo/1/osc/shape",
    "lfo/1/fm",
    "lfo/1/cutoff",
    "lfo/1/cutoff/1",
    "lfo/1/pan",

    "osc/key/mode",

    "chorus/mix",
    "chorus/rate",
    "chorus/depth",
    "chorus/delay",
    "chorus/feedback",
    "chorus/shape",

    "delay/mode",
    "delay/send",
    "delay/time",
    "delay/feedback",
    "delay/rate",
    "delay/depth",
    "delay/shape",
    "delay/color",

    "lfo/2/rate",
    "lfo/2/shape",
    "lfo/2/mode",
    "lfo/2/keyTrk",
    "lfo/2/dest",
    "lfo/2/dest/amt",
    "lfo/2/fade",

    "tempo",

    "lfo/0/clock",
    "lfo/1/clock",
    "delay/clock",
    "lfo/2/clock",

    "filter/0/env/polarity",
    "filter/1/env/polarity",
    "filter/cutoff/link",
    "filter/keyTrk/start",
    "fm/mode",
    "osc/innit/phase",
    "osc/pushIt",

    "osc/2/mode",
    "osc/2/level",
    "osc/2/semitone",
    "osc/2/fine",
    "eq/lo/freq",
    "eq/hi/freq",
    "osc/0/shape/velo",
    "osc/1/shape/velo",
    "velo/pw",
    "velo/fm",

    "velo/filter/0/env",
    "velo/filter/1/env",
    "velo/filter/0/reson",
    "velo/filter/1/reson",

    "velo/volume",
//      "velo/pan",

    "phase/mode",
    "phase/mix",
    "phase/rate",
    "phase/depth",
    "phase/freq",
    "phase/feedback",
    "phase/pan",
    "eq/mid/gain",
    "eq/mid/freq",
    "eq/mid/q",
    "eq/lo/gain",
    "eq/hi/gain",
    "character/amt",
    "character/tune",

    "dist/type",
    "dist/amt",

    "reverb/mode",
    "reverb/send",
    "reverb/type",
    "reverb/time",
    "reverb/redamper",
    "reverb/color",
    "reverb/delay",
    "reverb/clock",
    "reverb/feedback",
    "delay/type",
    "delay/ratio",
    "delay/clock/left",
    "delay/clock/right",
    "delay/bw",

    "freq/shift/type",
    "freq/shift/mix",
    "freq/shift/freq",
    "freq/shift/phase",
    "freq/shift/left",
    "freq/shift/right",
    "freq/shift/reson",
    "character/type",

    "osc/0/mode",
    "osc/1/mode",
    "osc/0/formant/pan",
    "osc/0/formant/shift",
    "osc/0/local/detune",
    "osc/0/int",
    "osc/1/formant/pan",
    "osc/1/formant/shift",
    "osc/1/local/detune",
    "osc/1/int",
    "dist/booster",
    "dist/hi/cutoff",
    "dist/mix",
    "dist/q",
    "dist/tone",

  ]
  keys.forEach {
    self[$0] = Self.param($0)?.randomize() ?? 0
  }
}

const oscModelOptions = ["Classic", "HyperSaw", "Wavetable", "Wave PWM", "Grain Simple", "Grain Complex", "Formant Simple", "Formant Complex"]

const oscShapeIso = Miso.switcher([
  .int(0, "Wave"),
  .range([1, 63], Miso.m(100/64) >>> Miso.round() >>> Miso.str("%g%% W>S")),
  .int(64, "Saw"),
  .range([65, 126], Miso.a(-64) >>> Miso.m(100/64) >>> Miso.round() >>> Miso.str("%g%% S>P")),
  .int(127, "Pulse"),
])

const pwIso = Miso.d(127) >>> Miso.unitLerp(0.[5, 1]) >>> tenthPercIso

const waveSelectIso = Miso.switcher([
  .int(0, "Sine"),
  .int(1, "Triangle"),
], default: Miso.a(1) >>> Miso.str("Wave %g"))

const osc2WaveIso = Miso.switcher([
  .int(0, "Off"),
  .int(1, "Slave"),
  .int(2, "Saw"),
  .int(3, "Pulse"),
  .int(4, "Sine"),
  .int(5, "Triangle"),
], default: Miso.a(-3) >>> Miso.str("Wave %g"))

const keyFollowIso = Miso.switcher([
  .int(96, "Norm")
], default: Miso.a(-64) >>> Miso.str())

/// Map [0, 1] to a % round to 1 dec place
const tenthPercIso = Miso.m(100) >>> Miso.round(1) >>> Miso.str("%g%%")

const fullPercIso = unitIso >>> tenthPercIso

const bipolarPercIso = unitLerp([-1, 1]) >>> tenthPercIso

const fullPercIsoWOff = Miso.switcher([
  .rangeString([0, 0], "Off"),
], default: fullPercIso)

const perc200Iso = unitIso >>> Miso.m(2) >>> tenthPercIso

const noiseVolIso = Miso.switcher([
  .int(0, "Off")
], default: Miso.str())

const lfoShapeIso = Miso.switcher([
  .int(0, "Sine"),
  .int(1, "Triangle"),
  .int(2, "Saw"),
  .int(3, "Square"),
  .int(4, "S&H"),
  .int(5, "S&G"),
], default: Miso.a(-3) >>> Miso.str("Wave %g"))

const atomizerIso = Miso.switcher([
  .int(0, "Off"),
  .int(1, "On"),
], default: Miso.str())

// map from [0, 127] to [0, 1] (the virus way)
const unitIso = Miso.switcher(`int(127/${1)}`, default: Miso.m(1/128))

static func unitLerp(_ range: ClosedRange<Float>) -> Iso<Float, Float> {
  return unitIso >>> Miso.unitLerp(range)
}

const eqGainIso = Miso.switcher(`int(64/${"Off")}`, default: unitLerp([-16, 16]) >>> Miso.round(2) >>> Miso.str("%g dB"))

const delaySendIso = Miso.switcher([
  .int(0, "Off"),
  .range([1, 35], Miso.ln() >>> Miso.m(8.6858) >>> Miso.a(-46.185) >>> Miso.round(1) >>> Miso.str("%g dB")),
  .range([36, 95], Miso.m(0.25) >>> Miso.a(-24) >>> Miso.round(2) >>> Miso.str("%g dB")),
  .range([96, 126], Miso.options([0, -0.3, -0.6, -0.9, -1.2, -1.5, -1.8, -2.1, -2.5, -2.9, -3.3, -3.7, -4.1, -4.5, -5, -5.5, -6, -6.6, -7.2, -7.8, -8.5, -9.3, -10.1, -11, -12, -13.2, -14.5, -16.1, -18.1, -20.6, -24], startIndex: 96) >>> Miso.str("0/%g dB")),
  .int(127, "Effect")
])

const delayTimeIso = Miso.m(5.4614173228) >>> Miso.round(1) >>> Miso.str("%g ms")

const reverbPredelayIso = Miso.switcher(`int(92/${500)}`, default: Miso.m(5.4614173228)) >>> Miso.round(1) >>> Miso.str("%g ms")

const loFreqIso = Miso.m(0.5) >>> Miso.floor() >>> Miso.m(0.04191964) >>> Miso.exp() >>> Miso.m(32.69248232) >>> Miso.a(-0.68997284) >>> Miso.round() >>> Miso.str()

// a little off
const midFreqExpPartIso = Miso.m(0.05587764) >>> Miso.exp() >>> Miso.m(19.83282644) >>> Miso.a(-1.34511443)
const midFreqIso = Miso.switcher([
  .range([0, 112], midFreqExpPartIso),
  .range([113, 126], Miso.a(1) >>> midFreqExpPartIso),
  .int(127, 24000)
]) >>> Miso.round() >>> Miso.str()

const midQIso = Miso.switcher([
  .range([0, 16], Miso.m(0.0106214427002507) >>> Miso.a(0.277336468944884)),
  .range([17, 32], Miso.m(0.0163613868730386) >>> Miso.a(0.182936230077398)),
  .range([33, 48], Miso.m(0.0113806676777093) >>> Miso.a(0.345343618929774)),
  .range([49, 63], Miso.m(0.0430731688188778) >>> Miso.a(-1.17743337671029)),
  .range([64, 79], Miso.m(0.0774705351108967) >>> Miso.a(-3.37664472031135)),
  .range([80, 96], Miso.m(0.136813698962105) >>> Miso.a(-8.12372180820082)),
  .range([97, 112], Miso.m(0.243824024403959) >>> Miso.a(-18.3971105934826)),
  .range([113, 127], Miso.m(0.431214570166687) >>> Miso.a(-39.4044157591677)),
]) >>> Miso.round(2) >>> Miso.str()

const hiFreqIso = Miso.m(0.5) >>> Miso.floor() >>> Miso.m(4.18752638e-02) >>> Miso.exp() >>> Miso.m(1.83615763e+03) >>> Miso.a(-4.71797185e+00) >>> Miso.round() >>> Miso.str()

const freqShiftPolesIso = unitLerp([2, 6]) >>> Miso.round(2) >>> Miso.str()
const freqShiftFTypeIso = Miso.switcher([
  .int(0, "LP"),
  .int(64, "BP"),
  .int(127, "HP")
], default: Miso.str())

const oscDensityIso = Miso.switcher([
  .range([0, 64], Miso.m(0.0309964160768649) >>> Miso.a(1.05119066190202)),
  .range([65, 68], Miso.m(0.0998751397383792) >>> Miso.a(-3.39173934758308)),
  .range([69, 73], Miso.m(0.0483287476928924) >>> Miso.a(0.147627189234737)),
  .range([74, 80], Miso.m(0.0494096986612037) >>> Miso.a(0.0676368305753373)),
  .range([81, 84], Miso.m(0.100006856833258) >>> Miso.a(-4.00050944576357)),
  .range([85, 96], Miso.m(0.0489590010030881) >>> Miso.a(0.319206303112423)),
  .range([97, 101], Miso.m(0.180041766883461) >>> Miso.a(-12.3441265253952)),
  .range([102, 104], Miso.m(0.0499914852930645) >>> Miso.a(0.817464934300320)),
  .range([105, 108], Miso.m(0.199910739509612) >>> Miso.a(-14.8904937865277)),
  .range([109, 112], Miso.m(0.0699710423208910) >>> Miso.a(-0.806757604863247)),
  .range([113, 116], Miso.m(0.199996226558739) >>> Miso.a(-15.4995913730911)),
  .range([117, 120], Miso.m(0.0699877834673506) >>> Miso.a(-0.368534885309073)),
  .range([121, 127], Miso.m(0.150003085632388) >>> Miso.a(-9.98610014923964)),
]) >>> Miso.round(1) >>> Miso.str()

const arpPatternIso = Miso.switcher([
  .int(0, "User")
], default: Miso.a(1) >>> Miso.str())

const arpSwingIso = Miso.switcher([
  .int(0, "Off"),
  .int(21, "16B"),
  .int(41, "16C"),
  .int(66, "16D"),
  .int(87, "16E"),
  .int(107, "16F"),
], default: unitLerp([50, 75]) >>> Miso.round(1) >>> Miso.str("%g%"))

const arpResolutionOptions = ["1/128", "1/64", "1/32", "1/16", "1/8", "1/4", "3/128", "3/64", "3/32", "3/16", "1/48", "1/24", "1/12", "1/6", "1/3", "3/8", "1/2"]

const wavetableOptions = ["Sine", "HarmncSweep", "Glass Sweep", "Draw Bars", "Clusters", "Insine Out", "Landing", "Liquid Metal", "Opposition", "Overtunes 1", "Overtunes 2", "Scale Trix", "sine Rider", "Sqr Series", "Upsine Down", "Thumbs Up", "Waterphone", "E-Chime", "Tinkabll", "Bellfizz", "Bellentine", "Robot WaFS", "Alternator", "Finger Bass", "Fizzybar", "Flutes", "HP Love", "Majestix", "Hotch Potch", "Resynater", "Smooth Rough", "Sawsalito", "Bells 1", "Bells 2", "SportReport", "Metal Guru", "Bat Cave", "Acetate", "Buzzbizz", "Buzzportout", "Vanish", "Ooverbones", "Pulsechecker", "Stratosfear", "Sooty Sweep", "Throoty", "Didgitalis", "Evil", "Chords", "FM Grit", "Bellsarnie", "Octavius", "Eat Pulse", "sinzin", "sine System", "clip Sweep", "Roughage", "waving", "Pling Saw", "E-Peas", "Bump Sweep", "Filter Sqr", "Fourmant", "Formantera", "Sundial 1", "Sundial 2", "Sundial 3", "Clipdial 1", "Clipdial 2", "Voxonix", "Solenoid", "Klingklang", "violator", "Potassium", "Pile Up", "Tincanali", "Sniper", "Squeezy", "Decomposer", "Morfants", "Fingvox", "Adenoids", "Nasal", "Partialism", "TableDance", "Cascade", "Prismism", "Friction", "Robotix", "Whizzfizz", "Spangly", "Fluxbin", "Fiboglide", "Fibonice", "Fibonasty", "Penetrator", "Blinder", "Element 5", "Bad Signs", "Domina7rix"]

const knobOptions = ["Off", "Mod Wheel", "Breath", "Ctrl 3", "Foot Pedal", "Data Entry", "Balance", "Ctrl 9", "Expression", "Ctrl 12", "Ctrl 13", "Ctrl 14", "Ctrl 15", "Ctrl 16", "Patch Volume", "Chan Volume", "Pan", "Transpose", "Porta", "Unison Detune", "Unison Spread", "Unison LFO Phase", "Chorus Mix", "Chorus Rate", "Chorus Depth", "Chorus Delay", "Chorus Feedback", "Effect Send (Delay)", "Delay Time", "Delay Feedbk", "Delay Rate", "Delay Depth", "Osc 1 Wave Select", "Osc 1 PW", "Osc 1 Pitch", "Osc 1 Keyfollow", "Osc 2 Wave Select", "Osc 2 PW", "F Env > Osc 2 Pitch", "F Env > FM Amt", "Osc 2 Keyfollow", "Noise Volume", "F1 Reson", "F2 Reson", "F1 Env Amt", "F2 Env Amt", "F1 Keyfollow", "F2 Keyfollow", "LFO 1 Contour", "LFO 1 > Osc 1", "LFO 1 > Osc 2", "LFO 1 > PW", "LFO 1 > Reson", "LFO 1 > Filter Gain", "LFO 2 Contour", "LFO 2 > Shape", "LFO 2 > FM Amt", "LFO 2 > Cutoff 1", "LFO 2 > Cutoff 2", "LFO 2 > Pan", "LFO 3 Rate", "LFO 3 Assign Amt", "Bend Up", "Bend Down", "Aftertouch", "Velo > FM Amt", "Velo > F1 Env Amt", "Velo > F2 Env Amt", "Velo > Reson 1", "Velo > Reson 2", "Velo > Volume", "Velo > Pan", "Assign 1 Amt 1", "Assign 2 Amt 1", "Assign 2 Amt 2", "Assign 3 Amt 1", "Assign 3 Amt 2", "Assign 3 Amt 3", "Clock Tempo", "Input Thru", "Osc Init Phase", "Punch Intens", "Ring Mod", "Noise Color", "Delay Color", "Analog Boost Int", "Analog Boost Tune", "Dist Intens", "FreqShift Freq", "Osc 3 Volume", "Osc 3 Pitch", "Osc 3 Detune", "LFO 1 > Assign Amt", "LFO 2 > Assign Amt", "Phaser Mix", "Phaser Rate", "Phaser Depth", "Phaser Freq", "Phase Feedbk", "Phaser Spread", "Reverb Decay", "Reverb Damp", "Reverb Color", "Reverb Feedbk", "Surround Bal", "Arp Mode", "Arp Pattern", "Arp Resolution", "Arp Note Len", "Arp Swing", "Arp Octaves", "Arp Hold", "EQ Mid Gain", "EQ Mid Freq", "EQ Mid Q", "Assign 4 Amt 1", "Assign 5 Amt 1", "Assign 6 Amt 1", "Effect Send (Revb)", "Osc 1 Local Detune", "Osc 2 Local Detune", "Osc 1 F-Shift", "Osc 2 F-Shift", "Osc 1 F-Spread", "Osc 2 F-Spread", "Osc 1 Interp", "Osc 2 Interp", "Freq Shift Mix"]

const knobNames = VirusCVoicePatch.knobNames + ["Bite", "Flanger", "RingMod", "Punch", "Fuzz", "Modulate", "Party!", "Interpolation", "F-Shift", "F-Spread", "Bush", "Muscle", "Sack", "Vowel", "Comb", "Speaker"]

const modSrcOptions = ["Off", "Pitch Bend", "Chan Press", "Mod Wheel", "Breath", "Ctrlr 3", "Foot Pedal", "Data Entry", "Balance", "Ctrlr 9", "Expression", "Ctlr 12", "Ctlr 13", "Ctlr 14", "Ctlr 15", "Ctlr 16", "Hold Pedal", "Porta Sw", "Sus Pedal", "Amp Env", "Filt Env", "LFO 1 Bi", "LFO 2 Bi", "LFO 3 Bi", "Velo On", "Velo Off", "Key Follow", "Random", "Arp Input", "LFO 1 Uni", "LFO 2 Uni", "LFO 3 Uni", "1% const", "10% const", "AnaKey1 Fine", "AnaKey2 Fine", "AnaKey1 Coarse", "AnaKey2 Coarse", "Env 3", "Env 4"]

const modDestOptions = ["Off", "Patch Vol", "Osc 1 Interp", "Pan", "Transpose", "Porta", "Osc 1 Shape/Index", "Osc 1 PW", "Osc 1 Wave Sel", "Osc 1 Pitch", "Slot 6 Amt 3", "Osc 2 Shape/Index", "Osc 2 PW", "Osc 2 Wave Sel", "Osc 2 Pitch", "Osc 2 Detune", "Osc 2 FM Amt", "Filt Env>Osc 2 Pitch", "Filt Env>FM/Sync", "Osc 2 Interp", "Osc Balance", "Sub Volume", "Osc Volume", "Noise Volume", "Filter 1 Cutoff", "Filter 2 Cutoff", "Filter 1 Reson", "Filter 2 Reson", "F1 Env Amt", "F2 Env Amt", "Slot 5 Amt 2", "Slot 5 Amt 3", "Filter Balance", "F Env Attack", "F Env Decay", "F Env Sustain", "F Env Slope", "F Env Release", "Amp Env Attack", "Amp Env Decay", "Amp Env Sustain", "Amp Env Slope", "Amp Env Release", "LFO 1 Rate", "LFO 1 Contour", "LFO 1>Osc 1 Pitch", "LFO 1>Osc 2 Pitch", "LFO 1>PW", "LFO 1>Reson", "LFO 1>Filter Gain", "LFO 2 Rate", "LFO 2 Contour", "LFO2>Shape", "LFO2>FM Amt", "LFO2>Cutoff 1", "LFO2>Cutoff 2", "LFO2>Pan", "LFO 3 Rate", "LFO 3 Assign Amt", "Unison Detune", "Pan Spread", "Unison LFO Phase", "Chorus Mix", "Chorus Mod Rate", "Chorus Mod Depth", "Chorus Delay", "Chorus Feedback", "Delay Send", "Delay Time", "Delay Feedback", "Delay Mod Rate", "Delay Mod Depth", "Reverb Send", "-reserved (73)-", "-reserved (74)-", "Slot 6 Amt 2", "Slot 4 Amt 2", "Slot 3 Amt 3", "Filterbank Reso", "Filterbank Poles", "Slot 2 Amt 3", "Filterbank Slope", "Slot 1 Amt 1", "Slot 2 Amt 1", "Slot 2 Amt 2", "Slot 3 Amt 1", "Slot 3 Amt 2", "Slot 3 Amt 3", "-reserved (88)-", "Punch Intens", "Ring Mod", "Noise Color", "Delay Color", "Slot 1 Amt 2", "Slot 1 Amt 3", "Dist Intens", "FreqShifter Freq", "Osc 3 Volume", "Osc 3 Pitch", "Osc 3 Detune", "LFO 1 Assign Amt", "LFO 2 Assign Amt", "Phaser Mix", "Phaser Mod Rate", "Phaser Mod Depth", "Phaser Freq", "Phaser Feedbk", "-reserved (107)-", "Reverb Time", "Reverb Damp", "Reverb Color", "Reverb PreDelay", "-reserved (112)-", "Surround Balance", "Arp Note Length", "Arp Swing Factor", "Arp Pattern", "EQ Mid Gain", "EQ Mid Freq", "-reserved (119)-", "Slot 4 Amt 1", "Slot 5 Amt 1", "Slot 6 Amt 1", "Osc 1 F-Shift", "Osc 2 F-Shift", "Osc 1 F-Spread", "Osc 2 F-Spread", "Dist Mix"]

const categoryOptions = VirusCVoicePatch.categoryOptions + ["Atomizer"]

const smoothOptions = VirusCVoicePatch.smoothOptions + ["Quantise 1/64", "Quantise 1/32", "Quantise 1/16", "Quantise 1/8", "Quantise 1/4", "Quantise 1/2", "Quantise 3/64", "Quantise 3/32", "Quantise 3/16", "Quantise 3/8", "Quantise 1/24", "Quantise 1/12", "Quantise 1/6", "Quantise 1/3", "Quantise 2/3", "Quantise 3/4", "Quantise 1/1"]

const chorusSpeedParam = MisoParam.make(iso: Miso.switcher([
  .rangeString([0, 63], "Slow"),
  .rangeString([64, 127], "Fast")
]))

const chorusDistanceIso = unitIso >>> Miso.switcher([
  .range(0.[0, 0].49975825646378563, Miso.m(16.0070327639812) >>> Miso.a(4.01076926406655)),
  .range(0.[49975825646378563, 0].6215075771071618, Miso.m(23.8305793295562) >>> Miso.a(0.100887273091541)),
  .range(0.[6215075771071618, 0].7534918320398745, Miso.m(31.9999820556711) >>> Miso.a(-4.97645842162877)),
  .range(0.[7534918320398745, 0].8750101247956927, Miso.m(40.1693819103551) >>> Miso.a(-11.1320344848009)),
  .range(0.[8750101247956927, 1].0, Miso.m(47.9826212970748) >>> Miso.a(-17.9686980556331)),
]) >>> Miso.round(1) >>> Miso.str("%gcm")
const chorusDistanceParam = MisoParam.make(iso: chorusDistanceIso)

const chorusMicAngleParam = MisoParam.make(iso: unitLerp([-180, 180]) >>> Miso.round() >>> Miso.str("%g°"))

const hyperChorusAmtParam = MisoParam.make(iso: unitLerp([1, 3]) >>> Miso.round(2) >>> Miso.str("%g"))

const distortModes = ["Off", "Light", "Soft", "Medium", "Hard", "Digital", "Wave Shaper", "Rectifier", "Bit Reducer Old", "Rate Reducer Old", "Low Pass", "High Pass", "Wide", "Soft Bounce", "Hard Bounce", "Sine Fold", "Triangle Fold", "Sawtooth Fold", "Rate Reducer", "Bit Reducer", "Mint Overdrive", "Curry Overdrive", "Saffron Overdrive", "Onion Overdrive", "Pepper Overdrive", "Chili Overdrive"]

const vocoderModes = ["Off", "Oscillator", "Osc Hold", "Noise", "In L", "In L+R", "In R"]

const characterTypes = ["Analog Boost", "Vintage 1", "Vintage 2", "Vintage 3", "Pad Opener", "Lead Enhancer", "Bass Enhancer", "Stereo Widener", "Speaker Cabinet"]

const delayLFOWaveOptions = ["Sine", "Triangle", "Saw", "Square", "S&H", "S&G"]
// "Simple" = 1. 0 is off which we shouldn't send (puts the virus in a bad state)
const delayModeOptions = ["Simple", "Ping Pong 2:1", "Ping Pong 4:3", "Ping Pong 4:1", "Ping Pong 8:7", "Pattern 1+1", "Pattern 2+1", "Pattern 3+1", "Pattern 4+1", "Pattern 5+1", "Pattern 2+3", "Pattern 2+5", "Pattern 3+2", "Pattern 3+3", "Pattern 3+4", "Pattern 3+5", "Pattern 4+3", "Pattern 4+5", "Pattern 5+2", "Pattern 5+3", "Pattern 5+4", "Pattern 5+5"]

const delayClockOptions = ["Off", "1/64", "1/32", "1/16", "1/8", "1/4", "1/2", "3/64", "3/32", "3/16", "3/8", "1/24", "1/12", "1/6", "1/3", "2/3", "3/4"]
const delayLRClockOptions = ["1/32", "1/16", "2/16", "3/16", "4/16", "5/16"]
const delayRatioOptions = ["1/4", "2/4", "3/4", "4/4", "4/3", "4/2", "4/1"]
  
// starts at 1. 0 is probably "Off"... avoid
const reverbModeOptions = ["Reverb", "Feedback 1", "Feedback 2"]

const reverbTypeOptions = ["Ambience", "Small Room", "Large Room", "Hall"]

const lfoClockOptions = ["Off", "1/64", "1/32", "1/16", "1/8", "1/4", "1/2", "3/64", "3/32", "3/16", "3/8", "1/24", "1/12", "1/6", "1/3", "2/3", "3/4", "1/1", "2/1", "4/1", "8/1", "16/1"]



const parms = [
  // byte and param directly correlate
  
  // byte 0 and 1
  // from bank:  09 00
  // post fetch: 0c 01
  
  // When byte 2 is 4, that seems to indicate that the patch doesn't have any funny business
  // when it's 1, there is funny business
  
//    [[.], { b: 1 }],        // $_Single Patchmanagement/Flags
//    [[.], { b: 2 }],        // $_Single Patchmanagement/Original Bank
//    [[.], { b: 3 }],        // $_Single Patchmanagement/Original Patch
//    [[.], { b: 4 }],        // $_CC/Foot Controller CC04
  ["porta", { b: 5, iso: noiseVolIso }],        // $_Portamento
//    [[.], { b: 6 }],        // $_CC/Data Slider CC06
//    [[.], { b: 7 }],        // $_Part Volume
//    [[.], { b: 8 }],        // $_CC/Balance CC08
//    [[.], { b: 9 }],        // $_CC/MIDI Controller CC09
  ["pan", { b: 10, dispOff: -64 }],        // $_Patch Panorama
//    [[.], { b: 11 }],        // $_CC/Expression 11
//    [[.], { b: 12 }],        // $_CC/MIDI Controller 12
//    [[.], { b: 13 }],        // $_CC/MIDI Controller 13
//    [[.], { b: 14 }],        // $_CC/MIDI Controller 14
//    [[.], { b: 15 }],        // $_CC/MIDI Controller 15
//    [[.], { b: 16 }],        // $_CC/MIDI Controller 16
  ["osc/0/shape", { b: 17, iso: oscShapeIso }],        // $_Oscillator 1 Waveform Shape - x
  ["osc/0/pw", { b: 18, iso: pwIso }],        // $_Oscillator 1 Pulsewidth - x
  ["osc/0/wave", { b: 19, max: 63, iso: waveSelectIso }],        // $_Oscillator 1 Wave Select - x
  ["osc/0/semitone", { b: 20, rng: [16, 112], dispOff: -64 }],        // $_Oscillator 1 Detune In Semitones - x
  ["osc/0/keyTrk", { b: 21, iso: keyFollowIso }],        // $_Oscillator 1 Keyfollow - x
  ["osc/1/shape", { b: 22, iso: oscShapeIso }],        // $_Oscillator 2 Shape - x
  ["osc/1/pw", { b: 23, iso: pwIso }],        // $_Oscillator 2 Pulsewidth - x
  ["osc/1/wave", { b: 24, max: 63, iso: waveSelectIso }],        // $_Oscillator 2 Wave Select - x
  ["osc/1/semitone", { b: 25, rng: [16, 112], dispOff: -64 }],        // $_Oscillator 2 Detune In Semitones - x
  ["osc/1/detune", { b: 26 }],        // $_Oscillator 2 Fine Detune - x
  ["fm/amt", { b: 27, iso: fullPercIso }],        // $_FM Amount - x
  ["osc/0/sync", { b: 28 }],        // $_Oscillator 1 Sync - x
  ["filter/env/pitch", { b: 29, iso: bipolarPercIso }],        // $_Filter Envelope --> Pitch - x
  ["filter/env/fm", { b: 30, iso: bipolarPercIso }],        // $_Filter Envelope --> FM - x
  ["osc/1/keyTrk", { b: 31, iso: keyFollowIso }],        // $_Oscillator 2 Keyfollow - x
  ["osc/balance", { b: 33, iso: bipolarPercIso }],        // $_Oscillator Balance - x
  ["sub/level", { b: 34 }],        // $_Sub Oscillator Volume - x
  ["sub/shape", { b: 35, opts: ["Square", "Triangle"] }],        // $_Sub Oscillator Waveform Shape - x
  ["osc/level", { b: 36, dispOff: -64 }],        // $_Oscillator Section Volume - x
  ["noise/level", { b: 37, iso: noiseVolIso }],        // $_Noise Oscillator Volume - x
  ["noise/color", { b: 39, dispOff: -64 }],        // $_Noise Color - x
  ["filter/0/cutoff", { b: 40 }],        // $_Filter 1 Cutoff - x
  ["filter/1/cutoff", { b: 41 }],        // $_Filter 2 Cutoff - x
  ["filter/reson", { b: 42 }],        // $_Filter Resonance 1+2 - x
  ["filter/reson/extra", { b: 43 }],        // $_Filters/Resonance Helper - x
  ["filter/env/amt", { b: 44, iso: fullPercIso }],        // $_Filter Envelope Amount 1+2 - x
  ["filter/env/extra", { b: 45, iso: fullPercIso }],        // $_Filters/Envelope Helper - x
  ["filter/keyTrk", { b: 46, dispOff: -64 }],        // $_Filter Keyfollow 1+2 - x
  ["filter/keyTrk/extra", { b: 47, dispOff: -64 }],        // $_Filters/Keyfollow Helper - x
  ["filter/balance", { b: 48, dispOff: -64 }],        // $_Filter Balance - x
  ["saturation/type", { b: 49, opts: ["Off", "Light", "Soft", "Middle", "Hard", "Digital", "Waveshaper", "Rectifier", "Bit Reducer", "Rate Reducer", "Rate+Follow", "Low Pass", "Low+Follow", "High Pass", "High+Follow"] }],        // $_Voice Saturation Type - x
  ["ringMod/level", { b: 50, iso: noiseVolIso }],        // $_Ring Modulator Volume - x
  ["filter/0/mode", { b: 51, opts: ["Low Pass", "Hi Pass", "Band Pass", "Band Stop", "Analog 1 Pole", "Analog 2 Pole", "Analog 3 Pole", "Analog 4 Pole"] }],        // $_Filter 1 Mode - x
  ["filter/1/mode", { b: 52, opts: ["Low Pass", "Hi Pass", "Band Pass", "Band Stop"] }],        // $_Filter 2 Mode - x
  ["filter/routing", { b: 53, opts: ["Serial 4", "Serial 6", "Parallel 4", "Split Mode"] }],        // $_Filter Routing - x
  ["filter/env/attack", { b: 54 }],        // $_Filter Envelope Attack - x
  ["filter/env/decay", { b: 55 }],        // $_Filter Envelope/Decay - x
  ["filter/env/sustain", { b: 56, iso: fullPercIso }],        // $_Filter Envelope/Sustain - x
  ["filter/env/sustain/slop", { b: 57, dispOff: -64 }],        // $_Filter Envelope/Sustain Slope - x
  ["filter/env/release", { b: 58 }],        // $_Filter Envelope/Release - x
  ["amp/env/attack", { b: 59 }],        // $_Amplifier Envelope/Attack - x
  ["amp/env/decay", { b: 60 }],        // $_Amplifier Envelope/Decay - x
  ["amp/env/sustain", { b: 61, iso: fullPercIso }],        // $_Amplifier Envelope/Sustain - x
  ["amp/env/sustain/slop", { b: 62, dispOff: -64 }],        // $_Amplifier Envelope/Sustain Slope - x
  ["amp/env/release", { b: 63 }],        // $_Amplifier Envelope/Release - x
//    [[.], { b: 64 }],        // $_CC/Hold Pedal 64
//    [[.], { b: 65 }],        // $_CC/Portamento Pedal 65
//    [[.], { b: 66 }],        // $_CC/Sostenuto Pedal 66
  ["lfo/0/rate", { b: 67 }],        // $_LFO 1/Rate - x
  ["lfo/0/shape", { b: 68, max: 67, iso: lfoShapeIso }],        // $_LFO 1/Waveform Shape - x
  ["lfo/0/env/mode", { b: 69, max: 1 }],        // $_LFO 1 Envelope Mode - x
  ["lfo/0/mode", { b: 70, opts: ["Poly", "Mono"] }],        // $_LFO 1 Mode - x
  ["lfo/0/curve", { b: 71, dispOff: -64 }],        // $_LFO 1/Waveform Contour - x
  ["lfo/0/keyTrk", { b: 72, iso: fullPercIso }],        // $_LFO 1 Keyfollow - x
  ["lfo/0/trigger", { b: 73, iso: noiseVolIso }],        // $_LFO 1 Trigger Phase - x
  ["lfo/0/osc", { b: 74, iso: bipolarPercIso }],        // $_LFO 1 --> Osc 1+2 - x
  ["lfo/0/osc/1", { b: 75, iso: bipolarPercIso }],        // $_LFO 1 --> Osc 2 - x
  ["lfo/0/pw", { b: 76, iso: bipolarPercIso }],        // $_LFO 1 --> Pulsewidth - x
  ["lfo/0/filter/reson", { b: 77, iso: bipolarPercIso }],        // $_LFO 1 -->Filter Resonance 1+2 - x
  ["lfo/0/filter/env", { b: 78, iso: bipolarPercIso }],        // $_LFO 1 --> Filter Envelope Gain - x
  ["lfo/1/rate", { b: 79 }],        // $_LFO 2/Rate - x
  ["lfo/1/shape", { b: 80, max: 67, iso: lfoShapeIso }],        // $_LFO 2/Waveform Shape - x
  ["lfo/1/env/mode", { b: 81, max: 1 }],        // $_LFO 2/Envelope Mode - x
  ["lfo/1/mode", { b: 82, opts: ["Poly", "Mono"] }],        // $_LFO 2 Mode - x
  ["lfo/1/curve", { b: 83, dispOff: -64 }],        // $_LFO 2 Waveform Contour - x
  ["lfo/1/keyTrk", { b: 84, iso: fullPercIso }],        // $_LFO 2/Keyfollow - x
  ["lfo/1/trigger", { b: 85, iso: noiseVolIso }],        // $_LFO 2/Trigger Phase - x
  ["lfo/1/osc/shape", { b: 86, iso: bipolarPercIso }],        // $_LFO 2 --> Shape 1+2 - x
  ["lfo/1/fm", { b: 87, iso: bipolarPercIso }],        // $_LFO 2 --> FM Amount - x
  ["lfo/1/cutoff", { b: 88, iso: bipolarPercIso }],        // $_LFO 2 --> Cutoff 1+2 - x
  ["lfo/1/cutoff/1", { b: 89, iso: bipolarPercIso }],        // $_LFO 2 --> Cutoff 2 - x
  ["lfo/1/pan", { b: 90, iso: bipolarPercIso }],        // $_LFO 2 --> Panorama - x
  ["volume", { b: 91 }],        // $_Patch Volume - x
  ["transpose", { b: 93, dispOff: -64 }],        // $_Patch Transposition - x
  ["osc/key/mode", { b: 94, opts: ["Poly", "Mono 1", "Mono 2", "Mono 3", "Mono 4", "Hold"] }],        // $_Oscillator Section Keyboard Mode - x
  ["chorus/type", { b: 103, opts: ["Off", "Classic", "Vintage", "Hyper", "Air", "Vibrato", "Rotary"] }],        // $_Chorus/Type - x
  ["chorus/amt", { b: 104 }],        // $_Chorus/Mix - x
  ["chorus/mix", { b: 105 }],        // $_Chorus/Mix - x
  ["chorus/rate", { b: 106 }],        // $_Chorus/LFO Rate - x
  ["chorus/depth", { b: 107, iso: fullPercIso }],        // $_Chorus/LFO Depth - x
  ["chorus/delay", { b: 108 }],        // $_Chorus/Delay - x
  ["chorus/feedback", { b: 109, iso: bipolarPercIso }],        // $_Chorus/Feedback - x
  ["chorus/shape", { b: 110, opts: delayLFOWaveOptions }],        // $_Chorus/LFO Shape - x
  ["chorus/cross", { b: 111 }],        // $_Chorus/X Over - x

  ["delay/mode", { b: 112, opts: delayModeOptions, startIndex: 1 }],        // $_Delay Mode - x
  ["delay/send", { b: 113, iso: delaySendIso }],        // $_Delay Send - x
  ["delay/time", { b: 114, iso: delayTimeIso)        // $_Delay Time (ms }], - x
  ["delay/feedback", { b: 115, iso: fullPercIso }],        // $_Delay Feedback - x. ACTUALLY depends on mode
  ["delay/rate", { b: 116 }],        // $_Delay LFO Rate - x
  ["delay/depth", { b: 117, iso: fullPercIso }],        // $_Delay LFO Depth - x
  ["delay/shape", { b: 118, opts: delayLFOWaveOptions }],        // $_Delay LFO Shape - x
  ["delay/color", { b: 119, dispOff: -64 }],        // $_Delay Color - x
  ["local", { b: 122)        // $_CC/Local On (prob no sens on a desktop module }],!
//    [[.], { b: 123 }],        // $_CC/All Notes Off

  ["arp/pattern", { b: 130, max: 63, iso: arpPatternIso }],        // $_Arpeggiator/Pattern - x
  ["arp/range", { b: 131, max: 3, dispOff: 1 }],        // $_Arpeggiator Range In Octaves - x
  ["arp/hold", { b: 132 }],        // $_Arpeggiator Hold Mode - x
  ["arp/note/length", { b: 133, iso: bipolarPercIso }],        // $_Arpeggiator Note Length - x
  ["arp/swing", { b: 134, iso: arpSwingIso }],        // $_Arpeggiator Swing Factor - x
  ["lfo/2/rate", { b: 135 }],        // $_LFO 3/Rate - x
  ["lfo/2/shape", { b: 136, max: 67, iso: lfoShapeIso }],        // $_LFO 3/Waveform Shape - x
  ["lfo/2/mode", { b: 137, opts: ["Poly", "Mono"] }],        // $_LFO 3 Mode - x
  ["lfo/2/keyTrk", { b: 138, iso: fullPercIso }],        // $_LFO 3 Keyfollow - x
  ["lfo/2/dest", { b: 139, opts: ["Osc 1 Pitch", "Osc 1+2 Pitch", "Osc 2 Pitch", "Osc 1 PW", "Osc 1+2 PW", "Osc 2 PW", "Sync Phase"] }],        // $_LFO 3 User Destination - x
  ["lfo/2/dest/amt", { b: 140, iso: fullPercIso }],        // $_LFO 3 User Destination Amount - x
  ["lfo/2/fade", { b: 141 }],        // $_LFO 3/Fade In Time - x
  // byte 142???
  ["arp/mode", { b: 143, opts: ["Off", "Up", "Down", "Up&Down", "As Played", "Random", "Chord", "Arp>Matrix"] }],        // $_Arpeggiator/Mode - x
  ["tempo", { b: 144, dispOff: 63)        // $_Tempo (Disabled When Used With Virus Control }], - x
  ["arp/clock", { b: 145, opts: arpResolutionOptions, startIndex: 1 }],        // $_Arpeggiator Clock - ???? resolution?
  ["lfo/0/clock", { b: 146, opts: lfoClockOptions }],        // $_LFO 1/Clock - x
  ["lfo/1/clock", { b: 147, opts: lfoClockOptions }],        // $_LFO 2/Clock - x
  ["delay/clock", { b: 148, opts: delayClockOptions }],        // $_Delay Clock - x
  ["lfo/2/clock", { b: 149, opts: lfoClockOptions }],        // $_LFO 3/Clock - x
  ["param/smooth", { b: 153, opts: smoothOptions }],        // $_Parameter Smooth Mode - x
  ["bend/up", { b: 154, dispOff: -64 }],        // $_Bender Up Range - x
  ["bend/down", { b: 155, dispOff: -64 }],        // $_Bender Down Range - x
  ["bend/scale", { b: 156, opts: ["Linear", "Expon"] }],        // $_Bender Scale - x
  ["filter/0/env/polarity", { b: 158, opts: ["Negative", "Positive"] }],        // $_Filter 1 Envelope Polarity - x
  ["filter/1/env/polarity", { b: 159, opts: ["Negative", "Positive"] }],        // $_Filter 2 Polarity - x
  ["filter/cutoff/link", { b: 160 }],        // $_Filter Cutoff Link - x
  ["filter/keyTrk/start", { b: 161, iso: Miso.noteName(zeroNote: "C-1") }],        // $_Filter Keyfollow Base - x
  ["fm/mode", { b: 162, opts: ["Pos Tri", "Triangle", "Wave", "Noise", "In L", "In L+R", "In R"] }],        // $_FM Mode - x
  ["osc/innit/phase", { b: 163, iso: noiseVolIso }],        // $_Oscillator Section Initial Phase - x
  ["osc/pushIt", { b: 164, iso: fullPercIso }],        // $_Oscillator Punch Intensity - x
  ["input/follow", { b: 166, opts: ["Off", "In L", "In L+R", "In R"] }],        // $_Input Follower/Select - x
  ["vocoder/mode", { b: 167, opts: vocoderModes }],        // $_Vocoder Mode - x
  ["osc/2/mode", { b: 169, rng: [0, 67], iso: osc2WaveIso }],        // $_Oscillator 3 Model - x
  ["osc/2/level", { b: 170 }],        // $_Oscillator 3 Volume - x
  ["osc/2/semitone", { b: 171, rng: [16, 112], dispOff: -64 }],        // $_Oscillator 3 Detune In Semitone - x
  ["osc/2/fine", { b: 172, iso: Miso.switcher(`int(0/${0)}`, default: Miso.m(-1)) >>> Miso.str() }],        // $_Oscillator 3 Fine Detune - x
  ["eq/lo/freq", { b: 173, iso: loFreqIso)        // $_EQ/Low Frequency (Hz }], - x
  ["eq/hi/freq", { b: 174, iso: hiFreqIso)        // $_EQ/High Frequency (kHz }], - x
  ["osc/0/shape/velo", { b: 175, iso: bipolarPercIso }],        // $_Velocity -->Osc1 Waveform Shape - x
  ["osc/1/shape/velo", { b: 176, iso: bipolarPercIso }],        // $_Velocity --> Osc2 Waveform Shape - x
  ["velo/pw", { b: 177, iso: bipolarPercIso }],        // $_Velocity --> Pulsewidth - x
  ["velo/fm", { b: 178, iso: bipolarPercIso }],        // $_Velocity --> FM Amount - x
  ["knob/0/name", { b: 179, opts: knobNames }],        // $_Soft Knob 1 Name - x
  ["knob/1/name", { b: 180, opts: knobNames }],        // $_Soft Knob 2 Name - x
  ["knob/2/name", { b: 181, opts: knobNames }],        // $_Soft Knob 3 Name - x
  ["velo/filter/0/env", { b: 182, iso: bipolarPercIso }],        // $_Velocity --> Filter 1 Envelope Amount - x
  ["velo/filter/1/env", { b: 183, iso: bipolarPercIso }],        // $_Velocity --> Filter 2 Envelope Amount - x
  ["velo/filter/0/reson", { b: 184, iso: bipolarPercIso }],        // $_Velocity -->Filter 1 Resonance - x
  ["velo/filter/1/reson", { b: 185, iso: bipolarPercIso }],        // $_Velocity --> Filter 2 Resonance - x
  ["surround/balance", { b: 186 }],        // $_Surround  Channel Balance - x
  // surround output doesn't seem to be in the patch?
  ["velo/volume", { b: 188, iso: bipolarPercIso }],        // $_Velocity --> Volume - x
  ["velo/pan", { b: 189, iso: bipolarPercIso }],        // $_Velocity --> Panorama - x
  ["knob/0/dest", { b: 190, opts: knobOptions }],        // $_Soft Knob 1 Destination - x
  ["knob/1/dest", { b: 191, opts: knobOptions }],        // $_Soft Knob 2 Destination - x

  ["mod/0/src", { b: 192, opts: modSrcOptions }],        // $_Mod Matrix Slot 1/Source - x
  ["mod/0/dest/0", { b: 193, opts: modDestOptions }],        // $_Mod Matrix Slot 1/Destination 1 - x
  ["mod/0/amt/0", { b: 194, dispOff: -64 }],        // $_Mod Matrix Slot 1/Amount 1 - x
  ["mod/1/src", { b: 195, opts: modSrcOptions }],        // $_Mod Matrix Slot 2/Source - x
  ["mod/1/dest/0", { b: 196, opts: modDestOptions }],        // $_Mod Matrix Slot 2/Destination 1 - x
  ["mod/1/amt/0", { b: 197, dispOff: -64 }],        // $_Mod Matrix Slot 2/Amount 1 - x
  ["mod/1/dest/1", { b: 198, opts: modDestOptions }],        // $_Mod Matrix Slot 2/Destination 2 - x
  ["mod/1/amt/1", { b: 199, dispOff: -64 }],        // $_Mod Matrix Slot 2/Amount 2 - x
  ["mod/2/src", { b: 200, opts: modSrcOptions }],        // $_Mod Matrix Slot 3/Source - x
  ["mod/2/dest/0", { b: 201, opts: modDestOptions }],        // $_Mod Matrix Slot 3/Destination 1 - x
  ["mod/2/amt/0", { b: 202, dispOff: -64 }],        // $_Mod Matrix Slot 3/Amount 1 - x
  ["mod/2/dest/1", { b: 203, opts: modDestOptions }],        // $_Mod Matrix Slot 3/Destination 2 - x
  ["mod/2/amt/1", { b: 204, dispOff: -64 }],        // $_Mod Matrix Slot 3/Amount 2 - x
  ["mod/2/dest/2", { b: 205, opts: modDestOptions }],        // $_Mod Matrix Slot 3/Destination 3 - x
  ["mod/2/amt/2", { b: 206, dispOff: -64 }],        // $_Mod Matrix Slot 3/Amount 3 - x

  ["lfo/0/dest", { b: 207, opts: modDestOptions }],        // $_LFO 1 User Destination - x
  ["lfo/0/dest/amt", { b: 208, iso: bipolarPercIso }],        // $_LFO 1 User Destination Amount - x
  ["lfo/1/dest", { b: 209, opts: modDestOptions }],        // $_LFO 2 User Destination - x
  ["lfo/1/dest/amt", { b: 210, iso: bipolarPercIso }],        // $_LFO 2 User Destination Amount - x
  ["phase/mode", { b: 212, max: 5, dispOff: 1 }],        // $_Phaser/Stages - x
  ["phase/mix", { b: 213, iso: noiseVolIso }],        // $_Phaser/Mix - x
  ["phase/rate", { b: 214 }],        // $_Phaser/LFO Rate - x
  ["phase/depth", { b: 215, iso: fullPercIso }],        // $_Phaser/Depth - x
  ["phase/freq", { b: 216 }],        // $_Phaser/Frequency - x
  ["phase/feedback", { b: 217, iso: bipolarPercIso }],        // $_Phaser/Feedback - x
  ["phase/pan", { b: 218 }],        // $_Phaser/Spread - x
  ["eq/mid/gain", { b: 220, iso: eqGainIso)        // $_EQ/Mid Gain (dB }], - x
  ["eq/mid/freq", { b: 221, iso: midFreqIso)        // $_EQ/Mid Frequency (Hz }], - x
  ["eq/mid/q", { b: 222, iso: midQIso }],        // $_EQ/Mid Q-Factor - x
  ["eq/lo/gain", { b: 223, iso: eqGainIso)        // $_EQ/Low Gain (dB }], - x
  ["eq/hi/gain", { b: 224, iso: eqGainIso)        // $_EQ/High Gain (dB }], - x
  ["character/amt", { b: 225, iso: fullPercIsoWOff }],        // $_Character Intensity - x
  ["character/tune", { b: 226 }],        // $_Character Tune - x
  ["ringMod/mix", { b: 227 }],        // $_Ring Modulator Mix - x ??? FX don't seem to use it.
  ["dist/type", { b: 228, opts: distortModes }],        // $_Distortion Type - x
  ["dist/amt", { b: 229, iso: fullPercIso }],        // $_Distortion Intensity - x
  ["mod/3/src", { b: 231, opts: modSrcOptions }],        // $_Mod Matrix Slot 4/Source - x
  ["mod/3/dest/0", { b: 232, opts: modDestOptions }],        // $_Mod Matrix Slot 4/Destination 1 - x
  ["mod/3/amt/0", { b: 233, dispOff: -64 }],        // $_Assign Slot 4/Amount 1 - x
  ["mod/4/src", { b: 234, opts: modSrcOptions }],        // $_Mod Matrix Slot 5/Source - x
  ["mod/4/dest/0", { b: 235, opts: modDestOptions }],        // $_Mod Matrix Slot 5/Destination 1 - x
  ["mod/4/amt/0", { b: 236, dispOff: -64 }],        // $_Mod Matrix Slot 5/Amount 1 - x
  ["mod/5/src", { b: 237, opts: modSrcOptions }],        // $_Mod Matrix Slot 6/Source - x
  ["mod/5/dest/0", { b: 238, opts: modDestOptions }],        // $_Mod Matrix Slot 6/Destination 1 - x
  ["mod/5/amt/0", { b: 239, dispOff: -64 }],        // $_Mod Matrix Slot 6/Amount 1 - x
  ["filter/select", { b: 250, opts: ["Filter 1", "Filter 2", "Filter 1+2"] }],        // $_Filter Select - x
  ["category/0", { b: 251, opts: categoryOptions }],        // $_Patch Category 1 - x
  ["category/1", { b: 252, opts: categoryOptions }],        // $_Patch Category 2 - x
//    ["osc/select", { b: 255 }],        // $_Oscillators/Select - ????

  ["reverb/mode", { b: 257, opts: reverbModeOptions, startIndex: 1 }],        // $_Reverb/Mode - x
  ["reverb/send", { b: 258, iso: delaySendIso }],        // $_Reverb/Send - x
  ["reverb/type", { b: 259, opts: reverbTypeOptions }],        // $_Reverb/Type - x
  ["reverb/time", { b: 260 }],        // $_Reverb/Time - x
  ["reverb/redamper", { b: 261, iso: fullPercIso }],        // $_Reverb/Damping - x
  ["reverb/color", { b: 262, dispOff: -64 }],        // $_Reverb/Color - x
  ["reverb/delay", { b: 263, rng: [0, 92], iso: reverbPredelayIso }],        // $_Reverb/Predelay - x
  ["reverb/clock", { b: 264, opts: delayClockOptions }],        // $_Reverb/Clock - x
  ["reverb/feedback", { b: 265 }],        // $_Reverb/Feedback - x
  ["delay/type", { b: 266, opts: ["Classic", "Tape Clked", "Tape Free", "Tape Dppl"] }],        // $_Delay Type - x
  ["delay/ratio", { b: 268, opts: delayRatioOptions }],        // $_Delay Tape Delay Ratio - x
  ["delay/clock/left", { b: 269, opts: delayLRClockOptions }],        // $_Delay Tape Delay Clock Left - x
  ["delay/clock/right", { b: 270, opts: delayLRClockOptions }],        // $_Delay Tape Delay Clock Right - x
  ["delay/bw", { b: 273 }],        // $_Delay Tape Delay Bandwidth - x
  ["freq/shift/type", { b: 275, opts: ["Off", "Ring Mod", "Freq Shift", "Vowel Filter", "Comb Filter", "1 Pole XFade", "2 Pole XFade", "4 Pole XFade", "6 Pole XFade", "LP VariSlope", "HP VariSlope", "BP VariSlope"] }],        // $_Frequency Shifter Type - VOCODER???
  ["freq/shift/mix", { b: 276, iso: fullPercIso }],        // $_Frequency Shifter Mix
  ["freq/shift/freq", { b: 277, dispOff: -64 }],        // $_Frequency Shifter Frequency
  ["freq/shift/phase", { b: 278, dispOff: -64 }],        // $_Frequency Shifter Stereo Phase
  ["freq/shift/left", { b: 279, iso: bipolarPercIso }],        // $_Frequency Shifter Left Shape
  ["freq/shift/right", { b: 280, iso: bipolarPercIso }],        // $_Frequency Shifter Right Shape
  ["freq/shift/reson", { b: 281, dispOff: -64 }],        // $_Frequency Shifter Resonance
  ["character/type", { b: 282, opts: characterTypes }],        // $_Character Type - x
  ["knob/2/dest", { b: 284, opts: knobOptions }],        // $_Soft Knob 3 Destination - x
  ["osc/0/mode", { b: 286, opts: oscModelOptions }],        // $_Oscillator 1 Model - x
  ["osc/1/mode", { b: 291, opts: oscModelOptions }],        // $_Oscillator 2 Model - x
  ["osc/0/formant/pan", { b: 293 }],        // $_Oscillator 1 Formant Spread - x
  ["osc/0/formant/shift", { b: 298, dispOff: -64 }],        // $_Oscillator 1 Formant Shift - x
  ["osc/0/local/detune", { b: 299 }],        // $_Oscillator 1 Local Detune - x
  ["osc/0/int", { b: 300 }],        // $_Oscillator 1 Interpolation - x
  ["osc/1/formant/pan", { b: 313 }],        // $_Oscillator 2 Formant Spread - x
  ["osc/1/formant/shift", { b: 318, dispOff: -64 }],        // $_Oscillator 2 Formant Shift - x
  ["osc/1/local/detune", { b: 319 }],        // $_Oscillator 2 Local Detune - x
  ["osc/1/int", { b: 320 }],        // $_Oscillator 2 Interpolation - x
  ["dist/booster", { b: 326, iso: fullPercIso }],        // $_Distortion Treble Booster - x
  ["dist/hi/cutoff", { b: 327, iso: fullPercIso }],        // $_Distortion High Cut - x
  ["dist/mix", { b: 328, iso: fullPercIso }],        // $_Distortion Mix - x
  ["dist/q", { b: 329, iso: fullPercIso }],        // $_Distortion Quality - x
  ["dist/tone", { b: 330, iso: bipolarPercIso }],        // $_Distortion Tone W - x
      
  ["env/2/attack", { b: 336 }],
  ["env/2/decay", { b: 337 }],
  ["env/2/sustain", { b: 338, iso: fullPercIso }],
  ["env/2/sustain/slop", { b: 339, dispOff: -64 }],
  ["env/2/release", { b: 340 }],
  ["env/3/attack", { b: 341 }],
  ["env/3/decay", { b: 342 }],
  ["env/3/sustain", { b: 343, iso: fullPercIso }],
  ["env/3/sustain/slop", { b: 344, dispOff: -64 }],
  ["env/3/release", { b: 345 }],
  
  ["mod/0/dest/1", { b: 346, opts: modDestOptions }],        // $_Mod Matrix Slot 1/Destination 2 - x
  ["mod/0/amt/1", { b: 347, dispOff: -64 }],        // $_Mod Matrix Slot 1/Amount 2 - x
  ["mod/0/dest/2", { b: 348, opts: modDestOptions }],        // $_Mod Matrix Slot 1/Destination 3 - x
  ["mod/0/amt/2", { b: 349, dispOff: -64 }],        // $_Mod Matrix Slot 1/Amount 3 - x
  ["mod/1/dest/2", { b: 350, opts: modDestOptions }],        // $_Mod Matrix Slot 2/Destination 3 - x
  ["mod/1/amt/2", { b: 351, dispOff: -64 }],        // $_Mod Matrix Slot 2/Amount 3 - x
  ["mod/3/dest/1", { b: 352, opts: modDestOptions }],        // $_Mod Matrix Slot 4/Destination 2 - x
  ["mod/3/amt/1", { b: 353, dispOff: -64 }],        // $_Assign Slot 4/Amount 2 - x
  ["mod/3/dest/2", { b: 354, opts: modDestOptions }],        // $_Mod Matrix Slot 4/Destination 3 - x
  ["mod/3/amt/2", { b: 355, dispOff: -64 }],        // $_Mod Matrix Slot 4/Amount 3 - x
  ["mod/4/dest/1", { b: 356, opts: modDestOptions }],        // $_Mod Matrix Slot 5/Destination 2 - x
  ["mod/4/amt/1", { b: 357, dispOff: -64 }],        // $_Mod Matrix Slot 5/Amount 2 - x
  ["mod/4/dest/2", { b: 358, opts: modDestOptions }],        // $_Mod Matrix Slot 5/Destination 3 - x
  ["mod/4/amt/2", { b: 359, dispOff: -64 }],        // $_Mod Matrix Slot 5/Amount 3 - x
  ["mod/5/dest/1", { b: 360, opts: modDestOptions }],        // $_Mod Matrix Slot 6/Destination 2 - x
  ["mod/5/amt/1", { b: 361, dispOff: -64 }],        // $_Mod Matrix Slot 6/Amount 2 - x
  ["mod/5/dest/2", { b: 362, opts: modDestOptions }],        // $_Mod Matrix Slot 6/Destination 3 - x
  ["mod/5/amt/2", { b: 363, dispOff: -64 }],        // $_Mod Matrix Slot 6/Amount 3 - x
//    ["lfo/0/backup/shape", { b: 366 }],        // $_LFO 1/BackupShape
//    ["lfo/1/backup/shape", { b: 367 }],        // $_LFO 2/BackupShape
//    ["lfo/2/backup/shape", { b: 368 }],        // $_LFO 3/BackupShape
//    ["assign/select", { b: 371 }],        // $_Assigns/Slot Select
//    ["lfo/select", { b: 372 }],        // $_LFOs/Select
//    ["fx/hi/select", { b: 373 }],        // $_FX Upper/Select
//    ["fx/lo/select", { b: 374 }],        // $_FX Lower/Select
//    ["osc/backup/key/mode", { b: 378 }],        // $_Oscillators/BackupKeyMode
//    ["arp/backup/mode", { b: 379 }],        // $_Arpeggiator/BackupMode
//    ["osc/2/backup/mode", { b: 380 }],        // $_Oscillator 3/BackupMode
  ["arp/pattern/length", { b: 383, max: 31, dispOff: 1 }],        // $_Arpeggiator Pattern Length
  
  { prefix: 'arp', count: 32, bx: 3, block: [
    ["length", { b: 384 }],        // $_Step 1 Length
    ["velo", { b: 385 }],        // $_Step 1 Velocity
    ["on", { b: 386 }],        // $_*
  ] },

  ["unison/mode", { b: 504, rng: [0, 7], iso: VirusCVoice.unisonModeIso }],        // $_Unison Mode - x
  ["unison/detune", { b: 505 }],        // $_Unison Detune - x
  ["unison/pan", { b: 506, iso: fullPercIso }],        // $_Unison Panorama Spread - x
  ["unison/phase", { b: 507, dispOff: -64 }],        // $_Unison LFO Phase Offset - x
  ["input/mode", { b: 508, opts: ["Off", "Dynamic", "Static"] }],        // $_Input Mode - x
  ["input/select", { b: 509, opts: ["Left", "L + R", "Right"] }],        // $_Input Select - x
  ["loop", { b: 510, max: 16, iso: atomizerIso }],        // $_Atomizer - x
]

const patchTruss = {
  single: 'voice',
  parms: parms,
  initFile: "virusti-voice-init",
  namePack: [240, 249],
  // get 513 bytes (checksum is in the middle)
  parseBody: ['>',
    ['bytes', { start: 9, count: 513 }],
    [['bytes', { start: 0, count: 256 }], ['bytes', { start: 257, count: 256 }]],
  ],
}

  static func location(forData data: Data) -> Int {
  guard data.count > 8 else { return 0 }
  return Int(data[8])
}

// save as single mode edit buffer patch. 16 deviceId is OMNI
func fileData() -> Data {
  return sysexData(deviceId: 16, bank: 0, part: 0x40)
}
  
func sysexData(deviceId: UInt8, bank: UInt8, part: UInt8) -> Data {
  var data = Data(VirusTI.sysexHeader)
  var b1 = [deviceId, 0x10, bank, part] // these are included in checksum1
  b1.append(contentsOf: bytes[0..<256])
  // b1 holds deviceId + command header + bytes 0..<256
  data.append(contentsOf: b1)
  
  // checksum1
  let checksum1 = b1.map{ Int($0) }.reduce(0, +) & 0x7f
  var b2 = [UInt8(checksum1)]
  b2.append(contentsOf: bytes[256..<512])
  // b2 holds checksum1 + bytes 256..<512
  data.append(contentsOf: b2)
  
  // checksum2
  let checksum2 = (checksum1 + b2.map{ Int($0) }.reduce(0, +)) & 0x7f
  data.append(UInt8(checksum2))

  data.append(0xf7)
  return data
}


class VirusTISeriesVoiceBank<T:VirusTIVoicePatch> : TypicalTypedSysexPatchBank<T>, VoiceBank {

  override class var patchCount: Int { return 128 }
  override class var initFileName: String { return "virusti-voice-bank-init" }

  func sysexData(deviceId: UInt8, bank: UInt8) -> Data {
    return sysexData { $0.sysexData(deviceId: deviceId, bank: bank, part: UInt8($1)) }
  }
  
  override func fileData() -> Data {
    return sysexData(deviceId: 16, bank: 1)
  }

}

const patchTransform = {
  throttle: 100,
  param: (path, parm, value) => {
    let section = param.byte / 128 // should be 0...3
    let cmdByte: UInt8 = [0x70, 0x71, 0x6e, 0x6f][section]
    let cmdBytes = self.sysexCommand([cmdByte, 0x40, UInt8(param.byte % 128), UInt8(value)])
    return [Data(cmdBytes)]
  },
  singlePatch: [[tempPatchData(patch: patch), 10]],
  name: { (patch, path, name) -> [Data]? in
    // batch as a single data so that it doesn't get .wait()s interleaved
    return [Data(patch.nameBytes.enumerated().map {
      Data(self.sysexCommand([0x71, 0x40, UInt8(0x70 + $0.offset), $0.element]))
    }.joined())]

  }
}

const bankTransform = bank => ({
  throttle: 0,
  singleBank: loc => [[sysexData(deviceId, bank + 1, loc), 50]],
})
  
private func tempPatchData(patch: VirusTIVoicePatch) -> [Data] {
  return [patch.sysexData(deviceId: deviceId, bank: 0, part: 0x40)]
}

