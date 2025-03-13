module.exports = {
  controller: {
    color: 1, 
    builders: [
      ['panel', 'device', { }, [[
        ["Device ID", "deviceId"],
        ["MIDI Channel", "channel"],
        [{checkbox: "Auto Edit"}, "autoEdit"],
        ["Popup Time", "popup/time"],
        ["Contrast", "contrast"],
      ]]],
      ['panel', 'tune', { }, [[
        ["Master Tune", "tune"],
        ["Transpose", "transpose"],
        [{switch: "Clock"}, "clock"],
        [{select: "Velo Curve"}, "velo/curve"],
      ]]],
      ['panel', 'ctrl', { }, [[
        [{switch: "Ctrl Send"}, "ctrl/send"],
        [{checkbox: "Ctrl Rcv"}, "ctrl/rcv"],
        ["Ctrl W", "ctrl/0"],
        ["Ctrl X", "ctrl/1"],
        ["Ctrl Y", "ctrl/2"],
        ["Ctrl Z", "ctrl/3"],
      ]]],
    ], 
    simpleGridLayout: [
      [["device", 1]], [["tune", 1]], [["ctrl", 1]],
    ],
  }
}