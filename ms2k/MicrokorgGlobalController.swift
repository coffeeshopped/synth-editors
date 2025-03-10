
class MicrokorgGlobalController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["main"])
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([[("main", 1)]], spacing: "-s1-")
    
    let velo = PBKnob(label: "Velo")
    quickGrid(panel: "main", items: [[
      (PBKnob(label: "Tune"), [.tune], nil),
      (PBKnob(label: "Transpose"), [.transpose], nil),
      (PBSwitch(label: "Position"), [.post], nil),
      (PBKnob(label: "Velo Curve"), [.velo, .curve], nil),
      (velo, [.velo], nil),
      (PBCheckbox(label: "Protect"), [.protect], nil),
      ],[
      (PBCheckbox(label: "Local"), [.local], nil),
      (PBKnob(label: "MIDI Chan"), [.channel], nil),
      (PBSwitch(label: "Clock"), [.clock], nil),
      (PBCheckbox(label: "Bend"), [.bend, .on], nil),
      (PBCheckbox(label: "CC"), [.ctrl, .on], nil),
      (PBCheckbox(label: "Pgm Ch"), [.pgmChange, .on], nil),
    ]])
    
    addPatchChangeBlock(path: [.velo, .curve]) { velo.isHidden = $0 != 8 }
    addColorToAll()
  }
}
