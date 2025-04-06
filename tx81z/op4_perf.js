const Op4 = require('./op4.js')

const sysexData = ['yamCmd', ['channel', 0x7e, 0x00, 0x78], [["enc", "LM  8976PE"], "b"]]

const patchWerk = Op4.patchWerk(0x10, sysexData)

const createPatchTruss = parms => ({
  type: 'singlePatch',
  id: 'tx81z.perf',
  bodyDataCount: 110, 
  namePack: [100, 110],
  parms: parms, 
  initFile: "tx81z-perf-init", 
  createFile: sysexData,
  parseBody: 16,
})

const createCompactTruss = compactParms => ({
  type: 'singlePatch',
  id: 'tx81z.perf.compact',
  bodyDataCount: 76,
  namePack: [66, 76],
  parms: compactParms,
})

const createBankTruss = (patchCount, patchTruss, compactTruss) => ({
  type: 'compactSingleBank',
  patchTruss: patchTruss,
  patchCount: patchCount,
  paddedPatchCount: 32,
  initFile: "",
  fileDataCount: 2450, 
  compactTruss: compactTruss, 
  createFile: ['yamCmd', ['channel', 0x7e, 0x13, 0x0a], [['enc', "LM  8976PM"], 'b']],
  parseBody: 16,
})

const wholeBankTransform = bankTruss => ({
  type: 'wholeBank',
  singleBankTruss: bankTruss,
  waitInterval: 100,
})

const patchTransform = {
  type: 'singlePatch',
  throttle: 30, 
  editorVal: Op4.sysexChannel,
  param: (path, parm, value) => {
    if (pathLast(path) == 'number') {
      return [
        [patchWerk.paramData([parm.b - 1, ['bit', 7, value]]), 50],
        [patchWerk.paramData([parm.b, ['bits', [0, 7], value]]), 0],
      ]
    }
    else {
      return [[patchWerk.paramData([parm.b, ['byte', parm.b]]), 0]]
    }
  }, 
  patch: sysexData, 
  name: patchWerk.nameTransform,
}

const setup = config => {
  const patchTruss = createPatchTruss(config.parms)
  const compactTruss = createCompactTruss(config.compactParms)
  const bankTruss = createBankTruss(config.patchCount, patchTruss, compactTruss)
  
  return {
    patchTruss,
    compactTruss,
    bankTruss,
    presetVoices: config.presetVoices,
    patchTransform,
    bankTransform: wholeBankTransform(bankTruss),
  }
}

module.exports = {
  setup,
}