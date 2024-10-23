const FS1R = require('./FS1R.js')


// TODO: get/set needs to take into account 2-byte params but also those bytes aren't contiguous in the frames!
// Same with param sends on this stuff!

const parms = [
  { b2p: [
    ["loop/start", { b: 0x10, extra: [[0, 2]], max: 511 }],
    ["loop/end", { b: 0x12, extra: [[0, 2]], max: 511 }],
    ["loop/mode", { b: 0x14, opts: ["1-way", "Round"] }],
    ["speed", { b: 0x15 }],
    ["speed/velo", { b: 0x16, max: 7 }],
    ["pitch/mode", { b: 0x17, opts: ["Pitch", "Non-pitch"] }],
    ["note/assign", { b: 0x18 }],
    ["detune", { b: 0x19, max: 126, displayOffset: -63 }],
    ["delay", { b: 0x1a, max: 99 }],
    ["form", { b: 0x1b, opts: ["128", "256", "384", "512"] }],
    ["end", { b: 0x1e, extra: [[0, 2]], max: 511 }],
  ] },
  { prefix: 'step', count: 512, bx: 50, block: { b: 16, offset: [
    { b2p: [
      ["pitch", { b: 0x10, extra: [[0, 2]], max: 16383 }],
      // step/0/trk/0/...
      { prefix: 'trk', count: 8, bx: 1, block: [
        ["voiced/freq", { b: 0x12, extra: [[0, 2]], max: 16383 }],
        ["voiced/level", { b: 0x22 }],
        ["unvoiced/freq", { b: 0x2a, extra: [[0, 2]], max: 16383 }],
        ["unvoiced/level", { b: 0x3a }],
      ] },
    ] },
  ] } },
]

const sysexData = (deviceId) => FS1R.sysexData(deviceId, [0x60, 0x00, 0x00])

/// sysex bytes for patch as stored in memory location
const sysexDataWithLocation = (deviceId, location) =>
  FS1R.sysexData(deviceId, [0x61, 0x00, location])


const patchTruss = {
  type: 'singlePatch',
  id: "fseq", 
  bodyDataCount: 6443 - 11,
  namePack: [0, 8], 
  parms: parms, 
  createFileData: sysexData(0), 
  initFile: "fs1r-fseq-init", 
  // variable data length - 50 bytes per frame
  parseBody: ['bytes', { start: 9, end: -2 }],
  validBundle: { counts: [6443, 12843, 19243, 25643] },
} 


const presets = ["ShoobyDo", "2BarBeat", "D&B", "D&B Fill", "4BarBeat", "YouCanG", "EBSayHey", "RtmSynth", "VocalRtm", "WooWaPa", "UooLha", "FemRtm", "ByonRole", "WowYeah", "ListenVo", "YAMAHAFS", "Laugh", "Laugh2", "AreYouR", "Oiyai", "Oiaiuo", "UuWaUu", "Wao", "RndArp1", "FiltrArp", "RndArp2", "TechArp", "RndArp3", "Voco-Seq", "PopTech", "1BarBeat", "1BrBeat2", "Undo", "RndArp4", "VoclRtm2", "Reiyowha", "RndArp5", "VocalArp", "CanYouGi", "Pu-Yo", "Yaof", "MyaOh", "ChuckRtm", "ILoveYou", "Jan-On", "Welcome", "One-Two", "Edokko", "Everybdy", "Uwau", "YEEAAH", "4-3-2-1", "Test123", "CheckSnd", "ShavaDo", "R-M-H-R", "HiSchool", "M.Blastr", "L&G MayI", "Hellow", "ChowaUu", "Everybd2", "Dodidowa", "Check123", "BranNewY", "BoomBoom", "Hi=Woo", "FreeForm", "FreqPad", "YouKnow", "OldTech", "B/M", "MiniJngl", "EveryB-S", "IYaan", "Yeah", "ThankYou", "Yes=No", "UnWaEDon", "MouthPop", "Fire", "TBLine", "China", "Aeiou", "YaYeYiYo", "C7Seq", "SoundLib", "IYaan2", "Relax", "PSYAMAHA"]


const headerParamData = (deviceId, paramAddress, byteCount) => {
  // instead of sending <value>, we send the byte from the bytes array, because some params share bytes with others
  let v = byteCount == 1 ? ['byte', paramAddress] : (['byte', paramAddress] << 7) + ['byte', paramAddress + 1]
  let paramBytes = []// TODO: RolandAddress(intValue: paramAddress).sysexBytes(count: 2)
  return FS1R.dataSetMsg(deviceId, [0x70, paramBytes], v)
}

const bankIsValid = (sysex) => {
  // smallest possible
  if (sysex.count < 6443 * 6) { return false }

  // let s = SysexData(data: Data(sysex))
  // guard s.count == 6 else { return false }
  // for msg in s {
  //   guard patchTruss.isValidSize(msg.count) else { return false }
  // }
  return true
}

module.exports = {
  patchTruss: patchTruss,
  bankTruss: {
    type: 'singleBank',
    patchTruss: patchTruss,
    patchCount: 6,
    createFile: {
      locationMap: location => sysexDataWithLocation(0, location)
    }, 
    locationIndex: 8,
    validSize: size => {
      // there are so many possibilities of valid file sizes, we're fudging.
      return size >= 6443 * 6
    },
    validData: bankIsValid,
    completeFetch: bankIsValid,
  },
  patchTransform: {
    type: 'singlePatch',
    throttle: 30,
    param: (path, parm, value) => {
      return null
      //      guard let param = FS1RFseqPatch.params[path] else { return nil }
      //      if let part = path[0] == .part ? path.i(1) : nil {
      //        return [(perfPartParamData(editor, patch: patch, part: part, param: param), 0.03)]
      //      }
      //      else {
      //        // common params have param address stored in .byte
      //        var byte = param.byte
      //        let byteCount = param.parm > 0 ? param.parm : 1
      //        if (0x30..<0x40).contains(byte) {
      //          // special treatment for src bits
      //          byte = byte - (byte % 2)
      //        }
      //        return [(perfCommonParamData(editor, patch: patch, paramAddress: byte, byteCount: byteCount), 0.03)]
      //      }
    }, 
    patch: [[sysexData(FS1R.deviceIdMap), 30]], 
    name: patchTruss.namePack.rangeMap(i => [
      headerParamData(FS1R.deviceIdMap, i, 1), 30
    ]),
  },
  bankTransform: {
    type: 'singleBank',
    throttle: 0,
    bank: location => [sysexDataWithLocation(FS1R.deviceIdMap, location), 100],
  },
  presets: presets,
}