
public class JD800SettingsController : NewPatchEditorController {
  
  public override func loadView(_ view: PBView) {
    createPanels(forKeys: ["main"])
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([[("main", 1)]], spacing: "-s1-")
    
    quickGrid(panel: "main", items: [[
      (PBKnob(label: "Device ID"), [.deviceId], nil),
      (PBKnob(label: "Channel"), [.channel], nil),
      (PBSelect(label: "PCM Card"), [.pcm], nil),
      ]])
    
    addColorToAll()
  }
  
}

