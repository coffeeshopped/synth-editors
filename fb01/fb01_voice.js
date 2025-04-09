const FB01 = require('./fb01.js')

//  override func randomize() {
//    super.randomize()
//    let algoIndex = value("Algorithm")!
//    let algo = type(of: self).algorithms()[algoIndex]
//
//    for outputId in algo.outputOps {
//      let op = "Op\(outputId+1)"
//      // set output levels to between 100 and 127 (remember levels are inverted)
//      set(value: (0...27).random()!, forParameterKey: "\(op)Level")
//    }
//
//    set(value: 1, forParameterKey: "Op1On")
//    set(value: 1, forParameterKey: "Op2On")
//    set(value: 1, forParameterKey: "Op3On")
//    set(value: 1, forParameterKey: "Op4On")
//
//    set(value: 0, forParameterKey: "Transpose")
//    set(value: 0, forParameterKey: "Porta")
//
//    // for one out, make it harmonic and louder
//    let randomOut = algo.outputOps[(0...(algo.outputOps.count-1)).random()!] + 1
//    set(value: 1, forParameterKey: "Op\(randomOut)Coarse")
//    set(value: 0, forParameterKey: "Op\(randomOut)Fine")
//  }
  

const freqRatio = (coarse, fine) => {
  const c = coarse == 0 ? 0.5 : coarse
  const f = fine < 4 ? ([1, 1.41, 1.57, 1.73])[fine] : 1
  return c * f
}

const levelScaleTypePack = (byte) => ['splitter', [
  {
    byte: byte,
    byteBits: [7, 7],
    valueBits: [0, 0],
  },
  {
    byte: byte + 2,
    byteBits: [7, 7],
    valueBits: [1, 1],
  },
]]
  
const lfoWaveOptions = ["Saw Up","Square","Triangle","S/Hold"]
    
const ctrlOptions = ["None","Aftertouch","Mod Wheel","Breath Ctrl","Foot Ctrl"]

const parms = [
  ['lfo/speed', { b: 0x08, max: 255 }],
  ['lfo/load', { b: 0x09, bit: 7 }],
  ['amp/mod/depth', { b: 0x09, bits: [0, 6] }],
  ['lfo/sync', { b: 0x0a, bit: 7 }],
  ['pitch/mod/depth', { b: 0x0a, bits: [0, 6] }],
  (4).map(i =>
    [`op/${i}/on`, { b: 0x0b, bit: 6 - i }]
  ),
  ['feedback', { b: 0x0c, bits: [3, 5], max: 7 }],
  ['algo', { b: 0x0c, bits: [0, 2], rng: [0, 8], dispOff: 1 }],
  ['pitch/mod/sens', { b: 0x0d, bits: [4, 6], max: 7 }],
  ['amp/mod/sens', { b: 0x0d, bits: [0, 1], max: 3 }],
  ['lfo/wave', { b: 0x0e, bits: [5, 6], opts: lfoWaveOptions }],
  ['transpose', { b: 0x0f, rng: [-128, 127] }],
  ([3,2,1,0]).map((op, i) => {
    const offset = 0x10 + (i * 0x08)
    return { prefix: ['op', op], block: ({
      b: offset, offset: [
        ['level', { b: 0x00, max: 127 }],
        ['level/scale/type', { b: 0x01, packIso: levelScaleTypePack(offset + 1), opts: ["0","1","2","3"] }],
        ['velo', { b: 0x01, bits: [4, 6], max: 7 }],
        ['level/scale', { b: 0x02, bits: [4, 7], max: 15 }],
        ['level/adjust', { b: 0x02, bits: [0, 3], max: 15 }],
        ['detune', { b: 0x03, bits: [4, 6], rng: [-3, 3] }],
        ['coarse', { b: 0x03, bits: [0, 3], max: 15 }],
        ['rate/scale', { b: 0x04, bits: [6, 7], max: 3 }],
        ['attack', { b: 0x04, bits: [0, 4], max: 31 }],
        ['amp/mod', { b: 0x05, bit: 7 }],
        ['attack/velo', { b: 0x05, bits: [5, 6], max: 3 }],
        ['decay/0', { b: 0x05, bits: [0, 4], max: 31 }],
        ['fine', { b: 0x06, bits: [6, 7], max: 3 }],
        ['decay/1', { b: 0x06, bits: [0, 4], max: 31 }],
        ['decay/level', { b: 0x07, bits: [4, 7], max: 15 }],
        ['release', { b: 0x07, bits: [0, 3], max: 15 }],
      ]
    }) }
  }),
  ['poly', { b: 0x3a, bit: 7 }],
  ['porta', { b: 0x3a, bits: [0, 6] }],
  ['pitch/mod/depth/ctrl', { b: 0x3b, bits: [4, 6], opts: ctrlOptions }],
  ['bend', { b: 0x3b, bits: [0, 3], max: 12 }],
]

// last 2 bytes of hello are the value 128 (number of bytes in packet) broken into two bytes per docs
const sysexData = part => ['>',
  ['nibblizeLSB'], // turn body data into 4-bit nibbles
  ['yamCmd', [0x75, 'channel', 0x08 + part, 0, 0, 0x01, 0x00], 'b'],
]

const patchTruss = {
  type: 'singlePatch',
  id: "voice", 
  bodyDataCount: 64, 
  namePack: [0, 7], 
  parms: parms, 
  initFile: "fb01-init", 
  createFile: sysexData(0), 
  parseBody: ['>',
    ['bytes', { start: 9, count: 128 }],
    'denibblizeLSB',    
  ],
}

const paramData = (instrument, paramAddress) => 
  FB01.paramData(instrument, [
    0x40 + paramAddress,
    // grab data from the patch rather than a passed value,
    // because a byte can contain multiple param values.
    ['bits', [0, 3], ['byte', paramAddress]],
    ['bits', [4, 7], ['byte', paramAddress]],
  ])

  
const patchTransform = (instrument) => ({
  type: 'singlePatch',
  throttle: 30,
  param: (path, parm, value) =>
    [paramData(instrument, parm.b), 10]
  ,
  patch: sysexData(instrument),
  name: patchTruss.namePack.rangeMap(i => [
    paramData(instrument, i), 10
  ]),
})

// offset of 74 is from:
// 7 bytes in header
// 67: reserved packet. 2 bytes to describe size (64), 64 data bytes, 1 checksum byte

const bankTruss = (bank) => ({
  type: 'compactSingleBank',
  patchTruss: patchTruss,
  patchCount: 48, 
  fileDataCount: 6363,
  createFile: {
    wrapper: ['yamSyx', [0x75, 'channel', 0x00, 0x00, bank, 0x00, 0x40, 0x05, 0x07, 0x03, 0x07, 0x05, 0x06, 0x02, 0x07, 0x00, 0x02, 0x01, 0x03, 0x00, 0x02, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4C, 'b']],
    patchBodyTransform: ['>',
      'nibblizeLSB',
      [0x01, 0x00, 'b' ['yamChk', 'b']],
    ],
  } 
  parseBody: {
    offset: 74,
    patchByteCount: 131,
    patchBodyTransform: ['>',
      ['bytes', { start: 2, count: 128 }],
      'denibblizeLSB',
    ],  
  },
})

// 
// static func transform(bank: Int) -> MidiTransform {
//   .single(throttle: 30, sysexChannel, .wholeBank({ editorVal, bodyData in
//     [(.sysex(sysexData(bodyData, channel: editorVal, bank: bank)), 10)]
//   }))
// }

module.exports {
  lfoWaveOptions,
  ctrlOptions,
}