
protocol DX200SynthPatch : DX200SinglePatch { }
extension DX200SynthPatch {
  static var modelId: UInt8 { return 0x62 }
}

class DX200VoiceCommon1Patch : DX200SynthPatch {
  
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
    return 0x100000
  }
  
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
    return RolandAddress([0x20, UInt8(index), 0x00])
  }
  
  
//  class var bankType: SysexPatchBank.Type { return DX7VoiceBank.self }
  static let dataByteCount: Int = 0x29
  class var initFileName: String { return "DX-init" }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).bytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
    self[[.voice, .level]] = 127
    self[[.filter, .gain]] = (60...65).random()!
    self[[.eq, .lo, .gain]] = 64
    self[[.eq, .mid, .gain]] = 64
    self[[.amp, .env, .attack]] = 64
    self[[.amp, .env, .decay]] = 64
    self[[.amp, .env, .sustain]] = 64
    self[[.amp, .env, .release]] = 64

    
    switch self[[.filter, .type]] {
    case 0, 1, 2: // lopass
      self[[.cutoff]] = (25...127).random()!
      self[[.filter, .env, .amt]] = (56...127).random()!
    case 4: // hipass
      self[[.cutoff]] = (0...90).random()!
      self[[.filter, .env, .amt]] = (0...110).random()!
    default:
      self[[.filter, .env, .amt]] = (54...74).random()!
    }
  }

  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.dist, .on]] = RangeParam(byte: 0x00, maxVal: 1)
    p[[.dist, .drive]] = RangeParam(byte: 0x01, maxVal: 64)
    p[[.dist, .type]] = OptionsParam(byte: 0x02, options: ["Off","Stack", "Combo", "Tube"])
    p[[.dist, .cutoff]] = OptionsParam(byte: 0x03, options: distCutoffOptions)
    p[[.dist, .level]] = RangeParam(byte: 0x04, maxVal: 100)
    p[[.dist, .amt]] = RangeParam(byte: 0x05)
    p[[.eq, .lo, .freq]] = OptionsParam(byte: 0x06, options: loFreqOptions)
    p[[.eq, .lo, .gain]] = RangeParam(byte: 0x07, range: 0x34...0x4c, displayOffset: -64)
    p[[.eq, .mid, .freq]] = OptionsParam(byte: 0x08, options: midFreqOptions)
    p[[.eq, .mid, .gain]] = RangeParam(byte: 0x09, range: 0x34...0x4c, displayOffset: -64)
    p[[.eq, .mid, .q]] = OptionsParam(byte: 0x0a, options: midQOptions)

    p[[.cutoff]] = RangeParam(byte: 0x0c)
    p[[.reson]] = RangeParam(byte: 0x0d, range: 0...116, displayOffset: -16)
    p[[.filter, .type]] = OptionsParam(byte: 0x0e, options: filterOptions)
    p[[.filter, .cutoff, .scale, .amt]] = RangeParam(byte: 0x0f, displayOffset: -64)
    p[[.filter, .cutoff, .mod, .amt]] = RangeParam(byte: 0x10, maxVal: 99)
    p[[.filter, .gain]] = RangeParam(byte: 0x11, range: 0x34...0x4c, displayOffset: -64)
    p[[.filter, .env, .attack]] = RangeParam(byte: 0x12)
    p[[.filter, .env, .decay]] = RangeParam(byte: 0x13)
    p[[.filter, .env, .sustain]] = RangeParam(byte: 0x14)
    p[[.filter, .env, .release]] = RangeParam(byte: 0x15)
    p[[.filter, .env, .amt]] = RangeParam(byte: 0x16, displayOffset: -64)
    p[[.filter, .env, .velo]] = RangeParam(byte: 0x17, displayOffset: -64)
    
    p[[.noise, .type]] = OptionsParam(byte: 0x19, options: noiseOptions)
    p[[.voice, .level]] = RangeParam(byte: 0x1a)
    p[[.noise, .level]] = RangeParam(byte: 0x1b)
    p[[.mod, .i(0), .harmonic]] = RangeParam(byte: 0x1c, displayOffset: -64)
    p[[.mod, .i(1), .harmonic]] = RangeParam(byte: 0x1d, displayOffset: -64)
    p[[.mod, .i(2), .harmonic]] = RangeParam(byte: 0x1e, displayOffset: -64)
    p[[.mod, .i(0), .fm, .amt]] = RangeParam(byte: 0x1f, displayOffset: -64)
    p[[.mod, .i(1), .fm, .amt]] = RangeParam(byte: 0x20, displayOffset: -64)
    p[[.mod, .i(2), .fm, .amt]] = RangeParam(byte: 0x21, displayOffset: -64)
    p[[.mod, .i(0), .env, .decay]] = RangeParam(byte: 0x22, displayOffset: -64)
    p[[.mod, .i(1), .env, .decay]] = RangeParam(byte: 0x23, displayOffset: -64)
    p[[.mod, .i(2), .env, .decay]] = RangeParam(byte: 0x24, displayOffset: -64)
    p[[.amp, .env, .attack]] = RangeParam(byte: 0x25, displayOffset: -64)
    p[[.amp, .env, .decay]] = RangeParam(byte: 0x26, displayOffset: -64)
    p[[.amp, .env, .sustain]] = RangeParam(byte: 0x27, displayOffset: -64)
    p[[.amp, .env, .release]] = RangeParam(byte: 0x28, displayOffset: -64)

    return p
  }()
  class var params: SynthPathParam { return _params }
  
  static let filterOptions = OptionsParam.makeOptions(["LPF 24", "LPF 18", "LPF 12", "BPF", "HPF 12", "BEF"])
  
  static let distCutoffOptions = OptionsParam.makeOptions(Array(freqOptions[34...60]))
  
  static let loFreqOptions = OptionsParam.makeOptions(Array(freqOptions[4...40]))
  
  static let midFreqOptions = OptionsParam.makeOptions(Array(freqOptions[14...54]))
  
  static let freqOptions = ["0", "0", "0", "0", "32", "39", "46", "53", "60", "67", "74", "81", "88", "95", "100", "115", "125", "140", "190", "240", "290", "340", "390", "440", "490", "540", "590", "640", "690", "740", "790", "840", "890", "940", "1000", "1175", "1350", "1525", "1700", "1875", "2000", "2350", "2700", "3050", "3400", "3750", "4100", "4450", "5000", "5750", "6500", "7250", "8000", "8750", "10k", "12k", "14k", "16k", "18k", "20k", "Thru"]
  
  static let midQOptions = OptionsParam.makeOptions((10...120).map { String(format: "%.1f", Double($0) / 10) })
  
  static let noiseOptions = OptionsParam.makeOptions(["White", "Pink", "Up Slow", "Up Mid", "Up High", "Down Slow", "Down Mid", "Down High", "Pitch Scale 1", "Pitch Scale 2", "Pitch Scale 3", "Pitch Scale 4", "Variation 1", "Variation 2", "Variation 3", "Variation 4"])
}


class DX200VoiceCommon2Patch : DX200SynthPatch {
  
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
    return 0x100100
  }
  
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
    return RolandAddress([0x21, UInt8(index), 0x00])
  }

  static let dataByteCount: Int = 0x05
  class var initFileName: String { return "DX-init" }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).bytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
    self[[.tempo]] = (60...150).random()!
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.mod, .select]] = RangeParam(byte: 0x00)
    p[[.scene]] = RangeParam(byte: 0x01)
    p[[.tempo]] = RangeParam(parm: 2, byte: 0x02, range: 20...300)
    p[[.swing]] = RangeParam(byte: 0x04, range: 50...83)
    
    return p
  }()
  class var params: SynthPathParam { return _params }
}


class DX200VoiceScenePatch : DX200SynthPatch {
  
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
    let index = synthPath.i(1) ?? 0
    return RolandAddress([0x10, 0x03 + UInt8(index), 0x00])
  }
  
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
    let subIndex = synthPath.i(1) ?? 0
    return RolandAddress([0x40 + UInt8(subIndex), UInt8(index), 0x00])
  }

  static let dataByteCount: Int = 0x1c
  class var initFileName: String { return "DX-init" }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).bytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
  }

  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.cutoff]] = RangeParam(byte: 0x00)
    p[[.reson]] = RangeParam(byte: 0x01)
    p[[.filter, .env, .attack]] = RangeParam(byte: 0x02)
    p[[.filter, .env, .decay]] = RangeParam(byte: 0x03)
    p[[.filter, .env, .sustain]] = RangeParam(byte: 0x04)
    p[[.filter, .env, .release]] = RangeParam(byte: 0x05)
    p[[.filter, .env, .amt]] = RangeParam(byte: 0x06, displayOffset: -64)
    p[[.filter, .type]] = OptionsParam(byte: 0x07, options: DX200VoiceCommon1Patch.filterOptions)
    p[[.voice, .lfo, .speed]] = RangeParam(byte: 0x08)
    p[[.extra, .porta, .time]] = RangeParam(byte: 0x09)
    p[[.noise, .level]] = RangeParam(byte: 0x0a)
    p[[.mod, .i(0), .harmonic]] = RangeParam(byte: 0x0b, displayOffset: -64)
    p[[.mod, .i(1), .harmonic]] = RangeParam(byte: 0x0c, displayOffset: -64)
    p[[.mod, .i(2), .harmonic]] = RangeParam(byte: 0x0d, displayOffset: -64)
    p[[.mod, .i(0), .fm, .amt]] = RangeParam(byte: 0x0e, displayOffset: -64)
    p[[.mod, .i(1), .fm, .amt]] = RangeParam(byte: 0x0f, displayOffset: -64)
    p[[.mod, .i(2), .fm, .amt]] = RangeParam(byte: 0x10, displayOffset: -64)
    p[[.mod, .i(0), .env, .decay]] = RangeParam(byte: 0x11, displayOffset: -64)
    p[[.mod, .i(1), .env, .decay]] = RangeParam(byte: 0x12, displayOffset: -64)
    p[[.mod, .i(2), .env, .decay]] = RangeParam(byte: 0x13, displayOffset: -64)
    p[[.amp, .env, .attack]] = RangeParam(byte: 0x14, displayOffset: -64)
    p[[.amp, .env, .decay]] = RangeParam(byte: 0x15, displayOffset: -64)
    p[[.amp, .env, .sustain]] = RangeParam(byte: 0x16, displayOffset: -64)
    p[[.amp, .env, .release]] = RangeParam(byte: 0x17, displayOffset: -64)
    p[[.volume]] = RangeParam(byte: 0x18) // corresponds to part volume (not voice common)
    p[[.pan]] = RangeParam(byte: 0x19, displayOffset: -64)
    p[[.fx, .send]] = RangeParam(byte: 0x1a)
    p[[.param]] = RangeParam(byte: 0x1b) // this is fx param. short like this for auto sync-mapping

    return p
  }()
  class var params: SynthPathParam { return _params }
}


class DX200VoiceFreeEnvPatch : DX200SynthPatch {
  
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
    return 0x100200
  }
  
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
    return RolandAddress([0x30 + UInt8(index >> 3), UInt8(index & 0b111) << 4, 0x00])
  }

  static let dataByteCount: Int = 0x60c
  class var initFileName: String { return "DX-init" }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).bytes(forData: data)
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    p[[.trigger]] = OptionsParam(byte: 0x00, options: triggerOptions)
    p[[.loop, .type]] = OptionsParam(byte: 0x01, options: loopTypeOptions)
    p[[.length]] = OptionsParam(byte: 0x02, options: lengthOptions)
    p[[.keyTrk]] = RangeParam(byte: 0x03, displayOffset: -64)
    (0..<4).forEach { trk in
      p[[.trk, .i(trk), .param]] = OptionsParam(byte: 0x04 + (trk * 2), options: paramOptions)
      p[[.trk, .i(trk), .scene, .on]] = RangeParam(byte: 0x05 + (trk * 2), maxVal: 1)
      
      (0..<192).forEach { step in
        p[[.trk, .i(trk), .data, .i(step)]] = RangeParam(parm: 2, byte: RolandAddress(intValue: 0x0c + (step * 2) + (trk * 384)).value, maxVal: 255)
      }
    }
    return p
  }()
  class var params: SynthPathParam { return _params }
  
  static let triggerOptions: [Int:String] = OptionsParam.makeOptions(["Free", "MIDI In Notes", "All Notes", "Seq Start"])
  
  static let loopTypeOptions: [Int:String] = OptionsParam.makeOptions(["Off", "Forward", "Forward 1/2", "Alternate", "Alternate 1/2"])
  
  static let lengthOptions: [Int:String] = {
    var map: [Int:String] = [
      2 : "1/2 bar",
      3 : "1 bar",
      4 : "3/2 bars",
      5 : "2 bars",
      6 : "3 bars",
      7 : "4 bars",
      8 : "6 bars",
      9 : "8 bars",
    ]
    (0xa..<0x50).forEach { map[$0] = String(format: "%.1f sec", Double($0) / 10) }
    (0x50...0x60).forEach { map[$0] = String(format: "%.1f sec", Double($0 - 0x50) * 0.5 + 8) }
    return map
  }()
  
  static let paramOptions: [Int:String] = OptionsParam.makeOptions(["Off", "Porta Time", "LFO Speed", "Mod 1 Harmonic", "Mod 2 Harmonic", "Mod 3 Harmonic", "Mod All Harmonic", "Mod 1 FM Depth", "Mod 2 FM Depth", "Mod 3 FM Depth", "Mod All FM Depth", "Mod 1 EG Decay", "Mod 2 EG Decay", "Mod 3 EG Decay", "Mod All EG Decay", "Noise Level", "Filter Type", "Filter Cutoff", "Filter Reson", "FEG Attack", "FEG Decay", "FEG Sustain", "FEG Release", "FEG Depth", "AEG Attack", "AEG Decay", "AEG Sustain", "AEG Release", "FX Param", "FX Wet Level", "Track Pan", "Track Level"])
}



class DX200VoiceSeqPatch : DX200SynthPatch {
  
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
    return 0x104000
  }
  
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
    return RolandAddress([0x50, UInt8(index), 0x00])
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
      self[[.i(step), .note]] = (35...90).random()!
      self[[.i(step), .gate, .hi]] = (gateBytes >> 7)
    }
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.step, .scale]] = RangeParam(byte: 0x00)
    p[[.length]] = RangeParam(byte: 0x01)
    (0..<16).forEach { step in
      p[[.i(step), .note]] = OptionsParam(byte: 0x06 + step, options: ParamHelper.midiNoteOptions)
      p[[.i(step), .velo]] = RangeParam(byte: 0x16 + step)
      p[[.i(step), .gate, .lo]] = RangeParam(byte: 0x26 + step)
      p[[.i(step), .ctrl]] = RangeParam(byte: 0x36 + step)
      p[[.i(step), .gate, .hi]] = RangeParam(byte: 0x46 + step)
      p[[.i(step), .mute]] = RangeParam(byte: 0x56 + step, maxVal: 1)
    }
    
    return p
  }()
  class var params: SynthPathParam { return _params }
}
