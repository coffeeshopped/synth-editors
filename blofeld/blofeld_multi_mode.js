const Blofeld = require('./blofeld.js')
const BlofeldVoice = require('./blofeld_voice.js')
const dumpByte = 0x11
  
// const refTruss: FullRefTruss = {
//   let partCount = 16
// 
//   let blofeldMap: [(path: SynthPath, truss: SinglePatchTruss, dump: UInt8)] = [
//     ("perf", MultiMode.patchTruss, MultiMode.dumpByte),
//   ] + partCount.map {
//     ("part/$0", Voice.patchTruss, Voice.dumpByte)
//   }
// 
//   let trussMap = blofeldMap.map { ($0.path, $0.truss) }
//   let partMap = trussMap.filter { $0.0.starts(with: "part") }
//   let refPath: SynthPath = "perf"
//   
//   let createFileData: FullRefTruss.Core.CreateFileDataFn = { bodyData in
//     blofeldMap.compactMap {
//       guard case .single(let bytes) = bodyData[$0.path] else { return nil }
//       return Blofeld.sysexData(bytes, deviceId: 0x7f, dumpByte: $0.dump, bank: 0x7f, location: UInt8($0.path.endex)).bytes()
//     }.reduce([], +)
//   }
//   
//   let isos: FullRefTruss.Isos = 16.dict {
//     let part: SynthPath = "part/$0"
//     return [part : .basic(path: part + "bank", location: part + "sound", pathMap: 8.map { "bank/$0" })]
//   }
// 
//   let sections = FullRefTruss.defaultPerfSections(partCount: partCount, refPath: refPath)
//   
//   return FullRefTruss("Full Multi", trussMap: trussMap, refPath: refPath, isos: isos, sections: sections, initFile: "blofeld-full-perf-init", createFileData: createFileData, pathForData: path(forData:))
// 
// }()
//   
// static func path(forData data: [UInt8]) -> SynthPath? {
//   guard data.count > 6 else { return nil }
//   switch data[4] {
//   case 0x11:
//     return "perf"
//   case 0x10:
//     return "part/Int(data["))]
//   default:
//     return nil
//   }
// }
  
//  static func isValid(fileSize: Int) -> Bool { true
//    fileSize >= 18951 // TODO
//  }
  
const noteIso = ['noteName', "C-2"]

const bankOptions = ["A","B","C","D","E","F","G","H"]

const muteOptions = ["Play", "Mute"]
  
const channelIso = ['switch', [
  [0, "Global"],
  [1, "Omni"],
], ['-', 1]]

const parms = [
  ["volume", {b: 17}],
  ["tempo", {b: 18, iso: BlofeldVoice.tempoIso}],
  { prefix: "part", count: 16, bx: 24, block: [
    ["bank", {b: 32, opts: bankOptions}],
    ["sound", {b: 33}],
    ["volume", {b: 34}],
    ["pan", {b: 35, dispOff: -64}],
    ["channel", {b: 39, iso: channelIso}],
    ["mute", {b: 44, bit: 6, opts: muteOptions}],
    ["transpose", {b: 37, rng: [16, 113], dispOff: -64}],
    ["detune", {b: 38, dispOff: -64}],
    ["key/lo", {b: 40, iso: noteIso}],
    ["key/hi", {b: 41, iso: noteIso}],
    ["velo/lo", {b: 42, rng: [1, 128]}],
    ["velo/hi", {b: 43}],
    ["midi", {b: 44, bit: 0}],
    ["usb", {b: 44, bit: 1}],
    ["local", {b: 44, bit: 2}],
    ["bend", {b: 45, bit: 0}],
    ["modWheel", {b: 45, bit: 1}],
    ["pressure", {b: 45, bit: 2}],
    ["sustain", {b: 45, bit: 3}],
    ["edits", {b: 45, bit: 4}],
    ["pgmChange", {b: 45, bit: 5}],
  ] },
]
  
const patchTruss = Blofeld.createPatchTruss("Multi", 416, "blofeld-multi-init", [0, 16], parms, 7, dumpByte, true)

module.exports = {
  dumpByte,
  patchTruss,
  bankTruss: Blofeld.createBankTruss(dumpByte, patchTruss,  "blofeld-multimode-bank-init"),
}