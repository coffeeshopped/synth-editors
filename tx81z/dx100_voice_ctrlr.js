const Op4 = require('./op4.js')
const Op4VoiceCtrlr = require('./op4_voice_ctrlr.js')

const opPath = Op4VoiceCtrlr.opPath

const AllPaths = ["attack", "decay/0", "decay/1", "release", "decay/level", "level/scale", "rate/scale", "env/bias/sens", "amp/mod", "velo", "level", "coarse", "detune"]

const miniOpController = index => {
  const coarsePath = opPath(index, "coarse")
  const detunePath = opPath(index, "detune")

  return Op4VoiceCtrlr.miniOpController(index, ['patchChange', {
    paths: [coarsePath, detunePath], 
    fn: values => {
      const coarse = values[coarsePath]
      const detune = values[detunePath]
      const detuneOff = detune - 3
      const detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? detuneOff : `+${detuneOff}`)
  
      return [
        ['setCtrlLabel', "osc/mode",  `${Op4.coarseRatio(coarse)}${detuneString}`],
      ]
    }
  }], "DX100Op", AllPaths)
}

const opController = index => {
  const coarseLookup = Op4.coarseRatioLookup.map(x => `${x}`)
  const coarsePath = opPath(index, "coarse")
  
  return {
    builders: [
      ['grid', Op4VoiceCtrlr.opItems(index, [[
        [{checkbox: "On"}, "on"],
        [{knob: "Coarse", id: coarsePath}, null],
        ["Detune", "detune"],
        [{checkbox: "Amp Mod"}, "amp/mod"],
      ],[
        Op4VoiceCtrlr.envItem(index),
        ["Level", "level"],
        ["Velocity", "velo"],
      ],[
        ["Attack", "attack"],
        ["Decay 1", "decay/0"],
        ["Sustain", "decay/level"],
        ["Release", "release"],
      ],[
        ["L Scale", "level/scale"],
        ["EBS", "env/bias/sens"],
        ["Decay 2", "decay/1"],
        ["R Scale", "rate/scale"],
      ]])]
    ], 
    effects: [
      ['dimsOn', opPath(index, "on")],
      ['ctrlBlocks', opPath(index, "coarse"), {opts: coarseLookup}],
      ['editMenu', "env", {
        paths: Op4VoiceCtrlr.opPaths(index, ["attack", "decay/0", "decay/1", "decay/level", "release"]), type: "TX81ZEnvelope",
      }],
    ],
  }
}

module.exports = {
  miniOpController,
  opController,
  ctrlr: {
    builders: [
      ['child', Op4VoiceCtrlr.algoCtrlr(miniOpController), "algo", {color: 2, clearBG: true}],
      ['child', opController(0), "op0", { color: 1 }],
      ['child', opController(1), "op1", { color: 1 }],
      ['child', opController(2), "op2", { color: 1 }],
      ['child', opController(3), "op3", { color: 1 }],
      ['panel', 'algoKnob', { prefix: "voice", color: 2 }, [[
        ["Algorithm", "algo"],
      ],[
        ["Feedback", "feedback"],
        [{checkbox: "Mono"}, "poly"],
      ]]],
      ['panel', 'transpose', { prefix: "voice", color: 2, }, [[
        ["transpose"],
        ["P Bend", "bend"],
      ],[
        ["Porta Time" , "porta/time"],
        [{checkbox: "Fingered"}, "porta/mode"],
      ]]],
      ['panel', 'lfo', { prefix: "voice", color: 2, }, [[
        [{switsch: "LFO Wave"}, "lfo/wave"],
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
      ['panel', 'mods', { prefix: "voice", color: 2, }, [[
        ["Mod→Pitch", "modWheel/pitch"],
        ["Amp", "modWheel/amp"],
        '-',
        '-',
      ],[
        ["Foot→Volume", "foot/volume"],
        '-',
        '-',
        '-',
      ],[
        ["Breath→Pitch", "breath/pitch"],
        ["Amp", "breath/amp"],
        ["P Bias", "breath/pitch/bias"],
        ["EG Bias", "breath/env/bias"],
      ]]]
    ], 
    layout: [
      ['row', [["algo",5],["algoKnob",2],["transpose",2],["lfo",3],["mods",4]]],
      ['row', [["op0",1],["op1",1],["op2",1],["op3",1]]],
      ['col', [["algo",3],["op0",4]]],
    ],
  },
}