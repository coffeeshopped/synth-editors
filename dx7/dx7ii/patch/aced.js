require('/core/ArrayUtils.js')
const { inc, prefix, reduce, fromOpts } = require('/core/ParamOptions.js')
const { patchSysex } = require('/dx7/yamaha.js')

const sysexData = (bytes, channel) => patchSysex(bytes, channel, [0x05, 0x00, 0x31])

const pitchEnvRangeOptions = ["8 oct", "2 oct", "1 oct", "1/2 oct"]

const paramOptions = reduce(function*() {
  yield prefix(["op"], {count: 6, bx: -1}, [
    [["scale", "mode"], { b: 5, opts: ["Normal","Frac"]}],
    [["amp", "mod"], { b: 11, max: 7}],
  ])
  
  yield inc({b: 12}, function*() {
    yield [
      [["pitch", "env", "range"], {opts: pitchEnvRangeOptions}],
      [["lfo", "trigger", "mode"], {opts: ["Single","Multi"]}],
      [["velo", "pitch", "sens"], {max: 1}],
      [["mono"], {opts: ["Poly","Mono", "Uni Poly", "Uni Mono"]}], // on TX-802 is just ["Poly","Mono"]
    ]
    yield prefix(["bend"], {}, [
      [["range"], { max: 12 }],
      [["step"], { max: 12 }],
      [["mode"], { max: 2 }],  
    ])
    yield [
      [["random", "pitch"], { max: 7 }],
    ]
    yield prefix(["porta"], {}, [
      [["mode"], { opts: ["Retain","Follow"] }],
      [["step"], { max: 12 }],
      [["time"], { max: 99 }],
    ])
    yield prefix(["modWheel"], {}, [
      [["pitch"], { max: 99 }],
      [["amp"], { max: 99 }],
      [["env", "bias"], { max: 99 }],
    ])
    yield prefix(["foot"], {}, [
      [["pitch"], { max: 99 }],
      [["amp"], { max: 99 }],
      [["env", "bias"], { max: 99 }],
      [["volume"], { max: 99 }],
    ])
    yield prefix(["breath"], {}, [
      [["pitch"], { max: 99 }],
      [["amp"], { max: 99 }],
      [["env", "bias"], { max: 99 }],
      [["pitch", "bias"], { max: 100 }],
    ])
    yield prefix(["aftertouch"], {}, [
      [["pitch"], { max: 99 }],
      [["amp"], { max: 99 }],
      [["env", "bias"], { max: 99 }],
      [["pitch", "bias"], { max: 100 }],
    ])
    yield [
      [["pitch", "env", "rate", "scale"], { max: 7 }],
    ]
    // Not used on TX-802, but on DX7ii/S
    yield prefix(["foot", 1], {}, [
      [["pitch"], { p: 64, max: 99 }],
      [["amp"], { p: 65, max: 99 }],
      [["env", "bias"], { p: 66, max: 99 }],
      [["volume"], { p: 67, max: 99 }],
    ])
    yield prefix(["midi", "ctrl"], {}, [
      [["pitch"], { p: 68, max: 99 }],
      [["amp"], { p: 69, max: 99 }],
      [["env", "bias"], { p: 70, max: 99 }],
      [["volume"], { p: 71, max: 99 }],
    ])
    // TODO: DX7s manual gave me the parm (72) here. I think I guessed on the byte # (47, originally).
    //   The DX200 lists unison detune as byte 48 though. So that might be right.
    //   So I swapped byte # for these next 2. Need to test with hardware...
    yield [
      [["unison", "detune"], { p: 72, max: 7 }],
      [["foot", "slider"], { p: 73, max: 1 }],
    ]

  })
})
  
module.exports = {
  trussType: "SinglePatch",
  localType: "ACED",
  fileDataCount: 57,
  initFileName: "tx802-aced-init",
  
  bytes: (fileData) => fileData.safeBytes([6, 6 + 49]),
  
  sysexData: sysexData,
  fileData: (bytes) => sysexData(bytes, 0),

  paramOptions: paramOptions,
  
  params: (function() {
    let p = {}
    for (let i=0; i<paramOptions.length; ++i) {
      let path = paramOptions[i][0].join('/')
      let obj = paramOptions[i][1]
      p[path] = obj
    }
    return p
  })()

}
