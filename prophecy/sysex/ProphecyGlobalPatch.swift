
class ProphecyGlobalPatch : ByteBackedSysexPatch, GlobalPatch {

  static let initFileName = "prophecy-global-init"
  static let fileDataCount = 663

  var bytes: [UInt8]
  var name = ""

  required init(data: Data) {
    bytes = data.unpack87(count: 574, inRange: 6..<662)
  }
    
  func unpack(param: Param) -> Int? {
    guard let p = param as? ParamWithRange,
          p.range.lowerBound < 0 else { return defaultUnpack(param: param) }
    
    // handle negative values
    guard let bits = p.bits else { return Int(Int8(bitPattern: bytes[p.byte])) }
    return bytes[p.byte].signedBits(bits)
  }

  func sysexData(channel: Int) -> Data {
    var data = Data()
    data.append(contentsOf: Prophecy.sysexHeader(deviceId: UInt8(channel)) + [0x51, 0x00])
    data.append(Data.pack78(bytes: bytes, count: 656))
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }
    
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.tune]] = MisoParam.make(parm: 1, byte: 0, range: -100...100, iso: Miso.m(0.1) >>> Miso.a(440) >>> Miso.round(1))
    p[[.transpose]] = RangeParam(parm: 2, byte: 1, range: -12...12)
    p[[.velo, .curve]] = RangeParam(parm: 3, byte: 2, maxVal: 7, displayOffset: 1)
    p[[.aftertouch, .curve]] = RangeParam(parm: 4, byte: 3, maxVal: 7, displayOffset: 1)
    p[[.aftertouch, .sens]] = RangeParam(parm: 5, byte: 4, maxVal: 99)
    p[[.z, .sens]] = RangeParam(parm: 6, byte: 5, maxVal: 99)
    p[[.foot, .pedal, .polarity]] = OptionsParam(parm: 7, byte: 6, bit: 0, options: ["+", "-"])
    p[[.foot, .mode, .polarity]] = OptionsParam(parm: 8, byte: 6, bit: 1, options: ["+", "-"])
    p[[.transpose, .mode]] = OptionsParam(parm: 9, byte: 6, bit: 2, options: ["Post Kbd", "Pre TG"])
    p[[.octave, .mode]] = OptionsParam(parm: 10, byte: 6, bit: 3, options: ["Latch", "Unlatch"])
    p[[.scene, .memory]] = RangeParam(parm: 11, byte: 6, bit: 4) // page memory
    p[[.hold]] = RangeParam(parm: 12, byte: 6, bit: 5) // 10's hold
    p[[.delay, .on]] = OptionsParam(parm: 13, byte: 6, bit: 6, options: ["On", "Bypass"])
    (0..<12).forEach { i in
      p[[.scale, .octave, .i(i)]] = RangeParam(parm: 14 + i, byte: 7 + i, range: -100...100)
    }
    (0..<128).forEach { i in
      p[[.scale, .key, .i(i)]] = RangeParam(parm: 26 + i, byte: 19 + i, range: -100...100)
    }
    p[[.memory, .protect]] = RangeParam(parm: 170, byte: 163, bit: 0)
    p[[.arp, .memory, .protect]] = RangeParam(parm: 171, byte: 163, bit: 1)
    (0..<5).forEach { i in
      p[[.knob, .i(i), .ctrl]] = OptionsParam(parm: 172 + i, byte: 164 + i, options: ProphecyVoicePatch.ctrlOptions)
    }
    p[[.velo, .ctrl]] = OptionsParam(parm: 177, byte: 169, options: arpCtrlOptions)
    p[[.gate, .ctrl]] = OptionsParam(parm: 178, byte: 170, options: arpCtrlOptions)
    (0..<5).forEach { i in
      p[[.extra, .i(i)]] = OptionsParam(parm: 179 + i, byte: 171 + i, options: ec5Options)
    }
    p[[.channel]] = RangeParam(parm: 184, byte: 176, maxVal: 15, displayOffset: 1)
    p[[.local]] = RangeParam(parm: 185, byte: 177, bit: 0)
    p[[.omni]] = RangeParam(parm: 186, byte: 177, bit: 1)
    p[[.clock, .src]] = OptionsParam(parm: 187, byte: 177, bit: 2, options: ["Int", "Ext"])
    p[[.sysex, .send]] = RangeParam(parm: 188, byte: 178, bit: 0)
    p[[.sysex, .rcv]] = RangeParam(parm: 189, byte: 178, bit: 1)
    p[[.pgm, .send]] = RangeParam(parm: 190, byte: 179, bit: 0)
    p[[.pgm, .rcv]] = RangeParam(parm: 191, byte: 179, bit: 1)
    (0..<3).forEach { i in
      let off = i * 2
      p[[.bank, .i(i), .hi]] = RangeParam(parm: 192 + off, byte: 181 + off)
      p[[.bank, .i(i), .lo]] = RangeParam(parm: 193 + off, byte: 180 + off)
      
      (0..<64).forEach { loc in
        let loff = i * 64 + loc
        p[[.bank, .i(i), .pgm, .i(loc)]] = RangeParam(parm: 198 + loff, byte: 186 + loff)
      }
    }
    p[[.bend, .send]] = RangeParam(parm: 390, byte: 378, bit: 0)
    p[[.bend, .rcv]] = OptionsParam(parm: 391, byte: 378, bits: 1...2, options: rcvOptions)
    p[[.bend, .thru]] = RangeParam(parm: 392, byte: 378, bit: 3)
    p[[.bend, .transpose]] = MisoParam.make(parm: 393, byte: 379, maxVal: 97, iso: translationIso)
    p[[.aftertouch, .send]] = RangeParam(parm: 394, byte: 380, bit: 0)
    p[[.aftertouch, .rcv]] = OptionsParam(parm: 395, byte: 380, bits: 1...2, options: rcvOptions)
    p[[.aftertouch, .thru]] = RangeParam(parm: 396, byte: 380, bit: 3)
    p[[.aftertouch, .transpose]] = MisoParam.make(parm: 397, byte: 381, maxVal: 97, iso: translationIso)
    (0..<96).forEach { i in
      let off = i * 4
      let boff = i * 2
      p[[.ctrl, .i(i), .send]] = RangeParam(parm: 398 + off, byte: 382 + boff, bit: 0)
      p[[.ctrl, .i(i), .rcv]] = OptionsParam(parm: 399 + off, byte: 382 + boff, bits: 1...2, options: rcvOptions)
      p[[.ctrl, .i(i), .thru]] = RangeParam(parm: 400 + off, byte: 382 + boff, bit: 3)
      p[[.ctrl, .i(i), .transpose]] = MisoParam.make(parm: 401 + off, byte: 383 + boff, maxVal: 97, iso: translationIso)
    }

    return p
  }()

  static let rcvOptions = OptionsParam.makeOptions(["Dis", "Ena", "Intp"])
  
  static let translationIso = Miso.switcher([
    .int(0, "PBend"),
    .int(1, "ATouch")
  ], default: Miso.a(-2) >>> Miso.str("CC%g"))
  
  static let ec5Options = OptionsParam.makeOptions(["Off", "Sustain", "Pgm Up", "Pgm Down", "Octave Up", "Octave Down", "Porta SW", "Dist SW", "Wah SW", "Delay SW", "Chorus SW", "Reverb SW", "Arp Off/On", "Wheel3 Hold"])
  
  static let arpCtrlOptions = OptionsParam.makeOptions({
    var opts = ["Off", "PBend", "After Touch", ]
    opts += (0...95).map { "CC\($0)" }
    return opts
  }())

}
