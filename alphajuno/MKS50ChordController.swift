
class MKS50ChordController : NewPatchEditorController {
      
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0.1
    paddedView.verticalPadding = 0.3
    let view = paddedView.mainView
      
    let notes = (0..<6).map { PBKnob(label: "Note \($0 + 1)")}
    grid(panel: "notes", items: [notes.map { ($0, nil) }])
    
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([[("notes", 1)]])

    layout.activateConstraints()
    self.view = paddedView
    
    let miso = Miso.switcher([
      .int(35, "Off"),
      .range(36...60, Miso.a(-60) >>> Miso.str()),
      .range(61...84, Miso.a(-60) >>> Miso.str("+%g")),
    ])
    let misoParam = MisoParam.make(range: 35...84, iso: miso)
    notes.enumerated().forEach {
      let knob = $0.element
      defaultConfigure(control: knob, forParam: misoParam)
      addPatchChangeBlock(path: [.note, .i($0.offset)]) { knob.value = $0 == 127 ? 35 : $0 }
      addDefaultControlChangeBlock(control: knob, path: [.note, .i($0.offset)]) {
        knob.value == 35 ? 127 : knob.value
      }
    }
    
    addColorToAll()
  }
      
}
