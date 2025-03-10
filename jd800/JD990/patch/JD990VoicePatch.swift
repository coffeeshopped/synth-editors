
class JD990VoicePatch : JD990MultiPatch, BankablePatch, VoicePatch {

  class var bankType: SysexPatchBank.Type { return JD990VoiceBank.self }

  static func location(forData data: Data) -> Int {
    return Int(addressBytes(forSysex: data)[1])
  }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    if (path?.count ?? 0) > 1 {
      return RolandAddress(0x02000000) + (path!.endex * RolandAddress(0x010000))
    }
    else {
      return 0x03000000
    }
  }
  
  class var initFileName: String { return "jd990-voice-init" }
  
  var addressables: [SynthPath:RolandSingleAddressable]
  
  required init(data: Data) {
    addressables = Self.addressables(forData: data)
  }
  
  private static let _addressableTypes: [SynthPath:RolandSingleAddressable.Type] = [
    [.common]      : JD990CommonPatch.self,
    [.tone, .i(0)] : JD990TonePatch.self,
    [.tone, .i(1)] : JD990TonePatch.self,
    [.tone, .i(2)] : JD990TonePatch.self,
    [.tone, .i(3)] : JD990TonePatch.self,
    ]
  class var addressableTypes: [SynthPath:RolandSingleAddressable.Type] {
    return _addressableTypes
  }
  
  private static let _subpatchAddresses: [SynthPath:RolandAddress] = [
    [.common]      : 0x0000,
    [.tone, .i(0)] : 0x0076,
    [.tone, .i(1)] : 0x0152,
    [.tone, .i(2)] : 0x022e,
    [.tone, .i(3)] : 0x030a,
    ]
  class var subpatchAddresses: [SynthPath:RolandAddress] {
    return _subpatchAddresses
  }
  
  // Synth saves this as common message + tone msgs compacted!
  func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
    // save common as one sysex msg
    var data = [Data]()
    if let common = addressables[[.common]] {
      data.append(contentsOf: common.sysexData(deviceId: deviceId, address: address))
    }

    // then tones as 2 more sysex msgs, compacted
    let toneData: [[Data]] = (0..<4).compactMap {
      let path: SynthPath = [.tone, .i($0)]
      guard let a = Self.subpatchAddresses[path] else { return nil }
      return addressables[path]?.sysexData(deviceId: deviceId, address: a)
    }
    let rData = RolandData(sysexData: [Data](toneData.joined()), addressableType: type(of: self))
    data.append(contentsOf: rData.sysexMsgs(deviceId: deviceId, offsetAddress: address))

    return data
  }
  
  static func isValid(fileSize: Int) -> Bool {
    return fileSize == 519 || fileSize == fileDataCount
  }
}

class JD990CommonPatch : JD990Patch {
  
    static let initFileName = ""
    static let nameByteRange = 0..<0x10
    class var size: RolandAddress { return 0x76 }
    
    static func startAddress(_ path: SynthPath?) -> RolandAddress {
      return 0x0000
    }
    
    var bytes: [UInt8]
    
    required init(data: Data) {
      bytes = Self.contentBytes(forData: data)
    }
    
    func randomize() {
      randomizeAllParams()

      self[[.level]] = 100
      self[[.pan]] = 50

      (0..<4).forEach {
        self[[.tone, .i($0), .on]] = 1
        self[[.velo, .range, .i($0)]] = 0
        self[[.velo, .pt, .i($0)]] = 64
        self[[.velo, .fade, .i($0)]] = 0
        self[[.tone, .i($0), .key, .lo]] = 0
        self[[.tone, .i($0), .key, .hi]] = 127
      }

    }
    
    private static let _params: SynthPathParam = {
      var p = SynthPathParam()
      
      p[[.level]] = RangeParam(byte: 0x10, maxVal: 100)
      p[[.pan]] = RangeParam(byte: 0x11, maxVal: 100, displayOffset: -50)
      p[[.analogFeel]] = RangeParam(byte: 0x12, maxVal: 100)
      p[[.priority]] = OptionsParam(byte: 0x13, options: ["Last", "Loudest"])
      p[[.bend, .down]] = RangeParam(byte: 0x14, maxVal: 48)
      p[[.bend, .up]] = RangeParam(byte: 0x15, maxVal: 12)
      p[[.ctrl, .src, .i(0)]] = OptionsParam(byte: 0x16, options: ctrlSrcOptions)
      p[[.ctrl, .src, .i(1)]] = OptionsParam(byte: 0x17, options: ctrlSrcOptions)
      p[[.tone, .i(0), .on]] = RangeParam(byte: 0x18, bit: 0)
      p[[.tone, .i(1), .on]] = RangeParam(byte: 0x18, bit: 1)
      p[[.tone, .i(2), .on]] = RangeParam(byte: 0x18, bit: 2)
      p[[.tone, .i(3), .on]] = RangeParam(byte: 0x18, bit: 3)
      p[[.tone, .i(0), .active]] = RangeParam(byte: 0x19, bit: 0)
      p[[.tone, .i(1), .active]] = RangeParam(byte: 0x19, bit: 1)
      p[[.tone, .i(2), .active]] = RangeParam(byte: 0x19, bit: 2)
      p[[.tone, .i(3), .active]] = RangeParam(byte: 0x19, bit: 3)
      p[[.porta]] = RangeParam(byte: 0x1a, maxVal: 1)
      p[[.porta, .mode]] = OptionsParam(byte: 0x1b, options: JD800CommonPatch.portaModeOptions)
      p[[.porta, .type]] = OptionsParam(byte: 0x1c, options: ["Time", "Rate"])
      p[[.porta, .time]] = RangeParam(byte: 0x1d, maxVal: 100)
      p[[.solo]] = RangeParam(byte: 0x1e, maxVal: 1)
      p[[.solo, .legato]] = RangeParam(byte: 0x1f, maxVal: 1)
      p[[.solo, .sync]] = OptionsParam(byte: 0x20, options: ["Off", "A", "B", "C", "D"])
      p[[.lo, .freq]] = OptionsParam(byte: 0x21, options: JD800CommonPatch.loFreqOptions)
      p[[.lo, .gain]] = RangeParam(byte: 0x22, maxVal: 30, displayOffset: -15)
      p[[.mid, .freq]] = OptionsParam(byte: 0x23, options: JD800CommonPatch.midFreqOptions)
      p[[.mid, .q]] = OptionsParam(byte: 0x24, options: JD800CommonPatch.midQOptions)
      p[[.mid, .gain]] = RangeParam(byte: 0x25, maxVal: 30, displayOffset: -15)
      p[[.hi, .freq]] = OptionsParam(byte: 0x26, options:JD800CommonPatch.hiFreqOptions)
      p[[.hi, .gain]] = RangeParam(byte: 0x27, maxVal: 30, displayOffset: -15)
      p[[.structure, .i(0)]] = RangeParam(byte: 0x28, maxVal: 5)
      p[[.structure, .i(1)]] = RangeParam(byte: 0x29, maxVal: 5)
      (0..<4).forEach {
        p[[.tone, .i($0), .key, .lo]] = MisoParam.make(byte: 0x2a + $0, iso: keyRangeIso)
        p[[.tone, .i($0), .key, .hi]] = MisoParam.make(byte: 0x2e + $0, iso: keyRangeIso)
        p[[.velo, .range, .i($0)]] = OptionsParam(byte: 0x32 + $0, options: ["All", "Low", "High"])
        p[[.velo, .pt, .i($0)]] = RangeParam(byte: 0x36 + $0, range: 1...127)
        p[[.velo, .fade, .i($0)]] = RangeParam(byte: 0x3a + $0)
      }

      p[[.fx, .i(1), .balance]] = RangeParam(byte: 0x3e, maxVal: 100)
      p[[.fx, .ctrl, .src, .i(0)]] = OptionsParam(byte: 0x3f, options: ctrlSrcOptions)
      p[[.fx, .ctrl, .dest, .i(0)]] = OptionsParam(byte: 0x40, options: ctrlDestOptions)
      p[[.fx, .ctrl, .depth, .i(0)]] = RangeParam(byte: 0x41, maxVal: 100, displayOffset: -50)
      p[[.fx, .ctrl, .src, .i(1)]] = OptionsParam(byte: 0x42, options: ctrlSrcOptions)
      p[[.fx, .ctrl, .dest, .i(1)]] = OptionsParam(byte: 0x43, options: ctrlDestOptions)
      p[[.fx, .ctrl, .depth, .i(1)]] = RangeParam(byte: 0x44, maxVal: 100, displayOffset: -50)
      p[[.fx, .i(0), .seq]] = OptionsParam(byte: 0x45, options: JD800FXPatch.fxBlockASeqOptions)
      p[[.fx, .i(0), .part, .i(0), .on]] = RangeParam(byte: 0x46, maxVal: 1)
      p[[.fx, .i(0), .part, .i(1), .on]] = RangeParam(byte: 0x47, maxVal: 1)
      p[[.fx, .i(0), .part, .i(2), .on]] = RangeParam(byte: 0x48, maxVal: 1)
      p[[.fx, .i(0), .part, .i(3), .on]] = RangeParam(byte: 0x49, maxVal: 1)
      p[[.dist, .type]] = OptionsParam(byte: 0x4a, options: JD800FXPatch.distTypeOptions)
      p[[.dist, .drive]] = RangeParam(byte: 0x4b, maxVal: 100)
      p[[.dist, .level]] = RangeParam(byte: 0x4c, maxVal: 100)
      p[[.phase, .freq]] = MisoParam.make(byte: 0x4d, maxVal: 99, iso: phaseFreqIso)
      p[[.phase, .rate]] = MisoParam.make(byte: 0x4e, maxVal: 99, iso: chorusRateMiso)
      p[[.phase, .depth]] = RangeParam(byte: 0x4f, maxVal: 100)
      p[[.phase, .reson]] = RangeParam(byte: 0x50, maxVal: 100)
      p[[.phase, .mix]] = RangeParam(byte: 0x51, maxVal: 100)
      (0..<6).forEach {
        p[[.spectral, .i($0)]] = RangeParam(byte: 0x52 + $0, maxVal: 30, displayOffset: -15)
      }
      p[[.spectral, .skirt]] = RangeParam(byte: 0x58, maxVal: 4, displayOffset: 1)
      p[[.extra, .sens]] = RangeParam(byte: 0x59, maxVal: 100)
      p[[.extra, .mix]] = RangeParam(byte: 0x5a, maxVal: 100)
      p[[.fx, .i(1), .seq]] = OptionsParam(byte: 0x5b, options: JD800FXPatch.fxBlockBSeqOptions)
      p[[.fx, .i(1), .part, .i(0), .on]] = RangeParam(byte: 0x5c, maxVal: 1)
      p[[.fx, .i(1), .part, .i(1), .on]] = RangeParam(byte: 0x5d, maxVal: 1)
      p[[.fx, .i(1), .part, .i(2), .on]] = RangeParam(byte: 0x5e, maxVal: 1)
      p[[.chorus, .rate]] = MisoParam.make(byte: 0x5f, maxVal: 99, iso: chorusRateMiso)
      p[[.chorus, .depth]] = RangeParam(byte: 0x60, maxVal: 100)
      p[[.chorus, .delay]] = MisoParam.make(byte: 0x61, maxVal: 99, iso: chorusDelayIso)
      p[[.chorus, .feedback]] = MisoParam.make(byte: 0x62, maxVal: 98, iso: feedBackIso)
      p[[.chorus, .level]] = RangeParam(byte: 0x63, maxVal: 100)
      p[[.delay, .mode]] = OptionsParam(byte: 0x64, options: delayModeOptions)
      p[[.delay, .mid, .time]] = MisoParam.make(parm: 2, byte: 0x65, maxVal: 255, iso: delayTimeIso)
      p[[.delay, .mid, .level]] = RangeParam(byte: 0x67, maxVal: 100)
      p[[.delay, .left, .time]] = MisoParam.make(parm: 2, byte: 0x68, maxVal: 255, iso: delayTimeIso)
      p[[.delay, .left, .level]] = RangeParam(byte: 0x6a, maxVal: 100)
      p[[.delay, .right, .time]] = MisoParam.make(parm: 2, byte: 0x6b, maxVal: 255, iso: delayTimeIso)
      p[[.delay, .right, .level]] = RangeParam(byte: 0x6d, maxVal: 100)
      p[[.delay, .feedback]] = MisoParam.make(byte: 0x6e, maxVal: 98, iso: feedBackIso)
      p[[.reverb, .type]] = OptionsParam(byte: 0x6f, options: JD800FXPatch.reverbTypeOptions)
      p[[.reverb, .pre]] = RangeParam(byte: 0x70, maxVal: 120)
      p[[.reverb, .early]] = RangeParam(byte: 0x71, maxVal: 100)
      p[[.reverb, .hi, .cutoff]] = OptionsParam(byte: 0x72, options: JD800FXPatch.reverbHiCutoffOptions)
      p[[.reverb, .time]] = MisoParam.make(byte: 0x73, maxVal: 100, iso: reverbTimeIso)
      p[[.reverb, .level]] = RangeParam(byte: 0x74, maxVal: 100)
      p[[.octave]] = OptionsParam(byte: 0x75, options: ["-1", "0", "+1"])

      return p
    }()
    
    class var params: SynthPathParam { return _params }
  
  static let keyRangeIso = Miso.noteName(zeroNote: "C-1")
  
  static let ctrlSrcOptions = OptionsParam.makeOptions(["Mod", "After", "Exp", "Breath", "P Bend", "Foot"])
  
  static let ctrlDestOptions = OptionsParam.makeOptions(["FX Bal", "Ds Drv", "Ph Man", "Ph Rat", "Ph Res", "Ph Mix", "En Mix", "Ch Rat", "Ch Fdb", "Ch Lvl", "Dl Fdb", "Dl Lvl", "Rv Tim", "Rv Lvl"])
  
  static let phaseFreqIso = Miso.switcher([
    .range(0...25, Miso.m(10.0000000282265) >>> Miso.a(49.9999997692986)),
    .range(26...49, Miso.m(29.9999999865915) >>> Miso.a(-459.999999813094)),
    .range(50...85, Miso.m(199.999999966054) >>> Miso.a(-8899.99999766912)),
    .range(86...99, Miso.m(499.999999906003) >>> Miso.a(-34499.9999910922)),
  ]) >>> Miso.hzKhz(round: 1)
  
  static let chorusRateMiso = Miso.a(1) >>> Miso.m(0.1) >>> Miso.round(1) >>> Miso.unitFormat("Hz")
  
  static let chorusDelayIso = Miso.switcher([
    .range(0...49, Miso.m(0.100000047696406) >>> Miso.a(0.0999992368571603)),
    .range(50...58, Miso.m(0.500000509605718) >>> Miso.a(-19.5000313438840)),
    .range(59...99, Miso.m(0.999999950677264) >>> Miso.a(-48.9999957582447)),
  ]) >>> Miso.round(1) >>> Miso.unitFormat("ms")

  static let delayModeOptions = OptionsParam.makeOptions(["Normal", "MIDI Tempo", "Manual Tempo"])
  
  static let delayTimeIso = Miso.switcher([
    .int(246, "16th"),
    .int(247, "trip 8th"),
    .int(248, "8th"),
    .int(249, "trip 1/4"),
    .int(250, "dot 8th"),
    .int(251, "1/4"),
    .int(252, "trip 1/2"),
    .int(253, "dot 1/4"),
    .int(254, "1/2"),
    .int(255, "1/1"),
  ], default: Miso.switcher([
    .range(0...49, Miso.m(0.100000440891873) >>> Miso.a(0.0999929456811404)),
    .range(50...59, Miso.m(0.500019596432311) >>> Miso.a(-19.5010737172579)),
    .range(60...89, Miso.m(1.00000080721755) >>> Miso.a(-49.0000649504459)),
    .range(90...104, Miso.m(9.99999969893828) >>> Miso.a(-849.999969616484)),
    .range(105...245, Miso.m(20.0000000010745) >>> Miso.a(-1900.00000021346)),
  ]) >>> Miso.msSec(round: 2))
  
  static let feedBackIso = Miso.a(-49) >>> Miso.m(2) >>> Miso.unitFormat("%")
    
  static let reverbTimeIso = Miso.switcher([
    .range(0...79, Miso.m(0.100000008277927) >>> Miso.a(0.0999997847738637)),
    .range(80...95, Miso.m(0.500000533235464) >>> Miso.a(-31.5000463392955)),
    .range(96...99, Miso.m(1.00000702039767) >>> Miso.a(-79.0006879990425)),
  ]) >>> Miso.round(1) >>> Miso.unitFormat("s")
}

class JD990TonePatch : JD990Patch {
  
  static let size: RolandAddress = 0x5c
  static let initFileName = "jd990-tone-init"
  
  class func startAddress(_ path: SynthPath?) -> RolandAddress {
    let index = path?.endex ?? 0
    return RolandAddress([0x20 + UInt8(0x02 * index), 0x00])
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()

    self[[.wave, .group]] = 0
    self[[.level]] = (80...100).random()!
    self[[.bias, .level]] = 10
    self[[.amp, .env, .time, .i(0)]] = (0...50).random()!
    self[[.tone, .delay, .mode]] = 0
    self[[.tone, .delay, .time]] = 0
    self[[.pitch, .keyTrk]] = (10...14).random()!
    self[[.pitch, .coarse]] = 48
    self[[.pitch, .fine]] = 50
    self[[.pitch, .random]] = 0

//    self[[.wave, .number, .i(0)]] = (1...651).random()!
  }
  
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.wave, .group]] = OptionsParam(byte: 0x00, options: ["Int", "Card", "Exp"])
    p[[.wave, .number]] = OptionsParam(parm: 2, byte: 0x01, options: waveOptions)
    p[[.fxm, .color]] = RangeParam(byte: 0x03, maxVal: 7, displayOffset: 1)
    p[[.fxm, .depth]] = RangeParam(byte: 0x04, maxVal: 100)
    p[[.sync, .on]] = RangeParam(byte: 0x05, maxVal: 1)
    p[[.tone, .delay, .mode]] = OptionsParam(byte: 0x06, options: ["Normal", "Hold", "K-Off N", "K-Off D", "Playmate"])
    p[[.tone, .delay, .time]] = RangeParam(byte: 0x07, maxVal: 127, formatter: toneDelayTimeFrmt)
    p[[.pitch, .coarse]] = RangeParam(byte: 0x08, maxVal: 96, displayOffset: -48)
    p[[.pitch, .fine]] = RangeParam(byte: 0x09, maxVal: 100, displayOffset: -50)
    p[[.pitch, .random]] = RangeParam(byte: 0x0a, maxVal: 100)
    p[[.pitch, .keyTrk]] = OptionsParam(byte: 0x0b, options: ["-100", "-50", "-20", "-10", "-5", "0", "5", "10", "20", "50", "98", "99", "100", "101", "102", "150", "200"])
    p[[.pitch, .env, .depth]] = RangeParam(byte: 0x0c, maxVal: 24, displayOffset: -12)
    p[[.bend, .on]] = RangeParam(byte: 0x0d, maxVal: 1)
    p[[.pitch, .env, .velo]] = RangeParam(byte: 0x0e, maxVal: 100, displayOffset: -50)
    p[[.pitch, .env, .time, .velo]] = RangeParam(byte: 0x0f, maxVal: 100, displayOffset: -50)
    p[[.pitch, .env, .time, .keyTrk]] = RangeParam(byte: 0x10, maxVal: 20, displayOffset: -10)
    p[[.pitch, .env, .level, .i(-1)]] = RangeParam(byte: 0x11, maxVal: 100, displayOffset: -50)
    p[[.pitch, .env, .time, .i(0)]] = RangeParam(byte: 0x12, maxVal: 100)
    p[[.pitch, .env, .level, .i(0)]] = RangeParam(byte: 0x13, maxVal: 100, displayOffset: -50)
    p[[.pitch, .env, .time, .i(1)]] = RangeParam(byte: 0x14, maxVal: 100)
    p[[.pitch, .env, .level, .i(1)]] = RangeParam(byte: 0x15, maxVal: 100, displayOffset: -50)
    p[[.pitch, .env, .time, .i(2)]] = RangeParam(byte: 0x16, maxVal: 100)
    p[[.pitch, .env, .level, .i(2)]] = RangeParam(byte: 0x17, maxVal: 100, displayOffset: -50)
    p[[.filter, .type]] = OptionsParam(byte: 0x18, options: ["HPF", "BPF", "LPF"])
    p[[.cutoff]] = RangeParam(byte: 0x19, maxVal: 100)
    p[[.reson]] = RangeParam(byte: 0x1a, maxVal: 100)
    p[[.cutoff, .keyTrk]] = RangeParam(byte: 0x1b, formatter: cutoffKeyTrkFrmt)
    p[[.filter, .env, .depth]] = RangeParam(byte: 0x1c, maxVal: 100, displayOffset: -50)
    p[[.filter, .env, .velo]] = RangeParam(byte: 0x1d, maxVal: 100, displayOffset: -50)
    p[[.filter, .env, .time, .velo]] = RangeParam(byte: 0x1e, maxVal: 100, displayOffset: -50)
    p[[.filter, .env, .time, .keyTrk]] = RangeParam(byte: 0x1f, maxVal: 20, displayOffset: -10)
    p[[.filter, .env, .time, .i(0)]] = RangeParam(byte: 0x20, maxVal: 100)
    p[[.filter, .env, .level, .i(0)]] = RangeParam(byte: 0x21, maxVal: 100)
    p[[.filter, .env, .time, .i(1)]] = RangeParam(byte: 0x22, maxVal: 100)
    p[[.filter, .env, .level, .i(1)]] = RangeParam(byte: 0x23, maxVal: 100)
    p[[.filter, .env, .time, .i(2)]] = RangeParam(byte: 0x24, maxVal: 100)
    p[[.filter, .env, .level, .i(2)]] = RangeParam(byte: 0x25, maxVal: 100)
    p[[.filter, .env, .time, .i(3)]] = RangeParam(byte: 0x26, maxVal: 100)
    p[[.filter, .env, .level, .i(3)]] = RangeParam(byte: 0x27, maxVal: 100)
    p[[.level]] = RangeParam(byte: 0x28, maxVal: 100)
    p[[.bias, .direction]] = OptionsParam(byte: 0x29, options: ["Upper", "Lower", "Up & Low"])
    p[[.bias, .pt]] = RangeParam(byte: 0x2a)
    p[[.bias, .level]] = RangeParam(byte: 0x2b, maxVal: 20, displayOffset: -10)
    p[[.pan]] = RangeParam(byte: 0x2c, maxVal: 103, formatter: {
      switch $0 {
      case 101: return "Rnd"
      case 102: return "Alt-L"
      case 103: return "Alt-R"
      default:
        return "\($0-50)"
      }
    })
    p[[.pan, .keyTrk]] = OptionsParam(byte: 0x2d, options: ["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"])
    p[[.amp, .env, .velo]] = RangeParam(byte: 0x2e, maxVal: 100, displayOffset: -50)
    p[[.amp, .env, .time, .velo]] = RangeParam(byte: 0x2f, maxVal: 100, displayOffset: -50)
    p[[.amp, .env, .time, .keyTrk]] = RangeParam(byte: 0x30, maxVal: 20, displayOffset: -10)
    p[[.amp, .env, .time, .i(0)]] = RangeParam(byte: 0x31, maxVal: 100)
    p[[.amp, .env, .level, .i(0)]] = RangeParam(byte: 0x32, maxVal: 100)
    p[[.amp, .env, .time, .i(1)]] = RangeParam(byte: 0x33, maxVal: 100)
    p[[.amp, .env, .level, .i(1)]] = RangeParam(byte: 0x34, maxVal: 100)
    p[[.amp, .env, .time, .i(2)]] = RangeParam(byte: 0x35, maxVal: 100)
    p[[.amp, .env, .level, .i(2)]] = RangeParam(byte: 0x36, maxVal: 100)
    p[[.amp, .env, .time, .i(3)]] = RangeParam(byte: 0x37, maxVal: 100)
    p[[.velo, .curve]] = RangeParam(byte: 0x38, maxVal: 6, displayOffset: 1)
    p[[.hold, .ctrl]] = RangeParam(byte: 0x39, maxVal: 1)
    (0..<2).forEach { lfo in
      let off = lfo * 9
      p[[.lfo, .i(lfo), .wave]] = OptionsParam(byte: 0x3a + off, options: ["Tri", "Sin", "Saw", "Squ", "Trp", "S&H", "Rnd", "CHS"])
      p[[.lfo, .i(lfo), .rate]] = RangeParam(byte: 0x3b + off, maxVal: 100)
      p[[.lfo, .i(lfo), .delay]] = RangeParam(byte: 0x3c + off, maxVal: 101, formatter: {
        return $0 == 101 ? "Rel" : "\($0)"
      })
      p[[.lfo, .i(lfo), .fade]] = RangeParam(byte: 0x3d + off, maxVal: 100, displayOffset: -50)
      p[[.lfo, .i(lfo), .offset]] = OptionsParam(byte: 0x3e + off, options: ["+", "0", "-"])
      p[[.lfo, .i(lfo), .key, .trigger]] = RangeParam(byte: 0x3f + off, maxVal: 1)
      p[[.lfo, .i(lfo), .pitch]] = RangeParam(byte: 0x40 + off, maxVal: 100, displayOffset: -50)
      p[[.lfo, .i(lfo), .filter]] = RangeParam(byte: 0x41 + off, maxVal: 100, displayOffset: -50)
      p[[.lfo, .i(lfo), .amp]] = RangeParam(byte: 0x42 + off, maxVal: 100, displayOffset: -50)
    }
    (0..<2).forEach { ctrl in
      (0..<4).forEach { dest in
        let off = ctrl * 8 + dest * 2
        p[[.ctrl, .i(ctrl), .dest, .i(dest)]] = OptionsParam(byte: 0x4c + off, options: ctrlDestOptions)
        p[[.ctrl, .i(ctrl), .depth, .i(dest)]] = RangeParam(byte: 0x4d + off, maxVal: 100, displayOffset: -50)
      }
    }

    return p
  }()
  class var params: SynthPathParam { return _params }
  
  static let waveOptions = OptionsParam.makeOptions(["Syn Saw 1", "Syn Saw 2", "FAT Saw", "FAT Square", "Syn Pulse 1", "Syn Pulse2", "Syn Pulse3", "Syn Pulse4", "Syn Pulse5", "Pulse Mod", "Triangle", "Syn Sine", "Soft Pad", "Wire Str", "MIDI Clav", "Spark Vox1", "Spark Vox2", "Syn Sax", "Clav Wave", "Cello Wave", "Bright Digi", "Cutters", "Syn Bass", "Rad Hose", "Vocal Wave", "Wally Wave", "Brusky Ip", "Digiwave", "Can Wave 1", "Can Wave 2", "EML 5th", "Wave Scan", "Nasty ", "Wave Table", "Fine Wine", "Funk Bass 1", "Funk Bass 2", "Strat Sust", "Harp Harm", "Full Organ", "Full Draw", "Doo", "Zzz Vox", "Org Vox", "Male Vox", "Kalimba", "Xylo", "Marim Wave", "Log Drum", "AgogoBells", "Bottle Hit", "Gamelan 1", "Gamelan 2", "Gamelan 3", "Tabla", "Pole lp", "Pluck Harp", "Nylon Str", "Hooky", "Muters", "Klack Wave", "Crystal", "Digi Bell", "FingerBell", "Digi Chime", "Bell Wave", "Org Bell", "Scrape Gut", "Strat Atk", "Hellow Bs", "Piano Atk", "EP Hard", "Clear Keys", "EP Distone", "Flute Push", "Shami", "Wood Crak", "Kimba Atk", "Block", "Org Atk 1", "Org Atk 2", "Cowbell", "Sm Metal", "StrikePole", "Pizz", "Switch", "Tuba Slap", "Plink", "Plunk", "EP Atk", "TVF Trig", "Flute Tone", "Pan Pipe", "Bottle Blow", "Shaku Atk", "FlugelWave", "French", "White Noise", "Pink Noise", "Pitch Wind", "Vox Noise 1", "Vox Noise2", "Crunch Wind", "ThroatWind", "Metal Wind", "Windago", "Anklungs", "Wind Chime 1", "Ac Piano 1", "SA Rhodes 1", "SA Rhodes 2", "E.Piano 1", "E.Piano 2", "Clav 1", "Organ 1", "Jazz Organ", "Pipe Organ", "Nylon GTR", "6STR GTR", "GTR HARM", "Mute GTR 1", "Pop Strat", "Stratus", "SYN GTR", "Harp 1", "Pick Bass", "E.Bass", "Fretless 1", "Upright BS", "Slap Bass 1", "Slap & Pop", "Slap Bass 2", "Slap Bass 3", "Flute 1", "Trumpet 1", "Trombone 1", "Harmon Mute 1", "Alto Sax 1", "Tenor Sax 1", "Blow Pipe", "Trumpet SECT", "Strings", "SYN VOX 1", "SYN VOX 2", "Org Vox 2", "Pop Voice", "Fantasynth", "Fanta Bell", "Vibes", "Steel Drums", "MMM VOX", "Lead Wave", "Feedbackwave", "Rattles", "Tin Wave", "Spectrum 1", "Solid Kick", "Room Kick", "808 K", "Long Hard SN", "808 SN", "90's SN", "Bigshot SN", "Power SN", "Power Tom", "Closed HH1", "Closed HH2", "Open HH", "Crash Cym", "Ride Cym", "808 Claps", "Maraca", "Cabasa Up", "Cabasa Down", "Slap Cga", "Mute Cga 1", "Mute Cga 2", "Hi Conga", "Lo Conga", "Snaps", "Tambourine", "Cowbell 2", "Saw +DC", "Sqr +DC", "Pulse 1 +DC", "Pulse2 +DC", "Pulse3 +DC", "Pulse4 +DC", "Pulse5 +DC", "Triangle +DC", "Sine +DC", "Loop 1", "Loop 2", "Loop 3", "Loop 4"])
  
  static let toneDelayTimeFrmt: ParamValueFormatter = {
    return "\($0)"
  }
  
  static let cutoffKeyTrkFrmt: ParamValueFormatter = {
    return "\($0)"
  }
  
  static let ctrlDestOptions = OptionsParam.makeOptions(["Pitch", "Cutoff", "Reson", "Level", "P-LFO1", "P-LFO2", "F-LFO1", "F-LFO2", "A-LFO1", "A-LFO2", "LFO1-R", "LFO2-R"])
}
