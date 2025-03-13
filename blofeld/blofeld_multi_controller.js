
const part = {
  prefix: {index: "part"}, 
  color: 1, 
  builders: [
    ['grid', [
      [[{select:"Bank"}, 'bank']],
      [[{select:"Sound"}, 'sound']],
      [
        ["Volume", "volume"],
        ["Pan", "pan"],
      ],
      [["Channel", 'channel']],
      [
        ["Transpose", "transpose"],
        ["Detune", "detune"],
      ],
      [
        ["Velo Lo", "velo/lo"],
        ["Velo Hi", "velo/hi"],
      ],
      [
        ["Key Lo", "key/lo"],
        ["Key Hi", "key/hi"],
      ],
      [[{switch: ""}, 'mute']],
    ]],
  ], 
  effects: [
    ['dimsOn', "mute", null, { dimWhen: v => v == 1 }],
    ['indexChange', i => ['setCtrlLabel', "mute", `${i + 1}`]],
    ['patchSelector', "sound", {
      bankValue: "bank", 
      paramMap: bank => ['fullPath', `patch/name/${bank}`],
    }],
  ],
}

const receive = ['oneRow', 16, {
  prefix: {index: "part"}, 
  color: 1, 
  builders: [
    ['grid', [
      [[{l: "?", id: 'part'}, null]],
      [[{checkbox: "MIDI"}, 'midi']],
      [[{checkbox: "USB"}, 'usb']],
      [[{checkbox: "Local"}, 'local']],
      [[{checkbox: "Bend"}, 'bend']],
      [[{checkbox: "Mod W"}, 'modWheel']],
      [[{checkbox: "Pressure"}, 'pressure']],
      [[{checkbox: "Sustain"}, 'sustain']],
      [[{checkbox: "Edits"}, 'edits']],
      [[{checkbox: "Pgm Ch"}, 'pgmChange']],
    ]]
  ], 
  effects: [
    ['indexChange', i => ['setCtrlLabel', "part", `${i + 1}`]]
  ],
}]

module.exports = {
  controller: {
    builders: [
      ['switcher', ["Main 1–8","Main 9–16","Receive"], {color: 1}],
      ['panel', 'ctrl', { color: 1, }, [[
        ["Volume", "volume"],
        ["Tempo", "tempo"],
      ]]]
    ], 
    layout: [
      ['row', [["switch",8],["ctrl",8]]],
      ['row', [["page",1]]],
      ['col', [["switch",1],["page",8]]],
    ], 
    pages: ['map', ["part/0", "part/1", "rcv"], [
      ["part", ['oneRow', 8, part, (parentIndex, offset) => offset + (parentIndex * 8)]],
      ["rcv", receive],
    ]],
  }
}