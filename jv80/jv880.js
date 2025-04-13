const JV8X = require('./jv8x.js')
const GlobalController = require('./jv880_global_ctrlr.js')
const PerfController = require('./jv880_perf_ctrlr.js')

const editor = JV8X.editorTruss("JV-880", {
  global: {
    size: 0x110,
    extraParms: [
      ['out/mode', { b: 0x21, opts: ["Out2","Out4"] }],
      ['rhythm/edit/key', { b: 0x22, opts: ["MIDI & Int", "Int"] }],
      ['scale/tune', { b: 0x23, max: 1 }],
      { prefix: "scale/tune", count: 8, bx: 12, block: {
        prefix: "note", count: 8, bx: 1, block: [
          ["", { b: 0x24, dispOff: -64 }],
        ]
      } },
      { prefix: "scale/tune/patch/note", count: 12, bx: 1, block: [
        ["", { b: 0x0104, .dispOff: -64 }]
      ] },
    ],
    initFile: "jv880-global",
  },
  voice: {
    size: 0x74,
    extraParms: [
      ['out/assign', { b: 0x73, opts: ["Mix","Sub"] }],
    ],
  },
  perf: {
    size: 0x23,
    extraParms: [
      ['out/assign', { b: 0x22, opts: ["Main", "Sub", "Patch"] }],
    ],
  },
  rhythm: {
    size: 0x34,
    extraParms: [
      ['out/assign', { b: 0x33, opts: ["Main","Sub"] }],
    ],
  },
})

const moduleTruss = JV8X.moduleTruss(editor, "jv880", GlobalController, PerfController, false)
