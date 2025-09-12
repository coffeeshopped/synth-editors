require('./utils.js')

const env = label => {
  const parts = ["delay", "attack", "decay", "sustain", "release"]
  return {
    display: 'dadsrEnv',
    l: label,
    maps: parts.map(part => ["u", part, 63]),
    id: "env"
  }
}

const envController = (label, index) => ({
  prefix: { fixed: ["env", index] },
  builders: [
    ["grid", [[
      env(label),
      ["Delay", "delay"],
      ["Attack", "attack"],
      ["Decay", "decay"],
      ["Sustain", "sustain"],
      ["Release", "release"],
    ],[
      ["Amp", "amp"],
      ["Velo", "velo"],
      ["Trigger Mode", "trigger/mode"],
      ["Mode", "mode"],
      ["LFO Trigger", "lfo/trigger/mode"],
    ]]]
  ], 
  effects: [
    ["editMenu", "env", {
      paths: ["delay", "attack", "decay", "sustain", "release"], 
      type: "Matrix6Envelope",
      init: [0, 0, 0, 63, 0],
    }],
  ],
})

const lfoEffects = [
  ['patchChange', 'wave', v => ['dimItem', v != 6, 'sample/src', 0]],
  ['patchChange', 'trigger', v => ['dimItem', v == 0, "retrigger/pt", 0]],
]

const lfo1 = {
  prefix: { fixed: ["lfo", 0] },
  builders: [
    ["grid", [[
      [{t: "select", l: "LFO 1"}, "wave"],
      ["Speed", "speed"],
      ["←Press", "speed/pressure/amt"],
      [{t: "select", l: "Sampled"}, "sample/src"],
      ],[
      ["Amp", "amp"],
      ["←Ramp1", "ramp/0/amt"],
      [{t: "switsch", l: "Trig Mode"}, ["trigger"]],
      ["Retrig Pt", "retrigger/pt"],
      [{t: "checkbox", l: "Lag"}, "lag"],
    ]]]
  ], 
  effects: lfoEffects,
}

const lfo2 = {
  type: 'patch',
  prefix: { fixed: ["lfo", 1] },
  builders: [
    ["grid", [[
      [{t: "select", l: "LFO 2"}, "wave"],
      ["Speed", "speed"],
      ["←Keybd", "speed/key/amt"],
      [{t: "select", l: "Sampled"}, "sample/src"],
      ],[
      ["Amp", "amp"],
      ["←Ramp2", "ramp/1/amt"],
      [{t: "switsch", l: "Trig Mode"}, ["trigger"]],
      ["Retrig Pt", "retrigger/pt"],
      [{t: "checkbox", l: "Lag"}, "lag"],
    ]]]
  ], 
  effects: lfoEffects,
}

const modParts = ["src", "amt", "dest"]
const modEffects = (10).map(mod => {
  const modPaths = modParts.map(part => ["mod", mod, part])
  return ['patchChange', {
    paths: modPaths,
    // values is an object (path => value)
    fn: values => {
      var active = false
      if (values) {
        vals = []
        for (let key in values) {
          vals.push(values[key])
        }
        active = vals.map(v => v != 0).reduce((a, b) => a && b, true)
      }
      return modPaths.map(p => ['dimItem', !active, p])
    }
  }]
})

let modItems = [
  { 
    row: [
      {l: "Mod Src", w: 3},
      {l: "Amt", w: 2},
      {l: "Dest", w: 3},
    ], 
    h: 0.5, 
  }
].concat((10).map((mod) => { 
  return { 
    row: [
      [{t: 'select', l: ""}, ["mod", mod, "src"]],
      ["", ["mod", mod, "amt"]],
      [{t: 'select', l: ""}, ["mod", mod, "dest"]],
    ], 
    h: 1,
  }
}))

module.exports = {
  builders: [
    ['child', envController("Env 1 (VCF Freq)", 0), "env0", { color: 2 }],
    ['child', envController("Env 2 (Amp)", 1), "env1", { color: 3 }],
    ['child', envController("Env 3 (VCF FM)", 2), "env2", { color: 1 }],
    ['child', lfo1, "lfo0", {color: 1}],
    ['child', lfo2, "lfo1", {color: 1}],
    ['panel', 'osc', {color: 1}, [[
      [{t: 'switsch', l: "DCO1"}, "osc/0/wave"],
      ["Freq", "osc/0/freq"],
      ["←LFO1", "osc/0/freq/lfo/0/amt"],
      ["PW", "osc/0/pw"],
      ["←LFO2", "osc/0/pw/lfo/1/amt"],
      ["Shape", "osc/0/shape"],
      [{t: 'switsch', l: "Fixed Mod"}, "osc/0/fixed/mod"],
      [{t: 'checkbox', l: "Click"}, "osc/0/click"],
      [{t: 'switsch', l: "Sync"}, "osc/sync"],
      [{t: 'checkbox', l: "Porta"}, "osc/0/porta"],
      '-',
      ],[
      [{t: 'switsch', l: "DCO2"}, "osc/1/wave"],
      ["Freq", "osc/1/freq"],
      ["←LFO1", "osc/1/freq/lfo/0/amt"],
      ["PW", "osc/1/pw"],
      ["←LFO2", "osc/1/pw/lfo/1/amt"],
      ["Shape", "osc/1/shape"],
      [{t: 'switsch', l: "Fixed Mod"}, "osc/1/fixed/mod"],
      [{t: 'checkbox', l: "Click"}, "osc/1/click"],
      ["Detune", "osc/1/detune"],
      [{t: 'switsch', l: "Keybd/Porta"}, "osc/1/porta"],
      ["Mix", "mix"],
    ]]],
    ['panel', 'track', {color: 1}, [[
      [{t: 'select', l: "Track Source"}, "trk/src"],
      ["1", "trk/pt/0"],
      ["2", "trk/pt/1"],
      ["3", "trk/pt/2"],
      ["4", "trk/pt/3"],
      ["5", "trk/pt/4"],
    ]]],
    ['panel', 'filter', {color: 2}, [[
      ["Cutoff", "cutoff"],
      ["←Env1", "cutoff/env/0/amt"],
      ["←Press", "cutoff/pressure/amt"],
      ["Reson", "reson"],
      [{t: 'switsch', l: "Fixed Mod"}, "filter/fixed/mod"],
    ],[
      [{t: 'switsch', l: "Keybd Mod"}, "filter/porta"],
      ["FM", "filter/fm"],
      ["←Env3", "filter/fm/env/2/amt"],
      ["←Press", "filter/fm/pressure/amt"],
    ]]],
    ['panel', 'vca', {color: 3}, [[
      ["VCA1", "amp/0/amt"],
      ["←Velo", "amp/0/velo/amt"],
      ["Env2→VCA2", "amp/1/env/1/amt"],
      [{t: 'switsch', l: "Keybd Mode"}, "key/mode"],
    ]]],
    ['panel', "mod", {color: 1}, modItems],
    ['panel', 'ramp0', {color: 1}, [[
      ["Ramp 1 Rate", "ramp/0/rate"],
      [{t: 'switsch', l: "Trigger"}, "ramp/0/mode"],
    ]]],
    ['panel', 'ramp1', {color: 1}, [[
      ["Ramp 2 Rate", "ramp/1/rate"],
      [{t: 'switsch', l: "Trigger"}, "ramp/1/mode"],
    ]]],
    ['panel', 'porta', {color: 1}, [[
      ["Porta Rate", "porta/rate"],
      ["←Velo", "porta/rate/velo/amt"],
      [{t: 'switsch', l: "Lag Mode"}, "lag/mode"],
      [{t: 'checkbox', l: "Legato"}, "porta/legato"],
    ]]],
  ], 
  effects: modEffects,
  layout: [
    ["row", [["osc",24],["porta",8]], {opts: ["alignAllTop"]}],
    ["rowPart", [["env0",15],["filter",10]], {opts: ["alignAllTop"]}],
    ["rowPart", [["ramp0",1],["ramp1",1]]],
    ["col", [["osc",2],["env0",2],["env1",2],["env2",2],["track",1]], {opts: ["alignAllLeading"]}],
    ["colPart", [["filter",2],["vca",1],["lfo0",2],["lfo1",2]], {opts: ["alignAllLeading"]}],
    ["col", [["porta",1], ["ramp0",1], ["mod",7]]],
    ["eq", ["osc","filter","vca","lfo0","lfo1"], "trailing"],
    ["eq", ["env0","env1","env2","track"], "trailing"],
    ["eq", ["mod", "ramp1", "porta"], "trailing"],
    ["eq", ["track","lfo1","mod"], "bottom"],
  ]
}