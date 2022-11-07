const { inc, prefix, prefixes, reduce } = require('/core/ParamOptions.js')
require('/core/NumberUtils.js')
require('/core/ArrayUtils.js')

// enum DXLevelScalingCurve: Int {
//   case negativeLinear = 0
//   case negativeExponential = 1
//   case positiveExponential = 2
//   case positiveLinear = 3
// }

// channel should be 0-15
function sysexData(bytes, channel) {
  return ([0xf0, 0x043, channel, 0x00, 0x01, 0x1b]).concat(bytes).concat([checksum(bytes), 0xf7])
}

const curveOptions = ["- Lin","- Exp","+ Exp","+ Lin"]

const lfoWaveOptions = ["Triangle","Saw Down","Saw Up","Square","Sine","Sample/Hold"]


const dx7VoicePatch = {
  // bankType: DX7VoiceBank
  trussType: "SinglePatch",
  localType: "Patch",
  nameByteRange: [118, 128],
  
  bytes: (fileData) => fileData.safeBytes(6, 6 + 155),
    
  sysexData: sysexData,
  fileData: (bytes) => sysexData(bytes, 0),

  paramOptions: reduce(function*() {
    yield prefix(["op"], {count: 6, bx: -21}, offset({b: 85}, function*() {
      yield prefix(["rate"], {count: 4, bx: 1}, [[[], {b: 0}]])
      yield prefix(["level"], {count: 4, bx: 1}, [[[], {b: 4}]])
      yield prefix(["level", "scale"], {}, [
        [["brk", "pt"], {b: 8}],
        [["left", "depth"], {b: 9}],
        [["right", "depth"], {b: 10}],
        [["left", "curve"], {b: 11, bits: [0, 1]}],
        [["right", "curve"], {b: 11, bits: [2, 3]}],
      ])
      yield [
        [["rate", "scale"], {b: 12, bits: [0, 2]}],
        [["amp", "mod"], {b: 13, bits: [0, 1]}],
        [["velo"], {b: 13, bits: [2, 4]}],
        [["level"], {b: 14}],
        [["osc", "mode"], {b: 15, bit: 0}],
        [["coarse"], {b: 15, bits: [1, 6]}],
        [["fine"], {b: 16}],
        [["detune"], {b: 12, bits: [3, 6]}],
      ]
    }))
    
    yield prefix(["pitch", "env"], {}, function*() {
      yield prefix(["rate"], {count: 4, bx: 1}, [[[], {b: 102}]])
      yield prefix(["level"], {count: 4, bx: 1}, [[[], {b: 106}]])
    })
  
    yield [
      [["algo"], {b: 110}],
      [["feedback"], {b: 111, bits: [0, 2]}],
      [["osc", "sync"], {b: 111, bit: 3}],
    ]
    yield prefix(["lfo"], {}, [
      [["speed"], {b: 112}],
      [["delay"], {b: 113}],
      [["pitch", "mod", "depth"], {b: 114}],
      [["amp", "mod", "depth"], {b: 115}],
      [["sync"], {b: 116, bit: 0}],
      [["wave"], {b: 116, bits: [1, 3]}],
      [["pitch", "mod"], {b: 116, bits: [4, 6]}],    
    ])
    yield [
      [["transpose"], {b: 117}],
    ]
  }),


  parseBankData: function(bankData) {
    // // create empty bytes to pack into
    // bytes = [UInt8](repeating: 0, count: 155)
    // let b = [UInt8](bankData)
    // // unpack the name
    // name = type(of: self).name(forRange: type(of: self).bankNameByteRange, bytes: b)
    // type(of: self).bankParams.forEach {
    //   self[$0.key] = type(of: self).defaultUnpack(param: $0.value, forBytes: b)
    // }
  },
  
  bankSysexData: function(bodyData) {
    var b = (128).map(() => 0)
    
    // pack the name
    const nameByteRange = [118, 128]
    let n = nameSetFilter(name) as NSString
    let nameBytes = (0..<nameByteRange.count).map { $0 < n.length ? UInt8(n.character(at: $0)) : 32 }
    b.replaceSubrange(nameByteRange, with: nameBytes)
  
    // pack the params
    bankParams.forEach {
      let param = $0.value
      b[param.byte] = defaultPackedByte(value: self[$0.key] ?? 0, forParam: param, byte: b[param.byte])
    }
    
    return b
  },

}

module.exports = dx7VoicePatch 