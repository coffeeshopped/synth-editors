
protocol WavestationPatch : ByteBackedSysexPatch { }

extension WavestationPatch {

  func printMyBytes() {
    bytes.enumerated().forEach {
      debugPrint("\($0.offset): ".appending(String(format: "%02hhx", $0.element)))
    }
  }

  func sysexHeader(channel: Int) -> [UInt8] {
    return [0xf0, 0x42, 0x30 + UInt8(channel), 0x28]
  }
  
  func sysexBodyData() -> Data {
    return Data(bytes.map { [$0 & 0xf, ($0 >> 4) & 0xf] }.joined())
  }
  
  func checksum(_ data: Data) -> UInt8 {
    return data.reduce(0) { ($0 + $1) & 0x7f }
  }
  
  func unpack(param: Param) -> Int? {
    let byteCount = param.extra[WavestationSRPatchPatch.ByteCount] ?? 1
    let v: Int?
    switch byteCount {
    case 4:
      v = 0.set(bits: 24...31, value: bytes[param.byte])
        .set(bits: 16...23, value: bytes[param.byte + 1])
        .set(bits: 8...15, value: bytes[param.byte + 2])
        .set(bits: 0...7, value: bytes[param.byte + 3])
      if let rangeParam = param as? ParamWithRange,
        rangeParam.range.lowerBound < 0 {
        return v?.int16()
      }
    case 2:
      v = 0.set(bits: 8...15, value: bytes[param.byte])
        .set(bits: 0...7, value: bytes[param.byte + 1])
      if let rangeParam = param as? ParamWithRange,
        rangeParam.range.lowerBound < 0 {
        return v?.int16()
      }
    default: // 1 byte
      v = defaultUnpack(param: param)
      if let rangeParam = param as? ParamWithRange,
        rangeParam.range.lowerBound < 0 {

        guard param.byte < bytes.count else { return nil }
        guard let bits = param.bits else { return Int(Int8(bitPattern: bytes[param.byte])) }
        return Int(bytes[param.byte]).signedBits(bits)
      }
    }
    return v
  }
  
  func pack(value: Int, forParam param: Param) {
    let byteCount = param.extra[WavestationSRPatchPatch.ByteCount] ?? 1

    switch byteCount {
    case 4:
      bytes[param.byte] = UInt8(value.bits(24...31))
      bytes[param.byte + 1] = UInt8(value.bits(16...23))
      bytes[param.byte + 2] = UInt8(value.bits(8...15))
      bytes[param.byte + 3] = UInt8(value.bits(0...7))
    case 2:
      bytes[param.byte] = UInt8(value.bits(8...15))
      bytes[param.byte + 1] = UInt8(value.bits(0...7))
    default: // 1 byte
      bytes[param.byte] = type(of: self).defaultPackedByte(value: value, forParam: param, byte: bytes[param.byte])
    }
    
  }


}
