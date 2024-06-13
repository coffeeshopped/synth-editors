require('../core/NumberUtils.js')
require('../core/ArrayUtils.js')
const Matrix = require('./matrix.js')

const rampModeOptions = ["Single","Multi","External","Ext Gated"]
const fixedModsOptions = ["Off","Bend","Vibrato","Both"]

const mixOptions = (64).map((i) => 
  i == 31 ? "Equal" : i < 31 ? `O2 +${31 - i}` : `O1 +${i - 31}`
)

const portaOptions = ["Off","Porta","Key Track"]

const modSourceOptions = ["Unused","Env 1","Env 2","Env 3","LFO 1","LFO 2","Vibrato","Ramp 1","Ramp 2","Keyboard","Portamento","Tracking Gen","Keybd Gate","Velocity","Release Velo","Pressure","Pedal 1","Pedal 2","Lever 1 (Bend)","Lever 2 (Mod)","Lever 3 (Breath)"]

// removing first option
const trkSrcOptions = modSourceOptions.mapWithIndex((s, i) => [i, s]).slice(1)

const modDestinationOptions = ["Unused","DCO1 Freq","DCO1 PW","DCO1 Waveshape","DCO2 Freq","DCO2 PW","DCO2 Waveshape","Mix Level","VCF FM Amount","VCF Freq","VCF Resonance","VCA1 Level","VCA2 Level","Env1 Delay","Env1 Attack","Env1 Decay","Env1 Release","Env1 Amp","Env2 Delay","Env2 Attack","Env2 Decay","Env2 Release","Env2 Amp","Env3 Delay","Env3 Attack","Env3 Decay","Env3 Release","Env3 Amp","LFO1 Speed","LFO1 Amp","LFO2 Speed","LFO2 Amp","Porta Time"]

function createPatchTruss(createFileData) {    
  return {
    type: "singlePatch",
    id: "matrix6.voice",
    bodyDataCount: 134,
    initFile: "matrix1000-init",
    parseBody: (bodyData) => {
      let d = bodyData.safeBytes(5, 268)
      return (134).map((i) => {
        let off = i * 2
        return d[off].bits(0, 3) + (d[off + 1].bits(0, 3) << 4)
      })
    },
    createFile: createFileData,
    parms: parms,
    unpack: (bodyData, param) => {
      // Gotta handle those negative values
      let byte = param.byte
      if (byte >= bodyData.count) { return null }
      // return Int(Int8(bitPattern: bodyData[byte]))
      return bodyData[byte]
    },
    namePack: {
      type: 'filtered',
      range: [0, 8],
      toBytes: ['upper', (char) => char & 0x3f],
      toString: [(byte) => byte > 31 ? byte : (byte & 0x3f) | 0x40, 'clean'],
    },
    randomize: () => [
      [["env", 1, "trigger", "mode"], 0],
      [["env", 1, "lfo", "trigger", "mode"], 0],
      [["env", 1, "mode"], 0],
      [["env", 1, "delay"], 0],
      [["env", 1, "amp"], 63],
      [["env", 1, "velo"], (64).rand()],
      [["amp", 0, "amt"], 63],
      [["amp", 0, "velo", "amt"], (64).rand()],
      [["amp", 1, "env", 1, "amt"], 63],
    ],
  }
}

function createBankTruss(patchTruss) {
  let patchCount = 100
  
  // 30404 is a full dump with extra global/splits info
  return {
    type: "singleBank",
    patchTruss: patchTruss,
    patchCount: patchCount, 
    createFile: {
      type: 'createFileDataWithLocationMap',
      locationMap: (bodyData, location) => sysexDataWithLocation(bodyData, location),
    }, 
    parseBody: {
      type: 'sortAndParseBody',
      locationIndex: 4, 
      parseBody: patchTruss.parseBody, 
      patchCount: patchCount,
    }, 
    validSizes: [30404], 
    includeFileDataCount: true,
  }
}

const parms = [
  [
    [["key", "mode"], { b: 8, p: 48, opts: ["Reassign","Rotate","Unison","Reassign w/ Rob"] }],
    [["osc", 0, "freq"], { b: 9, p: 0, max: 63 }],
    [["osc", 0, "shape"], { b: 10, p: 5, max: 63 }],
    [["osc", 0, "pw"], { b: 11, p: 3, max: 63 }],
    [["osc", 0, "fixed", "mod"], { b: 12, p: 7, opts: fixedModsOptions }],
    [["osc", 0, "wave"], { b: 13, p: 6, opts: ["Off","Pulse","Wave","Both"] }],
    [["osc", 1, "freq"], { b: 14, p: 10, max: 63 }],
    [["osc", 1, "shape"], { b: 15, p: 15, max: 63 }],
    [["osc", 1, "pw"], { b: 16, p: 13, max: 63 }],
    [["osc", 1, "fixed", "mod"], { b: 17, p: 17, opts: fixedModsOptions }],
    [["osc", 1, "wave"], { b: 18, p: 16, opts: ["Off","Pulse","Wave","Both","Noise"] }],
    [["osc", 1, "detune"], { b: 19, p: 12, rng: [-31, 32] }],
    [["mix"], { b: 20, p: 20, opts: mixOptions }],
    [["osc", 0, "porta"], { b: 21, p: 8, max: 1 }],
    [["osc", 0, "click"], { b: 22, p: 9, max: 1 }],
    [["osc", 1, "porta"], { b: 23, p: 18, opts: portaOptions }],
    [["osc", 1, "click"], { b: 24, p: 19, max: 1 }],
    [["osc", "sync"], { b: 25, p: 2, opts: ["Off","Soft","Medium","Hard"] }],
    [["cutoff"], { b: 26, p: 21 }],
    [["reson"], { b: 27, p: 24, max: 63 }],
    [["filter", "fixed", "mod"], { b: 28, p: 25, opts: fixedModsOptions }],
    [["filter", "porta"], { b: 29, p: 26, opts: portaOptions }],
    [["filter", "fm"], { b: 30, p: 30, max: 63 }],
    [["amp", 0, "amt"], { b: 31, p: 27, max: 63 }],
    [["porta", "rate"], { b: 32, p: 44, max: 63 }],
    [["lag", "mode"], { b: 33, p: 46, opts: ["Const Speed","Const Time","Exponent"] }],
    [["porta", "legato"], { b: 34, p: 47, max: 1 }],
  ],
  {
    prefix: 'lfo', count: 2, bx: 7, px: 10, block: () => [
      [["speed"], { b: 35, p: 80, max: 63 }],
      [["trigger"], { b: 36, p: 86, opts: ["Off","Single","Multi","External"] }],
      [["lag"], { b: 37, p: 87, max: 1 }],
      [["wave"], { b: 38, p: 82, opts: ["Triangle","Saw Up","Saw Down","Square","Random","Noise","Sampled Modulation"] }],
      [["retrigger", "pt"], { b: 39, p: 83, max: 63 }],
      [["sample", "src"], { b: 40, p: 88, options: trkSrcOptions }],
      [["amp"], { b: 41, p: 84, max: 63 }],
    ] 
  },
  {
    prefix: 'env', count: 3, bx: 9, px: 10, block: () => [
      [["trigger", "mode"], { b: 49, p: 57, opts: ["Single","Single Reset","Multiple","Multi Reset","Ext Single","Ext Single Reset","Ext Multi","Ext Multi Reset"] }],
      [["delay"], { b: 50, p: 50, max: 63 }],
      [["attack"], { b: 51, p: 51, max: 63 }],
      [["decay"], { b: 52, p: 52, max: 63 }],
      [["sustain"], { b: 53, p: 53, max: 63 }],
      [["release"], { b: 54, p: 54, max: 63 }],
      [["amp"], { b: 55, p: 55, max: 63 }],
      [["lfo", "trigger", "mode"], { b: 56, p: 59, options: [
        [0, "Normal"],
        [2, "LFO 1"],
        [3, "Gated LFO 1"],
        ] }],
      [["mode"], { b: 57, p: 58, opts: ["Normal","DADR","Freerun","Both"] }],
    ]
  },
  [
    [["trk", "src"], { b: 76, p: 33, options: trkSrcOptions }],
  ],
  {
    prefix: "trk/pt", count: 5, bx: 1, px: 1, block: () => [
      [[], { b: 77, p: 34, max: 63 }],
    ]
  },
  [
    [["ramp", 0, "rate"], { b: 82, p: 40, max: 63 }],
    [["ramp", 0, "mode"], { b: 83, p: 41, opts: rampModeOptions }],
    [["ramp", 1, "rate"], { b: 84, p: 42, max: 63 }],
    [["ramp", 1, "mode"], { b: 85, p: 43, opts: rampModeOptions }],
    [["osc", 0, "freq", "lfo", 0, "amt"], { b: 86, p: 1, rng: [-63, 64] }],
    [["osc", 0, "pw", "lfo", 1, "amt"], { b: 87, p: 4, rng: [-63, 64] }],
    [["osc", 1, "freq", "lfo", 0, "amt"], { b: 88, p: 11, rng: [-63, 64] }],
    [["osc", 1, "pw", "lfo", 1, "amt"], { b: 89, p: 14, rng: [-63, 64] }],
    [["cutoff", "env", 0, "amt"], { b: 90, p: 22, rng: [-63, 64] }],
    [["cutoff", "pressure", "amt"], { b: 91, p: 23, rng: [-63, 64] }],
    [["amp", 0, "velo", "amt"], { b: 92, p: 28, rng: [-63, 64] }],
    [["amp", 1, "env", 1, "amt"], { b: 93, p: 29, rng: [-63, 64] }],
    [["env", 0, "velo"], { b: 94, p: 56, rng: [-63, 64] }],
    [["env", 1, "velo"], { b: 95, p: 66, rng: [-63, 64] }],
    [["env", 2, "velo"], { b: 96, p: 76, rng: [-63, 64] }],
    [["lfo", 0, "ramp", 0, "amt"], { b: 97, p: 85, rng: [-63, 64] }],
    [["lfo", 1, "ramp", 1, "amt"], { b: 98, p: 95, rng: [-63, 64] }],
    [["porta", "rate", "velo", "amt"], { b: 99, p: 45, rng: [-63, 64] }],
    [["filter", "fm", "env", 2, "amt"], { b: 100, p: 31, rng: [-63, 64] }],
    [["filter", "fm", "pressure", "amt"], { b: 101, p: 32, rng: [-63, 64] }],
    [["lfo", 0, "speed", "pressure", "amt"], { b: 102, p: 81, rng: [-63, 64] }],
    [["lfo", 1, "speed", "key", "amt"], { b: 103, p: 91, rng: [-63, 64] }],  
  ],
  {
    prefix: 'mod', count: 10, bx: 3, px: 0, block: (mod) => [
      [["src"], { b: 104, p: -(mod + 1), opts: modSourceOptions }],
      [["amt"], { b: 105, p: -(mod + 1), rng: [-63, 64] }],
      [["dest"], { b: 106, p: -(mod + 1), opts: modDestinationOptions }],
    ]
  },
]

const sysex = (bodyData, location) =>
  ['syx', sysexDataWithLocation(bodyData, location)]

const sysexDataWithLocation = (bodyData, location) =>
  sysexDataWithHeader(bodyData, [0x01, location])

const sysexDataWithHeader = (bodyData, header) => {
  let bodyBytes = bodyData.flatMap(b => [b.bits(0, 4), b.bits(4, 8)])
  let checksum = bodyData.sum() & 0x7f
  return Matrix.sysex(header.concat(bodyBytes).concat([checksum]))
}

const patchOut = (location, bytes) => [[["syx", sysexDataWithLocation(bytes, location)], 100]]

const patchTruss = createPatchTruss(bodyData => sysexDataWithLocation(bodyData, 0))

module.exports = {

  patchTruss: patchTruss,

  createPatchTruss: createPatchTruss,
  
  sysex: sysex,
  
  sysexDataWithLocation: sysexDataWithLocation,
  
  sysexDataWithHeader: sysexDataWithHeader,

  bankTruss: createBankTruss(patchTruss),
  
  createBankTruss: createBankTruss,
  
  patchTransform: {
    type: 'singlePatch',
    throttle: 200,
    editorVal: Matrix.tempPatch,
    param: (v, bodyData, parm, value) => {
      if (!parm) { return null }
      if (parm.p < 0) {
        // MATRIX MOD SEND
        // send the whole patch for mod changes
        return patchOut(v, bodyData)
      }
      else {
        // NORMAL PARAM SEND
        if (value < 0 || pathEq(parm.path, "env/0/sustain") || pathEq(parm.path, "amp/1/env/1/amt")) {
          return patchOut(v, bodyData)
        }
        else {
          // quick edit doesn't save to the 6, so use a timer to do periodic saves
          return [
            [["syx", Matrix.sysex([0x05])], 10], // quick edit mode bytes
            [["syx", Matrix.sysex([0x06, parm.p, value])], 10],
          ]
        }
      }
    }, 
    patch: (v, bodyData) => patchOut(v, bodyData), 
    name: (v, bodyData, path, name) => patchOut(v, bodyData),
  },

  parms: parms,
  
  bankTransform: {
    type: 'singleBank',
    throttle: 0,
    bank: (editorVal, bodyData, location) => [(sysex(bodyData, location), 50)],
  },

}

// console.dir(module.exports, { depth: null })