
module.exports = {
  ctrlr: {
    builders: [
      ['panel', 'dev', { color: 1 }, [[
        ["Device ID", "deviceId"],
        ["Note Shift", "note/shift"],
        ["Detune", "detune"],
        [{switsch: "Dump Int"}, "dump/interval"],
        [{switsch: "Pgm Ch Mode"}, "pgmChange/mode"],
        [{select: "Perf Channel"}, "perf/channel"],
        [{switsch: "Knob Mode"}, "knob/mode"],
      ]]],
      ['panel', 'curve', { color: 1 }, [[
        [{switsch: "Breath Crv"}, "breath/curve"],
        [{switsch: "Velo Crv"}, "velo/curve"],
        [{switsch: "Note Rcv"}, "rcv/note"],
        [{checkbox: "Bank Rcv"}, "rcv/bank/select"],
        [{checkbox: "Pgm Ch Rcv"}, "rcv/pgmChange"],
        [{checkbox: "Knob Rcv"}, "rcv/knob"],
        [{checkbox: "Knob Send"}, "send/knob"],
      ]]],
      ['panel', 'knob', { color: 1 }, [[
        ["Knob 1", "knob/ctrl/0/number"],
        ["2", "knob/ctrl/1/number"],
        ["3", "knob/ctrl/2/number"],
        ["4", "knob/ctrl/3/number"],
      ]]],
      ['panel', 'mc', { color: 1 }, [[
        ["MC 1", "midi/ctrl/0/number"],
        ["2", "midi/ctrl/1/number"],
        ["3", "midi/ctrl/2/number"],
        ["4", "midi/ctrl/3/number"],
      ]]],
      ['panel', 'foot', { color: 1 }, [[
        ["Formant Ctrl", "formant/ctrl/number"],
        ["FM Ctrl", "fm/ctrl/number"],
      ],[
        ["Foot Ctrl", "foot/ctrl/number"],
        ["Breath Ctrl", "breath/ctrl/number"],
      ]]],
      ['panel', 'play', { color: 1 }, [[
        ["Play Note 1", "preview/note/0"],
        ["2", "preview/note/1"],
        ["3", "preview/note/2"],
        ["4", "preview/note/3"],
      ],[
        ["Play Velo 1", "preview/velo/0"],
        ["2", "preview/velo/1"],
        ["3", "preview/velo/2"],
        ["4", "preview/velo/3"],
      ]]],
    ], 
    layout: [
      ['row', [["dev", 1]]],
      ['row', [["curve", 1]]],
      ['row', [["knob", 1],["mc", 1]]],
      ['row', [["foot", 1],["play",2]]],
      ['col', [["dev",1], ["curve", 1], ["knob", 1], ["foot", 2]]],
    ])
  }
}