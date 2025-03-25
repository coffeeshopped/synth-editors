const JVXP = require('./jvxp.js')
const JV1080Global = require('./jv1080_global.js')

const keyVeloOptions = (128).map(i => i == 0 ? "Real" : `${i}`)
const pedalAssigns = (96).map(i => `CC ${i}`).concat(["Bender","Aftertouch","Pgm Up","Pgm Down","Start/Stop","Punch In/Out","Tap Tempo"])

const ctrlOutModes = ["Off","Int","MIDI","Int/MIDI"]

const ctrlAssigns = (96).map(i => `CC ${i}`).concat(["Bender","Aftertouch"])

const polarityOptions = ["Standard","Reverse"]

const parms = JV1080Global.parms.concat([
  ['send/pgmChange', { b: 0x28, max: 1 }],
  ['send/bank/select', { b: 0x29, max: 1 }],
  ["patch/send/channel", { b: 0x2a, max: 17, iso: ['switch', [
    [16, "Rcv Channel"],
    [17, "Off"],
  ], ['+', 1]] }],
  ['transpose', { b: 0x2b, max: 1 }],
  ['transpose/amt', { b: 0x2c, max: 11, dispOff: -5 }],
  ['octave/shift', { b: 0x2d, max: 6, dispOff: -3 }],
  ['key/velo', { b: 0x2e, opts: keyVeloOptions }],
  ['key/sens', { b: 0x2f, opts: ["Light","Stanard","Heavy"] }],
  ['aftertouch/sens', { b: 0x30, max: 100 }],
  ['pedal/0/assign', { b: 0x31, opts: pedalAssigns }],
  ['pedal/0/out/mode', { b: 0x32, opts: ctrlOutModes }],
  ['pedal/0/polarity', { b: 0x33, opts: polarityOptions }],
  ['pedal/1/assign', { b: 0x34, opts: pedalAssigns }],
  ['pedal/1/out/mode', { b: 0x35, opts: ctrlOutModes }],
  ['pedal/1/polarity', { b: 0x36, opts: polarityOptions }],
  ['ctrl/0/assign', { b: 0x37, opts: ctrlAssigns }],
  ['ctrl/0/out/mode', { b: 0x38, opts: ctrlOutModes }],
  ['ctrl/1/assign', { b: 0x39, opts: ctrlAssigns }],
  ['ctrl/1/out/mode', { b: 0x3a, opts: ctrlOutModes }],
  ['hold/out/mode', { b: 0x3b, opts: ctrlOutModes }],
  ['hold/polarity', { b: 0x3c, opts: polarityOptions }],
  { prefix: "bank/select", count: 7, bx: 3, block: [
    ['on', { b: 0x3d, max: 1 }],
    ['hi', { b: 0x3e }],
    ['lo', { b: 0x3f }],
  ] },
])

module.exports = {
  patchWerk: JVXP.globalPatchWerk(parms, 0x52, "xp50-global-init"),
  parms,
  ctrlOutModes,
  ctrlAssigns,
  pedalAssigns,
}
