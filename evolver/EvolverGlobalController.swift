
class EvolverGlobalController : NewPatchEditorController {

  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0.1
    paddedView.verticalPadding = 0.2
    let view = paddedView.mainView
    
    createPanels(forKeys: ["midi", "volume", "tempo"])
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([[
      ("midi", 3), ("volume", 5),
      ],[
      ("tempo", 8),
      ]], spacing: "-s1-")
    
    quickGrid(panel: "midi", items: [[
      (PBKnob(label: "MIDI Ch"), [.channel], nil),
      (PBSwitch(label: "MIDI Rcv"), [.midi, .rcv], nil),
      (PBSwitch(label: "MIDI Send"), [.midi, .send], nil),
      ]])

    quickGrid(panel: "volume", items: [[
      (PBKnob(label: "Volume"), [.volume], nil),
      (PBKnob(label: "Transpose"), [.transpose], nil),
      (PBKnob(label: "Fine Tune"), [.fine], nil),
      (PBKnob(label: "Bank"), [.bank], nil),
      (PBKnob(label: "Pgm #"), [.pgm], nil),
      ]])

    quickGrid(panel: "tempo", items: [[
      (PBKnob(label: "Tempo"), [.tempo], nil),
      (PBSelect(label: "Clock Div"), [.clock, .divide], nil),
      (PBCheckbox(label: "Use Pgm Tempo"), [.pgm, .tempo], nil),
      (PBSelect(label: "Clock"), [.midi, .clock], nil),
      (PBCheckbox(label: "Lock Seq"), [.lock, .seq], nil),
      (PBSwitch(label: "Poly Chain"), [.poly, .chain], nil),
      (PBKnob(label: "In Gain"), [.input, .gain], nil),
      ]])

    layout.activateConstraints()
    self.view = paddedView
    
    addColorToAll()
  }
  
}
