
class MiniakVoiceIndexController : NewPatchEditorController {
    
  override func loadView(_ view: PBView) {
    let statusLabel = createLabel()
    statusLabel.textAlignment = .center
    grid(panel: "main", items: [[(statusLabel, nil)]])
    
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([[("main",1)]], spacing: "-s1-")
    
    addPatchChangeBlock { (changes) in
      guard let patch = changes.changes.1 as? MiniakVoiceIndexPatch else { return }
      statusLabel.text = patch.count == 0 ? "Please Fetch Table of Contents!" : "\(patch.count) Programs on synth"
    }
    
    addColorToAll()
  }
}
