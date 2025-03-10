
class JD990GlobalPatch : JD990Patch, GlobalPatch {
  
  static let initFileName = "jd990-system-init"
  class var size: RolandAddress { return 0x26 }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x0000
  }
  
  var bytes: [UInt8]
  var name = ""
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.mode]] = OptionsParam(byte: 0x00, options: ["Patch", "Performance", "Rhythm"])
    p[[.tune]] = RangeParam(byte: 0x01, maxVal: 100, displayOffset: -50)
    p[[.contrast]] = RangeParam(byte: 0x02, maxVal: 7, displayOffset: 1)
    p[[.text, .style]] = OptionsParam(byte: 0x03, options: ["Type 1", "Type 2"])
    p[[.rhythm, .out]] = OptionsParam(byte: 0x04, options: ["Key Out", "All Mix"])
    p[[.patch, .remain]] = RangeParam(byte: 0x05, maxVal: 1)
    p[[.start, .mode]] = OptionsParam(byte: 0x06, options: ["Last Set", "Default"])
    p[[.tone, .ctrl, .src, .i(0)]] = RangeParam(byte: 0x07, maxVal: 1)
    p[[.tone, .ctrl, .src, .i(1)]] = RangeParam(byte: 0x08, maxVal: 1)
    p[[.fx, .ctrl, .src, .i(0)]] = RangeParam(byte: 0x09, maxVal: 1)
    p[[.fx, .ctrl, .src, .i(1)]] = RangeParam(byte: 0x0a, maxVal: 1)
    p[[.fx, .chorus, .on]] = RangeParam(byte: 0x0b, maxVal: 1)
    p[[.fx, .delay, .on]] = RangeParam(byte: 0x0c, maxVal: 1)
    p[[.fx, .reverb, .on]] = RangeParam(byte: 0x0d, maxVal: 1)
    p[[.fx, .i(0), .on]] = RangeParam(byte: 0x0e, maxVal: 1)
    p[[.patch, .channel]] = RangeParam(byte: 0x0f, maxVal: 17, formatter: {
      switch $0 {
      case 16: return "Part"
      case 17: return "Off"
      default:
        return "\($0+1)"
      }
    })
    p[[.rhythm, .channel]] = RangeParam(byte: 0x10, maxVal: 18, formatter: {
      switch $0 {
      case 16: return "Patch"
      case 17: return "Part 8"
      case 18: return "Off"
      default:
        return "\($0+1)"
      }
    })
    p[[.ctrl, .channel]] = RangeParam(byte: 0x11, maxVal: 16, formatter: {
      return $0 == 16 ? "Off" : "\($0+1)"
    })
    p[[.rcv, .pgmChange]] = RangeParam(byte: 0x12, maxVal: 1)
    p[[.rcv, .volume]] = RangeParam(byte: 0x13, maxVal: 1)
    p[[.rcv, .bend]] = RangeParam(byte: 0x14, maxVal: 1)
    p[[.rcv, .aftertouch]] = RangeParam(byte: 0x15, maxVal: 1)
    p[[.rcv, .mod]] = RangeParam(byte: 0x16, maxVal: 1)
    p[[.rcv, .breath]] = RangeParam(byte: 0x17, maxVal: 1)
    p[[.rcv, .expression]] = RangeParam(byte: 0x18, maxVal: 1)
    p[[.rcv, .foot]] = RangeParam(byte: 0x19, maxVal: 1)
    p[[.eq, .hi]] = RangeParam(byte: 0x1a, maxVal: 10, displayOffset: -5)
    p[[.eq, .mid]] = RangeParam(byte: 0x1b, maxVal: 10, displayOffset: -5)
    p[[.eq, .lo]] = RangeParam(byte: 0x1c, maxVal: 10, displayOffset: -5)
    p[[.preview, .mode]] = OptionsParam(byte: 0x1d, options: ["Single", "Chord"])
    (0..<4).forEach {
      p[[.preview, .note, .i($0)]] = RangeParam(byte: 0x1e + $0, maxVal: 88, formatter: {
        return $0 == 0 ? "Off" : ParamHelper.noteName($0 + 20)
      })
      p[[.preview, .velo, .i($0)]] = RangeParam(byte: 0x22 + $0, range: 1...127)
    }

    return p
  }()
  
  class var params: SynthPathParam { return _params }

}

