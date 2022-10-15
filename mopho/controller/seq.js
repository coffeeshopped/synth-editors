require('/core/NumberUtils.js')
const { ctrlr } = require('/core/Controller.js')

function controller(vc) {
  vc.addChildren(4, "trk", (index) => ctrlr(trackController, index))
  vc.layGridCol(4, "trk", {})
  vc.colorAllPanels()
}

function trackController(vc, index) {
  vc.prefix(() => ["seq", index])

  vc.panel("ctrl", [
    [[{l: "Sequence "+(index + 1), ctrl: "label", width: 2, align: "center"}, null]],
    [[{l: "Destination", ctrl: "select"}, "dest"]],
    [[{l: "Edit", ctrl: "button", id: "button"}, null]],
  ])  
    
  vc.registerForEditMenu("button", {
    paths: () => (16).map((i) => ["step", i]),
    pasteboardType: "com.cfshpd.MophoSeqTrack",
    initialize: () => (16).map(() => 0) ,
    randomize: () => (16).map(() => (128).rand()),
  })
  
  const noteMap = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
  var items = []
  for (let i=0; i<16; ++i) {
    const id = "step" + i
    items.push([{l: "", ctrl: "slider", id: id}, ["step", i]])
    
    vc.onPatchChange(["step", i], v => {
      let l = ""
      switch (v) {
      case 127:
        l = "Rest"
        break
      case 126:
        l = "Reset"
        break
      default:
        l = "" + noteMap[Math.floor((v % 24) / 2)] + (v % 2 == 1 ? "+" : "") + Math.floor(v / 24)
      }
      vc.get(id).config({l: l})
    })
    
  }
  vc.panel("sliders", [items])
  
  vc.layGrid([
    [["ctrl", 2], ["sliders", 16]]
  ])
  
  vc.colorAllPanels()

}

module.exports = () => ctrlr(controller)
