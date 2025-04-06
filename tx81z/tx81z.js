const Op4 = require('./op4.js')
const Op4Voice = require('./op4_voice.js')
const Op4Perf = require('./op4_perf.js')
const Op4Module = require('./op4_module.js')

const VoiceController = require('./tx81z_voice_ctrlr.js')

const synth = "TX81Z"

const Voice = Op4Voice.setup({
  synth: synth,
  keys: ['extra', 'voice'],
  patchFile: 'tx81z-init',
  validSizes: [],
  patchCount: 32,
  bankFile: 'tx81z-voice-bank-init',
})

const Perf = Op4Perf.setup(require('./tx81z_perf.js'))

const fetchTransforms = [
  ["patch", Op4.fetchWithHeader("8976AE")],
  ["perf", Op4.fetchWithHeader("8976PE")],
  ["micro/octave", Op4.fetchWithHeader("MCRTE0")],
  ["micro/key", Op4.fetchWithHeader("MCRTE1")],
  ["bank", Op4.fetch([0x04])],
  ["bank/perf", Op4.fetchWithHeader("8976PM")],
]

const editor = Op4Module.editorTruss(synth, Voice, Perf, fetchTransforms)

module.exports = {
  module: Op4Module.moduleTruss(editor, "tx81z", VoiceController, Perf, [
    "#a2cd50",
    "#f93d31",
    "#00d053",
  ]),
}