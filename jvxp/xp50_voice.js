const JVXP = require('./jvxp.js')
const JV1080Voice = require('./jv1080_voice.js')

const commonParms = JV1080Voice.commonParms.concat([
  ['clock/src', { b: 0x48, opts: ["Patch","Sequencer"] }],
])

const commonPatchWerk = JVXP.perfCommonPatchWerk(commonParms, 0x49)

const patchWerk = JVXP.voicePatchWerk(commonPatchWerk, JV1080Voice.tonePatchWerk, "xp80-init")

module.exports = {
  patchWerk,
  bankWerk: JVXP.voiceBankWerk(patchWerk),
}
