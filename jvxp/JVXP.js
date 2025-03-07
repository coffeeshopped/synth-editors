require('./utils.js')

/// MSB first. lower 4 bits of each byte used
// 2 bytes per value
const multiPack = (byte) => ['splitter', (2).map(i => {
  let loValBit = (2 - (i + 1)) * 4
  let hiValBit = loValBit + 3
  return {
    byte: (byte + i), // RolandAddress(intValue: i)).intValue(), 
    byteBits: [0, 4], 
    valueBits: [loValBit, hiValBit + 1],
  }
})]
// Roland.msbMultiPackIso(2)(byte)


const indexToPathPart = index => index < 9 ? index : index + 1
const pathPartToIndex = part => part < 9 ? part : part - 1


const editorTruss = (name, deviceId, global, perf, voice, rhythm, voiceBank, perfBank, rhythmBank) => ({
  rolandModelId: [0x6a], 
  addressCount: 4,
  name: name,
  deviceId: deviceId,
  map: ([
    // ['deviceId'],
    ['global', 0x0000, global],
    ['perf', 0x01000000, perf],
    ['patch', 0x03000000, voice],
    ['rhythm', 0x02090000, rhythm],
    ['bank/patch/0', 0x11000000, voiceBank],
    ['bank/perf/0', 0x10000000, perfBank],
    ['bank/rhythm/0', 0x10400000, rhythmBank],
  ]).concat((15).map(i => {
    const p = indexToPathPart(i)
    return [`part/${p}`, [0x02, p, 0, 0], voice]
  })),
  extraParamOuts: ([
    ['perf', ['bankNames', "bank/patch/0", 'patch/name']],
    ['perf', ['bankNames', "bank/rhythm/0", 'rhythm/name']],
  ]).concat((15).map(i => {
    const p = indexToPathPart(i)
    return [`part/${p}`, ['patchOut', "perf", (change, patch) => {
      const v = change["common/fx/src"]
      if (v == null) { return [] }
      return [{
        path: "common/fx/src",
        p: change["common/fx/src"]
      }]        
    }]]
  })),
  midiChannels: [
   ["patch", ['patch', "global", "patch/channel"]],
  ].concat((16).map(i =>
    [i == 9 ? "rhythm" : `part/${i}`, ['patch', "perf", `part/${i}/channel`]]
  )),
  slotTransforms: [
    ["bank/patch/0", ['user', i => `US:${(i + 1).zPad(3)}`]],
    ["bank/perf/0", ['user', i => `US:${(i + 1).zPad(2)}`]],
    ["bank/rhythm/0", ['user', i => `US:${(i + 1)}`]],
  ],
})

const globalPatchWerk = (parms, size, initFile) => ({
  single: "Global", 
  parms: parms, 
  size: size, 
  initFile: initFile,
})

const voicePatchWerk = (common, tone, initFile) => ({
  multi: "Voice", 
  map: [
    ['common', 0x0000, common],
    ['tone/0', 0x1000, tone],
    ['tone/1', 0x1200, tone],
    ['tone/2', 0x1400, tone],
    ['tone/3', 0x1600, tone],
  ], 
  initFile: initFile,
})

const voiceBankWerk = patchWerk => ({
  multiBank: patchWerk, 
  patchCount: 128, 
  initFile: "jv1080-voice-bank-init",
  iso: ['lsbyte', 2],
})

const voiceCommonPatchWerk = (parms, size) => ({
  single: "Voice Common", 
  parms: parms, 
  size: size, 
  name: [0x00, 0x0c],
})  

const perfPatchWerk = (common, part, initFile) => ({
  multi: "Perf", 
  map: [
    ["common", 0x0000, common],
  ].concat(
    (16).map(i => [`part/${i}`, [0x10 + i, 0x00], part])
  ), 
  initFile: initFile,
})

const perfBankWerk = patchWerk => ({
  multiBank: patchWerk, 
  patchCount: 32,
  initFile: "jv1080-perf-bank-init",
  iso: ['lsbyte', 2],
})

const perfCommonPatchWerk = (parms, size) => ({
  single: "Perf Common", 
  parms: parms, 
  size: size, 
  name: [0x00, 0x0c],
  randomize: () => [
    ["level", 127],
    ["pan", 64],
    ["fx/out/assign", 0],
    ["fx/out/level", Math.random(38) + 90],
    ["velo/range/on", 0],
    ["clock/src", 0],
    ["category", 0],
  ],
})

const perfPartPatchWerk = (parms, size) => ({
  single: "Perf Part", 
  parms: parms, 
  size: size, 
  randomize: () => {
    const pgid = Math.random(6) + 1
    return [
      ["patch/group", 0],
      ["patch/group/id", pgid == 2 ? 1 : pgid],
      ["patch/number", Math.random(128)],
    ]
  }
})

module.exports = {
  multiPack: multiPack,
  globalPatchWerk: globalPatchWerk,

  voicePatchWerk: voicePatchWerk,
  voiceBankWerk: voiceBankWerk,
  
  perfPatchWerk: perfPatchWerk,
  perfBankWerk: perfBankWerk,
  perfCommonPatchWerk: perfCommonPatchWerk,
  perfPartPatchWerk: perfPartPatchWerk,
  
  editorTruss: editorTruss,

}