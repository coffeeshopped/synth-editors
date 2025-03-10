
class DX200SystemController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["channel"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("channel",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("channel",1)], pinned: true, spacing: "-s1-")
    
    quickGrid(panel: "channel", items: [[
      (PBKnob(label: "Synth Ch"), [.voice, .channel], nil),
      (PBKnob(label: "Rhythm 1 Ch"), [.rhythm, .i(0), .channel], nil),
      (PBKnob(label: "Rhythm 2 Ch"), [.rhythm, .i(1), .channel], nil),
      (PBKnob(label: "Rhythm 3 Ch"), [.rhythm, .i(2), .channel], nil),
      (PBKnob(label: "FX Gate Length"), [.fx, .gate], nil),
      (PBSwitch(label: "Loop Type"), [.loop, .type], nil),
      ]])
    
    addColorToAll()
  }
  
}
