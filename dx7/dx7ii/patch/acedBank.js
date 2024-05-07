const { prefix, reduce, offset } = require('/core/ParamOptions.js')
require('/core/ArrayUtils.js')

const { patchSysex } = require('/dx7/yamaha.js')


const sysexData = (compactByteArrays, channel) => patchSysex(compactByteArrays.flat(), channel, [0x06, 0x08, 0x60])

const compactByteCount = 35

module.exports = {
  trussType: "CompactSingleBank",
  localType: "PatchBank",
  PatchType: require('aced.js'),
  initFileName: "tx802-aced-bank-init",
  patchCount: 32,
  fileDataCount: 1128,
  compactByteCount: compactByteCount,
  
  sysexData: sysexData,
  fileData: compactByteArrays => sysexData(compactByteArrays, 0),

  compactByteArrays: fileData => fileData.slices(compactByteCount, 6),
  
  compactParamOptions: reduce(function*() {
    yield prefix(["op"], {}, [
      [[5, "scale", "mode"], {b: 0, bit: 0}],
      [[4, "scale", "mode"], {b: 0, bit: 1}],
      [[3, "scale", "mode"], {b: 0, bit: 2}],
      [[2, "scale", "mode"], {b: 0, bit: 3}],
      [[1, "scale", "mode"], {b: 0, bit: 4}],
      [[0, "scale", "mode"], {b: 0, bit: 5}],
      [[5, "amp", "mod"], {b: 1, bits: [0, 3]}],
      [[4, "amp", "mod"], {b: 1, bits: [3, 6]}],
      [[3, "amp", "mod"], {b: 2, bits: [0, 3]}],
      [[2, "amp", "mod"], {b: 2, bits: [3, 6]}],
      [[1, "amp", "mod"], {b: 3, bits: [0, 3]}],
      [[0, "amp", "mod"], {b: 3, bits: [3, 6]}],
    ])
    
    yield [
      [["pitch", "env", "range"], {b: 4 bits: [0, 2]}],
      [["lfo", "trigger", "mode"], {b: 4, bit: 2}],
      [["velo", "pitch", "sens"], {b: 4, bit: 3}],
      [["mono"], {b: 5, bits: [0, 2]}],
    ]
    yield prefix(["bend"], {}, [
      [["range"], { b: 5, bits: [2, 6] }], // This was wrong in the Yamaha docs.
      [["step"], { b: 6, bits: [0, 4] }],
      [["mode"], { b: 6, bits: [4, 6] }],  
    ])
    yield [
      [["random", "pitch"], {b: 4, bits: [4, 7]}],
    ]
    yield prefix(["porta"], {}, [
      [["mode"], {b:7, bit: 0 }],
      [["step"], {b: 7, bits: [1, 5] }],
      [["time"], {b: 8 }],
    ])
  
    yield inc({b: 9}, function*() {
      yield prefix(["modWheel"], {}, [
        [["pitch"], {}],
        [["amp"], {}],
        [["env", "bias"], {}],
      ])
      yield prefix(["foot"], {}, [
        [["pitch"], {}],
        [["amp"], {}],
        [["env", "bias"], {}],
        [["volume"], {}],
      ])
      yield prefix(["breath"], {}, [
        [["pitch"], {}],
        [["amp"], {}],
        [["env", "bias"], {}],
        [["pitch", "bias"], {}],
      ])
      yield prefix(["aftertouch"], {}, [
        [["pitch"], {}],
        [["amp"], {}],
        [["env", "bias"], {}],
        [["pitch", "bias"], {}],
      ])
      yield [
        [["pitch", "env", "rate", "scale"], {}],
      ]
    })
    
    yield inc({b: 26}, function*() {
      // Not used on TX-802, but on DX7ii/S
      yield prefix(["foot", 1], {}, [
        [["pitch"], {}],
        [["amp"], {}],
        [["env", "bias"], {}],
        [["volume"], {}],
      ])
      yield prefix(["midi", "ctrl"], {}, [
        [["pitch"], {}],
        [["amp"], {}],
        [["env", "bias"], {}],
        [["volume"], {}],
      ])
    })
    
    yield [
      [["unison", "detune"], {b: 34, bits: [0, 3] }],
      [["foot", "slider"], {b: 34, bit: 3 }],
    ]
  }),
}
