

const modCombo = (label, pre) => ({
  items: [
    [label, [pre, "amt"]],
    `← ${label} Src`, [pre, "src"]],
  ],
  cmd: ['patchChange', {
    paths: [pre + "amt", pre + "src"], 
    fn: values => {
      guard let src = values[pre + "src"],
            let amt = values[pre + "amt"] else { return [] }
      let off = src == 0 || amt == 64
      return [
        ['dimItem', off, pre + "amt"],
        ['dimItem', off, pre + "src"],
      ]
    }
  }],
})

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
  const pwm = modCombo("PWM", "pw")
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
        pwm.items
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
    ],
  }
}

const filterController = {
  let cutoff = modCombo("Cutoff Mod", "cutoff")
  let fm = fmCombo()
  let pan = modCombo("Pan Mod", "pan")

  return ['index', "filter", "type", i => { "Filter \($0+1)" }, [
    ['grid', [[
      [{select: "Filter"}, "type"],
      ["cutoff"],
      ["reson"],
      ["Env Amt", "env/amt"],
      ["Velocity", "velo"],
    ], cutoff.items + fm.items, [
      ["pan"],
    ] + pan.items + [
      ["drive"],
      ["Key Track", "keyTrk"],
    ]]],
  ], effects: [
    cutoff.cmd,
    fm.cmd,
    pan.cmd,
    ['dimsOn', "type"]
  ])
}

const envItem = (_ label: String?, prefix: SynthPath = [], _ id: SynthPath) => {
  let pathFn: PatchController.DisplayPathFn = { path, values in
    let mode = EnvelopeMode(rawValue: Int(values["mode"] ?? 0)) ?? .ADS1DS2R
    let attackLevel = values["attack/level"] ?? 0
    let attack = values["attack"] ?? 0
    let decay = values["decay"] ?? 0
    let sustain = values["sustain"] ?? 0
    let decay2 = values["decay2"] ?? 0
    let sustain2 = values["sustain2"] ?? 0
    let rrelease = values["release"] ?? 0

    let adsrStyle = mode == .ADSR || mode == .OneShot
    let segCount: CGFloat = {
      switch mode {
      case .ADSR, .LoopAll, .LoopS1S2: return 4
      case .ADS1DS2R: return 5
      case .OneShot: return 3
      }
    }()
    let segWidth = 1 / segCount
    var x: CGFloat = 0
    
    path.move(to: CGPoint(x: 0, y: 0))
    
    // attack
    x += attack * segWidth
    path.addLine(to: CGPoint(x: x, y: adsrStyle ? 1 : attackLevel))
    
    // decay
    x += decay * segWidth
    path.addCurve(to: CGPoint(x: x, y: sustain))

    if mode == .ADSR {
      // sustain1
      x += segWidth
      path.addLine(to: CGPoint(x: x, y: sustain))
    }
    
    if !adsrStyle {
      // s1 to s2
      x += decay2 * segWidth
      path.addLine(to: CGPoint(x: x, y: sustain2))
    }
    
    if mode == .ADS1DS2R {
      // sustain2
      x += segWidth
      path.addLine(to: CGPoint(x: x, y: sustain2))
    }
    
    // release
    x += rrelease * segWidth
    let rWeight = mode == .OneShot ? 0.5 : 0
    path.addCurve(to: CGPoint(x: x, y: 0), weight: rWeight)      
  }
  
  let maps: [PatchController.DisplayMap] = [
    .ident("mode"),
    .unit("attack/level"),
    .unit("attack"),
    .unit("decay"),
    .unit("sustain"),
    .unit("decay2"),
    .unit("sustain2"),
    .unit("release"),
  ]
  
  let item: PatchController.PanelItem = .display(.env(pathFn), label, maps.map { $0.srcPrefix(prefix) }, id: id)
  
  let paths: [SynthPath] = ["mode", "attack", "attack/level", "decay", "sustain", "decay2", "sustain2", "release"].map { prefix + $0 }
  let cmd: PatchController.Effect = ['editMenu', id, paths: paths, type: "MicroQEnvelope", init: [0, 0, 64, 0, 127, 64, 64, 0], rand: { [5.rand()] + 7.map { 128.rand() } }]
  
  return (item, cmd)
}

const envController = (withFilter: Bool = false) => {
  
  let items = (withFilter ? ["Filter"] : []) + ["Amp","3","4"]
  let knobs = envControllerSetup()
      
  let labels = (withFilter ? ["Filter"] : []) + ["Amp", "Env 3", "Env 4"]
  let env = envItem(nil, "env")
  return .patch(prefix: .indexFn({ "env/$0 + (withFilter ? 0 : 1)" }), [
    .grid([
      knobs.items, [
        ['switcher', label: "Envelope", items, width: withFilter ? 7 : 5],
        [{select: "Mode"}, "mode"],
        env.0,
        [{switsch: "Trigger"}, "trigger"],
    ]]],
  ], effects: [
    knobs.cmd,
    env.1,
    .indexChange({
      [['setCtrlLabel', "env", labels[$0 % labels.count]]]
    })
  ])

}

const envControllerSetup = (prefix: SynthPath = []) => {
  return (
    items: [
      ["AL", "attack/level"], // 0
      ["A", "attack"], // 1
      ["D1", "decay"], // 2
      ["S1", "sustain"], // 3
      ["D2", "decay2"], // 4
      ["S2", "sustain2"], // 5
      ["R", "release"], // 6
    ],
    cmd: .patchChange(prefix + "mode", {
      let hideSome = [0, 2].contains($0) // 0,2==adsr
      return [
        ['setCtrlLabel', "decay", hideSome ? "D" : "D1"],
        ['setCtrlLabel', "sustain", hideSome ? "S" : "S1"],
        ['dimItem', hideSome, "attack/level", dimAlpha: 0],
        ['dimItem', hideSome, "decay2", dimAlpha: 0],
        ['dimItem', hideSome, "sustain2", dimAlpha: 0],
      ]
    })
  )
}

static let lfoController: PatchController = .patch(prefix: .index("lfo"), [
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
], effects: [
  .indexChange({
    [['setCtrlLabel', "shape", "LFO \($0 + 1)"]]
  }),
  .patchChange("clock", {
    [['configCtrl', "speed", .opts(ParamOptions(isoS: $0 == 0 ? nil :lfoRateIso))]]
  }),
  ['dimsOn', "sync", id: "phase"]
])


const voiceController = {
  let pitch = modCombo("Pitch Mod", "pitch")
  
  let knobs = envControllerSetup(prefix: "env/0")

  let env = envItem("Filter", prefix: "env/0", "env/0")
  builders: [
    // add before fEnv panels so it's in the back.
    ['panel', 'fEnvCon', { color: 2, }, [[]]],
    ['child', oscController(0), "osc0", color: 1],
    ['child', oscController(1), "osc1", color: 1],
    ['child', oscController(2), "osc2", color: 1],
    ['children', 2, "filter", color: 2, filterController],
    ['child', envController(), "env", color: 3],
    ['child', lfoController, "lfo", color: 3],
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
    .panel("pitch", color: 1, [pitch.items]),
    ['panel', 'route', { color: 2, }, [[
      [{switsch: "Routing"}, "filter/routing"],
    ]]],
    ['panel', 'fEnv', { prefix: "env/0", color: 2, }, [[
      knobs.items[1],
      knobs.items[2],
      knobs.items[3],
    ],[
      knobs.items[0],
      [{switsch: "Trigger"}, "trigger"],
      knobs.items[6],
    ],[
      [{select: "Mode"}, "mode"],
      env.0,
    ]]],
    ['panel', 'fEnvX', { prefix: "env/0", color: 2, }, [[
      knobs.items[4],
      knobs.items[5],
    ]]],
  ], 
  effects: [
    knobs.cmd,
    env.1,
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



static let modsController: PatchController = .patch([
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
  let knobCount = 14
  
  let setKnobValues: PatchController.Effect = .patchChange(paths: ["type"] + 14.map { "param/$0" }, { values in
    guard let fxType = values["type"] else { return [] }
    return knobCount.compactMap {
      guard let pindex = paramIndex(forType: fxType, knob: $0) else { return nil }
      return ['setValue', "$0", values["param/pindex"] ?? 0]
    }
  })
  
  // configure knobs when fxType changes
  let knobConfig: PatchController.Effect = .patchChange("type", { v in
    guard let fxMap = fxParams(forType: v) else { return [] }
    return knobCount.flatMap {
      let knob: SynthPath = "$0"
      return [
        ['dimItem', $0 >= fxMap.count, knob, dimAlpha: 0]
      ] + ($0 >= fxMap.count ? [] : [
        ['setCtrlLabel', knob, fxMap[$0].label],
        ['configCtrl', knob, .opts(fxMap[$0])]
      ])
    }
  })

  let knobControlChanges: [PatchController.Effect] = knobCount.map { k in
      .controlChange("k") { state, locals in
        guard let fxType = state.prefixedValue("type"),
              let pindex = paramIndex(forType: fxType, knob: k),
              let v = locals["k"] else { return nil }
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
  guard let fxMap = fxParams(forType: type),
        knob < fxMap.count else { return nil }
  return (fxMap[knob].path.i(0) ?? 146) - 146
}


static let arp: PatchController = .patch([
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
    let pathItems: [SynthPathItem] = "step/length/timing/accent/glide"
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

static let stepCount = 16

const arpStepPanel = (_ panel: String, _ label: String, _ pathItem: SynthPathItem, _ control: PatchController.Control) => {
  .panel(panel, prefix: "arp", color: 2, [stepCount.map {
    let label = $0 == 0 ? "\(label) 1" : "\($0 + 1)"
    let path: SynthPath = `$0/${pathItem}`
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
    let ampCombo = modCombo("Amp Mod", "amp/mod")
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