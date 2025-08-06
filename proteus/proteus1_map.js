
const sysexData = Proteus.sysex([0x07, 'b'])

const patchTransform = {
  type: 'singlePatch',
  throttle: 100, 
  param: (path, parm, value) => [[Proteus.paramData(parm.p, value), 10]], 
  patch: [[sysexData, 10]],
}

const parms = [
  { prefix: '', count: 128, bx: 1, block: [
    ['', { p: 512, max: 191 }],
  ] },
]

const patchTruss = {
  single: "proteus1.map", 
  bodyDataCount: 256, 
  parms: parms, 
  initFile: "proteus1-map-init", 
  createFileData: sysexData, 
  parseBody: 5, 
  pack: (parm, value) => Proteus.pack(parm.p - 512, value),
  unpack: (parm) => Proteus.unpack(parm.p - 512),
}

module.exports = {
  patchTruss,
  patchTransform,
}
