
class SY77MultiController : NewPagedEditorController {
  
  private let partsController = SY77MultiPartsController()
  private let fxController = SY77MultiFXController()
  
  convenience init(hideIndivOut: Bool) {
    self.init()
    partsController.hideIndivOut = hideIndivOut
  }

  override func loadView(_ view: PBView) {
    switchCtrl = PBSegmentedControl(items: ["Parts 1–8", "9–16", "FX"])
    grid(panel: "switch", items: [[(switchCtrl, nil)]])
    
    createPanels(forKeys: ["space"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch", 8), ("space", 4)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("switch",1),("page",8)], pinned: true, spacing: "-s1-")
    
    addColor(panels: ["switch"], clearBackground: true)

  }
  
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 2:
      return fxController
    default:
      partsController.index = index
      return partsController
    }
  }
}

class SY77MultiPartsController : TG77MultiPartsController {
  override var prefix: SynthPath? { return nil }
}

class SY77MultiFXController : TG77MultiFXController {
  override var prefix: SynthPath? { return nil }
}
