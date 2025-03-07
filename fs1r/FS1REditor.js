require('./utils.js')
const FS1R = require('./FS1R.js')
const Global = require('./FS1RGlobal.js')
const Voice = require('./FS1RVoice.js')
const Fseq = require('./FS1RFseq.js')
const Perf = require('./FS1RPerf.js')


// MARK: MIDI I/O

const patchFetch = address => ['truss', FS1R.fetch(address)]
const bankFetch = address => ['bankTruss', FS1R.fetch(address)]

const banks = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"]
const userXform = ['user', i => `Int-${i + 1}`]

const extra = path => {
  return i => { path + (i == 0 ? [] : "extra") } // mem > 0 -> voice bank of 64 (no fseqs)
}


// static let backupTruss = BackupTruss("FS1R", map: [
//   ([.global], Global.patchTruss),
//   ([.bank, .voice], Voice.Bank.bankTruss),
//   ([.bank, .perf], Perf.Bank.bankTruss),
// ], pathForData: backupPathForData)
// 
// static let backup64Truss = BackupTruss("FS1R", map: [
//   ([.global], Global.patchTruss),
//   ([.bank, .voice], Voice.Bank64.bankTruss),
//   ([.bank, .perf], Perf.Bank.bankTruss),
//   ([.bank, .fseq], Fseq.Bank.bankTruss),
// ], pathForData: backupPathForData)
// 
// 
// static let backupPathForData: BackupTruss.PathForDataFn = {
//   guard $0.count > 6 else { return nil }
//   switch $0[6] {
//   case 0x00:
//     return [.global]
//   case 0x11:
//     return [.bank, .perf]
//   case 0x51:
//     return [.bank, .voice]
//   case 0x61:
//     return [.bank, .fseq]
//   default:
//     return nil
//   }
// }



const editor = {
  name: "FS1R",
  trussMap: ([
    ["global", Global.patchTruss],
    ["perf", Perf.patchTruss],
    ["fseq", Fseq.patchTruss],
    ["bank/voice", Voice.bankTruss],
    ["bank/perf", Perf.bankTruss],
    ["bank/fseq", Fseq.bankTruss],
    ["bank/voice/extra", Voice.bank64Truss],
    // ["backup", backupTruss],
    // ["backup/extra", backup64Truss],
    // ["extra/perf", Perf.Full.refTruss],
  ]).concat(
    (4).map(i => [["part", i], Voice.patchTruss])
  ),
  
  fetchTransforms: ([
    ["global", patchFetch([0x00, 0x00, 0x00])],
    ["perf", patchFetch([0x10, 0x00, 0x00])],
    ["fseq", patchFetch([0x60, 0x00, 0x00])],
    ["bank/voice", bankFetch([0x51, 0x00, 'b'])],
    ["bank/perf" , bankFetch([0x11, 0x00, 'b'])],
    ["bank/fseq" , bankFetch([0x61, 0x00, 'b'])],
    ["bank/voice/extra", bankFetch([0x51, 0x00, 'b'])],
  ]).concat(
    (4).map(i => [["part", i], patchFetch([0x40 + i, 0x00, 0x00])])
  ),
  
  compositeFetchWaitInterval: 10,
  
  extraParamOuts: [
    ["perf", ['bankNames', "bank/voice", "patch/name"]],
    ["perf", ['bankNames', "bank/fseq", "fseq/name"]],
  ].concat((4).map(part => [["part", part], ['patchOut', "perf", (change, patch) => {
    var out = []
    var v = null
    v = change["part/part/filter/on"]
    if (v !== null) {
      out.push({ path: 'filter/on', p: v })
    }
    v = change["fseq/part"]
    if (v !== null) {
      out.push({ path: 'fseq/on', p: v == part + 1 ? 1 : 0 })
    }
    return out
  }]])),
  
  midiOuts: [
    ["global", Global.patchTransform],
    ["perf", Perf.patchTransform],
    ["fseq", Fseq.patchTransform],
    ["bank/voice", Voice.bankTransform],
    ["bank/perf", Perf.bankTransform],
    ["bank/fseq", Fseq.bankTransform],
    ["bank/voice/extra", Voice.bankTransform],
  ].concat(
    (4).map(i => [["part", i], Voice.patchTransform(i)])
  ),
  
  midiChannels: (4).map(p =>
    [["part", p], ['patch', "perf", ["part", p, "channel"], ch => ch > 15 ? 0 : ch]]
  ),
  
  slotTransforms: (11).map(b =>
    [["preset", "voice", b], ['preset', i => `Pr${banks[b]}-${i}`, Voice.ramBanks[b]]]
  ).concat([
    ["preset/fseq", ['preset', i => `Pre-${i}`, Fseq.presets]],
    ["bank/voice", userXform],
    ["bank/perf", userXform],
    ["bank/fseq", userXform],
    ["bank/voice/extra", userXform],
  ]),
  
  commandEffects: ((4).map(part =>
    // if channel is changed, update channel max (as synth does)
    ['patchParamChange', "perf", ["part", part, "channel"], (value, transmit) => {
      const chanMax = value < 16 ? value : 0x7f
      return [[["part", part, "channel/hi"], chanMax], false]
    }]
  )).concat((4).map(part => {
    // algo change sets level adjusts back to 0 on synth
    ['patchParamChange', ["part", part], "algo", (value, transmit) => {
      return [(8).map(i => [["adjust/op", i, "level"], 0]), false]
    }]
  })),
  
  // check system settings "memory" to map to which bank/backup format we're using
  pathTransforms: [
    ["backup", ['patchParam', "global", "memory", extra("backup")]],
    ["bank/voice", ['patchParam', "global", "memory", extra("bank/voice")]],
  ],
  
  compositeSendWaitInterval: 300,
}

module.exports = {
  editor: editor,
}

//  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
//    // side effect: if saving from a part editor, update the perf
//    guard patchPath.first == .part else { return }
//    let params: [SynthPath:Int] = [
//      patchPath + "bank" : 1, // Internal bank
//      patchPath + "pgm" : index
//    ]
//    changePatch(forPath: "perf", .paramsChange(params), transmit: true)
//  }
