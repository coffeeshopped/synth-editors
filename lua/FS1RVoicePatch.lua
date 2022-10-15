-- import PBCore

FS1RVoicePatch = {
  -- typealias Bank = FS1RVoiceBank
  
  fileData = function (bytes) -- [UInt8]
    return sysexData(bytes, deviceId: 0, part: 0).bytes()
  end,
  
  dataByteCount = 608,
  initFileName = "fs1r-init",
  nameByteRange = 0..<10,

  
  -- sysex bytes for patch as temp voice
  sysexData = function (_ bytes: [UInt8], deviceId: UInt8, part: Int) -> MidiMessage {
    sysexData(bytes, deviceId: deviceId, address: [0x40 + UInt8(part), 0x00, 0x00])
  }

   -- sysex bytes for patch as stored in memory location
  sysexData = (_ bytes: [UInt8], deviceId: UInt8, location: Int) -> MidiMessage {
    sysexData(bytes, deviceId: deviceId, address: [0x51, 0x00, UInt8(location)])
  }

  static func algorithms() -> [DXAlgorithm] { FS1RAlgorithms.all }
  
  
  voicedFreq = function(_ patch: SysexPatch, forOp op: Int) -> Float {
    guard let oscMode = patch[[.op, .i(op), .voiced, .osc, .mode]],
      let specForm = patch[[.op, .i(op), .voiced, .spectral, .form]],
      let coarse = patch[[.op, .i(op), .voiced, .coarse]],
      let fine = patch[[.op, .i(op), .voiced, .fine]] else { return 0 }
    return voicedFreq(oscMode: oscMode, spectralForm: specForm, coarse: coarse, fine: fine)
  }
  
  unvoicedFreq = function(patch, op)
    local coarse = patch.get("op/i(" .. op .. ")/unvoiced/coarse")
    local fine = patch.get("op/i(" .. op .. ")/unvoiced/fine")
    if !coarse && !fine then
      return 0
    else
      return fixedFreq(coarse, fine)
    end
  end
  
  static func voicedFreq(oscMode: Int, spectralForm: Int, coarse: Int, fine: Int) -> Float {
    if oscMode == 0 && spectralForm < 7 {
      // ratio
      let c = (coarse == 0 ? 0.5 : Float(coarse))
      let f = (Float(fine) * c) / 100
      return c + f
    }
    else {
      // fixed
      return FS1RVoicePatch.fixedFreq(coarse: coarse, fine: fine)
    }
  }
  
  static func fixedFreq(coarse: Int, fine: Int) -> Float {
    guard coarse > 0 else { return 0 }
    let c = min(coarse, 21)
    return 14088 / powf(2, 21-(Float(c)+(Float(fine)/128)))
  }
  
  params = {
    "category" = OptionsParam{byte=0x0e, options=categoryOptions},
    "lfo/i(0)/wave" = OptionsParam{byte=0x10, options=lfoWaveOptions}
    p[[.lfo, .i(0), .rate]] = RangeParam(byte: 0x11, maxVal: 99)
    p[[.lfo, .i(0), .delay]] = RangeParam(byte: 0x12, maxVal: 99)
    p[[.lfo, .i(0), .key, .sync]] = RangeParam(byte: 0x13, maxVal: 1)
    p[[.lfo, .i(0), .pitch]] = RangeParam(byte: 0x15, maxVal: 99)
    p[[.lfo, .i(0), .amp]] = RangeParam(byte: 0x16, maxVal: 99)
    p[[.lfo, .i(0), .freq]] = RangeParam(byte: 0x17, maxVal: 99)
    p[[.lfo, .i(1), .wave]] = OptionsParam(byte: 0x18, options: lfoWaveOptions)
    p[[.lfo, .i(1), .rate]] = RangeParam(byte: 0x19)
    p[[.lfo, .i(1), .phase]] = OptionsParam(byte: 0x1c, options: OptionsParam.makeOptions(["0","90","180","270"]))
    p[[.lfo, .i(1), .key, .sync]] = RangeParam(byte: 0x1d, maxVal: 1)
    p[[.note, .shift]] = RangeParam(byte: 0x1e, maxVal: 48, displayOffset: -24)
    let pEnv: SynthPath = [.pitch, .env]
    p[pEnv + [.level, .i(-1)]] = RangeParam(byte: 0x1f, maxVal: 100, displayOffset: -50)
    p[pEnv + [.level, .i(0)]] = RangeParam(byte: 0x20, maxVal: 100, displayOffset: -50)
    p[pEnv + [.level, .i(1)]] = RangeParam(byte: 0x21, maxVal: 100, displayOffset: -50)
    p[pEnv + [.level, .i(3)]] = RangeParam(byte: 0x22, maxVal: 100, displayOffset: -50)
    p[pEnv + [.time, .i(0)]] = RangeParam(byte: 0x23, maxVal: 99)
    p[pEnv + [.time, .i(1)]] = RangeParam(byte: 0x24, maxVal: 99)
    p[pEnv + [.time, .i(2)]] = RangeParam(byte: 0x25, maxVal: 99)
    p[pEnv + [.time, .i(3)]] = RangeParam(byte: 0x26, maxVal: 99)
    p[pEnv + [.velo]] = RangeParam(byte: 0x27, maxVal: 7)
    p[[.op, .i(7), .voiced, .fseq]] = RangeParam(byte: 0x28, bit: 0)
    p[[.op, .i(7), .unvoiced, .fseq]] = RangeParam(byte: 0x2a, bit: 0)
    for i in 0...6 {
      p[[.op, .i(i), .voiced, .fseq]] = RangeParam(byte: 0x29, bit: i)
      p[[.op, .i(i), .unvoiced, .fseq]] = RangeParam(byte: 0x2b, bit: i)
    }
    p[[.algo]] = RangeParam(byte: 0x2c, maxVal: 87, displayOffset: 1)
    let levelAdjustOptions = OptionsParam.makeOptions((0...15).map { "-\(Float($0)*1.5) dB" })
    for i in 0..<8 {
      p[[.adjust, .op, .i(i), .level]] = OptionsParam(byte: 0x2d + i, options: levelAdjustOptions)
    }
    p[pEnv + [.range]] = OptionsParam(byte: 0x3b, options: ["8oct","2oct","1oct","1/2oct"])
    p[pEnv + [.time, .scale]] = RangeParam(byte: 0x3c, maxVal: 7)
    p[[.feedback]] = RangeParam(byte: 0x3d, maxVal: 7)
    p[pEnv + [.level,.i(2)]] = RangeParam(byte: 0x3e, maxVal: 100, displayOffset: -50)
    for i in 0..<5 {
      p[[.formant, .ctrl, .i(i), .dest]] = OptionsParam(byte: 0x40+i, bits: 4...5, options: knobDestOptions)
      p[[.formant, .ctrl, .i(i), .unvoiced]] = OptionsParam(byte: 0x40+i, bit: 3, options: ["Voiced","Unvoiced"])
      p[[.formant, .ctrl, .i(i), .op]] = RangeParam(byte: 0x40+i, bits: 0...2, maxVal: 7, displayOffset: 1)
      p[[.formant, .ctrl, .i(i), .depth]] = RangeParam(byte: 0x45+i, displayOffset: -64)
      
      p[[.fm, .ctrl, .i(i), .dest]] = OptionsParam(byte: 0x4a+i, bits: 4...5, options: knobDestOptions)
      p[[.fm, .ctrl, .i(i), .unvoiced]] = OptionsParam(byte: 0x4a+i, bit: 3, options: ["Voiced","Unvoiced"])
      p[[.fm, .ctrl, .i(i), .op]] = RangeParam(byte: 0x4a+i, bits: 0...2, maxVal: 7, displayOffset: 1)
      p[[.fm, .ctrl, .i(i), .depth]] = RangeParam(byte: 0x4f+i, displayOffset: -64)
    }
    p[[.filter, .type]] = OptionsParam(byte: 0x54, options: ["LFP24","LPF18","LPF12","HPF","BPF","BEF"])
    p[[.reson]] = RangeParam(byte: 0x55)
    p[[.reson, .velo]] = RangeParam(byte: 0x56, maxVal: 14, displayOffset: -7)
    p[[.cutoff]] = RangeParam(byte: 0x57)
    let fEnv: SynthPath = [.filter, .env]
    p[fEnv + [.depth, .velo]] = RangeParam(byte: 0x58, maxVal: 14, displayOffset: -7)
    p[[.cutoff, .lfo, .i(0)]] = RangeParam(byte: 0x59, maxVal: 99)
    p[[.cutoff, .lfo, .i(1)]] = RangeParam(byte: 0x5a, maxVal: 99)
    p[[.cutoff, .key, .scale, .depth]] = RangeParam(byte: 0x5b, displayOffset: -64)
    p[[.cutoff, .key, .scale, .pt]] = RangeParam(byte: 0x5c)
    p[[.filter, .gain]] = RangeParam(byte: 0x5d, maxVal: 24, displayOffset: -12)
    p[fEnv + [.depth]] = RangeParam(byte: 0x64, displayOffset: -64)
    (0..<4).forEach {
      p[fEnv + [.level, .i($0)]] = RangeParam(byte: 0x66+$0, maxVal: 100, displayOffset: -50)
      p[fEnv + [.time, .i($0)]] = RangeParam(byte: 0x69+$0, maxVal: 99)
    }
    p[fEnv + [.attack, .velo]] = RangeParam(byte: 0x6e, bits: 0...2, maxVal: 7)
    p[fEnv + [.time, .scale]] = RangeParam(byte: 0x6e, bits: 3...5, maxVal: 7)
    
    for i in 0..<8 {
      let opV: SynthPath = [.op, .i(i), .voiced]
      p[opV + [.key, .sync]] = rangeParam(op: i, parm: 0x00, bit: 6)
      p[opV + [.transpose]] = rangeParam(op: i, parm: 0x00, bits: 0...5, maxVal: 48, displayOffset: -24)
      p[opV + [.coarse]] = rangeParam(op: i, parm: 0x01, maxVal: 31)
      p[opV + [.fine]] = rangeParam(op: i, parm: 0x02, maxVal: 99)
      p[opV + [.note, .scale]] = rangeParam(op: i, parm: 0x03, maxVal: 99)
      p[opV + [.bw, .bias, .sens]] = rangeParam(op: i, parm: 0x04, bits: 3...6, maxVal: 14, displayOffset: -7)
      p[opV + [.spectral, .form]] = optionsParam(op: i, parm: 0x04, bits: 0...2, options: ["Sine", "All 1", "All 2", "Odd 1", "Odd 2", "Res 1", "Res 2", "Formant"])
      p[opV + [.osc, .mode]] = optionsParam(op: i, parm: 0x05, bit: 6, options: ["Ratio","Fixed"])
      p[opV + [.spectral, .skirt]] = rangeParam(op: i, parm: 0x05, bits: 3...5, maxVal: 7)
      p[opV + [.fseq, .trk]] = rangeParam(op: i, parm: 0x05, bits: 0...2, maxVal: 7, displayOffset: 1)
      p[opV + [.freq, .ratio, .spectral]] = rangeParam(op: i, parm: 0x06, maxVal: 99)
      p[opV + [.detune]] = rangeParam(op: i, parm: 0x07, maxVal: 30, displayOffset: -15)
      let freqEnv: SynthPath = [.freq, .env]
      p[opV + freqEnv + [.innit]] = rangeParam(op: i, parm: 0x08, maxVal: 100, displayOffset: -50)
      p[opV + freqEnv + [.attack, .level]] = rangeParam(op: i, parm: 0x09, maxVal: 100, displayOffset: -50)
      p[opV + freqEnv + [.attack]] = rangeParam(op: i, parm: 0x0a, maxVal: 99)
      p[opV + freqEnv + [.decay]] = rangeParam(op: i, parm: 0x0b, maxVal: 99)
      let aEnv: SynthPath = [.amp, .env]
      (0..<4).forEach {
        p[opV + aEnv + [.level, .i($0)]] = rangeParam(op: i, parm: 0x0c+$0, maxVal: 99)
        p[opV + aEnv + [.time, .i($0)]] = rangeParam(op: i, parm: 0x10+$0, maxVal: 99)
      }
      p[opV + aEnv + [.hold]] = rangeParam(op: i, parm: 0x14, maxVal: 99)
      p[opV + aEnv + [.time, .scale]] = rangeParam(op: i, parm: 0x15, maxVal: 7)
      p[opV + aEnv + [.level]] = rangeParam(op: i, parm: 0x16, maxVal: 99)
      p[opV + [.level, .scale, .brk, .pt]] = rangeParam(op: i, parm: 0x17, maxVal: 99)
      p[opV + [.level, .scale, .left, .depth]] = rangeParam(op: i, parm: 0x18, maxVal: 99)
      p[opV + [.level, .scale, .right, .depth]] = rangeParam(op: i, parm: 0x19, maxVal: 99)
      let lsCurves = OptionsParam.makeOptions(["-lin","-exp","+exp","+lin"])
      p[opV + [.level, .scale, .left, .curve]] = optionsParam(op: i, parm: 0x1a, options: lsCurves)
      p[opV + [.level, .scale, .right, .curve]] = optionsParam(op: i, parm: 0x1b, options: lsCurves)
      p[opV + [.freq, .bias, .sens]] = rangeParam(op: i, parm: 0x1f, bits: 3...6, maxVal: 14, displayOffset: -7)
      p[opV + [.pitch, .mod, .sens]] = rangeParam(op: i, parm: 0x1f, bits: 0...2, maxVal: 7)
      p[opV + [.freq, .mod, .sens]] = rangeParam(op: i, parm: 0x20, bits: 4...6, maxVal: 7)
      p[opV + [.freq, .velo]] = rangeParam(op: i, parm: 0x20, bits: 0...3, maxVal: 14, displayOffset: -7)
      p[opV + [.amp, .env, .mod, .sens]] = rangeParam(op: i, parm: 0x21, bits: 4...6, maxVal: 7)
      p[opV + [.amp, .env, .velo]] = rangeParam(op: i, parm: 0x21, bits: 0...3, maxVal: 14, displayOffset: -7 )
      p[opV + [.amp, .env, .bias, .sens]] = rangeParam(op: i, parm: 0x22, maxVal: 14, displayOffset: -7)
      
      let opN: SynthPath = [.op, .i(i), .unvoiced]
      p[opN + [.transpose]] = rangeParam(op: i, parm: 0x23, maxVal: 48, displayOffset: -24)
      p[opN + [.mode]] = optionsParam(op: i, parm: 0x24, bits: 5...6, options: ["Normal","Link FO", "Link FF"])
      p[opN + [.coarse]] = rangeParam(op: i, parm: 0x24, bits: 0...4, maxVal: 31)
      p[opN + [.fine]] = rangeParam(op: i, parm: 0x25, maxVal: 99)
      p[opN + [.note, .scale]] = rangeParam(op: i, parm: 0x26, maxVal: 99)
      p[opN + [.bw]] = rangeParam(op: i, parm: 0x27, maxVal: 99)
      p[opN + [.bw, .bias, .sens]] = rangeParam(op: i, parm: 0x28, maxVal: 14, displayOffset: -7)
      p[opN + [.reson]] = rangeParam(op: i, parm: 0x29, bits: 3...5, maxVal: 7)
      p[opN + [.skirt]] = rangeParam(op: i, parm: 0x29, bits: 0...2, maxVal: 7)
      p[opN + freqEnv + [.innit]] = rangeParam(op: i, parm: 0x2a, maxVal: 100, displayOffset: -50)
      p[opN + freqEnv + [.attack, .level]] = rangeParam(op: i, parm: 0x2b, maxVal: 100, displayOffset: -50)
      p[opN + freqEnv + [.attack]] = rangeParam(op: i, parm: 0x2c, maxVal: 99)
      p[opN + freqEnv + [.decay]] = rangeParam(op: i, parm: 0x2d, maxVal: 99)
      p[opN + [.amp, .env, .level]] = rangeParam(op: i, parm: 0x2e, maxVal: 99)
      p[opN + [.level, .key, .scale]] = rangeParam(op: i, parm: 0x2f, maxVal: 14, displayOffset: -7)
      (0..<4).forEach {
        p[opN + aEnv + [.level, .i($0)]] = rangeParam(op: i, parm: 0x30+$0, maxVal: 99)
        p[opN + aEnv + [.time, .i($0)]] = rangeParam(op: i, parm: 0x34+$0, maxVal: 99)
      }
      p[opN + aEnv + [.hold]] = rangeParam(op: i, parm: 0x38, maxVal: 99)
      p[opN + aEnv + [.time, .scale]] = rangeParam(op: i, parm: 0x39, maxVal: 7)
      p[opN + [.freq, .bias, .sens]] = rangeParam(op: i, parm: 0x3a, maxVal: 14, displayOffset: -7)
      p[opN + [.freq, .mod, .sens]] = rangeParam(op: i, parm: 0x3b, bits: 4...6, maxVal: 7)
      p[opN + [.freq, .velo]] = rangeParam(op: i, parm: 0x3b, bits: 0...3, maxVal: 14, displayOffset: -7)
      p[opN + [.amp, .env, .mod, .sens]] = rangeParam(op: i, parm: 0x3c, bits: 4...6, maxVal: 7)
      p[opN + [.amp, .env, .velo]] = rangeParam(op: i, parm: 0x3c, bits: 0...3, maxVal: 14, displayOffset: -7)
      p[opN + [.amp, .env, .bias, .sens]] = rangeParam(op: i, parm: 0x3d, maxVal: 14, displayOffset: -7)
    }
    
    return p
  }()
  
  private static func rangeParam(op: Int, parm p: Int = 0, bits bts: ClosedRange<Int>? = nil, range r: ClosedRange<Int> = 0...127, displayOffset off: Int = 0) -> RangeParam {
    let boff = 0x70 + op * 62
    return RangeParam(parm: p, byte: p + boff, bits: bts, range: r, displayOffset: off)
  }

  private static func rangeParam(op: Int, parm p: Int = 0, bits bts: ClosedRange<Int>? = nil, maxVal: Int, displayOffset off: Int = 0) -> RangeParam {
    let boff = 0x70 + op * 62
    return RangeParam(parm: p, byte: p + boff, bits: bts, maxVal: maxVal, displayOffset: off)
  }
  
  private static func rangeParam(op: Int, parm p: Int = 0, bit bt: Int) -> RangeParam {
    let boff = 0x70 + op * 62
    return RangeParam(parm: p, byte: p + boff, bit: bt)
  }

  private static func optionsParam(op: Int, parm p: Int = 0, bits bts: ClosedRange<Int>? = nil, options opts: [Int:String]) -> OptionsParam {
    let boff = 0x70 + op * 62
    return OptionsParam(parm: p, byte: p + boff, bits: bts, options: opts)
  }

  private static func optionsParam(op: Int, parm p: Int = 0, bit bt: Int, options opts: [Int:String]) -> OptionsParam {
    let boff = 0x70 + op * 62
    return OptionsParam(parm: p, byte: p + boff, bit: bt, options: opts)
  }

  static let categoryOptions = OptionsParam.makeOptions([
    "None",
    "Pf - Piano",
    "Cp - Chromatic Percussion",
    "Or - Organ",
    "Gt - Guitar",
    "Ba - Bass",
    "St - Strings/Orchestral",
    "En - Ensemble",
    "Br - Brass",
    "Rd - Reed",
    "Pi - Pipe",
    "Ld - Synth Lead",
    "Pd - Synth Pad",
    "Fx - Synth Sound Effects",
    "Et - Ethnic",
    "Pc - Percussive",
    "Se - Sound Effects",
    "Dr - Drums",
    "Sc - Synth Comping",
    "Vo - Vocal",
    "Co - Combination",
    "Wv - Material Wave",
    "Sq - Sequence",
    ])
  static let lfoWaveOptions = OptionsParam.makeOptions(["Triangle", "Saw Down", "Saw Up", "Square", "Sine", "S&H"])

  static let knobDestOptions = OptionsParam.makeOptions(["Off","Out","Freq","Width"])

}

