const XV5050Global = require('./xv5050_global.js')

const commonParms = [
  ['mode', { b: 0x00, opts: ["Perform","Patch","GM1","GM2","GS"] }],
  ['tune', { b: 0x01, packIso: XV.multiPack4(0x01), rng: [24, 2024], dispOff: -1024 }],
  ['key/shift', { b: 0x05, rng: [40, 88], dispOff: -64 }],
  ['level', { b: 0x06 }],
  ['scale/tune', { b: 0x07, max: 1 }],
  ['patch/remain', { b: 0x08, max: 1 }],
  ['mix', { b: 0x09, opts: ["Mix","Parallel"] }],
  ['fx', { b: 0x0a, max: 1 }],
  ['chorus', { b: 0x0b, max: 1 }],
  ['reverb', { b: 0x0c, max: 1 }],
  ['perf/channel', { b: 0x0d, opts: 17.map { $0 == 16 ? "Off" : "\($0 + 1)" } }],
  ['perf/bank/hi', { b: 0x0e }],
  ['perf/bank/lo', { b: 0x0f }],
  ['perf/pgm/number', { b: 0x10 }],
  ['patch/channel', { b: 0x11, rng: [0, 15], dispOff: 1 }],
  ['patch/bank/hi', { b: 0x12 }],
  ['patch/bank/lo', { b: 0x13 }],
  ['patch/pgm/number', { b: 0x14 }],
  ['clock/src', { b: 0x15, opts: ["Int", "MIDI"] }],
  ['tempo', { b: 0x16, packIso: XV.multiPack2(0x16), rng: [20, 250] }],
  { prefix: "ctrl", count: 4, bx: 1, block: [
    ['src', { b: 0x18, opts: XV5050Global.commonCtrlSrcOptions }],
  ] },
  ['rcv/pgmChange', { b: 0x1c, max: 1 }],
  ['rcv/bank', { b: 0x1d, max: 1 }],
]

const commonPatchWerk = {
  single: "Global Common",
  parms: parms,
  size: 0x1e,
}


const partParms = [
  { prefix: "scale/tune", count: 12, bx: 1, block: [
    ['', { b: 0, dispOff: -64 }],
  ] },
]

const partPatchWerk = {
  single: "Global Part", 
  parms: parms, 
  size: 0x0c,
}

// TODO: that part address calc is wrong. Not doing roland address math.
const patchWerk = {
  multi: "Global",
  map: [
    ["common", 0x0000, commonPatchWerk],
  ].concat((32).map(i => [["part", i], 0x1000 + (i * 0x100), partPatchWerk])),
  initFile: "xv3080-global-init",
}

module.exports = {
  patchWerk,
}
