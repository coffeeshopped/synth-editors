
const scale = {
  prefix: ['indexFn', i => ['scale/tune', i == 0 ? 'patch' : i - 1]], 
  gridBuilder: [[
    ['switcher', "Scale Part", ["Patch", "1", "2", "3", "4", "5", "6", "7", "8"]],
  ],[
    ["C", "note/0"],
    ["C#", "note/1"],
    ["D", "note/2"],
    ["D#", "note/3"],
    ["E", "note/4"],
    ["F", "note/5"],
    ["F#", "note/6"],
    ["G", "note/7"],
    ["G#", "note/8"],
    ["A", "note/9"],
    ["A#", "note/10"],
    ["B", "note/11"],
  ]],
}

const ctrlr = {
  color: 1, 
  builders: [
    ['child', scale, "scale"],
    ['panel', 'mode', [[
      [{switsch: "Mode"}, "mode"],
      ["Tune", "tune"],
    ]]],
    ['panel', 'fx', [[
      [{checkbox: "Reverb"}, "reverb"],
      [{checkbox: "Chorus"}, "chorus"],
    ]]],
    ['panel', 'rx', [[
      [{checkbox: "RX Volume"}, "rcv/volume"],
      [{checkbox: "CC"}, "rcv/ctrl/change"],
      [{checkbox: "Ch Press"}, "rcv/aftertouch"],
      [{checkbox: "Mod"}, "rcv/mod"],
      [{checkbox: "Bend"}, "rcv/bend"],
      [{checkbox: "Pgm Ch"}, "rcv/pgmChange"],
      [{checkbox: "Bank Sel"}, "rcv/bank/select"],
      ["Patch Channel", "patch/channel"],
    ]]],
    ['panel', 'etc', [[
      ["Ctrl Chan", "ctrl/channel"],
      [{switsch: "Out Mode"}, "out/mode"],
      [{switsch: "Rhythm Edit K"}, "rhythm/edit/key"],
    ]]],
    ['panel', 'scaleSwitch', [[
      [{checkbox: "Scale Tune"}, "scale/tune"],
    ]]],
  ], 
  layout: [
    ['row', [["mode",4], ["fx",2], ["etc",3]]],
    ['row', [["rx",8]]],
    ['row', [["scaleSwitch",1], ["scale",12]]],
    ['col', [["mode",1], ["rx",1], ["scaleSwitch",2]]],
  ],
}

