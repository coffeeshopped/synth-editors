
const osc = (prefix, label) => ({
  prefix: { fixed: prefix },
  gridBuilder: [[
    [{switch: label}, "wave"],
    [{switch: "Range"}, "octave"],
    ["Coarse", "coarse"],
    ["Fine", "fine"],
    ["Env Amt", "mod/env/pitch/amt"],
    ["LFO 1 Amt", "lfo/0/pitch/amt"],
    ["Mod Env→", "mod/env/pw/amt"],
    ["PW", 'pw'],
    ["←LFO 2", "lfo/1/pw/amt"],
  ]],
  effects: [
    ['patchChange', "wave", v => [
      ['dimItem', v == 3, "mod/env/pw/amt"],
      ['dimItem', v == 3, "pw"],
      ['dimItem', v == 3, "lfo/1/pw/amt"],
    ]],
  ]
})

const sub = {
  prefix: { fixed: 'sub' },
  gridBuilder: [[
    [{switch: "Sub Shape"}, "sub/wave"],
    [{switch: "Octave"}, "sub/octave"],
  ],[
    ["Coarse", "coarse"],
    ["Fine", "fine"],
  ]],
}

const env = (prefix, label) => ({
  prefix: { fixed: prefix }
  gridBuilder: [[
    {
      display: 'dadsrEnv',
      maps: [
        ['u', 'attack'],
        ['u', 'decay'],
        ['u', 'sustain'],
        ['u', 'release'],
      ],
      srcPrefix?: SynthPath,
      l: label,
      id: 'env',
    },
    [{switch: "Mode"}, "trigger"],
    [{checkbox: "Retrigger"}, "retrigger"],
    ["Retrig #", "retrigger/number"],
  ],[
    ["Attack", "attack"],
    ["Decay", "decay"],
    ["Sustain", "sustain"],
    ["Release", "release"],
    [{checkbox: "Fixed Dur"}, "fixed"],
    ["Velo", "velo"],
  ]],
  effects: [
    ['patchChange', "fixed", v => [
      ['dimItem', v != 0, 'retrigger'],
      ['setCtrlLabel', 'decay', v == 0 ? "Decay" : "Duration"]
    ]],
    ['patchChangePaths', ["fixed", "retrigger"]), values => {
      const fixed = values["fixed"]
      const r = values["retrigger"]
      return [
        ['dimItem', fixed != 0 || r != 1, 'retrigger/number']
      ]
    }],
    {
      'editMenu': 'env',
      paths: ["attack", "decay", "sustain", "release"],
      type: "BSIIEnv",
      init: [0, 0, 127, 0],
      // rand: { (0..<4).map { _ in (0...127).random()! } }
    },
  ]
})

const lfo = {
  index: 'lfo',
  labelItem: 'wave',
  text: i => `LFO ${i+1}`,
  gridBuilder: [[
    [{switch: "LFO \(index + 1)"}, "wave"],
    ["Delay", "delay"],
    [{knob: 'Speed', id: 'rate'}, null],
    ],[
    [{checkbox: "Key Sync"}, "key/sync"],
    ["Slew", "slew"],
    [{switch: "Mode"}, "time/sync"],
  ]],
  effects: [
    ["patchChange", 'time/sync', v => {
      const sync = v > 0
      return [
        ['setLabel', 'rate', sync ? 'Sync' : 'Speed'],
        // TODO: This should configure the control for the local path
        // config, add patchchangeblock and ccblock
        ['remapLocal', 'rate', sync ? 'sync' : 'speed'],
      ]
    }],
  ],
}

const ctrlr = {
  builders: [
    ['child', osc("osc/0, "Osc 1"), "osc0"],
    ['child', osc("osc/1", "Osc 2"), "osc1"],
    ['child', osc("sub", "Osc 3"), "osc2"],
    ['child', sub, "sub"],
    ['children', 2, 'lfo', lfo],
    ['child', env("mod/env", "Mod"), "mod"],
    ['child', env("amp/env", "Amp"), "amp"],
    ['panel', 'mix', { }, [[
      ["Osc 1", "osc/0/level"],
      ["Noise", "noise/level"],
      ],[
      ["Osc 2", "osc/1/level"],
      ["Ring", "ringMod/level"],
      ],[
      ["Sub", "sub/level"],
      ["Ext", "ext/level"],
    ]]],
    { 
      panel: 'afx',
      rows: [[
        [{switch: "Sub Mode"}, "sub/mode"],
        ["Overlay", "extra"],
      ]],
    },
    { 
      panel: 'para',
      rows: [[
        [{checkbox: "Paraphonic"}, "paraphonic"],
        ["Glide", "porta"],
        ["Divergence", "glide/split"],
        ["Bend", "bend"],
        ["Osc Error", "osc/slop"],
        [{checkbox: "Osc Sync"}, "sync"],
      ]],
    },
    {
      panel: 'filter',
      color: 2,
      prefix: 'filter',
      rows: [[
        [{switch: "Filter Type"}, "type"],
        [{switch: "Shape"}, "shape"],
        [{switch: "Slope"}, "slop"],
        ["Cutoff", "cutoff"],
        ["Reson", "reson"],
        ["Overdrive", "drive"],
        [{select: "Track"}, "trk"],
        ["Env Amt", "mod/env/cutoff/amt"],
        ["LFO2 Amt", "lfo/1/cutoff/amt"],
      ]],
    },
    {
      panel: 'fx',
      color: 2,
      rows: [[
        ["Distortion", "dist"],
        ["Osc Filter Mod", "osc/filter/mod"],
      ],[
        ["Limiter", "limiter"],
        ["MicroTune", "micro/tune"],
      ]],
    },
    {
      panel: 'wheel',
      rows: [[
        ["LFO1>Pitch", "mod/lfo/0/pitch"],
        ["LFO2>Cutoff", "mod/lfo/1/filter/cutoff"],
        ["Cutoff", "mod/filter/cutoff"],
        ["Osc2 Pitch", "mod/osc/1/pitch"],
      ],[
        { l: 'Mod Wheel', w: 1 },
      ]],
    },
    {
      panel: 'after',
      rows: [[
        ["LFO1>Pitch", "aftertouch/lfo/0/pitch"],
        ["LFO2 Speed", "aftertouch/lfo/1/speed"],
        ["Cutoff", "aftertouch/filter/cutoff"],
      ],[
        { l: 'Aftertouch', w: 1 },
      ]],
    },
    {
      panel: 'arp',
      prefix: 'arp',
      rows: [[
        [{checkbox: "Arp"}, "on"],
        ("Rhythm", "rhythm"),
        ],[
        ({switch: "Octave"}, "octave"),
        ("Swing", "swing"),
        ],[
        ({select: "Note Mode"}, "note/mode"),
        ],[
        ({checkbox: "Latch"}, "latch"),
        ({checkbox: "Retrig"}, "seq/retrigger"),
      ]],
    }
  ],
  effects: [
    ['patchChange', "filter/type", v => [
      ['dimItem', v > 0, 'filter/shape'],
      ['dimItem', v > 0, 'filter/slop'],
    ]],
    ['patchChange', "arp/on", v => [
      ['dimItem', v != 1, 'arp/rhythm'],      
      ['dimItem', v != 1, 'arp/octave'],      
      ['dimItem', v != 1, 'arp/swing'],      
      ['dimItem', v != 1, 'arp/note/mode'],      
      ['dimItem', v != 1, 'arp/latch'],      
      ['dimItem', v != 1, 'arp/seq/retrigger'],      
    ]],
    ['patchChange', "sub/mode", v => [
      ['dimPanel', v != 1, "osc2"],
      ['dimPanel', v != 0, "sub"],
    ]],
  ],
  layout: [
    ['row', [["mix", 2], ["osc0", 9], ["sub", 2]], {opts: ["alignAllTop"] }],
    ['row', [["filter", 9], ["para", 6]]],
    ['row', [["mod", 6], ["amp", 6], ["fx", 2], ["arp", 2]], {opts: ["alignAllTop"]}],
    ['rowPart', [["lfo0", 3], ["lfo1", 3], ["wheel", 4], ["after", 3]]],
    ['col', [["mix", 3], ["filter", 1], ["mod", 2], ["lfo0", 2]]],
    ['colPart', [["osc0", 1], ["osc1", 1], ["osc2", 1]], {opts: ["alignAllLeading", "alignAllTrailing"]}],
    ['colPart', [["sub", 2], ["afx", 1]], {opts: ["alignAllLeading", "alignAllTrailing"]}]
    ['eq', ["fx", "after"], 'trailing'],
    ['eq', ["mix", "osc2", "afx"], 'bottom'],
    ['eq', ["mod", "amp", "fx"], 'bottom'],
    ['eq', ["after", "arp"], 'bottom'],
  ]
}

  // addColor(panels: ["mod", "amp", "lfo0", "lfo1", "wheel", "after", "arp"], level: 3)