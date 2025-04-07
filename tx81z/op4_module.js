const Op4micro = require('./op4_micro.js')
const PerfController = require('./op4_perf_ctrlr.js')
const MicroController = require('./op4_micro_ctrlr.js')

// 
// const backupTruss = {
//   type: 'backup',
//   name: synth,
//   map: [
//     ["micro/octave", Op4micro.octWerk.truss],
//     ["micro/key", Op4micro.fullWerk.truss],
//     ["bank", Voice.bankTruss],
//     ["bank/perf", Perf.bankTruss],
//   ], 
//   pathForData: (d) => {
//     switch (d.length) {
//     case 42:
//       return "micro/octave"
//     case 274:
//       return "micro/key"
//     case 4104:
//       return "bank"
//     case 2450:
//       return "bank/perf"
//     default:
//       return null
//     }
//   }
// }

const editorTruss = (name, voice, perf, fetchTransforms) => {
  const trussMap = [
    ["global", 'channel'],
    ["patch", voice.patchTruss],
    ["bank", voice.bankTruss],
  ]
  const midiOuts = [
    ["patch", voice.patchTransform],
    ["bank", voice.bankTransform],
  ]
  
  if (perf) {
    trussMap.push(
      ["perf", perf.patchTruss],
      ["bank/perf", perf.bankTruss]
      // ["backup", backupTruss],
    )    
    trussMap.push(...Op4micro.trussMap)
    
    midiOuts.push(
      ["perf", perf.patchTransform],
      ["bank/perf", perf.bankTransform],
      ["micro/octave", Op4micro.octWerk.patchChangeTransform],
      ["micro/key", Op4micro.fullWerk.patchChangeTransform],
    )
  }

  return {
    name: name,
    trussMap: trussMap,
    fetchTransforms: fetchTransforms,
    midiOuts: midiOuts,
    extraParamOuts: [
      ["perf", ['bankNames', 'bank', 'patch/name', (i, name) => `I${i + 1}. ${name}` ]]
    ],
    extraValues: [
      ["patch", (4).map((i) => [["voice", "op", i, "on"], 1])],
    ],
    // when a new voice patch is pushed or replaced, reset op on values all to 1
    commandEffects: [
      ['patchPushReplaceChange', "patch", (4).map((i) => [["voice", "op", i, "on"], 1])],
    ],
    midiChannels: [
      ["patch", 'basic'],
      ["micro/octave", 'basic'],
      ["micro/key", 'basic'],
    ],
  }
}

const moduleTruss = (editor, subid, voiceCtrlr, perf, colorGuide) => {
  const firstSection = ['first', [
    'channel',
    ['voice', "Voice", voiceCtrlr.ctrlr],
  ]]
  const banks = ['banks', [
    ['bank', "Voice Bank", "bank"],
  ]]
  
  if (perf) {
    firstSection.push(
      ['perf', PerfController.ctrlr(perf.presetVoices)],
      ['voice', "Micro Oct", MicroController.octController, "micro/octave"],
      ['voice', "Micro Full", MicroController.fullController, "micro/key"]
    )
    banks.push(
      ['bank', "Perf Bank", "bank/perf"]
    )
  }
  
  return {
    editor: editor,
    manu: "Yamaha",
    subid: subid,
    sections: [
      firstSection,
      banks,
      // 'backup',
    ],
    dirMap: [
      ['bank', "Voice Bank"],
      ['micro/octave', "Micro Octave*"],
      ['micro/key', "Micro Full*"],
      ['bank/perf', "Perf Bank"],
    ],
    colorGuide: colorGuide,
  }
}

module.exports = {
  editorTruss,
  moduleTruss,
}