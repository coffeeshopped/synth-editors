
const pitch2Iso = Miso.switcher([
  .range([0, 118], Miso.lerp(in: [0, 118], out: -12...(-0.2)) >>> Miso.round(1)),
  .range([119, 127], Miso.lerp(in: [119, 127], out: -0.[093, 0]) >>> Miso.round(2)),
  .range([128, 136], Miso.lerp(in: [128, 136], out: [0, 0].093) >>> Miso.round(2)),
  .range([137, 255], Miso.lerp(in: [137, 255], out: 0.[2, 12]) >>> Miso.round(1))
]) >>> Miso.str()
//    Miso.lerp(inRange: [0, 255], outRange: [-12, 12]) >>> Miso.round(1) >>> Miso.str()

const lfoWaveOptions = ["Sine", "Tri", "Square", "Ramp Up", "Ramp Down", "S&H", "S&G"]

const lfoMonoIso = Miso.switcher([
  .int(0, "Poly"),
  .int(1, "Mono")
], default: Miso.a(-1) >>> Miso.str("Spread-%g"))

const oscRangeOptions = ["16'", "8'", "4'"]

const oscModSrcOptions = ["Manual", "LFO 1", "LFO 2", "VCA Env", "VCF Env", "Mod Env"]

const oscPitchModOptions = ["LFO 1", "LFO 2", "VCA Env", "VCF Env", "Mod Env", "LFO 1 Uni", "LFO 2 Uni"]

const portaModeOptions = ["Normal", "Fingered", "Fixed Rate", "Fixed Fingered", "Expon", "Expo Fingered", "Fixed +2", "Fixed -2", "Fixed +5", "Fixed -5", "Fixed +12", "Fixed -12", "Fixed +24", "Fixed -24"]

const envTriggerOptions = ["Key", "LFO 1", "LFO 2", "Loop", "Seq Step"]

const modSrcOptions = ["Off", "Pitch Bend", "Mod Wheel", "Foot Ctrl", "Breath Ctrl", "Pressure", "LFO1", "LFO2", "VCA Env", "VCF Env", "Mod Env", "Note Num", "Note Vel", "Ctrl Seq", "LFO1 (Uni)", "LFO2 (Uni)", "LFO1 (Fade)", "LFO2 (Fade)", "Note Off Vel", "Voice Num", "CC X (115)", "CC Y (116)", "CC Z (117)", "Uni Voice", "Expression"]

const modDestOptions = ["Off", "LFO1 Rate", "LFO1 Delay", "LFO1 Slew", "LFO1 Shape", "LFO2 Rate", "LFO2 Delay", "LFO2 Slew", "LFO2 Shape", "OSC1+2 Pit", "OSC1 Pitch", "OSC2 Pitch", "OSC1 PM Dep", "PWM Depth", "TMod Depth", "OSC2 PM Dep", "Porta Time", "VCF Freq", "VCF Res", "VCF Env", "VCF LFO", "Env Rates", "All Attack", "All Decay", "All Sus", "All Rel", "Env1 Rates", "Env2 Rates", "Env3 Rates", "Env1Curves", "Env2Curves", "Env3Curves", "Env1 Attack", "Env1 Decay", "Env1 Sus", "Env1 Rel", "Env1 AtCur", "Env1 DcyCur", "Env1 SuSCur", "Env1 RelCur", "Env2 Attack", "Env2 Decay", "Env2 Sus", "Env2 Rel", "Env2 AtCur", "Env2 DcyCur", "Env2 SuSCur", "Env2 RelCur", "Env3 Attack", "Env3 Decay", "Env3 Sus", "Env3 Rel", "Env3 AtCur", "Env3 DcyCur", "Env3 SuSCur", "Env3 RelCur", "VCA All**", "VCA Active**", "VCA EnvDep", "Pan Spread", "VCA Pan", "OSC2 Lvl", "Noise Lvl", "HP Freq", "Uni Detune", "OSC Drift", "Param Drift", "Drift Rate", "Arp Gate", "Seq Slew", "Mod 1 Dep", "Mod 2 Dep", "Mod 3 Dep", "Mod 4 Dep", "Mod 5 Dep", "Mod 6 Dep", "Mod 7 Dep", "Mod 8 Dep", "FX1 Param 1", "FX1 Param 2", "FX1 Param 3", "FX1 Param 4", "FX1 Param 5", "FX1 Param 6", "FX1 Param 7", "FX1 Param 8", "FX1 Param 9", "FX1 Param 10", "FX1 Param 11", "FX1 Param 12", "FX2 Param 1", "FX2 Param 2", "FX2 Param 3", "FX2 Param 4", "FX2 Param 5", "FX2 Param 6", "FX2 Param 7", "FX2 Param 8", "FX2 Param 9", "FX2 Param 10", "FX2 Param 11", "FX2 Param 12", "FX3 Param 1", "FX3 Param 2", "FX3 Param 3", "FX3 Param 4", "FX3 Param 5", "FX3 Param 6", "FX3 Param 7", "FX3 Param 8", "FX3 Param 9", "FX3 Param 10", "FX3 Param 11", "FX3 Param 12", "FX4 Param 1", "FX4 Param 2", "FX4 Param 3", "FX4 Param 4", "FX4 Param 5", "FX4 Param 6", "FX4 Param 7", "FX4 Param 8", "FX4 Param 9", "FX4 Param 10", "FX4 Param 11", "FX4 Param 12", "FX1 Level", "FX2 Level", "FX3 Level", "FX4 Level", "OSC1+2 Fine", "OSC1 Fine", "OSC2 Fine"]

const seqClocks = ["4", "3", "2", "1", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "3/64", "1/24", "1/32", "3/128", "1/48", "1/64"]
const seqClockOptions = seqClocks

const lfoClockSteps: [Float] = [0, 13, 26, 39, 52, 64, 77, 90, 103, 116, 128, 141, 154, 167, 180, 192, 205, 218, 231, 244]
const lfoClockIso: Iso<Float,String> = Miso.switcher((0..<20).map {
    let end = $0 < lfoClockSteps.count - 1 ? lfoClockSteps[$0 + 1] - 1 : 255
    return .rangeString((lfoClockSteps[$0])...end, seqClocks[$0])
  })
//    Miso.lerp(inRange: [0, 255], outRange: [0, 19]) >>> Miso.options(seqClocks)

// 0, 13, 64, 77

const seqStepIso = Miso.switcher([
  .int(0, "Skip")
], default: Miso.a(-128) >>> Miso.str())

const arpClockOptions = ["1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32", "1/48"]

const arpPatternIso = Miso.switcher([
  .int(0, "None"),
  .range([1, 32], Miso.str("Preset-%g")),
  .range([33, 64], Miso.a(-32) >>> Miso.str("User-%g"))
])

const fxTypeOptions = ["None", "HallRev", "PlateRev", "RichPltRev", "AmbVerb", "GatedRev", "Reverse", "RackAmp", "MoodFilter", "Phaser", "Chorus", "Flanger", "ModDlyRev", "Delay", "3TapDelay", "4TapDelay", "RotarySpkr", "Chorus-D", "Enhancer", "EdisonEX1", "Auto Pan", "T-RayDelay", "TC-DeepVRB", "FlangVerb", "ChorusVerb", "DelayVerb", "ChamberRev", "RoomRev", "VintageRev", "DualPitch", "MidasEQ", "FairComp", "MulBndDist", "NoiseGate", "DecimDelay", "Vintage Pitch"]

const categoryOptions = ["NONE", "BASS", "PAD", "LEAD", "MONO", "POLY", "STAB", "SFX", "ARP", "SEQ", "PERC", "AMBIENT", "MODULAR", "USER-1", "USER-2", "USER-3", "USER-4"]

const parms = [
  { inc: 1, b: 0, block: [
    ["lfo/0/rate", { max: 255 }],
    ["lfo/0/delay", { max: 255 }],
    ["lfo/0/wave", { opts: lfoWaveOptions }],
    ["lfo/0/key/sync", { max: 1 }],
    ["lfo/0/arp/sync", { max: 1 }],
    ["lfo/0/mono", { max: 255, iso: lfoMonoIso }],
    ["lfo/0/slew", { max: 255 }],
    ["lfo/1/rate", { max: 255 }],
    ["lfo/1/delay", { max: 255 }],
    ["lfo/1/wave", { opts: lfoWaveOptions }],
    ["lfo/1/key/sync", { max: 1 }],
    ["lfo/1/arp/sync", { max: 1 }],
    ["lfo/1/mono", { max: 255, iso: lfoMonoIso }],
    ["lfo/1/slew", { max: 255 }],
    ["osc/0/range", { opts: oscRangeOptions }],
    ["osc/1/range", { opts: oscRangeOptions }],
    ["osc/0/pw/src", { opts: oscModSrcOptions }],
    ["osc/1/tone/src", { opts: oscModSrcOptions }],
    ["osc/0/pulse/on", { max: 1 }],
    ["osc/0/saw/on", { max: 1 }],
    ["osc/sync", { max: 1 }],
    ["osc/0/pitch/mod/depth", { max: 255 }],
    ["osc/0/pitch/mod/src", { opts: oscPitchModOptions }],
    ["osc/0/pitch/aftertouch/depth", { max: 255 }],
    ["osc/0/pitch/modWheel/depth", { max: 255 }],
    ["osc/0/pw/depth", { max: 255 }],
    ["osc/1/level", { max: 255 }],
    ["osc/1/pitch", { max: 255, iso: pitch2Iso }],
    ["osc/1/tone/depth", { max: 255 }],
    ["osc/1/pitch/mod/depth", { max: 255 }],
    ["osc/1/pitch/aftertouch/depth", { max: 255 }],
    ["osc/1/pitch/modWheel/depth", { max: 255 }],
    ["osc/1/pitch/mod/src", { opts: oscPitchModOptions }],
    ["noise", { max: 255 }],
    ["porta/time", { max: 255 }],
    ["porta/mode", { opts: portaModeOptions }],
    ["bend/up", { rng: [-24, 24] }],
    ["bend/down", { rng: [-24, 24], iso: Miso.m(-1) }],
    ["osc/0/pitch/mod/mode", { opts: ["Osc 1+2", "Osc 1"] }],
    { prefix: 'filter', block: [
      ["cutoff", { max: 255 }],
      ["hi/cutoff", { max: 255 }],
      ["reson", { max: 255 }],
      ["env/depth", { max: 255 }],
      ["env/velo", { max: 255 }],
      ["cutoff/bend", { max: 255 }],
      ["lfo/depth", { max: 255 }],
      ["lfo/select", { opts: ["LFO 1", "LFO 2"] }],
      ["aftertouch/lfo", { max: 255 }],
      ["modWheel/lfo", { max: 255 }],
      ["keyTrk", { max: 255 }],
      ["env/polarity", { opts: ["-", "+"] }],
      ["mode", { opts: ["2-pole", "4-pole"] }],
      ["booster", { max: 1 }],
    ] },
    { prefix: 'amp/env', block: [
      ["attack", { max: 255 }],
      ["decay", { max: 255 }],
      ["sustain", { max: 255 }],
      ["release", { max: 255 }],
      ["trigger", { opts: envTriggerOptions }],
      ["attack/curve", { max: 255 }],
      ["decay/curve", { max: 255 }],
      ["sustain/curve", { max: 255 }],
      ["release/curve", { max: 255 }],
    ] },
    { prefix: 'filter/env', block: [
      ["attack", { max: 255 }],
      ["decay", { max: 255 }],
      ["sustain", { max: 255 }],
      ["release", { max: 255 }],
      ["trigger", { opts: envTriggerOptions }],
      ["attack/curve", { max: 255 }],
      ["decay/curve", { max: 255 }],
      ["sustain/curve", { max: 255 }],
      ["release/curve", { max: 255 }],
    ] },
    { prefix: 'mod/env', block: [
      ["attack", { max: 255 }],
      ["decay", { max: 255 }],
      ["sustain", { max: 255 }],
      ["release", { max: 255 }],
      ["trigger", { opts: envTriggerOptions }],
      ["attack/curve", { max: 255 }],
      ["decay/curve", { max: 255 }],
      ["sustain/curve", { max: 255 }],
      ["release/curve", { max: 255 }],
    ] },
    ["amp/level", { max: 255 }],
    ["amp/env/depth", { max: 255 }],
    ["amp/env/velo", { max: 255 }],
    ["pan", { max: 255, dispOff: -128 }],
    ["voice/priority", { opts: ["Lowest", "Highest", "Last"] }],
    ["poly", { opts: ["Poly", "Unison 2", "Unison 3", "Unison 4", "Unison 6", "Unison 12", "Mono", "Mono 2", "Mono 3", "Mono 4", "Mono 6", "Poly 6", "Poly 8"] }],
    ["env/trigger", { opts: ["Mono", "Re-trig", "Legato", "1-shot"] }],
    ["unison/detune", { max: 255 }],
    ["osc/slop", { max: 255 }],
    ["param/slop", { max: 255 }],
    ["slop/rate", { max: 255 }],
    ["porta/balance", { max: 255, dispOff: -128 }],
    ["osc/key/reset", { max: 1 }],
  ] },
  { prefix: 'mod', count: 8, bx: 3, block: [
    ["src", { b: 93, opts: modSrcOptions }],
    ["dest", { b: 94, opts: modDestOptions }],
    ["depth", { b: 95, max: 255, dispOff: -128 }],
  ]}
  ["seq/on", { b: 117, max: 1 }],
  ["seq/clock", { b: 118, opts: seqClockOptions }],
  ["seq/length", { b: 119, max: 30, dispOff: 2 }],
  ["seq/swing", { b: 120, max: 25, dispOff: 50 }],
  ["seq/key/sync/loop", { b: 121, opts: ["Loop", "Key Sync", "Loop+KeySync"] }],
  ["seq/slew/rate", { b: 122, max: 255 }],
  { prefix: 'seq/step', count: 32, bx: 1, block: [
    ["", { b: 123, max: 255, iso: seqStepIso }],
  ] }
  ["arp/on", { b: 155, max: 1 }],
  ["arp/mode", { b: 156, opts: ["Up", "Down", "Up&Down", "Up Inv", "Down Inv", "Up&Down Inv", "Up Alt", "Down Alt", "Random", "Played", "Chord"] }],
  ["arp/rate", { b: 157, max: 255, dispOff: 20 }],
  ["arp/clock", { b: 158, opts: arpClockOptions }],
  ["arp/key/sync", { b: 159, max: 1 }],
  ["arp/gate", { b: 160, max: 255 }],
  ["arp/hold", { b: 161, max: 1 }],
  ["arp/pattern", { b: 162, max: 64, iso: arpPatternIso }],
  ["arp/swing", { b: 163, max: 25, dispOff: 50 }],
  ["arp/octave", { b: 164, max: 5, dispOff: 1 }],
  ["fx/routing", { b: 165 }],
  { prefix: 'fx', count: 4, bx: 13, block: [
    ["type", { b: 166, opts: fxTypeOptions }],
    { prefix: 'param', count: 12, bx: 1, block: [
      ["", { b: 167, max: 255 }],
    ] },
  ] },
  { prefix: 'fx', count: 4, bx: 1, block: [
    ["level", { b: 218, max: 150 }],
  ] },
  ["fx/mode", { b: 222, opts: ["Insert", "Send", "Bypass"] }],
  ["category", { b: 240, opts: categoryOptions }],
  ["transpose", { b: 241, rng: [80, 176], dispOff: -128 }],
]


function sysexData(headerBytes) {
  return [Deepmind12.sysexHeader, headerBytes, ['pack78', 'b', 280], 0xf7]
}

/// Edit buffer sysex
const editBuffer = sysexData([0x04, 0x07])

const patchTruss = {
  single: 'voice',
  parms: parms,
  initFile: "deepmind12-voice-init",
  namePack: [223, 237],
  createFile: editBuffer,
  // 287 is edit buffer, 289 is stored program
  validSizes: ['auto', 291],
}

// func randomize() {
  // self["amp/level"] = 255
  // self["amp/env/depth"] = 255
// }


class Deepmind12VoicePatch : ByteBackedSysexPatch, VoicePatch, BankablePatch {

  static func location(forData data: Data) -> Int { return Int(data[9]) }
  
  // const fileDataCount = 289 // 287 in docs but firmware 1.1.2 seems to up it by 2 bytes
    
  required init(data: Data) {
    let range = data.count == 289 ? 8..<288 : 10..<290
    bytes = data.unpack87(count: 244, inRange: range)
  }
  
  func unpack(param: Param) -> Int? {
    guard let p = param as? ParamWithRange,
          p.range.lowerBound < 0 else { return defaultUnpack(param: param) }
    // handle negative values (bend)
    return Int(Int8(bitPattern: bytes[p.byte]))
  }
    
}

func sysexData(bank, program) {
  return sysexData([0x02, 0x07, bank, program])
}

function bankTruss(bank) => ({
  singleBank: patchTruss,
  patchCount: 128,
  initFile: "deepmind12-voice-bank-init",
  createFile: {
    locationMap: l => sysexData([0x02, 0x07, 0, l])
  },
})

const patchTransform = {
  throttle: 50,
  param: (path, parm, value) => {
    guard let param = type(of: patch).params[path] else { return nil }
    let channel = UInt8(self.channel)
    
    let v: Int
    if let param = param as? ParamWithRange,
       param.range.lowerBound < 0 {
      v = value - param.range.lowerBound
    }
    else {
      v = value
    }
    
    let msgs: [MidiMessage] = [
      .cc(channel: channel, number: 99, value: UInt8(param.byte >> 7)),
      .cc(channel: channel, number: 98, value: UInt8(param.byte & 0x7f)),
      .cc(channel: channel, number: 6, value: UInt8(v >> 7)),
      .cc(channel: channel, number: 38, value: UInt8(v & 0x7f))
    ]
    
    return msgs.map { Data($0.bytes()) }
  },
  singlePatch: [[sysexData, 10]], 
  name: [[sysexData, 10]], 
}

const bankTransform = bank => ({
  throttle: 0,
  singleBank: loc => [[patch.sysexData(channel: self.deviceId, bank: bank, program: $1), 50]],
})


  // override class var fileDataCount: Int { return 128 * 291 }
// 
// static func bankLetter(_ index: Int) -> String {
  // let letters = ["A","B","C","D","E","F","G","H"]
  // return letters[index]
// }
