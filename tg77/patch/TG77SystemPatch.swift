
class TG77SystemPatch: TG77Patch, GlobalPatch {
  
  static let initFileName = "tg77-system-init"
  static let fileDataCount = 98
  
  static let headerString: String = "LM  8101SY"
  func bytesForSysex() -> [UInt8] { return bytes }
  
  var bytes: [UInt8]
  var name = ""
  
  var upperGreeting: String {
    set { set(string: newValue, forByteRange: 0..<20) }
    get { return type(of: self).name(forRange: 0..<20, bytes: bytes) }
  }

  var lowerGreeting: String {
    set { set(string: newValue, forByteRange: 20..<40) }
    get { return type(of: self).name(forRange: 20..<40, bytes: bytes) }
  }
  
  func allNames() -> [SynthPath:String] {
    return [
      [] : name,
      [.hi] : upperGreeting,
      [.lo] : lowerGreeting,
    ]
  }


  required init(data: Data) {
    bytes = [UInt8](data[32..<96])
  }
  
  func set(name n: String, forPath path: SynthPath) {
    switch path {
    case [.hi]:
      upperGreeting = n
    case [.lo]:
      lowerGreeting = n
    default:
      name = n
    }
  }
  
  func name(forPath path: SynthPath) -> String? {
    switch path {
    case [.hi]:
      return upperGreeting
    case [.lo]:
      return lowerGreeting
    default:
      return name
    }
  }


  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.note, .shift]] = TG33RangeParam(parm: 0x0f00, parm2: 0x0028, byte: 40, displayOffset: -64)
    p[[.fine]] = TG33RangeParam(parm: 0x0f00, parm2: 0x0029, byte: 41, displayOffset: -64)
    p[[.fixed, .velo]] = TG33OptionsParam(parm: 0x0f00, parm2: 0x002a, byte: 42, options: OptionsParam.makeOptions((0..<128).map {
      return $0 == 0 ? "Off" : "\($0)"
    }))
    p[[.velo, .curve]] = TG33RangeParam(parm: 0x0f00, parm2: 0x002b, byte: 43, maxVal: 7)
    p[[.modWheel]] = TG33RangeParam(parm: 0x0f00, parm2: 0x002c, byte: 44, maxVal: 120)
    p[[.foot]] = TG33RangeParam(parm: 0x0f00, parm2: 0x002d, byte: 45, maxVal: 120)
    p[[.edit]] = TG33RangeParam(parm: 0x0f00, parm2: 0x002e, byte: 46, maxVal: 1)
    p[[.send, .channel]] = TG33RangeParam(parm: 0x0f00, parm2: 0x002f, byte: 47, maxVal: 15, displayOffset: 1)
    p[[.rcv, .channel]] = TG33OptionsParam(parm: 0x0f00, parm2: 0x0030, byte: 48, options: OptionsParam.makeOptions((0..<17).map {
      return $0 == 16 ? "Omni" : "\($0+1)"
    }))
    p[[.local]] = TG33RangeParam(parm: 0x0f00, parm2: 0x0031, byte: 49, maxVal: 1)
    p[[.deviceId]] = TG33OptionsParam(parm: 0x0f00, parm2: 0x0032, byte: 50, options: OptionsParam.makeOptions((0..<18).map {
      return $0 == 0 ? "Off" : $0 == 17 ? "All" : "\($0)"
    }))
    // even/odd
    p[[.note, .select]] = TG33OptionsParam(parm: 0x0f00, parm2: 0x0033, byte: 51, options: ["All", "Odd", "Even"])
    p[[.protect]] = TG33RangeParam(parm: 0x0f00, parm2: 0x0034, byte: 52, maxVal: 1)
    p[[.pgm, .mode]] = TG33OptionsParam(parm: 0x0f00, parm2: 0x0035, byte: 53, options: ["Off", "Normal", "Direct", "Table"])
    
    return p
  }()
  
}
