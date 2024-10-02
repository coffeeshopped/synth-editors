

static let deviceId: EditorValueTransform = .value([.global], [.deviceId])

static func deviceIdMap(_ value: Int) -> UInt8 {
  value > 15 ? 0 : UInt8(value)
}
  
module.exports = {
  parseOffset: 9,
  sysexData: (deviceId, address) => [
    ['yamCmd', [deviceId, 0x5e], ['+', ['count', 'b', 'msBytes7bit', 2], address, 'b']]
  ],
  dataSetMsg: (deviceId, address, v) =>
    ['yamParm', deviceId, [0x5e, address, (v >> 7) & 0x7f, v & 0x7f]],
}