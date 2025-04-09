const Algorithms = require('./algorithms.js')

// copied from TX81z

const envPathFn = values => {
  // must set default values as not all values may be present.
  const shft = values['shift'] || 0
  const a = values['attack'] || 0
  const d1 = values['decay/0'] || 0
  const d2 = values['decay/1'] || 0
  const s = values['decay/level'] || 0
  const r = values['release'] || 0
  const level = values['level'] || 0
  
  var cmds = []

  const segWidth = 0.2
  const shftHeight = shft // TODO: make it log not lin
  var x = 0
  
  // move to 0 , shftHeight
  cmds.push(
    ['move', x, 0],
    ['line', x, shftHeight]
  )
  
  // ar
  x += a == 1 ? 0 : 1 / Math.tan((0.25 + 0.25 * a) * Math.PI)
  cmds.push(['line', x, 1])
  
  // d1r
  x += d1 == 1 ? 0 : 1 / Math.tan((0.25 + 0.25 * d1) * Math.PI)
  cmds.push(['line', x, shftHeight + s])
  
  // d2r
  x += (1 - d2) * segWidth
  const y = shftHeight + (d2 == 0 ? 1 : 0.5) * s
  cmds.push(['line', x, y])
  
  // sustain
  x += (1 - r) * segWidth
  cmds.push(
    ['line', x, shftHeight],
    ['line', 1, shftHeight],
    ['line', 1, 0],
    ['scale', 1, level]
  )
  
  return cmds
}

const envItem = {
  env: envPathFn,
  l: "",
  map: [
    ['u', "attack", 31],
    ['u', "decay/0", 31],
    ['u', "decay/1", 31],
    ['src', "decay/level", v => (15 - v) / 15],
    ['u', "release", 15],
    ['src', "level", v => (127 - v) / 127],
  ],
  id: 'env',
}

const miniOpController = {

  let paths: [SynthPath] = parms.paths.compactMap {
    guard $0.starts(with: "op/0") else { return nil }
    return $0.subpath(from: 2)
  }

  return .patch(prefix: .index("op"), [
    .items(color: 1, [
      (envItem(), "env"),
      (.label("?", align: .leading, size: 11, id: "op"), "op"),
      (.label("x", align: .trailing, size: 11, bold: false, id: "osc/mode"), "freq"),
    ])
  ], effects: [
    .patchChange(paths: ["coarse", "fine"], { values in
      guard let coarse = values["coarse"],
            let fine = values["fine"] else { return [] }
      return [
        ['setCtrlLabel', "osc/mode", String(format: "%2.2f", freqRatio(coarse: coarse, fine: fine))],
      ]
    }),
    ['dimsOn', "on", id: nil],
    ['editMenu', "env", paths: paths, type: "FB01Op", init: nil, rand: nil],
    .indexChange({ [['setCtrlLabel', "op", "\(4 - $0)")] }],
  ], layout: [
    ['row', [["op",1],["freq",4]]],
    ['row', [["env",1]]],
    .colFixed(["op", "env"], fixed: "op", height: 11, spacing: 2),
  ])
}



const opController = {
  return .patch(prefix: .index("op"), [
    .grid(color: 1, [[
      "Ratio", nil, id: "ratio",
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Detune", "detune"],
    ],[
      ["Level", nil, id: "level"],
      ["Velocity", "velo"],
      [{checkbox: "Amp Mod"}, "amp/mod"],
      ["L Adjust", "level/adjust"],
    ],[
      ["Velo(A]", "attack/velo"),
      envItem(),
      [{checkbox: "On"}, "on"],
    ],[
      ["Attack", "attack"],
      ["Decay 1", "decay/0"],
      ["Sustain", nil, id: "decay/level"],
      ["Release", "release"],
    ],[
      ["L Scale", "level/scale"],
      [{switsch: "LS Type"}, "level/scale/type"],
      ["Decay 2", "decay/1"],
      ["R Scale", "rate/scale"],
    ]]]
  ], effects: [
    ['dimsOn', "on", id: nil],
    .indexChange({ [['setCtrlLabel', "env", "\(4 - $0)")] }],
    .patchChange(paths: ["coarse","fine"], { values in
      guard let coarse = values["coarse"],
        let fine = values["fine"] else { return [] }
      return [
        .configCtrl("ratio", .opts(ParamOptions(optArray: [
          String(format: "%2.2f", freqRatio(coarse: coarse, fine: fine)),
        ]))),
      ]
    }),
    .editMenu("env", paths: [
      "attack",
      "decay/0",
      "decay/1",
      "decay/level",
      "release",
    ], type: "FB01Envelope", init: nil, rand: nil),
  ]
                + .ctrlBlocks("level", value: { 127 - $0 }, cc: { 127 - $0 })
                + .ctrlBlocks("decay/level", value: { 15 - $0 }, cc: { 15 - $0 }))
}

const algo = ['fm', Algorithms.algorithms, miniOpController, { algo: 'algo' }]

module.exports = {
  builders: [
    ['child', algo, "algo", {color: 2, clearBG: true}],
    ['children', 4, "op", color: 1, Op.controller, indexFn: { p, offset in 3 - offset }],
    ['panel', 'algoKnob', { color: 2, }, [[
      ["Algorithm", "algo"],
    ],[
      ["Feedback", "feedback"],
      [{checkbox: "Mono"}, "poly"],
    ]]],
    .panel("transpose", color: 2, [
      `knob("Transpose"/${[.transpose}`)],
      `knob("P Bend"/${[.bend}`)],
      `knob("Porta Time"/${[.porta}`)],
    ]),
    ['panel', 'lfo', { color: 2, }, [[
      [{checkbox: "LFO Load"}, "lfo/load"],
      [{select: "LFO Wave"}, "lfo/wave"],
      ["Speed", "lfo/speed"],
    ],[
      [{checkbox: "Key Sync"}, "lfo/sync"],
      ["Pitch Depth", "pitch/mod/depth"],
      ["Pitch Sens", "pitch/mod/sens"],
    ],[
      [{select: "PMD Ctrl"}, "pitch/mod/depth/ctrl"],
      ["Amp Depth", "amp/mod/depth"],
      ["Amp Sens", "amp/mod/sens"],
    ]]],
  ], effects: [
  ], layout: [
    ['row', [["algo",5],["algoKnob",2],["transpose",1],["lfo",4]]],
    ['row', [["op0",1], ["op1",1], ["op2",1], ["op3",1]]],
    ['col', [["algo",3],["op0",5]]],
  ]
}
