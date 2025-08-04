const XV3080Global = require('./xv3080_global.js')

const eqParms = [
  ['on', { b: 0x00, max: 1 }],
  { prefix: '', count: 8, bx: 4, block: [
    ['lo/freq', { b: 0x01, opts: ["200", "400"] }],
    ['lo/gain', { b: 0x02, max: 30, dispOff: -15 }],
    ['hi/freq', { b: 0x03, opts: ["2000", "4000", "8000"] }],
    ['hi/gain', { b: 0x04, max: 30, dispOff: -15 }],
  ] }
]

const eqPatchWerk = {
  single: "Global Eq", 
  parms: eqParms, 
  size: 0x21,
}

// TODO: check those part addresses. Address math.
const patchWerk = {
  multi: "Global", 
  map: ([
    ["common", 0x0000, XV3080Global.commonPatchWerk],
    ["eq", 0x0200, eqPatchWerk],
  ]).concat((32).map(i => [["part", i], 0x1000 + (i * 0x100), XV3080Global.partPatchWerk])),
  initFile: "xv5080-global-init",
}
