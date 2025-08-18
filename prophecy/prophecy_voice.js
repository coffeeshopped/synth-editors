
const octaveOptions = ["32\"", "16\"", "8\"", "4\""]

const modSrcs = OptionsParam.makeOptions({
  var opts = ["Off"]
  opts += ([1, 4]).map { `EG${$0}` }
  opts += ["Pitch EG", "Amp EG"]
  opts += ([1, 4]).map { `LFO${$0}` }
  opts += ["Portamento", "Note No.", "Velocity", "Pitch Bender", "After Touch"]
  opts += ([0, 95]).map { `CC${$0}` }
  return opts
}())

const lfoSelects: [Int:String] = [7 : "LFO1", 8 : "LFO2", 9 : "LFO3", 10 : "LFO4"]

const envSelects: [Int:String] = {
  var map = [Int:String]()
  ["EG1", "EG2", "EG3", "EG4", "Pitch", "Amp"].enumerated().forEach {
    map[$0.offset + 1] = $0.element
  }
  return map
}()

const noteIso = ['noteName', "C-1"]

const pitchIntIso = Miso.m(0.02) >>> Miso.round(2)

const categoryOptions = ["HardLead", "SoftLead", "SynthBass", "RealBass", "GtrPluck", "Brass", "Reed", "Wind", "Bell", "Keyboard", "Perc", "Motion", "SFX/etc", "Arpeggio", "UserGrp1", "UserGrp2"]

const ctrlOptions = OptionsParam.makeOptions({
  var opts = ["Off", "PBend+/-", "PBend+", "PBend-", "After Touch", ]
  opts += ([0, 95]).map { `CC${$0}` }
  return opts
}())

const knobOptions = ["Off", "PEG_StartLevel", "PEG_AttackTime", "PEG_AttackLevel", "PEG_DecayTime", "PEG_BreakLevel", "PEG_SlopeTime", "PEG_ReleaseTime", "PEG_ReleasLevel", "PortaFingerMode", "PortamentoTime", "PortaTimeVel", "OSC1_Octave", "OSC1_SemiTone", "OSC1_FineTune", "OSC1_FreqOffset", "OSC1PitchLFOInt", "OSC1PitchModInt", "OSC2_Octave", "OSC2_SemiTone", "OSC2_FineTune", "OSC2_FreqOffset", "OSC2PitchLFOInt", "OSC2PitchModInt", "SUBOSC_SemiTone", "SUBOSC_FineTune", "SUBOSC_Wave", "Noise_LPF_Fc", "Filter1_Fc", "Filter1FcEGInt", "Filter1FcLFOInt", "Filter1FcModInt", "Filt1_Resonance", "Filt1ResoModInt", "Filter2_Fc", "Filter2FcEGInt", "Filter2FcLFOInt", "Filter2FcModInt", "Filt2_Resonance", "Filt2ResoModInt", "Amp1_Amplitude", "Amp1_ModInt", "Amp2_Amplitude", "Amp2_ModInt", "AEG_StartLevel", "AEG_AttackTime", "AEG_AttackLevel", "AEG_DecayTime", "AEG_BreakLevel", "AEG_SlopeTime", "AEG_SustanLevel", "AEG_ReleaseTime", "AEG_VelCtlLevel", "AEG_VelAtckTime", "AEG_VelDcayTime", "AEG_VelSlopTime", "AEG_VelRlsTime", "Distortion_Gain", "Distortion_Tone", "Distortion_Bal", "Wah_Resonance", "Wah_Balance", "Chorus_Feedback", "Chorus_Depth", "Chorus_Balance", "Delay_DelayTime", "Delay_Feedback", "Delay_HighDamp", "Delay_Balance", "Reverb_Time", "Reverb_HighDamp", "Reverb_Balance", "Panpot", "EG1_StartLevel", "EG1_AttackTime", "EG1_AttackLevel", "EG1_DecayTime", "EG1_BreakLevel", "EG1_SlopeTime", "EG1_SustanLevel", "EG1_ReleaseTime", "EG1_ReleasLevel", "EG1_VelCtlLevel", "EG1_VelAtckTime", "EG1_VelDcayTime", "EG1_VelSlopTime", "EG1_VelRlsTime", "EG2_StartLevel", "EG2_AttackTime", "EG2_AttackLevel", "EG2_DecayTime", "EG2_BreakLevel", "EG2_SlopeTime", "EG2_SustanLevel", "EG2_ReleaseTime", "EG2_ReleasLevel", "EG2_VelCtlLevel", "EG2_VelAtckTime", "EG2_VelDcayTime", "EG2_VelSlopTime", "EG2_VelRlsTime", "EG3_StartLevel", "EG3_AttackTime", "EG3_AttackLevel", "EG3_DecayTime", "EG3_BreakLevel", "EG3_SlopeTime", "EG3_SustanLevel", "EG3_ReleaseTime", "EG3_ReleasLevel", "EG3_VelCtlLevel", "EG3_VelAtckTime", "EG3_VelDcayTime", "EG3_VelSlopTime", "EG3_VelRlsTime", "EG4_StartLevel", "EG4_AttackTime", "EG4_AttackLevel", "EG4_DecayTime", "EG4_BreakLevel", "EG4_SlopeTime", "EG4_SustanLevel", "EG4_ReleaseTime", "EG4_ReleasLevel", "EG4_VelCtlLevel", "EG4_VelAtckTime", "EG4_VelDcayTime", "EG4_VelSlopTime", "EG4_VelRlsTime", "LFO1_WaveForm", "LFO1_Frequency", "LFO1_AmpOffset", "LFO1_AmpModInt", "LFO1_Fade_In", "LFO2_WaveForm", "LFO2_Frequency", "LFO2_AmpOffset", "LFO2_AmpModInt", "LFO2_Fade_In", "LFO3_WaveForm", "LFO3_Frequency", "LFO3_AmpOffset", "LFO3_AmpModInt", "LFO3_Fade_In", "LFO4_WaveForm", "LFO4_Frequency", "LFO4_AmpOffset", "LFO4_AmpModInt", "LFO4_Fade_In", "Mix_OSC1O1Level", "MixOSC1O1ModInt", "Mix_OSC1O2Level", "MixOSC1O2ModInt", "Mix_OSC2O1Level", "MixOSC2O1ModInt", "Mix_OSC2O2Level", "MixOSC2O2ModInt", "Mix_Sub_O1Level", "Mix_SubO1ModInt", "Mix_Sub_O2Level", "Mix_SubO2ModInt", "Mix_Noi_O1Level", "Mix_NoiO1ModInt", "Mix_Noi_O2Level", "Mix_NoiO2ModInt", "Mix_Fbk_O1Level", "Mix_FbkO1ModInt", "Mix_Fbk_O2Level", "Mix_FbkO2ModInt", "WS1_InputGain", "WS1InGainModInt", "WS1_ShapeTblSel", "WS1_Shape", "WS1_ShapeModInt", "WS1_OutputGain", "WS1_ThruGain", "WS2_InputGain", "WS2InGainModInt", "WS2_ShapeTblSel", "WS2_Shape", "WS2_ShapeModInt", "WS2_OutputGain", "WS2_ThruGain", "TriggerMode", "RetrigThresVel", "RetrigAbvBelw", "ScaleKey", "ScaleType", "RandomPitchInt", "Std1_Wave", "Std1_WaveLevel", "Std1_RampLevel", "Std1_WaveForm", "Std1_WaveLFOInt", "Std1_WaveModInt", "Std2_Wave", "Std2_WaveLevel", "Std2_RampLevel", "Std2_WaveForm", "Std2_WaveLFOInt", "Std2_WaveModInt", "Comb1_NoiseLvl", "Comb1_InWaveLvl", "Comb1_Feedback", "Comb1_FbkEGInt", "Comb1_FbkModInt", "Comb1_LoopLPF", "Comb2_NoiseLvl", "Comb2_InWaveLvl", "Comb2_Feedback", "Comb2_FbkEGInt", "Comb2_FbkModInt", "Comb2_LoopLPF", "VPM1Cr_Wave", "VPM1Cr_Level", "VPM1Cr_LvlEGInt", "VPM1CrLvlModInt", "VPM1_WaveShape", "VPM1WavShLFOInt", "VPM1WavShModInt", "VPM1Cr_Feedback", "VPM1MdPitModInt", "VPM1Md_Wave", "VPM1Md_Level", "VPM1Md_LvlEGInt", "VPM1MdLvlModInt", "VPM2Cr_Wave", "VPM2Cr_Level", "VPM2Cr_LvlEGInt", "VPM2CrLvlModInt", "VPM2_WaveShape", "VPM2WavShLFOInt", "VPM2WavShModInt", "VPM2Cr_Feedback", "VPM2MdPitModInt", "VPM2Md_Wave", "VPM2Md_Level", "VPM2Md_LvlEGInt", "VPM2MdLvlModInt", "Mod_RingCarria", "Mod_CrosCarria", "Mod_CrosDepth", "Mod_SyncWave", "BrassPressEGInt", "BrassLipCharact", "BrassBellTone", "BrassBellReso", "BrassNoiseLevel", "ReedPressEGInt", "ReedReedModInt", "ReedNoiseLevel", "PluckNoiseLevel", "PluckNoiseFc", "PluckStringPosi", "PluckStringLoss", "PluckInharmo"]

  
// std osc
const stdDefaults: [SynthPath:Int] = [
  "normal/wave" : 0,
  "normal/edge" : 99,
  "normal/wave/level" : 99,
  "normal/ramp/level" : 0,
  "normal/form" : 0,
  "normal/lfo" : 7,
  "normal/lfo/amt" : 0,
  "normal/mod/src" : 0,
  "normal/mod/amt" : 0,
]

// comb filter osc
const combDefaults: [SynthPath:Int] = [
  "filter/noise" : 99,
  "filter/wave" : 1,
  "filter/wave/level" : 30,
  "filter/gain" : 30,
  "filter/feedback" : 76,
  "filter/env" : 4,
  "filter/env/amt" : -40,
  "filter/mod/src" : 18,
  "filter/mod/amt" : -41,
  "filter/cutoff" : 99
  ,]

// vpm
const vpmDefaults: [SynthPath:Int] = [
  "fm/carrier/wave" : 2,
  "fm/carrier/level" : 99,
  "fm/carrier/env" : 1,
  "fm/carrier/env/amt" : 0,
  "fm/carrier/mod/src" : 0,
  "fm/carrier/mod/amt" : 0,
  "fm/table" : 19,
  "fm/table/lfo" : 8,
  "fm/table/lfo/amt" : 18,
  "fm/table/mod/src" : 2,
  "fm/table/mod/amt" : 14,
  "fm/carrier/feedback" : 3,
  "fm/mod/coarse" : -12,
  "fm/mod/fine" : 0,
  "fm/mod/pitch/key" : 0,
  "fm/mod/pitch/mod/src" : 0,
  "fm/mod/pitch/mod/amt" : 0,
  "fm/mod/wave" : 0,
  "fm/mod/level" : 20,
  "fm/mod/env" : 2,
  "fm/mod/env/amt" : 46,
  "fm/mod/env/key" : -26,
  "fm/mod/mod/src" : 18,
  "fm/mod/mod/amt" : -50,
]

// mod osc
const modDefaults: [SynthPath:Int] = [
  "mod/type" : 2,
  "mod/input" : 0,
  "mod/ringMod" : 0,
  "mod/cross/carrier" : 0,
  "mod/cross/depth" : 20,
  "mod/cross/env" : 1,
  "mod/cross/env/amt" : 0,
  "mod/cross/mod/src" : 0,
  "mod/cross/mod/amt" : 0,
  "mod/sync/wave" : 0,
  "mod/sync/edge" : 99,
]

// brass osc
const brassDefaults: [SynthPath:Int] = [
  "brass/type" : 0,
  "brass/bend/ctrl" : 14,
  "brass/bend/amt" : 0,
  "brass/bend/direction" : 0,
  "brass/pressure/env" : 2,
  "brass/pressure/env/amt" : 15,
  "brass/pressure/env/mod/src" : 17,
  "brass/pressure/env/mod/amt" : 50,
  "brass/pressure/lfo" : 7,
  "brass/pressure/lfo/amt" : 20,
  "brass/pressure/mod/src" : 1,
  "brass/pressure/mod/amt" : 95,
  "brass/lip/character" : 39,
  "brass/lip/mod/src" : 17,
  "brass/lip/mod/amt" : 61,
  "brass/bell/type" : 0,
  "brass/bell/tone" : 80,
  "brass/bell/reson" : 50,
  "brass/noise" : 30,
]

// reed osc
const reedDefaults: [SynthPath:Int] = [
  "reed/type" : 10,
  "reed/bend/ctrl" : 0,
  "reed/bend/amt" : 0,
  "reed/bend/direction" : 0,
  "reed/pressure/env" : 1,
  "reed/pressure/env/amt" : 99,
  "reed/pressure/env/mod/src" : 1,
  "reed/pressure/env/mod/amt" : 99,
  "reed/pressure/lfo" : 10,
  "reed/pressure/lfo/amt" : 15,
  "reed/pressure/mod/src" : 2,
  "reed/pressure/mod/amt" : 99,
  "reed/mod/src" : 3,
  "reed/mod/amt" : 42,
  "reed/noise" : 80,
]

// pluck osc
const pluckDefaults: [SynthPath:Int] = [
  "pluck/attack/level" : 99,
  "pluck/attack/level/velo" : 55,
  "pluck/noise/level" : 15,
  "pluck/noise/level/velo" : 80,
  "pluck/noise/filter/type" : 2,
  "pluck/noise/filter/cutoff" : 85,
  "pluck/noise/filter/velo" : 0,
  "pluck/noise/filter/reson" : 40,
  "pluck/curve/up" : 50,
  "pluck/curve/up/velo" : 92,
  "pluck/curve/down" : 10,
  "pluck/curve/down/velo" : -99,
  "pluck/attack/edge" : 99,
  "pluck/string/position" : 80,
  "pluck/string/position/velo" : 20,
  "pluck/string/position/mod/src" : 32,
  "pluck/string/position/mod/amt" : 30,
  "pluck/string/damp" : 12,
  "pluck/string/damp/key" : -99,
  "pluck/string/damp/mod/src" : 19,
  "pluck/string/damp/mod/amt" : 60,
  "pluck/off/harmonic/amt" : 72,
  "pluck/off/harmonic/key" : -50,
  "pluck/decay" : 92,
  "pluck/decay/key" : -1,
  "pluck/release" : 84,
  "pluck/release/key" : -50,
]

//  ["osc/select", { p: 154, b: 138, opts: ["Std/Std", "Std/Comb", "Std/VPM", "Std/Mod", "Comb/Comb", "Comb/VPM", "Comb/Mod", "VPM/VPM", "VPM/Mod", "Brass", "Reed", "Pluck"] }],

  const oscPairs: [[SynthPathItem?]] = [
    "normal/normal",
    "normal/filter",
    "normal/fm",
    "normal/mod",
    "filter/filter",
    "filter/fm",
    "filter/mod",
    "fm/fm",
    "fm/mod",
    `brass/${nil}`,
    `reed/${nil}`,
    `pluck/${nil}`,
  ]

const oscDefaults: [SynthPathItem:[SynthPath:Int]] = [
  .normal : stdDefaults,
  .filter : combDefaults,
  .fm : vpmDefaults,
  .mod : modDefaults,
  .brass : brassDefaults,
  .reed : reedDefaults,
  .pluck : pluckDefaults,
]

const parms = [
  ["pgm/category", { p: 17, b: 16, bits: [0, 3], opts: categoryOptions }],
  //    ["category", { p: 18, b: 16, bits: [4, 7] }], // user cat
  //    ["osc/mode", { p: 19, b: 17, bits: [0, 1]) // (solo }],
  ["hold", { p: 21, b: 17, bit: 3 }],
  ["key/priority", { p:22, b: 17, bits: [4, 5], opts: ["Last", "High", "Low"] }],
  ["trigger/mode", { p: 23, b: 17, bits: [6, 7], opts: ["Multi", "Single", "Velo"] }],
  //      (Retrigger Veclocty Control)    18
  ["retrigger/threshold/velo", { p: 24, b: 18, bits: [0, 6], rng: [1, 127] }],
  ["retrigger/direction", { p: 25, b: 18, bit: 7, opts: ["Above", "Below"] }],
  ["scale/key", { p: 26, b: 19, bits: [0, 3], max: 11, iso: Miso.noteName(zeroNote: "C", octave: false) }],
  ["scale/type", { p: 27, b: 19, bits: [4, 7], opts: ["Equal Temperament", "Pure Major", "Pure Minor", "Arabic", "Pythagorean", "Werckmeister", "Kirnberger", "Slendro", "Pelog", "User Scale 1", "User Scale 2"] }],
  ["random/pitch", { p: 28, b: 20, max: 99 }],
  { prefix: 'env', count: 4, bx: 18, px: 18, block: [
    ["start/level", { p: 30, b: 22, rng: [-99, 99] }],
    ["attack/time", { p: 31, b: 23, max: 99 }],
    ["attack/level", { p: 32, b: 24, rng: [-99, 99] }],
    ["decay/time", { p: 33, b: 25, max: 99 }],
    ["decay/level", { p: 3, b: 26, rng: [-99, 99] }],
    ["sustain/time", { p: 35, b: 27, max: 99 }],
    ["sustain/level", { p: 36, b: 28, rng: [-99, 99] }],
    ["release/time", { p: 37, b: 29, max: 99 }],
    ["release/level", { p: 38, b: 30, rng: [-99, 99] }],
    ["key/attack", { p: 39, b: 31, rng: [-99, 99] }],
    ["key/decay", { p: 40, b: 32, rng: [-99, 99] }],
    ["key/slop", { p: 41, b: 33, rng: [-99, 99] }],
    ["key/release", { p: 42, b: 34, rng: [-99, 99] }],
    ["velo/level", { p: 43, b: 35, rng: [-99, 99] }],
    ["velo/attack", { p: 44, b: 36, rng: [-99, 99] }],
    ["velo/decay", { p: 45, b: 37, rng: [-99, 99] }],
    ["velo/slop", { p: 46, b: 38, rng: [-99, 99] }],
    ["velo/release", { p: 47, b: 39, rng: [-99, 99] }],
  ] },
  { prefix: 'lfo', count: 4, bx: 11, px: 13, block: [
    ["wave", { p: 102, b: 94, bits: [0, 4], opts: ["Sin '0", "Sin '180", "Cos '0", "Cos '180", "Tri '0", "Tri '90", "Tri '180", "Tri '270", "Saw Up '0", "Saw Up '180", "Saw Down '0", "Saw Down '180", "Sqr '0", "Sqr '180", "Random 1", "Random 2", "Random 3", "Random 4", "Random 5", "Random 6", "Growl", "Guitar Vibrato", "Step Tri", "Step Saw", "Step Tri4", "Step Saw6", "Exp Saw Up", "Exp Saw Down", "Exp Tri", "String Vibrato"] }],
    ["key/sync", { p: 103, b: 94, bit: 7 }],
    ["mode", { p: 104, b: 94, bits: [5, 6], opts: ["On", "Off", "Both"] }],
    ["freq", { p: 105, b: 95, max: 199 }],
    ["freq/key/trk", { p: 106, b: 96, rng: [-99, 99] }],
    ["freq/ctrl", { p: 107, b: 97, rng: [-99, 99] }],
    ["freq/mod/src", { p: 108, b: 98, opts: modSrcs }],
    ["freq/mod/amt", { p: 109, b: 99, rng: [-99, 99] }],
    ["offset", { p: 110, b: 100, rng: [-99, 99] }],
    ["amp/mod/src", { p: 111, b: 101, opts: modSrcs }],
    ["amp/mod/depth", { p: 112, b: 102, rng: [-99, 99] }],
    ["delay", { p: 113, b: 103, max: 99 }],
    ["fade", { p: 114, b: 104, rng: [-99, 99] }],
  ] },
  ["osc/select", { p: 154, b: 138, opts: ["Std/Std", "Std/Comb", "Std/VPM", "Std/Mod", "Comb/Comb", "Comb/VPM", "Comb/Mod", "VPM/VPM", "VPM/Mod", "Brass", "Reed", "Pluck"] }],
  
  ["pitch/env/start/level", { p: 155, b: 139, rng: [-99, 99] }],
  ["pitch/env/attack/time", { p: 156, b: 140, max: 99 }],
  ["pitch/env/attack/level", { p: 157, b: 141, rng: [-99, 99] }],
  ["pitch/env/decay/time", { p: 158, b: 142, max: 99 }],
  ["pitch/env/decay/level", { p: 159, b: 143, rng: [-99, 99] }],
  ["pitch/env/sustain/time", { p: 160, b: 144, max: 99 }],
  ["pitch/env/release/time", { p: 162, b: 146, max: 99 }],
  ["pitch/env/release/level", { p: 163, b: 147, rng: [-99, 99] }],
  ["pitch/env/key/level", { p: 164, b: 148, rng: [-99, 99] }],
  ["pitch/env/key/time", { p: 165, b: 149, rng: [-99, 99] }],
  ["pitch/env/velo/level", { p: 166, b: 150, rng: [-99, 99] }],
  ["pitch/env/velo/time", { p: 167, b: 151, rng: [-99, 99] }],
  
  ["bend/up", { p: 168, b: 152, rng: [-60, 12] }],
  ["bend/down", { p: 169, b: 153, rng: [-60, 12] }],
  ["bend/step/up", { p: 170, b: 154, bits: [0, 3], rng: [1, 15] }],
  ["bend/step/down", { p: 171, b: 154, bits: [4, 7], rng: [1, 15] }],
  ["bend/aftertouch", { p: 172, b: 155, rng: [-12, 12] }],
  
  ["porta/mode", { p: 173, b: 156, bit: 7, opts: ["Normal", "Fingered"] }],
  ["porta/time", { p: 174, b: 156, bits: [0, 6], max: 99 }],
  ["porta/time/velo", { p: 175, b: 157, rng: [-99, 99] }],
  
  { prefix: 'osc', count: 2, bx: 48, px: 14, block: [
    ["octave", { p: 176, b: 158, opts: octaveOptions }],
    ["coarse", { p: 177, b: 159, rng: [-12, 12] }],
    ["fine", { p: 178, b: 160, rng: [-50, 50] }],
    ["offset", { p: 179, b: 161, rng: [-100, 100], iso: Miso.m(0.1) >>> Miso.round(1) }],
    ["key/lo", { p: 180, b: 162, iso: noteIso }],
    ["key/hi", { p: 181, b: 163, iso: noteIso }],
    ["slop/lo", { p: 182, b: 164, rng: [-50, 100], iso: pitchIntIso }],
    ["slop/hi", { p: 183, b: 165, rng: [-50, 100], iso: pitchIntIso }],
    ["pitch/lfo", { p: 184, b: 166, opts: lfoSelects }],
    ["pitch/lfo/amt", { p: 185, b: 167, rng: [-99, 99] }],
    ["pitch/lfo/aftertouch", { p: 186, b: 168, rng: [-99, 99] }],
    ["pitch/lfo/ctrl", { p: 187, b: 169, rng: [-99, 99] }],
    ["pitch/mod/src", { p: 188, b: 170, opts: modSrcs }],
    ["pitch/mod/amt", { p: 189, b: 171, rng: [-99, 99] }],
  ] },
  { prefix: 'osc', count: 2, bx: 48, px: 4096, block: 
    // parm depends on osc type
    { b: 172, p: 4096, offset: [
      // std osc
      ["normal/wave", { p: 388, b: 0, opts: ["Saw", "Pulse"] }],
      ["normal/edge", { p: 389, b: 1, max: 99 }],
      ["normal/wave/level", { p: 390, b: 2, max: 99 }],
      ["normal/ramp/level", { p: 391, b: 3, max: 99 }],
      ["normal/form", { p: 392, b: 4, rng: [-99, 99] }],
      ["normal/lfo", { p: 393, b: 5, opts: lfoSelects }],
      ["normal/lfo/amt", { p: 394, b: 6, rng: [-99, 99] }],
      ["normal/mod/src", { p: 395, b: 7, opts: modSrcs }],
      ["normal/mod/amt", { p: 396, b: 8, rng: [-99, 99] }],

      // comb filter osc
      ["filter/noise", { p: 397, b: 0, max: 99 }],
      ["filter/wave", { p: 398, b: 1, opts: ["Saw", "Squ", "Tri"] }],
      ["filter/wave/level", { p: 399, b: 2, max: 99 }],
      ["filter/gain", { p: 400, b: 3, max: 99 }],
      ["filter/feedback", { p: 401, b: 4, max: 99 }],
      ["filter/env", { p: 402, b: 5, opts: envSelects }],
      ["filter/env/amt", { p: 403, b: 6, rng: [-99, 99] }],
      ["filter/mod/src", { p: 404, b: 7, opts: modSrcs }],
      ["filter/mod/amt", { p: 405, b: 8, rng: [-99, 99] }],
      ["filter/cutoff", { p: 406, b: 9, max: 99 }],
      
      // vpm
      ["fm/carrier/wave", { p: 407, b: 0, opts: ["Sin", "Saw", "Tri", "Squ"] }],
      ["fm/carrier/level", { p: 408, b: 1, max: 99 }],
      ["fm/carrier/env", { p: 409, b: 2, opts: envSelects }],
      ["fm/carrier/env/amt", { p: 410, b: 3, rng: [-99, 99] }],
      ["fm/carrier/mod/src", { p: 411, b: 4, opts: modSrcs }],
      ["fm/carrier/mod/amt", { p: 412, b: 5, rng: [-99, 99] }],
      ["fm/table", { p: 413, b: 6, max: 99 }],
      ["fm/table/lfo", { p: 414, b: 7, opts: lfoSelects }],
      ["fm/table/lfo/amt", { p: 415, b: 8, rng: [-99, 99] }],
      ["fm/table/mod/src", { p: 416, b: 9, opts: modSrcs }],
      ["fm/table/mod/amt", { p: 417, b: 10, rng: [-99, 99] }],
      ["fm/carrier/feedback", { p: 418, b: 11, max: 99 }],
      ["fm/mod/coarse", { p: 419, b: 12, rng: [-12, 96] }],
      ["fm/mod/fine", { p: 420, b: 13, rng: [-50, 50] }],
      ["fm/mod/pitch/key", { p: 421, b: 14, rng: [-99, 99] }],
      ["fm/mod/pitch/mod/src", { p: 422, b: 15, opts: modSrcs }],
      ["fm/mod/pitch/mod/amt", { p: 423, b: 16, rng: [-99, 99] }],
      ["fm/mod/wave", { p: 424, b: 17, opts: ["Sin", "Saw", "Tri", "Squ", "Osc"] }],
      ["fm/mod/level", { p: 425, b: 18, max: 99 }],
      ["fm/mod/env", { p: 426, b: 19, opts: envSelects }],
      ["fm/mod/env/amt", { p: 427, b: 20, rng: [-99, 99] }],
      ["fm/mod/env/key", { p: 428, b: 21, rng: [-99, 99] }],
      ["fm/mod/mod/src", { p: 429, b: 22, opts: modSrcs }],
      ["fm/mod/mod/amt", { p: 430, b: 23, rng: [-99, 99] }],
      
      // mod osc
      ["mod/type", { p: 431, b: 0, opts: ["Ring", "Cross", "Sync"] }],
      ["mod/input", { p: 432, b: 1, opts: ["Osc1", "Feedbk", "Noise"] }],
      ["mod/ringMod", { p: 433, b: 2, opts: ["Sin", "Saw", "Squ"] }],
      ["mod/cross/carrier", { p: 434, b: 3, opts: ["Sin", "Saw", "Squ"] }],
      ["mod/cross/depth", { p: 435, b: 4, max: 99 }],
      ["mod/cross/env", { p: 436, b: 5, opts: envSelects }],
      ["mod/cross/env/amt", { p: 437, b: 6, rng: [-99, 99] }],
      ["mod/cross/mod/src", { p: 438, b: 7, opts: modSrcs }],
      ["mod/cross/mod/amt", { p: 439, b: 8, rng: [-99, 99] }],
      ["mod/sync/wave", { p: 440, b: 9, opts: ["Saw", "Tri"] }],
      ["mod/sync/edge", { p: 441, b: 10, max: 99 }],
      
      // brass osc
      ["brass/type", { p: 442, b: 0, opts: ["Trumpet 1", "Trumpet 2", "Trombone", "Horn"] }],
      ["brass/bend/ctrl", { p: 443, b: 1, opts: modSrcs }],
      ["brass/bend/amt", { p: 444, b: 2, bits: [0, 5], max: 12 }],
      ["brass/bend/direction", { p: 445, b: 2, bits: [6, 7], opts: ["Up", "Down", "Both"] }],
      ["brass/pressure/env", { p: 446, b: 3, opts: envSelects }],
      ["brass/pressure/env/amt", { p: 447, b: 4, rng: [-99, 99] }],
      ["brass/pressure/env/mod/src", { p: 448, b: 5, opts: modSrcs }],
      ["brass/pressure/env/mod/amt", { p: 449, b: 6, rng: [-99, 99] }],
      ["brass/pressure/lfo", { p: 450, b: 7, opts: lfoSelects }],
      ["brass/pressure/lfo/amt", { p: 451, b: 8, rng: [-99, 99] }],
      ["brass/pressure/mod/src", { p: 452, b: 9, opts: modSrcs }],
      ["brass/pressure/mod/amt", { p: 453, b: 10, rng: [-99, 99] }],
      ["brass/lip/character", { p: 456, b: 13, max: 99 }],
      ["brass/lip/mod/src", { p: 457, b: 14, opts: modSrcs }],
      ["brass/lip/mod/amt", { p: 458, b: 15, rng: [-99, 99] }],
      ["brass/bell/type", { p: 461, b: 18, opts: ["Open", "Mute"] }],
      ["brass/bell/tone", { p: 462, b: 19, max: 99 }],
      ["brass/bell/reson", { p: 463, b: 20, max: 99 }],
      ["brass/noise", { p: 464, b: 21, max: 99 }],

      // reed osc
      ["reed/type", { p: 477, b: 0, opts: ["Soprano Sax", "Alto Sax 1", "Alto Sax 2", "Tenor Sax 1", "Tenor Sax 2", "Bari Sax", "Flute", "Single Reed", "Double Reed", "Recorder", "Bottle", "Glass Bottle", "Monster"] }],
      ["reed/bend/ctrl", { p: 478, b: 1, opts: modSrcs }],
      ["reed/bend/amt", { p: 479, b: 2, bits: [0, 5], max: 12 }],
      ["reed/bend/direction", { p: 480, b: 2, bits: [6, 7], opts: ["Up", "Down", "Both"] }],
      ["reed/pressure/env", { p: 481, b: 3, opts: envSelects }],
      ["reed/pressure/env/amt", { p: 482, b: 4, max: 99 }],
      ["reed/pressure/env/mod/src", { p: 483, b: 5, opts: modSrcs }],
      ["reed/pressure/env/mod/amt", { p: 484, b: 6, rng: [-99, 99] }],
      ["reed/pressure/lfo", { p: 485, b: 7, opts: lfoSelects }],
      ["reed/pressure/lfo/amt", { p: 486, b: 8, rng: [-99, 99] }],
      ["reed/pressure/mod/src", { p: 487, b: 9, opts: modSrcs }],
      ["reed/pressure/mod/amt", { p: 488, b: 10, rng: [-99, 99] }],
      ["reed/mod/src", { p: 491, b: 13, opts: modSrcs }],
      ["reed/mod/amt", { p: 492, b: 14, rng: [-99, 99] }],
      ["reed/noise", { p: 496, b: 18, max: 99 }],

//      ["reed/extra/0", { p: 495, b: 17, max: 99 }],
//      ["reed/extra/1", { p: 497, b: 19, max: 99 }],
//      ["reed/extra/2", { p: 498, b: 20, max: 99 }],
      
      // pluck osc
      ["pluck/attack/level", { p: 512, b: 0, max: 99 }],
      ["pluck/attack/level/velo", { p: 513, b: 1, rng: [-99, 99] }],
      ["pluck/noise/level", { p: 514, b: 2, max: 99 }],
      ["pluck/noise/level/velo", { p: 515, b: 3, rng: [-99, 99] }],
      ["pluck/noise/filter/type", { p: 516, b: 4, opts: ["LPF", "HPF", "BPF"] }],
      ["pluck/noise/filter/cutoff", { p: 517, b: 5, max: 99 }],
      ["pluck/noise/filter/velo", { p: 518, b: 6, rng: [-99, 99] }],
      ["pluck/noise/filter/reson", { p: 519, b: 7, max: 99 }],
      ["pluck/curve/up", { p: 520, b: 8, max: 99 }],
      ["pluck/curve/up/velo", { p: 521, b: 9, rng: [-99, 99] }],
      ["pluck/curve/down", { p: 522, b: 10, max: 99 }],
      ["pluck/curve/down/velo", { p: 523, b: 11, rng: [-99, 99] }],
      ["pluck/attack/edge", { p: 524, b: 12, max: 99 }],
      ["pluck/string/position", { p: 525, b: 13, max: 99 }],
      ["pluck/string/position/velo", { p: 526, b: 14, rng: [-99, 99] }],
      ["pluck/string/position/mod/src", { p: 527, b: 15, opts: modSrcs }],
      ["pluck/string/position/mod/amt", { p: 528, b: 16, rng: [-99, 99] }],
      ["pluck/string/damp", { p: 529, b: 17, max: 99 }],
      ["pluck/string/damp/key", { p: 530, b: 18, rng: [-99, 99] }],
      ["pluck/string/damp/mod/src", { p: 531, b: 19, opts: modSrcs }],
      ["pluck/string/damp/mod/amt", { p: 532, b: 20, rng: [-99, 99] }],
      ["pluck/off/harmonic/amt", { p: 533, b: 21, max: 99 }],
      ["pluck/off/harmonic/key", { p: 534, b: 22, rng: [-99, 99] }],
      ["pluck/decay", { p: 535, b: 23, max: 99 }],
      ["pluck/decay/key", { p: 536, b: 24, rng: [-99, 99] }],
      ["pluck/release", { p: 537, b: 25, max: 99 }],
      ["pluck/release/key", { p: 538, b: 26, rng: [-99, 99] }],
    ] },
  },
  
  ["sub/pitch/src", { p: 204, b: 254, bit: 7, opts: ["Osc1", "Osc2"] }],
  ["sub/coarse", { p: 205, b: 254, bits: [0, 6], rng: [-24, 24] }],
  ["sub/fine", { p: 206, b: 255, rng: [-50, 50] }],
  ["sub/wave", { p: 207, b: 256, opts: ["Sin", "Saw", "Squ", "Tri"] }],
  ["noise/cutoff", { p: 208, b: 257, max: 99 }],
  ["noise/cutoff/key", { p: 209, b: 258, rng: [-99, 99] }],
  
  { prefix: 'osc', count: 2, bx: 13, px: 14, block: [
    ["input/gain", { p: 210, b: 259, max: 99 }],
    ["input/mod/src", { p: 211, b: 260, opts: modSrcs }],
    ["input/mod/amt", { p: 212, b: 261, rng: [-99, 99] }],
    ["input/offset", { p: 213, b: 262, rng: [-99, 99] }],
    ["feedback", { p: 216, b: 265, max: 99 }],
    ["cross", { p: 217, b: 266, max: 99 }],
    ["shape/select", { p: 218, b: 267, bit: 7, opts: ["Clip", "Reso"] }],
    ["shape/amt", { p: 219, b: 267, bits: [0, 6], max: 99 }],
    ["shape/mod/src", { p: 220, b: 268, opts: modSrcs }],
    ["shape/mod/amt", { p: 221, b: 269, rng: [-99, 99] }],
    ["out/gain", { p: 222, b: 270, max: 99 }],
    ["thru/gain", { p: 223, b: 271, max: 99 }],
  ] },
  
  { prefix: 'mix', count: 2, bx: 3, px: 3, block:
    { prefixes: ["osc/0", "osc/1", "sub", "noise", "feedback"], bx: 6, px: 6, block: [
      ["level", { p: 238, b: 285, max: 99 }],
      ["mod/src", { p: 239, b: 286, opts: modSrcs }],
      ["mod/amt", { p: 240, b: 287, rng: [-99, 99] }],
    ] },
  },
  
  ["filter/routing", { p: 268, b: 315, opts: ["Seri1", "Seri2", "Para"] }],

  { prefix: 'filter', count: 2, bx: 16, px: 16, block: [
    ["type", { p: 269, b: 316, opts: ["Thru", "LPF", "HPF", "BPF", "BRF"] }],
    ["input/gain", { p: 270, b: 317, max: 99 }],
    ["cutoff", { p: 271, b: 318, max: 99 }],
    ["cutoff/key/lo", { p: 272, b: 319, iso: noteIso }],
    ["cutoff/key/hi", { p: 273, b: 320, iso: noteIso }],
    ["cutoff/amt/lo", { p: 274, b: 321, rng: [-99, 99] }],
    ["cutoff/amt/hi", { p: 275, b: 322, rng: [-99, 99] }],
    ["cutoff/env", { p: 276, b: 323, opts: envSelects }],
    ["cutoff/env/amt", { p: 277, b: 324, rng: [-99, 99] }],
    ["cutoff/lfo", { p: 278, b: 325, opts: lfoSelects }],
    ["cutoff/lfo/amt", { p: 279, b: 326, rng: [-99, 99] }],
    ["cutoff/mod/src", { p: 280, b: 327, opts: modSrcs }],
    ["cutoff/mod/amt", { p: 281, b: 328, rng: [-99, 99] }],
    ["reson", { p: 282, b: 329, max: 99 }],
    ["reson/mod/src", { p: 283, b: 330, opts: modSrcs }],
    ["reson/mod/amt", { p: 284, b: 331, rng: [-99, 99] }],
  ] },
  
  { prefix: 'amp', count: 2, bx: 9, px: 9, block: [
    ["level", { p: 301, b: 348, max: 99 }],
    ["key/lo", { p: 302, b: 349, iso: noteIso }],
    ["key/hi", { p: 303, b: 350, iso: noteIso }],
    ["amt/lo", { p: 304, b: 351, rng: [-99, 99] }],
    ["amt/hi", { p: 305, b: 352, rng: [-99, 99] }],
    ["env", { p: 306, b: 353, opts: envSelects }],
    ["env/amt", { p: 307, b: 354, rng: [-99, 99] }],
    ["mod/src", { p: 308, b: 355, opts: modSrcs }],
    ["mod/amt", { p: 309, b: 356, rng: [-99, 99] }],
  ] },
  
  { prefix: 'amp/env', block: [
    ["start/level", { p: 319, b: 366, max: 99 }],
    ["attack/time", { p: 320, b: 367, max: 99 }],
    ["attack/level", { p: 321, b: 368, max: 99 }],
    ["decay/time", { p: 322, b: 369, max: 99 }],
    ["decay/level", { p: 323, b: 370, max: 99 }],
    ["sustain/time", { p: 324, b: 371, max: 99 }],
    ["sustain/level", { p: 325, b: 372, max: 99 }],
    ["release/time", { p: 326, b: 373, max: 99 }],
    ["key/attack", { p: 328, b: 375, rng: [-99, 99] }],
    ["key/decay", { p: 329, b: 376, rng: [-99, 99] }],
    ["key/slop", { p: 330, b: 377, rng: [-99, 99] }],
    ["key/release", { p: 331, b: 378, rng: [-99, 99] }],
    ["velo/level", { p: 332, b: 379, rng: [-99, 99] }],
    ["velo/attack", { p: 333, b: 380, rng: [-99, 99] }],
    ["velo/decay", { p: 334, b: 381, rng: [-99, 99] }],
    ["velo/slop", { p: 335, b: 382, rng: [-99, 99] }],
    ["velo/release", { p: 336, b: 383, rng: [-99, 99] }],
  ] },

  ["dist/gain", { p: 337, b: 384, max: 99 }],
  ["dist/tone", { p: 340, b: 387, max: 99 }],
  ["dist/level", { p: 341, b: 388, max: 99 }],
  ["dist/balance", { p: 342, b: 389, max: 100 }],
  ["dist/balance/mod/src", { p: 343, b: 390, opts: modSrcs }],
  ["dist/balance/mod/amt", { p: 344, b: 391, rng: [-99, 99] }],

  ["wah/reson", { p: 345, b: 392, max: 99 }],
  ["wah/freq/lo", { p: 346, b: 393, max: 99 }],
  ["wah/freq/hi", { p: 347, b: 394, max: 99 }],
  ["wah/swing/src", { p: 348, b: 395, opts: modSrcs }],
  ["wah/swing/direction", { p: 349, b: 396, opts: ["+", "-"] }],
  ["wah/level", { p: 350, b: 397, max: 99 }],
  ["wah/balance", { p: 351, b: 398, max: 100 }],
  ["wah/balance/mod/src", { p: 352, b: 399, opts: modSrcs }],
  ["wah/balance/mod/amt", { p: 353, b: 400, rng: [-99, 99] }],

  ["fx/select", { p: 354, b: 401, opts: ["Chorus/Delay", "Reverb"] }],

  ["chorus/delay", { p: 355, b: 402, max: 99, iso: Miso.a(1) >>> Miso.unitFormat("ms") }],
  ["chorus/feedback", { p: 356, b: 403, rng: [-99, 99] }],
  ["chorus/lfo", { p: 357, b: 404, opts: lfoSelects }],
  ["chorus/lfo/amt", { p: 358, b: 405, max: 99 }],
  ["chorus/mod/src", { p: 359, b: 406, opts: modSrcs }],
  ["chorus/mod/amt", { p: 360, b: 407, max: 99 }],
  ["chorus/balance", { p: 361, b: 408, max: 100 }],
  ["chorus/balance/mod/src", { p: 362, b: 409, opts: modSrcs }],
  ["chorus/balance/mod/amt", { p: 363, b: 410, rng: [-99, 99] }],

  ["delay/time", { p: 364, b: 411, max: 99, iso: Miso.a(1) >>> Miso.m(12) >>> Miso.unitFormat("ms") }],
  ["delay/feedback", { p: 365, b: 412, max: 99 }],
  ["delay/hi", { p: 366, b: 413, max: 99 }],
  ["delay/balance", { p: 367, b: 414, max: 100 }],
  ["delay/balance/mod/src", { p: 368, b: 415, opts: modSrcs }],
  ["delay/balance/mod/amt", { p: 369, b: 416, rng: [-99, 99] }],

  ["reverb/delay", { p: 370, b: 417, max: 99 }],
  ["reverb/time", { p: 371, b: 418, max: 99 }],
  ["reverb/hi", { p: 372, b: 419, max: 99 }],
  ["reverb/balance", { p: 373, b: 420, max: 100 }],
  ["reverb/balance/mod/src", { p: 374, b: 421, opts: modSrcs }],
  ["reverb/balance/mod/amt", { p: 375, b: 422, rng: [-99, 99] }],

  ["eq/hi/freq", { p: 376, b: 423, max: 49, iso: Miso.exponReg(a: 1.0003157588738856, b: 0.05775285614799131, c: -0.00016634797948438855) >>> Miso.round(2) >>> Miso.unitFormat("kHz") }],
  ["eq/hi/q", { p: 377, b: 424, max: 29 }],
  ["eq/hi/gain", { p: 378, b: 425, rng: [-18, 18] }],
  ["eq/lo/freq", { p: 379, b: 426, max: 49, iso: Miso.exponReg(a: 50.2962999890187, b: 0.09890607401716418, c: -0.8994057765699203) >>> Miso.round() >>> Miso.unitFormat("Hz") }],
  ["eq/lo/q", { p: 380, b: 427, max: 29 }],
  ["eq/lo/gain", { p: 381, b: 428, rng: [-18, 18] }],

  ["pan", { p: 382, b: 429, dispOff: -64 }],
  ["pan/mod/src", { p: 383, b: 430, opts: modSrcs }],
  ["pan/mod/amt", { p: 384, b: 431, rng: [-99, 99] }],
  ["out/level", { p: 385, b: 432 }],

  ["modWheel/0", { p: 542, b: 435, opts: ctrlOptions }],
  ["modWheel/1", { p: 543, b: 436, opts: ctrlOptions }],
  ["modWheel/2/up", { p: 544, b: 437, opts: ctrlOptions }],
  ["modWheel/2/down", { p: 545, b: 438, opts: ctrlOptions }],
  ["ctrl/x", { p: 546, b: 439, opts: ctrlOptions }],
  ["ctrl/z", { p: 547, b: 440, opts: ctrlOptions }],
  ["foot/pedal", { p: 548, b: 441, opts: ctrlOptions }],
  ["foot/mode", { p: 549, b: 442, opts: ["Off", "Sustain", "Oct Up", "Oct Down", "Porta", "Dist Sw", "Wah Sw", "Delay Sw", "Chorus Sw", "Reverb Sw", "Arp Sw", "Wh3 Hold"] }],
  ["ctrl/x/brk", { p: 550, b: 443, max: 1 }],
  
  { prefix: 'perf', count: 4, bx: 20, px: 20, block: [
    { prefix: 'knob', count: 5, bx: 4, px: 4, block: [
      ["param", { p: 551, b: 444, opts: knobOptions }],
      ["lo", { p: 552, b: 445, max: 100 }],
      ["hi", { p: 553, b: 446, max: 100 }],
      ["curve", { p: 554, b: 447, opts: ["Linear", "Exp", "Log"] }],
    ] },
  ] },
  { prefix: 'perf', count: 4, bx: 20, px: 1, block: (i) => [
    ["on", { p: 631, b: 524, bit: i }],
  ] },
  { prefix: 'knob', count: 5, bx: 1, px: 1, block: [
    ["amt", { p: 635, b: 525 }],
  ] },
  ["porta/on", { p: 640, b: 530, max: 1 }],
]

function sysexDataWithHeader(headerBytes) {
  return [Prophecy.sysexHeader, headerBytes, ['pack78'], 0xf7]
}

/// Edit buffer sysex
const editBuffer = sysexDataWithHeader([0x40, 0x01])

function sysexData(bank, program) {
  return sysexDataWithHeader([0x4c, bank, program, 0x00])
}


const patchTruss = {
  single: 'voice',
  namePack: [0, 15],
  initFile: "prophecy-voice-init",
  validSizes: ['auto', 621],
  createFile: editBuffer,
  parseBody: ['>',
    // let range = data.count == 619 ? 6..<618 : 8..<620
    ['bytes', { start: -613, count: 612 }]
    'unpack87',
  ],
}

static func location(forData data: Data) -> Int { return Int(data[6]) }

const fileDataCount = 619

func unpack(param: Param) -> Int? {
  guard let p = param as? ParamWithRange,
        p.range.lowerBound < 0 else { return defaultUnpack(param: param) }
  
  // handle negative values
  guard let bits = p.bits else { return Int(Int8(bitPattern: bytes[p.byte])) }
  return bytes[p.byte].signedBits(bits)
}

  // TODO
func randomize() {
  randomizeAllParams()

  self["osc/0/coarse"] = 0
  self["osc/0/fine"] = 0
  self["osc/0/offset"] = 0

  (0..<2).forEach { osc in
    self["osc/osc/key/lo"] = 60
    self["osc/osc/key/hi"] = 60
    self["osc/osc/slop/lo"] = 50
    self["osc/osc/slop/hi"] = 50
    self["osc/osc/pitch/lfo/amt"] = ([-7, 7]).random()!
    self["osc/osc/thru/gain"] = 99

  }
  
  let mixPres: [SynthPath] = [
    "osc/0", "osc/1", "sub", "noise", "feedback"
  ]
  (0..<2).forEach { mix in
    self["mix/mix/noise/level"] = ([0, 20]).random()!
  }


  (0..<2).forEach { f in
    self["filter/f/input/gain"] = 99
    self["filter/f/cutoff/key/lo"] = 60
    self["filter/f/cutoff/key/hi"] = 60
    self["filter/f/cutoff/amt/lo"] = 0
    self["filter/f/cutoff/amt/hi"] = 0
  }

  (0..<2).forEach { amp in
    self["amp/amp/level"] = 99
    self["amp/amp/key/lo"] = 60
    self["amp/amp/key/hi"] = 60
    self["amp/amp/amt/lo"] = 0
    self["amp/amp/amt/hi"] = 0
    self["amp/amp/env"] = 6
    self["amp/amp/env/amt"] = 99
  }
  
  self["amp/env/attack/level"] = 99

  
  self["pan"] = 64
  self["out/level"] = 127
  
  if let oscSet = self["osc/select"], oscSet < Self.oscPairs.count {
    let pairs = Self.oscPairs[oscSet]
    (0..<2).forEach { osc in
      guard let tp = pairs[osc] else { return }
      Self.params.forEach { (path, param) in
        guard path.starts(with: `osc/osc/${tp}`) else { return }
        self[path] = param.randomize()
      }
    }
  }
}


class ProphecyVoiceBank : TypicalTypedSysexPatchBank<ProphecyVoicePatch>, VoiceBank {

  override class var fileDataCount: Int { return 39141 }
  override class var patchCount: Int { return 64 }
  override class var initFileName: String { return "prophecy-voice-bank-init" }

  static let contentByteCount = 39132

  static func bankLetter(_ index: Int) -> String {
    return ["A","B"][index]
  }
  
  required init(data: Data) {
    let byteOffset = 8
    let bytesPerPatch = 535 // 34240
    let rawData = Data(data.unpack87(count: bytesPerPatch * Self.patchCount, inRange: byteOffset..<(byteOffset + Self.contentByteCount)))
    let patches = Self.patches(fromData: rawData, offset: 0, bytesPerPatch: bytesPerPatch) {
      Patch(rawBytes: [UInt8]($0))
    }
    super.init(patches: patches)
  }
  

  func sysexData(channel: Int, bank: Int) -> Data {
    var data = Data(Prophecy.sysexHeader(deviceId: UInt8(channel)) + [0x4c, 0x10 + UInt8(bank), 0x00, 0x00])
    let bytesToPack = [UInt8](patches.map { $0.bytes }.joined())
    data.append(Data.pack78(bytes: bytesToPack, count: Self.contentByteCount))
    data.append(0xf7)
    return data
  }
  
  override func fileData() -> Data {
    return sysexData(channel: 0, bank: 0)
  }
    
}
