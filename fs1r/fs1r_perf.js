require('./utils.js')

const FS1R = require('./fs1r.js')
const Voice = require('./fs1r_voice.js')

// TODO: treat byte (b) values as RolandAddresses for the purposes of packing/unpacking
// i.e. take b, make a RolandAddress from it, then get intValue(), and that's the actual byte address
// whereas the b value itself can be used for parameter midi transmission


// TODO: API QUESTION: should operators like prefix, offset, etc for Parms always treat b and p values as RolandAddresses? Seems like they should. Are there situations where they should not be (check out the Virus)? Should there be a switch to specify which behavior is desired?

const multiPack = (byte) => ['splitter', [
  { byte: byte, valueBits: [7, 14] },
  { byte: byte + 1, valueBits: [0, 7] },  
]]

const optionsDict = (range, options) =>
  Array.sparse(range.rangeMap(i => [i, options[i]]))


const presetFseqNames = ["ShoobyDo", "2BarBeat", "D&B", "D&B Fill", "4BarBeat", "YouCanG", "EBSayHey", "RtmSynth", "VocalRtm", "WooWaPa", "UooLha", "FemRtm", "ByonRole", "WowYeah", "ListenVo", "YAMAHAFS", "Laugh", "Laugh2", "AreYouR", "Oiyai", "Oiaiuo", "UuWaUu", "Wao", "RndArp1", "FiltrArp", "RndArp2", "TechArp", "RndArp3", "Voco-Seq", "PopTech", "1BarBeat", "1BrBeat2", "Undo", "RndArp4", "VoclRtm2", "Reiyowha", "RndArp5", "VocalArp", "CanYouGi", "Pu-Yo", "Yaof", "MyaOh", "ChuckRtm", "ILoveYou", "Jan-On", "Welcome", "One-Two", "Edokko", "Everybdy", "Uwau", "YEEAAH", "4-3-2-1", "Test123", "CheckSnd", "ShavaDo", "R-M-H-R", "HiSchool", "M.Blastr", "L&G MayI", "Hellow", "ChowaUu", "Everybd2", "Dodidowa", "Check123", "BranNewY", "BoomBoom", "Hi=Woo", "FreeForm", "FreqPad", "YouKnow", "OldTech", "B/M", "MiniJngl", "EveryB-S", "IYaan", "Yeah", "ThankYou", "Yes=No", "UnWaEDon", "MouthPop", "Fire", "TBLine", "China", "Aeiou", "YaYeYiYo", "C7Seq", "SoundLib", "IYaan2", "Relax", "PSYAMAHA"]
const presetFseqOptions = Array.sparse(presetFseqNames.map((e, i) => [i + 1, e]))

const bankOptions = ["Off","Int","PrA","PrB","PrC", "PrD","PrE","PrF","PrG","PrH","PrI","PrJ","PrK"]

var channelOptions = (16).map(i => `${i+1}`) 
channelOptions[0x10] = "Pfm"
channelOptions[0x7f] = "Off"

var channelMaxOptions = (16).map(i => `${i+1}`)   
channelMaxOptions[0x7f] = "Off"

const panOptions = { iso: ['switch', [
  [0, "Random"],
  [[1, 128], ['-', 64]],
]] }

const destOptions = ["Off","Insert Param 1", "Insert Param 2", "Insert Param 3", "Insert Param 4", "Insert Param 5", "Insert Param 6", "Insert Param 7", "Insert Param 8", "Insert Param 9", "Insert Param 10", "Insert Param 11", "Insert Param 12", "Insert Param 13", "Insert Param 14", "Ins->Rev", "Ins->Vari", "Volume", "Pan", "Rev Send", "Var Send", "Flt Cutoff", "Flt Reson", "Flt EG Depth", "Attack", "Decay", "Release", "Pitch EG Init", "Pitch EG Attack", "Pitch EG Rel Level", "Pitch EG Rel Time", "V/N Balance", "Formant", "FM", "Pitch Bias", "Amp EG Bias", "Freq Bias", "Voiced BW", "Unvoiced BW", "LFO1 Pitch Mod", "LFO1 Amp Mod", "LFO1 Freq Mod", "LFO1 Filter Mod", "LFO1 Speed", "LFO2 Filter Mod", "LFO2 Speed", "Fseq Speed", "Formant Scratch"]

const reverbOptions = ["None", "Hall 1", "Hall 2", "Room 1", "Room 2", "Room 3", "Stage 1", "Stage 2", "Plate", "White Room", "Tunnel", "Basement", "Canyon", "Delay LCR", "Delay L,R", "Echo", "Cross Delay",]

const varyOptions = ["None", "Chorus", "Celeste", "Flanger", "Symphonic", "Phaser 1", "Phaser 2", "Ens Detune", "Rotary Sp", "Tremolo", "Auto Pan", "Auto Wah", "Touch Wah", "3-Band EQ", "HM Enhancer", "Noise Gate", "Compressor", "Distortion", "Overdrive", "Amp Sim", "Delay LCR", "Delay L,R", "Echo", "Cross Delay", "Karaoke", "Hall", "Room", "Stage", "Plate"]

const insertOptions = ["Thru", "Chorus", "Celeste", "Flanger", "Symphonic", "Phaser 1", "Phaser 2", "Pitch Chng", "Ens Detune", "Rotary Sp", "2 Way Rotary", "Tremolo", "Auto Pan", "Ambience", "A-Wah+Dist", "A-Wah+Odrv", "T-Wah+Dist", "T-Wah+Odrv", "Wah+DS+Dly", "Wah+OD+Dly", "Lo-Fi", "3-Band EQ", "HM Enhncr", "Noise Gate", "Compressor", "Comp+Dist", "Cmp+DS+Dly", "Cmp+OD+Dly", "Distortion", "Dist+Dly", "Overdrive", "Ovdrv+Dly", "Amp Sim", "Delay LCR", "Delay L,R", "Echo", "CrossDelay", "ER 1", "ER 2", "Gate Rev", "Revrs Gate"]

const eqShapeOptions = ["Shelv", "Peak"]
const eqQOptions = { rng: [1, 121], iso: ['>'
  ['*', 0.1],
  ['str', "%.1f"],
] }
 

const reverbTimeParam = { rng: [0, 70], iso: ['switch', [
  [[0, 47] , ['>', ['*', 0.1], ['+', 0.3]]],
  [[47, 57], ['>', ['-', 47], ['*', 0.5], ['+', 5]]],
  [[57, 67], ['>', ['-', 57], ['*', 1], ['+', 10]]],
  [[67, 70], ['>', ['-', 67], ['*', 5], ['+', 20]]],
]] } 
  
const delay200Param = { rng: [0, 128], iso: ['>',
  ['/', 127],
  ['*', 199.9],
  ['+', 0.1],
  ['str', "%.1f"],
] }

const revDelayParam = { rng: [0, 64], iso: ['>',
  ['/', 63],
  ['*', 99.2],
  ['+', 0.1],
  ['str', "%.1f"],
] }

const hiDampParam = { rng: [1, 11], iso: ['>',
  ['*', 0.1],
  ['str', "%.1f"],
] }

const gainParam = { rng: [52, 77], dispOff: -64 }

const cutoffOptions = ["thru","22","25","28","32","36","40","45","50","56","63","70", "80","90","100","110","125","140","160","180","200","225","250","280","315","355","400","450","500","560", "630","700","800","900","1.0k","1.1k","1.2k","1.4k","1.6k","1.8k","2.0k","2.2k","2.5k", "2.8k","3.2k","3.6k","4.0k","4.5k","5.0k","5.6k","6.3k","7.0k","8.0k","9.0k", "10.0k", "11.0k", "12.0k", "14.0k", "16.0k", "18.0k", "thru"]


const hpfCutoffParam = { opts: optionsDict([0, 53], cutoffOptions) }
const lpfCutoffParam = { opts: optionsDict([34, 61], cutoffOptions) }
const eqLoFreqParam = { opts: optionsDict([4, 41], cutoffOptions) }
const eqHiFreqParam = { opts: optionsDict([28, 59], cutoffOptions) }
const eqMidFreqParam = { opts: optionsDict([14, 55], cutoffOptions) }

const qParam = { rng: [10, 121], iso: ['>',
  ['*', 0.1],
  ['str', "%.1f"],
] }

const erRevParam = { iso: ['switch', [
  [[1, 64], ['>', ['*', -1], ['+', 64], ['str', "E%d>R"]]],
  [64, "E=R"],
  [[65, 128], ['>', ['-', 64], ['str', "E<R%d"]]],
]] }

const dimOptions = ["0.5", "0.8", "1.0", "1.3", "1.5", "1.8", "2.0", "2.3", "2.6", "2.8", "3.1", "3.3", "3.6", "3.9", "4.1", "4.4", "4.6", "4.9", "5.2", "5.4", "5.7", "5.9", "6.2", "6.5", "6.7", "7.0", "7.2", "7.5", "7.8", "8.0", "8.3", "8.6", "8.8", "9.1", "9.4", "9.6", "9.9", "10.2", "10.4", "10.7", "11.0", "11.2", "11.5", "11.8", "12.1", "12.3", "12.6", "12.9", "13.1", "13.4", "13.7", "14.0", "14.2", "14.5", "14.8", "15.1", "15.4", "15.6", "15.9", "16.2", "16.5", "16.8", "17.1", "17.3", "17.6", "17.9", "18.2", "18.5", "18.8", "19.1", "19.4", "19.7", "20.0", "20.2", "20.5", "20.8", "21.1", "21.4", "21.7", "22.0", "22.4", "22.7", "23.0", "23.3", "23.6", "23.9", "24.2", "24.5", "24.9", "25.2", "25.5", "25.8", "26.1", "26.5", "26.8", "27.1", "27.5", "27.8", "28.1", "28.5", "28.8", "29.2", "29.5", "29.9", "30.2"]

const widthParam = { opts: optionsDict([0, 38], dimOptions) }
const heightParam = { opts: optionsDict([0, 74], dimOptions) }
const depthParam = { opts: optionsDict([0, 105], dimOptions) }

const delay1365Param = { rng: [1, 13651], iso: ['>', ['*', 0.1], ['str', "%.1f"]] }


const parms = [
  ["category", { b: 0x0e, opts: Voice.categoryOptions }],
  ["volume", { b: 0x10 }],
  ["pan", { b: 0x11, rng: [1, 127+1], dispOff: -64 }],
  ["note/shift", { b: 0x12, rng: [0, 48+1], dispOff: -24 }],
  ["part/out", { b: 0x14, opts: ["Off","Pre Ins","Post Ins"] }],
  ["fseq/part", { b: 0x15, opts: ["Off","1","2","3","4"] }],
  ["fseq/bank", { b: 0x16, opts: ["Int","Pre"] }],
  ["fseq/number", { b: 0x17, max: 89, dispOff: 1 }],
  ["fseq/speed", { b: 0x18, rng: [0, 5001], iso: ['switch', [
      [[0, 5], ['opts', ["Midi 1/4","Midi 1/2","Midi","Midi 2/1","Midi 4/1"]]],
      [[5, 100], "10.0%"],
      [[100, 5001], ['>', ['*', 0.1], ['str', "%.1f%%"]]],
    ]], packIso: multiPack(0x18) }],
  ["fseq/start", { b: 0x1a, packIso: multiPack(0x1a) }],
  ["fseq/loop/start", { b: 0x1c, packIso: multiPack(0x1c) }],
  ["fseq/loop/end", { b: 0x1e, packIso: multiPack(0x1e) }],
  ["fseq/loop", { b: 0x20, opts: ["1-way","Round"] }],
  ["fseq/mode", { b: 0x21, opts: Array.sparse([[1, "Scratch"], [2,  "Fseq"]]) }],
  ["fseq/speed/velo", { b: 0x22, max: 7 }],
  ["fseq/formant/pitch", { b: 0x23, opts: ["Fseq","Fixed"] }],
  ["fseq/trigger", { b: 0x24, opts: ["First","All"] }],
  ["fseq/formant/seq/delay", { b: 0x26, max: 99 }],
  ["fseq/level/velo", { b: 0x27, dispOff: -64 }],
  { prefix: 'ctrl', count: 8, bx: 1, block: [
    { prefix: 'part', count: 4, blockFn: part => 
      ['', { b: 0x28, bit: part }]
    },
    ["dest", { b: 0x40, opts: destOptions }],
    ["depth", { b: 0x48, dispOff: -64 }],
  ] },
  { prefix: 'ctrl', count: 8, blockFn: ctrl => 
    ([
    "knob/0",
    "knob/1",
    "knob/2",
    "knob/3",
    "midi/ctrl/0",
    "midi/ctrl/1",
    "bend",
    
    "channel/aftertouch",
    "poly/aftertouch",
    "foot",
    "breath",
    "midi/ctrl/2",
    "modWheel",
    "midi/ctrl/3",
    ]).map((path, i) =>
      [path, { b: 0x30 + (2 * ctrl) + (i < 7 ? 1 : 0), bit: i % 7 }]
    )
  },
  { prefix: 'reverb', count: 16, blockFn: i => {
    if (i < 8) {
      return ["", { b: 0x50 + 2 * i, packIso: multiPack(0x50 + 2 * i) }]
    }
    else {
      return ["", { b: 0x60 + i - 8 }]
    }
  } },
  { prefix: 'vary', count: 16, blockFn: i => 
    ["", { p: 2, b: 0x68 + 2 * i }]
  },
  { prefix: 'insert', count: 16, blockFn: i => 
    ["", { p: 2, b: 0x88 + 2 * i }]
  },
  { inc: 1, b: 0xa8, block: [
    ["reverb/type", { opts: reverbOptions }],
    ["reverb/pan", { rng: [1, 127+1], dispOff: -64 }],
    ["reverb/level", { }],
    ["vary/type", { opts: varyOptions }],
    ["vary/pan", { rng: [1, 127+1], dispOff: -64 }],
    ["vary/level", { }],
    ["vary/reverb", { }],
    ["insert/type", { opts: insertOptions }],
    ["insert/pan", { rng: [1, 127+1], dispOff: -64 }],
    ["insert/reverb", { }],
    ["insert/vary", { }],
    ["insert/level", { }],
    
    ["lo/gain", { rng: [52, 76+1], dispOff: -64 }],
    ["lo/freq", { opts: optionsDict([4, 41], cutoffOptions) }],
    ["lo/q", eqQOptions],
    ["lo/shape", { opts: eqShapeOptions }],
    ["mid/gain", { rng: [52, 76+1], dispOff: -64 }],
    ["mid/freq", { opts: optionsDict([14, 55], cutoffOptions) }],
    ["mid/q", eqQOptions],
    ["hi/gain", { rng: [52, 76+1], dispOff: -64 }],
    ["hi/freq", { opts: optionsDict([28, 59], cutoffOptions) }],
    ["hi/q", eqQOptions],
    ["hi/shape", { opts: eqShapeOptions }],
  ] },
  { b: 192, offset: 
    { prefix: 'part', count: 4, bx: 52, block: { b2p: 
      { inc: 1, b: 0, block: [
        ["note/reserve", { }],
        ["bank", { opts: bankOptions }],
        ["pgm", {  }],
        ["channel/hi", { opts: channelMaxOptions }],
        ["channel", { opts: channelOptions }],
        ["poly", { opts: ["Mono","Poly"] }],
        ["mono/priority", { opts: ["Last","Top","Bottom","First"] }],
        ["filter/on", { max: 1 }],
        ["note/shift", { max: 48, dispOff: -24 }],
        ["detune", { dispOff: -64 }],
        ["voiced/unvoiced", { dispOff: -64 }],
        ["volume", { }],
        ["velo/depth", { }],
        ["velo/offset", { }],
        ["pan", panOptions],
        ["note/lo", { }],
        ["note/hi", { }],
        ["level", { }],
        ["vary", { }],
        ["reverb", { }],
        ["insert", { }],
        ["lfo/0/rate", { dispOff: -64 }],
        ["lfo/0/pitch/mod", { dispOff: -64 }],
        ["lfo/0/delay", { dispOff: -64 }],
        ["cutoff", { dispOff: -64 }],
        ["reson", { dispOff: -64 }],
        ["env/attack", { dispOff: -64 }],
        ["env/decay", { dispOff: -64 }],
        ["env/release", { dispOff: -64 }],
        ["formant", { dispOff: -64 }],
        ["fm", { dispOff: -64 }],
        ["filter/env/depth", { dispOff: -64 }],
        ["pitch/env/innit", { dispOff: -64 }],
        ["pitch/env/attack", { dispOff: -64 }],
        ["pitch/env/release/level", { dispOff: -64 }],
        ["pitch/env/release/time", { dispOff: -64 }],
        ["porta", { opts: Array.sparse([[0,"Off"],[1,"Fingered"],[3,"Fulltime"]]) }],
        ["porta/time", { }],
        ["bend/hi", { range: [0x10, 0x59], dispOff: -64 }],
        ["bend/lo", { range: [0x10, 0x59], dispOff: -64 }],
        ["pan/scale", { max: 100, dispOff: -50 }],
        ["pan/lfo/depth", { max: 99 }],
        ["velo/lo", { rng: [1, 127+1] }],
        ["velo/hi", { rng: [1, 127+1] }],
        ["pedal/lo", { }],
        ["sustain/rcv", { max: 1 }],
        ["lfo/1/rate", { dispOff: -64 }],
        ["lfo/1/depth", { dispOff: -64 }],
      ] } } 
    }
  },
]

/// sysex bytes for patch as temp perf
const sysexData = FS1R.sysexData([0x10, 0x00, 0x00])

/// sysex bytes for patch as stored in memory location
const sysexDataWithLocation = location => FS1R.sysexData([0x11, 0x00, location])

const patchTruss = {
  single: "perf", 
  namePack: [0, 0x0c],
  parms: parms, 
  initFile: "fs1r-perf-init", 
  createFile: sysexData,
  parseBody: ['bytes', { start: FS1R.parseOffset, count: 400 }],
}

// instead of sending <value>, we send the byte from the bytes array, because some params share bytes with others
const commonParamData = (address, byteCount) => {
  // it's either 1 or 2 bytes holding the value
  const v = byteCount == 1 ? [0, ['byte', address]] : ['+' ['byte', address], ['byte', address + 1]]
  const paramBytes = ['msBytes7bit', address, 2]
  return FS1R.dataSetMsg([0x10, paramBytes], v)
}

const partParamData = (part, parm) => 
  FS1R.dataSetMsg([0x30 + part, 0x00, parm.p], ['byte', parm.b])

// const refTruss: FullRefTruss = {
// 
//   let refPath: SynthPath = "perf"
//   let sections: [(String, [SynthPath])] = [
//     ("Performance", ["perf"]),
//     ("Parts", 4.map { "part/$0" }),
//     ("Fseq", ["fseq"]),
//   ]
// 
//   let createFileData: FullRefTruss.Core.ToMidiFn = { bodyData in
//     // map over the types to ensure ordering of data
//     try trussMap.compactMap {
//       guard case .single(let d) = bodyData[$0.0] else { return nil }
//       switch $0.1.displayId {
//       case Voice.patchTruss.displayId:
//         return Voice.tempSysexData(d, deviceId: 0, part: $0.0.endex).bytes()
//       default:
//         return try $0.1.createFileData(anyBodyData: .single(d))
//       }
//     }.reduce([], +)
//   }
// 
//   let isos: FullRefTruss.Isos = [
//     "fseq" : .basic(path: "fseq/bank", location: "fseq/number", pathMap: [
//       "bank/fseq", "preset/fseq",
//     ])
//   ]
//   <<< 4.dict {
//     let part: SynthPath = "part/$0"
//     return [part : .basic(path: part + "bank", location: part + "pgm", pathMap: [
//       [], "bank/voice",
//     ] + 11.map { "preset/voice/$0" })]
//   }
// 
//   return FullRefTruss("perf.full", trussMap: trussMap, refPath: refPath, isos: isos, sections: sections, initFile: "fs1r-full-perf-init", createFileData: createFileData, pathForData: path(forData:))
// }()

// const trussMap: [(SynthPath, any SysexTruss)] = [
//   ("perf", Perf.patchTruss),
// ] + 4.map { ("part/$0", Voice.patchTruss)} + [
//   ("fseq", Fseq.patchTruss)
// ]

// static func path(forData data: [UInt8]) -> SynthPath? {
//   guard data.count > 6 else { return nil }
//   switch data[6] {
//   case 0x10:
//     return "perf"
//   case 0x40...0x43:
//     return "part/Int(data[") - 0x40)]
//   case 0x60:
//     return "fseq"
//   default:
//     return nil
//   }
// }


const Pairs = {
  loFreq: ["EQ LowFreq", eqLoFreqParam],
  loGain: ["EQ Low Gain", gainParam],
  hiFreq: ["EQ HiFreq", eqHiFreqParam],
  hiGain: ["EQ Hi Gain", gainParam],
  hiDamp: ["High Damp", hiDampParam],

  midFreq: ["Mid Freq", eqMidFreqParam],
  midGain: ["Mid Gain", gainParam],
  midQ: ["Mid Q", qParam],

  lfoFreq: ["LFO Freq", { }],
  lfoDepth: ["LFO Depth", { }],
  fbLevel: ["FB Level", { rng: [1, 128], dispOff: -64 }],
  mode: ["Mode", { }],

  delayOffset: ["Delay Ofst", { }],
  phaseShift: ["Phase Shift", { }],

  dryWet: ["Dry/Wet", { }],

  drive: ["Drive", { }],
  distLoGain: ["DS Low Gain", gainParam],
  distMidGain: ["DS Mid Gain", gainParam],
  lpfCutoff: ["LPF Cutoff", { }],
  outLevel: ["Output Level", { }],

  cutoff: ["Cutoff", { }],
  reson: ["Reson", { }],
  sens: ["Sensitivity", { }],

  delay: ["Delay", { }],
  leftDelay: ["LchDelay", delay1365Param],
  rightDelay: ["RchDelay", delay1365Param],
  centerDelay: ["CchDelay", delay1365Param],
  fbDelay: ["FB Delay", delay1365Param],

}

const hallParams = [
  [0, ["Time", reverbTimeParam]],
  [1, ["Diffusion", { max: 10 }]],
  [2, ["InitDelay", delay200Param]],
  [3, ["HPF Cutoff", hpfCutoffParam]],
  [4, ["LPF Cutoff", lpfCutoffParam]],
  [10, ["Rev Delay", revDelayParam]],
  [11, ["Density", { max: 4 }]],
  [12, ["ER/Rev", erRevParam]],
  [13, Pairs.hiDamp],
  [14, Pairs.fbLevel],
]

const whiteRoomParams = [
  [0, ["Time", reverbTimeParam]],
  [1, ["Diffusion", { max: 10 }]],
  [2, ["InitDelay", delay200Param]],
  [3, ["HPF Cutoff", hpfCutoffParam]],
  [4, ["LPF Cutoff", lpfCutoffParam]],
  [5, ["Width", widthParam]],
  [6, ["Height", heightParam]],
  [7, ["Depth", depthParam]],
  [8, ["Wall Vary", { max: 30 }]],
  [10, ["Rev Delay", revDelayParam]],
  [11, ["Density", { max: 4 }]],
  [12, ["ER/Rev", erRevParam]],
  [13, Pairs.hiDamp],
  [14, Pairs.fbLevel],
  ]

const delayLCRParams = [
  [0, Pairs.leftDelay],
  [1, Pairs.rightDelay],
  [2, Pairs.centerDelay],
  [3, Pairs.fbDelay],
  [4, Pairs.fbLevel],
  [5, ["CchLevel", { }]],
  [6, Pairs.hiDamp],
  [12, Pairs.loFreq],
  [13, Pairs.loGain],
  [14, Pairs.hiFreq],
  [15, Pairs.hiGain],
  ]

const delayLRParams = [
  [0, Pairs.leftDelay],
  [1, Pairs.rightDelay],
  [2, ["FBDelay1", { }]],
  [3, ["FBDelay2", { }]],
  [4, Pairs.fbLevel],
  [5, Pairs.hiDamp],
  [12, Pairs.loFreq],
  [13, Pairs.loGain],
  [14, Pairs.hiFreq],
  [15, Pairs.hiGain],
  ]

const echoParams = [
  [0, Pairs.leftDelay],
  [1, ["Lch FB Lvl", { }]],
  [2, Pairs.rightDelay],
  [3, ["Rch FB Lvl", { }]],
  [4, Pairs.hiDamp],
  [5, ["LchDelay2", { }]],
  [6, ["RchDelay2", { }]],
  [7, ["Delay2 Lvl", { }]],
  [12, Pairs.loFreq],
  [13, Pairs.loGain],
  [14, Pairs.hiFreq],
  [15, Pairs.hiGain],
  ]

const crossDelayParams = [
  [0, ["L>R Delay", { }]],
  [1, ["R>L Delay", { }]],
  [2, Pairs.fbLevel],
  [3, ["InputSelect", { }]],
  [4, Pairs.hiDamp],
  [12, Pairs.loFreq],
  [13, Pairs.loGain],
  [14, Pairs.hiFreq],
  [15, Pairs.hiGain],
  ]

const chorusParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.fbLevel],
  [3, Pairs.delayOffset],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [14, Pairs.mode],
  ]

const flangerParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.fbLevel],
  [3, Pairs.delayOffset],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [13, ["LFO Phase", { }]],
]

const symphParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.delayOffset],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  ]

const phaser1Params = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.phaseShift],
  [3, Pairs.fbLevel],
  [10, ["Stage",{ }]],
  [11, ["Diffuse",{ }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  ]

const phaser2Params = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.phaseShift],
  [3, Pairs.fbLevel],
  [10, ["Stage",{ }]],
  [12, ["LFO Phase", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  ]

const ensDetuneParams = [
  [0, ["Detune",{ }]],
  [1, ["InitDelayL",{ }]],
  [2, ["InitDelayR",{ }]],
  [10, Pairs.loFreq],
  [11, Pairs.loGain],
  [12, Pairs.hiFreq],
  [13, Pairs.hiGain],
  ]

const rotarySpParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  ]

const tremoloParams = [
  [0, Pairs.lfoFreq],
  [1, ["AM Depth", { }]],
  [2, ["PM Depth", { }]],
  [13, ["LFO Phase", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [14, Pairs.mode],
]

const autoPanParams = [
  [0, Pairs.lfoFreq],
  [1, ["L/R Depth", { }]],
  [2, ["F/R Depth", { }]],
  [3, ["Pan Dir", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
]

const autoWahParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, ["Cutoff", { }]],
  [3, ["Reson", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
]

const touchWahParams = [
  [0, ["Sensitivity", { }]],
  [1, ["Cutoff", { }]],
  [2, ["Reson", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
]

const noiseGateParams = [
  [0, ["Attack", { }]],
  [1, ["Release", { }]],
  [2, ["Threshold", { }]],
  [3, ["Output Level", { }]],
]

const compressorParams = [
  [0, ["Attack", { }]],
  [1, ["Release", { }]],
  [2, ["Threshold", { }]],
  [3, ["Ratio", { }]],
  [4, ["Output Level", { }]],
]

const distortionParams = [
  [0, Pairs.drive],
  [1, Pairs.loFreq],
  [2, Pairs.loGain],
  [6, Pairs.midFreq],
  [7, Pairs.midGain],
  [8, Pairs.midQ],
  [3, Pairs.lpfCutoff],
  [10, ["Edge", { }]],
  [4, Pairs.outLevel],
]

const ampSimParams = [
  [0, Pairs.drive],
  [1, ["Amp Type", { }]],
  [2, Pairs.lpfCutoff],
  [10, ["Edge", { }]],
  [3, Pairs.outLevel],
]

const karaokeParams = [
  [0, ["Delay Time", { }]],
  [1, Pairs.fbLevel],
  [2, ["HPF Cutoff", { }]],
  [3, ["LPF Cutoff", { }]],
]

const insertChorusParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.fbLevel],
  [3, Pairs.delayOffset],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [10, Pairs.midFreq],
  [11, Pairs.midGain],
  [12, Pairs.midQ],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [14, Pairs.mode],
  [9, Pairs.dryWet],
]

const insertFlangerParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.fbLevel],
  [3, Pairs.delayOffset],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [10, Pairs.midFreq],
  [11, Pairs.midGain],
  [12, Pairs.midQ],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [13, ["LFO Phase", { }]],
  [9, Pairs.dryWet],
]

const insertSymphParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.delayOffset],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [10, Pairs.midFreq],
  [11, Pairs.midGain],
  [12, Pairs.midQ],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const insertPhaser1Params = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.phaseShift],
  [3, Pairs.fbLevel],
  [10, ["Stage",{ }]],
  [11, ["Diffuse",{ }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const insertPhaser2Params = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.phaseShift],
  [3, Pairs.fbLevel],
  [10, ["Stage",{ }]],
  [12, ["LFO Phase", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const pitchChangeParams = [
  [0, ["Pitch",{ }]],
  [1, ["Init Delay", { }]],
  [2, ["Fine 1",{ }]],
  [3, ["Fine 2", { }]],
  [4, Pairs.fbLevel],
  [10, ["Pan 1", { }]],
  [11, ["Out Level 1", { }]],
  [12, ["Pan 2",{ }]],
  [13, ["Out Level 2", { }]],
  [9, Pairs.dryWet],
]

const insertEnsDetuneParams = [
  [0, ["Detune",{ }]],
  [1, ["InitDelayL",{ }]],
  [2, ["InitDelayR",{ }]],
  [10, Pairs.loFreq],
  [11, Pairs.loGain],
  [12, Pairs.hiFreq],
  [13, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const insertRotarySpParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [10, Pairs.midFreq],
  [11, Pairs.midGain],
  [12, Pairs.midQ],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const twoWayRotaryParams = [
  [0, ["Rotor Spd",{ }]],
  [1, ["Drive Low",{ }]],
  [2, ["Drive Hi",{ }]],
  [3, ["Low/High",{ }]],
  [11, ["Mic Angle",{ }]],
  [10, ["CrossFreq",{ }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
]

const insertTremoloParams = [
  [0, Pairs.lfoFreq],
  [1, ["AM Depth", { }]],
  [2, ["PM Depth", { }]],
  [13, ["LFO Phase", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [10, Pairs.midFreq],
  [11, Pairs.midGain],
  [12, Pairs.midQ],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [14, Pairs.mode],
]

const insertAutoPanParams = [
  [0, Pairs.lfoFreq],
  [1, ["L/R Depth", { }]],
  [2, ["F/R Depth", { }]],
  [3, ["Pan Dir", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [10, Pairs.midFreq],
  [11, Pairs.midGain],
  [12, Pairs.midQ],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
]

const ambienceParams = [
  [0, ["Delay Time", { }]],
  [1, ["Phase", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const autoWahDistParams = [
  [0, Pairs.lfoFreq],
  [1, Pairs.lfoDepth],
  [2, Pairs.cutoff],
  [3, Pairs.reson],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [10, Pairs.drive],
  [11, Pairs.distLoGain],
  [12, Pairs.distMidGain],
  [13, Pairs.lpfCutoff],
  [14, Pairs.outLevel],
  [9, Pairs.dryWet],
]

const touchWahDistParams = [
  [0, Pairs.sens],
  [1, Pairs.cutoff],
  [2, Pairs.reson],
  [15, ["Release", { }]],
  [5, Pairs.loFreq],
  [6, Pairs.loGain],
  [7, Pairs.hiFreq],
  [8, Pairs.hiGain],
  [10, Pairs.drive],
  [11, Pairs.distLoGain],
  [12, Pairs.distMidGain],
  [13, Pairs.lpfCutoff],
  [14, Pairs.outLevel],
  [9, Pairs.dryWet],
]

const wahDistDelayParams = [
  [10, Pairs.sens],
  [11, Pairs.cutoff],
  [12, Pairs.reson],
  [13, ["Release", { }]],
  [3, Pairs.drive],
  [4, Pairs.outLevel],
  [5, Pairs.distLoGain],
  [6, Pairs.distMidGain],
  [0, Pairs.delay],
  [1, Pairs.fbLevel],
  [2, ["Delay Mix", { }]],
  [9, Pairs.dryWet],
]

const loFiParams = [
  [0, ["Smpl Freq", { }]],
  [1, ["Word Length", { }]],
  [2, ["Output Gain", { }]],
  [3, Pairs.lpfCutoff],
  [5, ["LPF Reso", { }]],
  [4, ["Filter", { }]],
  [6, ["Bit Assign", { }]],
  [7, ["Emphasis", { }]],
  [9, Pairs.dryWet],
]

const triBandEQParams = [
  [5, Pairs.loFreq],
  [0, Pairs.loGain],
  [1, Pairs.midFreq],
  [2, Pairs.midGain],
  [3, Pairs.midQ],
  [6, Pairs.hiFreq],
  [4, Pairs.hiGain],
  [14, Pairs.mode],
]

const hmEnhancerParams = [
  [0, ["HPF Cutoff", { }]],
  [1, Pairs.drive],
  [2, ["Mix Level", { }]],
]

const compDistParams = [
  [11, ["Attack", { }]],
  [12, ["Release", { }]],
  [13, ["Threshold", { }]],
  [14, ["Ratio", { }]],
  [0, Pairs.drive],
  [1, Pairs.loFreq],
  [2, Pairs.loGain],
  [6, Pairs.midFreq],
  [7, Pairs.midGain],
  [8, Pairs.midQ],
  [3, Pairs.lpfCutoff],
  [10, ["Edge", { }]],
  [4, Pairs.outLevel],
  [9, Pairs.dryWet],
]

const compDistDelayParams = [
  [10, ["Attack", { }]],
  [11, ["Release", { }]],
  [12, ["Threshold", { }]],
  [13, ["Ratio", { }]],
  [3, Pairs.drive],
  [4, Pairs.outLevel],
  [5, Pairs.distLoGain],
  [6, Pairs.distMidGain],
  [0, Pairs.delay],
  [1, Pairs.fbLevel],
  [2, ["Delay Mix", { }]],
  [9, Pairs.dryWet],
]

const insertDistortionParams = [
  [0, Pairs.drive],
  [1, Pairs.loFreq],
  [2, Pairs.loGain],
  [6, Pairs.midFreq],
  [7, Pairs.midGain],
  [8, Pairs.midQ],
  [3, Pairs.lpfCutoff],
  [10, ["Edge", { }]],
  [4, Pairs.outLevel],
  [9, Pairs.dryWet],
]

const distDelayParams = [
  [5, Pairs.drive],
  [7, Pairs.distLoGain],
  [8, Pairs.distMidGain],
  [0, ["LchDelay", { }]],
  [1, ["RchDelay", { }]],
  [2, ["FB Delay", { }]],
  [3, Pairs.fbLevel],
  [4, ["Delay Mix", { }]],
  [6, Pairs.outLevel],
  [9, Pairs.dryWet],
  ]

const insertAmpSimParams = [
  [0, Pairs.drive],
  [1, ["Amp Type", { }]],
  [2, Pairs.lpfCutoff],
  [10, ["Edge", { }]],
  [3, Pairs.outLevel],
  [9, Pairs.dryWet],
]

const insertDelayLCRParams = [
  [0, Pairs.leftDelay],
  [1, Pairs.rightDelay],
  [2, Pairs.centerDelay],
  [3, Pairs.fbDelay],
  [4, Pairs.fbLevel],
  [5, ["CchLevel", { }]],
  [6, Pairs.hiDamp],
  [12, Pairs.loFreq],
  [13, Pairs.loGain],
  [14, Pairs.hiFreq],
  [15, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const insertDelayLRParams = [
  [0, Pairs.leftDelay],
  [1, Pairs.rightDelay],
  [2, ["FBDelay1", { }]],
  [3, ["FBDelay2", { }]],
  [4, Pairs.fbLevel],
  [5, Pairs.hiDamp],
  [12, Pairs.loFreq],
  [13, Pairs.loGain],
  [14, Pairs.hiFreq],
  [15, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const insertEchoParams = [
  [0, Pairs.leftDelay],
  [1, ["Lch FB Lvl", { }]],
  [2, Pairs.rightDelay],
  [3, ["Rch FB Lvl", { }]],
  [4, Pairs.hiDamp],
  [5, ["LchDelay2", { }]],
  [6, ["RchDelay2", { }]],
  [7, ["Delay2 Lvl", { }]],
  [12, Pairs.loFreq],
  [13, Pairs.loGain],
  [14, Pairs.hiFreq],
  [15, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const insertCrossDelayParams = [
  [0, ["L>R Delay", { }]],
  [1, ["R>L Delay", { }]],
  [2, Pairs.fbLevel],
  [3, ["InputSelect", { }]],
  [4, Pairs.hiDamp],
  [12, Pairs.loFreq],
  [13, Pairs.loGain],
  [14, Pairs.hiFreq],
  [15, Pairs.hiGain],
  [9, Pairs.dryWet],
]

const er1Params = [
  [0, ["Early Type", { }]],
  [1, ["Room Size", { }]],
  [2, ["Diffusion", { }]],
  [3, ["Init Delay", delay200Param]],
  [4, Pairs.fbLevel],
  [5, ["HPF Cutoff", { }]],
  [6, Pairs.lpfCutoff],
  [10, ["Liveness", { }]],
  [11, ["Density", { }]],
  [12, Pairs.hiDamp],
  [9, Pairs.dryWet],
]

const gateRevParams = [
  [0, ["Gate Type", { }]],
  [1, ["Room Size", { }]],
  [2, ["Diffusion", { }]],
  [3, ["Init Delay", delay200Param]],
  [4, Pairs.fbLevel],
  [5, ["HPF Cutoff", { }]],
  [6, Pairs.lpfCutoff],
  [10, ["Liveness", { }]],
  [11, ["Density", { }]],
  [12, Pairs.hiDamp],
  [9, Pairs.dryWet],
]

const reverbParams = [
  [],
  hallParams, // hall 1
  hallParams, // hall 2
  hallParams, // room 1
  hallParams, // room 2
  hallParams, // room 3
  hallParams, // stage 1
  hallParams, // stage 2
  hallParams, // plate
  whiteRoomParams, // white room
  whiteRoomParams, // tunnel
  whiteRoomParams, // basement
  whiteRoomParams, // canyon
  delayLCRParams,
  delayLRParams,
  echoParams,
  crossDelayParams,
]

const varyParams = [
  [],
  chorusParams,
  chorusParams, // celeste
  flangerParams,
  symphParams,
  phaser1Params,
  phaser2Params,
  ensDetuneParams,
  rotarySpParams,
  tremoloParams,
  autoPanParams,
  autoWahParams,
  touchWahParams,
  triBandEQParams,
  hmEnhancerParams,
  noiseGateParams,
  compressorParams,
  distortionParams,
  distortionParams, // overdrive
  ampSimParams,
  delayLCRParams,
  delayLRParams,
  echoParams,
  crossDelayParams,
  karaokeParams,
  hallParams, // hall
  hallParams, // room
  hallParams, // stage
  hallParams, // plate
]

const insertParams = [
  [],
  insertChorusParams,
  insertChorusParams, // celeste
  insertFlangerParams,
  insertSymphParams,
  insertPhaser1Params,
  insertPhaser2Params,
  pitchChangeParams,
  insertEnsDetuneParams,
  insertRotarySpParams,
  twoWayRotaryParams,
  insertTremoloParams,
  insertAutoPanParams,
  ambienceParams,
  autoWahDistParams,
  autoWahDistParams, // autowah/OD
  touchWahDistParams,
  touchWahDistParams, // touchwah/OD
  wahDistDelayParams,
  wahDistDelayParams, // wah/OD/delay
  loFiParams,
  triBandEQParams,
  hmEnhancerParams,
  noiseGateParams,
  compressorParams,
  compDistParams,
  compDistDelayParams,
  compDistDelayParams, // comp/OD/delay
  insertDistortionParams,
  distDelayParams,
  insertDistortionParams, // overdrive
  distDelayParams, // OD/delay
  insertAmpSimParams,
  insertDelayLCRParams,
  insertDelayLRParams,
  insertEchoParams,
  insertCrossDelayParams,
  er1Params,
  er1Params, // ER 2
  gateRevParams,
  gateRevParams, // reverse gate
]

module.exports = {
  patchTruss: patchTruss,
  bankTruss: {
    singleBank: patchTruss,
    patchCount: 128, 
    createFile: {
      locationMap: location => sysexDataWithLocation(location)
    },
    locationIndex: 8,
  },
  patchTransform: {
    throttle: 30,
    singlePatch: [[sysexData, 100]], 
    param: (path, parm, value) => {
      const part = path[0] == 'part' ? path[1] : -1
      if (part >= 0) {
        return [[partParamData(part, parm), 30]]
      }
      else {
        // common params have param address stored in .byte
        var byte = parm.b
        var byteCount = parm.packIso != null ? 2 : 1
        if (byte >= 0x30 && byte < 0x40) {
          // special treatment for src bits
          byte = byte - (byte % 2)
          byteCount = 2
        }
        return [[commonParamData(byte, byteCount), 30]]
      }
    }, 
    name: patchTruss.namePack.rangeMap(i => [
      commonParamData(i, 1), 30
    ]),
  },
  bankTransform: {
    throttle: 0,
    singleBank: location => [sysexDataWithLocation(location), 100]
  },
  reverbParams,
  varyParams,
  insertParams,
  presetFseqOptions,
}