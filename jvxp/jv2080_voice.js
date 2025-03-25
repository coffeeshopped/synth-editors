const JVXP = require('./jvxp.js')
const JV1080Voice = require('./jv1080_voice.js')

const categoryOptions = ["None", "Ac. Piano", "El. Piano", "Keyboards", "Bell", "Mallet", "Organ", "Accordion", "Harmonica", "Ac. Guitar", "El. Guitar", "Dist. Guitar", "Bass", "Synth Bass", "Strings", "Orchestra", "Hit & Stab", "Wind", "Flute", "Ac. Brass", "Synth Brass", "Sax", "Hard Lead", "Soft Lead", "Techno Synth", "Pulsating", "Synth FX", "Other Synth", "Bright Pad", "Soft Pad", "Vox", "Plucked", "Ethnic", "Fretted", "Percussion", "Sound FX", "Beat & Groove", "Drums", "Combination"]

const commonParms = JV1080Voice.commonParms.concat([
  ['clock/src', {b: 0x48, opts: ["Patch","System"] }],
  ['category', {b: 0x49, opt: categoryOptions }],
])

const commonPatchWerk = JVXP.perfCommonPatchWerk(commonParms, 0x4a)

const patchWerk = JVXP.voicePatchWerk(commonPatchWerk, JV1080Voice.tonePatchWerk, "jv2080-init")

module.exports = {
  patchWerk,
  bankWerk: JVXP.voiceBankWerk(patchWerk),
}
