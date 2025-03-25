const JVXP = require('./jvxp.js')
const XP80Global = require('./xp80_global.js')

const parms = XP80Global.parms.concat([
  ['system/tempo', { b: 0x60, packIso: JVXP.multiPack(0x60), rng: [20, 251] }],
])

module.exports = {
  patchWerk: JVXP.globalPatchWerk(parms, 0x62, "jv2080-global-init"),
  parms,
}
