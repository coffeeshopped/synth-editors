
module.exports = {
  parseOffset: 9,
  deviceId: ['e', 'global', 'deviceId'],
  deviceIdMap: value => value > 15 ? 0 : value,
  sysexData: (deviceId, address) => [
    ['yamCmd', [deviceId, 0x5e], ['+', ['count', 'b', 'msBytes7bit', 2], address, 'b']]
  ],
  dataSetMsg: (deviceId, address, v) =>
    ['yamParm', deviceId, [0x5e, address, (v >> 7) & 0x7f, v & 0x7f]],
}