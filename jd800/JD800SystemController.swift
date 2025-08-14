
class JD800SystemController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["eq", "tune", "delay", "chorus", "reverb"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("tune", 1), ("eq", 3), ("chorus", 6)
    ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([("delay", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([("reverb", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([
      ("tune", 1), ("delay", 1), ("reverb", 1)
    ], pinned: true, pinMargin: "", spacing: "-s1-")

    quickGrid(panel: "eq", items: [[
      (PBKnob(label: "Lo"), [.lo], nil),
      (PBKnob(label: "Mid"), [.mid], nil),
      (PBKnob(label: "Hi"), [.hi], nil),
      ]])
    
    quickGrid(panel: "tune", items: [[
      (PBKnob(label: "Master Tune"), [.tune], nil),
      ]])
    
    quickGrid(panel: "delay", items: [[
      (PBCheckbox(label: "Delay"), [.delay, .on], nil),
      (PBKnob(label: "C Tap"), [.delay, .mid, .time], nil),
      (PBKnob(label: "C Level"), [.delay, .mid, .level], nil),
      (PBKnob(label: "L Tap"), [.delay, .left, .time], nil),
      (PBKnob(label: "L Level"), [.delay, .left, .level], nil),
      (PBKnob(label: "R Tap"), [.delay, .right, .time], nil),
      (PBKnob(label: "R Level"), [.delay, .right, .level], nil),
      (PBKnob(label: "Feedback"), [.delay, .feedback], nil),
      ]])
        
    quickGrid(panel: "chorus", items: [[
      (PBCheckbox(label: "Chorus"), [.chorus, .on], nil),
      (PBKnob(label: "Rate"), [.chorus, .rate], nil),
      (PBKnob(label: "Depth"), [.chorus, .depth], nil),
      (PBKnob(label: "Delay"), [.chorus, .delay], nil),
      (PBKnob(label: "Feedback"), [.chorus, .feedback], nil),
      (PBKnob(label: "Level"), [.chorus, .level], nil),
      ]])

    quickGrid(panel: "reverb", items: [[
      (PBCheckbox(label: "Reverb"), [.reverb, .on], nil),
      (PBSelect(label: "Type"), [.reverb, .type], nil),
      (PBKnob(label: "Pre Delay"), [.reverb, .pre], nil),
      (PBKnob(label: "Early Ref"), [.reverb, .early], nil),
      (PBKnob(label: "HF Damp"), [.reverb, .hi, .cutoff], nil),
      (PBKnob(label: "Time"), [.reverb, .time], nil),
      (PBKnob(label: "Level"), [.reverb, .level], nil),
      ]])

    let disabledAlpha: CGFloat = 0.5
    addPatchChangeBlock(path: [.delay, .on]) { [weak self] (value) in
      self?.panels["delay"]?.alpha = value == 1 ? 1 : disabledAlpha
    }
    addPatchChangeBlock(path: [.chorus, .on]) { [weak self] (value) in
      self?.panels["chorus"]?.alpha = value == 1 ? 1 : disabledAlpha
    }
    addPatchChangeBlock(path: [.reverb, .on]) { [weak self] (value) in
      self?.panels["reverb"]?.alpha = value == 1 ? 1 : disabledAlpha
    }
    
    addColorToAll()
  }
  
}
