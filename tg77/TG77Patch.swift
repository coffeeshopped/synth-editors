
protocol TG77Patch: YamahaSinglePatch {
  static var headerString: String { get }
  func bytesForSysex() -> [UInt8]
}

extension TG77Patch {
  
  func sysexData(channel: Int) -> Data {
    return sysexData(channel: channel, location: -1)
  }
  
  func sysexData(channel: Int, location: Int) -> Data {
    var b = type(of: self).headerString.unicodeScalars.map { UInt8($0.value) }
    b.append(contentsOf: [UInt8](repeating: 0, count: 14))
    if location < 0 {
      b.append(contentsOf: [0x7f, 0x00]) // edit buffer
    }
    else {
      b.append(contentsOf: [0x00, UInt8(location)])
    }
    
    b.append(contentsOf: bytesForSysex())
    
    let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
    let byteCountLSB = UInt8(b.count & 0x7f)
    var data = Data([0xf0, 0x43, UInt8(channel), 0x7a, byteCountMSB, byteCountLSB])
    data.append(contentsOf: b)
    data.append(type(of: self).checksum(bytes: b))
    data.append(0xf7)
    return data
  }
}
