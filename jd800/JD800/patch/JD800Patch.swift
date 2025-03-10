
protocol JD800Patch : RolandSingleAddressable { }
extension JD800Patch {
  
  static var addressCount: Int { return 3 }

  static func dataSetHeader(deviceId: Int) -> Data {
    return Data([0xf0, 0x41, UInt8(deviceId), 0x3d, 0x12])
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

protocol JD800MultiPatch : RolandCompactMultiAddressable { }
extension JD800MultiPatch {
  
  static var addressCount: Int { return 3 }
  
  static func dataSetHeader(deviceId: Int) -> Data {
    return Data([0xf0, 0x41, UInt8(deviceId), 0x3d, 0x12])
  }
  
  // Overriding the RolandCompactMultiAddressable implementation bc I'm not sure if
  // the D-110 needs that version (which does a single, huge sysex msg instead of multiple 266-byte msgs
  func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
    let sortedPaths = type(of: self).sortedSubpatchPaths()
    var data: Data!
    var bytes = [UInt8]()
    sortedPaths.forEach {
      guard let addressable = addressables[$0] else { return }

      if data == nil {
        data = type(of: addressable).dataSetHeader(deviceId: deviceId)
      }

      bytes.append(contentsOf: addressable.bytes)
    }
    
    // now we have a slab of all the bytes. Break them up into 256-byte chunks, and make a sysex msg of each
    let chunkSize = 256
    return stride(from: 0, to: bytes.count, by: chunkSize).map {
      let thisAdd = address + RolandAddress(intValue: $0)
      var d = Data()
      d.append(type(of: self).dataSetHeader(deviceId: deviceId))
      d.append(contentsOf: thisAdd.sysexBytes(count: type(of: self).addressCount))
      let boff = min($0 + chunkSize, bytes.count)
      let theseB = [UInt8](bytes[$0..<boff])
      d.append(contentsOf: theseB)
      d.append(type(of: self).checksum(address: thisAdd, dataBytes: theseB))
      d.append(0xf7)
      return d
    }
  }

}
