require('./utils.js')
const Op4 = require('./op4.js')

  // note the order: 4, 2, 3, 1. wacky
const parms = ([3,1,2,0]).map((op, i) => ({
  prefix: ['op', op], block: {
    b: i * 13, offset: [
      ["attack", { b: 0, max: 31 }],
      ["decay/0", { b: 1, max: 31 }],
      ["decay/1", { b: 2, max: 31 }],
      ["release", { b: 3, rng: [1, 16] }],
      ["decay/level", { b: 4, max: 15 }],
      ["level/scale", { b: 5, max: 99 }],
      ["rate/scale", { b: 6, max: 3 }],
      ["env/bias/sens", { b: 7, max: 7 }],
      ["amp/mod", { b: 8, max: 1 }],
      ["velo", { b: 9, max: 7 }],
      ["level", { b: 10, max: 99 }],
      ["coarse", { b: 11, max: 63 }],
      ["detune", { b: 12, max: 6, dispOff: -3 }],
    ]
  }
})).concat([
  { inc: 1, b: 52, block: [
    ["algo", { max: 7, dispOff: 1 }],
    ["feedback", { max: 7 }],
    ["lfo/speed", { max: 99 }],
    ["lfo/delay", { max: 99 }],
    ["pitch/mod/depth", { max: 99 }],
    ["amp/mod/depth", { max: 99 }],
    ["lfo/sync", { max: 1 }],
    ["lfo/wave", { opts: ["Saw Up","Square","Triangle","S/Hold"] }],
    ["pitch/mod/sens", { max: 7 }],
    ["amp/mod/sens", { max: 3 }],
    ["transpose", { max: 48, dispOff: -24 }],
    ["poly", { max: 1 }],
    ["bend", { max: 12 }],
    ["porta/mode", { max: 1 }],
    ["porta/time", { max: 99 }],
    ["foot/volume", { max: 99 }],
    ["sustain", { max: 1 }],
    ["porta", { max: 1 }],
    ["chorus", { max: 1 }],
    ["modWheel/pitch", { max: 99 }],
    ["modWheel/amp", { max: 99 }],
    ["breath/pitch", { max: 99 }],
    ["breath/amp", { max: 99 }],
    ["breath/pitch/bias", { max: 99, dispOff: -50 }],
    ["breath/env/bias", { max: 99 }],
  ] },
  { inc: 1, b: 87, block: {
    prefix: "pitch/env", block: [
      // Pitch env is on DX21
      ["rate/0", { max: 99 }],
      ["rate/1", { max: 99 }],
      ["rate/2", { max: 99 }],
      ["level/0", { max: 99 }],
      ["level/1", { max: 99 }],
      ["level/2", { max: 99 }],
    ],
  } },
])

    // note the order: 4, 2, 3, 1. wacky
const compactParms = ([3,1,2,0]).map((op, i) => ({
  prefix: ["op", op], block: {
    b: i * 10, offset: [
      ["attack", { b: 0 }],
      ["decay/0", { b: 1 }],
      ["decay/1", { b: 2 }],
      ["release", { b: 3 }],
      ["decay/level", { b: 4 }],
      ["level/scale", { b: 5 }],
      ["rate/scale", { b: 9, bits: [3, 5] }],
      ["env/bias/sens", { b: 6, bits: [3, 6] }],
      ["amp/mod", { b: 6, bit: 6 }],
      ["velo", { b: 6, bits: [0, 3] }],
      ["level", { b: 7 }],
      ["coarse", { b: 8 }],
      ["detune", { b: 9, bits: [0, 3] }],
    ]
  }
})).concat([
  [
    ["algo", { b: 40, bits: [0, 3] }],
    ["feedback", { b: 40, bits: [3, 6] }],
    ["lfo/speed", { b: 41 }],
    ["lfo/delay", { b: 42 }],
    ["pitch/mod/depth", { b: 43 }],
    ["amp/mod/depth", { b: 44 }],
    ["lfo/sync", { b: 40, bit: 6 }],
    ["lfo/wave", { b: 45, bits: [0, 2] }],
    ["pitch/mod/sens", { b: 45, bits: [4, 7] }],
    ["amp/mod/sens", { b: 45, bits: [2, 4] }],
    ["transpose", { b: 46 }],
    ["poly", { b: 48, bit: 3 }],
    ["bend", { b: 47 }],
    ["porta/mode", { b: 48, bit: 0 }],
    ["porta/time", { b: 49 }],
    ["foot/volume", { b: 50 }],
    ["sustain", { b: 48, bit: 2 }],
    ["porta", { b: 48, bit: 1 }],
    ["chorus", { b: 48, bit: 4 }],
    ["modWheel/pitch", { b: 51 }],
    ["modWheel/amp", { b: 52 }],
    ["breath/pitch", { b: 53 }],
    ["breath/amp", { b: 54 }],
    ["breath/pitch/bias", { b: 55 }],
    ["breath/env/bias", { b: 56 }],
  
    // Pitch env is on DX21
    ["pitch/env/rate/0", { b: 67 }],
    ["pitch/env/rate/1", { b: 68 }],
    ["pitch/env/rate/2", { b: 69 }],
    ["pitch/env/level/0", { b: 70 }],
    ["pitch/env/level/1", { b: 71 }],
    ["pitch/env/level/2", { b: 72 }],
  ],
])

const sysexData = ['yamCmd', ['channel', 0x03, 0x00, 0x5d], "b"]

const patchTruss = {
  type: 'singlePatch',
  id: 'tx81z.vced',
  bodyDataCount: 93,
  initFile: "dx100-init",
  parseBody: 6,
  createFile: sysexData,
  parms: parms,
  namePack: [77, 87],
  randomize: () => [
    // TODO 
    //      let algos = Self.algorithms()
    //      let algoIndex = self[[.algo]] ?? 0
    //
    //      let algo = algos[algoIndex]
    //
    //      // make output ops audible
    //      for outputId in algo.outputOps {
    //        let op: SynthPath = [.op, .i(outputId)]
    //        self[op + [.level]] = 90+(0...9).random()!
    //        self[op + [.level, .scale]] = 0
    //      }
    //
    //      self[[.transpose]] = 24
    //      self[[.porta, .time]] = 0
    //      self[[.modWheel, .pitch]] = 0
    //      self[[.modWheel, .amp]] = 0
    //      self[[.breath, .pitch]] = 0
    //      self[[.breath, .amp]] = 0
    //      self[[.breath, .pitch, .bias]] = 50
    //      self[[.breath, .env, .bias]] = 0
    //
    //
    //      // flat pitch env
    //      for i in 0..<3 {
    //        self[[.pitch, .env, .level, .i(i)]] = 50
    //      }
    //
    //      // all ops on
    //      for op in 0..<4 { self[[.op, .i(op), .on]] = 1 }
  ],
}

const compactTruss = {
  type: 'singlePatch',
  id: 'tx81z.vced.compact',
  bodyDataCount: 128,
  namePack: [57, 67],
  parms: compactParms,
}
  
module.exports = {
  patchTruss: patchTruss,
  compactTruss: compactTruss,
  patchWerk: Op4.patchWerk(0x12, sysexData),
}

