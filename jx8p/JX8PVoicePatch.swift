
class JX8PVoicePatch : ByteBackedSysexPatch, VoicePatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = JX8PVoiceBank.self

  // not used
  static func location(forData data: Data) -> Int { 0 }

  // 67 bytes - 3.1 All Params with Tone Name // transmitted when patch change on synth
  // 77 bytes - apparently what the synth sends. patch param set to memory location, followed by tone.
  // 78 bytes : found online. tone, then msg to save to memory
  // 89 bytes : tone, then patch params (without bank and tone #)
    
  static let fileDataCount = 77
  static let nameByteRange = 0..<10
  // TODO: need actual init file
  static let initFileName = "jx8p-voice-init"

  var bytes: [UInt8]

  static func isValid(fileSize: Int) -> Bool { [67,77,78,89].contains(fileSize) }

  required init(data: Data) {
    let sysex = SysexData(data: data)
    bytes = [UInt8](repeating: 0, count: 66)
    // TODO: Init the Patch part with good data (in case it isn't there)
    sysex.forEach { msg in
      switch msg.count {
      case 67:
        (0..<59).forEach { bytes[$0] = msg[$0 + 7] }
      case 22:
        (0..<7).forEach { bytes[$0 + 59] = msg[$0 + 7]}
      default:
        break
      }
    }
  }
  
  func nameSetFilter(_ n: String) -> String { n.uppercased() }

  
  func fileData() -> Data { sysexData(channel: 0) }
  
  func toneData(channel: Int) -> Data { Data([0xf0, 0x41, 0x35, UInt8(channel), 0x21, 0x20, 0x01] + bytes[0..<59] + [0xf7]) }
  
  func sysexData(channel: Int) -> Data {
    // the tone
    var data = toneData(channel: channel)
    // the patch
    data.append(contentsOf: [0xf0, 0x41, 0x36, UInt8(channel), 0x21, 0x30, 0x01])
    (0..<7).forEach {
      data.append(UInt8($0))
      data.append(bytes[$0 + 59])
    }
    data.append(0xf7)
    return data
  }
  
  func writeData(channel: Int, location: Int) -> [Data] {
    [
      toneData(channel: channel),
      Data([0xf0, 0x41, 0x34, UInt8(channel), 0x21, 0x20, 0x01, 0x00, UInt8(location), 0x02, 0xf7]),
    ]
  }

  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      guard let v = unpack(param: param) else { return nil }
      switch path {
      case [.osc, .i(0), .range],
           [.osc, .i(0), .wave],
           [.osc, .i(1), .range],
           [.osc, .i(1), .wave],
           [.osc, .mod],
           [.pitch, .velo],
           [.pitch, .env, .mode],
           [.osc, .i(1), .amp, .velo],
           [.osc, .i(1), .amp, .env, .mode],
           [.hi, .cutoff],
           [.filter, .velo],
           [.filter, .env, .mode],
           [.amp, .velo],
           [.env, .i(0), .keyTrk],
           [.env, .i(1), .keyTrk]:
        return (v / 32) * 32 // map to 0/32/64/96
      case [.chorus],
           [.lfo, .wave]:
        return min((v / 32) * 32, 64) // map to 0/32/64
      case [.amp, .env, .mode]:
        return (v / 64) * 64 // map to 0/64
      // ... PATCH
      case [.patch, .bend]:
        return (v / 32) * 32 // map to 0/32/64/96
      case [.patch, .porta]:
        return (v / 64) * 64 // map to 0/64
      default:
        return v
      }
    }
    set { // standard setter
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      pack(value: newValue, forParam: param)
    }
  }
  
  static let params : SynthPathParam = {
    var p = SynthPathParam()

    p[[.osc, .i(0), .range]] = OptionsParam(byte: 11, options: oscRangeOptions)
    p[[.osc, .i(0), .wave]] = OptionsParam(byte: 12, options: oscWaveOptions)
    p[[.osc, .i(0), .tune]] = RangeParam(byte: 13, mapper: mapper12)
    p[[.osc, .i(0), .lfo, .depth]] = RangeParam(byte: 14, mapper: mapper99)
    p[[.osc, .i(0), .env, .depth]] = RangeParam(byte: 15, mapper: mapper99)
    p[[.osc, .i(1), .range]] = OptionsParam(byte: 16, options: oscRangeOptions)
    p[[.osc, .i(1), .wave]] = OptionsParam(byte: 17, options: oscWaveOptions)
    p[[.osc, .mod]] = OptionsParam(byte: 18, options: oscModOptions)
    p[[.osc, .i(1), .tune]] = RangeParam(byte: 19, mapper: mapper12)
    p[[.osc, .i(1), .fine]] = RangeParam(byte: 20, mapper: mapper50)
    p[[.osc, .i(1), .lfo, .depth]] = RangeParam(byte: 21, mapper: mapper99)
    p[[.osc, .i(1), .env, .depth]] = RangeParam(byte: 22, mapper: mapper99)
    p[[.pitch, .velo]] = OptionsParam(byte: 26, options: dynOptions)
    p[[.pitch, .env, .mode]] = OptionsParam(byte: 27, options: envModeOptions)
    p[[.osc, .i(0), .level]] = RangeParam(byte: 28, mapper: mapper99)
    p[[.osc, .i(1), .level]] = RangeParam(byte: 29, mapper: mapper99)
    p[[.osc, .i(1), .amp, .env, .depth]] = RangeParam(byte: 30, mapper: mapper99)
    p[[.osc, .i(1), .amp, .velo]] = OptionsParam(byte: 31, options: dynOptions)
    p[[.osc, .i(1), .amp, .env, .mode]] = OptionsParam(byte: 32, options: envModeOptions)
    p[[.hi, .cutoff]] = OptionsParam(byte: 33, options: hiPassOptions)
    p[[.cutoff]] = RangeParam(byte: 34, mapper: mapper99)
    p[[.reson]] = RangeParam(byte: 35, mapper: mapper99)
    p[[.filter, .lfo, .depth]] = RangeParam(byte: 36, mapper: mapper99)
    p[[.filter, .env, .depth]] = RangeParam(byte: 37, mapper: mapper99)
    p[[.filter, .keyTrk]] = RangeParam(byte: 38, mapper: mapper99)
    p[[.filter, .velo]] = OptionsParam(byte: 39, options: dynOptions)
    p[[.filter, .env, .mode]] = OptionsParam(byte: 40, options: envModeOptions)
    p[[.amp, .level]] = RangeParam(byte: 41, mapper: mapper99)
    p[[.amp, .velo]] = OptionsParam(byte: 42, options: dynOptions)
    p[[.chorus]] = OptionsParam(byte: 43, options: chorusOptions)
    p[[.lfo, .wave]] = OptionsParam(byte: 44, options: lfoWaveOptions)
    p[[.lfo, .delay]] = RangeParam(byte: 45, mapper: mapper99)
    p[[.lfo, .rate]] = RangeParam(byte: 46, mapper: mapper99)
    p[[.env, .i(0), .attack]] = RangeParam(byte: 47, mapper: mapper99)
    p[[.env, .i(0), .decay]] = RangeParam(byte: 48, mapper: mapper99)
    p[[.env, .i(0), .sustain]] = RangeParam(byte: 49, mapper: mapper99)
    p[[.env, .i(0), .release]] = RangeParam(byte: 50, mapper: mapper99)
    p[[.env, .i(0), .keyTrk]] = OptionsParam(byte: 51, options: dynOptions)
    p[[.env, .i(1), .attack]] = RangeParam(byte: 52, mapper: mapper99)
    p[[.env, .i(1), .decay]] = RangeParam(byte: 53, mapper: mapper99)
    p[[.env, .i(1), .sustain]] = RangeParam(byte: 54, mapper: mapper99)
    p[[.env, .i(1), .release]] = RangeParam(byte: 55, mapper: mapper99)
    p[[.env, .i(1), .keyTrk]] = OptionsParam(byte: 56, options: dynOptions)
    p[[.amp, .env, .mode]] = OptionsParam(byte: 58, options: ampEnvModeOptions)


    // PATCH params
    let patchOff = 59
    p[[.patch, .bend]] = OptionsParam(byte: patchOff + 0, options: bendOptions)
    p[[.patch, .porta, .time]] = RangeParam(byte: patchOff + 1) //, mapper: mapper99)
    p[[.patch, .porta]] = OptionsParam(byte: patchOff + 2, options: [0 : "Off", 64: "On"])
    p[[.patch, .assign, .mode]] = OptionsParam(byte: patchOff + 3, options: [
      0: "Poly 1",
      1: "Unison 1",
      2: "Solo 1",
      4: "Poly 2",
      5: "Unison 2",
      6: "Solo 2"])
    p[[.patch, .aftertouch]] = OptionsParam(byte: patchOff + 4, options: aftertouchOptions)
    p[[.patch, .bend, .lfo]] = RangeParam(byte: patchOff + 5) //, mapper: mapper99)
    p[[.patch, .unison, .detune]] = RangeParam(byte: patchOff + 6) //, mapper: mapper50)
    
    return p
  }()
  
  static func mapper(forArray arr: [Int]) -> ParamValueMapper {
    return (
      format: {
        return "\(arr[$0])"
      },
      parse: {
        let i = Int($0) ?? 0
        return arr.firstIndex(of: i) ?? 0
      }
    )
  }

  static let map99Values = [0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 10, 10, 11, 12, 13, 14, 14, 15, 16, 17, 17, 18, 19, 20, 20, 21, 22, 23, 24, 24, 25, 26, 27, 28, 28, 29, 30, 31, 31, 32, 33, 34, 35, 35, 36, 37, 38, 39, 39, 40, 41, 42, 43, 43, 44, 45, 46, 46, 47, 48, 49, 49, 50, 51, 52, 53, 53, 54, 55, 56, 56, 57, 58, 59, 60, 60, 61, 62, 63, 63, 64, 65, 66, 67, 67, 68, 69, 70, 71, 71, 72, 73, 74, 74, 75, 76, 77, 77, 78, 79, 80, 80, 81, 82, 83, 84, 84, 85, 86, 87, 88, 88, 89, 90, 91, 91, 92, 92, 93, 94, 95, 96, 96, 97, 98, 99]
  static let mapper99 = mapper(forArray: map99Values)
  
  static let map12Values = [-12, -12, -12, -12, -12, -12, -12, -12, -11, -11, -11, -11, -10, -10, -10, -10, -9, -9, -9, -9, -8, -8, -8, -8, -7, -7, -7, -7, -7, -7, -7, -7, -6, -6, -6, -6, -5, -5, -5, -5, -4, -4, -4, -4, -3, -3, -3, -3, -2, -2, -2, -2, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12]
  static let mapper12 = mapper(forArray: map12Values)
  
  static let map50Values = [-50, -49, -48, -47, -46, -46, -45, -44, -43, -43, -42, -41, -40, -39, -39, -38, -37, -36, -35, -35, -34, -33, -32, -31, -31, -30, -29, -28, -28, -27, -26, -25, -24, -24, -23, -22, -21, -20, -20, -19, -18, -17, -17, -16, -15, -14, -14, -13, -12, -11, -10, -10, -9, -8, -7, -6, -6, -5, -4, -3, -3, -2, -1, 0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 10, 10, 11, 12, 13, 14, 14, 15, 16, 17, 17, 18, 19, 20, 20, 21, 22, 23, 24, 24, 25, 26, 27, 28, 28, 29, 30, 31, 31, 32, 33, 34, 35, 35, 36, 37, 38, 39, 39, 40, 41, 42, 43, 43, 44, 45, 46, 46, 47, 48, 49, 50]
  static let mapper50 = mapper(forArray: map50Values)

  static func fourOptions(_ opts: [String]) -> [Int:String] {
    var out = [Int:String]()
    (0..<4).forEach { out[$0 * 32] = opts[$0] }
    return out
  }
  
  static let oscRangeOptions = fourOptions(["16'", "8'", "4'", "2'"])
  
  static let oscWaveOptions = fourOptions(["Noise", "Square", "Pulse", "Saw"])

  static let oscModOptions = fourOptions(["Off", "Sync 1", "Sync 2", "X Mod"])

  static let dynOptions = fourOptions(["Off", "1", "2", "3"])

  static let envModeOptions = fourOptions(["Env 2 Invert", "Env 2 Normal", "Env 1 Invert", "Env 1 Normal"])

  static let hiPassOptions = fourOptions(["0", "1", "2", "3"])
  
  static let chorusOptions: [Int:String] = [
    0 : "Off",
    32 : "1",
    64 : "2",
  ]

  static let lfoWaveOptions: [Int:String] = [
    0 : "Random",
    32 : "Square",
    64 : "Sine",
  ]

  static let ampEnvModeOptions: [Int:String] = [
    0 : "Gate",
    64 : "Env 2 Normal",
  ]
  
  
  // PATCH
  
  static let bendOptions = fourOptions(["2", "3", "4", "7"])
    
  static let aftertouchOptions: [Int:String] = [
    0 : "Off",
    1 : "Vibrato",
    2 : "Brilliance",
    4 : "Volume",
  ]


}

