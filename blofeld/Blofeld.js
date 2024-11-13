
const displayId = "blofeld"
const broadcastDeviceId = 0x7f

const deviceId = ['e', 'global', 'deviceId', broadcastDeviceId]

const sysex = (deviceId, bytes) => [0xf0, 0x3e, 0x13, deviceId, bytes, 0xf7]

/// dumpByte: cmd byte for what kind of dump.
const sysexData = (deviceId, dumpByte, bank, location, hasBankAndLocation) => {
  // universal checksum
  const dumpArr = hasBankAndLocation ? [dumpByte, bank, location] : [dumpByte]
  return sysex(deviceId, [dumpArr, 'b', 0x7f])
}
  
const paramData = (deviceId, bufferBytes, parm) => sysex(deviceId, [
  bufferBytes,
  ['>', parm, [
    ['bits', 0, 7, 'b'],
    ['bits', 7, 9, 'b']
  ]],
  ['byte', parm],
])

const createPatchTruss = (displayId, bodyDataCount, initFile, namePack, parms, parseOffset, dumpByte, hasBankAndLocation) => ({
  type: 'singlePatch',
  id: displayId,
  bodyDataCount: bodyDataCount,
  namePack: namePack,
  parms: parms,
  initFile: initFile, 
  createFile: sysexData(0x7f, dumpByte, 0x7f, 0x00, hasBankAndLocation), 
  parseBody: parseOffset,
})

const createBankTruss = (dumpByte, patchTruss, initFile) => ({
  type: 'singleBank',
  patchTruss: patchTruss,
  patchCount: 128,
  createFile: {
    locationMap: location => sysexData(0x7f, dumpByte, 0, location, true),
  },
  locationIndex: 6,
  initFile: initFile,
})