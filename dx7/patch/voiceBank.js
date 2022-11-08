const { prefix, reduce, offset } = require('/core/ParamOptions.js')
require('/core/ArrayUtils.js')
const DX7VoicePatch = require('./voice.js')

function checksum(bytes) {
  return (-1 * bytes.sum()) & 0x7f
}

function sysexData(channel, compactByteArrays) {
  const patchData = compactByteArrays.flat()
  return ([0xf0, 0x43, channel, 0x09, 0x20, 0x00]).concat(patchData).concat([checksum(patchData), 0xf7])
}

const compactByteCount = 128
const DX7VoiceBank = {
  trussType: "CompactSingleBank",
  localType: "PatchBank",
  PatchType: DX7VoicePatch,
  initFileName: "dx7-voice-bank-init",
  patchCount: 32,
  fileDataCount: 4104,
  compactByteCount: compactByteCount,
  
  sysexData: sysexData,
  fileData: compactByteArrays => sysexData(0, compactByteArrays),

  compactByteArrays: fileData => fileData.slices(compactByteCount, 6),
  
  compactNameByteRange: [118, 128],

  compactParamOptions: reduce(function*() {
    yield prefix(["op"], {count: 6, bx: -17}, offset({b: 85}, function*() {
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

}

module.exports = DX7VoiceBank
