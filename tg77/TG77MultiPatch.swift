
class TG77MultiPatch : YamahaMultiPatch, BankablePatch {
  
  open class var bankType: SysexPatchBank.Type { return TG77MultiBank.self }
  static func location(forData data: Data) -> Int { return Int(data[31] & 0xf) }

  private static let _subpatchTypes: [SynthPath : SysexPatch.Type] = [
    [.common] : TG77MultiCommonPatch.self,
    [.extra] : TG77MultiExtraPatch.self,
    ]
  open class var subpatchTypes: [SynthPath : SysexPatch.Type] { return _subpatchTypes }
  
  public var ySubpatches: [SynthPath:YamahaPatch]
  
  public static func isValid(fileSize: Int) -> Bool {
    return fileSize == fileDataCount || fileSize == TG77MultiCommonPatch.fileDataCount
  }
  
  public static func isCompleteFetch(sysex: Data) -> Bool {
    // default impl would stop fetch after only common is received
    return sysex.count == fileDataCount
  }

  var name: String {
    get { return subpatches[[.common]]?.name ?? "" }
    set { subpatches[[.common]]?.name = newValue }
  }
  
  required public init(data: Data) {
    ySubpatches = type(of: self).ySubpatches(forData: data)
  }
  
  required public init(common: TG77MultiCommonPatch, extra: TG77MultiExtraPatch) {
    ySubpatches = [
      [.common] : common,
      [.extra] : extra,
    ]
  }
  
  public static let initFileName = "tg77-multi-init"
  
  public func sysexData(channel: Int) -> Data {
    return sysexData(channel: channel, location: -1)
  }
  
  func sysexData(channel: Int, location: Int) -> Data {
    // Common, then Extra
    var data = (ySubpatches[[.common]] as? TG77MultiCommonPatch)?.sysexData(channel: channel, location: location) ?? Data()
    if let extra = ySubpatches[[.extra]] as? TG77MultiExtraPatch {
      data += extra.sysexData(channel: channel, location: location)
    }
    return data
  }
}


class TG77MultiCommonPatch: TG77Patch, BankablePatch {
  
  open class var bankType: SysexPatchBank.Type { return TG77MultiCommonBank.self }
  static func location(forData data: Data) -> Int { return Int(data[31] & 0xf) }

  static let nameByteRange = 0..<19
  static let initFileName = "tg77-multi-common-init"
  static let fileDataCount = 204
  
  static let headerString: String = "LM  8101MU"
  func bytesForSysex() -> [UInt8] { return bytes }

  var bytes: [UInt8]

  required init(data: Data) {
    bytes = [UInt8](data[32..<202])
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    // FX
    p[[.fx, .mode]] = TG33OptionsParam(parm: 0x0800, parm2: 0x0000, byte: 20, options: TG77VoicePatch.fxModeOptions)
    (0..<2).forEach { chorus in
      let off = chorus * 7
      let byteOff = 20 + off
      p.merge(new: [
        [.fx, .chorus, .i(chorus), .type] : TG33OptionsParam(parm: 0x0800, parm2: 0x0001 + off, byte: 1 + byteOff, options: TG77VoicePatch.chorusOptions),
        [.fx, .chorus, .i(chorus), .balance] : TG33RangeParam(parm: 0x0800, parm2: 0x0002 + off, byte: 2 + byteOff, maxVal: 100),
        [.fx, .chorus, .i(chorus), .level] : TG33RangeParam(parm: 0x0800, parm2: 0x0003 + off, byte: 3 + byteOff, maxVal: 100),
        [.fx, .chorus, .i(chorus), .param, .i(0)] : TG33RangeParam(parm: 0x0800, parm2: 0x0004 + off, byte: 4 + byteOff),
        [.fx, .chorus, .i(chorus), .param, .i(1)] : TG33RangeParam(parm: 0x0800, parm2: 0x0005 + off, byte: 5 + byteOff),
        [.fx, .chorus, .i(chorus), .param, .i(2)] : TG33RangeParam(parm: 0x0800, parm2: 0x0006 + off, byte: 6 + byteOff),
        [.fx, .chorus, .i(chorus), .param, .i(3)] : TG33RangeParam(parm: 0x0800, parm2: 0x0007 + off, byte: 7 + byteOff),
      ])
    }
    (0..<2).forEach { reverb in
      let off = reverb * 6
      let byteOff = 20 + off
      p.merge(new: [
        [.fx, .reverb, .i(reverb), .type] : TG33OptionsParam(parm: 0x0800, parm2: 0x000f + off, byte: 15 + byteOff, options: TG77VoicePatch.reverbOptions),
        [.fx, .reverb, .i(reverb), .balance] : TG33RangeParam(parm: 0x0800, parm2: 0x0010 + off, byte: 16 + byteOff, maxVal: 100),
        [.fx, .reverb, .i(reverb), .level] : TG33RangeParam(parm: 0x0800, parm2: 0x0011 + off, byte: 17 + byteOff, maxVal: 100),
        [.fx, .reverb, .i(reverb), .param, .i(0)] : TG33RangeParam(parm: 0x0800, parm2: 0x0012 + off, byte: 18 + byteOff),
        [.fx, .reverb, .i(reverb), .param, .i(1)] : TG33RangeParam(parm: 0x0800, parm2: 0x0013 + off, byte: 19 + byteOff),
        [.fx, .reverb, .i(reverb), .param, .i(2)] : TG33RangeParam(parm: 0x0800, parm2: 0x0014 + off, byte: 20 + byteOff),
      ])
    }
    p[[.fx, .mix, .i(0)]] = TG33RangeParam(parm: 0x0800, parm2: 0x001b, byte: 52 + 27, maxVal: 1)
    p[[.fx, .mix, .i(1)]] = TG33RangeParam(parm: 0x0800, parm2: 0x001c, byte: 52 + 28, maxVal: 1)
    
    // PARTS
    (0..<16).forEach { part in
      let parm = 0x0100 + part
      let off = 58 + (part * 7)
      p[[.i(part), .on]] = TG33RangeParam(parm: parm, parm2: 0x0000, byte: 0 + off, bit: 6)
      p[[.i(part), .out, .select]] = TG33OptionsParam(parm: parm, parm2: 0x0000, byte: 0 + off, bits: 2...5, options: indivOutOptions)
      p[[.i(part), .out, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0000, byte: 0 + off, bit: 0)
      p[[.i(part), .out, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0000, byte: 0 + off, bit: 1)
      p[[.i(part), .voice, .bank]] = TG33OptionsParam(parm: parm, parm2: 0x0001, byte: 1 + off, options: voiceBankOptions)
      p[[.i(part), .voice, .number]] = TG33RangeParam(parm: parm, parm2: 0x0002, byte: 2 + off, maxVal: 63)
      p[[.i(part), .volume]] = TG33RangeParam(parm: parm, parm2: 0x0003, byte: 3 + off)
      p[[.i(part), .fine]] = TG33RangeParam(parm: parm, parm2: 0x0004, byte: 4 + off, displayOffset: -64)
      p[[.i(part), .note, .shift]] = TG33RangeParam(parm: parm, parm2: 0x0005, byte: 5 + off, displayOffset: -64)
      p[[.i(part), .pan]] = TG33RangeParam(parm: parm, parm2: 0x0006, byte: 6 + off, maxVal: 63)
    }

    return p
  }()
  
  static let indivOutOptions = OptionsParam.makeOptions((0...8).map { $0 == 0 ? "Off" : "\($0)" })
  
  static let voiceBankOptions = OptionsParam.makeOptions(["Int", "P1", "P2", "Card"])
}

class TG77MultiExtraPatch: TG77Patch {

  static let initFileName = "tg77-multi-extra-init"
  static let fileDataCount = 68
  
  static let headerString: String = "LM  8104MU"
  func bytesForSysex() -> [UInt8] { return bytes }

  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = [UInt8](data[32..<66])
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.mode]] = TG33OptionsParam(parm: 0x0c00, parm2: 0x0000, byte: 0, options: ["Dynamic", "Static"])

    (0..<16).forEach { part in
      let pre: SynthPath = [.i(part)]
      let parm = 0x0c00
      p[pre + [.fm]] = TG33RangeParam(parm: parm, parm2: part + 2, byte: part + 2, maxVal: 16)
      p[pre + [.wave]] = TG33RangeParam(parm: parm, parm2: part + 18, byte: part + 18, maxVal: 16)
    }
    
    return p
  }()
}
