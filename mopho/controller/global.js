const { ctrlr } = require('/core/Controller.js')

function controller(vc) {
  vc.panel("tune", [[
    [{l: "Transpose"}, "semitone"],
    [{l: "Detune"}, "detune"],
    [{l: "MIDI Ch"}, "channel"],
    [{l: "MIDI Clock", ctrl: "select"}, "clock"],
    [{l: "MIDI Out", ctrl: "switch"}, "midi/out"],
  ]])
  
  vc.panel("param", [[
    [{l: "Param Send", ctrl: "switch"}, "param/send"],
    [{l: "Param Rcv", ctrl: "switch"}, "param/rcv"],
    [{l: "Ctrl", ctrl: "checkbox"}, "ctrl"],
    [{l: "Sysex", ctrl: "checkbox"}, "sysex"],
    [{l: "Audio Out", ctrl: "switch"}, "out"],
  ]])
  
  vc.layGrid([
    [["tune", 1]],
    [["param", 1]],
  ], {})

  
  vc.colorAllPanels()
}

module.exports = () => ctrlr(controller)