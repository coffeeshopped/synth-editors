
const commonOutAssignOptions = Array.sparse([
  [0, "MFX"],
  [1, "A"],
  [2, "B"],
  [3, "C"],
  [5, "1"],
  [6, "2"],
  [7, "3"],
  [8, "4"],
  [9, "5"],
  [10, "6"],
  [13, "Tone"],
])

const commonParms = XV5050Voice.commonParms.concat([
  ['out/assign', { b: 0x27, opts: commonOutAssignOptions }]
])

const commonPatchWerk = XVVoice.commonPatchWerk(commonParms)

const toneOutAssignOptions = Array.sparse([
  [0, "MFX"],
  [1, "A"],
  [2, "B"],
  [3, "C"],
  [5, "1"],
  [6, "2"],
  [7, "3"],
  [8, "4"],
  [9, "5"],
  [10, "6"],
])

const toneParms = XV5050Voice.toneParms.concat([
  ['out/assign', { b: 0x11, opts: toneOutAssignOptions }],
])

const tonePatchWerk = XVVoice.tonePatchWerk(toneParms)

const waveGroupOptions =
  XV5050Voice.Tone.internalWaveGroupOptions <<<
  XV5050Voice.Tone.srxWaveGroupOptions <<<
  XV5050Voice.Tone.srjvWaveGroupOptions

const patchWerk = XV.Voice.patchWerk(common: Common.patchWerk, tone: Tone.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, initFile: "xv5050-voice-init")
  
const bankWerk = XV.Voice.bankWerk(patchWerk)

module.exports = {
  patchWerk,
  bankWerk,
}