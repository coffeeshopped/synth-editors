require('/core/NumberUtils.js')

function MophoTypeBackup(GlobalPatch, VoiceBank) {
  return {
    trussType: "Backup",
    localType: "Backup",
    
    trussMap: [
      [["global"], GlobalPatch],
    ].concat((3).map(i => [["bank", i], VoiceBank])),
  
    path(fileData) {
      switch (fileData[3]) {
        case 0x0f: // global
          return ["global"]
        case 0x02: // bank
          return ["bank", fileData[4]]
        default:
          return null
      }
    },
  }
}

module.exports = MophoTypeBackup
