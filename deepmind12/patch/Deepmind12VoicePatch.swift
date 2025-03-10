
class Deepmind12VoicePatch : ByteBackedSysexPatch, VoicePatch, BankablePatch {

  static let bankType: SysexPatchBank.Type = Deepmind12VoiceBank.self
  static func location(forData data: Data) -> Int { return Int(data[9]) }
  
  static let initFileName = "deepmind12-voice-init"
  static let fileDataCount = 289 // 287 in docs but firmware 1.1.2 seems to up it by 2 bytes
  static let nameByteRange = 223..<238
  
  var bytes: [UInt8]
  
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
  
  // 287 is edit buffer, 289 is stored program
  static func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, 291].contains(fileSize)
  }
  
  private func sysexData(channel: Int, headerBytes: [UInt8]) -> Data {
    var data = Data(Deepmind12.sysexHeader(deviceId: UInt8(channel)))
    data.append(contentsOf: headerBytes)
    data.append(Data.pack78(bytes: bytes, count: 280))
    data.append(0xf7)
    return data
  }
  
  /// Edit buffer sysex
  func sysexData(channel: Int) -> Data {
    return sysexData(channel: channel, headerBytes: [0x04, 0x07])
  }
  
  func sysexData(channel: Int, bank: Int, program: Int) -> Data {
    return sysexData(channel: channel, headerBytes: [0x02, 0x07, UInt8(bank), UInt8(program)])
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }

  func randomize() {
    randomizeAllParams()
    
    self[[.amp, .level]] = 255
    self[[.amp, .env, .depth]] = 255
//
//    self[[.extra]] = 0
//    self[[.micro, .tune]] = 0
//    self[[.arp, .on]] = 0
  }

    
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.lfo, .i(0), .rate]] = RangeParam(byte: 0, maxVal: 255)
    p[[.lfo, .i(0), .delay]] = RangeParam(byte: 1, maxVal: 255)
    p[[.lfo, .i(0), .wave]] = OptionsParam(byte: 2, options: lfoWaveOptions)
    p[[.lfo, .i(0), .key, .sync]] = RangeParam(byte: 3, maxVal: 1)
    p[[.lfo, .i(0), .arp, .sync]] = RangeParam(byte: 4, maxVal: 1)
    p[[.lfo, .i(0), .mono]] = MisoParam.make(byte: 5, maxVal: 255, iso: lfoMonoIso)
    p[[.lfo, .i(0), .slew]] = RangeParam(byte: 6, maxVal: 255)
    p[[.lfo, .i(1), .rate]] = RangeParam(byte: 7, maxVal: 255)
    p[[.lfo, .i(1), .delay]] = RangeParam(byte: 8, maxVal: 255)
    p[[.lfo, .i(1), .wave]] = OptionsParam(byte: 9, options: lfoWaveOptions)
    p[[.lfo, .i(1), .key, .sync]] = RangeParam(byte: 10, maxVal: 1)
    p[[.lfo, .i(1), .arp, .sync]] = RangeParam(byte: 11, maxVal: 1)
    p[[.lfo, .i(1), .mono]] = MisoParam.make(byte: 12, maxVal: 255, iso: lfoMonoIso)
    p[[.lfo, .i(1), .slew]] = RangeParam(byte: 13, maxVal: 255)
    p[[.osc, .i(0), .range]] = OptionsParam(byte: 14, options: oscRangeOptions)
    p[[.osc, .i(1), .range]] = OptionsParam(byte: 15, options: oscRangeOptions)
    p[[.osc, .i(0), .pw, .src]] = OptionsParam(byte: 16, options: oscModSrcOptions)
    p[[.osc, .i(1), .tone, .src]] = OptionsParam(byte: 17, options: oscModSrcOptions)
    p[[.osc, .i(0), .pulse, .on]] = RangeParam(byte: 18, maxVal: 1)
    p[[.osc, .i(0), .saw, .on]] = RangeParam(byte: 19, maxVal: 1)
    p[[.osc, .sync]] = RangeParam(byte: 20, maxVal: 1)
    p[[.osc, .i(0), .pitch, .mod, .depth]] = RangeParam(byte: 21, maxVal: 255)
    p[[.osc, .i(0), .pitch, .mod, .src]] = OptionsParam(byte: 22, options: oscPitchModOptions)
    p[[.osc, .i(0), .pitch, .aftertouch, .depth]] = RangeParam(byte: 23, maxVal: 255)
    p[[.osc, .i(0), .pitch, .modWheel, .depth]] = RangeParam(byte: 24, maxVal: 255)
    p[[.osc, .i(0), .pw, .depth]] = RangeParam(byte: 25, maxVal: 255)
    p[[.osc, .i(1), .level]] = RangeParam(byte: 26, maxVal: 255)
    p[[.osc, .i(1), .pitch]] = MisoParam.make(byte: 27, maxVal: 255, iso: pitch2Iso)
    p[[.osc, .i(1), .tone, .depth]] = RangeParam(byte: 28, maxVal: 255)
    p[[.osc, .i(1), .pitch, .mod, .depth]] = RangeParam(byte: 29, maxVal: 255)
    p[[.osc, .i(1), .pitch, .aftertouch, .depth]] = RangeParam(byte: 30, maxVal: 255)
    p[[.osc, .i(1), .pitch, .modWheel, .depth]] = RangeParam(byte: 31, maxVal: 255)
    p[[.osc, .i(1), .pitch, .mod, .src]] = OptionsParam(byte: 32, options: oscPitchModOptions)
    p[[.noise]] = RangeParam(byte: 33, maxVal: 255)
    p[[.porta, .time]] = RangeParam(byte: 34, maxVal: 255)
    p[[.porta, .mode]] = OptionsParam(byte: 35, options: portaModeOptions)
    p[[.bend, .up]] = RangeParam(byte: 36, range: -24...24)
    p[[.bend, .down]] = MisoParam.make(byte: 37, range: -24...24, iso: Miso.m(-1))
    p[[.osc, .i(0), .pitch, .mod, .mode]] = OptionsParam(byte: 38, options: ["Osc 1+2", "Osc 1"])
    p[[.filter, .cutoff]] = RangeParam(byte: 39, maxVal: 255)
    p[[.filter, .hi, .cutoff]] = RangeParam(byte: 40, maxVal: 255)
    p[[.filter, .reson]] = RangeParam(byte: 41, maxVal: 255)
    p[[.filter, .env, .depth]] = RangeParam(byte: 42, maxVal: 255)
    p[[.filter, .env, .velo]] = RangeParam(byte: 43, maxVal: 255)
    p[[.filter, .cutoff, .bend]] = RangeParam(byte: 44, maxVal: 255)
    p[[.filter, .lfo, .depth]] = RangeParam(byte: 45, maxVal: 255)
    p[[.filter, .lfo, .select]] = OptionsParam(byte: 46, options: ["LFO 1", "LFO 2"])
    p[[.filter, .aftertouch, .lfo]] = RangeParam(byte: 47, maxVal: 255)
    p[[.filter, .modWheel, .lfo]] = RangeParam(byte: 48, maxVal: 255)
    p[[.filter, .keyTrk]] = RangeParam(byte: 49, maxVal: 255)
    p[[.filter, .env, .polarity]] = OptionsParam(byte: 50, options: ["-", "+"])
    p[[.filter, .mode]] = OptionsParam(byte: 51, options: ["2-pole", "4-pole"])
    p[[.filter, .booster]] = RangeParam(byte: 52, maxVal: 1)
    p[[.amp, .env, .attack]] = RangeParam(byte: 53, maxVal: 255)
    p[[.amp, .env, .decay]] = RangeParam(byte: 54, maxVal: 255)
    p[[.amp, .env, .sustain]] = RangeParam(byte: 55, maxVal: 255)
    p[[.amp, .env, .release]] = RangeParam(byte: 56, maxVal: 255)
    p[[.amp, .env, .trigger]] = OptionsParam(byte: 57, options: envTriggerOptions)
    p[[.amp, .env, .attack, .curve]] = RangeParam(byte: 58, maxVal: 255)
    p[[.amp, .env, .decay, .curve]] = RangeParam(byte: 59, maxVal: 255)
    p[[.amp, .env, .sustain, .curve]] = RangeParam(byte: 60, maxVal: 255)
    p[[.amp, .env, .release, .curve]] = RangeParam(byte: 61, maxVal: 255)
    p[[.filter, .env, .attack]] = RangeParam(byte: 62, maxVal: 255)
    p[[.filter, .env, .decay]] = RangeParam(byte: 63, maxVal: 255)
    p[[.filter, .env, .sustain]] = RangeParam(byte: 64, maxVal: 255)
    p[[.filter, .env, .release]] = RangeParam(byte: 65, maxVal: 255)
    p[[.filter, .env, .trigger]] = OptionsParam(byte: 66, options: envTriggerOptions)
    p[[.filter, .env, .attack, .curve]] = RangeParam(byte: 67, maxVal: 255)
    p[[.filter, .env, .decay, .curve]] = RangeParam(byte: 68, maxVal: 255)
    p[[.filter, .env, .sustain, .curve]] = RangeParam(byte: 69, maxVal: 255)
    p[[.filter, .env, .release, .curve]] = RangeParam(byte: 70, maxVal: 255)
    p[[.mod, .env, .attack]] = RangeParam(byte: 71, maxVal: 255)
    p[[.mod, .env, .decay]] = RangeParam(byte: 72, maxVal: 255)
    p[[.mod, .env, .sustain]] = RangeParam(byte: 73, maxVal: 255)
    p[[.mod, .env, .release]] = RangeParam(byte: 74, maxVal: 255)
    p[[.mod, .env, .trigger]] = OptionsParam(byte: 75, options: envTriggerOptions)
    p[[.mod, .env, .attack, .curve]] = RangeParam(byte: 76, maxVal: 255)
    p[[.mod, .env, .decay, .curve]] = RangeParam(byte: 77, maxVal: 255)
    p[[.mod, .env, .sustain, .curve]] = RangeParam(byte: 78, maxVal: 255)
    p[[.mod, .env, .release, .curve]] = RangeParam(byte: 79, maxVal: 255)
    p[[.amp, .level]] = RangeParam(byte: 80, maxVal: 255)
    p[[.amp, .env, .depth]] = RangeParam(byte: 81, maxVal: 255)
    p[[.amp, .env, .velo]] = RangeParam(byte: 82, maxVal: 255)
    p[[.pan]] = RangeParam(byte: 83, maxVal: 255, displayOffset: -128)
    p[[.voice, .priority]] = OptionsParam(byte: 84, options: ["Lowest", "Highest", "Last"])
    p[[.poly]] = OptionsParam(byte: 85, options: ["Poly", "Unison 2", "Unison 3", "Unison 4", "Unison 6", "Unison 12", "Mono", "Mono 2", "Mono 3", "Mono 4", "Mono 6", "Poly 6", "Poly 8"])
    p[[.env, .trigger]] = OptionsParam(byte: 86, options: ["Mono", "Re-trig", "Legato", "1-shot"])
    p[[.unison, .detune]] = RangeParam(byte: 87, maxVal: 255)
    p[[.osc, .slop]] = RangeParam(byte: 88, maxVal: 255)
    p[[.param, .slop]] = RangeParam(byte: 89, maxVal: 255)
    p[[.slop, .rate]] = RangeParam(byte: 90, maxVal: 255)
    p[[.porta, .balance]] = RangeParam(byte: 91, maxVal: 255, displayOffset: -128)
    p[[.osc, .key, .reset]] = RangeParam(byte: 92, maxVal: 1)
    (0..<8).forEach { mod in
      let off = 93 + mod * 3
      p[[.mod, .i(mod), .src]] = OptionsParam(byte: off, options: modSrcOptions)
      p[[.mod, .i(mod), .dest]] = OptionsParam(byte: off + 1, options: modDestOptions)
      p[[.mod, .i(mod), .depth]] = RangeParam(byte: off + 2, maxVal: 255, displayOffset: -128)
    }
    p[[.seq, .on]] = RangeParam(byte: 117, maxVal: 1)
    p[[.seq, .clock]] = OptionsParam(byte: 118, options: seqClockOptions)
    p[[.seq, .length]] = RangeParam(byte: 119, maxVal: 30, displayOffset: 2)
    p[[.seq, .swing]] = RangeParam(byte: 120, maxVal: 25, displayOffset: 50)
    p[[.seq, .key, .sync, .loop]] = OptionsParam(byte: 121, options: ["Loop", "Key Sync", "Loop+KeySync"])
    p[[.seq, .slew, .rate]] = RangeParam(byte: 122, maxVal: 255)
    (0..<32).forEach { step in
      p[[.seq, .step, .i(step)]] = MisoParam.make(byte: 123 + step, maxVal: 255, iso: seqStepIso)
    }
    p[[.arp, .on]] = RangeParam(byte: 155, maxVal: 1)
    p[[.arp, .mode]] = OptionsParam(byte: 156, options: ["Up", "Down", "Up&Down", "Up Inv", "Down Inv", "Up&Down Inv", "Up Alt", "Down Alt", "Random", "Played", "Chord"])
    p[[.arp, .rate]] = RangeParam(byte: 157, maxVal: 255, displayOffset: 20)
    p[[.arp, .clock]] = OptionsParam(byte: 158, options: arpClockOptions)
    p[[.arp, .key, .sync]] = RangeParam(byte: 159, maxVal: 1)
    p[[.arp, .gate]] = RangeParam(byte: 160, maxVal: 255)
    p[[.arp, .hold]] = RangeParam(byte: 161, maxVal: 1)
    p[[.arp, .pattern]] = MisoParam.make(byte: 162, maxVal: 64, iso: arpPatternIso)
    p[[.arp, .swing]] = RangeParam(byte: 163, maxVal: 25, displayOffset: 50)
    p[[.arp, .octave]] = RangeParam(byte: 164, maxVal: 5, displayOffset: 1)
    p[[.fx, .routing]] = RangeParam(byte: 165)
    (0..<4).forEach { fx in
      let off = 166 + fx * 13
      p[[.fx, .i(fx), .type]] = OptionsParam(byte: off, options: fxTypeOptions)
      (0..<12).forEach { param in
        p[[.fx, .i(fx), .param, .i(param)]] = RangeParam(byte: off + 1 + param, maxVal: 255)
      }
      p[[.fx, .i(fx), .level]] = RangeParam(byte: 218 + fx, maxVal: 150)
    }
    p[[.fx, .mode]] = OptionsParam(byte: 222, options: ["Insert", "Send", "Bypass"])
    p[[.category]] = OptionsParam(byte: 240, options: categoryOptions)
    p[[.transpose]] = RangeParam(byte: 241, range: 80...176, displayOffset: -128)

    return p
  }()
  
  static let pitch2Iso = Miso.switcher([
    .range(0...118, Miso.lerp(in: 0...118, out: -12...(-0.2)) >>> Miso.round(1)),
    .range(119...127, Miso.lerp(in: 119...127, out: -0.093...0) >>> Miso.round(2)),
    .range(128...136, Miso.lerp(in: 128...136, out: 0...0.093) >>> Miso.round(2)),
    .range(137...255, Miso.lerp(in: 137...255, out: 0.2...12) >>> Miso.round(1))
  ]) >>> Miso.str()
//    Miso.lerp(inRange: 0...255, outRange: -12...12) >>> Miso.round(1) >>> Miso.str()
  
  static let lfoWaveOptions = OptionsParam.makeOptions(["Sine", "Tri", "Square", "Ramp Up", "Ramp Down", "S&H", "S&G"])
  
  static let lfoMonoIso = Miso.switcher([
    .int(0, "Poly"),
    .int(1, "Mono")
  ], default: Miso.a(-1) >>> Miso.str("Spread-%g"))
  
  static let oscRangeOptions = OptionsParam.makeOptions(["16'", "8'", "4'"])
  
  static let oscModSrcOptions = OptionsParam.makeOptions(["Manual", "LFO 1", "LFO 2", "VCA Env", "VCF Env", "Mod Env"])
  
  static let oscPitchModOptions = OptionsParam.makeOptions(["LFO 1", "LFO 2", "VCA Env", "VCF Env", "Mod Env", "LFO 1 Uni", "LFO 2 Uni"])
  
  static let portaModeOptions = OptionsParam.makeOptions(["Normal", "Fingered", "Fixed Rate", "Fixed Fingered", "Expon", "Expo Fingered", "Fixed +2", "Fixed -2", "Fixed +5", "Fixed -5", "Fixed +12", "Fixed -12", "Fixed +24", "Fixed -24"])
  
  static let envTriggerOptions = OptionsParam.makeOptions(["Key", "LFO 1", "LFO 2", "Loop", "Seq Step"])
  
  static let modSrcOptions = OptionsParam.makeOptions(["Off", "Pitch Bend", "Mod Wheel", "Foot Ctrl", "Breath Ctrl", "Pressure", "LFO1", "LFO2", "VCA Env", "VCF Env", "Mod Env", "Note Num", "Note Vel", "Ctrl Seq", "LFO1 (Uni)", "LFO2 (Uni)", "LFO1 (Fade)", "LFO2 (Fade)", "Note Off Vel", "Voice Num", "CC X (115)", "CC Y (116)", "CC Z (117)", "Uni Voice", "Expression"])
  
  static let modDestOptions = OptionsParam.makeOptions(["Off", "LFO1 Rate", "LFO1 Delay", "LFO1 Slew", "LFO1 Shape", "LFO2 Rate", "LFO2 Delay", "LFO2 Slew", "LFO2 Shape", "OSC1+2 Pit", "OSC1 Pitch", "OSC2 Pitch", "OSC1 PM Dep", "PWM Depth", "TMod Depth", "OSC2 PM Dep", "Porta Time", "VCF Freq", "VCF Res", "VCF Env", "VCF LFO", "Env Rates", "All Attack", "All Decay", "All Sus", "All Rel", "Env1 Rates", "Env2 Rates", "Env3 Rates", "Env1Curves", "Env2Curves", "Env3Curves", "Env1 Attack", "Env1 Decay", "Env1 Sus", "Env1 Rel", "Env1 AtCur", "Env1 DcyCur", "Env1 SuSCur", "Env1 RelCur", "Env2 Attack", "Env2 Decay", "Env2 Sus", "Env2 Rel", "Env2 AtCur", "Env2 DcyCur", "Env2 SuSCur", "Env2 RelCur", "Env3 Attack", "Env3 Decay", "Env3 Sus", "Env3 Rel", "Env3 AtCur", "Env3 DcyCur", "Env3 SuSCur", "Env3 RelCur", "VCA All**", "VCA Active**", "VCA EnvDep", "Pan Spread", "VCA Pan", "OSC2 Lvl", "Noise Lvl", "HP Freq", "Uni Detune", "OSC Drift", "Param Drift", "Drift Rate", "Arp Gate", "Seq Slew", "Mod 1 Dep", "Mod 2 Dep", "Mod 3 Dep", "Mod 4 Dep", "Mod 5 Dep", "Mod 6 Dep", "Mod 7 Dep", "Mod 8 Dep", "FX1 Param 1", "FX1 Param 2", "FX1 Param 3", "FX1 Param 4", "FX1 Param 5", "FX1 Param 6", "FX1 Param 7", "FX1 Param 8", "FX1 Param 9", "FX1 Param 10", "FX1 Param 11", "FX1 Param 12", "FX2 Param 1", "FX2 Param 2", "FX2 Param 3", "FX2 Param 4", "FX2 Param 5", "FX2 Param 6", "FX2 Param 7", "FX2 Param 8", "FX2 Param 9", "FX2 Param 10", "FX2 Param 11", "FX2 Param 12", "FX3 Param 1", "FX3 Param 2", "FX3 Param 3", "FX3 Param 4", "FX3 Param 5", "FX3 Param 6", "FX3 Param 7", "FX3 Param 8", "FX3 Param 9", "FX3 Param 10", "FX3 Param 11", "FX3 Param 12", "FX4 Param 1", "FX4 Param 2", "FX4 Param 3", "FX4 Param 4", "FX4 Param 5", "FX4 Param 6", "FX4 Param 7", "FX4 Param 8", "FX4 Param 9", "FX4 Param 10", "FX4 Param 11", "FX4 Param 12", "FX1 Level", "FX2 Level", "FX3 Level", "FX4 Level", "OSC1+2 Fine", "OSC1 Fine", "OSC2 Fine"])
  
  static let seqClocks = ["4", "3", "2", "1", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "3/64", "1/24", "1/32", "3/128", "1/48", "1/64"]
  static let seqClockOptions = OptionsParam.makeOptions(seqClocks)
  
  static let lfoClockSteps: [Float] = [0, 13, 26, 39, 52, 64, 77, 90, 103, 116, 128, 141, 154, 167, 180, 192, 205, 218, 231, 244]
  static let lfoClockIso: Iso<Float,String> = Miso.switcher((0..<20).map {
      let end = $0 < lfoClockSteps.count - 1 ? lfoClockSteps[$0 + 1] - 1 : 255
      return .rangeString((lfoClockSteps[$0])...end, seqClocks[$0])
    })
//    Miso.lerp(inRange: 0...255, outRange: 0...19) >>> Miso.options(seqClocks)
  
  // 0, 13, 64, 77
  
  static let seqStepIso = Miso.switcher([
    .int(0, "Skip")
  ], default: Miso.a(-128) >>> Miso.str())
  
  static let arpClockOptions = OptionsParam.makeOptions(["1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32", "1/48"])

  static let arpPatternIso = Miso.switcher([
    .int(0, "None"),
    .range(1...32, Miso.str("Preset-%g")),
    .range(33...64, Miso.a(-32) >>> Miso.str("User-%g"))
  ])
  
  static let fxTypeOptions = OptionsParam.makeOptions(["None", "HallRev", "PlateRev", "RichPltRev", "AmbVerb", "GatedRev", "Reverse", "RackAmp", "MoodFilter", "Phaser", "Chorus", "Flanger", "ModDlyRev", "Delay", "3TapDelay", "4TapDelay", "RotarySpkr", "Chorus-D", "Enhancer", "EdisonEX1", "Auto Pan", "T-RayDelay", "TC-DeepVRB", "FlangVerb", "ChorusVerb", "DelayVerb", "ChamberRev", "RoomRev", "VintageRev", "DualPitch", "MidasEQ", "FairComp", "MulBndDist", "NoiseGate", "DecimDelay", "Vintage Pitch"])
  
  static let categoryOptions = OptionsParam.makeOptions(["NONE", "BASS", "PAD", "LEAD", "MONO", "POLY", "STAB", "SFX", "ARP", "SEQ", "PERC", "AMBIENT", "MODULAR", "USER-1", "USER-2", "USER-3", "USER-4"])
  
}
