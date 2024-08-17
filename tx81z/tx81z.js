const Op4 = require('./op4.js')
const Op4micro = require('./op4micro.js')
const Perf = require('./tx81zPerf.js')
const VCED = require('./vced.js')
const ACED = require('./aced.js')
const VoiceController = require('./tx81zVoiceCtrlr.js')

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

const voiceBankTransform = Op4.patchBankTransform
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

const opOns = (4).map(i => ['extra', 'patch', ['voice', 'op', i, 'on']])

// calc based on stored editor values and new incoming value
const opOnByte = (dict, newOp, value) => {
  (4).map(i => {
    const isOn = i == newOp ? value > 0 : dict[transform] == 1
    return isOn ? 1 << ((4 - 1) - i) : 0
  }).sum()
}

/// For TX81z. Same as VCED only except send full patch (VCED and ACED) when there are multiple changes
const patchChangeTransform = werkMap => ({
  type: 'multiDictPatch',
  throttle: 100,
  editorVal: opOns,
  param: (path, parm, value) => {
    const first = path[0]
    const isOpOn = first == 'voice' && path[path.length - 1] == 'on'
    const parmByte = isOpOn ? 93 : parm.b
    var data = [first, ['byte', parmByte]]
    switch (first) {
      case 'voice':
        // TODO: opOn stuff
        // const v = isOpOn ? opOnByte(editorVal, path[2], value) : subval
        data.push(VCED.patchWerk.paramData([parmByte, 'b']))
        break
      case 'extra':
        data.push(ACED.patchWerk.paramData([parmByte, 'b']))
        break
      case 'aftertouch':
        // offset byte by 23 to get param address
        data.push(ACED.patchWerk.paramData([parmByte + 23, 'b']))
        break
      default:
        return null
    }
    return [[data, 0]]
    
  }, 
  patch: werkMap.map(pair => [[pair[0], pair[1].sysexData], 100]),
  name: VCED.patchTruss.namePack.rangeMap(i => [
    ['voice', VCED.patchWerk.paramData([i, ['byte', i]])], 10
  ]),
})

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
    ["patch", patchChangeTransform(werkMap)],
    ["perf", Perf.patchTransform],
    ["micro/octave", Op4micro.octWerk.patchChangeTransform],
    ["micro/key", Op4micro.fullWerk.patchChangeTransform],
    ["bank", {
      type: 'wholeBank',
      throttle: 0,
      multi: [[Op4.voiceBankSysexData, 100]]
    }],
    ["bank/perf", Perf.wholeBankTransform],
  ],
  
})



const moduleTruss = {
  editor: editor,
  manu: "Yamaha",
  subid: "tx81z",
  sections: [
    ['first', [
      'channel',
      ['voice', "Voice", VoiceController],
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
}

module.exports = {
  module: moduleTruss,
}