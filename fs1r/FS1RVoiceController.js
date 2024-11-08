

const opPaths = patchTruss.params.keys.compactMap {
    guard $0.starts(with: "op/0") else { return nil }
    return $0.subpath(from: 2)
  }

const opEnv = prefix => ({
  display: 'timeLevelEnv',
  pointCount: 5, 
  sustain: 3,
  maps: ([
    ['u', "level", "gain", 99],
    ['u', "hold", "time/0", 99],
    ['u', "time/3", "time/4", 99],
    ['u', "level/3", "level/4", 99],
    ['u', "level/3", "level/0", 99],
  ]).concat((3).flatMap(i => [
    ['u', ["time", i], ["time", i + 1], 99],
    ['u', ["level", i], ["level", i + 1], 99],
  ])),
  srcPrefix: [prefix, "amp/env"],
  id: [prefix, "amp/env"],
})
  
const miniOpController = ['index', "op", "op", i => `${i + 1}`, {
  builders: [
    ['items', {}, [
      [opEnv("voiced"), "env"],
      [opEnv("unvoiced"), "nenv"],
      [{ l: "?", align: 'leading', size: 11, id: "op"}, "op"],
      [{ l: "x", align: 'trailing', size: 11, bold: false, id: "osc/mode"}, "freq"],
    ]]
  ],
  effects: [
    ['patchChange', {
      paths: ["voiced/osc/mode", "voiced/spectral/form", "voiced/coarse", "voiced/fine", "voiced/detune"], 
      fn: values => {
        const oscMode = values["voiced/osc/mode"] || 0
        const specForm = values["voiced/spectral/form"] || 0
        const coarse = values["voiced/coarse"] || 0
        const fine = values["voiced/fine"] || 0
        const detune = values["voiced/detune"] || 0
        const ratioMode = oscMode == 0 && specForm < 7
        const valText = voicedFreq(oscMode, specForm, coarse, fine)
        // const valText = String(String(format: "%5.3f", voicedFreq(oscMode, specForm, coarse, fine)).prefix(5))
        const detuneOff = detune - 15
        const detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? detuneOff : `+${detuneOff}`)

        return [
          ['setCtrlLabel', "osc/mode", ratioMode ? `x ${valText}${detuneString}` : `${valText} Hz`]
        ]
      }
    }],
    ['setup', [
      ['colorItem', "voiced/amp/env", 2],
      ['colorItem', "unvoiced/amp/env", 3, true],
      ['colorItem', "op", 1],
      ['colorItem', "osc/mode", 1],
    ]],
    // on-click for the VC's view, send an event up.
    ['click', null, (state, locals) => ['event', "op", state, locals]],
    // .editMenu(nil, paths: opPaths, type: "Op", init: {
    //   let bd = try! patchTruss.createInitBodyData()
    //   return opPaths.map { patchTruss.getValue(bd, path: "op/0" + $0) ?? 0 }
    // }(), rand: {
    //   let patch = patchTruss.randomize()
    //   return opPaths.map { patch["op/0" + $0] ?? 0 }
    // })
  ],
  layout: [
    ['row', [["op",1],["freq",4]]],
    ['row', [["env", 1]]],
    ['colFixed', ["op", "env"], { fixed: "op", height: 11, spacing: 2 }],
    ['row', [["nenv", 1]]],
    ['colFixed', ["op", "nenv"], { fixed: "op", height: 11, spacing: 2 }],
  ]
}

const algo = ['fm', algorithms, miniOpController, {
  algo: "algo", 
  reverse: true, 
  selectable: true,
}]

const algoOptions = (88).map(i => `fs1r-algo-${i + 1}`)

const formantController = (destLabel, prefixItem) => ({
  prefix: ['index', [prefixItem, 'ctrl']], 
  color: 1,
  builders: [
    ['grid', [[
      ["Op", "op"],
      [{switch: "V/N"}, "unvoiced"],
      [{switch: destLabel}, "dest"],
      ["Depth", "depth"],
    ]]],
  ], 
  effects: [
    ['patchChange', {
      paths: ["dest", "depth"], 
      fn: values => [['dimPanel', values["dest"] == 0 || values["depth"] == 64, null]],
    })
  ])
})

const knobController = (topLabel, destLabel, prefixItem) => ({
  border: 1, 
  builders: [
    ['children', 5, "mod", formantController(destLabel, prefixItem)],
    ['panel', "label", {color: 1, clearBG: true}, [[
      {l: topLabel},
    ]]],
  ], 
  layout: [
    ['row', [["label", 1], ["mod0", 1]]],
    ['row', [["mod1", 1], ["mod2", 1]]],
    ['row', [["mod3", 1], ["mod4", 1]]],
    ['col', [["label", 1], ["mod1", 1], ["mod3", 1]]],
  ],
})

const modsController = {
  builders: [
    ['child', knobController("Formant Control", "Formant Dest", 'formant'), "formant"],
    ['child', knobController("FM Control", "FM Dest", 'fm'), "fm"],
  ], 
  simpleGridLayout: [
    [[["formant", 1], ["fm", 1]]],
  ],
}

const env = label => ({
  display: 'timeLevelEnv',
  pointCount: 4, 
  sustain: 2, 
  bipolar: true,
  l: label,
  maps: [
    ['src', "level/-1", "start/level", v => (v - 50) / 50)],
  ] + (4).flatMap(i => [
    ['u', ["time", i], 99],
    ['src', ["level", i], v => (v - 50) / 50],
  ]),
  id: "env",
})

const envEffect = ['editMenu', "env", {
  paths: (4).flatMap(i => [["time", i], ["level", i]]), 
  type: "FS1REnvelope",
}]

const pitchController = {
  prefix: ['fixed', "pitch/env"],
  builders: [
    ['grid', [[
      env("Pitch EG"),
      ["T1", "time/0"],
      ["T2", "time/1"],
      ["T3", "time/2"],
      ["T4", "time/3"],
      [{switch: "EG Range"}, "range"],
    ],[
      ["Velocity", "velo"],
      ["L0", "level/-1"],
      ["L1", "level/0"],
      ["L2", "level/1"],
      ["L3", "level/2"],
      ["L4", "level/3"],
      ["T Scale", "time/scale"],
    ]]],
  ], 
  effects: envEffect,
}

const filterController = {
  prefix: .fixed("filter/env"), 
  builders: [
    ['grid', [[
      env("Filter EG"),
      ["T1", "time/0"],
      ["T2", "time/1"],
      ["T3", "time/2"],
      ["T4", "time/3"],
      ["EG Depth", "depth"],
    ],[
      ["Velocity", "depth/velo"],
      ["Attack Velo", "attack/velo"],
      ["L1", "level/0"],
      ["L2", "level/1"],
      ["L3", "level/2"],
      ["L4", "level/3"],
      ["T Scale", "time/scale"],
    ]]],
  ], 
  effects: envEffect,
}


const common = {
  builders: [
    ['child', pitchController, "pitch", color: 1],
    ['child', filterController, "filter", color: 1],
    ['panel', 'filter2', { color: 1 }, [[
      [{select: "Filter"}, "filter/type"],
      ["Cutoff", "cutoff"],
      ["Reson", "reson"],
      ["Reson Velo", "reson/velo"],
    ],[
      ["LFO1 Cutoff", "cutoff/lfo/0"],
      ["LFO2 Cutoff", "cutoff/lfo/1"],
      ["Input Gain", "filter/gain"],
      ["Key Sc Cutoff", "cutoff/key/scale/depth"],
      ["Key Sc Brk Pt", "cutoff/key/scale/pt"]
    ]]],
    ['panel', 'lfo1', { color: 1, }, [[
      [{select: "LFO 1"}, "lfo/0/wave"],
      ["Speed", "lfo/0/rate"],
      ["Delay", "lfo/0/delay"],
      [{checkbox: "Key Sync"}, "lfo/0/key/sync"],
      ["Pitch", "lfo/0/pitch"],
      ["Amp", "lfo/0/amp"],
      ["Freq", "lfo/0/freq"],
    ]]],
    ['panel', 'lfo2', { color: 1, }, [[
      [{select: "LFO 2"}, "lfo/1/wave"],
      ["Speed", "lfo/1/rate"],
      [{switsch: "Phase"}, "lfo/1/phase"],
      [{checkbox: "Key Sync"}, "lfo/1/key/sync"],
    ]]],
    ['panel', 'cat', { color: 1, }, [[
      [{select: "Category"}, "category"],
      ["Note Shift", "note/shift"],
    ]]],
    ['panel', 'level', { color: 1, }, [[
      ["Level Adj 1", "adjust/op/0/level"],
      ["2", "adjust/op/1/level"],
      ["3", "adjust/op/2/level"],
      ["4", "adjust/op/3/level"],
    ],[
      ["5", "adjust/op/4/level"],
      ["6", "adjust/op/5/level"],
      ["7", "adjust/op/6/level"],
      ["8", "adjust/op/7/level"],
  ]]]
  ], 
  effects: [
    ['paramChange', "filter/on", parm => {
      const dim = parm.p == 0
      return (["filter", "filter2", "lfo2"]).map(i => ['dimPanel', dim, i])
    }]
  ], 
  layout: [
    ['row', [["pitch", 7], ["lfo1", 7.5]], { opts: ['alignAllTop'] }],
    ['rowPart', [["lfo2", 4.5], ["cat", 2.5]]],
    ['row', [["filter", 7], ["filter2", 5], ["level", 4]]],
    ['col', [["pitch", 2], ["filter", 2]]],
    ['colPart', [["lfo1", 1], ["lfo2", 1]]],
    ['eq', ["lfo1", "cat"], 'trailing'],
    ['eq', ["pitch", "lfo2"], 'bottom'],
  ],
}

// MARK: Palette

const palette = subVC => {
  builders: ([
    ['children', 8, "vc", subVC],
  ]).concat((8).map(i =>
    ['panel', ["label", i], {color: 1, clearBG: true}, [[
      {l: `${i + 1}`}
    ]]]
  )), 
  layout: [
    ['row', []],
    ['row', []],
    ['col', [["vc0", 15], ["label0", 1]]]
  ],
}


const paletteEffect = ['dimsOn', "amp/env/level", null]

const voicedPrefix = ['indexFn', i => ["op", i, "voiced"]]
const unvoicedPrefix = ['indexFn', i => ["op", i, "unvoiced"]]
    
const ampController = {
  builder: ['grid', [[
    ["T1", "amp/env/time/0"],
    ["T2", "amp/env/time/1"],
  ],[
    ["T3", "amp/env/time/2"],
    ["T4", "amp/env/time/3"],
  ],[
    ["Velo", "amp/env/velo"],
    ["Amp Mod", "amp/env/mod/sens"],
  ],[
    ["L1", "amp/env/level/0"],
    ["L2", "amp/env/level/1"],
  ],[
    ["L3", "amp/env/level/2"],
    ["L4", "amp/env/level/3"],
  ],[
    ["Level", "amp/env/level"],
    [{checkbox: "Mute", id: "mute"}, null],
  ]]],
  effects: [
    ['patchChange', "amp/env/level", v => [['setValue', "mute", v == 0 ? 1 : 0)]]],
    ['controlChange', "mute", (state, locals) => {
      const value = locals["mute"] || 0
      var level = 0
      var changes = []
      if (value > 0) {
        const newLastLevel = state.prefixedValue("amp/env/level") || 90
        changes.push(['setValue', "extra/level", newLastLevel == 0 ? 90 : newLastLevel])
        level = 0
      }
      else {
        level = locals["extra/level"] || 90
      }
      return changes.concat(['paramsChange', [["amp/env/level", level]]])
    }],
    paletteEffect,
  ],
}

const spectralFormEffect = ['patchChange', "spectral/form", v => {
  const isSine = v == 0
  const isFormant = v == 7
  return [
    ['hideItem', isFormant, "osc/mode"],
    ['hideItem', v < 5, "freq/ratio/spectral"],
    ['setCtrlLabel', "freq/ratio/spectral", isFormant ? "BW" : "Reson"],
    ['hideItem', isFormant, "key/sync"],
    ['hideItem', isSine, "spectral/skirt"],
    // these next are only present in the bigger op controller
    ['hideItem', !isFormant, "bw/bias/sens"],
    ['hideItem', !isFormant, "note/scale"],
    ['hideItem', !isFormant, "freq/velo"],
    ['hideItem', !isFormant, "freq/mod/sens"],
    ['hideItem', !isFormant, "freq/bias/sens"],
  ]
}]

const oscModeEffect = ['patchChange', {
  paths: ["osc/mode", "spectral/form", "coarse", "fine"],
  fn: values => {
    const oscMode = values["osc/mode"] || 0
    const specForm = values["spectral/form"] || 0
    const coarse = values["coarse"] || 0
    const fine = values["fine"] || 0
    return [
      ['setCtrlLabel', "ratio", (oscMode == 0 && specForm < 7) ? "Ratio" : "Fixed"],
      ['configCtrl', "ratio", { opts: [
        voicedFreq(oscMode, specForm, coarse, fine)
      ] }],
    ]
  },
}]


const voicedOscController = {
  prefix: voicedPrefix, 
  color: 2, 
  border: 2, 
  builders: [
    ['grid', [[
      [{switch: "Mode" }, "osc/mode"],
      [{switch: "Ratio", id: "ratio" }, null],
    ], [
      ["Coarse", "coarse"],
      ["Fine", "fine"],
    ], [
      ["Detune", "detune"],
      ["Transpose", "transpose"],
    ], [
      ["P Mod", "pitch/mod/sens"],
      ["Skirt", "spectral/skirt"],
    ], [
      [{select: "Spectral Form"}, "spectral/form"],
    ], [
      ["BW", "freq/ratio/spectral"],
      [{checkbox: "Key Sync"}, "key/sync"],
    ]]],
  ], 
  effects: [
    paletteEffect,
    spectralFormEffect,
    oscModeEffect,
  ],
}

const freqEnv = {
  display: 'timeLevelEnv',
  pointCount: 2, 
  sustain: 999, 
  bipolar: true,
  l: "Freq EG", 
  maps: [
    ['src', "freq/env/innit", "start/level", v => (v - 50) / 50 )],
    ['src', "freq/env/attack/level", "level/0", v => (v - 50) / 50 )],
    ['u', "freq/env/attack", "time/0", 99],
    ['u', "freq/env/decay", "time/1", 99],
  ], 
  id: "env",
}


const freqEnvMenu = ['editMenu', "env", {
  paths: ["freq/env/innit", "freq/env/attack/level", "freq/env/attack", "freq/env/decay"], 
  type: "FS1RFreqEnvelope", 
  init: [0, 0, 20, 20], 
  rand: () => (4).map(i => ([0, 100]).random()),
}]


const freqController = fseqTrk => ['grid', [[
    freqEnv,
  ],[
    ["Initial", "freq/env/innit"],
    ["A Level", "freq/env/attack/level"],
  ],[
    ["Attack", "freq/env/attack"],
    ["Decay", "freq/env/decay"],
  ],[
    ["Freq Scaling", "note/scale"],
    ["Fr Bias", "freq/bias/sens"],
  ],[
    ["Fr Velo", "freq/velo"],
    ["Fr Mod", "freq/mod/sens"],
  ],([
    [{checkbox: "Fseq"}, "fseq"],
  ]).concat(fseqTrk ? [["Fseq Trk", "fseq/trk"]] : [])
]]


const freqEffects = [
  ['patchChange', "spectral/form", v => ([
      "freq/velo",
      "freq/mod/sens",
      "freq/bias/sens",
      "note/scale",
    ]).map(p => ['hideItem', v == 7, p])
  ],
  ['paramChange', "fseq/on", parm => [
    ['dimItem', parm.p == 0, "fseq"],
    ['dimItem', parm.p == 0, "fseq/trk"],
  ] ],
  freqEnvMenu,
  paletteEffect,
]

const unvoicedRatioEffect = ['patchChange', { 
  paths: ["coarse", "fine", "mode"], 
  fn: values => {
    const mode = values["mode"] || 0
    const coarse = values["coarse"] || 0
    const fine = values["fine"] || 0
    return [
      ['hideItem', mode > 0, "ratio"],
      ['configCtrl', "ratio", { opts: [
        fixedFreq(coarse, fine),
      ] } ],
    ]
  }
}]

const unvoicedModeEffect = ['patchChange', "mode", value => {
  const isNormal = value == 0
  return [
    ['hideItem', !isNormal, "coarse"],
    ['hideItem', !isNormal, "fine"],
    // only in bigger controller
    ['hideItem', !isNormal, "freq/velo"],
    ['hideItem', !isNormal, "freq/mod/sens"],
    ['hideItem', !isNormal, "freq/bias/sens"],
    ['hideItem', !isNormal, "note/scale"],
  ]
}]

const unvoicedOscController = {
  prefix: unvoicedPrefix, 
  color: 3, 
  border: 3, 
  builders: [
    ['grid', [[
      [{switch: "Mode"}, "mode"],
      [{switch: "Ratio"}, "ratio"],
    ], [
      ["Coarse", "coarse"],
      ["Fine", "fine"],
    ], [
      ["Transpose", "transpose"],
    ], [
      ["BW", "bw"],
      ["BW Bias", "bw/bias/sens"],
    ], [
      ["Skirt", "skirt"],
      ["Reson", "reson"],
    ]]],
  ], 
  effects: [
    paletteEffect,
    unvoicedRatioEffect,
    unvoicedModeEffect,
  ],
}




const opAmpController = {
  prefix: ['fixed', "amp/env"], 
  builders: [
    ['grid', [[
      {
        display: 'timeLevelEnv',
        pointCount: 5, 
        sustain: 3,
        l: "Amp EG",
        maps: [
          ['u', "hold", "time/0", 99],
          ['u', "level/3", "start/level", 99],
          ['u', "level/3", "level/0", 99],
        ] + (4).flatMap(i => [
          ['u', ["time", i], ["time", i + 1, 99],
          ['u', ["level", i], ["level", i + 1, 99],
        ]), 
        id: "env",
      },
      ["T1", "time/0"],
      ["T2", "time/1"],
      ["T3", "time/2"],
      ["T4", "time/3"],
      ["Velo", "velo"],
      ["Amp Mod", "mod/sens"],
      ],[
      ["T Scale", "time/scale"],
      ["Hold", "hold"],
      ["L1", "level/0"],
      ["L2", "level/1"],
      ["L3", "level/2"],
      ["L4", "level/3"],
      ["EG Bias", "bias/sens"],
      ["Level", "level"],
      [{checkbox: "Mute", id: "mute"}, null],
    ]]]
  ], 
  effects: [
    ['patchChange', "level", v => [['setValue', "mute", v == 0 ? 1 : 0)]]],
    ['controlChange', "mute", (state, locals) => {
      const value = locals["mute"] || 0
      var level = 0
      var changes = []
      if (value > 0) {
        const newLastLevel = state.prefixedValue("level") || 90
        changes.push(['setValue', "extra/level", newLastLevel == 0 ? 90 : newLastLevel])
        level = 0
      }
      else {
        level = locals["extra/level"] || 90
      }
      return changes.concat(['paramsChange', [["level", level]]])
    }],
    ['editMenu', "env", {
      paths: (4).map(i => ["time", i]).concat(
        (4).map(i => ["level", i])
      ).concat(["hold"]), 
      type: "FS1RAmpEnvelope", 
      init: [0, 20, 20, 0, 99, 99, 99, 0, 0], 
      rand: { 9.map { $0 > 6 ? 0 : (0..<100).random()! } }],
    }]
  ]
}

const opFreqController = {
  builders: [
    ['grid', [[
      Controller.freqEnv,
      ["Initial", "freq/env/innit"],
      ["A Level", "freq/env/attack/level"],
      ["Attack", "freq/env/attack"],
      ["Decay", "freq/env/decay"],
    ]]],
  ], 
  effects: [
    Controller.freqEnvMenu,
  ],
}


const opControllerEffects = [
  ['patchChange', "amp/env/level", v => ['dimPanel', v == 0, null]],
  ['paramChange', "fseq/on", parm => [
    ['dimItem', parm.p == 0, "fseq"],
    ['dimItem', parm.p == 0, "fseq/trk"],
  ] }],
]

const voicedPaths: [SynthPath] = patchTruss.params.keys.compactMap {
  guard $0.starts(with: "op/0/voiced") else { return nil }
  return $0.subpath(from: 3)
}

const voicedOp = {
  prefix: ['fixed', "voiced"], 
  border: 2, 
  builders: [
    ['child', opAmpController, "amp", {color: 2}],
    ['child', opFreqController, "freq", {color: 2}],
    ['child', levelScale, "levelScale", {color: 2}],
    ['button', "Op", {color: 2}],
    ['panel', 'osc', { color: 2 }, [[
      [{switch: "Mode"}, "osc/mode"],
      "Ratio", nil, id: "ratio",
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Detune", "detune"],
      ["Transpose", "transpose"],
      ["P Mod", "pitch/mod/sens"],
    ], [
      [{select: "Spectral Form"}, "spectral/form"],
      ["Skirt", "spectral/skirt"],
      ["BW", "freq/ratio/spectral"],
      ["BW Bias", "bw/bias/sens"],
      [{checkbox: "Key Sync"}, "key/sync"],
      ["Freq Scaling", "note/scale"],
      [{checkbox: "Fseq"}, "fseq"],
      ["Fseq Trk", "fseq/trk"],
    ]]],
    ['panel', 'freq2', { color: 2, }, [[
      ["Fr Velo", "freq/velo"],
      ["Fr Mod", "freq/mod/sens"],
      ["Fr Bias", "freq/bias/sens"],
    ]]],
  ], 
  effects: ([
    Controller.spectralFormEffect,
    Controller.oscModeEffect,
    ['indexChange', i => ['setCtrlLabel', "button", `Op ${i + 1} - Voiced`]],
    ['editMenu', "button", {
      paths: voicedPaths, 
      type: "FS1RVoicedOp", 
      init: {
        let bd = patchTruss.createInitBodyData()
        return voicedPaths.map { patchTruss.getValue(bd, path: "op/0/voiced" + $0) ?? 0 }
      }(), 
      rand: {
        let patch = patchTruss.randomize()
        return voicedPaths.map { patch["op/0/voiced" + $0] ?? 0 }
      }
    }],
  ]).concat(opControllerEffects), 
  layout: [
    ['row', [["freq", 6], ["freq2", 3]]],
    ['row', [["button", 3], ["levelScale", 7.5]]],
    ['col', [["osc", 2], ["freq", 1], ["amp", 2], ["button", 1]]],
    ['eq', ["osc","freq2","amp","levelScale"], 'trailing'],
  ])
}

const levelScale = {
  prefix: ['fixed', "level/scale"], 
  builders: [
    ['grid', [[
      {
        display: 'levelScaling',
        maps: [
          ['ident', "left/curve"],
          ['ident', "right/curve"],
          ['u', "left/depth", 99],
          ['u', "right/depth", 99],
          ['u', "brk/pt", 99],
        ],
        id: "level/scale", 
        width: 4,
      },
      ["L Depth", "left/depth"],
      [{switch: "L Curve"}, "left/curve"],
      ["Break Pt", "brk/pt"],
      ["R Depth", "right/depth"],
      [{switch: "R Curve"}, "right/curve"],
    ]]]
  ], 
  effects: [
    ['editMenu', "level/scale", {
      paths: [
        "left/depth",
        "left/curve",
        "right/depth",
        "right/curve",
        "brk/pt",
      ], 
      type: "FS1RRateLevel", 
      init: [0, 3, 0, 0, 39], 
      rand: {
        5.map { $0 % 2 == 1 ? (0..<4).random()! : (0..<100).random()! }
      },
    }],
  ],
}

const unvoicedPaths = patchTruss.params.keys.compactMap {
  guard $0.starts(with: "op/0/unvoiced") else { return nil }
  return $0.subpath(from: 3)
}

const unvoicedOp = {
  prefix: ['fixed', "unvoiced"], 
  border: 3, 
  builders: [
    ['child', opAmpController, "amp", {color: 3}],
    ['child', opFreqController, "freq", {color: 3}],
    ['button', "Op", {color: 3}],
    ['panel', 'osc', { color: 3 }, [[
      [{switch: "Mode"}, "mode"],
      [{switch: "Ratio"}, "ratio"],
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Transpose", "transpose"],
      ["Freq Scale", "note/scale"],
    ],[
      ["Skirt", "skirt"],
      ["BW", "bw"],
      ["BW Bias", "bw/bias/sens"],
      ["Reson", "reson"],
      ["Fr Velo", "freq/velo"],
      ["Fr Mod", "freq/mod/sens"],
      ["Fr Bias", "freq/bias/sens"],
    ]]],
    ['panel', 'freq2', { color: 3 }, [[
      [{checkbox: "Fseq"}, "fseq"],
    ]]],
    ['panel', 'amp2', { color: 3 }, [[
      ["Level Scale", "level/key/scale"],
    ]]]
  ], 
  effects: ([
    ['indexChange', i => ['setCtrlLabel', "button", `Op ${i + 1} - Unvoiced`],
    ['editMenu', "button", {
      paths: unvoicedPaths, 
      type: "FS1RUnvoicedOp", 
      init: {
        let bd = patchTruss.createInitBodyData()
        return voicedPaths.map { patchTruss.getValue(bd, path: "op/0/unvoiced" + $0) ?? 0 }
      }(), 
      rand: {
        let patch = patchTruss.randomize()
        return voicedPaths.map { patch["op/0/unvoiced" + $0] ?? 0 }
      }
    }],
    Controller.unvoicedRatioEffect,
    Controller.unvoicedModeEffect,
  ]).concat(opControllerEffects), 
  layout: [
    ['row', [["freq", 6], ["freq2", 1]]],
    ['row', [["button", 3], ["amp2", 4]]],
    ['col', [["osc", 2], ["freq", 1], ["amp", 2], ["button", 1]]],
    ['eq', ["osc","freq2","amp","amp2"], 'trailing'],
  ])
}


const opController = {
  prefix: ['index', "op"],
  builders: [
    ['child', voicedOp, "v"],
    ['child', unvoicedOp, "n"],
  ], 
  effects: [
    ['indexChange', i => [
      ['setIndex', "v", i],
      ['setIndex', "n", i],
    ]],
  ], 
  simpleGridLayout: [
    [[["v", 8.5],["n", 7.5]]],
  ],
}




const controller = {
  builders: [
    ['switcher', (8).map(i => `Op ${i + 1}`).concat(["Common", "V Osc", "V Amp", "V Freq", "Mods", "N Osc", "N Amp", "N Freq"]), { cols: 4, color: 1 }],
    ['child', algo, "algo", {color: 1, clearBG: true}],
    ['panel', 'feed', { color: 1, }, [[
      [{imgSelect: "Algorithm", w: 120, h: 120, images: algoOptions}, "algo"],
    ],[
      ["Feedback", "feedback"],
    ]]],
  ], 
  effects: [
    ['indexChange', i => ['setIndex', "algo", i]],
    // listen for events from the algo controller to select index.
    ['listen', "op", (state, locals) => ['setIndex', null, state.index]],
  ], 
  layout: [
    ['row', [["algo", 8], ["feed",2], ["switch", 6]]],
    ['row', [["page", 1]]],
    ['col', [["algo", 3], ["page", 5]]],
  ], 
  pages: ['map', (8).map(i => ["op", i]).concat([
      "common", "voiced/osc", "voiced/amp", "voiced/freq",
      "mod", "unvoiced/osc", "unvoiced/amp", "unvoiced/freq",
    ]), [
    ["common", commonController],
    ["mod", modsController],
    ["op", opController],
    ["voiced/amp", palette({
      prefix: voicedPrefix, 
      color: 2, 
      border: 2, 
      builders: [ampController.builder], 
      effects: ampController.effects,
    })],
    ["voiced/osc", palette(voicedOscController)],
    ["voiced/freq", palette({
      prefix: voicedPrefix, 
      color: 2, 
      border: 2, 
      builders: [freqController(true)], 
      effects: freqEffects,
    })],
    ["unvoiced/amp", palette({
      prefix: unvoicedPrefix, 
      color: 3, 
      border: 3, 
      builders: [ampController.builder], 
      effects: ampController.effects,
    })],
    ["unvoiced/osc", palette(unvoicedOscController)],
    ["unvoiced/freq", palette({
      prefix: unvoicedPrefix, 
      color: 3, 
      border: 3,
      builders: [freqController(false)], 
      effects: freqEffects,
    })],
  ]))
}

module.exports = {
  controller: controller,
}