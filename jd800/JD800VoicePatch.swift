
class JD800VoicePatch : JD800MultiPatch, VoicePatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = JD800VoiceBank.self
  
  // TODO: requires some byte math. Check the D-10 or something for a solution
  static func location(forData data: Data) -> Int {
    return 0// Int(addressBytes(forSysex: data)[1])
  }

  // TODO: same as above
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x000000
  }
  
  class var initFileName: String { return "jd800-voice-init" }
  
  var addressables: [SynthPath:RolandSingleAddressable]
  
  required init(data: Data) {
    if data.count == JD800VoicePartPatch.fileDataCount {
      addressables = JD800VoicePartPatch.addressables(forData: data)
      addressables[[.fx]] = JD800FXPatch()
    }
    else {
      addressables = type(of: self).addressables(forData: data)
    }
  }
  
  private static let _addressableTypes: [SynthPath:RolandSingleAddressable.Type] = [
    [.common]      : JD800CommonPatch.self,
    [.fx]          : JD800FXPatch.self,
    [.tone, .i(0)] : JD800TonePatch.self,
    [.tone, .i(1)] : JD800TonePatch.self,
    [.tone, .i(2)] : JD800TonePatch.self,
    [.tone, .i(3)] : JD800TonePatch.self,
    ]
  class var addressableTypes: [SynthPath:RolandSingleAddressable.Type] {
    return _addressableTypes
  }
  
  private static let _subpatchAddresses: [SynthPath:RolandAddress] = [
    [.common]      : 0x0000,
    [.fx]          : 0x0032,
    [.tone, .i(0)] : 0x0060,
    [.tone, .i(1)] : 0x0128,
    [.tone, .i(2)] : 0x0170,
    [.tone, .i(3)] : 0x0238,
    ]
  class var subpatchAddresses: [SynthPath:RolandAddress] {
    return _subpatchAddresses
  }
  
  static func isValid(fileSize: Int) -> Bool {
    return fileSize == fileDataCount || fileSize == JD800VoicePartPatch.fileDataCount
  }

  // render the sysex for this patch as a voice part
  func partSysexData(deviceId: Int, address: RolandAddress) -> [Data] {
    return JD800VoicePartPatch.addressableTypes.compactMap { (path, addressableType) -> [Data]? in
      guard let subAdd = JD800VoicePartPatch.subpatchAddresses[path] else { return nil }
      return addressables[path]?.sysexData(deviceId: deviceId, address: address + subAdd)
    }.joined().map { $0 }
  }

}


class JD800CommonPatch : JD800Patch {
  
  static let initFileName = ""
  static let nameByteRange = 0..<0x0f
  class var size: RolandAddress { return 0x32 }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x0000
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()

    self[[.tone, .i(0), .on]] = 1
    self[[.tone, .i(1), .on]] = 1
    self[[.tone, .i(2), .on]] = 1
    self[[.tone, .i(3), .on]] = 1

    self[[.level]] = 100

    self[[.tone, .i(0), .key, .lo]] = 0
    self[[.tone, .i(0), .key, .hi]] = 127
    self[[.tone, .i(1), .key, .lo]] = 0
    self[[.tone, .i(1), .key, .hi]] = 127
    self[[.tone, .i(2), .key, .lo]] = 0
    self[[.tone, .i(2), .key, .hi]] = 127
    self[[.tone, .i(3), .key, .lo]] = 0
    self[[.tone, .i(3), .key, .hi]] = 127
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.level]] = RangeParam(byte: 0x10, maxVal: 100)
    p[[.tone, .i(0), .key, .lo]] = RangeParam(byte: 0x11, formatter: ParamHelper.noteNameFormatter)
    p[[.tone, .i(0), .key, .hi]] = RangeParam(byte: 0x12, formatter: ParamHelper.noteNameFormatter)
    p[[.tone, .i(1), .key, .lo]] = RangeParam(byte: 0x13, formatter: ParamHelper.noteNameFormatter)
    p[[.tone, .i(1), .key, .hi]] = RangeParam(byte: 0x14, formatter: ParamHelper.noteNameFormatter)
    p[[.tone, .i(2), .key, .lo]] = RangeParam(byte: 0x15, formatter: ParamHelper.noteNameFormatter)
    p[[.tone, .i(2), .key, .hi]] = RangeParam(byte: 0x16, formatter: ParamHelper.noteNameFormatter)
    p[[.tone, .i(3), .key, .lo]] = RangeParam(byte: 0x17, formatter: ParamHelper.noteNameFormatter)
    p[[.tone, .i(3), .key, .hi]] = RangeParam(byte: 0x18, formatter: ParamHelper.noteNameFormatter)
    p[[.bend, .down]] = RangeParam(byte: 0x19, maxVal: 48)
    p[[.bend, .up]] = RangeParam(byte: 0x1A, maxVal: 12)
    p[[.aftertouch, .bend]] = RangeParam(byte: 0x1B, maxVal: 26)
    p[[.solo]] = RangeParam(byte: 0x1C, maxVal: 1)
    p[[.solo, .legato]] = RangeParam(byte: 0x1D, maxVal: 1)
    p[[.porta]] = RangeParam(byte: 0x1E, maxVal: 1)
    p[[.porta, .mode]] = OptionsParam(byte: 0x1F, options: portaModeOptions)
    p[[.porta, .time]] = RangeParam(byte: 0x20, maxVal: 100)
    p[[.tone, .i(0), .on]] = RangeParam(byte: 0x21, bit: 0)
    p[[.tone, .i(1), .on]] = RangeParam(byte: 0x21, bit: 1)
    p[[.tone, .i(2), .on]] = RangeParam(byte: 0x21, bit: 2)
    p[[.tone, .i(3), .on]] = RangeParam(byte: 0x21, bit: 3)
    p[[.tone, .i(0), .active]] = RangeParam(byte: 0x22, bit: 0)
    p[[.tone, .i(1), .active]] = RangeParam(byte: 0x22, bit: 1)
    p[[.tone, .i(2), .active]] = RangeParam(byte: 0x22, bit: 2)
    p[[.tone, .i(3), .active]] = RangeParam(byte: 0x22, bit: 3)
    p[[.lo, .freq]] = OptionsParam(byte: 0x23, options: loFreqOptions)
    p[[.lo, .gain]] = RangeParam(byte: 0x24, maxVal: 30, displayOffset: -15)
    p[[.mid, .freq]] = OptionsParam(byte: 0x25, options: midFreqOptions)
    p[[.mid, .q]] = OptionsParam(byte: 0x26, options: midQOptions)
    p[[.mid, .gain]] = RangeParam(byte: 0x27, maxVal: 30, displayOffset: -15)
    p[[.hi, .freq]] = OptionsParam(byte: 0x28, options: hiFreqOptions)
    p[[.hi, .gain]] = RangeParam(byte: 0x29, maxVal: 30, displayOffset: -15)
    p[[.key, .mode]] = OptionsParam(byte: 0x2A, options: ["Whole", "Split", "Dual"])
    p[[.split, .pt]] = RangeParam(byte: 0x2B, maxVal: 85, formatter: {
      ParamHelper.noteNameFormatter($0 + 24)
    })
    p[[.channel, .lo]] = RangeParam(byte: 0x2C, maxVal: 15, displayOffset: 1)
    p[[.channel, .hi]] = RangeParam(byte: 0x2D, maxVal: 15, displayOffset: 1)
    p[[.pgmChange, .lo]] = RangeParam(byte: 0x2E, displayOffset: 1)
    p[[.pgmChange, .hi]] = RangeParam(byte: 0x2F, displayOffset: 1)
    p[[.hold]] = OptionsParam(byte: 0x30, options: ["Upper", "Lower", "Both"])

    return p
  }()
  
  class var params: SynthPathParam { return _params }

  static let portaModeOptions = OptionsParam.makeOptions(["Normal", "Legato"])

  static let loFreqOptions = OptionsParam.makeOptions(["200", "400Hz"])
  
  static let midFreqOptions = OptionsParam.makeOptions(["200", "250", "315", "400", "500", "630", "800", "1k", "1.25k", "1.6k", "2k", "2.5k", "3.15k", "4k", "5k", "6.3k", "8kHz"])
  
  static let midQOptions = OptionsParam.makeOptions(["0.5", "1.0", "2.0", "4.0", "9.0"])

  static let hiFreqOptions = OptionsParam.makeOptions(["4k", "8kHz"])

}

class JD800FXPatch : JD800Patch {
  
  static let initFileName = ""
  class var size: RolandAddress { return 0x2e }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x0032
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
//    self[[.tone, .type]] = 0
//
//    self[.level] = 127
//    self[.pan] = 64
//    self[[.out, .assign]] = 13
//
//    self[[.coarse]] = 64
//    self[[.fine]] = 64
//    self[[.octave, .shift]] = 64
//
//    self[[.cutoff]] = 64
//    self[[.reson]] = 64
//    self[[.attack]] = 64
//    self[[.release]] = 64
//    self[[.velo]] = 64
//
//    (0..<4).forEach { ctrl in
//      self[[.mtrx, .ctrl, .i(ctrl), .src]] = 0
//      (0..<4).forEach { dest in
//        self[[.mtrx, .ctrl, .i(ctrl), .dest, .i(dest)]] = 0
//        self[[.mtrx, .ctrl, .i(ctrl), .amt, .i(dest)]] = 64
//      }
//    }
  }

  static let fxA: [[SynthPathItem]] = [
    [.dist, .phase, .spectral, .extra],
    [.dist, .phase, .extra, .spectral],
    [.dist, .spectral, .extra, .phase],
    [.dist, .spectral, .phase, .extra],
    [.dist, .extra, .phase, .spectral],
    [.dist, .extra, .spectral, .phase],
    [.phase, .dist, .spectral, .extra],
    [.phase, .dist, .extra, .spectral],
    [.phase, .spectral, .extra, .dist],
    [.phase, .spectral, .dist, .extra],
    [.phase, .extra, .dist, .spectral],
    [.phase, .extra, .spectral, .dist],
    [.spectral, .phase, .dist, .extra],
    [.spectral, .phase, .extra, .dist],
    [.spectral, .dist, .extra, .phase],
    [.spectral, .dist, .phase, .extra],
    [.spectral, .extra, .phase, .dist],
    [.spectral, .extra, .dist, .phase],
    [.extra, .phase, .spectral, .dist],
    [.extra, .phase, .dist, .spectral],
    [.extra, .spectral, .dist, .phase],
    [.extra, .spectral, .phase, .dist],
    [.extra, .dist, .phase, .spectral],
    [.extra, .dist, .spectral, .phase],
  ]

  static let fxB: [[SynthPathItem]] = [
    [.chorus, .delay, .reverb],
    [.chorus, .reverb, .delay],
    [.delay, .chorus, .reverb],
    [.delay, .reverb, .chorus],
    [.reverb, .chorus, .delay],
    [.reverb, .delay, .chorus],
  ]

  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.i(0), .seq]] = OptionsParam(byte: 0x0, options: fxBlockASeqOptions)
    p[[.i(1), .seq]] = OptionsParam(byte: 0x1, options: fxBlockBSeqOptions)
    p[[.i(0), .part, .i(0), .on]] = RangeParam(byte: 0x2, maxVal: 1)
    p[[.i(0), .part, .i(1), .on]] = RangeParam(byte: 0x3, maxVal: 1)
    p[[.i(0), .part, .i(2), .on]] = RangeParam(byte: 0x4, maxVal: 1)
    p[[.i(0), .part, .i(3), .on]] = RangeParam(byte: 0x5, maxVal: 1)
    p[[.i(1), .part, .i(0), .on]] = RangeParam(byte: 0x6, maxVal: 1)
    p[[.i(1), .part, .i(1), .on]] = RangeParam(byte: 0x7, maxVal: 1)
    p[[.i(1), .part, .i(2), .on]] = RangeParam(byte: 0x8, maxVal: 1)
    p[[.i(1), .balance]] = RangeParam(byte: 0x9, maxVal: 100)
    p[[.dist, .type]] = OptionsParam(byte: 0x0A, options: distTypeOptions)
    p[[.dist, .drive]] = RangeParam(byte: 0x0B, maxVal: 100)
    p[[.dist, .level]] = RangeParam(byte: 0x0C, maxVal: 100)
    p[[.phase, .manual]] = RangeParam(byte: 0x0D, maxVal: 99)
    p[[.phase, .rate]] = RangeParam(byte: 0x0E, maxVal: 99)
    p[[.phase, .depth]] = RangeParam(byte: 0x0F, maxVal: 100)
    p[[.phase, .reson]] = RangeParam(byte: 0x10, maxVal: 100)
    p[[.phase, .mix]] = RangeParam(byte: 0x11, maxVal: 100)
    p[[.spectral, .i(0)]] = RangeParam(byte: 0x12, maxVal: 30, displayOffset: -15)
    p[[.spectral, .i(1)]] = RangeParam(byte: 0x13, maxVal: 30, displayOffset: -15)
    p[[.spectral, .i(2)]] = RangeParam(byte: 0x14, maxVal: 30, displayOffset: -15)
    p[[.spectral, .i(3)]] = RangeParam(byte: 0x15, maxVal: 30, displayOffset: -15)
    p[[.spectral, .i(4)]] = RangeParam(byte: 0x16, maxVal: 30, displayOffset: -15)
    p[[.spectral, .i(5)]] = RangeParam(byte: 0x17, maxVal: 30, displayOffset: -15)
    p[[.spectral, .skirt]] = RangeParam(byte: 0x18, maxVal: 4, displayOffset: 1)
    p[[.extra, .sens]] = RangeParam(byte: 0x19, maxVal: 100)
    p[[.extra, .mix]] = RangeParam(byte: 0x1A, maxVal: 100)
    p[[.delay, .mid, .time]] = RangeParam(byte: 0x1B, maxVal: 125)
    p[[.delay, .mid, .level]] = RangeParam(byte: 0x1C, maxVal: 100)
    p[[.delay, .left, .time]] = RangeParam(byte: 0x1D, maxVal: 125)
    p[[.delay, .left, .level]] = RangeParam(byte: 0x1E, maxVal: 100)
    p[[.delay, .right, .time]] = RangeParam(byte: 0x1F, maxVal: 125)
    p[[.delay, .right, .level]] = RangeParam(byte: 0x20, maxVal: 100)
    p[[.delay, .feedback]] = RangeParam(byte: 0x21, maxVal: 98)
    p[[.chorus, .rate]] = RangeParam(byte: 0x22, maxVal: 99)
    p[[.chorus, .depth]] = RangeParam(byte: 0x23, maxVal: 100)
    p[[.chorus, .delay]] = RangeParam(byte: 0x24, maxVal: 99)
    p[[.chorus, .feedback]] = RangeParam(byte: 0x25, maxVal: 98)
    p[[.chorus, .level]] = RangeParam(byte: 0x26, maxVal: 100)
    p[[.reverb, .type]] = OptionsParam(byte: 0x27, options: reverbTypeOptions)
    p[[.reverb, .pre]] = RangeParam(byte: 0x28, maxVal: 121)
    p[[.reverb, .early]] = RangeParam(byte: 0x29, maxVal: 100)
    p[[.reverb, .hi, .cutoff]] = OptionsParam(byte: 0x2A, options: reverbHiCutoffOptions)
    p[[.reverb, .time]] = RangeParam(byte: 0x2B, maxVal: 100)
    p[[.reverb, .level]] = RangeParam(byte: 0x2C, maxVal: 100)

    return p
  }()
  
  class var params: SynthPathParam { return _params }

  static let fxBlockASeqOptions = OptionsParam.makeOptions(["DS-PH-SP-EN", "DS-PH-EN-SP", "DS-SP-EN-PH", "DS-SP-PH-EN", "DS-EN-PH-SP", "DS-EN-SP-PH", "PH-DS-SP-EN", "PH-DS-EN-SP", "PH-SP-EN-DS", "PH-SP-DS-EN", "PH-EN-DS-SP", "PH-EN-SP-DS", "SP-PH-DS-EN", "SP-PH-EN-DS", "SP-DS-EN-PH", "SP-DS-PH-EN", "SP-EN-PH-DS", "SP-EN-DS-PH", "EN-PH-SP-DS", "EN-PH-DS-SP", "EN-SP-DS-PH", "EN-SP-PH-DS", "EN-DS-PH-SP", "EN-DS-SP-PH"])
  
  static let fxBlockBSeqOptions = OptionsParam.makeOptions(["CHO-DLY-REV", "CHO-REV-DLY", "DLY-CHO-REV", "DLY-REV-CHO", "REV-CHO-DLY", "REV-DLY-CHO"])
  static let distTypeOptions = OptionsParam.makeOptions(["MELLOW DRIVE", "OVERDRIVE", "CRY DRIVE", "MELLOW DIST", "LIGHT DIST", "FAT DIST", "FUZZ DIST"])
  
  static let reverbTypeOptions = OptionsParam.makeOptions(["ROOM1", "ROOM2", "HALL1", "HALL2", "HALL3", "HALL4", "GATE", "REVERSE", "FLYING1", "FLYING2"])
  
  static let reverbHiCutoffOptions = OptionsParam.makeOptions(["500", "630", "800", "1k", "1.25k", "1.6k", "2k", "2.5k", "3.15k", "4k", "5k", "6.3k", "8k", "10k", "12.5k", "16kHz", "Bypass"])

}

class JD800TonePatch : JD800Patch {
  
  static let size: RolandAddress = 0x0048
  static let initFileName = "jd800-tone-init"
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    let index = path?.endex ?? 0
    return RolandAddress([0x60]) + (RolandAddress([0x48]) * index)
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()

    self[[.wave, .group]] = 0
//    self[[.delay, .mode]] = 0
//    self[[.delay, .time]] = 0
//    self[[.level]] = 127
//    self[.pan] = (54...74).random()!
//    self[[.out, .assign]] = (0...1).random()!
//    self[[.dry]] = 127
//
//    self[[.coarse]] = (57...71).random()!
//    self[[.fine]] = (57...71).random()!
//    self[[.random, .pitch]] = 0
//    self[[.pitch, .keyTrk]] = 74
//
//    self[[.pitch, .env, .depth]] = 64
//
//    self[[.velo, .fade, .depth]] = 0
//    self[[.velo, .range, .lo]] = 1
//    self[[.velo, .range, .hi]] = 127
//    self[[.key, .range, .lo]] = 0
//    self[[.key, .range, .hi]] = 127
//
//    self[[.filter, .env, .depth]] = (64...80).random()!
//    self[[.amp, .env, .velo]] = (54...127).random()!
//    self[[.amp, .env, .velo, .time, .i(0)]] = 64
//    self[[.amp, .env, .velo, .time, .i(3)]] = 64
//    self[[.amp, .env, .time, .i(0)]] = (0...30).random()!
//    self[[.amp, .env, .time, .i(1)]] = (30...40).random()!
//    self[[.amp, .env, .time, .i(2)]] = (20...80).random()!
//    self[[.amp, .env, .time, .i(3)]] = (0...80).random()!
//    self[[.amp, .env, .level, .i(0)]] = 127
//    self[[.amp, .env, .level, .i(1)]] = (30...127).random()!
//    self[[.amp, .env, .level, .i(2)]] = (30...127).random()!
//
//    self[[.lfo, .i(0), .pitch]] = (54...84).random()!
//    self[[.lfo, .i(1), .pitch]] = (54...84).random()!
//    self[[.bias, .level]] = 64
  }
  
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()

    p[[.velo, .curve]] = RangeParam(byte: 0x0, maxVal: 3, displayOffset: 1)
    p[[.hold, .ctrl]] = RangeParam(byte: 0x1, maxVal: 1)
    p[[.lfo, .i(0), .rate]] = RangeParam(byte: 0x2, maxVal: 100)
    p[[.lfo, .i(0), .delay]] = RangeParam(byte: 0x3, maxVal: 101)
    p[[.lfo, .i(0), .fade]] = RangeParam(byte: 0x4, maxVal: 100, displayOffset: -50)
    p[[.lfo, .i(0), .wave]] = OptionsParam(byte: 0x5, options: ["TRI", "SAW", "SQU", "S/H", "RND"])
    p[[.lfo, .i(0), .offset]] = OptionsParam(byte: 0x6, options: ["+", "0", "-"])
    p[[.lfo, .i(0), .key, .sync]] = RangeParam(byte: 0x7, maxVal: 1)
    p[[.lfo, .i(1), .rate]] = RangeParam(byte: 0x8, maxVal: 100)
    p[[.lfo, .i(1), .delay]] = RangeParam(byte: 0x9, maxVal: 101)
    p[[.lfo, .i(1), .fade]] = RangeParam(byte: 0x0A, maxVal: 100, displayOffset: -50)
    p[[.lfo, .i(1), .wave]] = OptionsParam(byte: 0x0B, options: ["TRI", "SAW", "SQU", "S/H", "RND"])
    p[[.lfo, .i(1), .offset]] = OptionsParam(byte: 0x0C, options: ["+", "0", "-"])
    p[[.lfo, .i(1), .key, .sync]] = RangeParam(byte: 0x0D, maxVal: 1)
    p[[.wave, .group]] = OptionsParam(byte: 0x0E, options: ["INT", "CARD"])
    p[[.wave, .number]] = OptionsParam(parm: 2, byte: 0x0F, options: internalWaveOptions)
    p[[.pitch, .coarse]] = RangeParam(byte: 0x11, maxVal: 96, displayOffset: -48)
    p[[.pitch, .fine]] = RangeParam(byte: 0x12, maxVal: 100, displayOffset: -50)
    p[[.pitch, .random]] = RangeParam(byte: 0x13, maxVal: 100)
    p[[.pitch, .keyTrk]] = OptionsParam(byte: 0x14, options: ["-100", "-50", "-20", "-10", "-5", "0", "+5", "+10", "+20", "+50", "+98", "+99", "+100", "+101", "+102", "+150", "+200"])
    p[[.bend]] = RangeParam(byte: 0x15, maxVal: 1)
    p[[.pitch, .aftertouch]] = RangeParam(byte: 0x16, maxVal: 1)
    p[[.pitch, .lfo, .i(0), .depth]] = RangeParam(byte: 0x17, maxVal: 100, displayOffset: -50)
    p[[.pitch, .lfo, .i(1), .depth]] = RangeParam(byte: 0x18, maxVal: 100, displayOffset: -50)
    p[[.pitch, .ctrl, .depth]] = RangeParam(byte: 0x19, maxVal: 100)
    p[[.pitch, .aftertouch, .mod]] = RangeParam(byte: 0x1A, maxVal: 100)
    p[[.pitch, .env, .velo]] = RangeParam(byte: 0x1B, maxVal: 100, displayOffset: -50)
    p[[.pitch, .env, .time, .velo]] = RangeParam(byte: 0x1C, maxVal: 100, displayOffset: -50)
    p[[.pitch, .env, .time, .keyTrk]] = RangeParam(byte: 0x1D, maxVal: 20, displayOffset: -10)
    p[[.pitch, .env, .level, .i(-1)]] = RangeParam(byte: 0x1E, maxVal: 100, displayOffset: -50)
    p[[.pitch, .env, .time, .i(0)]] = RangeParam(byte: 0x1F, maxVal: 100)
    p[[.pitch, .env, .level, .i(0)]] = RangeParam(byte: 0x20, maxVal: 100, displayOffset: -50)
    p[[.pitch, .env, .time, .i(1)]] = RangeParam(byte: 0x21, maxVal: 100)
    p[[.pitch, .env, .time, .i(2)]] = RangeParam(byte: 0x22, maxVal: 100)
    p[[.pitch, .env, .level, .i(1)]] = RangeParam(byte: 0x23, maxVal: 100, displayOffset: -50)
    p[[.filter, .type]] = OptionsParam(byte: 0x24, options: ["HPF", "BPF", "LPF"])
    p[[.cutoff]] = RangeParam(byte: 0x25, maxVal: 100)
    p[[.reson]] = RangeParam(byte: 0x26, maxVal: 100)
    p[[.filter, .keyTrk]] = RangeParam(byte: 0x27, maxVal: 40)
    p[[.filter, .aftertouch, .depth]] = RangeParam(byte: 0x28, maxVal: 100, displayOffset: -50)
    p[[.filter, .lfo]] = OptionsParam(byte: 0x29, options: ["LFO 1", "LFO 2"])
    p[[.filter, .lfo, .depth]] = RangeParam(byte: 0x2A, maxVal: 100, displayOffset: -50)
    p[[.filter, .env, .depth]] = RangeParam(byte: 0x2B, maxVal: 100, displayOffset: -50)
    p[[.filter, .env, .velo]] = RangeParam(byte: 0x2C, maxVal: 100, displayOffset: -50)
    p[[.filter, .env, .time, .velo]] = RangeParam(byte: 0x2D, maxVal: 100, displayOffset: -50)
    p[[.filter, .env, .time, .keyTrk]] = RangeParam(byte: 0x2E, maxVal: 20, displayOffset: -10)
    p[[.filter, .env, .time, .i(0)]] = RangeParam(byte: 0x2F, maxVal: 100)
    p[[.filter, .env, .level, .i(0)]] = RangeParam(byte: 0x30, maxVal: 100)
    p[[.filter, .env, .time, .i(1)]] = RangeParam(byte: 0x31, maxVal: 100)
    p[[.filter, .env, .level, .i(1)]] = RangeParam(byte: 0x32, maxVal: 100)
    p[[.filter, .env, .time, .i(2)]] = RangeParam(byte: 0x33, maxVal: 100)
    p[[.filter, .env, .level, .i(2)]] = RangeParam(byte: 0x34, maxVal: 100)
    p[[.filter, .env, .time, .i(3)]] = RangeParam(byte: 0x35, maxVal: 100)
    p[[.filter, .env, .level, .i(3)]] = RangeParam(byte: 0x36, maxVal: 100)
    p[[.bias, .direction]] = OptionsParam(byte: 0x37, options: ["UP", "LOW", "U&L"])
    p[[.bias, .pt]] = RangeParam(byte: 0x38, formatter: ParamHelper.noteNameFormatter)
    p[[.bias, .level]] = RangeParam(byte: 0x39, maxVal: 20, displayOffset: -10)
    p[[.level]] = RangeParam(byte: 0x3A, maxVal: 100)
    p[[.amp, .aftertouch, .depth]] = RangeParam(byte: 0x3B, maxVal: 100, displayOffset: -50)
    p[[.amp, .lfo]] = OptionsParam(byte: 0x3C, options: ["LFO 1", "LFO 2"])
    p[[.amp, .lfo, .depth]] = RangeParam(byte: 0x3D, maxVal: 100, displayOffset: -50)
    p[[.amp, .env, .velo]] = RangeParam(byte: 0x3E, maxVal: 100, displayOffset: -50)
    p[[.amp, .env, .time, .velo]] = RangeParam(byte: 0x3F, maxVal: 100, displayOffset: -50)
    p[[.amp, .env, .time, .keyTrk]] = RangeParam(byte: 0x40, maxVal: 20, displayOffset: -10)
    p[[.amp, .env, .time, .i(0)]] = RangeParam(byte: 0x41, maxVal: 100)
    p[[.amp, .env, .level, .i(0)]] = RangeParam(byte: 0x42, maxVal: 100)
    p[[.amp, .env, .time, .i(1)]] = RangeParam(byte: 0x43, maxVal: 100)
    p[[.amp, .env, .level, .i(1)]] = RangeParam(byte: 0x44, maxVal: 100)
    p[[.amp, .env, .time, .i(2)]] = RangeParam(byte: 0x45, maxVal: 100)
    p[[.amp, .env, .level, .i(2)]] = RangeParam(byte: 0x46, maxVal: 100)
    p[[.amp, .env, .time, .i(3)]] = RangeParam(byte: 0x47, maxVal: 100)

    return p
  }()
  class var params: SynthPathParam { return _params }
  
  static let internalWaveNames: [String] = ["Syn Saw 1", "Syn Saw 2", "FAT Saw", "FAT Square", "Syn Pulse 1", "Syn Pulse2", "Syn Pulse3", "Syn Pulse4", "Syn Pulse5", "Pulse Mod", "Triangle", "Syn Sine", "Soft Pad", "Wire Str", "MIDI Clav", "Spark Vox1", "Spark Vox2", "Syn Sax", "Clav Wave", "Cello Wave", "Bright Digi", "Cutters", "Syn Bass", "Rad Hose", "Vocal Wave", "Wally Wave", "Brusky Ip", "Digiwave", "Can Wave 1", "Can Wave 2", "EML 5th", "Wave Scan", "Nasty", "Wave Table", "Fine Wine", "Funk Bass 1", "Funk Bass 2", "Strat Sust", "Harp Harm", "Full Organ", "Full Draw", "Doo", "Zzz Vox", "Org Vox", "Male Vox", "Kalimba", "Xylo", "Marim Wave", "Log Drum", "AgogoBells", "Bottle Hit", "Gamelan 1", "Gamelan 2", "Gamelan 3", "Tabla", "Pole lp", "Pluck Harp", "Nylon Str", "Hooky", "Muters", "Klack Wave", "Crystal", "Digi Bell", "FingerBell", "Digi Chime", "Bell Wave", "Org Bell", "Scrape Gut", "Strat Atk", "Hellow Bs", "Piano Atk", "EP Hard", "Clear Keys", "EP Distone", "Flute Push", "Shami", "Wood Crak", "Kimba Atk", "Block", "Org Atk 1", "Org Atk 2", "Cowbell", "Sm Metal", "StrikePole", "Pizz", "Switch", "Tuba Slap", "Plink", "Plunk", "EP Atk", "TVF Trig", "Flute Tone", "Pan Pipe", "Bottle Blow", "Shaku Atk", "FlugelWave", "French", "White Noise", "Pink Noise", "Pitch Wind", "Vox Noise1", "Vox Noise2", "Crunch Wind", "ThroatWind", "Metal Wind", "Windago", "Anklungs", "Wind Chime"]
  
  static let internalWaveOptions: [Int:String] = OptionsParam.makeOptions(internalWaveNames)
  
}

