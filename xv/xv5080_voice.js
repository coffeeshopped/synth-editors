
const outAssignOptions = XV5080.Voice.Tone.outAssignOptions <<<
[13 : "Tone"]

const commonParms = XV3080Voice.commonParms.concat([
  ['out/assign', { b: 0x27, opts: outAssignOptions }]
])

const commonPatchWerk = XVVoice.commonPatchWerk(commonParms)

const tonePatchWerk = XVVoice.tonePatchWerk(toneParms)

const toneParms = XV3080Voice.toneParms.concat([
  ['out/assign', { b: 0x11, opts: outAssignOptions }]
])

const waveGroupOptions = XV3080.Voice.Tone.waveGroupOptions

const outAssignOptions = [
  0 : "MFX",
  1 : "A",
  2 : "B",
  3 : "C",
  4 : "D",
  5 : "1",
  6 : "2",
  7 : "3",
  8 : "4",
  9 : "5",
  10 : "6",
  11 : "7",
  12 : "8"
]

const patchWerk = XVVoice.patchWerk({
    common: Common.patchWerk,
    tone: Tone.patchWerk, 
    fx: FX.patchWerk, 
    chorus: FX.chorusPatchWerk,
    reverb: FX.reverbPatchWerk,
  }, "xv5050-voice-init")

const bankWerk = XVVoice.bankWerk(patchWerk)

module.exports = {
  patchWerk,
  bankWerk,
}