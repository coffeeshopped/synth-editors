const JVXP = require('./jvxp.js')
const JVXPModule = require('./jvxp_module.js')

const JV1010Perf = require('./jv1010_perf.js')

// hard-coded deviceId
const editor = JVXP.editorTruss("XP-30", 16, {
  global: 'jv1010',
  perf: 'xp50',
  voice: 'jv2080',
})

module.exports = {
  module: JVXPModule.moduleTruss(editor, "xp30", { 
    perf: { 
      showXP: true, 
      show2080: false,
      config: JV1010Perf.config 
    }, 
    clkSrc: true,
    cat: true,
  }),
}
