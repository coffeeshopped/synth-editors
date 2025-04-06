const Op4VoiceCtrlr = require('./op4_voice_ctrlr.js')
const { opController, miniOpController } = require('./tx81z_voice_ctrlr.js')

module.exports = {
  ctrlr: {
    builders: [
      ['child', Op4VoiceCtrlr.algoCtrlr(miniOpController), "algo", {color: 2, clearBG: true}],
      ['child', opController(0), "op0", {color: 1}],
      ['child', opController(1), "op1", {color: 1}],
      ['child', opController(2), "op2", {color: 1}],
      ['child', opController(3), "op3", {color: 1}],
      ['child', Op4VoiceCtrlr.pitch, "pitch", {color: 2}],
      ['panel', 'algoKnob', { color: 2, }, [[
        ["Algorithm", "voice/algo"],
        ["Feedback", "voice/feedback"],
        [{checkbox: "Mono"}, "voice/poly"],
        ["Transpose", "voice/transpose"],
        ["P Bend", "voice/bend"],
        ["Reverb", "extra/reverb"],
      ]]],
      ['panel', 'porta', { color: 2, }, [[
        ["Porta Time", "voice/porta/time"],
        [{checkbox: "Fingered"}, "voice/porta/mode"],
      ]]],
      ['panel', 'lfo', { color: 2, }, [[
        [{switsch: "LFO Wave"}, "voice/lfo/wave"],
        ["Speed", "voice/lfo/speed"],
      ],[
        [{checkbox: "Key Sync"}, "voice/lfo/sync"],
        ["Pitch Depth", "voice/pitch/mod/depth"],
        ["Pitch Sens", "voice/pitch/mod/sens"],
      ],[
        ["Delay", "voice/lfo/delay"],
        ["Amp Depth", "voice/amp/mod/depth"],
        ["Amp Sens", "voice/amp/mod/sens"],
      ]]],
      ['panel', 'mod', { color: 2, }, [[
        ["Mod→Amp", "voice/modWheel/amp"],
        ["Pitch", "voice/modWheel/pitch"],
      ]]],
      ['panel', 'foot', { color: 2, }, [[
        ["Foot→Amp", "extra/foot/amp"],
        ["Pitch", "extra/foot/pitch"],
        ["Volume", "voice/foot/volume"],
        .spacer(2),
      ]]],
      ['panel', 'breath', { color: 2, }, [[
        ["Breath→Amp", "voice/breath/amp"],
        ["Pitch", "voice/breath/pitch"],
        ["P Bias", "voice/breath/pitch/bias"],
        ["EG Bias", "voice/breath/env/bias"],
      ]]],
      ['panel', 'after', { color: 2, }, [[
        ["AfterT→Amp", "aftertouch/aftertouch/amp"],
        ["Pitch", "aftertouch/aftertouch/pitch"],
        ["P Bias", "aftertouch/aftertouch/pitch/bias"],
        ["EG Bias", "aftertouch/aftertouch/env/bias"],
      ]]],
    ], 
    layout: [
      ['row', [["algo",6], ["algoKnob",6], ["mod",2], ["porta",2]], { opts: ['alignAllTop'] }],
      ['row', [["op0",1],["op1",1],["op2",1],["op3",1]]],
      ['col', [["algo",4], ["op0",5]]],
      ['rowPart', [["lfo", 3], ["pitch", 3], ["foot", 4]], { opts: ['alignAllTop'] }],
      ['colPart', [["foot", 1], ["breath", 1], ["after", 1]], { opts: ['alignAllLeading', 'alignAllTrailing'] }],
      ['colPart', [["algoKnob", 1], ["lfo", 3]]],
      ['eq', ["porta", "foot"], 'trailing'],
      ['eq', ["algoKnob", "mod", "porta"], 'bottom'],
      ['eq', ["algo", "lfo", "pitch", "after"], 'bottom'],
    ]
  },
}
