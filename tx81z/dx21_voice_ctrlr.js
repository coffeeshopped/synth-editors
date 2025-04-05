const Op4 = require('./op4.js')
const Op4VoiceCtrlr = require('./op4_voice_ctrlr.js')
const { opController, miniOpController } = require('./dx100_voice_ctrlr.js')

const pitch = prefix => ({
  prefix: {fixed: prefix }, 
  builders: [
    ['grid', [[
      {
        display: 'rateLevelEnv',
        pointCount: 3,
        sustain: 999,
        bipolar: true,
        l: "Pitch",
        maps: (3).flatMap(i => [
          ['u', ['rate', i], 99],
          ['src', ["level", i], v => (v - 50) / 50],
        ]),
        id: "env"
      }
      ],[
      ["R1", "rate/0"],
      ["R2", "rate/1"],
      ["R3", "rate/2"],
      ],[
      ["L1", "level/0"],
      ["L2", "level/1"],
      ["L3", "level/2"],
    ]]]
  ],
})

module.exports = {
  ctrlr: {
    builders: [
      ['child', Op4VoiceCtrlr.algoCtrlr(miniOpController), "algo", {color: 2, clearBG: true}],
      ['child', opController(0), "op0", {color: 1}],
      ['child', opController(1), "op1", {color: 1}],
      ['child', opController(2), "op2", {color: 1}],
      ['child', opController(3), "op3", {color: 1}],
      ['child', pitch("voice/pitch/env"), "pitch", {color: 2}],
      ['panel', 'algoKnob', { prefix: "voice", color: 2, }, [[
        ["Algorithm", "algo"],
      ],[
        ["feedback"],
      ],[
        [{checkbox: "Mono"}, "poly"],
      ],[
        [{checkbox: "Chorus"}, "chorus"],
      ]]],
      ['panel', 'transpose', { prefix: "voice", color: 2 }, [[
        ["Transpose", "transpose"],
      ],[
        ["P Bend", "bend"],
      ],[
        ["porta/time"],
      ],[
        [{checkbox: "Fingered"}, "porta/mode"],
      ]]],
      ['panel', 'lfo', { prefix: "voice", color: 2 }, [[
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
      ['panel', 'mods', { prefix: "voice", color: 2 }, [[
        ["Mod→Pitch", "modWheel/pitch"],
        ["Mod→Amp", "modWheel/amp"],
      ],[
        ["Foot→Volume", "foot/volume"],
      ],[
        ["Breath→Pitch", "breath/pitch"],
        ["Breath→Amp", "breath/amp"],
      ],[
        ["Breath→P Bias", "breath/pitch/bias"],
        ["Breath→EG Bias", "breath/env/bias"],
      ]]],
    ], 
    layout: [
      ['row', [["algo",5],["algoKnob",1],["transpose",1],["lfo",3],["mods",2], ["pitch", 3]]],
      ['row', [["op0",1],["op1",1],["op2",1],["op3",1]]],
      ['col', [["algo",4],["op0",4]]],
    ],
  }
}