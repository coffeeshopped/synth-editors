
class WavestationSRGlobalController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["main"])
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([[("main", 1)]], spacing: "-s1-")
    
    quickGrid(panel: "main", items: [[
      (PBKnob(label: "MIDI Channel"), [.channel], nil),
      (PBKnob(label: "Write Bank"), [.bank], nil),
      (PBKnob(label: "Write Location"), [.location], nil),
      ],[
      (PBKnob(label: "Fetch Bank"), [.dump, .bank], nil),
      (PBKnob(label: "Fetch Location"), [.dump, .location], nil),
      ]])
  }
  
//  override func apply(colorGuide: ColorGuide) {
//    view.backgroundColor = backgroundColor(forColorGuide: colorGuide)
//    colorAllPanels(colorGuide: colorGuide)
//  }
  
}

