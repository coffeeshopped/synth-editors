
public class JD990SettingsController : NewPatchEditorController {
  
  public override func loadView(_ view: PBView) {
    createPanels(forKeys: ["main"])
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([[("main", 1)]], spacing: "-s1-")
    
    grid(panel: "main", items: [[
      (PBKnob(label: "Device ID"), [.deviceId]),
      (PBSelect(label: "PCM Card"), [.pcm]),
      (PBSelect(label: "Exp Board"), [.extra]),
      ]])
    
    addColorToAll()
  }
  
}

