
const fx = {
  prefix: { index: "common/fx" }, 
  builders: [
    ['grid', [[
      [{select: "FX"}, "type"],
      ["Param 1", "param/0"],
      ["Param 2", "param/1"],
    ]]],
  ], 
  effects: [
    ['indexChange', i => ['setCtrlLabel', "type", `FX ${i + 1}`]],
    ['patchChange', "type", v => {
      var labels = []
      switch (v) {
      case 1:
        labels = ["Drive", "Tone"]
      case 2:
        labels = ["Sens", "Rez"]
      case 3, 4, 5:
        labels = ["Depth", "Rate"]
      case 6, 7:
        labels = ["Depth", "Time"]
      default:
        labels = ["", ""]
      }
      return [
        ['setCtrlLabel', "param/0", labels[0]],
        ['setCtrlLabel', "param/1", labels[1]],
        ['hideItem', v == 0, "param/0"],
        ['hideItem', v == 0, "param/1"],
      ]
    }],
  ],
}

const pitch = {
  let env: PatchController.PanelItem = .display(.rateLevelEnv(pointCount: 4, sustain: 2, bipolar: true), "Pitch", 4.map { .unit("rate/$0") } + 4.map { .src("level/$0", { ($0 - 64) / 48 })}, id: "env")
  prefix: { fixed: "common/pitch/env" }, 
  builders: [
    ['grid', [[
      env,
    ],[
      ["R1", "rate/0"],
      ["R2", "rate/1"],
      ["R3", "rate/2"],
      ["R4", "rate/3"],
    ],[
      ["L1", "level/0"],
      ["L2", "level/1"],
      ["L3", "level/2"],
      ["L4", "level/3"],
    ]]]
  ],
}

const op = {
  prefix: {index : "op" }, 
  color: 1, 
  border: 1, 
  builders: [
    ['panel', 'on', { }, [[
      [{checkbox: "On"}, "on"],
      [{switsch: "Freq Mode"}, "freq/mode"],
      ["Coarse", "coarse"],
      ["Fine", "fine"],
    ],[
      ["Level", "level"],
      ["Velocity", "velo"],
      ["Feedback", nil, id: "feedback"],
      ["Detune", "detune"],
    ]]],
    ['panel', 'env', { }, [[
      ["R1", "rate/0"],
      ["R2", "rate/1"],
      ["R3", "rate/2"],
      ["R4", "rate/3"],
    ],[
      ["L1", "level/0"],
      ["L2", "level/1"],
      ["L3", "level/2"],
      ["L4", "level/3"],
      ]]],
    ['panel', 'crv', { }, [[
      ["LS Left", nil, id: "level/scale/left/depth"],
      ["LS Right", nil, id: "level/scale/right/depth"],
      ["Rate Scale", "rate/scale"],
      ["LFO Amp", "lfo/amp/mod"],
    ],[
      "Crv Left", nil, id: "level/scale/left/curve",
      "Crv Right", nil, id: "level/scale/right/curve",
      [{checkbox: "LFO Pitch"}, "lfo/pitch/mod"],
      [{checkbox: "Pitch EG"}, "pitch/env"],
    ]]],
  ], 
  effects: [
    ['setup', [
      ['configCtrl', "feedback", { iso: Op.feedbackIso, rng: [-127, 127] }],
    ]],
    ['indexChange', i => [
      ['setCtrlLabel', "on", `${i + 1}`],
      ['setCtrlLabel', "env", `${i + 1}`],
    ]],
    ['patchChange', {
      paths: ["coarse", "fine"], 
      fn: values => {
        const coarse = values["coarse"]
        const fine = values["fine"]
        return [
          ['configCtrl', "freq/mode", { opts: [
            freqRatio(false, coarse, fine),
            freqRatio(true, coarse, fine),
          ] }],
        ]
      },
    }],
    ['patchChange', {
      paths: ["feedback/type", "feedback/level"], 
      fn: values => {
        const type = values["feedback/type"]
        const level = values["feedback/level"]
        return [['setValue', "feedback", (type * 2 - 1) * level]]
      }
    }],
    ['controlChange', "feedback", (state, locals) => {
      const feedback = locals["feedback"]
      const type = feedback < 0 ? 0 : 1
      const level = abs(feedback)
      return ['paramsChange', [
        ["feedback/type", type],
        ["feedback/level", level],
      ]]
    }],
    ['patchChange', "freq/mode", v =>
      [['setCtrlLabel', "freq/mode", v == 0 ? "Ratio" : "Fixed (Hz)"]]
    ],
    ['editMenu', "env", paths: 4.map { "rate/$0" } + 4.map { "level/$0" }, type: "RefaceDXEnvelope", init: nil, rand: nil],
    ['dimsOn', "on", id: nil],
  ] + levelScaleEffects(side: .left) + levelScaleEffects(side: .right), 
  layout: [
    .grid([
      (row: [("on", 1)], height: 2),
      (row: [("env", 1)], height: 2),
      (row: [("crv", 1)], height: 2),
    ])
  ])
}

const levelScaleEffects = (side) => {
  let depthId: SynthPath = `level/scale/${side}/depth`
  let curveId: SynthPath = `level/scale/${side}/curve`
  let ccFn: PatchController.ControlChangeFn = { state, locals in
    let depthVal = locals[depthId] ?? 0
    let curveVal = locals[curveId] ?? 0
    let curve: Int
    if depthVal < 0 {
      curve = curveVal == 0 ? 0 : 1
    }
    else {
      curve = curveVal == 0 ? 3 : 2
    }
    return `paramsChange([
      depthId : abs(depthVal)/${curveId : curve}/${}`)]
  }
  
  return [
    .setup([
      ['configCtrl', depthId, .span(.rng(-127...127))],
      ['configCtrl', curveId, .span(.opts(["Lin", "Exp"]))],
    ]),
    ['controlChange', depthId, fn: ccFn],
    ['controlChange', curveId, fn: ccFn],
    .patchChange(paths: [depthId, curveId], { values in
      guard let depth = values[depthId],
            let curve = values[curveId] else { return [] }
      let mult = curve < 2 ? -1 : 1
      return [['setValue', depthId, mult * depth]]
    }),
    .patchChange(curveId, {
      [['setValue', curveId, $0 == 0 || $0 == 3 ? 0 : 1]]
    }),
  ]
  
}


static let env: PatchController.PanelItem = {
  let env: PatchController.Display = .rateLevelEnv(pointCount: 4, sustain: 2, bipolar: false)
  return .display(env, "", 4.flatMap { [
    .unit("rate/$0"),
    .unit("level/$0"),
  ] } + "unit([.level", dest: "gain")], id: "env")
}()

const miniOp = {
  let paths = [SynthPath](Op.parms.params().keys)

  return .patch(prefix: .index("op"), [
    .items(color: 1, [
      (env, "env"),
      (.label("?", align: .leading, size: 11, id: "op"), "op"),
      (.label("x", align: .trailing, size: 11, bold: false, id: "osc/mode"), "freq"),
    ])
  ], effects: [
    .patchChange(paths: ["coarse", "fine", "detune", "freq/mode"], { values in
      guard let coarse = values["coarse"],
            let fine = values["fine"],
            let detune = values["detune"] else { return [] }
      let fixedMode = values["freq/mode"] == 1
      let valText = freqRatio(fixedMode: fixedMode, coarse: coarse, fine: fine)
      let detuneOff = detune - 64
      let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")
      
      return [
        ['setCtrlLabel', "osc/mode", fixedMode ? "\(valText) Hz" : "x \(valText)\(detuneString)"]
      ]
    }),
    .indexChange({ [['setCtrlLabel', "op", "\($0 + 1)")] }],
    ['dimsOn', "on", id: nil],
    ['editMenu', "env", paths: paths, type: "RefaceDXOp", init: nil, rand: nil]
  ], layout: [
    ['row', [["op",1],["freq",4]]],
    ['row', [["env", 1]]],
    .colFixed(["op", "env"], fixed: "op", height: 11, spacing: 2),
  ])
}

const Algorithms = require('./reface-dx-algos.json')

const algo = ['fm', Algorithms, miniOp, { algo: "common/algo" }]

const ctrlr = {  
  builders: [
    ['child', algo, "algo", { color: 1, clearBG: true }],
    ['children', 4, "op", op],
    ['children', 2, "fx", fx, {color: 2}],
    ['child', pitch, "pitch", {color: 2}],
    ['panel', 'algoKnob', { color: 2 }, [[
      ["Algorithm", "common/algo"],
      [{switsch: "Mono"}, "common/mono"],
      ["Transpose", "common/transpose"],
      ["P Bend", "common/bend"],
      ["Porta", "common/porta"],
    ]]],
    ['panel', 'lfo', { color: 2 }, [[
      [{select: "LFO Wave"}, "common/lfo/wave"],
      ["Speed", "common/lfo/speed"],
    ],[
      ["Delay", "common/lfo/delay"],
      ["Pitch Depth", "common/lfo/pitch/mod"],
    ]]],
  ],
  layout: [
    ['row', [["algo",6], ["algoKnob",6], ["pitch", 4],], { opts: ['alignAllTop'] }],
    ['rowPart', [["lfo", 2.5], ["fx0", 3.5]], { opts: ['alignAllTop'] }],
    ['row', [["op0",1],["op1",1],["op2",1],["op3",1]]],
    ['col', [["algo",3],["op0",6]]],
    ['colPart', [["fx0", 1], ["fx1", 1]], { opts: ['alignAllLeading', 'alignAllTrailing'] }],
    ['colPart', [["algoKnob", 1], ["lfo", 2]]],
    ['eq', ["algoKnob", "fx0", "fx1"], 'trailing'],
    ['eq', ["algo", "lfo", "fx1", "pitch"], 'bottom'],
  ],
}