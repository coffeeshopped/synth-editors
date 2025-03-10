
protocol DX200SinglePatch : YamahaSinglePatch {
  static var dataByteCount: Int { get }
  static var modelId: UInt8 { get }
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress
  func sysexData(deviceId: Int, address: RolandAddress) -> Data
  func bankSysexData(deviceId: Int, path: SynthPath, index: Int) -> Data
}

extension DX200SinglePatch {
  static var fileDataCount: Int { return dataByteCount + 11 }
  
  static func bytes(forData data: Data) -> [UInt8] {
    guard data.count >= (9 + dataByteCount) else {
      return [UInt8](repeating: 0, count: dataByteCount)
    }
    return [UInt8](data[9..<(9+dataByteCount)])
  }
  
  // YamahaSinglePatch requirement. Fix.
  func sysexData(channel: Int) -> Data {
    return Data()
  }
  
  func sysexData(deviceId: Int, address: RolandAddress) -> Data {
    let sizeBytes = type(of: self).dataByteCount.bytes7bit(count: 2)
    let addressBytes = address.sysexBytes(count: 3)
    let allBytes = sizeBytes + addressBytes + bytes
    var data = Data([0xf0, 0x43, UInt8(deviceId), type(of: self).modelId])
    data.append(contentsOf: allBytes)
    data.append(type(of: self).checksum(bytes: allBytes))
    data.append(0xf7)
    return data
  }
  
  func bankSysexData(deviceId: Int, path: SynthPath, index: Int) -> Data {
    let address = type(of: self).bankAddress(forSynthPath: path, index: index)
    return sysexData(deviceId: deviceId, address: address)
  }
  
  func fileData() -> Data {
    let address = type(of: self).tempAddress(forSynthPath: [])
    return sysexData(deviceId: 0, address: address)
  }
  

  /// Param parm > 1 -> multi-byte parameter
  func unpack(param: Param) -> Int? {
    let byteCount = param.parm == 0 ? 1 : param.parm
    let byte = RolandAddress(param.byte).intValue()

    guard byteCount > 1 else {
      return type(of: self).defaultUnpack(byte: byte, bits: param.bits, forBytes: bytes)
    }
    
    return type(of: self).multiByteParamInt(from: Array(bytes[byte..<(byte+byteCount)]))
  }

  /// Param parm > 1 -> multi-byte parameter
  func pack(value: Int, forParam param: Param) {
    let byteCount = param.parm == 0 ? 1 : param.parm
    // roland byte addresses in params are *Roland* addresses
    let byte = RolandAddress(param.byte).intValue()
    guard byteCount > 1 else {
      bytes[byte] = type(of: self).defaultPackedByte(value: value, forParam: param, byte: bytes[byte])
      return
    }
    
    let b = type(of: self).multiByteParamBytes(from: value, count: byteCount)
    b.enumerated().forEach { bytes[byte+$0.offset] = $0.element }
  }

  
  /// Compose Int value from bytes (MSB first)
  static func multiByteParamInt(from: [UInt8]) -> Int {
    guard from.count > 1 else { return Int(from[0]) }
    return (1...from.count).reduce(0) {
      let shift = (from.count - $1) * 7
      return $0 + (Int(from[$1-1]) << shift)
    }
  }

  /// Decompose Int to bytes (4 bits at a time)
  static func multiByteParamBytes(from: Int, count: Int) -> [UInt8] {
    guard count > 0 else { return [UInt8(from)] }
    return (1...count).map {
      let shift = (count - $0) * 7
      return UInt8((from >> shift) & 0x7f)
    }
  }
}
