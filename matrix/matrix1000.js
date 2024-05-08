const Matrix = require('./matrix.js')
const Voice = require('./matrix1000voice.js')
const VoiceCtrlr = require('./matrix6voiceCtrlr.js')

const editor = {
  name: "Matrix-1000",
  trussMap: [
    [["global"], "channel"],
    [["patch"], Voice.patchTruss],
    [["bank", 0], Voice.bankTruss],
    [["bank", 1], Voice.bankTruss],
  ],

  fetchTransforms: [
    [["patch"], { truss: (editorVal) => Matrix.sysex([0x04, 0x04, 0x0]) }],
  ].concat((2).map((bank) => {
    [["bank", bank], {
      sequence: [
        {
          type: 'custom',
          fn: (editorVals, x) => [
            [
              ["send", ["syx", Matrix.bankSelect(bank)]], // select bank
              ["send", ["syx", Matrix.sysex([0xc])]], // turn off bank lock
            ],
          ],
        },
        { bankTruss: (editorVal, location) => Matrix.fetchPatch(location) },
      ]
    }]
  })),
  
  midiOuts: [
    [["patch"], Voice.patchTransform],
  ].concat((2).map((bank) => {
    [["bank", bank], Voice.bankTransform(bank)]
  })),

  midiChannels: [
    [["patch"], "basic"],
  ],

  slotTransforms: (2).map((bank) => {
    const b = bank * 100
    return [["bank", bank], { user: (location) => `${location + b}` }]
  })
}


module.exports = {
  module: {
    editor: editor,
    manu: "Oberheim",
    subId: "matrix1000",
    sections: [
      ['first', [
        ['channel'],
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