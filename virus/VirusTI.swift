
struct VirusTI {
  
  static let sysexHeader: [UInt8] = [0xf0, 0x00, 0x20, 0x33, 0x01]
  
  static func commandHeader(deviceId: UInt8, functionId: UInt8) -> [UInt8] {
    return sysexHeader + [deviceId, functionId]
  }
  
}
