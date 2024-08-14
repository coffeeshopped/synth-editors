const Op4 = require('./op4.js')
const Op4VoiceCtrlr = require('./op4voiceCtrlr.js')

const opPath = Op4VoiceCtrlr.opPath

const AllPaths = ["attack", "decay/0", "decay/1", "release", "decay/level", "level/scale", "rate/scale", "env/bias/sens", "amp/mod", "velo", "level", "coarse", "detune", "extra/wave", "extra/osc/mode", "extra/fixed/range", "extra/fine", "extra/shift"]


const miniOpController = index => {
  const modePath = opPath(index, "extra/osc/mode")
  const rangePath = opPath(index, "extra/fixed/range")
  const coarsePath = opPath(index, "coarse")
  const finePath = opPath(index, "extra/fine")
  const detunePath = opPath(index, "detune")

  return Op4VoiceCtrlr.miniOpController(index, ['patchChangeMulti', [modePath, rangePath, coarsePath, finePath, detunePath], values => {
    const range = values[rangePath]
    const coarse = values[coarsePath]
    const fine = values[finePath]
    const detune = values[detunePath]
    const fixedMode = values[modePath] == 1
    const valText = Op4.freqRatio(fixedMode, range, coarse, fine)
    const detuneOff = detune - 3
    const detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")
    
    return [
      ['setCtrlLabel', "osc/mode", fixedMode ? `${valText} Hz` : `x ${valText}${detuneString}`],
    ]
  }], "TX81ZOp", AllPaths)
}
      
const opController = index => {
  
  const modePath = opPath(index, "extra/osc/mode")
  const rangePath = opPath(index, "extra/fixed/range")
  const coarsePath = opPath(index, "coarse")
  const finePath = opPath(index, "extra/fine")

  return {
    builders: [
      ['grid', Op4VoiceCtrlr.opItems(index, [[
        [{t: 'checkbox', l: "On"}, "on"],
        [{t: 'imgSelect', id: "wave", w: 75, h: 64}, "extra/wave"],
        [{t: 'switch', l: "Fixed"}, "extra/osc/mode"],
      ],[
        [{t: 'knob', l: "Range"}, "extra/fixed/range"],
        [{t: 'knob', l: "Coarse"}, "coarse"],
        [{t: 'knob', l: "Fine"}, "extra/fine"],
        [{t: 'knob', l: "Detune"}, "detune"],
      ],[
        Op4VoiceCtrlr.envItem(index),
        [{t: 'knob', l: "Level"}, "level"],
        [{t: 'knob', l: "Velocity"}, "velo"],
      ],[
        [{t: 'knob', l: "Attack"}, "attack"],
        [{t: 'knob', l: "Decay 1"}, "decay/0"],
        [{t: 'knob', l: "Sustain"}, "decay/level"],
        [{t: 'knob', l: "Decay 2"}, "decay/1"],
        [{t: 'knob', l: "Release"}, "release"],
      ],[
        [{t: 'knob', l: "L Scale"}, "level/scale"],
        [{t: 'knob', l: "Shift (dB)"}, "extra/shift"],
        [{t: 'knob', l: "EBS"}, "env/bias/sens"],
        [{t: 'checkbox', l: "Amp Mod"}, "amp/mod"],
        [{t: 'knob', l: "R Scale"}, "rate/scale"],
      ]])]
    ], 
    effects: [
      ['dimsOn', opPath(index, "on")],
      ['patchChange', {
        paths: [modePath, rangePath, coarsePath, finePath],
        fn: values => {
          const range = values[rangePath]
          const coarse = values[coarsePath]
          const fine = values[finePath]
          const fixedMode = values[modePath] == 1
          return [
            ['setCtrlLabel', modePath, fixedMode ? "Freq (Hz)" : "Ratio"],
            ['configCtrl', modePath, { opts: [
              Op4.freqRatio(false, range, coarse, fine),
              Op4.freqRatio(true, range, coarse, fine),
            ]}],
            ['dimItem', !fixedMode, "extra/fixed/range"],
          ]
        },
      }],
      ['editMenu', "env", {
        paths: Op4VoiceCtrlr.opPaths(index, ["attack", "decay/0", "decay/1", "decay/level", "release"]), 
        type: "TX81ZEnvelope",
      }],
    ]
  }
}


module.exports = {
  builders: [
    ['child', Op4VoiceCtrlr.algoCtrlr(miniOpController), "algo", { color: 2, clearBG: true }],
    ['child', opController(0), "op0", { color: 1 }],
    ['child', opController(1), "op1", { color: 1 }],
    ['child', opController(2), "op2", { color: 1 }],
    ['child', opController(3), "op3", { color: 1 }],
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