
protocol DX200RhythmPatch : DX200SinglePatch { }
extension DX200RhythmPatch {
  static var modelId: UInt8 { return 0x6d }
}

class DX200RhythmFXPatch : DX200RhythmPatch {
  
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
    return 0x020100
  }
  
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
    return RolandAddress([0x30, UInt8(index), 0x00])
  }

  //  class var bankType: SysexPatchBank.Type { return DX7VoiceBank.self }
  static let dataByteCount: Int = 0x03
  class var initFileName: String { return "DX-init" }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).bytes(forData: data)
  }
  
  func randomize() {
    let type = (0...(FX.allFx.count-1)).random()!
    let fx = FX.allFx[type]
    self[[.type, .hi]] = (fx.value >> 8) & 0xf
    self[[.type, .lo]] = fx.value & 0xf
    self[[.param]] = (0...127).random()!
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    p[[.type, .hi]] = RangeParam(byte: 0x00)
    p[[.type, .lo]] = RangeParam(byte: 0x01)
    p[[.param]] = RangeParam(byte: 0x02)
    return p
  }()
  class var params: SynthPathParam { return _params }
  
  struct FX {
    
    let value: Int
    let name: String
    let param: (String,Param)
    
    init(value: Int, name: String, param: (String,Param)) {
      self.value = value
      self.name = name
      self.param = param
    }

    static let lfoParam: (String,Param) = ("LFO Speed", OptionsParam(options: lfoFreqOptions))
    static let delayParam: (String,Param) = ("Tempo Sync", OptionsParam(options: tempoOptions))
    static let reverbParam: (String,Param) = ("Time", OptionsParam(options: reverbTimeOptions))
    static let ampParam: (String,Param) = ("Drive", RangeParam())

    static let typeOptions: [Int:String] = allFx.dictionary { [$0.value : $0.name] }
    
    static let allFx: [FX] = [
      delay1,
      delay2,
      delay3,
      reverb,
      flanger1,
      flanger2,
      chorus,
      phaser1,
      phaser2,
      phaser3,
      ampSim1,
      ampSim2,
      ampSim3,
      ]
    
    /// Map fx type value to FX instance
    static let fxValueMap: [Int:FX] = allFx.dictionary { [$0.value : $0] }
    
    static let delay1 = FX(value: 0x0000, name: "Delay 1 (mono)", param: delayParam)
    static let delay2 = FX(value: 0x0001, name: "Delay 2 (stereo)", param: delayParam)
    static let delay3 = FX(value: 0x0002, name: "Delay 3 (cross)", param: delayParam)
    static let reverb = FX(value: 0x0003, name: "Reverb", param: reverbParam)
    static let flanger1 = FX(value: 0x0100, name: "Flanger 1", param: lfoParam)
    static let flanger2 = FX(value: 0x0101, name: "Flanger 2", param: lfoParam)
    static let chorus = FX(value: 0x0102, name: "Chorus", param: lfoParam)
    static let phaser1 = FX(value: 0x0200, name: "Phaser 1", param: lfoParam)
    static let phaser2 = FX(value: 0x0201, name: "Phaser 2", param: lfoParam)
    static let phaser3 = FX(value: 0x0202, name: "Phaser 3", param: lfoParam)
    static let ampSim1 = FX(value: 0x0300, name: "AmpSim 1", param: ampParam)
    static let ampSim2 = FX(value: 0x0301, name: "AmpSim 2", param: ampParam)
    static let ampSim3 = FX(value: 0x0302, name: "AmpSim 3", param: ampParam)
  
    static let lfoFreqOptions = OptionsParam.makeOptions(["0", "0.04", "0.08", "0.12", "0.16", "0.21", "0.25", "0.29", "0.33", "0.37", "0.42", "0.46", "0.5", "0.54", "0.58", "0.63", "0.67", "0.71", "0.75", "0.79", "0.84", "0.88", "0.92", "0.96", "1", "1.05", "1.09", "1.13", "1.17", "1.22", "1.26", "1.3", "1.34", "1.38", "1.43", "1.47", "1.51", "1.55", "1.59", "1.64", "1.68", "1.72", "1.76", "1.8", "1.85", "1.89", "1.93", "1.97", "2.01", "2.06", "2.1", "2.14", "2.18", "2.22", "2.27", "2.31", "2.35", "2.39", "2.43", "2.48", "2.52", "2.56", "2.6", "2.65", "2.69", "2.77", "2.86", "2.94", "3.02", "3.11", "3.19", "3.28", "3.36", "3.44", "3.53", "3.61", "3.7", "3.86", "4.03", "4.2", "4.37", "4.54", "4.71", "4.87", "5.04", "5.21", "5.38", "5.55", "5.72", "6.05", "6.39", "6.72", "7.06", "7.4", "7.73", "8.07", "8.41", "8.74", "9.08", "9.42", "9.75", "10", "10.7", "11.4", "12.1", "12.7", "13.4", "14.1", "14.8", "15.4", "16.1", "16.8", "17.5", "18.1", "19.5", "20.8", "22.2", "23.5", "24.8", "26.2", "27.5", "28.9", "30.2", "31.6", "32.9", "34.3", "37", "39.7"])
    
    static let reverbTimeOptions = OptionsParam.makeOptions((0..<128).map {
      let v: Float
      switch $0 {
      case 0...93:
        v = Float($0 / 2) * 0.1 + 0.3
      case 94...113:
        v = Float(($0 - 94) / 2) * 0.5 + 5
      default:
        v = Float(($0 - 114) / 2) + 10
      }
      return String(format: "%.1f", v)
    })
    
    static let tempoOptions = OptionsParam.makeOptions((0..<128).map {
      switch $0 {
      case 0...7: return "1/32"
      case 8...15: return "1/24"
      case 16...23: return "1/16"
      case 24...31: return "1/12"
      case 32...39: return "3/32"
      case 40...47: return "1/8"
      case 48...55: return "1/6"
      case 56...63: return "3/16"
      case 64...71: return "1/4"
      case 72...79: return "1/3"
      case 80...95: return "3/8"
      default: return "1/2"
      }
    })
  }
}


class DX200RhythmMultiPartPatch : DX200RhythmPatch {
  
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
    let index = synthPath == [.part, .voice] ? 8 : (synthPath.i(1) ?? 0)
    return RolandAddress([0x08, UInt8(index), 0x00])
  }
  
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
    let subIndex = synthPath == [.part, .voice] ? 8 : (synthPath.i(1) ?? 0)
    return RolandAddress([0x40 + UInt8(subIndex), UInt8(index), 0x00])
  }

  //  class var bankType: SysexPatchBank.Type { return DX7VoiceBank.self }
  static let dataByteCount: Int = 0x0f
  class var initFileName: String { return "DX-init" }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).bytes(forData: data)
  }
  
  func randomize() {
    self[[.volume]] = (100...127).random()!
    self[[.pan]] = (54...74).random()!
    self[[.fx, .send]] = (0...127).random()
    self[[.cutoff]] = (54...74).random()!
    self[[.reson]] = (54...74).random()!
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.volume]] = RangeParam(byte: 0x05)
    p[[.pan]] = RangeParam(byte: 0x06)
    p[[.fx, .send]] = RangeParam(byte: 0x07)
    p[[.cutoff]] = RangeParam(byte: 0x0a, displayOffset: -64)
    p[[.reson]] = RangeParam(byte: 0x0b, displayOffset: -64)

    return p
  }()
  class var params: SynthPathParam { return _params }
  
}


class DX200RhythmSeqPatch : DX200RhythmPatch {
  
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
    let index = synthPath.i(1) ?? 0
    return RolandAddress([0x10, UInt8(index), 0x00])
  }
  
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
    let subIndex = synthPath.i(1) ?? 0
    return RolandAddress([0x20 + UInt8(subIndex), UInt8(index), 0x00])
  }

  //  class var bankType: SysexPatchBank.Type { return DX7VoiceBank.self }
  static let dataByteCount: Int = 0x66
  class var initFileName: String { return "DX-init" }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).bytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
    
    (0..<16).forEach { step in
      let stepWhole: Int
      let stepPart: Int // 0...63
      switch (0...2).random() {
      case 0:
        stepWhole = 0
        stepPart = (0...63).random()!
      case 1:
        stepWhole = (1...3).random()!
        stepPart = 0
      default:
        stepWhole = (1...8).random()!
        stepPart = 0
      }
      let gateBytes = (stepWhole << 6) | stepPart
      self[[.i(step), .gate, .lo]] = gateBytes & 0x7f
      self[[.i(step), .pitch]] = (54...90).random()!
      self[[.i(step), .gate, .hi]] = (gateBytes >> 7)
    }
  }

  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    (0..<16).forEach { step in
      p[[.i(step), .voice]] = OptionsParam(byte: 0x06 + step, options: drumOptions)
      p[[.i(step), .velo]] = RangeParam(byte: 0x16 + step)
      p[[.i(step), .gate, .lo]] = RangeParam(byte: 0x26 + step)
      p[[.i(step), .pitch]] = RangeParam(byte: 0x36 + step, displayOffset: -64)
      p[[.i(step), .gate, .hi]] = RangeParam(byte: 0x46 + step)
      p[[.i(step), .mute]] = RangeParam(byte: 0x56 + step, maxVal: 1)
    }

    return p
  }()
  class var params: SynthPathParam { return _params }
  
  
  static let gateOptions: [Int:String] = OptionsParam.makeOptions((0..<1024).map {
    let steps: Double
    if $0 == 0 {
      steps = 0.01
    }
    else if $0 <= 64 {
      steps = Double($0) / 64
    }
    else {
      steps = Double($0 + 1) / 64
    }
    return String(format: "%.2f", steps)
  })
  
  static let drumOptions: [Int:String] = OptionsParam.makeOptions(["PulseBass C", "PulseBass C#", "PulseBass D", "PulseBass D#", "PulseBass E", "PulseBass F", "PulseBass F#", "PulseBass G", "PulseBass G#", "PulseBass A", "PulseBass A#", "PulseBass B", "SineBass C", "SineBass C#", "SineBass D", "SineBass D#", "SineBass E", "SineBass F", "SineBass F#", "SineBass G", "SineBass G#", "SineBass A", "SineBass A#", "SineBass B", "PickBass C", "PickBass C#", "PickBass D", "PickBass D#", "PickBass E", "PickBass F", "PickBass F#", "PickBass G", "PickBass G#", "PickBass A", "PickBass A#", "PickBass B", "BD Analog", "BD R&B 1", "BD R&B 2", "BD Lo-Fi", "BD Jungle", "BD Hip 1", "BD Hip 2", "BD Tech", "BD Dist 1", "BD Dist 2", "BD Human 1", "BD Human 2", "BD Elec 1", "BD Elec 2", "BD Elec 3", "SD Live", "SD R&B 1", "SD R&B 2", "SD Analog", "SD Hip 1", "SD Hip 2", "SD Hip 3", "SD Cut", "SD Dodge", "SD Timbre", "SD D&B", "SD Dist", "SD Elec 1", "SD Elec 2", "SD Rim 1", "SD Rim 2", "HH D&B Cls", "HH D&B Opn", "HH Ana Cls 1", "HH Ana Opn 1", "HH Syn Cls", "HH Syn Opn", "HH Ana Cls 2", "HH Ana Opn 2", "Tom Dist", "Tom Ana 1", "Tom Ana 2", "Tom Synth", "Tom Sine", "Crush Cym", "Ride Cym", "Ride Bell", "Tambourine", "Tabla Open", "Tabla Mute", "Tabla Nah", "Udu Low", "Udu High", "Udu Finger", "Clave", "Maracas", "Shaker", "Clap", "Scratch 1", "Scratch 2", "Scratch 3", "Scratch 4", "Ripper", "Zap 1", "Zap 2", "Rev Low", "Synth Vibra", "Metal", "Click", "Gt Attack", "Gt Power", "Stab Organ", "SlowBass", "FingerBass", "SynthBass 1", "SynthBass 2", "SynthBass 3", "SynthBass 4", "Digi Wave 1", "Digi Wave 2", "Digi Wave 3", "Digi Wave 4", "Digi Wave 5", "Digi Wave 6", "Digi Wave 7"])
}
