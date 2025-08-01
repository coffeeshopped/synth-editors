
const ctrlSrcOptions: [Int:String] = {
  var opts = [
    0 : "Off",
    96 : "Bend",
    97 : "Aftertouch",
    ]
  (1...31).forEach { opts[$0] = "CC \($0)" }
  (33...95).forEach { opts[$0] = "CC \($0)" }
  return opts
}()

const parms = [
  ['tune', { b: 0x00, p: 4, rng: [24, 2024], dispOff: -1024 }],
  { inc: 1, b: 0x04, block: [
    ['key/shift', { rng: [40, 88], dispOff: -64 }],
    ['level', { }],
    ['scale/tune', { max: 1 }],
    ['patch/remain', { max: 1 }],
    ['mix', { opts: ["Mix","Parallel"] }],
    ['perf/channel', { opts: 17.map { $0 == 16 ? "Off" : "\($0 + 1)" } }],
  ] },
  ['patch/channel', { b: 0x0b, rng: [0, 15], dispOff: 1 }],
  { prefix: "scale/tune", count: 12, bx: 1, block: [
    ['', { b: 0x0c, dispOff: -64 }],
  ] },
  { prefix: "ctrl", count: 4, bx: 1, block: [
    ['src', { b: 0x18, opts: ctrlSrcOptions }],
  ] },
  { inc: 1, b: 0x1c, block: [
    ['rcv/pgmChange', { max: 1 }],
    ['rcv/bank', { max: 1 }],
    ['clock/src', { opts: ["Int", "MIDI", "USB"] }],
    ['tempo', { p: 2, rng: [20, 250] }],
  ] },
]

const commonPatchWerk = {
  single: "Global Common",
  parms: commonParms, 
  size: 0x21,
}

const eqParms = [
  ['on', { b: 0x00, max: 1 }],
  { prefix: '', count: 4, bx: 4, block: [
    ['lo/freq', { b: 0x01, opts: ["200", "400"] }],
    ['lo/gain', { b: 0x02, max: 30, dispOff: -15 }],
    ['hi/freq', { b: 0x03, opts: ["2000", "4000", "8000"] }],
    ['hi/gain', { b: 0x04, max: 30, dispOff: -15 }],
  ] },
]

const eqPatchWerk = {
  single: "Global Eq", 
  parms: eqParms, 
  size: 0x11,
}

const patchWerk = {
  multi: "Global", 
  map: [
    ["common", 0x0000, commonPatchWerk],
    ["eq", 0x0200, eqPatchWerk],
  ],
  initFile: "xv5050-global-init",
]

module.exports = {
  patchWerk,
}

