
class JD800PartsController : NewPatchEditorController {
  
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0.1
    let view = paddedView.mainView
    
    (0..<6).forEach {
      let vc = PartController()
      vc.index = $0
      addChild(vc, withPanel: "vc\($0)")
    }
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([[("vc0", 1), ("vc1", 1), ("vc2", 1), ("vc3", 1), ("vc4", 1), ("vc5", 1)]], pinMargin: "", spacing: "-s1-")
    
    layout.activateConstraints()
    self.view = paddedView
    
    addColorToAll()
  }
  
  
  class PartController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.part, .i(index)] }
    
    override var index: Int {
      didSet { label.text = index == 5 ? "Special" : "Part \(index + 1)" }
    }
    
    private let label = LabelItem()
    
    override func loadView(_ view: PBView) {
      label.textAlignment = .center
      
      let pan = PBKnob(label: "Pan")
      let fxMode = PBSwitch(label: "FX Mode")
      let fxLevel = PBKnob(label: "FX Level")
      
      if index == 5 {
        pan.isHidden = true
        fxMode.isHidden = true
        fxLevel.isHidden = true
      }
      
      quickGrid(view: view, items: [[
        (label, nil, "label"),
        ],[
        (PBKnob(label: "Level"), [.level], nil),
        (pan, [.pan], nil),
        ],[
        (PBKnob(label: "MIDI Ch"), [.channel], nil),
        (PBSwitch(label: "Out Assign"), [.out], nil),
        ],[
        (fxMode, [.fx, .mode], nil),
        (fxLevel, [.fx, .level], nil),
        ]])
    }
  }
  
}
