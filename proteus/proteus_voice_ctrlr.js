
const envPaths = [
  "attack",
  "hold",
  "decay",
  "sustain",
  "release",
]

const env: (env: PatchController.PanelItem, menu: PatchController.Effect) = {
  let maps: [PatchController.DisplayMap] = envPaths.map { .unit($0, max: 99) }
  let env: PatchController.PanelItem = .display(.ahdsrEnv(), "", maps, id: "env")
  return (env: env, menu: ['editMenu', "env", paths: envPaths, type: "ProteusEnvelope", init: [0, 0, 72, 50, 12], rand: { 5.map { _ in (0...99).rand() } })]
}()

const extra = {
  prefix: { fixed: "extra" }, 
  builders: [
    ['grid', [[
      ["Delay", "delay"],
      env.env,
      ["Amount", "amt"],
      ],[
      ["Attack", "attack"],
      ["Hold", "hold"],
      ["Decay", "decay"],
      ["Sustain", "sustain"],
      ["Release", "release"],
    ]]]
  ], 
  effects: [
    env.menu,
  ],
}

const kv = {
  prefix: { index: "key/velo" }, 
  builders: [
    ['grid', [[
      [{switsch: "Src"}, "src"],
      ["Amount", "amt"],
      [{select: "Dest"}, "dest"],
    ]]]
  ], 
  effects: [
    .indexChange({ [['setCtrlLabel', "src", "K/V Src \($0 + 1)")] }],
    .patchChange(paths: ["amt", "dest"], { values in
      [['dimPanel', values["amt"] == 0 || values["dest"] == 0, nil]]
    })
  ])
}

const lfo = {
  prefix: { index: "lfo" }, 
  builders: [
    ['grid', [[
      [{switsch: "LFO"}, "shape"],
      ["Rate", "freq"],
      ["Amount", "amt"],
      ["Delay", "delay"],
      ["Vari", "mod"],
    ]]]
  ], 
  effects: [
    .indexChange({ [['setCtrlLabel', "shape", "LFO \($0 + 1)")] }],
  ],
}

const mod = {
  prefix: { index: "mod" }, 
  builders: [
    ['grid', [[
      [{select: "Src"}, "src"],
      [{select: "Dest"}, "dest"],
    ]]]
  ], 
  effects: [
    .indexChange({ [['setCtrlLabel', "src", "RT Src \($0 + 1)")] }],
    ['dimsOn', "dest", id: nil],
  ])
}

const inst = (chorusMax) => {
  let envCtrls = envPaths + ["env"]

  return .patch(prefix: .index([]), [
    ['grid', [[
      [{select: "Wave"}, "wave"],
      ["Start", "start"],
      ["Volume", "volume"],
      ["Delay", "delay"],
      env.env,
      [{checkbox: "Env On"}, "env/on"],
      [{checkbox: "Solo"}, "solo"],
      (chorusMax == 1 ? [{checkbox: "Chorus"}, "chorus"] : ["Chorus", "chorus"]),
      [{checkbox: "Reverse"}, "reverse"],
      ],[
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Pan", "pan"],
      ["Attack", "attack"],
      ["Hold", "hold"],
      ["Decay", "decay"],
      ["Sustain", "sustain"],
      ["Release", "release"],
      ["Key Lo", "key/lo"],
      ["Key Hi", "key/hi"],
    ]]]
  ], 
  effects: [
    .indexChange({ [['setCtrlLabel', "wave", $0 == 0 ? "Primary" : "Secondary")]}],
    ['dimsOn', "wave", id: nil],
    env.menu,
  ] + envCtrls.map {
    ['dimsOn', "env/on", id: $0]
  })
}


const ctrlr = (chorusMax) => ({  
  builders: [
    ['children', 2, "inst", color: 1, inst(chorusMax)],
    ['children', 6, "kv", color: 3, kv],
    ['children', 8, "mod", color: 2, mod],
    ['children', 2, "lfo", color: 2, lfo],
    ['child', extra, "extra", color: 2],
    ['panel', 'xfade', { color: 1 }, [[
      [{switsch: "XFade"}, "cross/mode"],
      [{switsch: "Dir"}, "cross/direction"],
      ["Balance", "cross/balance"],
      ["Amount", "cross/amt"],
      ["Switch Pt", "cross/pt"],
    ]]],
    ['panel', 'bend', { color: 1 }, [[
      ["Bend", "bend"],
      ["Pressure", "pressure/amt"],
      [{select: "Tuning"}, "tune"],
    ]]],
    ['panel', 'key', { color: 1 }, [[
      ["Key Lo", "key/lo/0"],
      ["Key Hi", "key/hi/0"],
    ]]],
    ['panel', 'velo', { color: 1 }, [[
      ["Velo Crv", "velo/curve"],
      ],[
      [{switsch: "Mix Out"}, "mix"],
    ]]],
    ['panel', 'center', { color: 3 }, [[
      ["Key Center", "key/mid"],
    ]]],
    ['panel', 'ctrl', { color: 2 }, [[
      ["Ctrl A", "ctrl/0/amt"],
      ["Ctrl B", "ctrl/1/amt"],
      ],[
      ["Ctrl C", "ctrl/2/amt"],
      ["Ctrl D", "ctrl/3/amt"],
    ]]],
    ['panel', 'foot', { color: 1 }, [[
      [{select: "Foot 1"}, "foot/0/dest"],
      [{select: "Foot 2"}, "foot/1/dest"],
      [{select: "Foot 3"}, "foot/2/dest"],
    ]]],
    ['panel', 'link', { color: 1 }, [[
      [{select: "Link 1"}, "link/0"],
      ["Key Lo", "key/lo/1"],
      ["Key Hi", "key/hi/1"],
      ],[
      [{select: "Link 2"}, "link/1"],
      ["Key Lo", "key/lo/2"],
      ["Key Hi", "key/hi/2"],
      ],[
      [{select: "Link 3"}, "link/2"],
      ["Key Lo", "key/lo/3"],
      ["Key Hi", "key/hi/3"],
      ]]]
  ], 
  effects: [
    ['dimsOn', "cross/mode", id: "xfade"],
    .paramChange("patch/name", { param in
      3.map { ['configCtrl', "link/$0", .param(param)] }
    })
  ] + 3.map { link in
      .patchChange("link/link") { value in
        let dim = value == -1
        return [
          ['dimItem', dim, "link/link"],
          ['dimItem', dim, "key/lo/link + 1"],
          ['dimItem', dim, "key/hi/link + 1"],
        ]
      }
    }, 
  layout: [
    ['row', [["inst0",10.5], ["xfade",5.5]], { opts: ['alignAllTop'] }],
    ['rowPart', [["bend",3.5], ["key", 2]]],
    ['row', [["inst1",10.5], ["velo",2], ["link", 3.5]], { opts: ['alignAllTop'] }],
    ['rowPart', [["kv0",3.5], ["kv1",3.5], ["kv2",3.5], ["center",1]]],
    ['rowPart', [["ctrl",2], ["lfo0",5], ["extra",5]], { opts: ['alignAllTop'] }],
    ['rowPart', [["mod0",3], ["mod1",3], ["mod2",3], ["mod3",3],]],
    ['rowPart', [["mod4",3], ["mod5",3], ["mod6",3], ["mod7",3],]],
    ['col', [["inst0",2], ["inst1",2], ["kv0",1], ["kv3",1], ["kv4",1], ["kv5",1], ["foot",1]]],
    ['colPart', [["xfade", 1], ["bend", 1]]],
    ['colPart', [["lfo0",1], ["lfo1",1]], { opts: ['alignAllLeading', 'alignAllTrailing'] }],
    ['colPart', [["ctrl",2], ["mod0",1], ["mod4",1]]],
    ['eq', ["xfade", "key", "extra", "mod3", "mod7"], 'trailing'],
    ['eq', ["inst0", "bend"], 'bottom'],
    ['eq', ["inst1", "velo"], 'bottom'],
    ['eq', ["center", "link"], 'bottom'],
    ['eq', ["velo", "center"], 'trailing'],
    ['eq', ["ctrl", "lfo1", "extra"], 'bottom'],
    ['eq', ["kv0", "kv3", "kv4", "kv5", "foot"], 'trailing'],
    ['eq', ["foot", "mod4"], 'bottom'],
    ['eq', ["kv1", "ctrl"], 'leading'],
    ['eq', ["kv3", "ctrl"], 'top'],
  ],
})