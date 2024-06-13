const AllPaths = ["attack", "decay/0", "decay/1", "release", "decay/level", "level/scale", "rate/scale", "env/bias/sens", "amp/mod", "velo", "level", "coarse", "detune", "extra/wave", "extra/osc/mode", "extra/fixed/range", "extra/fine", "extra/shift"]


const miniOpController = (index) => {
  let modePath = Op4.opPath(index, "extra/osc/mode")
  let rangePath = Op4.opPath(index, "extra/fixed/range")
  let coarsePath = Op4.opPath(index, "coarse")
  let finePath = Op4.opPath(index, "extra/fine")
  let detunePath = Op4.opPath(index, "detune")

  return Op4.MiniOp.controller(index: index, ratioEffect: .patchChange(paths: [modePath, rangePath, coarsePath, finePath, detunePath], { values in
    guard let range = values[rangePath],
      let coarse = values[coarsePath],
      let fine = values[finePath],
      let detune = values[detunePath] else { return [] }
    let fixedMode = values[modePath] == 1
    let valText = Op4.freqRatio(fixedMode: fixedMode, range: range, coarse: coarse, fine: fine)
    let detuneOff = detune - 3
    let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")
    
    return [
      .setCtrlLabel("osc/mode", fixedMode ? "\(valText) Hz" : "x \(valText)\(detuneString)"),
    ]
  }), "TX81ZOp", AllPaths)
}
      
const opController = (index: Int) -> PatchController {
  
  let modePath: SynthPath = Op4.opPath(index, "extra/osc/mode")
  let rangePath: SynthPath = Op4.opPath(index, "extra/fixed/range")
  let coarsePath: SynthPath = Op4.opPath(index, "coarse")
  let finePath: SynthPath = Op4.opPath(index, "extra/fine")

  return {
    builders: [
      ['grid', Op4.opItems(index, [[
        [{checkbox: "On"}, "on"],
        .imgSelect("wave", "extra/wave", w: 75, h: 64),
        [{switch: "Fixed"}, "extra/osc/mode"],
      ],[
        ["Range", "extra/fixed/range"],
        ["Coarse", "coarse"],
        ["Fine", "extra/fine"],
        ["Detune", "detune"],
      ],[
        Op4.envItem(index: index),
        ["Level", "level"],
        ["Velocity", "velo"],
      ],[
        ["Attack", "attack"],
        ["Decay 1", "decay/0"],
        ["Sustain", "decay/level"],
        ["Decay 2", "decay/1"],
        ["Release", "release"],
      ],[
        ["L Scale", "level/scale"],
        ["Shift (dB)", "extra/shift"],
        ["EBS", "env/bias/sens"],
        [{checkbox: "Amp Mod"}, "amp/mod"],
        ["R Scale", "rate/scale"],
      ]]])
    ], 
    effects: [
      .dimsOn(Op4.opPath(index, "on"), id: nil),
      .patchChange(paths: [modePath, rangePath, coarsePath, finePath], { values in
        guard let range = values[rangePath],
          let coarse = values[coarsePath],
          let fine = values[finePath] else { return [] }
        let fixedMode = values[modePath] == 1
        return [
          .setCtrlLabel(modePath, fixedMode ? "Freq (Hz)" : "Ratio"),
          .configCtrl(modePath, .opts(ParamOptions(optArray: [
            Op4.freqRatio(fixedMode: false, range: range, coarse: coarse, fine: fine),
            Op4.freqRatio(fixedMode: true, range: range, coarse: coarse, fine: fine)]))),
          .dimItem(!fixedMode, "extra/fixed/range"),
        ]
      }),
      ['editMenu', "env", {
        paths: Op4.opPaths(index, ["attack", "decay/0", "decay/1", "decay/level", "release"]), 
        type: "TX81ZEnvelope",
      }],
    ]
  }
}


module.exports = {
  builders: [
    ['child', Op4.algoCtrlr(MiniOp.controller), "algo", { color: 2, clearBG: true }],
    ['child', Op.controller(index: 0), "op0", { color: 1 }],
    ['child', Op.controller(index: 1), "op1", { color: 1 }],
    ['child', Op.controller(index: 2), "op2", { color: 1 }],
    ['child', Op.controller(index: 3), "op3", { color: 1 }],
    ['panel', "algoKnob", { prefix: "voice", color: 1 }, [[
      ["Algorithm", "algo"],
    ],[
      ["Feedback", "feedback"],
      [{checkbox: "Mono"}, "poly"]
    ]]],
    ['panel', "transpose", { color: 2 }, [[
      ["Transpose", "voice/transpose"],
      ["P Bend", "voice/bend"],
    ],[
      ["Reverb", "extra/reverb"],
    ],[
      ["Porta Time", "voice/porta/time"],
      [{checkbox: "Fingered"}, "voice/porta/mode"],
    ]]],
    ['panel', "lfo", { prefix: "voice", color: 2 }, [[
      [{switch: "LFO Wave"}, "lfo/wave"],
      ["Speed", "lfo/speed"],
    ],[
      [{checkbox: "Key Sync"}, "lfo/sync"],
      ["Pitch Depth", "pitch/mod/depth"],
      ["Pitch Sens", "pitch/mod/sens"],
    ],[
      ["Delay", "lfo/delay"],
      ["Amp Depth", "amp/mod/depth"],
      ["Amp Sens", "amp/mod/sens"],
    ]]],
    ['panel', "mods", { color: 2 }, [[
      ["Mod→Amp", "voice/modWheel/amp"],
      ["Pitch", "voice/modWheel/pitch"],
      {spacer: 2},
      {spacer: 2},
    ],[
      ["Foot→Amp", "extra/foot/amp"],
      ["Pitch", "extra/foot/pitch"],
      ["Volume", "voice/foot/volume"],
      {spacer: 2},
    ],[
      ["Breath→Amp", "voice/breath/amp"],
      ["Pitch", "voice/breath/pitch"],
      ["P Bias", "voice/breath/pitch/bias"],
      ["EG Bias", "voice/breath/env/bias"],
    ]]]
  ], 
  layout: [
    ['row', [["algo",5],["algoKnob",2],["transpose",2],["lfo",3],["mods",4]]],
    ['row', [["op0",1],["op1",1],["op2",1],["op3",1]]],
    ['col', [["algo",3],["op0",5]]],
  ],
}