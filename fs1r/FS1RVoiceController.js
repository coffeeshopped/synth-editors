
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
  ],
}

const voicedAmpController = {
  prefix: voicedPrefix, 
  color: 2, 
  border: 2, 
  builders: [ampController.builder], 
  effects: ampController.effects.concat([paletteEffect]),
}

const spectralFormEffect = .patchChange("spectral/form", { value in
  let isSine = value == 0
  let isFormant = value == 7
  return [
    ['dimItem', isFormant, "osc/mode", dimAlpha: 0],
    ['dimItem', value < 5, "freq/ratio/spectral", dimAlpha: 0],
    ['setCtrlLabel', "freq/ratio/spectral", isFormant ? "BW" : "Reson"],
    ['dimItem', isFormant, "key/sync", dimAlpha: 0],
    ['dimItem', isSine, "spectral/skirt", dimAlpha: 0],
    // these next are only present in the bigger op controller
    ['dimItem', !isFormant, "bw/bias/sens", dimAlpha: 0],
    ['dimItem', !isFormant, "note/scale", dimAlpha: 0],
    ['dimItem', !isFormant, "freq/velo", dimAlpha: 0],
    ['dimItem', !isFormant, "freq/mod/sens", dimAlpha: 0],
    ['dimItem', !isFormant, "freq/bias/sens", dimAlpha: 0],
  ]
})

static let oscModeEffect: PatchController.Effect = .patchChange(paths: ["osc/mode", "spectral/form", "coarse", "fine"], { values in
  guard let oscMode = values["osc/mode"],
    let specForm = values["spectral/form"],
    let coarse = values["coarse"],
    let fine = values["fine"] else { return [] }
  return [
    ['setCtrlLabel', "ratio", (oscMode == 0 && specForm < 7) ? "Ratio" : "Fixed"],
    .configCtrl("ratio", .opts(ParamOptions(optArray: [
      String(String(format: "%5.3f", voicedFreq(oscMode: oscMode, spectralForm: specForm, coarse: coarse, fine: fine)).prefix(5))
    ]))),
  ]
})



static var voicedOscController: PatchController {
  return .patch(prefix: voicedPrefix, color: 2, border: 2, [
    ['grid', [[
      [{switsch: "Mode"}, "osc/mode"],
      "Ratio", nil, id: "ratio",
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
  ], effects: [
    paletteEffect,
    spectralFormEffect,
    oscModeEffect,
  ])
}

static let freqEnv: PatchController.PanelItem = {
  let env: PatchController.Display = .timeLevelEnv(pointCount: 2, sustain: 999, bipolar: true)
  return .display(env, "Freq EG", [
    .src("freq/env/innit", dest: "start/level", { ($0 - 50) / 50 }),
    .src("freq/env/attack/level", dest: "level/0", { ($0 - 50) / 50 }),
    .src("freq/env/attack", dest: "time/0", { $0 / 99 }),
    .src("freq/env/decay", dest: "time/1", { $0 / 99 }),
  ], id: "env")
}()

static let freqEnvMenu: PatchController.Effect = ['editMenu', "env", paths: ["freq/env/innit", "freq/env/attack/level", "freq/env/attack", "freq/env/decay"], type: "FS1RFreqEnvelope", init: [0, 0, 20, 20], rand: { 4.map { _ in (0..<100).random()! } }]


const freqController = (fseqTrk: Bool) => {
  
  let builder: PatchController.Builder = ['grid', [[
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
  ],[
    [{checkbox: "Fseq"}, "fseq"],
  ] + (fseqTrk ? `knob("Fseq Trk"/${[.fseq}/trk`)] : [])])
  
  let effects: [PatchController.Effect] = [
    .patchChange("spectral/form", { value in
      let isFormant = value == 7
      let freqPaths: [SynthPath] = [
        "freq/velo",
        "freq/mod/sens",
        "freq/bias/sens",
        "note/scale",
      ]
      return freqPaths.map { ['dimItem', isFormant, $0, dimAlpha: 0] }
    }),
    .paramChange("fseq/on", { param in
      [
        ['dimItem', param.parm == 0, "fseq"],
        ['dimItem', param.parm == 0, "fseq/trk"],
      ]
    }),
    freqEnvMenu,
  ]
  
  return (builder, effects)
}

static var voicedFreqController: PatchController {
  let c = freqController(fseqTrk: true)
  return .patch(prefix: voicedPrefix, color: 2, border: 2, [c.0], effects: c.1 + [paletteEffect])
}

static var unvoicedAmpController: PatchController {
  let c = ampController()
  return .patch(prefix: unvoicedPrefix, color: 3, border: 3, [c.0], effects: c.1 + [paletteEffect])
}

static let unvoicedRatioEffect: PatchController.Effect = .patchChange(paths: ["coarse", "fine", "mode"], { values in
  guard let mode = values["mode"],
    let coarse = values["coarse"],
    let fine = values["fine"] else { return [] }
  return [
    ['dimItem', mode > 0, "ratio", dimAlpha: 0],
    .configCtrl("ratio", .opts(ParamOptions(optArray: [
      String(String(format: "%5.3f", fixedFreq(coarse: coarse, fine: fine)).prefix(5)),
    ])))
  ]
})

static let unvoicedModeEffect: PatchController.Effect = .patchChange("mode", { value in
  let isNormal = value == 0
  return [
    ['dimItem', !isNormal, "coarse", dimAlpha: 0],
    ['dimItem', !isNormal, "fine", dimAlpha: 0],
    // only in bigger controller
    ['dimItem', !isNormal, "freq/velo", dimAlpha: 0],
    ['dimItem', !isNormal, "freq/mod/sens", dimAlpha: 0],
    ['dimItem', !isNormal, "freq/bias/sens", dimAlpha: 0],
    ['dimItem', !isNormal, "note/scale", dimAlpha: 0],
  ]
})

static var unvoicedOscController: PatchController {
  return .patch(prefix: unvoicedPrefix, color: 3, border: 3, [
    .grid( [[
      [{switsch: "Mode"}, "mode"],
      [{switsch: "Ratio"}, "ratio"],
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
    ]]]
  ], effects: [
    paletteEffect,
    unvoicedRatioEffect,
    unvoicedModeEffect,
  ])
}

static var unvoicedFreqController: PatchController {
  let c = freqController(fseqTrk: false)
  return .patch(prefix: unvoicedPrefix, color: 3, border: 3, [c.0], effects: c.1 + [paletteEffect])
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
    ["voiced/amp", palette(voicedAmpController)],
    ["voiced/osc", palette(voicedOscController)],
    ["voiced/freq", palette(voicedFreqController)],
    ["unvoiced/amp", palette(unvoicedAmpController)],
    ["unvoiced/osc", palette(unvoicedOscController)],
    ["unvoiced/freq", palette(unvoicedFreqController)],
  ]))
}

module.exports = {
  controller: controller,
}