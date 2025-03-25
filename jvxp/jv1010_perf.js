const JV1080Perf = require('./jv1080_perf.js')
const JV2080Perf = require('./jv2080_perf.js')

module.exports = {
  config: {
    voicePresets: JV2080Perf.voicePresetOptionMap, 
    rhythmPresets: JV2080Perf.rhythmPresetOptionMap, 
    blank: JV1080Perf.blankPatches, 
    patchGroups: JV2080Perf.patchGroups, 
    hasOutSelect: false,
  },
}
