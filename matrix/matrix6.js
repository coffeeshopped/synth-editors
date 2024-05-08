const Matrix = require('./matrix.js')
const Voice = require('./matrix6voice.js')
const VoiceCtrlr = require('./matrix6voiceCtrlr.js')

const globalPatchTruss = {
  type: "json",
  id: "matrix6.global",
  parms: [
    [
      [["channel"], { b: 0, max: 15, dispOff: 1 }],
      [["patch"], { b: 1, max: 99 }],
    ]
  ]
}

const createEditorTruss = (name) => {
  return {
    name: name,
    trussMap: [
      [["global"], globalPatchTruss],
      [["patch"], Voice.patchTruss],
      [["bank"], Voice.bankTruss],
    ],
    
    fetchTransforms: [
      [["patch"], {
        type: "sequence",
        sequence: [
        // on Matrix 6, selected patch has to match the patch we're editing so send pgmChange after fetch
        { type: 'truss', editorVal: Matrix.tempPatch, fn: (editorVal) => Matix.fetchPatch(editorVal) },
        {
          type: 'custom',
          editorVals: ['basic', Matrix.tempPatch],
          fn: (editorVals, x) => {
            let channel = editorVals['basic']
            let tempPatch = editorVals[Matrix.tempPatch]
            return [["send", ['pgmChange', channel, tempPatch]]]
          }
        },
        ],
      }],
      [["bank"], {
        type: "bankTruss",
        fn: (editorVal, location) => Matrix.fetchPatch(loc),
      }],
    ],
    
    midiOuts: [
      [["patch"], Voice.patchTransform],
      [["bank"], Voice.bankTransform],
    ],
    
    midiChannels: [
      [["patch"], "basic"],
    ],
    
    slotTransforms: [
      [["bank"], { user: (location) => `${location}` }]
    ],
  }
}

const globalCtrlr = {
  builders: [
    ["grid", { color: 1 }, [[
      ["MIDI Channel", "channel"],
      ["Temp Patch #", "patch"],
    ]]],
  ]
}


const createModuleTruss = (name, subid) => {
  return {
    editor: createEditorTruss(name),
    manu: "Oberheim",
    subId: subid,
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
    ], colorGuide: [
      "#e8a833",
      "#1a7bf5",
      "#9aec2c",
      "#ff3ba6",
    ],
  } 
} 


module.exports = {
  createModuleTruss: createModuleTruss,
}
