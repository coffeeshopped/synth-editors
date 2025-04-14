
const common = perf => ({
  prefix: {fixed: "common"}, 
  color: 1, 
  builders: [
    ['panel', 'velo', { }, [[
      [{checkbox: "Velo"}, "velo"],
      ["Analog Feel", "analogFeel"],
      ["Level", "level"],
      ["Pan", "pan"],
      ["Bend Down", "bend/down"],
      ["Bend Up", "bend/up"],
      [{checkbox: "Mono"}, "mono"],
      [{checkbox: "Legato"}, "legato"],
      ]]],
    ['panel', 'reverb', { }, [[
      [{select: "Reverb"}, "reverb/type"],
      ["Level", "reverb/level"],
      ["Time", "reverb/time"],
      ["Feedback", "reverb/feedback"],
      ]]],
    ['panel', 'porta', { }, [[
      [{checkbox: "Porta"}, "porta"],
      [{switsch: "Mode"}, "porta/legato"],
      [{switsch: "Type"}, "porta/type"],
      ["Time", "porta/time"],
      ]]],
    ['panel', 'chorus', { }, [[
      [{switsch: "Chorus"}, "chorus/type"],
      ["Level", "chorus/level"],
      ["Depth", "chorus/depth"],
      ["Rate", "chorus/rate"],
      ["Feedback", "chorus/feedback"],
      [{switsch: "Output"}, "chorus/out/assign"],
      ]]],
  ], 
  effects: perf ? [
    ['setup', [
      ['dimPanel', true, "chorus"],
      ['dimPanel', true, "reverb"],
    ]]
  ] : [], 
  layout: [
    ['row', [["velo",1]]],
    ['row', [["reverb",4.5], ["porta", 4]]],
    ['row', [["chorus",1]]],
    ['col', [["velo",1], ["reverb",1], ["chorus",1]]],
  ])
})


const wave = {
  color: 1, 
  builders: [
    ['grid', [[
      [{switsch: "Group"}, "wave/group"],
      "Wave", nil, id: "wave/number",
      ]]]
  ], 
  effects: [
    ['basicPatchChange', "wave/number"],
    ['basicControlChange', "wave/number"],
    .patchSelector(id: "wave/number", bankValues: ["wave/group"]) { values, state, locals in
      let group = values["wave/group"] ?? 0
      let options: [Int:String]
      switch group {
      case 0:
        options = JV80.Voice.Tone.waveOptions
      case 1:
        let internalCard = (state.params["pcm"] as? RangeParam)?.parm ?? 0
        let card = SRJVBoard.boards[internalCard] ?? SRJVBoard.pop
        options = OptionsParam.makeOptions(card.waves)
      default:
        options = JV80.Voice.Tone.blankWaveOptions
      }
      return .opts(ParamOptions(opts: options))
    }
  ],
}

const env = (label, pre, bipolar) => ({
  menu: ['editMenu', "env", {
    paths: ([]).concat(
      (4).map(i => [pre, 'time', i]),
      (4).map(i => [pre, 'level', i])
    ), 
    type: "JV880RateLevelEnvelope",
  }],
  env: {
    display: 'timeLevelEnv',
    pointCount: 4, 
    sustain: 2, 
    bipolar: bipolar
    l: label, 
    maps: ([]).concat(
      (4).map(i => ['u', ["time", i]),
      (4).map(i => bipolar 
        ? ['src', ["level", i], v => (v - 63) / 63] 
        : ['u', ["level", i]])
    ), 
    srcPrefix: pre,
    id: "env",
  }
})

const pitchEnv = env("Pitch", "pitch/env", true)
const filterEnv = env("Filter", "filter/env", false)
const ampEnv = env("Amp", "amp/env", false)

const pitch = {
  builders: [
    ['grid', [[
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Random Pitch", "random/pitch"],
      ["Key→Pitch", "pitch/keyTrk"],
    ],[
      pitchEnv.env,
      ["Env Depth", "pitch/env/depth"],
      ["Key→Env T", "pitch/env/time/keyTrk"],
      ["Velo→Env", "pitch/env/velo/sens"],
    ],
    (4).map(i => [`T${i+1}`, ["pitch/env/time", i]]).concat([
      ["Velo→T1", "pitch/env/velo/time/0"],
    ]),
    (4).map(i => [`L${i+1}`, ["pitch/env/level", i]]).concat([
      ["Velo→T4", "pitch/env/velo/time/3"],      
    ])
    ]]
  ], 
  effects: [pitchEnv.menu],
}

const filter = {
  builders: [
    ['grid', [[
      [{switsch: "Filter"}, "filter/type"],
      ["Cutoff", "cutoff"],
      ["Reson", "reson"],
      [{switsch: "Reson Mode"}, "reson/mode"],
      ["Key→Cutoff", "cutoff/keyTrk"],
    ],[
      filterEnv.env,
      ["Env Depth", "filter/env/depth"],
      ["Key→Env T", "filter/env/time/keyTrk"],
      ["Velo→Env", "filter/env/velo/sens"],
      ["Velo Crv", "filter/env/velo/curve"],
    ],
    (4).map(i => [`T${i+1}`, ["filter/env/time", i]]).concat([
      ["Velo→T1", "filter/env/velo/time/0"],
    ]),
    (4).map(i => [`L${i+1}`, ["filter/env/level", i]]).concat([
      ["Velo→T4", "filter/env/velo/time/3"],      
    ])
    ]]
  ], 
  effects: [
    filterEnv.menu,
    ['dimsOn', "filter/type"],
  ],
}

const amp = {
  gridBuilder: [[
    ["Level", "tone/level"],
    ["Key→Level", "bias/level"],
    [{knob: "Pan", id: "pan"}, null],
    [{knob: "Random Pan", id: "random/pan" }, null],
    ["Key→Pan", "pan/keyTrk"],
  ],[
    ampEnv.env,
    ["Key→Env T", "amp/env/time/keyTrk"],
    ["Velo→Env", "amp/env/velo/sens"],
    ["Velo Crv", "amp/env/velo/curve"],
  ],
  (4).map(i => [`T${i+1}`, ["amp/env/time", i]]).concat([
    ["Velo→T1", "amp/env/velo/time/0"],
  ]),
  (3).map(i => [`L${i+1}`, ["amp/env/level", i]]).concat([
    ["Velo→T4", "amp/env/velo/time/3"],      
  ])
  ], 
  effects: [
    .patchChange("pan", {
      var changes: [PatchController.AttrChange] = [
        ['dimItem', $0 == 128, "pan", dimAlpha: 0],
        ['setValue', "random/pan", $0 == 128 ? 1 : 0],
      ]
      if $0 < 128 {
        changes.append(['setValue', "pan", $0)]
      }
      return changes
    }),
    ['basicControlChange', "pan"],
    .controlChange("random/pan", { state, locals in
      let rp = locals["random/pan"] ?? 0
      let p = locals["pan"] ?? 0
      return ["pan" : rp == 1 ? 128 : p]
    }),
    ampEnv.menu
  ],
}
      
const lfo = ['index', "lfo", "wave", i => `LFO ${i + 1}`, {
  builders: [
    ['grid', [[
      [{select: "LFO"}, "wave"],
      [{switsch: "Offset"}, "level/offset"],
      [{checkbox: "Sync"}, "key/trigger"],
      ["Rate", "rate"],
      ["Delay", "delay"],
      [{switsch: "Fade"}, "fade/mode"],
      ["Fade Time", "fade/time"],
      ["Pitch", "pitch"],
      ["Filter", "filter"],
      ["Amp", "amp"],
    ]]]
  ],
}]

const toneCtrl = {
  prefix: {select: ["mod", "aftertouch", "expression"]}, 
  builders: [
    ['grid', [[
      ['switcher', ["Mod","Aftertouch","Expression"]],
    ], [
      [{select: "Dest 1"}, "dest/0"],
      ["Amt 1", "depth/0"],
      [{select: "Dest 2"}, "dest/1"],
      ["Amt 2", "depth/1"],
    ], [
      [{select: "Dest 3"}, "dest/2"],
      ["Amt 3", "depth/2"],
      [{select: "Dest 4"}, "dest/3"],
      ["Amt 4", "depth/3"],
    ]]]
  ],
}

const tone = hideOut => ({
  prefix: {index: "tone"}, 
  builders: [
    ['child', wave, "wave", {color: 1}],
    ['child', pitch, "pitch", {color: 1}],
    ['child', filter, "filter", {color: 2}],
    ['child', amp, "amp", {color: 1}],
    ['children', 2, "lfo", {color: 1}, lfo],
    ['child', toneCtrl, "ctrl", {color: 1}],
    ['panel', 'fxm', { color: 1, }, [[
      [{checkbox: "FXM"}, "fxm/on"],
      ["Depth", "fxm/depth"],
    ]]],
    ['panel', 'range', { color: 1 }, [[
      ["Velo Lo", "velo/range/lo"],
      ["Velo Hi", "velo/range/hi"],
    ]]],
    ['panel', 'volume', { color: 1 }, [[
      [{checkbox: "Volume"}, "volume/ctrl"],
      [{checkbox: "Hold"}, "hold/ctrl"],
    ]]],
    ['panel', 'delay', { color: 1 }, [[
      [{switsch: "Delay Mode"}, "delay/mode"],
      ["Time", "delay/time"],
    ]]],
    ['panel', 'outs', { color: 1 }, [[
      ["Dry", "out/level"],
      ["Reverb", "reverb"],
      ["Chorus", "chorus"],
      [{switsch: "Output"}, "out/assign"],
    ]]],
    ['button', "Tone", {color: 1}],
    ['panel', 'space', { }, [[]]],
  ], 
  effects: [
    ['editMenu', "button", {
      paths: Voice.Tone.patchWerk.truss.paramKeys(), 
      type: "JV880Tone",
    }],
    .setup([
      ['hideItem', hideOut, "out/assign"],
    ]),
    ['dimsOn', "on"],
  ], 
  layout: [
    ['row', [["wave",2.5], ["fxm", 2], ["range", 2], ["volume", 2], ["delay", 2], ["outs", 4], ["button", 2]]],
    ['row', [["pitch",5], ["filter", 6], ["amp", 5]]],
    ['row', [["lfo0",11], ["ctrl", 5]], { opts: ['alignAllTop'] }],
    ['col', [["wave",1], ["pitch",4], ["lfo0",1], ["lfo1",1], ["space",1]]],
    ['eq', ["lfo0","lfo1","space"], 'trailing'],
    ['eq', ["ctrl","space"], 'bottom'],
  ])
})

// MARK: Palette

const palettePitch = {
  color: 1, 
  builders: [
    ['grid', [[
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Random Amt", "random/pitch"],
      ["Key→Pitch", "pitch/keyTrk"],
    ],[
      pitchEnv.env,
      ["Env→Pitch", "pitch/env/depth"],
      ["Key→Env T", "pitch/env/time/keyTrk"],
    ],
    (4).map(i => [`T${i+1}`, ["pitch/env/time", i]]),
    (4).map(i => [`L${i+1}`, ["pitch/env/level", i]]),
    [
      ["Velo→Env", "pitch/env/velo/sens"],
      ["Velo→T1", "pitch/env/velo/time/0"],
      ["Velo→T4", "pitch/env/velo/time/3"],
    ],[
      ["LFO 1", "lfo/0/pitch"],
      ["LFO 2", "lfo/1/pitch"],
    ]]]
  ], 
  effects: [pitchEnv.menu],
}

const palettePitchWave = {
  color: 1, 
  builders: [
    ['child', wave, "wave"],
    ['child', palettePitch, "pitch"],
  ], 
  layout: [
    .grid([
      (row: [(key: "wave", width: 1)], height: 1),
      (row: [(key: "pitch", width: 1)], height: 6),
    ])
  ])
}


const paletteFilter = {
  color: 1, 
  builders: [
    ['grid', [[
      [{switsch: "Filter"}, "filter/type"],
      ["Cutoff", "cutoff"],
      ["Reson", "reson"],
      [{switsch: "Reson Mode"}, "reson/mode"],
    ],[
      filterEnv.env,
      ["Env→Cutoff", "filter/env/depth"],
      ["Key→Env T", "filter/env/time/keyTrk"],
    ],
    (4).map(i => [`T${i+1}`, ["filter/env/time", i]]),
    (4).map(i => [`L${i+1}`, ["filter/env/level", i]]),
    [
      ["Velo→Env", "filter/env/velo/sens"],
      ["Velo→T1", "filter/env/velo/time/0"],
      ["Velo→T4", "filter/env/velo/time/3"],
    ],[
      ["Key→Cutoff", "cutoff/keyTrk"],
      ["Env Velo Crv", "filter/env/velo/curve"],
    ],[
      ["LFO 1", "lfo/0/filter"],
      ["LFO 2", "lfo/1/filter"],
    ]]]
  ], 
  effects: [
    filterEnv.menu,
    ['dimsOn', "filter/type", id: nil],
  ],
}

const paletteAmp = {
  color: 1, 
  builders: [
    ['grid', [[
      ["Level", "tone/level"],
      ["Key→Level", "bias/level"],
    ],[
      ampEnv.env,
      ["Velo Crv", "amp/env/velo/curve"],
      ["Key→Env T", "amp/env/time/keyTrk"],
    ],
    (4).map(i => [`T${i+1}`, ["amp/env/time", i]]),
    [
      ["L1", "amp/env/level/0"],
      ["L2", "amp/env/level/1"],
      ["L3", "amp/env/level/2"],
      '-',
    ],[
      ["Velo→Env", "amp/env/velo/sens"],
      ["Velo→T1", "amp/env/velo/time/0"],
      ["Velo→T4", "amp/env/velo/time/3"],
    ],[
      [{knob: "Pan", id: "pan"}, null],
      [{knob: "Random Pan", id: "random/pan" }, null],
      ["Key→Pan", "pan/keyTrk"],
    ],[
      ["LFO 1", "lfo/0/amp"],
      ["LFO 2", "lfo/1/amp"],
    ]]]
  ], 
  effects: ampEffects,
}

const paletteLFO = {
  color: 1, 
  builders: [
    ['children', 2, "vc", ['index', "lfo", "wave", i => `LFO ${i + 1}`, {
      builders: [
        ['grid', [[
          [{select: "LFO"}, "wave"],
          ["Rate", "rate"],
          [{checkbox: "Sync"}, "key/trigger"],
        ],[
          ["Delay", "delay"],
          [{switsch: "Fade"}, "fade/mode"],
          ["Fade Time", "fade/time"],
          [{switsch: "Offset"}, "level/offset"],
        ],[
          ["Pitch", "pitch"],
          ["Filter", "filter"],
          ["Amp", "amp"],
        ]]]
      ],
    }]],
  ], 
  layout: [
    ['simpleGrid', [[("vc0", 1)], [("vc1", 1)]]],
  ],
}

const paletteOther = hideOut => ({
  color: 1, 
  builders: [
    ['panel', 'fxm', { }, [[
      [{checkbox: "FXM"}, "fxm/on"],
      ["Depth", "fxm/depth"],
    ]]],
    ['panel', 'range', { }, [[
      ["Velo Lo", "velo/range/lo"],
      ["Velo Hi", "velo/range/hi"],
    ]]],
    ['panel', 'volume', { }, [[
      [{checkbox: "Volume"}, "volume/ctrl"],
      [{checkbox: "Hold"}, "hold/ctrl"],
    ]]],
    ['panel', 'delay', { }, [[
      [{switsch: "Delay Mode"}, "delay/mode"],
      ["Time", "delay/time"],
    ]]],
    ['panel', 'outs', { }, [[
      ["Dry", "out/level"],
      ["Reverb", "reverb"],
      ["Chorus", "chorus"],
      [{switsch: "Output"}, "out/assign"],
    ]]],
    ['panel', 'mod', { }, [[
      [{select: "Mod Dest 1"}, "mod/dest/0"],
      ["Amt", "mod/depth/0"],
      [{select: "Mod Dest 2"}, "mod/dest/1"],
      ["Amt", "mod/depth/1"],
    ]]],
    ['panel', 'after', { }, [[
      [{select: "After Dest 1"}, "aftertouch/dest/0"],
      ["Amt", "aftertouch/depth/0"],
      [{select: "After Dest 2"}, "aftertouch/dest/1"],
      ["Amt", "aftertouch/depth/1"],
    ]]],
    ['panel', 'expr', { }, [[
      [{select: "Expr Dest 1"}, "expression/dest/0"],
      ["Amt", "expression/depth/0"],
      [{select: "Expr Dest 2"}, "expression/dest/1"],
      ["Amt", "expression/depth/1"],
    ]]],
  ], 
  effects: [
    ['setup', [
      ['hideItem', hideOut, "out/assign"],
    ]],
  ], 
  simpleGridLayout: [
    [["fxm", 2], ["range", 2]],
    [["volume", 2], ["delay", 2]],
    [["outs", 4]],
    [["mod", 4]],
    [["after", 4]],
    [["expr", 4]],
  ],
})

const fourPalettes = (pasteType, pal) => 
  ['palettes', pal, 4, "tone", "Tone", pasteType]

const ctrlr = (perf, hideOut) => {
  builders: [
    ['switcher', ["Common","1","2","3","4", "Pitch", "Filter", "Amp", "LFO", "FX/Other"], {color: 1}],
    ['panel', 'on', { color: 1 }, [[
      [{checkbox: "1"}, "tone/0/on"],
      [{checkbox: "2"}, "tone/1/on"],
      [{checkbox: "3"}, "tone/2/on"],
      [{checkbox: "4"}, "tone/3/on"],
    ]]],
  ], 
  layout: [
    ['row', [["switch", 12], ["on", 4]]],
    ['row', [["page", 1]]],
    ['col', [["switch", 1], ["page", 8]]],
  ], 
  pages: ['map', (["common"]).concat(
    (4).map(i => ["tone", i]),
    ["pitch", "filter", "amp", "lfo", "extra"]
  ), [
    ["common", common(perf)],
    ["tone", tone(hideOut)],
    ["pitch", fourPalettes("JV8XPitch", palettePitchWave)],
    ["filter", fourPalettes("JV8XFilter", paletteFilter)],
    ["amp", fourPalettes("JV8XAmp", paletteAmp)],
    ["lfo", fourPalettes("JV8XLFO", paletteLFO)],
    ["extra", fourPalettes("JV8XExtra", paletteOther(hideOut))],
  ]]
}
