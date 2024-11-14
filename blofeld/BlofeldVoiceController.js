

const modItems = (label, pre) => [
  [label, [pre, "amt"]],
  `← ${label} Src`, [pre, "src"]],
]

const modEffect = pre => ['patchChange', {
  paths: [pre + "amt", pre + "src"], 
  fn: values => {
    const src = values[pre + "src"] || 0
    const amt = values[pre + "amt"] || 0
    const off = src == 0 || amt == 64
    return [
      ['dimItem', off, pre + "amt"],
      ['dimItem', off, pre + "src"],
    ]
  }
}]


const fmCombo = {
  items: [
    ["FM", "fm/amt"],
    [{select: "← FM Src"}, "fm/src"],
  ],
  cmd: ['patchChange', "fm/src", v => [
    ['dimItem', v == 0, "fm/amt"],
    ['dimItem', v == 0, "fm/src"],
  ] }
}


const oscController = index => {
  var dim = ['dimsOn', {paths: ["shape", "sample"]}]
  var items = [
    [{switch: "Mode"}, "sample"],
    [{switch: "Limit WT"}, "limitWT"],
  ]
  if (index >= 2) {
    dim = ['dimsOn', "shape"]
    items = [
      [{checkbox: "Sync 2→3"}, "sync"],
      '-'
    ]
  }
  
  return {
    prefix: .fixed("osc/index"), 
    builders: [
      ['grid', [[
        [{select: `Osc ${index + 1} Wave`}, "shape"],
        [{select: 'Octave'}, "octave"],
        ["Semi", "coarse"],
        ["Detune", "fine"],
        ["PW", "pw"],
      ].concat(
        modItems("PWM", "pw")
      ).concat(
        fmCombo.items
      ).concat([
        ["Key Track", "keyTrk"],
        ["bend"],
        ["brilliance"],
      ]).concat(
        items
      )]],
    ], 
    effects: [
      dim,
      ['patchChange', "sample", v => ['configCtrl', "shape", {opts:  $0 == 0 ? waveformOptions : sampleOptions}]],
      fm.cmd,
      modEffect('pw'),
    ],
  }
}

const filterController = ['index', "filter", "type", i => `Filter ${i + 1}`, {
  builders: [
    ['grid', [[
      [{select: "Filter"}, "type"],
      ["cutoff"],
      ["reson"],
      ["Env Amt", "env/amt"],
      ["Velocity", "velo"],
    ], modItems("Cutoff Mod", "cutoff").concat(fmCombo.items), ([
      ["pan"],
    ]).concat(modItems("Pan Mod", "pan")).concat([
      ["drive"],
      ["Key Track", "keyTrk"],
    ])]],
  ], 
  effects: [
    modEffect("cutoff"),
    fmCombo.cmd,
    modEffect("pan"),
    ['dimsOn', "type"]
  ],
}]


const pathFn = values => {
  const mode = values["mode"] || 0
  const attackLevel = values["attack/level"] || 0
  const attack = values["attack"] || 0
  const decay = values["decay"] || 0
  const sustain = values["sustain"] || 0
  const decay2 = values["decay2"] || 0
  const sustain2 = values["sustain2"] || 0
  const rrelease = values["release"] || 0

  var cmds = []

  const adsrStyle = mode == 0 || mode == 2
  const segCount = (() => {
    switch (mode) {
    case 0:
    case 3:
    case 4: 
      return 4
    case 1: 
      return 5
    case 2: 
      return 3
    }
  })()
  const segWidth = 1 / segCount
  var x = 0
  
  cmds.push(['move', 0, 0])
  
  // attack
  x += attack * segWidth
  cmds.push(['line', x, adsrStyle ? 1 : attackLevel])
  
  // decay
  x += decay * segWidth
  cmds.push(['curve', x, sustain])

  if (mode == 0) {
    // sustain1
    x += segWidth
    cmds.push(['line', x, sustain])
  }
  
  if (!adsrStyle) {
    // s1 to s2
    x += decay2 * segWidth
    cmds.push(['line', x, sustain2])
  }
  
  if (mode == 1) {
    // sustain2
    x += segWidth
    cmds.push(['line', x, sustain2])
  }
  
  // release
  x += rrelease * segWidth
  const rWeight = mode == 2 ? 0.5 : 0
  cmds.push(['curve', x, 0, rWeight])
  
  return cmds
}

const envItem = (label, prefix, id) => ({
  env: pathFn,
  l: label,
  maps: [
    ['=', "mode"],
    ['u', "attack/level"],
    ['u', "attack"],
    ['u', "decay"],
    ['u', "sustain"],
    ['u', "decay2"],
    ['u', "sustain2"],
    ['u', "release"],
  ],
  srcPrefix: prefix,
  id: id,
})

const envMenu = (prefix, id) => ['editMenu', id, {
  paths: (["mode", "attack", "attack/level", "decay", "sustain", "decay2", "sustain2", "release"]).map(p => [prefix, p]), 
  type: "MicroQEnvelope", 
  init: [0, 0, 64, 0, 127, 64, 64, 0], 
  // rand: { [5.rand()] + 7.map { 128.rand() } },
}]

const envEffect = prefix => ['patchChange', [prefix, "mode"], v => {
  const hideSome = (v == 0) || (v == 2) // 0,2==adsr
  return [
    ['setCtrlLabel', "decay", hideSome ? "D" : "D1"],
    ['setCtrlLabel', "sustain", hideSome ? "S" : "S1"],
    ['hideItem', hideSome, "attack/level"],
    ['hideItem', hideSome, "decay2"],
    ['hideItem', hideSome, "sustain2"],
  ]
}]


const envController = withFilter => {
  const items = (withFilter ? ["Filter"] : []).concat(["Amp","3","4"])
  const labels = (withFilter ? ["Filter"] : []).concat(["Amp", "Env 3", "Env 4"])
  
  return {
    prefix: ['indexFn', i => `env/${i + (withFilter ? 0 : 1)}`, 
    builders: [
      ['grid', [[
        ["AL", "attack/level"], // 0
        ["A", "attack"], // 1
        ["D1", "decay"], // 2
        ["S1", "sustain"], // 3
        ["D2", "decay2"], // 4
        ["S2", "sustain2"], // 5
        ["R", "release"], // 6
      ],[
        ['switcher', "Envelope", items, {width: withFilter ? 7 : 5}],
        [{select: "Mode"}, "mode"],
        envItem(null, '', "env"),
        [{switch: "Trigger"}, "trigger"],
      ]]],
    ], 
    effects: [
      envEffect(''),
      envMenu('', 'env'),
      ['indexChange', i => ['setCtrlLabel', "env", labels[i % labels.length]]],
    ],
  }
}


const lfoController = {
  prefix: .index("lfo"), 
  builders: [
    ['grid', [[
      ["speed"],
      [{checkbox: "Clocked"}, "clock"],
      ["Key Track", "keyTrk"],
      ["phase"],
      ["delay"],
      ["fade"],
    ],[
      ['switcher', label: "LFO", ["1","2","3"]],
      [{select: "Wave"}, "shape"],
      "sync",
    ]]],
  ], 
  effects: [
    ['indexChange', i => ['setCtrlLabel', "shape", `LFO ${i + 1}`]],
    ['patchChange', "clock", v => ['configCtrl', "speed", { iso: v == 0 ? null : lfoRateIso }],
    ['dimsOn', "sync", "phase"],
  ],
}


const voiceController = {
  builders: [
    // add before fEnv panels so it's in the back.
    ['panel', 'fEnvCon', { color: 2, }, [[]]],
    ['child', oscController(0), "osc0", {color: 1}],
    ['child', oscController(1), "osc1", {color: 1}],
    ['child', oscController(2), "osc2", {color: 1}],
    ['children', 2, "filter", {color: 2}, filterController],
    ['child', envController(false), "env", {color: 3}],
    ['child', lfoController, "lfo", {color: 3}],
    ['panel', 'mix', { color: 1, }, [[
      ["O1 Lvl", "osc/0/level"],
      ["O1 Bal", "osc/0/balance"],
    ],[
      ["O2 Lvl", "osc/1/level"],
      ["O2 Bal", "osc/1/balance"],
    ],[
      ["O3 Lvl", "osc/2/level"],
      ["O3 Bal", "osc/2/balance"],
    ],[
      ["Noise", "noise/level"],
      ["Balance", "noise/balance"],
    ],[
      ["Ring Mod", "ringMod/level"],
      ["Balance", "ringMod/balance"],
    ]]],
    ['panel', 'noise', { color: 1, }, [[
      ["Nz Color", "noise/color"],
    ]]],
    ['panel', "pitch", {color: 1}, [modItems("Pitch Mod", "pitch")]),
    ['panel', 'route', { color: 2, }, [[
      [{switsch: "Routing"}, "filter/routing"],
    ]]],
    ['panel', 'fEnv', { prefix: "env/0", color: 2, }, [[
      ["A", "attack"], // 1
      ["D1", "decay"], // 2
      ["S1", "sustain"], // 3
    ],[
      ["AL", "attack/level"], // 0
      [{switch: "Trigger"}, "trigger"],
      ["R", "release"], // 6
    ],[
      [{select: "Mode"}, "mode"],
      envItem("Filter", "env/0", "env/0"),
    ]]],
    ['panel', 'fEnvX', { prefix: "env/0", color: 2, }, [[
      ["D2", "decay2"], // 4
      ["S2", "sustain2"], // 5
    ]]],
  ], 
  effects: [
    envEffect("env/0"),
    envMenu("env/0", "env/0"),
    modEffect("pitch"),
  ], 
  layout: [
    ['row', [["mix", 2], ["osc0", 16]], { opts: ['alignAllTop'] }],
    ['rowPart', [["noise", 1], ["route", 1], ["filter0", 5.5], ["filter1", 5.5]], { opts: ['alignAllTop'] }],
    ['rowPart', [["fEnv", 3], ["fEnvX", 2]], { opts: ['alignAllTop'] }],
    ['rowPart', [["env", 7], ["lfo", 6]]],
    ['col', [["mix", 5], ["fEnv", 3]]],
    ['col', [["osc0", 1], ["osc1", 1], ["osc2", 1], ["filter1", 3], ["lfo", 2]], { opts: ['alignAllTrailing'] }],
    ['colPart', [["noise", 1], ["pitch", 1]]],
    ['eq', ["osc0", "osc1", "osc2", "noise", "pitch"], 'leading'],
    ['eq', ["route", "pitch", "fEnvX"], 'trailing'],
    ['eq', ["mix", "pitch"], 'bottom'],
    ['eq', ["noise", "route"], 'bottom'],
    ['eq', ["fEnvX", "filter0", "filter1"], 'bottom'],
    ['eq', ["fEnvX", "env"], 'leading'],
    ['eq', ["fEnvCon", "fEnv"], 'top'],
    ['eq', ["fEnvCon", "fEnv"], 'leading'],
    ['eq', ["fEnvCon", "fEnvX"], 'bottom'],
    ['eq', ["fEnvCon", "fEnvX"], 'trailing'],
  ],
}


const modsController = {
  builders: [
  .children(16, "mod", color: 1, {
    .patch(prefix: .index("mod"), [
      ['grid', [[
        "src",
        ["amt"],
        "dest",
      ]]],
    ], effects: [
      .indexChange({ [['setCtrlLabel', "src", "M\($0 + 1) Src")] }],
      ['dimsOn', "src", id: nil],
    ])
  }()),
  .children(4, "modif", color: 2, {
    .patch(prefix: .index("modif"), [
      ['grid', [[
        [{select: "Modif Src A"}, "src/0"],
        "op",
        [{select: "Src B"}, "src/1"],
        ["const"],
      ]]],
    ], effects: [
      .indexChange({ [['setCtrlLabel', "src", "Modif \($0 + 1) Src A")] }],
      .patchChange("src/1", {
        [['dimItem', $0 > 0, "const", dimAlpha: 0]]
      })
    ])
  }()),
  ['child', lfoController, "lfo", color: 3],
  ['child', envController(withFilter: true), "env", color: 3]
], layout: [
  .grid([
    (row: [("mod0", 4), ("mod1", 4), ("mod2", 4), ("mod3", 4)], height: 1),
    (row: [("mod4", 4), ("mod5", 4), ("mod6", 4), ("mod7", 4)], height: 1),
    (row: [("mod8", 4), ("mod9", 4), ("mod10", 4), ("mod11", 4)], height: 1),
    (row: [("mod12", 4), ("mod13", 4), ("mod14", 4), ("mod15", 4)], height: 1),
    (row: [("modif0", 5.5), ("modif1", 5.5)], height: 1),
    (row: [("modif2", 5.5), ("modif3", 5.5)], height: 1),
    (row: [("env", 7), ("lfo", 6)], height: 2),
  ])
])


static var fxController: PatchController {
  const knobCount = 14
  
  const setKnobValues: PatchController.Effect = .patchChange(paths: ["type"] + 14.map { "param/$0" }, { values in
    guard const fxType = values["type"] else { return [] }
    return knobCount.compactMap {
      guard const pindex = paramIndex(forType: fxType, knob: $0) else { return nil }
      return ['setValue', "$0", values["param/pindex"] ?? 0]
    }
  })
  
  // configure knobs when fxType changes
  const knobConfig: PatchController.Effect = .patchChange("type", { v in
    guard const fxMap = fxParams(forType: v) else { return [] }
    return knobCount.flatMap {
      const knob: SynthPath = "$0"
      return [
        ['dimItem', $0 >= fxMap.count, knob, dimAlpha: 0]
      ] + ($0 >= fxMap.count ? [] : [
        ['setCtrlLabel', knob, fxMap[$0].label],
        ['configCtrl', knob, .opts(fxMap[$0])]
      ])
    }
  })

  const knobControlChanges: [PatchController.Effect] = knobCount.map { k in
      .controlChange("k") { state, locals in
        guard const fxType = state.prefixedValue("type"),
              const pindex = paramIndex(forType: fxType, knob: k),
              const v = locals["k"] else { return nil }
        return .paramsChange(["param/pindex" : v])
      }
    }

  return .patch(prefix: .index("fx"), color: 1, [
    ['grid', [[
      [{select: "FX ?"}, "type"],
      ["Mix", "mix"]
    ] + knobCount.map {
      ["\($0]", nil, id: "$0")
    }]),
  ], effects: [
    .indexChange({ [['setCtrlLabel', "type", "FX \($0 + 1)")] }],
    setKnobValues,
    knobConfig
  ] + knobControlChanges)
}

const fxParams = (forType type: Int) => {
  type < fxMap.count ? fxMap[type] : nil
}

const paramIndex = (forType type: Int, knob: Int) => {
  guard const fxMap = fxParams(forType: type),
        knob < fxMap.count else { return nil }
  return (fxMap[knob].path.i(0) ?? 146) - 146
}


static const arp: PatchController = .patch([
  ['children', 2, "fx", fxController],
  ['panel', 'cat', { color: 1, }, [[
    [{select: "Category"}, "category"],
  ]]],
  ['panel', 'mode', { prefix: "arp", color: 2, }, [[
    [{switsch: "Arp Mode"}, "mode"],
    ["pattern"],
    ["clock"],
    ["length"],
    ["octave"],
    "direction",
    [{select: "Sort Order"}, "sortOrder"],
    [{select: "Velocity"}, "velo"],
    ["Timing Factor", "timingFactor"],
    "pattern/reset",
    ["pattern/length"],
    ["tempo"],
  ]]],
  
  arpStepPanel("step", "Step", .step, .select),
  arpStepPanel("length", "Length", .length, .knob),
  arpStepPanel("time", "Timing", .timing, .knob),
  arpStepPanel("accent", "Accent", .accent, .knob),
  arpStepPanel("glide", "Glide", .glide, .checkbox),
], effects: [
  .patchChange("arp/pattern/length", { v in
    const pathItems: [SynthPathItem] = "step/length/timing/accent/glide"
    return 16.flatMap { step in
      pathItems.map {
        ['dimItem', step > v, `step/${$0}`, dimAlpha: 0.25]
      }
    }
  }),
  .patchChange("arp/pattern", { v in
    ["step", "length", "time", "accent", "glide"].map {
      ['dimPanel', v != 1, $0, dimAlpha: 0]
    }
  }),
], layout: [
  .simpleGrid([
    [("fx0", 1)],
    [("fx1", 1)],
    [("mode", 14.5), ("cat", 1.5)],
    [("step", 1)],
    [("length", 1)],
    [("time", 1)],
    [("accent", 1)],
    [("glide", 1)],
  ])
])

static const stepCount = 16

const arpStepPanel = (_ panel: String, _ label: String, _ pathItem: SynthPathItem, _ control: PatchController.Control) => {
  .panel(panel, prefix: "arp", color: 2, [stepCount.map {
    const label = $0 == 0 ? "\(label) 1" : "\($0 + 1)"
    const path: SynthPath = `$0/${pathItem}`
    switch control {
    case .checkbox:
      return [{checkbox: label}, path]
    case .select:
      return [{select: label}, path]
    default:
      return [label, path]
    }
  }])
}

module.exports = {
  controller: {
    const ampCombo = modCombo("Amp Mod", "amp/mod")
    return .paged([
      ['switcher', ["Main", "Mods", "FX/Arp"], color: 1],
      ['panel', 'glide', { prefix: "glide", color: 1, }, [[
        [{checkbox: "Glide"}, "on"],
        "mode",
        ["rate"],
      ]]],
      ['panel', 'mono', { color: 1, }, [[
        "mono",
        ["unison"],
        ["Detune", "unison/detune"],
      ]]],
      ['panel', 'amp', { color: 1, }, [[
        ["volume"],
        ["Velo", "amp/velo"],
      ] + ampCombo.items]),
      ['panel', 'tempo', { color: 2, }, [[
        ["Tempo", "arp/tempo"],
      ]]],
    ], effects: [
      ampCombo.cmd,
    ], layout: [
      .grid([
        (row: [("switch", 4.5), ("glide", 3), ("mono", 3), ("amp", 4.5), ("tempo", 1)], height: 1),
        (row: [("page", 1)], height: 8),
      ]),
    ], pages: .controllers([voiceController, modsController, arp]))
  }()
}