const Voice = require('./fb01_voice.js')

const parms = [
  ['voice/load/mode', { b: 0x08, p: 0x14, max: 1 }],
  ['lfo/speed', { b: 0x09, p: 0x10 }],
  ['amp/mod/depth', { b: 0x0a, p: 0x11 }],
  ['pitch/mod/depth', { b: 0x0b, p: 0x12 }],
  ['lfo/wave', { b: 0x0c, p: 0x13, opts: Voice.lfoWaveOptions }],
  ['key/rcv/mode', { b: 0x0d, opts: ["All","Even","Odd"] }],
  { prefix: "part", count: 8, bx: 0x10, block:
      { b: 0x20, offset: [
        ['voice/reserve', { b: 0x00, max: 8 }],
        ['channel', { b: 0x01, max: 15, dispOff: 1 }],
        ['key/hi', { b: 0x02 }],
        ['key/lo', { b: 0x03 }],
        ['bank', { b: 0x04, opts: (7).map(i => `${i+1}`) }],
        ['pgm', { b: 0x05, max: 47 }],
        ['detune', { b: 0x06, rng: [-64, 63] }],
        ['octave', { b: 0x07, max: 4, dispOff: -2 }],
        ['level', { b: 0x08 }],
        ["pan", { b: 0x09, opts: [
          [0, "Left"],
          [64, "L+R"],
          [127, "Right"],
        ] }],
        ['lfo/on', { b: 0x0a, max: 1 }],
        ['porta', { b: 0x0b }],
        ['bend', { b: 0x0c, max: 12 }],
        ['mono', { b: 0x0d, max: 1 }],
        ['pitch/mod/depth/ctrl', { b: 0x0e, opts: Voice.ctrlOptions }],
      ] }
  },
]

// pass -1 for temp patch sysex data
const sysexData = (location) => ['yamCmd', 
  [0x75, 'channel', 0, location < 0 ? 1 : 2, location < 0 ? 0 : location, 0x01, 0x20], 
  'b',
]

const tempSysexData = sysexData(-1)

const patchTruss = {
  type: 'singlePatch',
  id: 'perf',
  bodyDataCount: 160,
  namePack: [0, 7],
  parms: parms,
  initFile: "fb01-perf-init",
  createFile: tempSysexData,
  parseBody: 9,
}   
  
const bankTruss = {
  type: 'compactSingleBank',
  patchTruss: patchTruss,
  patchCount: 16, 
  fileDataCount: 2616,
  createFile: {
    wrapper: ['yamSyx', [0x75, 'channel', 0x00, 0x03, 0x00, 'b']],
    patchBodyTransform: [0x01, 0x20, 'b', ['yamChk', 'b']],
  },
  parseBody: {
    offset: 7, 
    patchByteCount: 163,
    patchBodyTransform: ['bytes', {start: 2, count: 160}]
  }
} 

module.exports = {
  patchTruss,
  bankTruss,
  tempSysexData,
}