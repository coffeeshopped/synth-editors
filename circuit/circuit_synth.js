

// -1, -2 == synth 1, synth 2 temp
function sysexData(location) {
  // location < 0 == temp patch
  const cmd = location < 0 ? 0 : 1
  const loc = location < 0 ? (-location) - 1 : location
  return [0xf0, 0x00, 0x20, 0x29, 0x01, 0x60, cmd, loc, 0x00, 'b', 0xf7]
}
  
const genreOptions = ["None", "Classic", "D&B/Breaks", "House", "Industrial", "Jazz", "R&B/HHop", "Rock/Pop", "Techno", "Dubstep"]

const categoryOptions = ["None", "Arp", "Bass", "Bell", "Classic", "Drum", "Keyboard", "Lead", "Movement", "Pad", "Poly", "SFX", "String", "User", "Voc/Tune"]

const oscWaveOptions = ["Sine", "Triangle", "Sawtooth", "Saw 9:1 PW", "Saw 8:2 PW", "Saw 7:3 PW", "Saw 6:4 PW", "Saw 5:5 PW", "Saw 4:6 PW", "Saw 3:7 PW", "Saw 2:8 PW", "Saw 1:9 PW", "Pulse Width", "Square", "Sine Table", "Analogue Pulse", "Analogue Sync", "Tri-Saw Blend", "Digi Nasty 1", "Digi Nasty 2", "Digi Saw-Square", "Digi Vocal 1", "Digi Vocal 2", "Digi Vocal 3", "Digi Vocal 4", "Digi Vocal 5", "Digi Vocal 6", "Random Coll 1", "Random Coll 2", "Random Coll 3"]

const filterDriveOptions = ["Diode", "Valve", "Clipper", "Cross-over", "Rectifier", "Bit Reduce", "Rate Reduce"]

const filterTypeOptions = ["LP 12dB", "LP 24dB", "BP 6dB", "BP 12dB", "HP 12dB", "HP 24dB"]

const lfoWaveOptions = ["Sine", "Triangle", "Sawtooth", "Square", "Random S/H", "Time S/H", "Piano Env", "Seq 1", "Seq 2", "Seq 3", "Seq 4", "Seq 5", "Seq 6", "Seq 7", "Alt 1", "Alt 2", "Alt 3", "Alt 4", "Alt 5", "Alt 6", "Alt 7", "Alt 8", "Chromatic", "Chroma 16", "Major", "Major 7", "Minor 7", "Min Arp 1", "Min Arp 2", "Diminished", "Dec Minor", "Minor 3rd", "Pedal", "4ths", "4ths x12", "1625 Maj", "1625 Min", "2511"]

const lfoPhaseOptions = ([0, 119]).map { `${$0 * 3}` }

const lfoDelayTriggerOptions = ["Single", "Multi"]

const lfoFadeOptions = ["Fade In", "Fade Out", "Gate In", "Gate Out"]

const syncOptions = ["Off", "1/32 T", "1/32", "1/16 T", "1/16", "1/8 T", "1/16 D", "1/8", "1/4 T", "1/8 D", "1/4", "1+ 1/3", "1/4 D", "1/2", "2+ 2/3", "3 Beats", "4 Beats", "5+ 1/3", "6 Beats", "8 Beats", "10 + 2/3", "12 Beats", "13+ 1/3", "16 Beats", "18 Beats", "18+ 2/3", "20 Beats", "21+ 1/3", "24 Beats", "28 Beats", "30 Beats", "32 Beats", "36 Beats", "42 Beats", "48 Beats", "64 Beats"]

const modSrcOptions = ["Direct", "Modulation Wheel", "After Touch", "Expression", "Velocity", "Keyboard", "LFO 1 +", "LFO 1 +/-", "LFO 2 +", "LFO 2 +/-", "Env Amp", "Env Filter", "Env 3"]

const modDestOptions = ["Osc 1/2 Pitch", "Osc 1 Pitch", "Osc 2 Pitch", "Osc 1 V-sync", "Osc 2 V-sync", "Osc 1 PW", "Osc 2 PW", "Osc 1 Level", "Osc 2 Level", "Noise Level", "Ring Mod 1*2 Level", "Drive Amount", "Frequency", "Resonance", "LFO 1 Rate", "LFO 2 Rate", "Amp Env Decay", "Mod Env Decay"]

const macroDestOptions = ["Off", "Porta Rate", "Post FX Level", "Osc 1 Wave Interp", "Osc 1 PW Index", "Osc 1 VSync Depth", "Osc 1 Density", "Osc 1 Density Detune", "Osc 1 Semitones", "Osc 1 Cents", "Osc 2 Wave Interp", "Osc 2 PW Index", "Osc 2 VSync Depth", "Osc 2 Density", "Osc 2 Density Detune", "Osc 2 Semitones", "Osc 2 Cents", "Osc 1 Level", "Osc 2 Level", "Ring Mod Level", "Noise Level", "Cutoff", "Resonance", "Drive", "Key Track", "Env 2 Mod", "Env 1 Attack", "Env 1 Decay", "Env 1 Sustain", "Env 1 Release", "Env 2 Attack", "Env 2 Decay", "Env 2 Sustain", "Env 2 Release", "Env 3 Delay", "Env 3 Attack", "Env 3 Decay", "Env 3 Sustain", "Env 3 Release", "LFO 1 Rate", "LFO 1 Sync", "LFO 1 Slew", "LFO 2 Rate", "LFO 2 Sync", "LFO 2 Slew", "Distortion Level", "Chorus Level", "Chorus Rate", "Chorus Feedback", "Chorus Depth", "Chorus Delay", "Mod Matrix 1", "Mod Matrix 2", "Mod Matrix 3", "Mod Matrix 4", "Mod Matrix 5", "Mod Matrix 6", "Mod Matrix 7", "Mod Matrix 8", "Mod Matrix 9", "Mod Matrix 10", "Mod Matrix 11", "Mod Matrix 12", "Mod Matrix 13", "Mod Matrix 14", "Mod Matrix 15", "Mod Matrix 16", "Mod Matrix 17", "Mod Matrix 18", "Mod Matrix 19", "Mod Matrix 20"]

const parms = [
  ["category", { p: -1, b: 16, opts: categoryOptions }],
  ["genre", { p: -1, b: 17, opts: genreOptions }],
  { inc: 1, b: 32, block: [
    ["poly", { p: 3, opts: ["Mono", "Mono AG", "Poly"] }],
    ["porta", { p: 5 }],
    ["glide", { p: 9, rng: [52, 76], dispOff: -64 }],
    ["octave", { p: 13, rng: [58, 69], dispOff: -64 }],
    { prefix: 'osc/0', block: [
      ["wave", { p: 19, opts: oscWaveOptions }],
      ["wave/mix", { p: 20 }],
      ["pw", { p: 21, dispOff: -64 }],
      ["sync", { p: 22 }],
      ["unison", { p: 24 }],
      ["unison/detune", { p: 25 }],
      ["semitone", { p: 26, dispOff: -64 }],
      ["detune", { p: 27, dispOff: -64 }],
      ["bend", { p: 28, rng: [52, 76], dispOff: -64 }],
    ] },
    { prefix: 'osc/1', block: [
      ["wave", { p: 29, opts: oscWaveOptions }],
      ["wave/mix", { p: 30 }],
      ["pw", { p: 31, dispOff: -64 }],
      ["sync", { p: 33 }],
      ["unison", { p: 35 }],
      ["unison/detune", { p: 36 }],
      ["semitone", { p: 37, dispOff: -64 }],
      ["detune", { p: 39, dispOff: -64 }],
      ["bend", { p: 40, rng: [52, 76], dispOff: -64 }],
    ] },
    
    ["mix/osc/0", { p: 51 }],
    ["mix/osc/1", { p: 52 }],
    ["mix/ringMod", { p: 54 }],
    ["mix/noise", { p: 56 }],
    ["mix/pre/fx", { p: 58, rng: [52, 82], dispOff: -64 }],
    ["mix/post/fx", { p: 59, rng: [52, 82], dispOff: -64 }],
    
    ["filter/routing", { p: 60, opts: ["Normal", "Osc 1 Bypass", "Osc 1/2 Bypass"] }],
    ["filter/drive", { p: 63 }],
    ["filter/drive/type", { p: 65, opts: filterDriveOptions }],
    ["filter/type", { p: 68, opts: filterTypeOptions }],
    ["filter/cutoff", { p: 74 }],
    ["filter/trk", { p: 69 }],
    ["filter/reson", { p: 71 }],
    ["filter/q/normal", { p: 78 }],
    ["filter/env/1/cutoff", { p: 79, dispOff: -64 }],
    
    ["env/0/velo", { p: 108, dispOff: -64 }],
    ["env/0/attack", { p: 73 }],
    ["env/0/decay", { p: 75 }],
    ["env/0/sustain", { p: 70 }],
    ["env/0/release", { p: 72 }],
    
    ["env/1/velo", { p: 10000, dispOff: -64 }],
    ["env/1/attack", { p: 10001 }],
    ["env/1/decay", { p: 10002 }],
    ["env/1/sustain", { p: 10003 }],
    ["env/1/release", { p: 10004 }],
    
    ["env/2/delay", { p: 10014 }],
    ["env/2/attack", { p: 10015 }],
    ["env/2/decay", { p: 10016 }],
    ["env/2/sustain", { p: 10017 }],
    ["env/2/release", { p: 10018 }],
  ] },
  { prefix: 'lfo/0', block: [
    ["wave", { p: 10070, b: 84, opts:lfoWaveOptions }],
    ["phase", { p: 10071, b: 85, opts: lfoPhaseOptions }],
    ["slew", { p: 10072, b: 86 }],
    ["delay", { p: 10074, b: 87 }],
    ["delay/sync", { p: 10075, b: 88, opts: syncOptions }],
    ["rate", { p: 10076, b: 89 }],
    ["rate/sync", { p: 10077, b: 90, opts: syncOptions }],
    ["oneShot", { p: 10122, b: 91, bit: 0 }],
    ["key/sync", { p: 10122, b: 91, bit: 1 }],
    ["common/sync", { p: 10122, b: 91, bit: 2 }],
    ["delay/trigger", { p: 10122, b: 91, bit: 3, opts: lfoDelayTriggerOptions }],
    ["fade", { p: 10123, b: 91, bits: [4, 5], opts: lfoFadeOptions }],
  ] },
  { prefix: 'lfo/1', block: [
    ["wave", { p: 10079, b: 92, opts:lfoWaveOptions }],
    ["phase", { p: 10080, b: 93, opts: lfoPhaseOptions }],
    ["slew", { p: 10081, b: 94 }],
    ["delay", { p: 10083, b: 95 }],
    ["delay/sync", { p: 10084, b: 96, opts: syncOptions }],
    ["rate", { p: 10085, b: 97 }],
    ["rate/sync", { p: 10086, b: 98, opts: syncOptions }],
    ["oneShot", { p: 10122, b: 99, bit: 0 }],
    ["key/sync", { p: 10122, b: 99, bit: 1 }],
    ["common/sync", { p: 10122, b: 99, bit: 2 }],
    ["delay/trigger", { p: 10122, b: 99, bit: 3, opts: lfoDelayTriggerOptions }],
    ["fade", { p: 10123, b: 99, bits: [4, 5], opts: lfoFadeOptions }],
  ] },
  
  ["dist/level", { p: 91, b: 100 }],
  ["chorus/level", { p: 93, b: 102 }],
  ["eq/lo/freq", { p: 10104, b: 105 }],
  ["eq/lo/level", { p: 10105, b: 106, dispOff: -64 }],
  ["eq/mid/freq", { p: 10106, b: 107 }],
  ["eq/mid/level", { p: 10107, b: 108, dispOff: -64 }],
  ["eq/hi/freq", { p: 10108, b: 109 }],
  ["eq/hi/level", { p: 10109, b: 110, dispOff: -64 }],
  ["dist/type", { p: 11000, b: 116, opts: filterDriveOptions }],
  ["dist/adjust", { p: 11001, b: 117 }],
  ["chorus/type", { p: 11024, b: 118, opts: ["Phaser", "Chorus"] }],
  ["chorus/rate", { p: 11025, b: 119 }],
  ["chorus/rate/sync", { p: 11026, b: 120, opts: syncOptions }],
  ["chorus/feedback", { p: 11027, b: 121, dispOff: -64 }],
  ["chorus/mod/depth", { p: 11028, b: 122 }],
  ["chorus/delay", { p: 11029, b: 123 }],
  { prefix: 'mod', count: 20, bx: 4, block: (mod) => {
    const pbase = (mod < 9 ? 11083 : 12000) + mod * 5
    return [ 
      ["src/0", { p: pbase, b: 124, opts: modSrcOptions }],
      ["src/1", { p: pbase + (mod < 14 ? 1 : 2), b: 125, opts: modSrcOptions }],
      ["depth", { p: pbase + 3, b: 126, dispOff: -64 }],
      ["dest", { p: pbase + 4, b: 127, opts: modDestOptions }],
    ]
  } },
  { prefix: 'macro', count: 8, bx: 17, block: (macro) => [
    ["level", { p: 80 + macro, b: 204 }],
    { prefix: 'part', count: 4, bx: 4, block: (part) => {
      const pbase = 13000 + (macro * 16) + (part * 4)
      return [
        ["dest", { p: pbase + 0, b: 205, opts: macroDestOptions }],
        ["start", { p: pbase + 1, b: 206 }],
        ["end", { p: pbase + 2, b: 207 }],
        ["depth", { p: pbase + 3, b: 208, dispOff: -64 }],
      ]
    } },
  ] },
]

const patchTruss = {
  single: 'circuit.synth',
  parms: parms,
  namePack: [0, 15],
  initFile: "circuit-synth-init",
  parseBody: ['bytes', { start: 9, count: 340 }],
  createFile: sysexData(-1),
}

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 64,
  initFile: "circuit-synth-bank-init",
}


const patchTransform(location) = {
  throttle: 200,
  singlePatch: patch.sysexData(-(location + 1)),
  param: (path, parm, value) => {
      guard let param = type(of: patch).params[path] else { return nil }
  let channel = self.channel(forSynth: location)
  switch param.parm {
  case 0..<10000:
    // CC
    return [Data(Midi.cc(param.parm, value: value, channel: channel))]
  case 10000..<Int.max:
    // NRPN
    let msbCC = (param.parm - 10000) / 1000
    let lsbCC = (param.parm - 10000) % 1000
    let v: Int
    switch lsbCC {
    case 122:
      guard let lfo = path.i(1) else { return nil }
      switch path[2] {
      case .oneShot:
        v = 12 + value + lfo * 10
      case .key:
        v = 14 + value + lfo * 10
      case .common:
        v = 16 + value + lfo * 10
      case .delay:
        v = 18 + value + lfo * 10
      default:
        v = 0
      }
    case 123:
      guard let lfo = path.i(1) else { return nil }
      v = value + lfo * 4
    default:
      v = value
    }
    return [Data(
      Midi.cc(99, value: msbCC, channel: channel) +
      Midi.cc(98, value: lsbCC, channel: channel) +
      Midi.cc(6, value: v, channel: channel)
      )]
  default:
    // Send whole patch
    return [patch.sysexData(-(location + 1))]
  }
  }, 
  name: patch.sysexData(-(location + 1)),
}

const bankTransform = {
  throttle: 0,
  singleBank: loc => [[sysexData(loc), 50]],
}


  // static func location(forData data: Data) -> Int { return Int(data[7] & 0x3f) }

  class CircuitSynthBank : TypicalTypedSysexPatchBank<CircuitSynthPatch> {
        
    required public init(data: Data) {
      if data.count > 6 && data[6] == 0x00 {
        // cmd = set temp patch -> this is from a fetch
        let sysex = SysexData(data: data)
        if sysex.count == 64 {
          super.init(patches: sysex.map { Patch(data: $0) })
          return
        }
      }
      super.init(data: data)
    }

    override func fileData() -> Data {
      return sysexData { (patch, location) -> Data in
        patch.sysexData(location: location)
      }
    }
  
  }
