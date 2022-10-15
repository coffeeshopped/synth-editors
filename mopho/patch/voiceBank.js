require('/core/ArrayUtils.js')
const MophoVoicePatch = require('voicePatch.js')
const patchCount = 128

function MophoTypeVoiceBank(patchType) {
  return {
    trussType: "SingleBank",
    localType: "PatchBank",
    
    fileDataCount: patchCount * (patchType.fileDataCount + 2),
    PatchType: patchType,
    patchCount: patchCount,

    byteArrays(fileData) {
      return Sysex.singleSortedByteArrays(fileData, patchCount, (bytes) => bytes[5]).map((msg) => patchType.bytes(msg))
    },
    
    fileData(byteArrays) {
      return byteArrays.mapWithIndex((bytes, i) => patchType.sysexWriteData(bytes, 0, i)).flat()
    },

  }
}

const MophoVoiceBank = Object.assign(MophoTypeVoiceBank(MophoVoicePatch), {
  initFileName: "mopho-bank-init"
})

module.exports = MophoVoiceBank
