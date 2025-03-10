
class JD800SystemPatch : JD800Patch, GlobalPatch {

  static let initFileName = "jd800-system-init"
  class var size: RolandAddress { return 0x19 }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x020000
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.tune]] = RangeParam(byte: 0x0, maxVal: 100, displayOffset: -50)
    p[[.hi]] = RangeParam(byte: 0x1, maxVal: 10, displayOffset: -5)
    p[[.mid]] = RangeParam(byte: 0x2, maxVal: 10, displayOffset: -5)
    p[[.lo]] = RangeParam(byte: 0x3, maxVal: 10, displayOffset: -5)
    p[[.chorus, .on]] = RangeParam(byte: 0x4, maxVal: 1)
    p[[.delay, .on]] = RangeParam(byte: 0x5, maxVal: 1)
    p[[.reverb, .on]] = RangeParam(byte: 0x6, maxVal: 1)
    p[[.delay, .mid, .time]] = RangeParam(byte: 0x7, maxVal: 125)
    p[[.delay, .mid, .level]] = RangeParam(byte: 0x8, maxVal: 100)
    p[[.delay, .left, .time]] = RangeParam(byte: 0x9, maxVal: 125)
    p[[.delay, .left, .level]] = RangeParam(byte: 0x0A, maxVal: 100)
    p[[.delay, .right, .time]] = RangeParam(byte: 0x0B, maxVal: 125)
    p[[.delay, .right, .level]] = RangeParam(byte: 0x0C, maxVal: 100)
    p[[.delay, .feedback]] = RangeParam(byte: 0x0D, maxVal: 98, displayOffset: -48)
    p[[.chorus, .rate]] = RangeParam(byte: 0x0E, maxVal: 99)
    p[[.chorus, .depth]] = RangeParam(byte: 0x0F, maxVal: 100)
    p[[.chorus, .delay]] = RangeParam(byte: 0x10, maxVal: 99)
    p[[.chorus, .feedback]] = RangeParam(byte: 0x11, maxVal: 98)
    p[[.chorus, .level]] = RangeParam(byte: 0x12, maxVal: 100)
    p[[.reverb, .type]] = OptionsParam(byte: 0x13, options: ["ROOM1", "ROOM2", "HALL1", "HALL2", "HALL3", "HALL4", "GATE", "REVERSE", "FLYING1", "FLYING2"])
    p[[.reverb, .pre]] = RangeParam(byte: 0x14, maxVal: 121)
    p[[.reverb, .early]] = RangeParam(byte: 0x15, maxVal: 100)
    p[[.reverb, .hi, .cutoff]] = OptionsParam(byte: 0x16, options: ["500", "630", "800", "1k", "1.25k", "1.6k", "2k", "2.5k 3.15k", "4k", "5k", "6.3k 8k", "10k 12.5k", "16kHz", "BYPASS"])
    p[[.reverb, .time]] = RangeParam(byte: 0x17, maxVal: 100)
    p[[.reverb, .level]] = RangeParam(byte: 0x18, maxVal: 100)

    return p
  }()
  
  class var params: SynthPathParam { return _params }

}
