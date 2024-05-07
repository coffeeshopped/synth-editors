require('/core/ArrayUtils.js')

const dx7Path = "../../dx7/"
const DX7VoicePatch = require(dx7Path + "patch/voice.js")
const ACEDPatch = require('aced.js')

// bodyData is { path: bytes }
function sysexData(bodyData, channel) {
  const aced = ACEDPatch.sysexData(bodyData["extra"], channel)
  const voice DX7VoicePatch.sysexData(bodyData["voice"], channel)
  // ACED, then VCED
  return aced.concat(voice)
}

function defaultMultiPatchBodyData(bytes, trussMap) {
  var subs = {}
  bytes.sysex().forEach(msg => {
    for (var i=0; i < trussMap.length; ++i) {
      const truss = trussMap[i][1]
      if (truss.isValidFileData(msg)) {
        subs[trussMap[i][0]] = truss.bytes(msgs)
        break
      }
    }
  })
  
  return subs

  // for any unfilled subpatches, init them
  // for (key, type) in subpatchTypes {
  //   guard subpatches[key] == nil else { continue }
  //   subpatches[key] = type.init()
  // }
  // return subpatches
}

function defaultMultiPatchFileDataCount(trussMap) {
  return trussMap.map(truss => truss.fileDataCount).sum()
}

const trussMap = [
  [["voice"], DX7VoicePatch],
  [["extra"], ACEDPatch],
]

const fileDataCount = defaultMultiPatchFileDataCount(trussMap)

module.exports = {
  trussType: "MultiPatch",
  localType: "Patch",
  initFileName: "tx802-voice-init",
  fileDataCount: fileDataCount,
  namePath: "voice",

  trussMap: trussMap,
  
  sysexData: sysexData,
  fileData: bodyData => sysexData(bodyData, 0),
  bodyData: fileData => defaultMultiPatchBodyData(fileData, trussMap),
  
  // 163: A DX7 (mkI) patch
  isValidSize: fileSize => fileSize == fileDataCount || fileSize == 163
  
  algorithms: require(dx7Path + "patch/algos.js"),

}

