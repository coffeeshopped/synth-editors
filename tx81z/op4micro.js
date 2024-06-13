const Op4 = require('./op4.js')

const werk = (displayType, bodyDataCount, parms, initFile, subCmdByte, sysexIndex) => {
  const sysexData = (bd, channel) => 
    yamahaSysexData(channel, [0x7e, 0x00, 0x22], `LM  MCRTE${sysexIndex}`.sysexBytes().concat(bd))
  
  const patchWerk = Op4.patchWerk(0x10, null, sysexData)
  
  const paramData = (key, note, fine, channel) => patchWerk.paramData(channel, [subCmdByte, key, note, fine])

  const truss = {
    type: 'singlePatch',
    id: `tx81z.${displayType}`,
    bodyDataCount: bodyDataCount,
    parms: parms, 
    initFile: initFile, 
    createFileData: (bd) => sysexData(bd, 0),
    parseOffset: 16,
  }
  
  return {
    sysexIndex: sysexIndex,
    subCmdByte: subCmdByte,
    patchWerk: patchWerk,
    truss: truss,
        
    patchChangeTransform: {
      type: 'singlePatch',
      throttle: 100, 
      editorVal: sysexChannel, 
      coalesce: 10, 
      param: (editorVal, bodyData, parm, path, value) => {
        const key = path[0]
        var note = 0
        var fine = 0
        if path.last() == 'note' {
          note = Math.max(0, value)
          fine = patchTrussGetValue(truss, bodyData, [key, 'fine'])
        }
        else {
          note = patchTrussGetValue(truss, bodyData, [key, 'note'])
          fine = Math.max(0, value)
        }
        return [['syx', paramData(key, note, fine, editorVal), 0]]
      }, 
      patch: patchWerk.patchTransform,
    },
  }
}

const noteIso = {
  type: 'noteName',
  zeroNote: "C-2",
}

const octParms = [
  {
    prefix: [], count: 12, bx: 2, block: (i) => [
      ["note", { b: 0, iso: noteIso, rng: [13, 109] }],
      ["fine", { b: 1, max: 63 }],
    ]
  },
]

const fullParms = [
  {
    prefix: [], count: 128, bx: 2, block: (i) => [
      ["note", { b: 0, iso: noteIso, rng: [13, 109] }],
      ["fine", { b: 1, max: 63 }],
    ]
  },
]

module.exports = {
  octWerk: werk("micro.oct", 24, octParms, "", 0x7d, 0),
  fullWerk: werk("micro.full", 256, fullParms, "", 0x7e, 1),
}