
const deviceId = ['e', 'global', 'deviceId', 0]
const deviceIdMap = ['>', deviceId, value => value > 15 ? 0 : value]

module.exports = {
  parseOffset: 9,
  sysexData: address => [
    ['yamCmd', [deviceIdMap, 0x5e], [['count', 'b', 'msBytes7bit', 2], address, 'b']]
  ],
  // v should be 2 bytes
  dataSetMsg: (address, v) => ['yamParm', deviceIdMap, [0x5e, address, v]],
  fetch: address => ['yamFetch', deviceIdMap, [0x5e, address]]
}