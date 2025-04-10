
const paramData = (instrument, bodyBytes) =>
  ['yamSyx', [0x75, 'channel', 0x18 + instrument, bodyBytes]]



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

const editor = {
  name: "FB01",
  trussMap: [
    ["global", 'channel'],
    ["perf", Perf.patchTruss],
    ["bank/perf", Perf.bankTruss],
  ].concat(
    (8).map(i => [["part", i], Voice.patchTruss]),
    (2).map(i => [['bank', i], Voice.bankTruss])
  ),
  fetchTransforms: [
    ["perf", fetch([0x20, 0x01, 0x00])],
    ["bank/perf", fetch([0x20, 0x03, 0x00])],
  ].concat(
    (8).map(i => [["part", i], fetch([0x20 + i + 8, 0x0, 0x0])])
    (2).map(i => [["bank", i], fetch([0x20, 0x00, i])])
  ),
  midiOuts: [
    ["perf", Perf.patchChangeTransform],
    ["bank/perf", Perf.bankTransform],
  ].concat(
    (8).map(i => [["part", i], Voice.patchChangeTransform(i)]),
    (2).map(i => [['bank', i], Voice.bankTransform(i)])
  ),
  midiChannels: (8).map(i => 
    [["part", i], ['patch', "perf", ["part", i, "channel"]
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
    subid: fb01,
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
      [.part] : "Patch",
      [.bank] : "Patch Bank",
      [.bank, .perf] : "Perf Bank",
    ],
    colorGuide: [
      "#10ed7d",
      "#ff260f",
      "#8afc38",
    ],
  },
}