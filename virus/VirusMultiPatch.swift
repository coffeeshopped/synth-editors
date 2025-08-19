
protocol VirusMultiPatch : ByteBackedSysexPatch, PerfPatch {

}

extension VirusMultiPatch {

  static var fileDataCount: Int { return 267 }
  static var nameByteRange: Range<Int> { return 4..<14 }

  func sysexData(deviceId: UInt8, bank: UInt8, part: UInt8) -> Data {
    var data = Data(VirusTI.sysexHeader)
    var b1 = [deviceId, 0x11, bank, part] // these are included in checksum
    b1.append(contentsOf: bytes)
    // b1 holds deviceId + command header + bytes
    data.append(contentsOf: b1)
    
    // checksum
    let checksum = b1.map{ Int($0) }.reduce(0, +) & 0x7f
    data.append(UInt8(checksum))
    
    data.append(0xf7)
    return data
  }
  
  // save as edit buffer. 16 deviceId is OMNI
  func fileData() -> Data {
    return sysexData(deviceId: 16, bank: 0, part: 0)
  }

}
