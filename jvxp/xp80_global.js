const JVXP = require('./jvxp.js')
const XP50Global = require('./xp50_global.js')

const parms = XP50Global.parms.concat([
  { inc: 1, b: 0x52, block: [
    ['pedal/2/assign', { opts: XP50Global.pedalAssigns }],
    ['pedal/2/out/mode', { opts: XP50Global.ctrlOutModes }],
    ['pedal/2/polarity', { opts: XP50Global.polarityOptions }],
    ['pedal/3/assign', { opts: XP50Global.pedalAssigns }],
    ['pedal/3/out/mode', { opts: XP50Global.ctrlOutModes }],
    ['pedal/3/polarity', { opts: XP50Global.polarityOptions }],
    ['arp/style', { max: 32, dispOff: 1 }],
    ['arp/motif', { max: 33, dispOff: 1 }],
    ['arp/pattern', { max: 60, dispOff: 1 }],
    ['arp/accent/rate', { max: 100 }],
    ['arp/shuffle/rate', { rng: [50, 91] }],
    ['arp/key/velo', { opts: XP50Global.keyVeloOptions }],
    ['arp/octave/range', { max: 3, dispOff: -3 }],
    ['arp/part/number', { opts: (16).map(i => `Part ${i+1}`) }],
  ] }
])

module.exports = {
  patchWerk: JVXP.globalPatchWerk(parms, 0x60, "xp80-global-init"),
  parms,
}
