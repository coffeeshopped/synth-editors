//    const fileDataCount = 262 // 256 data bytes

const sysexData = (deviceId) => [0xf0, 0x18, 0x04, deviceId, 0x05, 'b', 0xf7]

const parms = (128).map(i => 
  [['octave', i / 12,'note', i % 12], { p: i, max: 8192 }]
)

const patchTruss = {
  single: "proteus.tuning", 
  bodyDataCount: 256, 
  parms: parms, 
  initFile: "proteus1-tuning-init", 
  createFileData: {
    sysexData($0, deviceId: 0)
  },
  parseOffset: 5, pack: { bodyData, param, value in
    Proteus.pack(&bodyData, parm: param.p!, value: value)
  },
  unpack: { bodyData, param in
    Proteus.unpack(bodyData, parm: param.p!)
  },
}

const patchTransform = {
  type: 'singleWholePatch',
  throttle: 300,
  patch: [[sysexData(deviceId), 100]],
}

module.exports = {
  patchTruss,
  patchTransform,
}