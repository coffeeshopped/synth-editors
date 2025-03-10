
struct Deepmind12 {
  static func sysexHeader(deviceId: UInt8) -> [UInt8] {
    return [0xf0, 0x00, 0x20, 0x32, 0x20, deviceId]
  }
}
