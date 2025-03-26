const JVXP = require('./jvxp.js')
const JVXPModule = require('./jvxp_module.js')
const Perf = require('./jv1010_perf.js')

// hard-coded deviceId
const editor = JVXP.editorTruss("JV-1010", 16, {
  global: 'jv1010',
  perf: 'xp50',
  voice: 'jv2080',
})

module.exports = {
  module: JVXPModule.moduleTruss(editor, "jv1010", { 
    perf: { 
      showXP: false, 
      show2080: false, 
      config: Perf.config 
    }, 
    clkSrc: true, 
    cat: true,
  }),
}
