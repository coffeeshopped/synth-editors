
function jdxiSysex(obj) {
  const addressCount = 4
  rolandSysex(obj, addressCount)
  obj.dataSetHeaderCount = 8 + addressCount
  obj.dataSetHeader = (deviceId) => [0xf0, 0x41, deviceId, 0x00, 0x00, 0x00, 0x0e, 0x12]
}

function jdxiSinglePatch(obj) {
  jdxiSysex(obj)
  rolandSinglePatch(obj)
}

function jdxiMultiPatch(obj) {
  jdxiSysex(obj)
  rolandMultiPatch(obj)
}

function jdxiMultiSysex(obj) {
  jdxiSysex(obj)
  rolandMultiSysex(obj)
}

module.exports = {
  jdxiSysex,
  jdxiSinglePatch,
  jdxiMultiPatch,
  jdxiMultiSysex,
}
//  static let requestHeader: [UInt8] = [ 0xf0, 0x41, 0x10, 0x00, 0x00, 0x00, 0x0e, 0x11]
