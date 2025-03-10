
class TG33MultiPatch : YamahaSinglePatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = TG33MultiBank.self
  
  static let nameByteRange = 0x0d..<0x15
  static let initFileName = "tg33-multi-init"
  static let fileDataCount = 226
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = [UInt8](data[0x10..<224])
  }
  
  init(bankData: Data) {
    bytes = [UInt8](bankData)
  }
  
  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      
      switch path.last! {
      case .on:
        let value = unpack(param: param) ?? 0
        return value << 3
      case .group:
        let value = unpack(param: param) ?? 0
        return value << 2
      case .shift, .detune:
        let v = bytes[param.byte]
        return Int(Int8(bitPattern: v << 1)) >> 1
      case .i(1):
        if path[path.count-2] == .out {
          let value = unpack(param: param) ?? 0
          return value << 1
        }
      default:
        break
      }
      return unpack(param: param)
    }
    set {
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      var packValue = newValue
      switch path.last! {
      case .on:
        let v = newValue >> 3
        pack(value: v, forParam: param)
        return
      case .group:
        let v = newValue >> 2
        pack(value: v, forParam: param)
        return
      case .shift, .detune:
        packValue = Int(UInt8(bitPattern: Int8(newValue << 1))) >> 1
      case .i(1):
        if path[path.count-2] == .out {
          let v = newValue >> 1
          pack(value: v, forParam: param)
          return
        }
      default:
        break
      }
      pack(value: packValue, forParam: param)
    }
  }
  
  
  func sysexData(channel: Int) -> Data {
    var b = "LM  0012ME".unicodeScalars.map { UInt8($0.value) }
    b.append(contentsOf: bytes)
    
    let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
    let byteCountLSB = UInt8(b.count & 0x7f)
    var data = Data([0xf0, 0x43, UInt8(channel), 0x7e, byteCountMSB, byteCountLSB])
    data.append(contentsOf: b)
    data.append(type(of: self).checksum(bytes: b))
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.common, .fx, .type]] = TG33OptionsParam(parm: 0x080000, parm2: 0x017f, byte: 0x00, bits: 0...3, options: TG33VoicePatch.fxOptions)
    p[[.common, .fx, .balance]] = TG33RangeParam(parm: 0x090001, parm2: 0x017f, byte: 0x01)
    p[[.common, .fx, .send, .i(0)]] = TG33RangeParam(parm: 0x0a0005, parm2: 0x017f, byte: 0x05)
    p[[.common, .fx, .send, .i(1)]] = TG33RangeParam(parm: 0x0a0006, parm2: 0x017f, byte: 0x06)
    p[[.common, .out, .i(0)]] = TG33OptionsParam(parm: 0x070007, parm2: 0x017e, byte: 0x07, bit: 0, options: [0: "Out 1", 1: "Out 2"])
    p[[.common, .out, .i(1)]] = TG33OptionsParam(parm: 0x070007, parm2: 0x017d, byte: 0x07, bit: 1, options: [0: "Out 1", 2: "Out 2"])
    p[[.common, .assign]] = TG33OptionsParam(parm: 0x050015, parm2: 0x017f, byte: 0x15, bits: 0...1, options: assignOptions)
    
    (0..<16).forEach {
      let off = $0 * 0x0b
      p[[.part, .i($0), .on]] = TG33OptionsParam(parm: 0x000000, parm2: 0x0177, byte: 0x20 + off, bit: 3, options: onOptions)
      p[[.part, .i($0), .group]] = TG33OptionsParam(parm: 0x060000, parm2: 0x017b, byte: 0x20 + off, bit: 2, options: groupOptions)
      p[[.part, .i($0), .bank]] = TG33OptionsParam(parm: 0x000001, parm2: 0x017f, byte: 0x21 + off, bits: 0...1, options: bankOptions)
      p[[.part, .i($0), .number]] = TG33RangeParam(parm: 0x000002, parm2: 0x017f, byte: 0x22 + off, bits: 0...5)
      p[[.part, .i($0), .volume]] = TG33OptionsParam(parm: 0x010003, parm2: 0x017f, byte: 0x23 + off, options: TG33VoicePatch.inverseOptions99)
      p[[.part, .i($0), .detune]] = TG33RangeParam(parm: 0x020004, parm2: 0x017f, byte: 0x25 + off, range: -50...50)
      p[[.part, .i($0), .note, .shift]] = TG33RangeParam(parm: 0x030005, parm2: 0x017f, byte: 0x27 + off, range: -12...12)
      p[[.part, .i($0), .pan]] = TG33OptionsParam(parm: 0x040006, parm2: 0x017f, byte: 0x28 + off, bits: 0...2, options: panOptions)
    }
    
    return p
  }()

  static let onOptions: [Int:String] = [
    0 : "Off",
    8 : "On"
  ]

  static let groupOptions: [Int:String] = [
    0 : "1",
    4 : "2"
  ]
  
  static let assignOptions: [Int:String] = OptionsParam.makeOptions(["32/0", "24/8", "16/16"])

  static let bankOptions: [Int:String] = OptionsParam.makeOptions(["Internal", "Preset 1", "Preset 2"])
  
  static let panOptions: [Int:String] = {
    var opts = TG33VoicePatch.panOptions
    opts[5] = "Voice"
    return opts
  }()
}
