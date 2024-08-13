const Matrix = require('./matrix.js')
const Voice = require('./matrix1000voice.js')
const VoiceCtrlr = require('./matrix6voiceCtrlr.js')

const bankFetch = bank => ['sequence', [
  ['custom', [
    ["send", Matrix.bankSelect(bank)], // select bank
    ["send", Matrix.sysex(0xc)], // turn off bank lock
  ]],
  ['bankTruss', Matrix.fetchPatch('b')],
]]

const editor = {
  name: "Matrix-1000",
  trussMap: [
    ["global", "channel"],
    ["patch", Voice.patchTruss],
    ["bank/0", Voice.bankTruss],
    ["bank/1", Voice.bankTruss],
  ],

  fetchTransforms: [
    ["patch", ['truss', Matrix.sysex([0x04, 0x04, 0x0])]],
    ["bank/0", bankFetch(0)],
    ["bank/1", bankFetch(1)],
  ],
  
  midiOuts: [
    ["patch", Voice.patchTransform],
    ["bank/0", Voice.bankTransform(0)],
    ["bank/1", Voice.bankTransform(1)],
  ],

  midiChannels: [
    ["patch", "basic"],
  ],

  slotTransforms: [
    ["bank/0", { user: location => `${location}` }],
    ["bank/1", { user: location => `${location + 100}` }]
  ],
}


module.exports = {
  module: {
    editor: editor,
    manu: "Oberheim",
    subid: "matrix1000",
    sections: [
      ['first', [
        'channel',
        ['voice', "Voice", VoiceCtrlr],
      ]],
      ['basic', "Voice Bank", [
        ['bank', "Bank 0-99", 'bank/0'],
        ['bank', "Bank 100-199", 'bank/1'],
      ]],
    ],
    dirMap: [
      ["bank", "Bank"],
    ], colorGuide: [
      "#e8a833",
      "#1a7bf5",
      "#9aec2c",
      "#ff3ba6",
    ],
  }
}