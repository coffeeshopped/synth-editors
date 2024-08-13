const Matrix = require('./matrix.js')
const Voice = require('./matrix6voice.js')
const VoiceCtrlr = require('./matrix6voiceCtrlr.js')

const globalPatchTruss = {
  type: "json",
  id: "matrix6.global",
  parms: [
    ["channel", { b: 0, max: 15, dispOff: 1 }],
    ["patch", { b: 1, max: 99 }],
  ]
}

const createEditorTruss = name => ({
  name: name,
  trussMap: [
    ["global", globalPatchTruss],
    ["patch", Voice.patchTruss],
    ["bank", Voice.bankTruss],
  ],
  
  fetchTransforms: [
    ["patch", ['sequence', [
      // on Matrix 6, selected patch has to match the patch we're editing so send pgmChange after fetch
      ['truss', Matrix.fetchPatch(Matrix.tempPatch)], 
      ['custom', [
        ["send", ['pgmChange', 'channel', Matrix.tempPatch]]
      ]],
    ]]],
    ["bank", ['bankTruss', Matrix.fetchPatch('b')]],
  ],
  
  midiOuts: [
    ["patch", Voice.patchTransform],
    ["bank", Voice.bankTransform],
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  
  slotTransforms: [
    ["bank", { user: location => `${location}` }]
  ],
})

const globalCtrlr = {
  builders: [
    ["grid", { color: 1 }, [[
      ["MIDI Channel", "channel"],
      ["Temp Patch #", "patch"],
    ]]],
  ]
}


const createModuleTruss = (name, subid) => ({
  editor: createEditorTruss(name),
  manu: "Oberheim",
  subid: subid,
  sections: [
    ['first', [
      ['global', globalCtrlr],
      ['voice', "Voice", VoiceCtrlr],
    ]],
    ['basic', "Voice Bank", [
      ['bank', "Bank 0-99", 'bank'],
    ]],
  ],
  dirMap: [
    ["bank", "Bank"],
  ], 
  colorGuide: [
    "#e8a833",
    "#1a7bf5",
    "#9aec2c",
    "#ff3ba6",
  ],
})


module.exports = {
  createModuleTruss: createModuleTruss,
  module: createModuleTruss("Matrix-6", "matrix6"),
}

