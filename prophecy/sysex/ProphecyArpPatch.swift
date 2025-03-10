
class ProphecyArpPatch : ByteBackedSysexPatch, BankablePatch {
  
  static var bankType: SysexPatchBank.Type = ProphecyArpBank.self

  static let initFileName = "prophecy-arp-init"
  static let fileDataCount = 155
  static let nameByteRange = 0..<16

  var bytes: [UInt8]

  required init(data: Data) {
    bytes = data.unpack87(count: 128, inRange: 7..<154)
  }
  
  func unpack(param: Param) -> Int? {
    guard let p = param as? ParamWithRange,
          p.range.lowerBound < 0 else { return defaultUnpack(param: param) }
    
    // handle negative values
    guard let bits = p.bits else { return Int(Int8(bitPattern: bytes[p.byte])) }
    return bytes[p.byte].signedBits(bits)
  }

  func sysexData(channel: Int, program: Int) -> Data {
    var data = Data()
    data.append(contentsOf: Prophecy.sysexHeader(deviceId: UInt8(channel)) + [0x69, UInt8(program), 0x00])
    data.append(Data.pack78(bytes: bytes, count: 147))
    data.append(0xf7)
    return data
  }
    
  func fileData() -> Data {
    return sysexData(channel: 0, program: 0)
  }
    
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.step, .time]] = OptionsParam(parm: 18, byte: 17, options: ["4", "4T", "8", "8T", "16", "16T"])
    p[[.sortOrder]] = RangeParam(parm: 19, byte: 18, maxVal: 1)
    p[[.key, .lo]] = MisoParam.make(parm: 20, byte: 19, iso: keyIso)
    p[[.key, .hi]] = MisoParam.make(parm: 21, byte: 20, iso: keyIso)
    p[[.velo]] = MisoParam.make(parm: 22, byte: 21, range: 1...129, iso: veloIso)
    p[[.velo, .ctrl, .amt]] = RangeParam(parm: 24, byte: 23, range: -99...99)
    p[[.gate]] = MisoParam.make(parm: 25, byte: 24, maxVal: 101, iso: gateIso)
    p[[.gate, .ctrl, .amt]] = RangeParam(parm: 27, byte: 26, range: -99...99)
    p[[.type]] = OptionsParam(parm: 28, byte: 27, options: ["As Play", "As Play(Fill)", "Run Up", "Up&Down"])
    p[[.octave, .alt]] = OptionsParam(parm: 29, byte: 28, options: ["Up", "Down", "Up&Down"])
    (0..<24).forEach { i in
      let off = i * 4
      p[[.step, .i(i), .offset]] = RangeParam(parm: 33 + off, byte: 32 + off, range: -49...49)
      p[[.step, .i(i), .tone]] = MisoParam.make(parm: 34 + off, byte: 33 + off, range: 1...13, iso: toneIso)
      p[[.step, .i(i), .velo]] = RangeParam(parm: 35 + off, byte: 34 + off, range: 1...127)
      p[[.step, .i(i), .gate]] = MisoParam.make(parm: 36 + off, byte: 35 + off, maxVal: 100, iso: stepGateIso)
    }

    return p
  }()
  
  static let keyIso = Miso.noteName(zeroNote: "C-1")
  
  static let veloIso = Miso.switcher([
    .int(128, "Key"),
    .int(129, "Step"),
  ], default: Miso.str())
  
  static let gateIso = Miso.switcher([
    .int(101, "Step")
  ], default: Miso.unitFormat("%"))
  
  static let toneIso = Miso.switcher([
    .int(13, "Loop"),
  ], default: Miso.str())

  static let stepGateIso = Miso.switcher([
    .int(0, "Off"),
  ], default: Miso.unitFormat("%"))

}
