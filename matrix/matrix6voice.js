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
    parseBody: [
      ['bytes', 5, 268],
      'denibblizeLSB',
    ],
    createFile: createFileData,
    parms: parms,
    unpack: {
      b: '2comp',
    },
    namePack: {
      type: 'filtered',
      range: [0, 8],
      toBytes: ['upper', char => char & 0x3f],
      toString: [byte => byte > 31 ? byte : (byte | 0x40), 'clean'],
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

// 30404 is a full dump with extra global/splits info
const createBankTruss = patchTruss => ({
  type: "singleBank",
  patchTruss: patchTruss,
  patchCount: 100, 
  createFile: {
    locationMap: sysexDataWithLocation,
  }, 
  parseBody: {
    locationIndex: 4, 
    parseBody: patchTruss.parseBody, 
    patchCount: 100,
  }, 
  validSizes: [30404], 
  includeFileDataCount: true,
})

const parms = [
  { inc: 1, b: 8, block: [
    ["key/mode", { p: 48, opts: ["Reassign","Rotate","Unison","Reassign w/ Rob"] }],
    [["osc", 0, "freq"], { p: 0, max: 63 }],
    [["osc", 0, "shape"], { p: 5, max: 63 }],
    [["osc", 0, "pw"], { p: 3, max: 63 }],
    [["osc", 0, "fixed", "mod"], { p: 7, opts: fixedModsOptions }],
    [["osc", 0, "wave"], { p: 6, opts: ["Off","Pulse","Wave","Both"] }],
    [["osc", 1, "freq"], { p: 10, max: 63 }],
    [["osc", 1, "shape"], { p: 15, max: 63 }],
    [["osc", 1, "pw"], { p: 13, max: 63 }],
    [["osc", 1, "fixed", "mod"], { p: 17, opts: fixedModsOptions }],
    [["osc", 1, "wave"], { p: 16, opts: ["Off","Pulse","Wave","Both","Noise"] }],
    [["osc", 1, "detune"], { p: 12, rng: [-31, 32] }],
    [["mix"], { p: 20, opts: mixOptions }],
    [["osc", 0, "porta"], { p: 8, max: 1 }],
    [["osc", 0, "click"], { p: 9, max: 1 }],
    [["osc", 1, "porta"], { p: 18, opts: portaOptions }],
    [["osc", 1, "click"], { p: 19, max: 1 }],
    [["osc", "sync"], { p: 2, opts: ["Off","Soft","Medium","Hard"] }],
    [["cutoff"], { p: 21 }],
    [["reson"], { p: 24, max: 63 }],
    [["filter", "fixed", "mod"], { p: 25, opts: fixedModsOptions }],
    [["filter", "porta"], { p: 26, opts: portaOptions }],
    [["filter", "fm"], { p: 30, max: 63 }],
    [["amp", 0, "amt"], { p: 27, max: 63 }],
    [["porta", "rate"], { p: 44, max: 63 }],
    [["lag", "mode"], { p: 46, opts: ["Const Speed","Const Time","Exponent"] }],
    [["porta", "legato"], { p: 47, max: 1 }],
  ] },
  { prefix: 'lfo', count: 2, bx: 7, px: 10, block: 
    { inc: 1, b: 35, block: [
      ["speed", { p: 80, max: 63 }],
      ["trigger", { p: 86, opts: ["Off","Single","Multi","External"] }],
      ["lag", { p: 87, max: 1 }],
      ["wave", { p: 82, opts: ["Triangle","Saw Up","Saw Down","Square","Random","Noise","Sampled Modulation"] }],
      ["retrigger/pt", { p: 83, max: 63 }],
      ["sample/src", { p: 88, options: trkSrcOptions }],
      ["amp", { p: 84, max: 63 }],
    ] }
  },
  { prefix: 'env', count: 3, bx: 9, px: 10, block: 
    { inc: 1, b: 49, block: [
      ["trigger/mode", { p: 57, opts: ["Single","Single Reset","Multiple","Multi Reset","Ext Single","Ext Single Reset","Ext Multi","Ext Multi Reset"] }],
      ["delay", { p: 50, max: 63 }],
      ["attack", { p: 51, max: 63 }],
      ["decay", { p: 52, max: 63 }],
      ["sustain", { p: 53, max: 63 }],
      ["release", { p: 54, max: 63 }],
      ["amp", { p: 55, max: 63 }],
      ["lfo/trigger/mode", { p: 59, options: [
        [0, "Normal"],
        [2, "LFO 1"],
        [3, "Gated LFO 1"],
        ] }],
      ["mode", { p: 58, opts: ["Normal","DADR","Freerun","Both"] }],
    ] } 
  },
  [["trk", "src"], { b: 76, p: 33, options: trkSrcOptions }],
  { prefix: "trk/pt", count: 5, bx: 1, px: 1, block: [
    ["", { b: 77, p: 34, max: 63 }],
  ] },
  { inc: 1, b: 82, block: [
    ["ramp/0/rate", { p: 40, max: 63 }],
    [["ramp", 0, "mode"], { p: 41, opts: rampModeOptions }],
    [["ramp", 1, "rate"], { p: 42, max: 63 }],
    [["ramp", 1, "mode"], { p: 43, opts: rampModeOptions }],
    [["osc", 0, "freq", "lfo", 0, "amt"], { p: 1, rng: [-63, 64] }],
    [["osc", 0, "pw", "lfo", 1, "amt"], { p: 4, rng: [-63, 64] }],
    [["osc", 1, "freq", "lfo", 0, "amt"], { p: 11, rng: [-63, 64] }],
    [["osc", 1, "pw", "lfo", 1, "amt"], { p: 14, rng: [-63, 64] }],
    [["cutoff", "env", 0, "amt"], { p: 22, rng: [-63, 64] }],
    [["cutoff", "pressure", "amt"], { p: 23, rng: [-63, 64] }],
    [["amp", 0, "velo", "amt"], { p: 28, rng: [-63, 64] }],
    [["amp", 1, "env", 1, "amt"], { p: 29, rng: [-63, 64] }],
    [["env", 0, "velo"], { p: 56, rng: [-63, 64] }],
    [["env", 1, "velo"], { p: 66, rng: [-63, 64] }],
    [["env", 2, "velo"], { p: 76, rng: [-63, 64] }],
    [["lfo", 0, "ramp", 0, "amt"], { p: 85, rng: [-63, 64] }],
    [["lfo", 1, "ramp", 1, "amt"], { p: 95, rng: [-63, 64] }],
    [["porta", "rate", "velo", "amt"], { p: 45, rng: [-63, 64] }],
    [["filter", "fm", "env", 2, "amt"], { p: 31, rng: [-63, 64] }],
    [["filter", "fm", "pressure", "amt"], { p: 32, rng: [-63, 64] }],
    [["lfo", 0, "speed", "pressure", "amt"], { p: 81, rng: [-63, 64] }],
    [["lfo", 1, "speed", "key", "amt"], { p: 91, rng: [-63, 64] }],  
  ] },
  { prefix: 'mod', count: 10, bx: 3, px: 0, block: mod => [
    ["src", { b: 104, p: -(mod + 1), opts: modSourceOptions }],
    ["amt", { b: 105, p: -(mod + 1), rng: [-63, 64] }],
    ["dest", { b: 106, p: -(mod + 1), opts: modDestinationOptions }],
  ] },
]

const sysexDataWithLocation = location => sysexDataWithHeader([0x01, location])

// returns: array of instructions for processing body data and returning sysex data
const sysexDataWithHeader = header => [
  ['concat', ['nibblize', 'lsb'], ['checksum']],
  ['wrap', ([0xf0, 0x10, 0x06]).concat(header), [0xf7]],
]

const patchOut = location => [[sysexDataWithLocation(location), 100]]

const patchTruss = createPatchTruss(sysexDataWithLocation(0))

module.exports = {

  patchTruss: patchTruss,

  createPatchTruss: createPatchTruss,
  
  sysexDataWithLocation: sysexDataWithLocation,
  
  sysexDataWithHeader: sysexDataWithHeader,

  bankTruss: createBankTruss(patchTruss),
  
  createBankTruss: createBankTruss,
  
  patchTransform: {
    type: 'singlePatch',
    throttle: 200,
    editorVal: Matrix.tempPatch,
    param: (v, parm, value) => {
      if (!parm) { return null }

      if (parm.p < 0 || value < 0 || pathEq(parm.path, "env/0/sustain") || pathEq(parm.path, "amp/1/env/1/amt")) {
        // MATRIX MOD SEND or buggy params
        return patchOut(v)
      }
      else {
        // NORMAL PARAM SEND
        // quick edit doesn't save to the 6, so use a timer to do periodic saves
        return [
          [Matrix.sysex([0x05]), 10], // quick edit mode bytes
          [Matrix.sysex([0x06, parm.p, value]), 10],
        ]
      }
    }, 
    patch: (v) => patchOut(v), 
    name: (v, path, name) => patchOut(v),
  },

  parms: parms,
  
  bankTransform: {
    type: 'singleBank',
    throttle: 0,
    bank: (editorVal, location) => [(sysexDataWithLocation(location), 50)],
  },

}

// console.dir(module.exports, { depth: null })