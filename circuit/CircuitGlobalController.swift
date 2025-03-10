
class CircuitGlobalController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["main"])
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([[("main",1)]], pinMargin: "-s1-", spacing: "-s1-")

    quickGrid(panel: "main", items: [[
      (PBKnob(label: "Synth 1 Channel"), [.channel, .i(0)], nil),
      (PBKnob(label: "Synth 2 Channel"), [.channel, .i(1)], nil),
      ]])
    addColorToAll()
  }
    
}
