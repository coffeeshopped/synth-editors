
class Deepmind12ArpController : NewPatchEditorController {
  
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0
    paddedView.verticalPadding = 0.1
    let view = paddedView.mainView
    
    grid(panel: "len", items: [[(PBKnob(label: "Length"), [.length])]])
    
    let velos = (1...32).map { PBKnob(label: $0 > 2 ? "\($0)" : "Velo \($0)")}
    let gates = (1...32).map { PBKnob(label: $0 > 2 ? "\($0)" : "Gate \($0)")}

    grid(panel: "velo0", items: [
      (0..<16).map {
        let step = $0 * 2
        return (velos[step], [.i(step), .velo])
      } + [(SpacerItem(text: nil, gridWidth: 1), nil)]
    ])

    grid(panel: "velo1", items: [
      [(SpacerItem(text: nil, gridWidth: 1), nil)] + (0..<16).map {
        let step = $0 * 2 + 1
        return (velos[step], [.i(step), .velo])
      }
    ])

    grid(panel: "gate0", items: [
      (0..<16).map {
        let step = $0 * 2
        return (gates[step], [.i(step), .gate])
      } + [(SpacerItem(text: nil, gridWidth: 1), nil)]
    ])

    grid(panel: "gate1", items: [
      [(SpacerItem(text: nil, gridWidth: 1), nil)] + (0..<16).map {
        let step = $0 * 2 + 1
        return (gates[step], [.i(step), .gate])
      }
    ])

    createPanels(forKeys: ["space"])
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([
      [("len", 1), ("space", 15)],
      [("velo0", 1)],
      [("velo1", 1)],
      [("gate0", 1)],
      [("gate1", 1)],
    ], spacing: "-s1-")
    
    addPatchChangeBlock(path: [.length]) { value in
      (0..<32).forEach {
        velos[$0].isHidden = $0 > value
        gates[$0].isHidden = $0 > value
      }
    }
    
    layout.activateConstraints()
    self.view = paddedView

    addColor(panels: ["len", "velo0", "velo1"], level: 1)
    addColor(panels: ["gate0", "gate1"], level: 2)
  }
  
}
