const JVXP = require('./jvxp.js')
const JVXPModule = require('./jvxp_module.js')

const JV1080Perf = require('./jv1080_perf.js')

const editor = JVXP.editorTruss("XP-50", null, {
  global: 'xp50',
  perf: 'xp50',
  voice: 'xp50',
})

module.exports = {
  module: JVXPModule.moduleTruss(editor, "xp50", { 
    perf: { 
      showXP: true,
      show2080: false, 
      config: JV1080Perf.config, 
    }, 
    clkSrc: true, 
    cat: false,
  }),
}
