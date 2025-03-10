
protocol NordLead2Patch : ByteBackedSysexPatch { }
extension NordLead2Patch {
  
  static func combinedBytes(forData data: Data) -> [UInt8] {
    var bytes = [UInt8]()
    let d = Data(data) // could be a slice, so copy it
    for i in (0..<d.count) where i % 2 == 0 {
      bytes.append(d[i] + (d[i+1] << 4))
    }
    return bytes
  }

  static func dataSetHeader(deviceId: Int, bank: Int, location: Int) -> Data {
    return Data([0xf0, 0x33, UInt8(deviceId), 0x04, UInt8(bank), UInt8(location)])
  }
  

  static func split(bytes: ArraySlice<UInt8>) -> [UInt8] {
    return [UInt8](bytes.map{ [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))] }.joined())
  }

  static func split(bytes: [UInt8]) -> [UInt8] {
    return [UInt8](bytes.map{ [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))] }.joined())
  }
  
  func sysexData(deviceId: Int, bank: Int, location: Int) -> Data {
    var data = type(of: self).dataSetHeader(deviceId: deviceId, bank: bank, location: location)
    data.append(contentsOf: type(of: self).split(bytes: bytes))
    data.append(0xf7)
    return data
  }
  
}
