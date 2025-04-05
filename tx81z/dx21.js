const Op4 = require('./op4.js')
const VCED = require('./vced.js')
const VoiceController = require('./dx21_voice_ctrlr.js')
const TX81Z = require('./tx81z.js')

const synth = "DX21"

const voiceMap = [
  ['voice', VCED.patchTruss],
]

const compactMap = [
  ["voice", VCED.compactTruss],
]

const werkMap = [
  ["voice", VCED.patchWerk],
]

const voicePatchTruss = Op4.createVoicePatchTruss(synth, voiceMap, "dx21-voice-init", [])

const voiceBankTruss = Op4.createVoiceBankTruss(voicePatchTruss, 32,  "dx21-voice-bank-init", compactMap)


const editor = Object.assign(Op4.editorTrussSetup, {
  name: synth,
  trussMap: [
    ["global", 'channel'],
    ["patch", voicePatchTruss],
    ["bank", voiceBankTruss],
  ],
    
  fetchTransforms: [
    ["patch", Op4.fetch([0x03])],
    ["bank", Op4.fetch([0x04])],
  ],

  midiOuts: [
    ["patch", TX81Z.patchChangeTransform(werkMap)],
    ["bank", TX81Z.voiceBankTransform(voiceBankTruss)],
  ],
  
})


module.exports = {
  module: {
    editor: editor,
    manu: "Yamaha",
    subid: "dx21",
    sections: [
      ['first', [
        'channel',
        ['voice', "Voice", VoiceController],
      ]],
      ['banks', [
        ['bank', "Voice Bank", "bank"],
      ]],
    ],
    dirMap: [
      ['bank', "Voice Bank"],
    ],
    colorGuide: [
      "#ca5e07",
      "#07afca",
      "#fa925f",
    ],
  }
}
