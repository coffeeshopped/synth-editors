
const algo = .fm(algorithms(), MiniOp.controller, algoPath: "algo", reverse: true, selectable: true)

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
    ["op", Op.controller],
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