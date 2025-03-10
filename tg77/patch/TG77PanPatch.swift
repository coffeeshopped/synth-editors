
class TG77PanPatch: TG77Patch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = TG77PanBank.self
  static func location(forData data: Data) -> Int { return Int(data[31] & 0x1f) }

  static let nameByteRange = 17..<27
  static let initFileName = "tg77-pan-init"
  static let fileDataCount = 61
  
  static let headerString: String = "LM  8101PN"
  func bytesForSysex() -> [UInt8] { return bytes }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = [UInt8](data[32..<59])
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.src]] = TG33OptionsParam(parm: 0x0a00, parm2: 0x0000, byte: 0, options: srcOptions)
    p[[.depth]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0001, byte: 1, maxVal: 99)
    p[[.hold, .time]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0002, byte: 2, maxVal: 63)
    p[[.rate, .i(0)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0003, byte: 3, maxVal: 63)
    p[[.rate, .i(1)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0004, byte: 4, maxVal: 63)
    p[[.rate, .i(2)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0005, byte: 5, maxVal: 63)
    p[[.rate, .i(3)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0006, byte: 6, maxVal: 63)
    p[[.release, .rate, .i(0)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0007, byte: 7, maxVal: 63)
    p[[.release, .rate, .i(1)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0008, byte: 8, maxVal: 63)
    p[[.level, .i(-1)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0009, byte: 9, maxVal: 63, displayOffset: -32)
    p[[.level, .i(0)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x000a, byte: 10, maxVal: 63, displayOffset: -32)
    p[[.level, .i(1)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x000b, byte: 11, maxVal: 63, displayOffset: -32)
    p[[.level, .i(2)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x000c, byte: 12, maxVal: 63, displayOffset: -32)
    p[[.level, .i(3)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x000d, byte: 13, maxVal: 63, displayOffset: -32)
    p[[.release, .level, .i(0)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x000e, byte: 14, maxVal: 63, displayOffset: -32)
    p[[.release, .level, .i(1)]] = TG33RangeParam(parm: 0x0a00, parm2: 0x000f, byte: 15, maxVal: 63, displayOffset: -32)
    p[[.loop, .pt]] = TG33RangeParam(parm: 0x0a00, parm2: 0x0010, byte: 16, maxVal: 3, displayOffset: 1)

    return p
  }()
  
  static let srcOptions = OptionsParam.makeOptions(["Velo","Note #","LFO"])
}
