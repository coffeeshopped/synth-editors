const XVVoice = require('./xv_voice.js')
const XV5050Voice = require('./xv5050_voice.js')

const outAssignOptions = [
  0 : "MFX",
  1 : "A",
  5 : "1",
  6 : "2",
]

const toneParms = XV5050Voice.toneParms.concat([
  ['out/assign', { b: 0x11, opts: outAssignOptions }]
])

const tonePatchWerk = XVVoice.tonePatchWerk(toneParms)

const commonOutAssignOptions = toneOutAssignOptions
commonOutAssignOptions[13] = "Tone"

const commonParms = XV5050Voice.commonParms.concat([
  ['out/assign', { b: 0x27, opts: commonOutAssignOptions }]
])

const commonPatchWerk = XVVoice.commonPatchWerk(commonParms)


const patchWerk = XVVoice.patchWerk({
  common: commonPatchWerk, 
  tone: Tone.patchWerk, 
  fx: FX.patchWerk,
  chorus: Chorus.patchWerk, 
  reverb: Reverb.patchWerk,
}, "xv5050-voice-init")

const bankWerk = XVVoice.bankWerk(patchWerk)

module.exports = {
  patchWerk,
  bankWerk,
}