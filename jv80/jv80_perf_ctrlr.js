const JV880PerfCtrlr = require('./jv880_perf_ctrlr.js')

const label = i => i == 7 ? "Rhythm" : `${i+1}`

const transmit = ['index', "part", "on", label, {
  color: 1
  builders: [
    ['grid', {prefix: "send"}, [[
      [{checkbox: "On"}, "on"],
      ["Channel", "channel"],
    ], [
      ["Pgm Ch", "pgmChange"],
      ["Volume", "volume"],
    ], [
      ["Pan", "pan"],
    ], [
      ["Key Lo", "key/range/lo"],
      ["Key Hi", "key/range/hi"],
    ], [
      ["Key Transpose", "key/transpose"],
    ], [
      ["Velo Sens", "velo/sens"],
      ["Velo Hi", "velo/hi"],
    ], [
      ["Velo Curve", "velo/curve"],
    ]]]
  ],
}]

const internl = ['index', "part", "on", label, {
  color: 1,
  builders: [
    ['grid', {prefix: "int"}, [[
      [{checkbox: "On"}, "on"],
    ], [
      ["Key Lo", "key/range/lo"],
      ["Key Hi", "key/range/hi"],
    ], [
      ["Key Transpose", "key/transpose"],
    ], [
      ["Velo Sens", "velo/sens"],
      ["Velo Hi", "velo/hi"],
    ], [
      ["Velo Curve", "velo/curve"],
    ]]]
  ],
}]

const ctrlr = {
  builders: [
    ['switcher', ["Common","Parts", "Transmit", "Internal"], {color: 1}],
    ['panel', 'space', { }, [[]]],
  ], 
  layout: [
    ['row', [["switch",10], ["space", 10]]],
    ['row', [["page",1]]],
    ['col', [["switch",1], ["page",8]]],
  ], 
  pages: ['controllers', [
    JV880PerfCtrlr.common,
    JV880PerfCtrlr.parts(true),
    ['oneRow', 8, transmit],
    ['oneRow', 8, internl],
  ]],
}