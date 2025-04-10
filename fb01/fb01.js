require('./utils.js')
const Voice = require('./fb01_voice.js')
const Perf = require('./fb01_perf.js')
const VoiceCtrlr = require('./fb01_voice_ctrlr.js')
const PerfCtrlr = require('./fb01_perf_ctrlr.js')

//    override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
//      // side effect: if saving from a part editor, update the multi
//      guard patchPath.first == .part,
//        let bankIndex = bankPath.i(1) else { return }
//      let params: [SynthPath:Int] = [
//        patchPath + "bank" : bankIndex,
//        patchPath + "pgm" : index
//      ]
//      changePatch(forPath: "perf", MakeParamsChange(params), transmit: true)
//    }

const fetch = (bytes) => ['truss', ['yamSyx', [0x75, 'channel', bytes]]]

const paramData = (instrument, bodyBytes) =>
['yamSyx', [0x75, 'channel', 0x18 + instrument, bodyBytes]]

const voiceParamData = (instrument, paramAddress) => 
  paramData(instrument, [
    0x40 + paramAddress,
    // grab data from the patch rather than a passed value,
    // because a byte can contain multiple param values.
    ['bits', [0, 3], ['byte', paramAddress]],
    ['bits', [4, 7], ['byte', paramAddress]],
  ])

const voicePatchTransform = (instrument) => ({
  type: 'singlePatch',
  throttle: 30,
  param: (path, parm, value) =>
    [voiceParamData(instrument, parm.b), 10]
  ,
  patch: Voice.sysexData(instrument),
  name: Voice.patchTruss.namePack.rangeMap(i => [
    voiceParamData(instrument, i), 10
  ]),
})

const perfParamData = (instrument, paramAddress, value) =>
  paramData(instrument, [paramAddress, value])

const perfPatchTransform = {
  type: 'singlePatch',
  throttle: 30,
  param: (path, parm, value) => {
    var data = null
    if (pathPart(path, 0) == 'part') {
      const part = pathPart(path, 1)
      data = perfParamData(part, parm.b % 0x10, ['byte', parm.b])
    }
    else if (parm.p > 0) {
      data = perfParamData(0, parm.p, ['byte', parm.b])
    }
    else {
      data = Perf.tempSysexData
    }
    return [data, 100]
  },
  patch: Perf.tempSysexData,
  // seems like sending name by individual parameter changes puts the synth in an unknown state.
  name: Perf.tempSysexData,
}

const editor = {
  name: "FB01",
  trussMap: [
    ["global", 'channel'],
    ["perf", Perf.patchTruss],
    ["bank/perf", Perf.bankTruss],
  ].concat(
    (8).map(i => [["part", i], Voice.patchTruss]),
    (2).map(i => [['bank', i], Voice.bankTruss(0)])
  ),
  fetchTransforms: [
    ["perf", fetch([0x20, 0x01, 0x00])],
    ["bank/perf", fetch([0x20, 0x03, 0x00])],
  ].concat(
    (8).map(i => [["part", i], fetch([0x20 + i + 8, 0x0, 0x0])]),
    (2).map(i => [["bank", i], fetch([0x20, 0x00, i])])
  ),
  midiOuts: [
    ["perf", perfPatchTransform],
    ["bank/perf", Perf.bankTruss],
  ].concat(
    (8).map(i => [["part", i], voicePatchTransform(i)]),
    (2).map(i => [['bank', i], Voice.bankTruss(i)])
  ),
  midiChannels: (8).map(i => 
    [["part", i], ['patch', "perf", ["part", i, "channel"]]]
  ),
  extraParamOuts: (2).map(i =>
    // options are names only, no numbers. Don't remember how it's presented on FB-01
    ["perf", ['bankNames', ["bank", i], ["patch/name", i], (i, name) => name]]
  ),
}

module.exports = {
  paramData,
  module: {
    editor: editor,
    manu: "Yamaha",
    subid: 'fb01',
    sections: [
      ['first', [
        'channel',
        ['perf', PerfCtrlr.ctrlr],
      ]],
      ['basic', "Voices", ['perfParts', 8, i => `Instrument ${i + 1}`, VoiceCtrlr.ctrlr]],
      ['banks', [
        ['bank', "Voice Bank 1", 'bank/0'],
        ['bank', "Voice Bank 2", 'bank/1'],
        ['bank', "Perf Bank", 'bank/perf'],
      ]],
    ],
    dirMap: [
      ['part', "Patch"],
      ['bank', "Patch Bank"],
      ['bank/perf', "Perf Bank"],
    ],
    colorGuide: [
      "#10ed7d",
      "#ff260f",
      "#8afc38",
    ],
  },
}