const VCED = require('./vced.js')
const ACED = require('./aced.js')
const Perf = require('./tx81z_perf.js')
const Op4micro = require('./op4_micro.js')
const Op4 = require('./op4.js')
const VoiceController = require('./tx81z_voice_ctrlr.js')
const PerfController = require('./tx81z_perf_ctrlr.js')
const MicroController = require('./tx81z_micro_ctrlr.js')
const TX81Z = require('./tx81z.js')

const synth = "TX81Z"

const voiceMap = [
  ["extra", ACED.patchTruss],
  ["voice", VCED.patchTruss],
]

const compactMap = [
  ["extra", ACED.compactTruss],
  ["voice", VCED.compactTruss],
]

const werkMap = [
  ["extra", ACED.patchWerk],
  ["voice", VCED.patchWerk],
]

const voicePatchTruss = Op4.createVoicePatchTruss(synth, voiceMap, "tx81z-init", [])
const voiceBankTruss = Op4.createVoiceBankTruss(voicePatchTruss, 32, "tx81z-voice-bank-init", compactMap)


const editor = Object.assign(Op4.editorTrussSetup, {
  name: synth,
  trussMap: [
    ["global", 'channel'],
    ["patch", voicePatchTruss],
    ["bank", voiceBankTruss],
  ].concat(Op4micro.trussMap).concat([
    ["perf", Perf.patchTruss],
    ["bank/perf", Perf.bankTruss],
    // ["backup", backupTruss],
  ]),
    
  fetchTransforms: [
    ["patch", Op4.fetchWithHeader("8976AE")],
    ["perf", Op4.fetchWithHeader("8976PE")],
    ["micro/octave", Op4.fetchWithHeader("MCRTE0")],
    ["micro/key", Op4.fetchWithHeader("MCRTE1")],
    ["bank", Op4.fetch([0x04])],
    ["bank/perf", Op4.fetchWithHeader("8976PM")],
  ],

  midiOuts: [
    ["patch", TX81Z.patchChangeTransform(werkMap)],
    ["perf", Perf.patchTransform],
    ["micro/octave", Op4micro.octWerk.patchChangeTransform],
    ["micro/key", Op4micro.fullWerk.patchChangeTransform],
    ["bank", TX81Z.voiceBankTransform(voiceBankTruss)],
    ["bank/perf", Perf.wholeBankTransform],
  ],
  
})

module.exports = {
  module: {
    editor: editor,
    manu: "Yamaha",
    subid: "tx81z",
    sections: [
      ['first', [
        'channel',
        ['voice', "Voice", VoiceController],
        ['perf', PerfController.ctrlr(Perf.presetVoices)],
        ['voice', "Micro Oct", MicroController.octController, "micro/octave"],
        ['voice', "Micro Full", MicroController.fullController, "micro/key"],
      ]],
      ['banks', [
        ['bank', "Voice Bank", "bank"],
        ['bank', "Perf Bank", "bank/perf"],
      ]],
      // 'backup',
    ],
    dirMap: [
      ['bank', "Voice Bank"],
      ['micro/octave', "Micro Octave*"],
      ['micro/key', "Micro Full*"],
      ['bank/perf', "Perf Bank"],
    ],
    colorGuide: [
      "#a2cd50",
      "#f93d31",
      "#00d053",
    ],
  },
}