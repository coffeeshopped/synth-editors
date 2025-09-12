const VCED = require('./vced.js')
const ACED = require('./aced.js')
const ACED2 = require('./aced2.js')

const map = {
  "aftertouch": ACED2,
  "extra": ACED,
  "voice": VCED,
}

const createPatchTruss = (synthName, keys, initFile, validSizes) => ({
  multiPatch: `${synthName}.voice`,
  trussMap: keys.map(k => [k, map[k].patchTruss]),
  namePath: "voice",
  initFile: initFile,
  validSizes: validSizes,
  includeFileDataCount: true,
})

const createBankTruss = (patchTruss, patchCount, initFile, keys) => ({
  compactMultiBank: patchTruss, 
  patchCount: patchCount, 
  initFile: initFile,
  fileDataCount: 4104,
  compactTrussMap: keys.map(k => [k, map[k].compactTruss]),
  createFile: ['yamCmd', ['channel', 0x04, 0x20, 0x00]],
  parseBody: 6, 
})

const opOns = (4).map(i => ['extra', 'patch', ['voice', 'op', i, 'on']])

// calc based on stored editor values and new incoming value
const opOnByte = (dict, newOp, value) => {
  (4).map(i => {
    const isOn = i == newOp ? value > 0 : dict[transform] == 1
    return isOn ? 1 << ((4 - 1) - i) : 0
  }).sum()
}

const patchTransform = keys => ({
  type: 'multiDictPatch',
  throttle: 100,
  editorVal: opOns,
  param: (path, parm, value) => {
    const first = pathPart(path, 0)
    const isOpOn = first == 'voice' && pathLast(path) == 'on'
    const parmByte = isOpOn ? 93 : parm.b
    var data = [first, ['byte', parmByte]]
    switch (first) {
      case 'voice':
        // TODO: opOn stuff
        // const v = isOpOn ? opOnByte(editorVal, path[2], value) : subval
        data.push(VCED.patchWerk.paramData([parmByte, 'b']))
        break
      case 'extra':
        data.push(ACED.patchWerk.paramData([parmByte, 'b']))
        break
      case 'aftertouch':
        // offset byte by 23 to get param address
        data.push(ACED.patchWerk.paramData([parmByte + 23, 'b']))
        break
      default:
        return null
    }
    return [[data, 0]]
  }, 
  patch: keys.map(k => [[k, map[k].patchWerk.sysexData], 100]),
  name: VCED.patchTruss.namePack.rangeMap(i => [
    ['voice', VCED.patchWerk.paramData([i, ['byte', i]])], 10
  ]),
})

const setup = (config) => {
  const patchTruss = createPatchTruss(config.synthName, config.keys, config.patchFile, config.validSizes)
  const bankTruss = createBankTruss(patchTruss, config.patchCount, config.bankFile, config.keys)
  return {
    patchTruss,
    bankTruss,
    patchTransform: patchTransform(config.keys),
    bankTransform: bankTruss,
  }
}

module.exports = {
  setup,
}