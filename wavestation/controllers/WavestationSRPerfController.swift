
class WavestationSRPerfController : NewPagedEditorController {
    
  private let partsController = PartsController()
  private let fxController = FXController()
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch", "levels"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch", 6), ("levels", 10),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",8),
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Parts", "FX"])
    quickGrid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil, "switchCtrl")]])

  }

//  override func apply(colorGuide: ColorGuide) {
//    view.backgroundColor = backgroundColor(forColorGuide: colorGuide)
//    colorAllPanels(colorGuide: colorGuide)
//    panels["switch"]?.backgroundColor = .clear
//  }

  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return partsController
    default:
      return fxController
    }
  }
  
  
  class PartsController : NewPatchEditorController {

    override func loadView(_ view: PBView) {
      (0..<8).forEach {
        let vc = PartController()
        vc.index = $0
        addChild(vc, withPanel: "part\($0)")
      }
      addPanelsToLayout(andView: view)

      layout.addGridConstraints([(0..<8).map { ("part\($0)", 1) }], pinMargin: "", spacing: "-s1-")
    }

//    override func apply(colorGuide: ColorGuide) {
//      colorAllPanels(colorGuide: colorGuide)
//    }

    
    class PartController : NewPatchEditorController {
      
      override var prefix: SynthPath? { return [.part, .i(index)] }
      
      override var index: Int {
        didSet { patch.label = "Part \(index + 1)" }
      }
      
      private let patch = PBSelect(label: "Patch")
      
      private var patchNames = [[Int:String]]()
      
      override func loadView(_ view: PBView) {
        quickGrid(view: view, items: [[
          (patch, [.patch], nil),
          ],[
          (PBKnob(label: "Bank"), [.bank], nil),
          (PBKnob(label: "Level"), [.level], nil),
          ],[
          (PBKnob(label: "Trans"), [.transpose], nil),
          (PBKnob(label: "Detune"), [.detune], nil),
          ],[
          (PBKnob(label: "Lo Key"), [.key, .lo], nil),
          (PBKnob(label: "Hi Key"), [.key, .hi], nil),
          ],[
          (PBKnob(label: "Lo Velo"), [.velo, .lo], nil),
          (PBKnob(label: "Hi Velo"), [.velo, .hi], nil),
          ],[
          (PBCheckbox(label: "Sustain"), [.sustain], nil),
          (PBKnob(label: "Delay"), [.delay], nil),
          ],[
          (PBSelect(label: "Tuning"), [.micro], nil),
          (PBKnob(label: "Key"), [.micro, .key], nil),
          ],[
          (PBSwitch(label: "Poly"), [.poly], nil),
          (PBSwitch(label: "Key Pri"), [.key, .assign], nil),
          ]])
        
        patchNames.append([:])
        patchNames.append([:])
        patchNames.append([:])

        addPatchChangeBlock(path: [.patch]) { (value) in
          view.alpha = value == 255 ? 0.4 : 1
        }
        addPatchChangeBlock(path: [.bank]) { [weak self] (value) in
          self?.updatePatchOptions(value)
        }
        addParamChangeBlock { [weak self] (params) in
          (0..<3).forEach { bank in
            guard let param = params.params[[.patch, .name, .i(bank)]] as? OptionsParam else { return }
            self?.patchNames[bank] = param.options
          }
          if let value = self?.latestValue(path: [.bank]) {
            self?.updatePatchOptions(value)
          }
        }
      }
      
      private func updatePatchOptions(_ value: Int) {
        var options = value > 2 ? WavestationSRPerfPatch.patchOptions[value - 3] : patchNames[value]
        options[255] = "Off"
        patch.options = options
      }

    }
  }
  
  class FXController : NewPatchEditorController {
        
    
    override func loadView(_ view: PBView) {

    }

//    override func apply(colorGuide: ColorGuide) {
//      colorAllPanels(colorGuide: colorGuide)
//    }
    
  }
}
