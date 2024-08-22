
  
const sysexWerk = {
  rolandModelId: [0x6a], 
  addressCount: 4,
} 

/// MSB first. lower 4 bits of each byte used
const multiPack = (byte) => Roland.msbMultiPackIso(2)(byte)


const mapItems = (global, perf, voice, rhythm, voiceBank, perfBank, rhythmBank) => [
  ['global', global.start, global],
  ['perf', perf.start, perf],
  ['patch', voice.start, voice],
  ['rhythm', rhythm.start, rhythm],
  ['bank/patch/0', voiceBank.start, voiceBank],
  ['bank/perf/0', perfBank.start, perfBank],
  ['bank/rhythm/0', rhythmBank.start, rhythmBank],
] + (15).map(i => {
  const p = indexToPathPart(i)
  return [`part/${p}`, [0x02, p, 0, 0], voice]
})


const indexToPathPart = index => index < 9 ? index : index + 1
const pathPartToIndex = part => part < 9 ? part : part - 1


const editorTruss = (name, deviceId, global, perf, voice, rhythm, voiceBank, perfBank, rhythmBank) => {
  const map = mapItems(global, perf, voice, rhythm, voiceBank, perfBank, rhythmBank)
  const werk = sysexWerk.editorWerk(name, deviceId, map)
  
  return {
    displayId: werk.displayId
    trussMap: [['deviceId', RolandDeviceIdSettingsTruss]] + werk.sysexMap(),
    fetchTransforms: werk.defaultFetchTransforms(),
    
    extraParamOuts: [
      ['perf', ['bankNames', "bank/patch/0", 'patch/name']],
      ['perf', ['bankNames', "bank/rhythm/0", 'rhythm/name']],
    ] + (15).map(i => {
      const p = indexToPathPart(i)
      return [`part/${p}`, ['patchOut', "perf", (change, patch) => {
        var out = SynthPathParam()
        if let v = change.value("common/fx/src") {
          out["common/fx/src"] = .p([], p: v)
        }
        return out
      }]]
    }),
    midiOuts: werk.midiOuts(),
    midiChannels: [
     ["patch", ['patch', "global", "patch/channel"]],
    ].concat((16).map(i =>
      [i == 9 ? "rhythm" : `part/${i}`, ['patch', "perf", `part/${i}/channel`]]
    )),
    slotTransforms: [
      ["bank/patch/0", ['user', i => `US:${(i + 1).zPad(3)}`),
      ["bank/perf/0", ['user', i => `US:${(i + 1).zPad(2)}`),
      ["bank/rhythm/0", ['user', i => `US:${(i + 1)}`),
    ],
  }
}

const globalPatchWerk = (parms, size, initFile) => ({
  werk: sysexWerk,
  single: "Global", 
  parms: parms, 
  size: size, 
  start: 0x0000, 
  initFile: initFile,
})

const voicePatchWerk = (common, tone, initFile) => ({
  werk: sysexWerk,
  multi: "Voice", 
  map: [
    ['common', 0x0000, common],
    ['tone/0', 0x1000, tone],
    ['tone/1', 0x1200, tone],
    ['tone/2', 0x1400, tone],
    ['tone/3', 0x1600, tone],
  ], 
  start: 0x03000000, 
  initFile: initFile,
})

const voiceBankWerk = patchWerk => ({
  werk: sysexWerk
  multiBank: patchWerk, 
  patchCount: 128, 
  start: 0x11000000, 
  initFile: "jv1080-voice-bank-init",
})

const voiceCommonPatchWerk = (parms, size) => ({
  werk: sysexWerk,
  single: "Voice Common", 
  parms: parms, 
  size: size, 
  start: 0x0000, 
  name: [0x00, 0x0c],
})  

const perfPatchWerk = (common, part, initFile) => ({
  werk: sysexWerk,
  multi: "Perf", 
  map: [
    ["common", 0x0000, common],
  ].concat(
    (16).map(i => [`part/${i}`, [0x10 + i, 0x00], part])
  ), 
  start: 0x01000000,
  initFile: initFile,
})

const perfBankWerk = patchWerk => ({
  werk: sysexWerk,
  multi: patchWerk, 
  patchCount: 32,
  start: 0x10000000,
  initFile: "jv1080-perf-bank-init",
})

const perfCommonPatchWerk = (parms, size) => ({
  werk: sysexWerk,
  single: "Perf Common", 
  parms: parms, 
  size: size, 
  start: 0x0000, 
  name: [0x00, 0x0c],
  randomize: () => [
    ["level", 127],
    ["pan", 64],
    ["fx/out/assign", 0],
    ["fx/out/level", (90...127).rand()],
    ["velo/range/on", 0],
    ["clock/src", 0],
    ["category", 0],
  ],
})

const perfPartPatchWerk = (parms, size) => ({
  werk: sysexWerk,
  single: "Perf Part", 
  parms: parms, 
  size: size, 
  start: 0x1000, 
  randomize: () => {
    const pgid = (1...6).rand()
    return [
      [.patch, .group] : 0,
      [.patch, .group, .id] : pgid == 2 ? 1 : pgid,
      [.patch, .number] : (0...127).rand(),
    ]
  })
}
)
const moduleTruss = (editorTruss, subid, sections) => ({
  editor: editorTruss,
  manu: Manufacturer.roland, 
  model: editorTruss.displayId, 
  subid: subid, 
  sections: sections, 
  dirMap: [
    ['part', "Patch"],
  ], 
  colorGuide: [
    "#093aba",
    "#a9dd36",
    "#0303fd",
    "#03ff0d",
  ], 
  indexPath: [2, 0],
})

const sections = (perf, clkSrc, cat) => {
  const voice = perfPart => JV1080.Voice.Controller.controller(clkSrc, cat, perfPart)
  
  return [
    ['first', [
      'deviceId',
      ['global', JV1080.Global.controller],
      ['voice', "Patch", voice(null)],
    ]],
    ['basic', "Tones", [
      ['perf', perf],
    ].concat(
      (9).map(i => ['voice', `Buffer ${i + 1}`, voice(i), `part/${i}`])
    ).concat([
      .custom("Rhythm", "rhythm", JV1080.Rhythm.Controller.controller()),
    ]).concat(
      (6).map(i => ['voice', `Buffer ${i + 11}`, voice(i + 10), `part/${i + 10}`])
    )],
    ['banks', [
      ['bank', "Patch Bank", "bank/patch/0"],
      ['bank', "Perf Bank", "bank/perf/0"],
      ['bank', "Rhythm Bank", "bank/rhythm/0"],
    ]],
  ]
}
