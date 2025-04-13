const JV8X = require('./jv8x.js')
const GlobalController = require('./jv80_global_ctrlr.js')
const PerfController = require('./jv80_perf_ctrlr.js')

const editor = JV8X.editorTruss("JV-80", {
  global: {
    size: 0x21,
    extraParms: [],
    initFile: "jv880-global",
  },
  voice: {
    size: 0x73,
    extraParms: [],
  },
  perf: {
    size: 0x22,
    extraParms: [],
  },
  rhythm: {
    size: 0x33,
    extraParms: [],
  },
})

const moduleTruss = JV8X.moduleTruss(editor, "jv80", GlobalController, PerfController, true)
