
public class Deepmind12ModeController : NewPatchEditorController {
    
  public override func loadView(_ view: PBView) {
    grid(panel: "main", items: [[(PBSelect(label: "Connection Mode"), [.mode])]])
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([[("main", 1)]], spacing: "-s1-")
    addColorToAll()
  }
    
}


