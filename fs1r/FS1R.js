
module.exports = {
  parseOffset: 9,
  deviceId: ['e', 'global', 'deviceId'],
  deviceIdMap: value => value > 15 ? 0 : value,
  sysexData: (deviceId, address) => [
    ['yamCmd', [deviceId, 0x5e], ['+', ['count', 'b', 'msBytes7bit', 2], address, 'b']]
  ],
  // v should be 2 bytes
  dataSetMsg: (deviceId, address, v) =>
    ['yamParm', deviceId, [0x5e, address, v]],
}