const Blofeld = require('./blofeld.js')
const Global = require('./blofeld_global.js')
const Voice = require('./blofeld_voice.js')
const MultiMode = require('./blofeld_multi_mode.js')

const patchFetch = bytes => ['truss', Blofeld.sysex(bytes)]

const bankFetch = bytes => ['bankTruss', Blofeld.sysex(bytes), {waitInterval: 100}]

const wholePatchTransform = (throttle, dumpByte, bank, location) => ({
  type: 'singleWholePatch',
  throttle: throttle,
  patch: [[Blofeld.sysexData(dumpByte, bank, location), 0]],
})

const bankPatch = (dumpByte, bank, interval) => ({
  type: 'singleBank',
  bank: location => [[Blofeld.sysexData(dumpByte, bank, location), interval]],
})

const channelMap = raw => raw == 0 ? 0 : raw - 1


// const backupTruss = {
//   let map: [(SynthPath, any SysexTruss)] = [
//     ("global", Global.patchTruss),
//   ] + 8.map {
//     ("bank/$0", Voice.bankTruss)
//   } + [
//     ("perf/bank", MultiMode.bankTruss),
//   ]
// 
//   let createFileData: BackupTruss.Core.CreateFileDataFn = { bodyData in
//     // map over the types to ensure ordering of data
//     try map.compactMap { path, truss in
//       switch truss.displayId {
//       case Voice.bankTruss.displayId:
//         // voice banks have multiple locations
//         guard let bankData = bodyData[path]?.data() as? SingleBankTruss.BodyData else { return nil }
//         let bank = UInt8(path.endex)
//         return bankData.enumerated().flatMap { location, bodyData in
//           sysexData(bodyData, deviceId: 0x7f, dumpByte: Voice.dumpByte, bank: bank, location: UInt8(location)).bytes()
//         }
// 
//       default:
//         guard let data = bodyData[path] else { return [] }
//         return try truss.createFileData(anyBodyData: data)
//       }
//     }.reduce([], +)
//   }
//   
//   return BackupTruss("Blofeld", map: map, pathForData: {
//       guard $0.count > 6 else { return nil }
//       switch $0[4] {
//       case 0x14:
//         return "global"
//       case 0x11:
//         return "perf/bank"
//       case 0x10:
//         return "bank/Int($0["))]
//       default:
//         return nil
//       }
//   }, createFileData: createFileData)
// }

const voiceParamData = (location, parm) => Blofeld.paramData([0x20, location], parm)
  
const voicePatchChange = (throttle, location) => ({
  type: 'singlePatch',
  throttle: throttle,
  param: (path, parm, value) => [[voiceParamData(location, parm.b), 10]],
  patch: Blofeld.sysexData(Voice.dumpByte, 0x7f, location, true), 
  name: Voice.patchTruss.namePack.rangeMap(i => [
    voiceParamData(location, i), 10
  ]),
})


module.exports = {
  editor: {
    name: "Blofeld", 
    trussMap: ([
      ["global", Global.patchTruss],
      ["voice", Voice.patchTruss],
      ["perf", MultiMode.patchTruss],
      ["perf/bank", MultiMode.bankTruss],
      // ["backup", backupTruss],
      // ["extra/perf", MultiMode.refTruss],
    ]).concat(
      (16).map(i => [['part', i], Voice.patchTruss]),
      (8).map(i => [['bank', i], Voice.bankTruss])
    ),
    
    fetchTransforms: ([
      ["global", patchFetch([0x04])],
      ["voice", patchFetch([0x00, 0x7f, 0x00])],
      ["perf", patchFetch([0x01, 0x7f, 0x00])],
      ["perf/bank", bankFetch([0x01, 0x00, 'b', 0x7f])],
    ]).concat(
      (16).map(i => [['part', i], patchFetch([0x00, 0x7f, i])]),
      (8).map(i => [['bank', i], bankFetch([0x00, i, 'b', 0x7f])])
    ),
    
    compositeFetchWaitInterval: 100,
    compositeSendWaitInterval: 300,
  
    extraParamOuts: (8).map(i => ["perf", ['bankNames', ['bank', i], ['patch/name', i]]]),
  
    midiOuts: ([
      ["global", wholePatchTransform(400, Global.dumpByte, 0, 0)],
      ["voice", voicePatchChange(30, 0)],
      ["perf", wholePatchTransform(400, MultiMode.dumpByte, 0x7f, 0)],
      ["perf/bank", bankPatch(MultiMode.dumpByte, 0, 200)],
    ]).concat(
      (16).map(i => [['part', i], voicePatchChange(30, i)]),
      (8).map(i => [['bank', i], bankPatch(Voice.dumpByte, i, 100)])
    ),
    
    midiChannels: ([
      ["voice", ['basic', channelMap]],
    ]).concat(
      (16).map(i => [`part/${i}`, ['custom', [
        ['value', "global", "channel"], 
        ['value', "perf", `part/${i}/channel`],
      ], values => {
        const rawCh = values[0] || 0
        const partCh = values[1] || 0
        switch (partCh) {
        case 0: // 0 is Global
          return channelMap(rawCh)
        case 1: // 1 is omni
          return 0
        default: // else channel - 2
          return partCh - 2
        }
      }]])
    ),
    
    slotTransforms: (8).map(b =>
      ["bank/b", ['user', i => Voice.bankLetter(b) + `${i + 1}`]]
    ),
  },
}
  
//  private let partPaths: [SynthPath] = (0..<16).map { "part/$0" }
//  private let multiPath: SynthPath = "perf"
//
//  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
//    // side effect: if saving from a part editor, update the multi
//    if partPaths.contains(patchPath) {
//      guard let bankIndex = bankPath.i(1) else { return }
//      let params: [SynthPath:Int] = [
//        patchPath + "bank" : bankIndex,
//        patchPath + "sound" : index
//      ]
//      changePatch(forPath: "perf", .paramsChange(params), transmit: true)
//    }
//  }
  
// As far as I can tell and have experimented, the Blofeld cannot receive individual parameter changes for Multis.