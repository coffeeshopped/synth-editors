const MophoVoicePatch = require('../patch/voicePatch.js')
const { ctrlr } = require('/core/Controller.js')
require('/core/NumberUtils.js')

function controller(vc) {
  vc.addChild(ctrlr(oscsController, syncPanel, true), "oscs")
  mainSetup(vc)

  vc.panel("knobs", [[
    [{ctrl: "select", l: "Knob 1" }, ["knob", 0]],
    [{ctrl: "select", l: "Knob 2" }, ["knob", 1]],
  ],[
    [{ctrl: "select", l: "Knob 3" }, ["knob", 2]],
    [{ctrl: "select", l: "Knob 4" }, ["knob", 3]],
  ]])
  
  vc.layRow([
    ["oscs",12], ["mods",4]
    ], {options: ["alignAllTop"], pinned: true})
  vc.layRow([
    ["fEnv", 7], ["aEnv",5]
    ], {pinned: false})
  vc.layRow([
    ["lfos",6], ["env3", 6.5], ["push", 3.5]
  ], {options: ["alignAllTop"], pinned: true})
  vc.layRow([
    ["knobs", 3], ["controls", 7]
  ], {pinned: false})

  vc.layCol([
    ["oscs",2],["fEnv",2],["lfos",4]
    ], {pinned: true})
  vc.layCol([
    ["env3",2],["knobs",2],
    ], {pinned: false})

  vc.layEqual(["aEnv","oscs"], "trailing")
  vc.layEqual(["aEnv","mods"], "bottom")
  vc.layEqual(["push","controls"], "trailing")
  vc.layEqual(["lfos","knobs"], "bottom")
  vc.layEqual(["env3","push"], "bottom")

  vc.colorPanels(["knobs"], {level: 2})
}

function syncPanel(vc) {
  vc.panel("sync", [[
    [{l: "Sync 2→1", ctrl: "checkbox"}, "sync"],
    [{l: "Slop"}, "slop"],
    [{l: "Bend"}, "bend"],
    [{l: "Key Assign Mode", ctrl: "select"}, "keyAssign"],
  ],[
    [{l: "Mix"}, "mix"],
    [{l: "Noise"}, "noise"],
    [{l: "Ext. A"}, "extAudio"],
    [{l: "Glide Mode", ctrl: "switch"}, "glide"],      
  ]])  
}

function mainSetup(vc) {
  vc.addChild(ctrlr(modsController), "mods")
  vc.addChild(ctrlr(controlsController), "controls")
  vc.addChild(ctrlr(lfosController), "lfos")

  vc.panel("fEnv", [[
    [{l: "Filter (Env 2)", ctrl: "dadsrEnv", id: "fEnv"}, null],
    [{l: "Env Amt"}, "filter/env/amt"],
    [{l: "Velo"}, "filter/env/velo"],
    [{l: "Cutoff"}, "cutoff"],
    [{l: "Reson"}, "reson"],
    [{l: "Aud Mod"}, "filter/extAudio"],
    ],[
    [{l: "Delay"}, "filter/env/delay"],
    [{l: "Attack"}, "filter/env/attack"],
    [{l: "Decay"}, "filter/env/decay"],
    [{l: "Sustain"}, "filter/env/sustain"],
    [{l: "Release"}, "filter/env/release"],
    [{l: "4-pole", ctrl: "checkbox"}, "filter/fourPole"],
    [{l: "Key Trk"}, "filter/keyTrk"],
    ]])
  envController(vc, "fEnv", "filter/env/")
  
  vc.panel("aEnv", [[
    [{l: "Amp (Env 1)", ctrl: "dadsrEnv", id: "aEnv"}, null],
    [{l: "Env Amt"}, "amp/env/amt"],
    [{l: "Velo"}, "amp/env/velo"],
    [{l: "Level"}, "amp/level"],
  ],[
    [{l: "Delay"}, "amp/env/delay"],
    [{l: "Attack"}, "amp/env/attack"],
    [{l: "Decay"}, "amp/env/decay"],
    [{l: "Sustain"}, "amp/env/sustain"],
    [{l: "Release"}, "amp/env/release"],
  ]])
  envController(vc, "aEnv", "amp/env/")
  
  vc.panel("env3", [[
    [{l: "Env 3", ctrl: "dadsrEnv", id: "env2"}, null],
    [{l: "Velo"}, "env/2/velo"],
    [{l: "Amount", id: "env3Amt"}, "env/2/amt"],
    [{l: "Destination", ctrl: "select"}, "env/2/dest"],
  ],[
    [{l: "Delay"}, "env/2/delay"],
    [{l: "Attack"}, "env/2/attack"],
    [{l: "Decay"}, "env/2/decay"],
    [{l: "Sustain"}, "env/2/sustain"],
    [{l: "Release"}, "env/2/release"],
    [{l: "Repeat", ctrl: "checkbox"}, "env/2/rrepeat"],
  ]])
  envController(vc, "env2", "env/2/")
  vc.dimsView("env3Amt", "env/2/dest")
  
  vc.panel("push", [[
    [{l: "Push It Note"}, "pushIt/note"],
    [{l: "Velocity"}, "pushIt/velo"],
  ],[
    [{l: "Switch Mode", ctrl: "switch"}, "pushIt/mode"],
  ]]) 
  
  vc.colorPanels(["fEnv", "aEnv", "uni"], {level: 1})
  vc.colorPanels(["knobs", "env3", "push"], {level: 2})   
}
  
function envController(vc, id, prefix) {
  
  let env = vc.get(id)
  
  vc.onPatchChange(prefix + "delay", v => env.config({delay: v / 127}))
  vc.onPatchChange(prefix + "attack", v => env.config({attack: v / 127}))
  vc.onPatchChange(prefix + "decay", v => env.config({decay: v / 127}))
  vc.onPatchChange(prefix + "sustain", v => env.config({sustain: v / 127}))
  vc.onPatchChange(prefix + "release", v => env.config({release: v / 127}))
  
  vc.registerForEditMenu(id, {
    paths: () => ["delay", "attack", "decay", "sustain", "release"].map(p => prefix + p),
    pasteboardType: "com.cfshpd.MophoEnvelope",
    initialize: () => [0, 0, 0, 127, 0],
    randomize: () => (5).map(() => (128).rand()),
  })
}
  
function oscsController(vc, syncPanelFn, waveReset) {
  vc.addChild(ctrlr(oscController, 0, waveReset), "osc0")
  vc.addChild(ctrlr(oscController, 1, waveReset), "osc1")
  syncPanelFn(vc)

  vc.layRow([
    ["osc0", 7.5], ["sync", 4.5],
    ], {options: ["alignAllTop"], pinned: true})
  vc.layCol([["osc0", 1], ["osc1", 1]], { options: ["alignAllLeading", "alignAllTrailing"], pinned: true })
  vc.layEqual(["osc1","sync"], "bottom")
  
  vc.colorAllPanels()
  vc.border()
}

function oscController(vc, index, waveReset) {
  vc.prefix(() => ["osc", index])

  let items = [
    [{l: "Oscillator "+(index + 1), ctrl: "switch", id: "wave"}, null],
    [{l: "PW", id: "pw"}, null],
    [{l: "Freq"}, "semitone"],
    [{l: "Fine"}, "detune"],
    [{l: "Glide"}, "glide"],
    [{l: "Key", ctrl: "checkbox"}, "keyTrk"],
    [{l: "Sub"}, "sub"],
  ]
  if (waveReset) {
    items.push([{l: "Reset", ctrl: "checkbox"}, ["reset"]])
  }
  vc.grid([items])

  let wave = vc.get("wave")
  wave.config({opts: MophoVoicePatch.waveOptions})
  let pw = vc.get("pw")
  pw.config({dispOff: -4, min: 4})
  
  vc.onCtrlChange(wave, "shape")
  vc.onCtrlChange(pw, "shape")
  
  vc.onPatchChange("shape", v => {
    wave.config({v: Math.min(v, 4)})
    pw.config({v: v, hide: v < 4})
  })

  vc.dims("shape")
}

function lfosController(vc) {
  vc.addChildren(4, "lfo", (index) => ctrlr(lfoController, index))

  vc.layGrid([
    [["lfo0", 1], ["lfo1", 1]],
    [["lfo2", 1], ["lfo3", 1]],
  ])
  vc.colorAllPanels({level: 3})
  vc.border({level: 3})
}

function lfoController(vc, index) {
  vc.prefix(() => ["lfo", index])

  vc.grid([[
    [{l: "LFO " +(index + 1), ctrl: "switch"}, "shape"],
    [{l: "Freq", id: "freqKnob"}, null],
    [{l: "Amount", id: "amt"}, "amt"],
    ],[
    [{l: "Sync", ctrl: "checkbox"}, "key/sync"],
    [{l: "Freq", ctrl: "select", id: "freqSelect"}, null],
    [{l: "Destination", ctrl: "select"}, "dest"],
    ]])
  
  let freqSelect = vc.get("freqSelect")
  freqSelect.config({opts: MophoVoicePatch.lfoFreqOptions})
  vc.onCtrlChange(freqSelect, "freq", () => freqSelect.v == 0 ? 75 : freqSelect.v + 150)

  let freqKnob = vc.get("freqKnob")
  freqKnob.config({max: 150})
  vc.onCtrlChange(freqKnob, "freq") // default
  
  vc.onPatchChange("freq", v => {
    freqKnob.config({hide: v > 150, v: v})
    freqKnob.v = v
    freqSelect.v = v < 151 ? 0 : v - 150
  })
  
  vc.dims("amt", ["dest"])  
}
  
function modsController(vc) {
  vc.addChildren(4, "mod", (index) => ctrlr(modController, index))

  vc.layGridCol(4, "mod", {pinMargin: ""})

  vc.colorAllPanels({level: 2})
  vc.border({level: 2})
}

function modController(vc, index) {
  vc.prefix(() => ["mod", index])
  vc.grid([[
    [{l: "Mod " + (index + 1) + " Src", ctrl: "select"}, ["src"]],
    [{l: "Amt"}, ["amt"]],
    [{l: "Destination", ctrl: "select"}, ["dest"]],
  ]], {})
  
  vc.onPatchChange([["src"], ["dest"]], values => {
    vc.dim(values["src"] == 0 || values["dest"] == 0)
  })
}

function controlsController(vc) {
  vc.addChild(ctrlr(ctrlController, "modWheel", "Mod Wheel"), "mod")
  vc.addChild(ctrlr(ctrlController, "pressure", "Pressure"), "press")
  vc.addChild(ctrlr(ctrlController, "breath", "Breath"), "breath")
  vc.addChild(ctrlr(ctrlController, "velo", "Velocity"), "velo")
  vc.addChild(ctrlr(ctrlController, "foot", "Foot"), "foot")
  
  vc.layGrid([
    [["mod", 1],["press", 1],["breath", 1],["velo", 1],["foot", 1]],
  ], {pinMargin: ""})
  
  vc.colorAllPanels({level: 2})
  vc.border({level: 2})
}


function ctrlController(vc, prefix, label) {
  vc.prefix(() => prefix)
  
  vc.grid([
    [
      [{ ctrl: "knob", l: label}, ["amt"]],
    ],[
      [{ ctrl: "select", l: "Dest"}, ["dest"]],
    ],
  ], {})
  
  vc.onPatchChange([["amt"], ["dest"]], values => {
    vc.dim(values["amt"] == 127 || values["dest"] == 0)
  })  
}

module.exports = () => ctrlr(controller)
