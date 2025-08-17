
class MicronGlobalController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    grid(panel: "main", items: [[
      (PBKnob(label: "MIDI Channel"), [.channel]),
      (PBKnob(label: "Write Bank"), [.bank]),
      (PBKnob(label: "Write Location"), [.location]),
      ],[
      (PBKnob(label: "Fetch Bank"), [.dump, .bank]),
      (PBKnob(label: "Fetch Location"), [.dump, .location]),
      ]])
    
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([[("main", 1)]], spacing: "-s1-")
    addColorToAll()
  }
}

