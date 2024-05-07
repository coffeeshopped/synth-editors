const { ctrlr } = require('/core/Controller.js')
const DX7VoicePatch = require('../patch/voice.js')
  
function initAmpMod(vc, ampModKnob) {
  // in DX7ii, this is stored in the "extra"
  vc.onDefaults(ampModKnob, "amp/mod")
}

function miniOpController(vc, index) {
  vc.index = index
  vc.prefix(vc => ["op", vc.index])
  
  vc.gridWithHeights([
    [[
      [{l: "?", ctrl: "label", id: "op", w: 1}, null],
      [{l: "?", ctrl: "label", id: "freq", w: 4}, null],
    ], 1],
    [[
      [{ctrl: "rateLevelEnv", id: "env"}, null],
    ], 3],
  ], {margin: 2, spacing: 2})
  
  const op = vc.get("op")
  op.config({align: "left", size: 11})
  vc.onIndexChange(i => op.config({l: (i + 1) + ""}))
  
  const freq = vc.get("freq")
  freq.config({align: "right", size: 11})

  vc.onPatchChangeAny(["osc/mode", "coarse", "fine", "detune"], v => {
    const fixedMode = v["osc/mode"] == 1
    let valText = DX7VoicePatch.freqRatio(fixedMode, v.coarse, v.fine)
    let detuneOff = v.detune - 7
    let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "" + detuneOff : "+" + detuneOff)
    freq.config({l: (fixedMode ? valText + " Hz" : "x " + valText) + detuneString})
  })
  
  addEnvCtrlBlocks(vc)

  vc.color()

  vc.dims("on")
  
  const env = vc.get("env")
  vc.onPatchChange("level", v => env.config({gain: v / 99 }))

  const paths = Object.keys(DX7VoicePatch.params).compactMap(path => {
    return path.startsWith("op/0/") ? path.substring(5) : null
  })
  vc.registerForEditMenu("env", {
    paths: () => paths,
    pasteboardType: "com.cfshpd.DX7Op",
    initialize: null,
    randomize: null,
  })
}

function algoController(vc, opCtrlr) {
  vc.grid([[
    [{ctrl: "algo", id: "algo"}, null],
  ]])

  const algo = vc.get("algo")
  
  let ops = []
  vc.addChildren(6, "op", index => {
    let sub = ctrlr(opCtrlr, index)  
    ops.push(sub.view)
    return sub
  })
  algo.config({
    algos: DX7VoicePatch.algorithms,
    ops: ops,
  })
  algo.v = 0
  vc.onPatchChange("algo", v => algo.v = v)
}


function controller(vc) {    
  
  vc.addChild(ctrlr(algoController, miniOpController), "algo")

  const ops = vc.addChildren(3, "op", index => ctrlr(opController, index, initAmpMod))

  vc.onIndexChange(i => {
    ops.forEachWithIndex((op, num) => op.index = num + 3 * i)
  })

  vc.panel("algoKnob", [[
    [{l: "Algorithm"}, "algo"],
  ],[
    [{l: "Feedback"}, "feedback"],
    [{l: "Osc Sync", ctrl: "checkbox"}, "osc/sync"],
  ]])
  
  vc.panel("opSwitch", [[
    [{l: "Ops", ctrl: "segmented", items: ["1–3","4–6"], id: "switch"}, null],
  ]])
    
  vc.panel("pitch", [[
    [{l: "Pitch", ctrl: "rateLevelEnv", id: "pitchEnv"}, null],
    [{l: "Transpose"}, "transpose"],
  ],[
    [{l: "R1"}, "pitch/env/rate/0"],
    [{l: "R2"}, "pitch/env/rate/1"],
    [{l: "R3"}, "pitch/env/rate/2"],
    [{l: "R4"}, "pitch/env/rate/3"],
  ],[
    [{l: "L1"}, "pitch/env/level/0"],
    [{l: "L2"}, "pitch/env/level/1"],
    [{l: "L3"}, "pitch/env/level/2"],
    [{l: "L4"}, "pitch/env/level/3"],
  ]])

  const pitchEnv = vc.get("pitchEnv")
  pitchEnv.config({susPt: 2, bipolar: true})

  for(let step = 0; step < 4; ++step) {
    vc.onPatchChange("pitch/env/rate/" + step, v => pitchEnv.config({rate: [1 - (v / 99), step]}))
    vc.onPatchChange("pitch/env/level/" + step, v => pitchEnv.config({level: [(v - 50) / 50, step]}))
  }

  vc.panel("lfo", [[
    [{l: "LFO Wave", ctrl: "select"}, "lfo/wave"],
    [{l: "Speed"}, "lfo/speed"],
  ],[
    [{l: "Delay"}, "lfo/delay"],
    [{l: "Key Sync", ctrl: "checkbox"}, "lfo/sync"],
  ],[
    [{l: "AMD"}, "lfo/amp/mod/depth"],
    [{l: "PMD"}, "lfo/pitch/mod/depth"],
    [{l: "Pitch Mod"}, "lfo/pitch/mod"],
  ]])
  
  vc.layRow([
    ["algo",7],["algoKnob",2],["pitch",4],["lfo",3]
    ], {options: ["alignAllTop"], pinned: true})
  vc.layRow([
    ["op0",1], ["op1",1], ["op2",1],
    ], {pinned: true})
  vc.layCol([
    ["algo",3],["op0",5],
    ], {pinned: true})
  vc.layCol([
    ["algoKnob",2],["opSwitch",1],
    ], {options: ["alignAllLeading", "alignAllTrailing"], pinned: false})
  vc.layEqual(["algo","opSwitch","pitch","lfo"], "bottom")

    
  // let paths: [SynthPath] = (0..<4).map { [.pitch, .env, .rate, .i($0)] } + (0..<4).map { [.pitch, .env, .level, .i($0)] }
  // registerForEditMenu(pitchEnv, bundle: (
  //   paths: { paths },
  //   pasteboardType: "com.cfshpd.DX7PitchEnv",
  //   initialize: nil,
  //   randomize: nil
  // ))
    
  vc.colorPanels(["op0", "op1", "op2"], {level: 1})
  vc.colorPanels(["algoKnob", "pitch", "lfo"], {level: 2})
  vc.colorPanels(["algo"], {level: 1, clearBG: true})
  vc.colorPanels(["opSwitch"], {level: 2, clearBG: true})
}


function addEnvCtrlBlocks(vc) {
  let env = vc.get("env")
  env.config({susPt: 2})
  
  for(let step = 0; step < 4; ++step) {
    vc.onPatchChange("rate/" + step, v => env.config({rate: [1 - (v / 99), step]}))
    vc.onPatchChange("level/" + step, v => env.config({level: [v / 99, step]}))
  }  
}

function opController(vc, index, initAmpMod) {
  vc.prefix((vc) => ["op", vc.index])
  vc.index = index
    
  vc.grid([[
    [{l: "On", ctrl: "checkbox", id: "on"}, "on"],
    [{l: "Osc Mode", ctrl: "switch", id: "oscMode"}, "osc/mode"],
    [{l: "Coarse"}, "coarse"],
    [{l: "Fine"}, "fine"],
    [{l: "Detune"}, "detune"],
  ],[
    [{ctrl: "rateLevelEnv", id: "env"}, null],
    [{ctrl: "levelScale", id: "levelScale"}, null],
    [{l: "Level"}, "level"],
    [{l: "Velo"}, "velo"],
  ],[
    [{l: "L1"}, "level/0"],
    [{l: "L2"}, "level/1"],
    [{l: "L3"}, "level/2"],
    [{l: "L4"}, "level/3"],
    [{l: "Amp Mod", id: "ampMod"}, null],
  ],[
    [{l: "R1"}, "rate/0"],
    [{l: "R2"}, "rate/1"],
    [{l: "R3"}, "rate/2"],
    [{l: "R4"}, "rate/3"],
    [{l: "Rate Scale"}, "rate/scale"],
  ],[
    [{l: "L Curve", ctrl: "switch"}, "level/scale/left/curve"],
    [{l: "L Depth"}, "level/scale/left/depth"],
    [{l: "R Depth"}, "level/scale/right/depth"],
    [{l: "R Curve", ctrl: "switch"}, "level/scale/right/curve"],
    [{l: "Break"}, "level/scale/brk/pt"],
  ]])
  
  addEnvCtrlBlocks(vc)
  
  const env = vc.get("env")
  vc.onIndexChange((i) => {
    env.config({l: "" + (i + 1)})
  })
  
  const paths = (4).map(i => "rate/" + i).concat((4).map(i => "level/" + i))
  vc.registerForEditMenu("env", {
    paths: () => paths,
    pasteboardType: "com.cfshpd.DX7Envelope",
    initialize: null,
    randomize: () => (8).map(() => (100).rand()),
  })

  const oscModeSwitch = vc.get("oscMode")
  vc.onPatchChangeAny(["osc/mode", "coarse", "fine"], values => {
    const coarse = values.coarse
    const fine = values.fine
    const fixedMode = values["osc/mode"] == 1
    const opts = [
      DX7VoicePatch.freqRatio(false, coarse, fine),
      DX7VoicePatch.freqRatio(true, coarse, fine),
    ]
    oscModeSwitch.config({l: fixedMode ? "Freq (Hz)" : "Ratio", opts: opts})
  })
  
  let onSwitch = vc.get("on")
  onSwitch.v = 1 // editor won't push an initial value for this
  
  let ampModKnob = vc.get("ampMod")
  vc.onIndexChange((i) => {
    onSwitch.config({l: "" + (i + 1)})
  })
  
  vc.dims("on")
  
  const levelScale = vc.get("levelScale")
  vc.onPatchChange("level/scale/left/depth", v => levelScale.config({ depthL: v}))
  vc.onPatchChange("level/scale/right/depth", v => levelScale.config({ depthR: v}))
  vc.onPatchChange("level/scale/left/curve", v => levelScale.config({ curveL: v}))
  vc.onPatchChange("level/scale/right/curve", v => levelScale.config({ curveR: v}))
  vc.onPatchChange("level/scale/brk/pt", v => levelScale.config({ breakPt: v}))
  
  const lsPaths = Object.keys(DX7VoicePatch.params).compactMap(path => {
    return path.startsWith("op/0/level/scale/") ? path.substring(5) : null
  })
  vc.registerForEditMenu("levelScale", {
    paths: () => lsPaths,
    pasteboardType: "com.cfshpd.DX7LevelScaling",
    initialize: null,
    randomize: null
  })

  initAmpMod(vc, ampModKnob)
    
}


module.exports = () => ctrlr(controller)

