
const deviceId = ['e', 'global', 'deviceId']
module.exports = {
  parseOffset: 9,
  deviceId: deviceId,
  deviceIdMap: value => value > 15 ? 0 : value,
  sysexData: (notUsed, address) => [
    ['yamCmd', [deviceId, 0x5e], ['+', ['count', 'b', 'msBytes7bit', 2], address, 'b']]
  ],
  // v should be 2 bytes
  dataSetMsg: (notUsed, address, v) =>
    ['yamParm', deviceId, [0x5e, address, v]],
}