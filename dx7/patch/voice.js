const { inc, prefix, reduce } = require('/core/ParamOptions.js')
require('/core/NumberUtils.js')
require('/core/ArrayUtils.js')

function checksum(bytes) {
  return (-1 * bytes.sum()) & 0x7f
}


// channel should be 0-15
function sysexData(bytes, channel) {
  return ([0xf0, 0x043, channel, 0x00, 0x01, 0x1b]).concat(bytes).concat([checksum(bytes), 0xf7])
}

const curveOptions = ["- Lin","- Exp","+ Exp","+ Lin"]

const lfoWaveOptions = ["Triangle","Saw Down","Saw Up","Square","Sine","Sample/Hold"]

const paramOptions = reduce(function*() {
  yield prefix(["op"], {count: 6, bx: -21}, inc({b: 105}, function*() {
    yield prefix(["rate"], {count: 4}, [[[], {max: 99}]])
    yield prefix(["level"], {count: 4}, [[[], {max: 99}]])
    yield prefix(["level", "scale"], {}, [
      [["brk", "pt"], {max: 88, isoS: Jiso.noteName("A-1")}],
      [["left", "depth"], {max: 99}],
      [["right", "depth"], {max: 99}],
      [["left", "curve"], {opts: curveOptions}],
      [["right", "curve"], {opts: curveOptions}],
    ])
    yield [
      [["rate", "scale"], {max: 7}],
      [["amp", "mod"], {max: 3}],
      [["velo"], {max: 7}],
      [["level"], {max: 99}],
      [["osc", "mode"], {max: 1}],
      [["coarse"], {max: 31}],
      [["fine"], {max: 99}],
      [["detune"], {max: 14, dispOff: -7}],
    ]
  }))
  
  yield prefix(["pitch", "env"], {}, function*() {
    yield prefix(["rate"], {count: 4, bx: 1}, [[[], {b: 126, max: 99}]])
    yield prefix(["level"], {count: 4, bx: 1}, [[[], {b: 130, max: 99}]])
  })

  yield inc({b: 134}, function*() {
    yield [
      [["algo"], {max: 31, dispOff: 1}],
      [["feedback"], {max: 7}],
      [["osc", "sync"], {max: 1}],
    ]
    yield prefix(["lfo"], {}, [
      [["speed"], {max: 99}],
      [["delay"], {max: 99}],
      [["pitch", "mod", "depth"], {max: 99}],
      [["amp", "mod", "depth"], {max: 99}],
      [["sync"], {max: 1}],
      [["wave"], {opts: lfoWaveOptions}],
      [["pitch", "mod"], {max: 7}],    
    ])
    yield [
      [["transpose"], {max: 48, isoS: Jiso.noteName("C1")}],
    ]
  })
})

const dx7VoicePatch = {
  // bankType: DX7VoiceBank
  trussType: "SinglePatch",
  localType: "Patch",
  fileDataCount: 163,
  initFileName: "dx7-voice-init",
  nameByteRange: [145, 155],
  
  bytes: (fileData) => fileData.safeBytes([6, 6 + 155]),
    
  sysexData: sysexData,
  fileData: (bytes) => sysexData(bytes, 0),

  algorithms: require("./algos.js"),

  freqRatio: function(fixedMode, coarse, fine) {
    if (fixedMode) {
      let freq = Math.pow(10, coarse % 4) * Math.exp(Math.log(10) * (fine / 100))
      return freq.toPrecision(4)
    }
    else {
      // ratio mode
      let c = coarse == 0 ? 0.5 : coarse
      let f = (fine * c) / 100
      return (c + f).toFixed(2)
    }
  },

  // open func randomize() {
  //   randomizeAllParams()
  // 
  //   self[[.partial, .i(0), .mute]] = 1
  // 
  //   // find the output ops and set level 4 to 0
  //   let algos = DXAlgorithm.algorithms()
  //   let algoIndex = self[[.algo]] ?? 0
  // 
  //   let algo = algos[algoIndex]
  // 
  //   for outputId in algo.outputOps {
  //     let op: SynthPath = [.op, .i(outputId)]
  //     self[op + [.level, .i(0)]] = 90+(0...9).random()!
  //     self[op + [.rate, .i(0)]] = 80+(0...19).random()!
  //     self[op + [.level, .i(2)]] = 80+(0...19).random()!
  //     self[op + [.level, .i(3)]] = 0
  //     self[op + [.rate, .i(3)]] = 30+(0...69).random()!
  //     self[op + [.level]] = 90+(0...9).random()!
  //     self[op + [.level, .scale, .left, .depth]] = (0...9).random()!
  //     self[op + [.level, .scale, .right, .depth]] = (0...9).random()!
  //   }
  // 
  //   // for one out, make it harmonic and louder
  //   let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
  //   let op: SynthPath = [.op, .i(randomOut)]
  //   self[op + [.osc, .mode]] = 0
  //   self[op + [.fine]] = 0
  //   self[op + [.coarse]] = 1
  // 
  //   // flat pitch env
  //   for i in 0..<4 {
  //     self[[.pitch, .env, .level, .i(i)]] = 50
  //   }
  // 
  //   // all ops on
  //   for op in 0..<6 { self[[.op, .i(op), .on]] = 1 }
  // }

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

module.exports = dx7VoicePatch 