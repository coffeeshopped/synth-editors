const parms = ([3,1,2,0]).forEachWithIndex((op, i) => {
  // note the order: 4, 2, 3, 1. wacky
  return {
    prefix: ['op', op], block: {
      offset: true, b: i * 5, block: [
        ["osc/mode", { b: 0, max: 1 }],
        ["fixed/range", { b: 1, max: 7 }],
        ["fine", { b: 2, max: 15 }],
        ["wave", { b: 3, .opts(8.map { "tx81z-wave-\($0 + 1)" }) }],
        ["shift", { b: 4, max: 3 }],
      ] 
    }
  }
}).concat([
  {
    inc: true, b: 20, block: [
      ["reverb", { max: 7 }],
      ["foot/pitch", max: 99 }],
      ["foot/amp", max: 99 }],
    ]
  }  
])

const compactParms = ([3,1,2,0]).forEachWithIndex((op, i) => {
  // note the order: 4, 2, 3, 1. wacky
  return {
    prefix: ["op", op], block: {
      offset: true, b: 73 + i * 2, block: [
        ["osc/mode", { b: 0, bit: 3 }],
        ["fixed/range", { b: 0, bits: [0, 3] }],
        ["fine", { b: 1, bits: [0, 4] }],
        ["wave", { b: 1, bits: [4, 7] }],
        ["shift", { b: 0, bits: [4, 6] }],
      ]
    }
  }
}).concat([
  {
    inc: true, b: 81, [
      ["reverb"],
      ["foot/pitch"],
      ["foot/amp"],
    ],
  },
]) 

const cmdByte = 0x13

const sysexData = (channel, bodyData) => 
  yamahaSysexData(channel, [0x7e, 0x00, 0x21], "LM  8976AE".sysexBytes().concat(bodyData))

const paramData = (channel, cmdBytes) => yamahaParamData(channel, [cmdByte].concat(cmdBytes))

const patchTransform = (editorVal, bodyData) =>  [['syx', sysexData(bodyData, editorVal), 100]]

const patchTruss = {
  type: 'singlePatch',
  id: 'tx81z.aced',
  bodyDataCount: 23,
  parseOffset: 16,
  createFile: (bodyData) => sysexData(0, bodyData),
  parms: parms,
  randomize: () => [
    // TODO 
  ],
}

    // compact: (body: 128, namePack: nil, parms: compactParms))

  //  open func randomize() {
  //    randomizeAllParams()
  //    (0..<4).forEach {
  //      self[[.op, .i($0), .shift]] = 0
  //    }
  //  }
  
module.exports = {
  patchTruss: patchTruss,
  sysexData: sysexData,
}


