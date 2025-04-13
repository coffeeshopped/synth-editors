const Perf = require('./jv8x_perf.js')

const reservePaths = (8).map(i => ["part", i, "voice/reserve"])

const common = {  
  prefix: { fixed: "common" }, 
  color: 1, 
  builders: [
    ['panel', 'reverb', { }, [[
      [{select: "Reverb"}, "reverb/type"],
      ["Level", "reverb/level"],
      ["Time", "reverb/time"],
      ["Feedback", "reverb/feedback"],
      ]]],
    ['panel', 'chorus', { }, [[
      [{switsch: "Chorus"}, "chorus/type"],
      ["Level", "chorus/level"],
      ["Depth", "chorus/depth"],
      ["Rate", "chorus/rate"],
      ["Feedback", "chorus/feedback"],
      [{switsch: "Output"}, "chorus/out/assign"],
      ]]],
    ['panel', 'reserve', { }, [[
      [{ knob: "Voice Reserve 1", id: "part/0/voice/reserve"}, null],
      [{ knob: "2", id: "part/1/voice/reserve"}, null],
      [{ knob: "3", id: "part/2/voice/reserve"}, null],
      [{ knob: "4", id: "part/3/voice/reserve"}, null],
    ], [
      [{ knob: "5", id: "part/4/voice/reserve"}, null],
      [{ knob: "6", id: "part/5/voice/reserve"}, null],
      [{ knob: "7", id: "part/6/voice/reserve"}, null],
      [{ knob: "8", id: "part/7/voice/reserve"}, null],
    ]]],
  ], 
  effects: [
    ['voiceReserve', reservePaths.map(p => ["common", p]), 28, reservePaths],
  ], 
  layout: [
    ['row', [["reverb",4.5]]],
    ['row', [["chorus",6]]],
    ['row', [["reserve",4]]],
    ['col', [["reverb",1], ["chorus",1], ["reserve",2]]],
  ])
}

const part = hideOut => ['index', "part", "on", i => i == 7 ? "Rhythm" : `${i + 1}`, {
  builders: [
    ['grid', {color: 1}, [[
      [{checkbox: "On"}, "on"],
      ["Channel", "channel"],
    ], [
      [{switch: "Group", id: "patch/group"}, null],
    ], [
      [{select: "Patch", id: "patch/number"}, null],
    ], [
      ["Level", "level"],
      ["Pan", "pan"],
    ], [
      ["Coarse", "coarse"],
      ["Fine", "fine"],
    ], [
      [{checkbox: "Reverb"}, "reverb"],
      [{checkbox: "Chorus"}, "chorus"],
    ], [
      [{checkbox: "Rx Pgm Ch"}, "rcv/pgmChange"],
      [{checkbox: "Rx Volume"}, "rcv/volume"],
    ], [
      [{checkbox: "Rx Hold"}, "rcv/hold"],
      [{switsch: "Output"}, "out/assign"],
    ]]],
  ], 
  effects: [
    ['setup', [
      ['configCtrl', "patch/group", {opts: Perf.patchGroupOptions}],
      ['hideItem', hideOut, "out/assign"],
    ]],
    ['patchChange', "patch/number", v => [
      ['setValue', "patch/group", v / 64],
      ['setValue', "patch/number", v % 64],
    ]],
    ['indexChange', i => [
      ['hideItem', i == 7, "patch/number"],
    ]],
    ['patchSelector', "patch/number", {
      bankValues: ["patch/number"],
      paramMapWithContext: (values, state, locals) => { 
        switch ((values["patch/number"] || 0) / 64) {
        case 0:
          return ['fullPath', "patch/name"]
        case 1:
          return {opts: Perf.blankPatchOptions}
        case 2:
          return {opts: Perf.presetAOptions}
        default:
          return {opts: Perf.presetBOptions}
        }
      },
    }],
    ['controlChange', ["patch/group", "patch/number"], (state, locals) => {
      const group = locals["patch/group"] || 0
      const number = locals["patch/number"] || 0
      return ["patch/number" : group * 64 + number]
    }],
  ],
}]

const parts = hideOut => ['oneRow', 8, part(hideOut)]

const ctrlr = {
  builders: [
    ['switcher', ["Common","Parts"], {color: 1}],
    ['panel', 'space', { }, [[]]],
  ], 
  layout: [
    ['row', [["switch",6], ["space", 10]]],
    ['row', [["page",1]]],
    ['col', [["switch",1], ["page",8]]],
  ], 
  pages: ['controllers', [common, parts(false)]],
}