const Op4 = require('./op4.js')

const werk = (displayType, bodyDataCount, parms, initFile, subCmdByte, sysexIndex) => {
  
  const sysexData = ['>',
    [["enc", `LM  MCRTE${sysexIndex}`], "b"],
    ['yamCmd', ['channel', 0x7e, 0x00, 0x22], "b"],
  ]

  const patchWerk = Op4.patchWerk(0x10, null, sysexData)

  const truss = {
    type: 'singlePatch',
    id: `tx81z.${displayType}`,
    bodyDataCount: bodyDataCount,
    parms: parms, 
    initFile: initFile, 
    createFile: sysexData,
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
      coalesce: 10, 
      param: (path, parm, value) => {
        const key = path[0]
        var note = 0
        var fine = 0
        if (path[path.length - 1] == 'note') {
          note = Math.max(0, value)
          fine = ['trussValues', truss, [[key, 'fine']]]
        }
        else {
          note = ['trussValues', truss, [[key, 'note']]]
          fine = Math.max(0, value)
        }
        return [[patchWerk.paramData([subCmdByte, key, note, fine]), 0]]
      }, 
      patch: patchWerk.sysexData,
    },
  }
}

const noteIso = {
  type: 'noteName',
  zeroNote: "C-2",
}

const octParms = [
  {
    prefix: [], count: 12, bx: 2, block: [
      ["note", { b: 0, iso: noteIso, rng: [13, 109] }],
      ["fine", { b: 1, max: 63 }],
    ]
  },
]

const fullParms = [
  {
    prefix: [], count: 128, bx: 2, block: [
      ["note", { b: 0, iso: noteIso, rng: [13, 109] }],
      ["fine", { b: 1, max: 63 }],
    ]
  },
]

const octWerk = werk("micro.oct", 24, octParms, "", 0x7d, 0)
const fullWerk = werk("micro.full", 256, fullParms, "", 0x7e, 1)

module.exports = {
  octWerk: octWerk,
  fullWerk: fullWerk,
  trussMap: [
    ["micro/octave", octWerk.truss],
    ["micro/key", fullWerk.truss],
  ],
}