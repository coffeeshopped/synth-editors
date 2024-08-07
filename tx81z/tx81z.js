const Op4 = require('./op4.js')
// const Op4micro = require('./op4micro.js')
const Perf = require('./tx81zPerf.js')
const VCED = require('./vced.js')
const ACED = require('./aced.js')

const synth = "TX81Z"

const voiceMap = [
  ["extra", ACED.patchTruss],
  ["voice", VCED.patchTruss],
]

const compactMap = [
  ["extra", ACED.compactTruss],
  ["voice", VCED.compactTruss],
]

const voicePatchTruss = Op4.createVoicePatchTruss(synth, voiceMap, "tx81z-init", [])
const voiceBankTruss = Op4.createVoiceBankTruss(voicePatchTruss, 32, "tx81z-voice-bank-init", compactMap)

// const voiceBankTransform = Op4.patchBankTransform(voiceMap)
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

/// For TX81z. Same as VCED only except send full patch (VCED and ACED) when there are multiple changes
// const patchChangeTransform = truss => ({
//   type: 'multiDictPatch',
//   throttle: 100,
//   editorVals: ([sysexChannel]).concat(opOns),
//   param: (editorVals, parm, value) => {
//     const first = parm.path[0]
//     const isOpOn = first == 'voice' && parm.path.last == 'on'
//     const parmByte = isOpOn ? 93 : parm.b
//     const channel = editorVals[0]
//     const subval = [
//       ['sub', first],
//       ['byte', parmByte]
//     ]
//     var data = []
//     switch (parm.path[0]) {
//       case 'voice':
//         const v = isOpOn ? opOnByte(editorVals, parm.path[2], value) : subval
//         data = VCED.patchWerk.paramData(channel, [parmByte, v])
//         break
//       case 'extra':
//         data = ACED.patchWerk.paramData(channel, [parmByte, subval])
//         break
//       case 'aftertouch':
//         // offset byte by 23 to get param address
//         data = ACED.patchWerk.paramData(channel, [parmByte + 23, subval])
//         break
//       default:
//         return null
//     }
//     return [[data, 0]]
//     
//   }, 
//   patch: (editorVals) => {
//     const channel = editorVals[0]
//     return try map.compactMap {
//       guard let b = bodyData[$0.0] else { return nil }
//       return try $0.1.patchTransform(channel, b)
//     }.reduce([], +)
//   
//   }, 
//   name: (editorVals, bodyData, path, name) => {
//     const channel = editorVals[0]
//     return VCED.patchWerk.nameTransform(channel, ['sub', 'voice'], path, name)
//   },
// })

const editor = Object.assign(Op4.editorTrussSetup, {
  name: synth,
  trussMap: [
    ["global", 'channel'],
    ["patch", voicePatchTruss],
    ["bank", voiceBankTruss],
  ].concat([] /* Op4.microSysexMap */).concat([
    ["perf", Perf.patchTruss],
    ["bank/perf", Perf.bankTruss],
    // ["backup", backupTruss],
  ]),
    
  fetchTransforms: [
    // ["patch", Op4.fetchWithHeader("8976AE")],
    // ["perf", Op4.fetchWithHeader("8976PE")],
    // ["micro/octave", Op4.fetchWithHeader("MCRTE0")],
    // ["micro/key", Op4.fetchWithHeader("MCRTE1")],
    // ["bank", Op4.fetch([0x04])],
    // ["bank/perf", Op4.fetchWithHeader("8976PM")],
  ],

  midiOuts: [
    // ["patch", Op4.patchChangeTransform(voicePatchTruss)],
    // ["perf", Perf.patchTransform],
    // ["micro/octave", Op4micro.octWerk.patchChangeTransform],
    // ["micro/key", Op4micro.fullWerk.patchChangeTransform],
    // ["bank", voiceBankTransform),
    // ["bank/perf", Perf.wholeBankTransform(Perf.bankTruss.patchCount, Perf.patchWerk)],
  ],
  
})



const moduleTruss = {
  editor: editor,
  manu: "Yamaha",
  subid: "tx81z",
  sections: [
    ['first', [
      'channel',
      // ['voice', "Voice", Voice.Controller.controller],
      // ['perf', Perf.Controller.controller(Perf.presetVoices)],
      // ['voice', "Micro Oct", Op4.Micro.Controller.octController, { path: "micro/octave" }],
      // ['voice', "Micro Full", Op4.Micro.Controller.fullController, { path: "micro/key" }],
    ]],
    ['banks', [
      ['bank', "Voice Bank", "bank"],
      ['bank', "Perf Bank", "bank/perf"],
    ]],
    // 'backup',
  ],
  // dirMap: [
  //     [.bank] : "Voice Bank",
  //     [.micro, .octave] : "Micro Octave*",
  //     [.micro, .key] : "Micro Full*",
  //     [.bank, .perf] : "Perf Bank",
  // ],
  colorGuide: [
    "#a2cd50",
    "#f93d31",
    "#00d053",
  ],
}

module.exports = {
  module: moduleTruss,
}