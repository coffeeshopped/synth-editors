const Op4 = require('./op4.js')

const noteIso = {
  type: 'noteName',
  zeroNote: "C-2",
}

const voiceNumberPack = byte => ({
  splitter: [
    [byte, null, [0, 7]],
    [byte - 1, null, [7, 8]],
  ],
})

const bankVoiceNumberPack = byte => ({
  splitter: [
    [byte, null, [0, 7]],
    [byte - 1, [4, 5], [7, 8]],
  ]
})

const parms = [
  { prefix: 'part', count: 8, bx: 12, block: i => [
    ["voice/reserve", { b: 0, max: 8 }],
    ["voice/number", { b: 2, packIso: voiceNumberPack(i * 12 + 2 ), max: 159 }],
    ["channel", { b: 3, opts: ((16).map(i => `${i + 1}`) + ["Omni"]) }],
    ["note/lo", { b: 4, iso: noteIso }],
    ["note/hi", { b: 5, iso: noteIso }],
    ["detune", { b: 6, max: 14, dispOff: -7 }],
    ["note/shift", { b: 7, max: 48, dispOff: -24 }],
    ["volume", { b: 8, max: 99 }],
    ["out/select", { b: 9, opts: ["Off", "I", "II", "I+II"] }],
    ["lfo", { b: 10, opts: ["Off", "Inst 1", "Inst 2", "Vib"] }],
    ["micro", { b: 11, max: 1 }],
  ] },
  ["micro/scale", { b: 96, opts: ["Oct.", "Full", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"] }],
  ["assign", { b: 97, opts: ["Norm", "Altr"] }],
  ["fx", { b: 98, opts: ["Off", "Delay", "Pan", "Chord"] }],
  ["micro/key", { b: 99, opts: ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"] }],
]

const compactParms = [
  { prefix: 'part', count: 8, bx: 8, block: i => [
    ["voice/reserve", { b: 0, bits: [0, 4] }],
    ["voice/number", { b: 1, packIso: bankVoiceNumberPack(i * 8 + 1) }], // MSB in bit 4 of po + 0
    ["channel", { b: 2, bits: [0, 3] }],
    ["note/lo", { b: 3 }],
    ["note/hi", { b: 4 }],
    ["detune", { b: 5, bits: [0, 4] }],
    ["note/shift", { b: 6, bits: [0, 6] }],
    ["volume", { b: 7 }],
    ["out/select", { b: 0, bits: [5, 7] }],
    ["lfo", { b: 2, bits: [5, 7] }],
    ["micro", { b: 6, bit: 6 }],
  ] },
  ["micro/scale", { b: 64, bits: [0, 4] }],
  ["assign", { b: 65, bit: 0 }],
  ["fx", { b: 65, bits: [1, 3] }],
  ["micro/key", { b: 65, bits: [3, 7] }],
]

const patchChangeTransform = (patchWerk) => ({
  type: 'singlePatch',
  throttle: 30, 
  editorVal: Op4.sysexChannel,
  param: (editorVal, bodyData, parm, path, value) => {
    if (path.last() == 'number') {
      return [
        [patchWerk.paramData(editorVal, [parm.b - 1, value.bit(7)]), 50],
        [patchWerk.paramData(editorVal, [parm.b, value.bits(0, 7)]), 0],
      ]
    }
    else {
      return [[patchWerk.paramData(editorVal, [parm.b, bodyData[parm.b]]), 0]]
    }
  }, 
  patch: patchWerk.patchTransform, 
  name: patchWerk.nameTransform,
})
const sysexData = channel => [
  ['+', ["enc", "LM  8976PE"], "b"],
  ['yamCmd', [channel, 0x7e, 0x00, 0x78]],
]

const patchTruss = {
  type: 'singlePatch',
  id: 'tx81z.perf',
  bodyDataCount: 110, 
  namePack: [100, 110],
  parms: parms, 
  initFile: "tx81z-perf-init", 
  createFile: sysexData(0),
  parseBody: 16,
}

const compactTruss = {
  type: 'singlePatch',
  id: 'tx81z.perf.compact',
  bodyDataCount: 76,
  namePack: [66, 76],
  parms: compactParms,
}


const createPatchWerk = (parms, compactParms) => Op4.patchWerk(0x10, patchTruss.namePack, sysexData)

const patchWerk = createPatchWerk(parms, compactParms)

const bankSysexData = channel => [
  ['+', ['enc', "LM  8976PM"], 'b'],
  ['yamCmd', [channel, 0x7e, 0x13, 0x0a]],
]


const createBankTruss = (patchCount, patchTruss, compactTruss, initFile) => ({
  type: 'compactSingleBank',
  patchTruss: patchTruss,
  patchCount: patchCount,
  paddedPatchCount: 32,
  initFile: initFile,
  fileDataCount: 2450, 
  compactTruss: compactTruss, 
  createFile: bankSysexData(0),
  parseBody: 16,
})

const wholeBankTransform = (patchCount, patchTruss, compactTruss) => ({
  type: 'single',
  throttle: 30,
  editorVal: Op4.sysexChannel,
  wholeBank: editorVal => [[bankSysexData(editorVal), 100]],
})

const presetVoices = ["A1. GrandPiano", "A2. Uprt Piano", "A3. Deep Grd", "A4. HonkeyTonk", "A5. Elec Grand", "A6. Fuzz Piano", "A7. SkoolPiano", "A8. Thump Pno", "A9. LoTine81Z", "A10. HiTine81Z", "A11. ElectroPno", "A12. NewElectro", "A13. DynomiteEP", "A14. DynoWurlie", "A15. Wood Piano", "A16. Reed Piano", "A17. PercOrgan", "A18. 16 8 4 2 F", "A19. PumpOrgan", "A20. <6 Tease>", "A21. Farcheeza", "A22. Small Pipe", "A23. Big Church", "A24. AnalogOrgn", "A25. Thin Clav", "A26. EZ Clav", "A27. Fuzz Clavi", "A28. LiteHarpsi", "A29. RichHarpsi", "A30. Celeste", "A31. BriteCelst", "A32. Squeezebox", "B1. Trumpet81Z", "B2. Full Brass", "B3. FlugelHorn", "B4. ChorusBras", "B5. French Horn", "B6. AtackBrass", "B7. SpitBoneBC", "B8. Horns BC", "B9. MelloTenor", "B10. RaspAlto", "B11. Flute", "B12. Pan Floot", "B13. Basson", "B14. Oboe", "B15. Clarinet", "B16. Harmonica", "B17. DoubleBass", "B18. BowCello", "B19. BoxCello", "B20. SoloViolin", "B21. HiString 1", "B22. LowString", "B23. Pizzicato", "B24. Harp", "B25. ReverbStrg", "B26. SynString", "B27. Voices", "B28. HarmoPad", "B29. FanfarTpts", "B30. HiString 2", "B31. PercFlute", "B32. BreathOrgn", "C1. NylonGuit", "C2. Guitar #1", "C3. TwelveStrg", "C4. Funky Pick", "C5. AllThatJaz", "C6. HeavyMetal", "C7. Old Banjo", "C8. Zither", "C9. ElecBass 1", "C10. SqncrBass", "C11. SynFunkBas", "C12. ElecBass 2", "C13. AnalogBass", "C14. Jaco Bass", "C15. LatelyBass", "C16. MonophBass", "C17. StadiumSol", "C18. TrumptSolo", "C19. BCSexyPhon", "C20. Lyrisyn", "C21. WarmSquare", "C22. Sync Lead", "C23. MellowSqar", "C24. Jazz Flute", "C25. HeavyLead", "C26. Java Jive", "C27. Xylophone", "C28. GreatVibes", "C29. Sitar", "C30. Bell Pad", "C31. PlasticHit", "C32. DigiAnnie", "D1. BaadBreath", "D2. VocalNuts", "D3. KrstlChoir", "D4. Metalimba", "D5. WaterGlass", "D6. BowedBell", "D7. >>WOW<<", "D8. Fuzzy Koto", "D9. Spc Midiot", "D10. Gurgle", "D11. Hole in 1", "D12. Birds", "D13. MalibuNite", "D14. Helicopter", "D15. Flight Sim", "D16. BrthBells", "D17. Storm Wind", "D18. Alarm Call", "D19. Racing Car", "D20. Whistling", "D21. Space Talk", "D22. Space Vibe", "D23. Timpani", "D24. FM Hi-Hats", "D25. Bass Drum", "D26. Tube Bells", "D27. Noise Shot", "D28. Snare 1", "D29. Snare 2", "D30. Hand Drum", "D31. Synballs", "D32. Efem Toms"]


module.exports = {
  patchTruss: patchTruss,
  compactTruss: compactTruss,
  bankTruss: createBankTruss(24, patchTruss, compactTruss, ""),
  patchTransform: patchChangeTransform(patchWerk),
}

