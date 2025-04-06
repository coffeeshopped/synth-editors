const Op4 = require('./op4.js')
const Op4Voice = require('./op4_voice.js')
const Op4Perf = require('./op4_perf.js')
const Op4Module = require('./op4_module.js')

const VoiceController = require('./dx21_voice_ctrlr.js')

const synth = "DX11"

const Voice = Op4Voice.setup({
  synth: synth,
  keys: ['aftertouch', 'extra', 'voice'],
  patchFile: 'dx11-voice-init',
  // TODO:
  // validSizes: [TX81Z.Voice.patchTruss.fileDataCount],
  validSizes: [],
  patchCount: 32,
  bankFile: 'dx11-voice-bank-init',
})

const Perf = Op4Perf.setup(require('./dx11_perf.js'))

const fetchTransforms = [
  // patch is different from TX81Z. Rest are same.
  ["patch", Op4.fetchWithHeader("8023AE")],
  ["perf", Op4.fetchWithHeader("8976PE")],
  ["micro/octave", Op4.fetchWithHeader("MCRTE0")],
  ["micro/key", Op4.fetchWithHeader("MCRTE1")],
  ["bank", Op4.fetch([0x04])],
  ["bank/perf", Op4.fetchWithHeader("8976PM")],
]

const editor = Op4Module.editorTruss(synth, Voice, Perf, fetchTransforms)

module.exports = {
  module: Op4Module.moduleTruss(editor, "dx11", VoiceController, Perf, [
    "#ca5e07",
    "#07afca",
    "#fa925f",
  ]),
}
