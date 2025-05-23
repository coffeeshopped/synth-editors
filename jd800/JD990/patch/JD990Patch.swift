
protocol JD990Patch : RolandSingleAddressable { }
extension JD990Patch {
  
  static var addressCount: Int { return 4 }

  static func dataSetHeader(deviceId: Int) -> Data {
    return Data([0xf0, 0x41, UInt8(deviceId), 0x57, 0x12])
  }
  
  // Different multi-byte param pack/unpack
  
  /// Compose Int value from bytes (MSB first)
  static func multiByteParamInt(from: [UInt8]) -> Int {
    guard from.count > 1 else { return Int(from[0]) }
    return (1...from.count).reduce(0) {
      let shift = (from.count - $1) * 7
      return $0 + (Int(from[$1 - 1]) << shift)
    }
  }

  /// Decompose Int to bytes (7! bits at a time)
  static func multiByteParamBytes(from: Int, count: Int) -> [UInt8] {
    guard count > 0 else { return [UInt8(from)] }
    return (1...count).map {
      let shift = (count - $0) * 7
      return UInt8((from >> shift) & 0x7f)
    }
  }

}

protocol JD990MultiPatch : RolandCompactMultiAddressable { }
extension JD990MultiPatch {
  
  static var addressCount: Int { return 4 }

  static func dataSetHeader(deviceId: Int) -> Data {
    return Data([0xf0, 0x41, UInt8(deviceId), 0x57, 0x12])
  }
}
