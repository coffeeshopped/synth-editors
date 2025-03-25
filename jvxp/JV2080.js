const JVXP = require('./jvxp.js')
const JVXPModule = require('./jvxp_module.js')

const Perf = require('./jv2080_perf.js')

const editor = JVXP.editorTruss("JV-2080", null, {
  global: 'jv2080',
  perf: 'jv2080',
  voice: 'jv2080',
})

module.exports = {
  module: JVXPModule.moduleTruss(editor, "jv2080", { 
    perf: { 
      showXP: false, 
      show2080: true,
      config: Perf.config 
    }, 
    clkSrc: true,
    cat: true,
  }),
}