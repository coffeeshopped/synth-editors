
class ESQPatch : ByteBackedSysexPatch, CompactBankablePatch {
  
  class var bankType: SysexPatchBank.Type { ESQBank.self }
  
  static let nameByteRange = 0..<6
  static let fileDataCount = 210
  static let initFileName = "ESQ-init"

  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = Self.parseBytes(Data(data[5..<209]))
  }
  
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x0f, 0x02, UInt8(channel), 0x01])
    data.append(bankSysexData())
    data.append(0xf7)
    return data
  }
  
  required init(bankData data: Data) {
    bytes = Self.parseBytes(data)
  }
  
  private static func parseBytes(_ data: Data) -> [UInt8] {
    102.map {
      let off = $0 * 2
      let lo4 = data[off].bits(0...3)
      let hi4 = data[off + 1].bits(0...3) << 4
      return UInt8(lo4 + hi4)
    }
  }
  
  func bankSysexData() -> Data {
    Data(bytes.map {
      [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))]
      }.joined())
  }
  
  func fileData() -> Data { sysexData(channel: 0) }
  
  func nameSetFilter(_ n: String) -> String { n.uppercased() }

  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      let byte = param.byte
      if path.first == .lfo && path.last == .src {
        let v = 0.set(bits: 2...3, value: bytes[byte].bits(6...7))
        return v.set(bits: 0...1, value: bytes[byte+1].bits(6...7))
      }
      else if path.first == .osc && path.last == .octave {
        return Int(bytes[byte] / 12) - 3
      }
      else if path.first == .osc && path.last == .semitone {
        return Int(bytes[byte] % 12)
      }
      else if path == [.split, .direction] {
        return bytes[98].bit(7) == 0 ? 0 : bytes[96].bit(7) + 1
      }
      else {
        let v = defaultUnpack(param: param)
        if let param = param as? RangeParam,
          let v = v {
          return param.range.lowerBound < 0 && v > 63 ? v - 128 : v
        }
        else {
          return v
        }
      }
    }
    set {
      guard let param = type(of: self).params[path],
        let v = newValue else { return }
      let byte = param.byte
      if path.first == .lfo && path.last == .src {
        bytes[byte] = bytes[byte].set(bits: 6...7, value: v.bits(2...3))
        bytes[byte+1] = bytes[byte+1].set(bits: 6...7, value: v.bits(0...1))
      }
      else if path.first == .osc && path.last == .octave {
        guard let osc = path.i(1) else { return }
        let semi = self[[.osc, .i(osc), .semitone]] ?? 0
        bytes[byte] = UInt8((12 * (v+3)) + semi)
      }
      else if path.first == .osc && path.last == .semitone {
        guard let osc = path.i(1) else { return }
        let octave = self[[.osc, .i(osc), .octave]] ?? 0
        bytes[byte] = UInt8((12 * (octave+3)) + v)
      }
      else if path == [.split, .direction] {
        bytes[96] = bytes[96].set(bit: 7, value: (v > 0 ? v-1 : 0))
        bytes[98] = bytes[98].set(bit: 7, value: (v > 0 ? 1 : 0))
      }
      else {
        defaultPack(value: v < 0 ? v + 128 : v, forParam: param)
      }
    }
  }

  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    // envelopes
    for i in 0..<4 {
      let off = i * 10
      let boff = 6 + i * 10
      let pre: SynthPath = [.env, .i(i)]

      p[pre + [.level, .i(0)]] = RangeParam(parm: off+0, byte: boff+0, bits: 1...7, range: -63...63)
      p[pre + [.level, .i(1)]] = RangeParam(parm: off+1, byte: boff+1, bits: 1...7, range: -63...63)
      p[pre + [.level, .i(2)]] = RangeParam(parm: off+2, byte: boff+2, bits: 1...7, range: -63...63)
      
      p[pre + [.level, .velo]] = RangeParam(parm: off+3, byte: boff+7, bits: 2...7, maxVal: 63)
      p[pre + [.rate, .i(0), .velo]] = RangeParam(parm: off+4, byte: boff+8, maxVal: 63)
      
      p[pre + [.rate, .i(0)]] = RangeParam(parm: off+5, byte: boff+3, maxVal: 63)
      p[pre + [.rate, .i(1)]] = RangeParam(parm: off+6, byte: boff+4, maxVal: 63)
      p[pre + [.rate, .i(2)]] = RangeParam(parm: off+7, byte: boff+5, maxVal: 63)
      p[pre + [.rate, .i(3)]] = RangeParam(parm: off+8, byte: boff+6, bits: 0...5, maxVal: 63)

      p[pre + [.rate, .key]] = RangeParam(parm: off+9, byte: boff+9, maxVal: 63)
    }
    
    // lfos
    for i in 0..<3 {
      let off = i * 8
      let boff = 6 + 40 + (i * 4)
      let pre: SynthPath = [.lfo, .i(i)]
      
      p[pre + [.freq]] = RangeParam(parm: off+40, byte: boff, bits: 0...5, maxVal: 63)
      p[pre + [.reset]] = RangeParam(parm: off+41, byte: boff+3, bit: 7)
      p[pre + [.analogFeel]] = RangeParam(parm: off+42, byte: boff+3, bit: 6)
      
      p[pre + [.wave]] = OptionsParam(parm: off+43, byte: boff, bits: 6...7, options: lfoWaveOptions)
      p[pre + [.level, .i(0)]] = RangeParam(parm: off+44, byte: boff+1, bits: 0...5, maxVal: 63)
      
      p[pre + [.delay]] = RangeParam(parm: off+45, byte: boff+3, bits: 0...5, maxVal: 63)
      p[pre + [.level, .i(1)]] = RangeParam(parm: off+46, byte: boff+2, bits: 0...5, maxVal: 63)
      
      p[pre + [.mod, .src]] = OptionsParam(parm: off+47, byte: boff+1, options: modSourceOptions)
    }
    
    // osc
    for i in 0..<3 {
      let off = i * 8
      let boff = 6 + 52 + (i * 10)
      let pre: SynthPath = [.osc, .i(i)]
      
      p[pre + [.octave]] = RangeParam(parm: off+64, byte: boff, range: -3...5)
      p[pre + [.semitone]] = RangeParam(parm: off+65, byte: boff, maxVal: 11)
      p[pre + [.fine]] = RangeParam(parm: off+66, byte: boff+1, bits: 3...7, maxVal: 31)
      
      p[pre + [.wave]] = OptionsParam(parm: off+67, byte: boff+5, options: waveOptions)
      
      p[pre + [.mod, .i(0), .src]] = OptionsParam(parm: off+68, byte: boff+2, bits: 0...3, options: modSourceOptions)
      p[pre + [.mod, .i(0), .amt]] = RangeParam(parm: off+69, byte: boff+3, bits: 1...7, range: -63...63)
      p[pre + [.mod, .i(1), .src]] = OptionsParam(parm: off+70, byte: boff+2, bits: 4...7, options: modSourceOptions)
      p[pre + [.mod, .i(1), .amt]] = RangeParam(parm: off+71, byte: boff+4, bits: 1...7, range: -63...63)
    }
    
    // dca
    for i in 0..<3 {
      let off = i * 6
      let boff = 6 + 52 + (i * 10)
      let pre: SynthPath = [.amp, .i(i)]
      
      p[pre + [.level]] = RangeParam(parm: off+88, byte: boff+6, bits: 1...6, maxVal: 63)
      p[pre + [.on]] = RangeParam(parm: off+89, byte: boff+6, bit: 7)
      
      p[pre + [.mod, .i(0), .src]] = OptionsParam(parm: off+90, byte: boff + 7, bits: 0...3, options: modSourceOptions)
      p[pre + [.mod, .i(0), .amt]] = RangeParam(parm: off+91, byte: boff + 8, bits: 1...7, range: -63...63)
      p[pre + [.mod, .i(1), .src]] = OptionsParam(parm: off+92, byte: boff + 7, bits: 4...7, options: modSourceOptions)
      p[pre + [.mod, .i(1), .amt]] = RangeParam(parm: off+93, byte: boff + 9, bits: 1...7, range: -63...63)
    }
    
    p[[.amp, .i(3), .mod, .amt]] = RangeParam(parm: 106, byte: 88, bits: 1...6, maxVal: 63) // chart shows 7 bits, wrong?
    p[[.pan]] = RangeParam(parm: 107, byte: 100, bits: 4...7, maxVal: 15)
    p[[.pan, .mod, .src]] = OptionsParam(parm: 108, byte: 100, bits: 0...3, options: modSourceOptions)
    p[[.pan, .mod, .amt]] = RangeParam(parm: 109, byte: 101, bits: 0...6, range: -63...63)
    p[[.cutoff]] = RangeParam(parm: 110, byte: 89, bits: 0...6, maxVal: 127)
    p[[.reson]] = RangeParam(parm: 111, byte: 90, maxVal: 31)
    p[[.filter, .mod, .i(2), .amt]] = RangeParam(parm: 112, byte: 94, bits: 1...6, maxVal: 63)
    p[[.filter, .mod, .i(0), .src]] = OptionsParam(parm: 113, byte: 91, bits: 0...3, options: modSourceOptions)
    p[[.filter, .mod, .i(0), .amt]] = RangeParam(parm: 114, byte: 92, bits: 0...6, range: -63...63)
    p[[.filter, .mod, .i(1), .src]] = OptionsParam(parm: 115, byte: 91, bits: 4...7, options: modSourceOptions)
    p[[.filter, .mod, .i(1), .amt]] = RangeParam(parm: 116, byte: 93, bits: 0...6, range: -63...63)
    p[[.am]] = RangeParam(parm: 117, byte: 88, bit: 7)
    p[[.glide]] = RangeParam(parm: 118, byte: 95, bits: 0...5, maxVal: 63)
    p[[.mono]] = RangeParam(parm: 119, byte: 93, bit: 7)
    p[[.sync]] = RangeParam(parm: 120, byte: 89, bit: 7)
    p[[.rotate]] = RangeParam(parm: 121, byte: 92, bit: 7)
    p[[.env, .reset]] = RangeParam(parm: 122, byte: 94, bit: 7)
    p[[.wave, .reset]] = RangeParam(parm: 123, byte: 95, bit: 7)
    p[[.cycle]] = RangeParam(parm: 124, byte: 101, bit: 7)
    p[[.split, .layer]] = RangeParam(parm: 125, byte: 99, bit: 7)
    p[[.split, .layer, .pgm]] = OptionsParam(parm: 126, byte: 99, bits: 0...6, options: programOptions)
    p[[.layer]] = RangeParam(parm: 127, byte: 97, bit: 7)
    p[[.layer, .pgm]] = OptionsParam(parm: 128, byte: 97, bits: 0...6, options: programOptions)
    p[[.split, .direction]] = OptionsParam(parm: 129, byte: 96, bit: 7, options: splitDirOptions)
//    p[[.split]] = RangeParam(parm: 0, byte: 98, bit: 7)
    p[[.split, .pgm]] = OptionsParam(parm: 130, byte: 98, bits: 0...6, options: programOptions)
    p[[.split, .pt]] = RangeParam(parm: 131, byte: 96, bits: 0...6, range: 21...108)
    
    return p
  }()

  class var params: SynthPathParam { _params }
  
  static let lfoWaveOptions = OptionsParam.makeOptions(["Triangle","Saw","Square","Noise"])
  
  static let modSourceOptions = OptionsParam.makeOptions(["LFO 1", "LFO 2", "LFO 3", "Env 1", "Env 2", "Env 3", "Env 4", "Vel", "Vel 2", "Kybd", "Kybd 2", "Wheel", "Pedal", "Xctrl", "Pressure", "Off"])
  
  static let waveOptions = OptionsParam.makeOptions(["Saw", "Bell", "Sine", "Square", "Pulse", "Noise 1", "Noise 2", "Noise 3", "Bass", "Piano", "Electric Piano", "Voice 1", "Voice 2", "Kick", "Reed", "Organ", "Synth 1", "Synth 2", "Synth 3", "Formant 1", "Formant 2", "Formant 3", "Formant 4", "Formant 5", "Pulse 2", "Square 2", "Four Octaves", "Prime", "Bass 2", "Electric Piano 2", "Octave", "Octave +5"])
  
  static let splitDirOptions = OptionsParam.makeOptions(["Off","Lower","Upper"])
  
  static let programOptions = OptionsParam.makeOptions(40.map { "\($0 + 1)" })
}


class SQ80Patch : ESQPatch {

  override class var bankType: SysexPatchBank.Type { SQ80Bank.self }

  private static let _params: SynthPathParam = {
    var p = ESQPatch.params
    for i in 0..<3 {
      let param = p[[.osc, .i(i), .wave]]!
      p[[.osc, .i(i), .wave]] = OptionsParam(parm: param.parm, byte: param.byte, options: extendedWaveOptions)
    }
    
    for i in 0..<4 {
      let off = i * 10
      let boff = 6 + i * 10
      let pre: SynthPath = [.env, .i(i)]

      p[pre + [.velo, .extra]] = OptionsParam(parm: off+3, byte: boff+7, bit: 0, options: ["Lin", "Exp"])
      p[pre + [.release, .extra]] = RangeParam(parm: off+8, byte: boff+6, bit: 7)
    }
    
    return p
  }()
  override class var params: SynthPathParam { _params }
    
  static let extendedWaveOptions = OptionsParam.makeOptions(["Saw", "Bell", "Sine", "Square", "Pulse", "Noise 1", "Noise 2", "Noise 3", "Bass", "Piano", "Electric Piano", "Voice 1", "Voice 2", "Kick", "Reed", "Organ", "Synth 1", "Synth 2", "Synth 3", "Formant 1", "Formant 2", "Formant 3", "Formant 4", "Formant 5", "Pulse 2", "Square 2", "Four Octaves", "Prime", "Bass 2", "Electric Piano 2", "Octave", "Octave +5", "Saw 2", "Triangle", "Reed 2", "Reed 3", "Grit 1", "Grit 2", "Grit 3", "Glint 1", "Glint 2", "Glint 3", "Clav", "Brass", "String", "Digit 1", "Digit 2", "Bell 2", "Alien", "Breath", "Voice3", "Steam", "Metal", "Chime", "Bowing", "Pick 1", "Pick 2", "Mallet", "Slap", "Plink", "Pluck", "Plunk", "Click", "Chiff", "Thump", "Logdrm", "Kick2", "Snare", "Tomtom", "Hihat", "Drums 1", "Drums 2", "Drums 3", "Drums 4", "Drums 5"])

}
