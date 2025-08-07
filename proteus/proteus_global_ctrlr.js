
const channel = ['index', '', "midi/on", i => `MIDI ${i + 1}`, {
  builders: [
    ['grid', [[
      [{checkbox: "MIDI Ch"}, "midi/on"],
    ],[
      [{checkbox: "Pgm Ch"}, "pgmChange/on"],
    ],[
      [{switsch: "Mix Out"}, "mix"],
    ]]]
  ],
}

const ctrlr = {
  color: 1, 
  builders: [
    ['children', 16, "midi", channel],
    ['panel', 'device', { }, [[
      ["Device ID", "deviceId"],
    ]]],
    ['panel', 'channel', { }, [[
      ["Channel", "channel"],
      ["Volume", "volume"],
      ["Pan", "pan"],
      ["Preset", "preset"],
    ]]],
    ['panel', 'tune', { }, [[
      ["Master Tune", "tune"],
      ["Transpose", "transpose"],
      ["Bend Range", "bend"],
      ["Velo Curve", "velo/curve"],
    ]]],
    ['panel', 'mode', { }, [[
      [{switsch: "MIDI Mode"}, "midi/mode"],
      [{checkbox: "Mode Change"}, "mode/change/on"],
      [{checkbox: "Overflow"}, "midi/extra"],
    ]]],
    ['panel', 'ctrl', { }, [[
      ["Ctrl A", "ctrl/0"],
      ["Ctrl B", "ctrl/1"],
      ["Ctrl C", "ctrl/2"],
      ["Ctrl D", "ctrl/3"],
    ]]],
    ['panel', 'foot', { }, [[
      ["Foot 1", "foot/0"],
      ["Foot 2", "foot/1"],
      ["Foot 3", "foot/2"],
    ]]]
  ],
  layout: [
    ['row', [["device", 1], ["channel", 4], ["tune", 4], ["mode", 3]]],
    ['row', [["ctrl", 4], ["foot", 3]]],
    ['row', []],
    ['col', [["device", 1], ["ctrl", 1], ["midi0", 3]]],
  ])
}
