const D110System = require('./d110_system.js')

const toneGroupOptions = ["A","B","Int","Rhythm"]

const toneNumberOptions = (64).map(i => `${i+1}`)

const assignModeOptions = ["Poly 1","Poly 2","Poly 3","Poly 4"]

const parms = [
  ['key/mode', { b: 0x00, opts: ["Whole","Dual","Split"] }],
  ['split/pt', { b: 0x01, iso: ['noteName', "C2"] max: 61 }],
  ['lo/tone/group', { b: 0x02, opts: toneGroupOptions }],
  ['lo/tone/number', { b: 0x03, opts: toneNumberOptions }],
  ['hi/tone/group', { b: 0x04, opts: toneGroupOptions }],
  ['hi/tone/number', { b: 0x05, opts: toneNumberOptions }],
  ['lo/tune', { b: 0x06, max: 48, dispOff: -24 }],
  ['hi/tune', { b: 0x07, max: 48, dispOff: -24 }],
  ['lo/fine', { b: 0x08, max: 100, dispOff: -50 }],
  ['hi/fine', { b: 0x09, max: 100, dispOff: -50 }],
  ['lo/bend', { b: 0x0a, max: 24 }],
  ['hi/bend', { b: 0x0b, max: 24 }],
  ['lo/assign/mode', { b: 0x0c, opts: assignModeOptions }],
  ['hi/assign/mode', { b: 0x0d, opts: assignModeOptions }],
  ['lo/out/assign', { b: 0x0e, max: 1 }],
  ['hi/out/assign', { b: 0x0f, max: 1 }],
  ['reverb/type', { b: 0x10, opts: D110System.reverbTypeOptions }],
  ['reverb/time', { b: 0x11, max: 7, dispOff: 1 }],
  ['reverb/level', { b: 0x12, max: 7 }],
  ['balance', { b: 0x13, max: 100, dispOff: -50 }],
  ['level', { b: 0x14, max: 100 }],
]

const patchWerk = {
  single: "Patch",
  parms: parms,
  size: 0x26,
  name: [0x15, 0x24],
}

const bankWerk = {
  compactSingleBank: patchWerk,
  patchCount: 128, 
  validSizes: [5054],
}

module.exports = {
  patchWerk,
  bankWerk,
}