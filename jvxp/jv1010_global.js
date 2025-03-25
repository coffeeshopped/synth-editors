const JVXP = require('./jvxp.js')
const JV2080Global = require('./jv2080_global.js')
const XP50Global = require('./xp50_global.js')

const parms = JV2080Global.parms.concat([
  ['ctrl/2/assign', { b: 0x62, opts: XP50Global.ctrlAssigns }],
  ['ctrl/2/out/mode', { b: 0x63, opts: XP50Global.ctrlOutModes }],
  ['ctrl/3/assign', { b: 0x64, opts: XP50Global.ctrlAssigns }],
  ['ctrl/3/out/mode', { b: 0x65, opts: XP50Global.ctrlOutModes }],
])

module.exports = {
  patchWerk: JVXP.globalPatchWerk(parms, 0x66, "jv1010-global-init")
}
