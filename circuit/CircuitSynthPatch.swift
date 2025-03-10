
class CircuitSynthPatch : ByteBackedSysexPatch, BankablePatch {

  static let bankType: SysexPatchBank.Type = CircuitSynthBank.self
  static func location(forData data: Data) -> Int { return Int(data[7] & 0x3f) }
  
  static let nameByteRange = 0..<16
  static let initFileName = "circuit-synth-init"
  static let fileDataCount = 350
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = [UInt8](data[9..<349])
  }
  
  // -1, -2 == synth 1, synth 2 temp
  func sysexData(location: Int) -> Data {
    // location < 0 == temp patch
    let cmd: UInt8 = location < 0 ? 0 : 1
    let loc: UInt8 = UInt8(location < 0 ? (-location) - 1 : location)
    var data = Data([0xf0, 0x00, 0x20, 0x29, 0x01, 0x60, cmd, loc, 0x00])
    data.append(contentsOf: bytes)
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(location: -1)
  }

  func randomize() {
    randomizeAllParams()
//    self[[.structure]] = (0...10).random()!
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.category]] = OptionsParam(parm: -1, byte: 16, options: categoryOptions)
    p[[.genre]] = OptionsParam(parm: -1, byte: 17, options: genreOptions)
    p[[.poly]] = OptionsParam(parm: 3, byte: 32, options: ["Mono", "Mono AG", "Poly"])
    p[[.porta]] = RangeParam(parm: 5, byte: 33)
    p[[.glide]] = RangeParam(parm: 9, byte: 34, range: 52...76, displayOffset: -64)
    p[[.octave]] = RangeParam(parm: 13, byte: 35, range: 58...69, displayOffset: -64)

    p[[.osc, .i(0), .wave]] = OptionsParam(parm: 19, byte: 36, options: oscWaveOptions)
    p[[.osc, .i(0), .wave, .mix]] = RangeParam(parm: 20, byte: 37)
    p[[.osc, .i(0), .pw]] = RangeParam(parm: 21, byte: 38, displayOffset: -64)
    p[[.osc, .i(0), .sync]] = RangeParam(parm: 22, byte: 39)
    p[[.osc, .i(0), .unison]] = RangeParam(parm: 24, byte: 40)
    p[[.osc, .i(0), .unison, .detune]] = RangeParam(parm: 25, byte: 41)
    p[[.osc, .i(0), .semitone]] = RangeParam(parm: 26, byte: 42, displayOffset: -64)
    p[[.osc, .i(0), .detune]] = RangeParam(parm: 27, byte: 43, displayOffset: -64)
    p[[.osc, .i(0), .bend]] = RangeParam(parm: 28, byte: 44, range: 52...76, displayOffset: -64)

    p[[.osc, .i(1), .wave]] = OptionsParam(parm: 29, byte: 45, options: oscWaveOptions)
    p[[.osc, .i(1), .wave, .mix]] = RangeParam(parm: 30, byte: 46)
    p[[.osc, .i(1), .pw]] = RangeParam(parm: 31, byte: 47, displayOffset: -64)
    p[[.osc, .i(1), .sync]] = RangeParam(parm: 33, byte: 48)
    p[[.osc, .i(1), .unison]] = RangeParam(parm: 35, byte: 49)
    p[[.osc, .i(1), .unison, .detune]] = RangeParam(parm: 36, byte: 50)
    p[[.osc, .i(1), .semitone]] = RangeParam(parm: 37, byte: 51, displayOffset: -64)
    p[[.osc, .i(1), .detune]] = RangeParam(parm: 39, byte: 52, displayOffset: -64)
    p[[.osc, .i(1), .bend]] = RangeParam(parm: 40, byte: 53, range: 52...76, displayOffset: -64)

    p[[.mix, .osc, .i(0)]] = RangeParam(parm: 51, byte: 54)
    p[[.mix, .osc, .i(1)]] = RangeParam(parm: 52, byte: 55)
    p[[.mix, .ringMod]] = RangeParam(parm: 54, byte: 56)
    p[[.mix, .noise]] = RangeParam(parm: 56, byte: 57)
    p[[.mix, .pre, .fx]] = RangeParam(parm: 58, byte: 58, range: 52...82, displayOffset: -64)
    p[[.mix, .post, .fx]] = RangeParam(parm: 59, byte: 59, range: 52...82, displayOffset: -64)
    
    p[[.filter, .routing]] = OptionsParam(parm: 60, byte: 60, options: ["Normal", "Osc 1 Bypass", "Osc 1/2 Bypass"])
    p[[.filter, .drive]] = RangeParam(parm: 63, byte: 61)
    p[[.filter, .drive, .type]] = OptionsParam(parm: 65, byte: 62, options: filterDriveOptions)
    p[[.filter, .type]] = OptionsParam(parm: 68, byte: 63, options: filterTypeOptions)
    p[[.filter, .cutoff]] = RangeParam(parm: 74, byte: 64)
    p[[.filter, .trk]] = RangeParam(parm: 69, byte: 65)
    p[[.filter, .reson]] = RangeParam(parm: 71, byte: 66)
    p[[.filter, .q, .normal]] = RangeParam(parm: 78, byte: 67)
    p[[.filter, .env, .i(1), .cutoff]] = RangeParam(parm: 79, byte: 68, displayOffset: -64)
    
    p[[.env, .i(0), .velo]] = RangeParam(parm: 108, byte: 69, displayOffset: -64)
    p[[.env, .i(0), .attack]] = RangeParam(parm: 73, byte: 70)
    p[[.env, .i(0), .decay]] = RangeParam(parm: 75, byte: 71)
    p[[.env, .i(0), .sustain]] = RangeParam(parm: 70, byte: 72)
    p[[.env, .i(0), .release]] = RangeParam(parm: 72, byte: 73)

    p[[.env, .i(1), .velo]] = RangeParam(parm: 10000, byte: 74, displayOffset: -64)
    p[[.env, .i(1), .attack]] = RangeParam(parm: 10001, byte: 75)
    p[[.env, .i(1), .decay]] = RangeParam(parm: 10002, byte: 76)
    p[[.env, .i(1), .sustain]] = RangeParam(parm: 10003, byte: 77)
    p[[.env, .i(1), .release]] = RangeParam(parm: 10004, byte: 78)

    p[[.env, .i(2), .delay]] = RangeParam(parm: 10014, byte: 79)
    p[[.env, .i(2), .attack]] = RangeParam(parm: 10015, byte: 80)
    p[[.env, .i(2), .decay]] = RangeParam(parm: 10016, byte: 81)
    p[[.env, .i(2), .sustain]] = RangeParam(parm: 10017, byte: 82)
    p[[.env, .i(2), .release]] = RangeParam(parm: 10018, byte: 83)

    p[[.lfo, .i(0), .wave]] = OptionsParam(parm: 10070, byte: 84, options:lfoWaveOptions)
    p[[.lfo, .i(0), .phase]] = OptionsParam(parm: 10071, byte: 85, options: lfoPhaseOptions)
    p[[.lfo, .i(0), .slew]] = RangeParam(parm: 10072, byte: 86)
    p[[.lfo, .i(0), .delay]] = RangeParam(parm: 10074, byte: 87)
    p[[.lfo, .i(0), .delay, .sync]] = OptionsParam(parm: 10075, byte: 88, options: syncOptions)
    p[[.lfo, .i(0), .rate]] = RangeParam(parm: 10076, byte: 89)
    p[[.lfo, .i(0), .rate, .sync]] = OptionsParam(parm: 10077, byte: 90, options: syncOptions)
    p[[.lfo, .i(0), .oneShot]] = RangeParam(parm: 10122, byte: 91, bit: 0)
    p[[.lfo, .i(0), .key, .sync]] = RangeParam(parm: 10122, byte: 91, bit: 1)
    p[[.lfo, .i(0), .common, .sync]] = RangeParam(parm: 10122, byte: 91, bit: 2)
    p[[.lfo, .i(0), .delay, .trigger]] = OptionsParam(parm: 10122, byte: 91, bit: 3, options: lfoDelayTriggerOptions)
    p[[.lfo, .i(0), .fade]] = OptionsParam(parm: 10123, byte: 91, bits: 4...5, options: lfoFadeOptions)

    p[[.lfo, .i(1), .wave]] = OptionsParam(parm: 10079, byte: 92, options:lfoWaveOptions)
    p[[.lfo, .i(1), .phase]] = OptionsParam(parm: 10080, byte: 93, options: lfoPhaseOptions)
    p[[.lfo, .i(1), .slew]] = RangeParam(parm: 10081, byte: 94)
    p[[.lfo, .i(1), .delay]] = RangeParam(parm: 10083, byte: 95)
    p[[.lfo, .i(1), .delay, .sync]] = OptionsParam(parm: 10084, byte: 96, options: syncOptions)
    p[[.lfo, .i(1), .rate]] = RangeParam(parm: 10085, byte: 97)
    p[[.lfo, .i(1), .rate, .sync]] = OptionsParam(parm: 10086, byte: 98, options: syncOptions)
    p[[.lfo, .i(1), .oneShot]] = RangeParam(parm: 10122, byte: 99, bit: 0)
    p[[.lfo, .i(1), .key, .sync]] = RangeParam(parm: 10122, byte: 99, bit: 1)
    p[[.lfo, .i(1), .common, .sync]] = RangeParam(parm: 10122, byte: 99, bit: 2)
    p[[.lfo, .i(1), .delay, .trigger]] = OptionsParam(parm: 10122, byte: 99, bit: 3, options: lfoDelayTriggerOptions)
    p[[.lfo, .i(1), .fade]] = OptionsParam(parm: 10123, byte: 99, bits: 4...5, options: lfoFadeOptions)

    p[[.dist, .level]] = RangeParam(parm: 91, byte: 100)
    p[[.chorus, .level]] = RangeParam(parm: 93, byte: 102)
    p[[.eq, .lo, .freq]] = RangeParam(parm: 10104, byte: 105)
    p[[.eq, .lo, .level]] = RangeParam(parm: 10105, byte: 106, displayOffset: -64)
    p[[.eq, .mid, .freq]] = RangeParam(parm: 10106, byte: 107)
    p[[.eq, .mid, .level]] = RangeParam(parm: 10107, byte: 108, displayOffset: -64)
    p[[.eq, .hi, .freq]] = RangeParam(parm: 10108, byte: 109)
    p[[.eq, .hi, .level]] = RangeParam(parm: 10109, byte: 110, displayOffset: -64)
    p[[.dist, .type]] = OptionsParam(parm: 11000, byte: 116, options: filterDriveOptions)
    p[[.dist, .adjust]] = RangeParam(parm: 11001, byte: 117)
    p[[.chorus, .type]] = OptionsParam(parm: 11024, byte: 118, options: ["Phaser", "Chorus"])
    p[[.chorus, .rate]] = RangeParam(parm: 11025, byte: 119)
    p[[.chorus, .rate, .sync]] = OptionsParam(parm: 11026, byte: 120, options: syncOptions)
    p[[.chorus, .feedback]] = RangeParam(parm: 11027, byte: 121, displayOffset: -64)
    p[[.chorus, .mod, .depth]] = RangeParam(parm: 11028, byte: 122)
    p[[.chorus, .delay]] = RangeParam(parm: 11029, byte: 123)
    
    (0..<20).forEach { mod in
      let off = 124 + mod * 4
      let pbase = (mod < 9 ? 11083 : 12000) + mod * 5
      let src0p = pbase
      let src1p = pbase + (mod < 14 ? 1 : 2)
      let depthp = pbase + 3
      let destp = pbase + 4
      p[[.mod, .i(mod), .src, .i(0)]] = OptionsParam(parm: src0p, byte: off + 0, options: modSrcOptions)
      p[[.mod, .i(mod), .src, .i(1)]] = OptionsParam(parm: src1p, byte: off + 1, options: modSrcOptions)
      p[[.mod, .i(mod), .depth]] = RangeParam(parm: depthp, byte: off + 2, displayOffset: -64)
      p[[.mod, .i(mod), .dest]] = OptionsParam(parm: destp, byte: off + 3, options: modDestOptions)
    }
    
    (0..<8).forEach { macro in
      let off = 204 + macro * 17
      p[[.macro, .i(macro), .level]] = RangeParam(parm: 80 + macro, byte: off + 0)
      (0..<4).forEach { part in
        let off = off + 1 + part * 4
        let pbase = 13000 + (macro * 16) + (part * 4)
        p[[.macro, .i(macro), .part, .i(part), .dest]] = OptionsParam(parm: pbase + 0, byte: off + 0, options: macroDestOptions)
        p[[.macro, .i(macro), .part, .i(part), .start]] = RangeParam(parm: pbase + 1, byte: off + 1)
        p[[.macro, .i(macro), .part, .i(part), .end]] = RangeParam(parm: pbase + 2, byte: off + 2)
        p[[.macro, .i(macro), .part, .i(part), .depth]] = RangeParam(parm: pbase + 3, byte: off + 3, displayOffset: -64)
      }
    }
    
    return p
  }()
  
  static let genreOptions = OptionsParam.makeOptions(["None", "Classic", "D&B/Breaks", "House", "Industrial", "Jazz", "R&B/HHop", "Rock/Pop", "Techno", "Dubstep"])
  
  static let categoryOptions = OptionsParam.makeOptions(["None", "Arp", "Bass", "Bell", "Classic", "Drum", "Keyboard", "Lead", "Movement", "Pad", "Poly", "SFX", "String", "User", "Voc/Tune"])
  
  static let oscWaveOptions = OptionsParam.makeOptions(["Sine", "Triangle", "Sawtooth", "Saw 9:1 PW", "Saw 8:2 PW", "Saw 7:3 PW", "Saw 6:4 PW", "Saw 5:5 PW", "Saw 4:6 PW", "Saw 3:7 PW", "Saw 2:8 PW", "Saw 1:9 PW", "Pulse Width", "Square", "Sine Table", "Analogue Pulse", "Analogue Sync", "Tri-Saw Blend", "Digi Nasty 1", "Digi Nasty 2", "Digi Saw-Square", "Digi Vocal 1", "Digi Vocal 2", "Digi Vocal 3", "Digi Vocal 4", "Digi Vocal 5", "Digi Vocal 6", "Random Coll 1", "Random Coll 2", "Random Coll 3"])
  
  static let filterDriveOptions = OptionsParam.makeOptions(["Diode", "Valve", "Clipper", "Cross-over", "Rectifier", "Bit Reduce", "Rate Reduce"])

  static let filterTypeOptions = OptionsParam.makeOptions(["LP 12dB", "LP 24dB", "BP 6dB", "BP 12dB", "HP 12dB", "HP 24dB"])
  
  static let lfoWaveOptions = OptionsParam.makeOptions(["Sine", "Triangle", "Sawtooth", "Square", "Random S/H", "Time S/H", "Piano Env", "Seq 1", "Seq 2", "Seq 3", "Seq 4", "Seq 5", "Seq 6", "Seq 7", "Alt 1", "Alt 2", "Alt 3", "Alt 4", "Alt 5", "Alt 6", "Alt 7", "Alt 8", "Chromatic", "Chroma 16", "Major", "Major 7", "Minor 7", "Min Arp 1", "Min Arp 2", "Diminished", "Dec Minor", "Minor 3rd", "Pedal", "4ths", "4ths x12", "1625 Maj", "1625 Min", "2511"])
  
  static let lfoPhaseOptions = OptionsParam.makeOptions((0...119).map { "\($0 * 3)" })

  static let lfoDelayTriggerOptions = OptionsParam.makeOptions(["Single", "Multi"])
  
  static let lfoFadeOptions = OptionsParam.makeOptions(["Fade In", "Fade Out", "Gate In", "Gate Out"])
  
  static let syncOptions = OptionsParam.makeOptions(["Off", "1/32 T", "1/32", "1/16 T", "1/16", "1/8 T", "1/16 D", "1/8", "1/4 T", "1/8 D", "1/4", "1+ 1/3", "1/4 D", "1/2", "2+ 2/3", "3 Beats", "4 Beats", "5+ 1/3", "6 Beats", "8 Beats", "10 + 2/3", "12 Beats", "13+ 1/3", "16 Beats", "18 Beats", "18+ 2/3", "20 Beats", "21+ 1/3", "24 Beats", "28 Beats", "30 Beats", "32 Beats", "36 Beats", "42 Beats", "48 Beats", "64 Beats"])
  
  static let modSrcOptions = OptionsParam.makeOptions(["Direct", "Modulation Wheel", "After Touch", "Expression", "Velocity", "Keyboard", "LFO 1 +", "LFO 1 +/-", "LFO 2 +", "LFO 2 +/-", "Env Amp", "Env Filter", "Env 3"])

  static let modDestOptions = OptionsParam.makeOptions(["Osc 1/2 Pitch", "Osc 1 Pitch", "Osc 2 Pitch", "Osc 1 V-sync", "Osc 2 V-sync", "Osc 1 PW", "Osc 2 PW", "Osc 1 Level", "Osc 2 Level", "Noise Level", "Ring Mod 1*2 Level", "Drive Amount", "Frequency", "Resonance", "LFO 1 Rate", "LFO 2 Rate", "Amp Env Decay", "Mod Env Decay"])
  
  static let macroDestOptions = OptionsParam.makeOptions(["Off", "Porta Rate", "Post FX Level", "Osc 1 Wave Interp", "Osc 1 PW Index", "Osc 1 VSync Depth", "Osc 1 Density", "Osc 1 Density Detune", "Osc 1 Semitones", "Osc 1 Cents", "Osc 2 Wave Interp", "Osc 2 PW Index", "Osc 2 VSync Depth", "Osc 2 Density", "Osc 2 Density Detune", "Osc 2 Semitones", "Osc 2 Cents", "Osc 1 Level", "Osc 2 Level", "Ring Mod Level", "Noise Level", "Cutoff", "Resonance", "Drive", "Key Track", "Env 2 Mod", "Env 1 Attack", "Env 1 Decay", "Env 1 Sustain", "Env 1 Release", "Env 2 Attack", "Env 2 Decay", "Env 2 Sustain", "Env 2 Release", "Env 3 Delay", "Env 3 Attack", "Env 3 Decay", "Env 3 Sustain", "Env 3 Release", "LFO 1 Rate", "LFO 1 Sync", "LFO 1 Slew", "LFO 2 Rate", "LFO 2 Sync", "LFO 2 Slew", "Distortion Level", "Chorus Level", "Chorus Rate", "Chorus Feedback", "Chorus Depth", "Chorus Delay", "Mod Matrix 1", "Mod Matrix 2", "Mod Matrix 3", "Mod Matrix 4", "Mod Matrix 5", "Mod Matrix 6", "Mod Matrix 7", "Mod Matrix 8", "Mod Matrix 9", "Mod Matrix 10", "Mod Matrix 11", "Mod Matrix 12", "Mod Matrix 13", "Mod Matrix 14", "Mod Matrix 15", "Mod Matrix 16", "Mod Matrix 17", "Mod Matrix 18", "Mod Matrix 19", "Mod Matrix 20"])
}
