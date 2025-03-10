
struct Prophecy {
  
  static func sysexHeader(deviceId: UInt8) -> [UInt8] {
    return [0xf0, 0x42, 0x30 + deviceId, 0x41]
  }

}
