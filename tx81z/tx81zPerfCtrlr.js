
const reservePaths = (8).map(i => ['part', i, 'voice', 'reserve'])

const partController = presetVoices => {
  const presetMap = presetVoices.map((e, i) => [i + 32, e])
  return {
    index: 'part', 
    label: 'voice/number', 
    fn: i => `Inst ${i + 1}`,
    color: 2, 
    builders: [
      ['grid', [[
        [{t: 'select', l: "Inst"}, "voice/number"],
      ],[
        [{t: 'select'}, "channel"],
        [{t: 'knob', l: "Max Notes", id: "voice/reserve"}, null],
      ],[
        [{t: 'knob'}, "volume"],
        [{t: 'switch', l: "Out Assign"}, "out/select"],
      ],[
        ["Low Note", "note/lo"],
        ["High Note", "note/hi"],
      ],[
        [{t: 'knob'}, "note/shift"],
        [{t: 'knob'}, "detune"],
      ],[
        [{t: 'switch', l: "LFO Select"}, "lfo"],
        [{t: 'checkbox', l: "Microtune"}, "micro"],
      ]]]
    ], 
    effects: [
      [
        ['paramChange', "patch/name", parm => {
          const options = parm.options || []
          return ['configCtrl', "voice/number", ['opts', options.concat(presetMap)]]
        }],
        ['dimsOn', "voice/reserve"],
      ],
      ['voiceReserve', reservePaths, 8, ["voice/reserve"]],
    ]
  }
}

module.exports = {
  ctrlr: presetVoices => ({
    builders: [
      ['children', 8, "part", partController(presetVoices)],
      ['panel', "other", {color: 1}, [[
        [{t: 'switch', l: "Assign Mode"}, 'assign'],
        [{t: 'select', l: "Effect"}, 'fx'],
        [{t: 'select', l: "Microtune"}, 'micro/scale'],
        [{t: 'select', l: "Key"}, 'micro/key'],
      ]]],
      ['panel', "space", {}, [[]]],
    ],
    layout: [
      ['row', (8).map(i => [`part${i}`, 1])],
      ['row', [["other", 7], ["space", 9]]],
      ['col', [["part0", 6], ["other", 1]]],
    ],
  }),
}
