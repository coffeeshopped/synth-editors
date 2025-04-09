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

const createBankTruss = (patchCount, patchTruss, compactTruss) => {
  // if patchCount < 32, need to add padding 0's
  // banks always hold 32 patches, even on the synths that only have 24 "real" patches
  const patchPad = 32 - patchCount
  const padData = (compactTruss.bodyDataCount * patchPad).map(i => 0)
  return {
    type: 'compactSingleBank',
    patchTruss: patchTruss,
    patchCount: patchCount,
    fileDataCount: 2450, 
    createFile: {
      wrapper: ['>',
        ['b', padData],
        ['yamCmd', ['channel', 0x7e, 0x13, 0x0a], [['enc', "LM  8976PM"], 'b']]
      ],
      patchBodyTransform: ['trussTransform', { from: patchTruss, to: compactTruss }],
    },
    parseBody: {
      offset: 16,
      patchByteCount: compactTruss.bodyDataCount,
      patchBodyTransform: ['trussTransform', { from: compactTruss, to: patchTruss }],
    },
  }
}


const patchTransform = {
  type: 'singlePatch',
  throttle: 30, 
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
    bankTransform: bankTruss,
  }
}

module.exports = {
  setup,
}