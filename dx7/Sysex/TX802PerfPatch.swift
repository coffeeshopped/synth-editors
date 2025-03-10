
//class TX802PerfPatch : YamahaSinglePatch, BankablePatch, CompactBankablePatch, PerfPatch {
//  
//  open class var bankType: SysexPatchBank.Type { return TX802PerfBank.self }
//  
//  static let fileDataCount = 250
//  class var initFileName: String { return "tx802-perf-init" }
//  static let nameByteRange = 96..<116
//  
//  var bytes: [UInt8]
//  
//  required init(data: Data) {
//    // 116 bytes, split into nibbles
//    bytes = type(of: self).bytes(fromAsciiHex: [UInt8](data[16..<248]))
//  }
//  
//  required init(bankData: Data) {
//    // create empty bytes to pack into
//    bytes = [UInt8](repeating: 0, count: 116)
//
//    // un-ascii-ize the data
//    // skip 12 bytes (0x01, 0x28, LM  8952PM), and grab 168 bytes (84 x 2)
//    let b = type(of: self).bytes(fromAsciiHex: [UInt8](bankData[12..<180]))
//
//    // unpack the name
//    name = type(of: self).name(forRange: type(of: self).bankNameByteRange, bytes: b)
//
//    type(of: self).bankParams.forEach {
//      self[$0.key] = type(of: self).defaultUnpack(param: $0.value, forBytes: b)
//    }
//  }
//  
//  private static let hexString = "0123456789ABCDEF"
//  
//  private static func bytes(fromAsciiHex b: [UInt8]) -> [UInt8] {
//    return (0..<(b.count/2)).map {
//      let i = 2 * $0
//      var hiVal = 0
//      var loVal = 0
//      if let index = hexString.firstIndex(of: Character(UnicodeScalar(b[i]))) {
//        hiVal = hexString.distance(from: hexString.startIndex, to: index)
//      }
//      if let index = hexString.firstIndex(of: Character(UnicodeScalar(b[i+1]))) {
//        loVal = hexString.distance(from: hexString.startIndex, to: index)
//      }
//      return UInt8((hiVal << 4) + loVal)
//    }
//  }
//  
//  private static func asciiHex(fromBytes b: [UInt8]) -> [UInt8] {
//    // crazy ascii hex formatting
//    return [UInt8](b.map { String(format:"%02X", $0).bytes(forCount: 2) }.joined())
//  }
//  
//  /// Transform internal bytes to ASCII hexadecimal
//  private func asciiHexBytes() -> [UInt8] {
//    return type(of: self).asciiHex(fromBytes: bytes)
//  }
//
//
//
//  /// 0x01, 0x28, LM 8952PM, PMEM data, checksum
//  func bankSysexData() -> Data {
//    var b = [UInt8](repeating: 0, count: 84)
//
//    // pack the name
//    let nameByteRange = type(of: self).bankNameByteRange
//    let n = nameSetFilter(name) as NSString
//    let nameBytes = (0..<nameByteRange.count).map { $0 < n.length ? UInt8(n.character(at: $0)) : 32 }
//    b.replaceSubrange(nameByteRange, with: nameBytes)
//
//    // pack the params
//    type(of: self).bankParams.forEach {
//      let param = $0.value
//      b[param.byte] = type(of: self).defaultPackedByte(value: self[$0.key] ?? 0, forParam: param, byte: b[param.byte])
//    }
//
//    let outbytes = "LM  8952PM".unicodeScalars.map { UInt8($0.value) } + type(of: self).asciiHex(fromBytes: b)
//    var data = Data([0x01, 0x28])
//    data.append(contentsOf: outbytes)
//    data.append(type(of: self).checksum(bytes: outbytes))
//    return data
//  }
//  
//  // channel should be 0-15
//  func sysexData(channel: Int) -> Data {
//    // this is part of the data! part of the checksum
//    let outbytes = "LM  8952PE".unicodeScalars.map { UInt8($0.value) } + asciiHexBytes()
//    var data = Data([0xf0, 0x043, UInt8(channel), 0x7e, 0x01, 0x68])
//    data.append(contentsOf: outbytes)
//    data.append(type(of: self).checksum(bytes: outbytes))
//    data.append(0xf7)
//    return data
//  }
//  
//  func fileData() -> Data {
//    return sysexData(channel: 0)
//  }
//  
//  
//  private static let _params: SynthPathParam = {
//    var p = SynthPathParam()
//    
//    for part in 0..<8 {
//      let pre: SynthPath = [.part, .i(part)]
//      p[pre + [.channel, .offset]] = RangeParam(byte: 0 + part, maxVal: 7)
//      p[pre + [.channel]] = OptionsParam(byte: 8 + part, options: channelOptions)
//      p[pre + [.voice, .bank]] = OptionsParam(byte: 16 + part, bits: 6...7, options: bankOptions)
//      p[pre + [.voice, .number]] = OptionsParam(byte: 16 + part, bits: 0...5, options: numberOptions)
//      p[pre + [.detune]] = RangeParam(byte: 24 + part, maxVal: 14, displayOffset: -7)
//      p[pre + [.volume]] = RangeParam(byte: 32 + part, maxVal: 99)
//      p[pre + [.out, .assign]] = OptionsParam(byte: 40 + part, options: outOptions)
//      p[pre + [.note, .lo]] = RangeParam(byte: 48 + part)
//      p[pre + [.note, .hi]] = RangeParam(byte: 56 + part)
//      p[pre + [.note, .shift]] = RangeParam(byte: 64 + part, maxVal: 48, displayOffset: -24)
//      p[pre + [.env, .redamper]] = RangeParam(byte: 72 + part, maxVal: 1)
//      p[pre + [.key, .assign, .group]] = RangeParam(byte: 80 + part, maxVal: 1) // alt assign
//      p[pre + [.micro, .tune]] = RangeParam(byte: 88 + part, maxVal: 254)
//    }
//    
//    return p
//  }()
//  
//  static let channelOptions = OptionsParam.makeOptions((0...16).map {
//    $0 < 16 ? "\($0+1)" : "Omni"
//  })
//  
//  static let bankOptions = OptionsParam.makeOptions(["Int","Cart","A","B"])
//  
//  static let numberOptions = OptionsParam.makeOptions((1...64).map { "\($0)" })
//  
//  static let outOptions = OptionsParam.makeOptions(["Off","I","II","I+II"])
//  
//  class var params: SynthPathParam { return _params }
//  
//  // MARK: Bank Params
//  
//  
//  private static let bankNameByteRange = 64..<84
//
//  // params for reading from a bank
//  private static let bankParams: SynthPathParam = {
//    var p = SynthPathParam()
//
//    (0..<8).forEach { part in
//      let pre: SynthPath = [.part, .i(part)]
//      p[pre + [.channel, .offset]] = RangeParam(byte: 0 + part, bits: 5...7)
//      p[pre + [.channel]] = RangeParam(byte: 0 + part, bits: 0...4)
//      p[pre + [.voice, .bank]] = RangeParam(byte: 8 + part, bits: 6...7)
//      p[pre + [.voice, .number]] = RangeParam(byte: 8 + part, bits: 0...5)
//      p[pre + [.detune]] = RangeParam(byte: 32 + part, bits: 3...6)
//      p[pre + [.volume]] = RangeParam(byte: 24 + part, bits: 0...6)
//      p[pre + [.out, .assign]] = RangeParam(byte: 32 + part, bits: 0...1)
//      p[pre + [.key, .assign, .group]] = RangeParam(byte: 32 + part, bit: 2) // alt assign
//      p[pre + [.note, .lo]] = RangeParam(byte: 40 + part, bits: 0...6)
//      p[pre + [.note, .hi]] = RangeParam(byte: 48 + part, bits: 0...6)
//      p[pre + [.note, .shift]] = RangeParam(byte: 56 + part, bits: 0...5)
//      p[pre + [.env, .redamper]] = RangeParam(byte: 56 + part, bit: 6)
//      p[pre + [.micro, .tune]] = RangeParam(byte: 16 + part)
//    }
//
//    return p
//  }()
//
//  
//}
