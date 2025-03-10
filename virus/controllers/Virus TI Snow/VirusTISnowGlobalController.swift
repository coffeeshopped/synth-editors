
class VirusTISnowGlobalController : NewPatchEditorController {
  
  override func loadView() {
    let paddedView = PaddedContainer()
    let view = paddedView.mainView
    createPanels(forKeys: ["glob"])
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([[("glob", 1)]])
    
    grid(panel: "glob", items: [[
      (PBKnob(label: "Global Channel"), [.channel]),
      (PBKnob(label: "Device ID"), [.deviceId]),
    ]])
    
    layout.activateConstraints()
    self.view = paddedView
    addColorToAll()
  }
  
}
