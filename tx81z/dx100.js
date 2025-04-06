const Op4 = require('./op4.js')
const Op4Voice = require('./op4_voice.js')
const Op4Module = require('./op4_module.js')

const VoiceController = require('./dx100_voice_ctrlr.js')

const synth = "DX100"

const Voice = Op4Voice.setup({
  synth: synth,
  keys: ['voice'],
  patchFile: 'dx100-init',
  validSizes: [],
  patchCount: 24,
  bankFile: 'dx100-voice-bank-init',
})

const fetchTransforms = [
  ["patch", Op4.fetch([0x03])],
  ["bank", Op4.fetch([0x04])],
]

const editor = Op4Module.editorTruss(synth, Voice, null, fetchTransforms)

module.exports = {
  module: Op4Module.moduleTruss(editor, "dx100", VoiceController, null, [
    "#ca5e07",
    "#07afca",
    "#fa925f",
  ]),
}
