const FS1R = require('./fs1r.js')

const sysexData = FS1R.sysexData([0x00, 0x00, 0x00])

const ctrlOptions = Array.sparse(
  (95).map(i => [i+1, i == 31 ? "Invalid" : `${i + 1}`])
)

const channels = (16).map(i => `${i + 1}`)
channels[0x10] = "All"
channels[0x7f] = "Off"

const parms = [
  ["detune", { b: 0x0, dispOff: -64}],
  ["note/shift", { b: 0x06, dispOff: -64}],
  ["dump/interval", { b: 0x07, opts: ["50","100","150","200","300"]}],
  ["pgmChange/mode", { b: 0x08, opts: ["Performance","Multi"]}],
  ["perf/channel", { b: 0x09, opts: channels}],
  ["knob/mode", { b: 0x0b, opts: ["Abs","Rel"]}],
  ["breath/curve", { b: 0x0d, opts: ["Thru","1","2","3"]}],
  ["velo/curve", { b: 0x0e, opts: ["thru", "sft1", "sft2", "wid", "hrd"]}],
  ["rcv/sysex", { b: 0x10, max: 1}],
  ["rcv/note", { b: 0x11, opts: ["All","Odd","Even"]}],
  ["rcv/bank/select", { b: 0x12, max: 1}],
  ["rcv/pgmChange", { b: 0x13, max: 1}],
  ["rcv/knob", { b: 0x14, max: 1}],
  ["send/knob", { b: 0x15, max: 1}],
  { prefix: 'knob/ctrl', count: 4, bx: 1, block: [
    ["number", { b: 0x16, opts: ctrlOptions }],
  ] },
  { prefix: 'midi/ctrl', count: 4, bx: 1, block: [
    ["number", { b: 0x1a, opts: ctrlOptions }],
  ] },
  ["foot/ctrl/number", { b: 0x1e, opts: ctrlOptions}],
  ["breath/ctrl/number", { b: 0x1f, opts: ctrlOptions}],
  ["formant/ctrl/number", { b: 0x20, opts: ctrlOptions}],
  ["fm/ctrl/number", { b: 0x21, opts: ctrlOptions}],
  { prefix: 'preview/note', count: 4, bx: 2, block: [
    ["", { b: 0x22 }],
  ] },
  { prefix: 'preview/velo', count: 4, bx: 2, block: [
    ["", { b: 0x23 }],
  ] },
  ["memory", { b: 0x47, opts: ["128 Voice", "64 Voice / 6 Fseq"]}],
  ["deviceId", { b: 0x49, max: 15, dispOff: 1}],
]

module.exports = {
  patchTruss: {
    single: "global", 
    parms: parms, 
    createFile: sysexData, 
    parseBody: ['bytes', { start: 9, count: 76 }],
  },
  patchTransform: {
    throttle: 100, 
    singlePatch: [[sysexData, 100]],
    param: (path, parm, value) => [[FS1R.dataSetMsg([0x00, 0x00, parm.b], value), 30]], 
  },
}