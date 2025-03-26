
const displayId = "blofeld"
const broadcastDeviceId = 0x7f

const deviceId = ['e', 'global', 'deviceId', broadcastDeviceId]

const sysex = bytes => [0xf0, 0x3e, 0x13, deviceId, bytes, 0xf7]

/// dumpByte: cmd byte for what kind of dump.
const sysexData = (dumpByte, bank, location, hasBankAndLocation) => {
  // universal checksum
  const dumpArr = hasBankAndLocation ? [dumpByte, bank, location] : [dumpByte]
  return sysex([dumpArr, 'b', 0x7f])
}
  
const paramData = (bufferBytes, parm) => sysex([
  bufferBytes,
  ['>', parm, [
    ['bits', [0, 7], 'b'],
    ['bits', [7, 9], 'b']
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
  createFile: sysexData(dumpByte, 0x7f, 0x00, hasBankAndLocation), 
  parseBody: parseOffset,
})

const createBankTruss = (dumpByte, patchTruss, initFile) => ({
  type: 'singleBank',
  patchTruss: patchTruss,
  patchCount: 128,
  createFile: {
    locationMap: location => sysexData(dumpByte, 0, location, true),
  },
  locationIndex: 6,
  initFile: initFile,
})

module.exports = {
  sysex,
  sysexData,
  paramData,
  createPatchTruss,
  createBankTruss,
}