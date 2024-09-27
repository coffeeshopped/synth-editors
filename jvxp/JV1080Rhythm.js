const JVXP = require('./JVXP.js')

const commonPatchWerk = { 
  single: "Rhythm Common",
  size: 0xc, 
  name: [0, 0x0c],
  parms: [],
}

const veloTSenses = ["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"]

const noteParms = [
  ['on', { b: 0x00, max: 1 }],
  ['wave/group', { b: 0x01, opts: ["Int","PCM","Exp"] }],
  ['wave/group/id', { b: 0x02 }],
  ['wave/number', { b: 0x03, packIso: JVXP.multiPack(0x03), max: 254 }],
  ['wave/gain', { b: 0x05, opts: ["-6","0","+6","+12"] }],
  ['bend/range', { b: 0x6, max: 12 }],
  ['mute/group', { b: 0x7, max: 31 }],
  ['env/sustain', { b: 0x8, max: 1 }],
  ['volume/ctrl', { b: 0x9, max: 1 }],
  ['hold/ctrl', { b: 0xa, max: 1 }],
  ['pan/ctrl', { b: 0xb, opts: ["Off","Continuous","Key-On"] }],
  ['src/key', { b: 0x0c }],
  ['fine', { b: 0x0d, max: 100, dispOff: -50 }],
  ['random/pitch', { b: 0x0e, opts: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"] }],
  { prefix: "pitch/env", block: [
    { inc: 1, b: 0x0f, block: [
      ['depth', { max: 24, dispOff: -12 }],
      ['velo/sens', { max: 125 }],
      ['velo/time', { opts: veloTSenses }],
      ['time/0', { }],
      ['time/1', { }],
      ['time/2', { }],
      ['time/3', { }],
      ['level/0', { max: 126, dispOff: -63 }],
      ['level/1', { max: 126, dispOff: -63 }],
      ['level/2', { max: 126, dispOff: -63 }],
      ['level/3', { max: 126, dispOff: -63 }],
    ] },
  ] },
  ['filter/type', { b: 0x1a, opts: ["Off","LPF","BPF","HPF","PKG"] }],
  ['cutoff', { b: 0x1b }],
  ['reson', { b: 0x1c }],
  ['reson/velo/sens', { b: 0x1d, max: 125 }],
  { prefix: "filter/env", block: [
    { inc: 1, b: 0x1e, block: [
      ['depth', { max: 126, dispOff: -63 }],
      ['velo/sens', { max: 125 }],
      ['velo/time', { opts: veloTSenses }],
      ['time/0', { }],
      ['time/1', { }],
      ['time/2', { }],
      ['time/3', { }],
      ['level/0', { }],
      ['level/1', { }],
      ['level/2', { }],
      ['level/3', { }],
    ] },
  ] },
  { inc: 1, b: 0x29, block: [
    ['tone/level', { }],
    { prefix: "amp/env", block: [
      ['velo/sens', { max: 125 }],
      ['velo/time', { opts: veloTSenses }],
      ['time/0', { }],
      ['time/1', { }],
      ['time/2', { }],
      ['time/3', { }],
      ['level/0', { }],
      ['level/1', { }],
      ['level/2', { }],
    ] },
    ['pan', { dispOff: -64 }],
    ['random/pan', { max: 63 }],
    ['alt/pan', { rng: [1, 128], dispOff: -63 }],
    ['out/assign', { opts: ["Mix","FX","Output 1","Output 2"] }],
    ['out/level', { }],
    ['chorus', { }],
    ['reverb', { }],
  ] }
]

const notePatchWerk = {
  single: "Rhythm Note", 
  parms: noteParms, 
  size: 0x3a, 
  initFile: "jv1080-rhythm-note-init", 
  // randomize: { [
  // "on" : 1,
  // "wave/group" : 0,
  // "wave/group/id" : (1...2).rand(),
  // "tone/level" : 127,
  // "pan" : 64,
  // "out/assign" : 0,
  // "out/level" : 127,
  // "random/pitch" : 0,
  // ] }
}

const patchWerk = {
  multi: "Rhythm",
  map: [
    ["common", 0x0000, commonPatchWerk],
  ].concat(
    (64).map(i => [`note/${i}`, [0x23 + i, 0x00], notePatchWerk])
  ),
  initFile: "jv1080-rhythm-init",
}

module.exports = {
  patchWerk: patchWerk,
  bankWerk: {
    multiBank: patchWerk,
    patchCount: 2,
    initFile: "jv1080-rhythm-bank-init",
    iso: ['lsbyte', 2, 0x40],
  },
  noteParms: noteParms,
}
