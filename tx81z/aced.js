require('../core/NumberUtils.js')
require('../core/ArrayUtils.js')
const Op4 = require('./op4.js')

// note the order: 4, 2, 3, 1. wacky
const parms = ([3,1,2,0]).mapWithIndex((op, i) => ({
  prefix: ['op', op], block: {
    b: i * 5, offset: [
      ["osc/mode", { b: 0, max: 1 }],
      ["fixed/range", { b: 1, max: 7 }],
      ["fine", { b: 2, max: 15 }],
      ["wave", { b: 3, opts: (8).map(i => `tx81z-wave-${i + 1}`) }],
      ["shift", { b: 4, max: 3 }],
    ] 
  }
})).concat([
  {
    inc: 1, b: 20, block: [
      ["reverb", { max: 7 }],
      ["foot/pitch", {max: 99} ],
      ["foot/amp", {max: 99} ],
    ]
  }  
])

// note the order: 4, 2, 3, 1. wacky
const compactParms = ([3,1,2,0]).mapWithIndex((op, i) => ({
  prefix: ["op", op], block: {
    b: 73 + i * 2, offset: [
      ["osc/mode", { b: 0, bit: 3 }],
      ["fixed/range", { b: 0, bits: [0, 3] }],
      ["fine", { b: 1, bits: [0, 4] }],
      ["wave", { b: 1, bits: [4, 7] }],
      ["shift", { b: 0, bits: [4, 6] }],
    ]
  }
})).concat([
  {
    inc: 1, b: 81, block: [
      ["reverb"],
      ["foot/pitch"],
      ["foot/amp"],
    ],
  },
]) 

const sysexData = ['yamCmd', ['channel', 0x7e, 0x00, 0x21], [["enc", "LM  8976AE"], "b"]]

const patchTruss = {
  type: 'singlePatch',
  id: 'tx81z.aced',
  bodyDataCount: 23,
  parseBody: 16,
  createFile: sysexData,
  parms: parms,
  randomize: () => [
    // TODO 
  //    (0..<4).forEach {
    //      self[[.op, .i($0), .shift]] = 0
    //    }
  ],
}

const compactTruss = {
  type: 'singlePatch',
  id: 'tx81z.aced.compact',
  bodyDataCount: 128,
  parms: compactParms,
}

module.exports = {
  patchTruss: patchTruss,
  compactTruss: compactTruss,
  patchWerk: Op4.patchWerk(0x13, null, sysexData),
}
