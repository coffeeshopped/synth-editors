const { pageCtrlr } = require('/core/Controller.js')
  
function controller(vc) {    
  vc.panel("vol", [[
    [{l: "Voice Vol"}, "volume"]
  ]])
  
  vc.panel("ctrl", [[
    [{l: "Tempo"}, "tempo"],
    [{l: "Clock Divide", ctrl: "select"}, "clock/divide"],
    [{l: "Sequencer", ctrl: "checkbox"}, "seq/on"],
    [{l: "Seq Trigger", ctrl: "select"}, "seq/trigger"],
    [{l: "Arp", ctrl: "checkbox"}, "arp/on"],
    [{l: "Arp Mode", ctrl: "switch"}, "arp/mode"],
  ]])
  
  fullCtrlr(vc, require('voice.js'))
}

function fullCtrlr(vc, voiceController) {
  vc.panel("switch", [[
    [{ctrl: "segmented", items: ["Voice", "Sequencer"], id: "switch"}, null]
  ]])
  
  vc.layRow([["switch", 4], ["vol", 2], ["ctrl", 12]], {pinned: true})
  vc.layRow([["page",1]], {pinned: true})
  vc.layCol([["switch",1],["page",8]], {pinned: true})
  
  vc.colorPanels(["vol", "ctrl"], {level: 1})
  vc.colorPanels(["switch"], {level: 1, clearBG: true})
  
  vc.setControllerFns([
    voiceController,
    require('seq.js'),
  ])
}
  
module.exports = () => pageCtrlr(controller)

