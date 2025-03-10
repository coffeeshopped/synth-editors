
class MicrokorgGlobalPatch : ByteBackedSysexPatch {
  
  static let fileDataCount = 235
  static let initFileName = "microkorg-global-init"

  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = data.unpack87(count: 200, inRange: 5..<234)
  }
  
  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      if let rangeParam = param as? ParamWithRange,
         rangeParam.range.lowerBound < 0 {
        return Int(Int8(bitPattern: bytes[param.byte]))
      }
      else {
        return unpack(param: param)
      }
    }
    set {
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      if let rangeParam = param as? ParamWithRange,
         rangeParam.range.lowerBound < 0 {
        bytes[param.byte] = UInt8(bitPattern: Int8(newValue))
      }
      else {
        pack(value: newValue, forParam: param)
      }
    }
  }
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, 0x51])
    data.append(Data.pack78(bytes: bytes, count: 229))
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }

  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.tune]] = RangeParam(byte: 0, range: -100...100, formatter: {
      "\(440 + CGFloat($0) / 10)"
    })
    p[[.transpose]] = RangeParam(byte: 1, range: -12...12)
    p[[.post]] = OptionsParam(byte: 2, bit: 0, options: ["Post KBD", "Pre TG"])
    p[[.velo]] = RangeParam(byte: 3, range: 1...127)
    p[[.velo, .curve]] = OptionsParam(byte: 4, options: ["1", "2", "3", "4", "5", "6", "7", "8", "Const"])
    p[[.local]] = RangeParam(byte: 5, bit: 2)
    p[[.protect]] = RangeParam(byte: 5, bit: 0)
    p[[.clock]] = OptionsParam(byte: 8, bits: 0...1, options: ["Int", "Ext", "Auto"])
    p[[.channel]] = RangeParam(byte: 9, bits: 0...3, maxVal: 15, displayOffset: 1)
    p[[.sync, .ctrl]] = RangeParam(byte: 10)
    p[[.timbre, .ctrl]] = RangeParam(byte: 11)
    p[[.sysex, .on]] = RangeParam(byte: 16, bit: 7)
    p[[.bend, .on]] = RangeParam(byte: 17, bit: 6)
    p[[.ctrl, .on]] = RangeParam(byte: 17, bit: 2)
    p[[.pgmChange, .on]] = RangeParam(byte: 17, bit: 0)

    // knob/switch map
    (0...40).forEach {
      // don't use i(0) bc the parms will be negative...
      p[[.ctrl, .i($0 + 1)]] = RangeParam(byte: 18 + $0)
    }

    // pgm change map

    
    return p
  }()
  
  class var params: SynthPathParam { return _params }
  
}
