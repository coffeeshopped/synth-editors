
class VirusCMultiController : NewPagedEditorController {
  
  private let commonController = CommonController()
  let partsController = PartsController()
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch"])
    addPanelsToLayout(andView: view)

    layout.addRowConstraints([("switch", 4)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page", 1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",8)
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Common", "Parts 1–8", "Parts 9–16"])
    grid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil)]])
    
    addColor(panels: ["switch"], clearBackground: true)
  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return commonController
    default:
      partsController.index = index - 1
      return partsController
    }
  }
  
  
  class CommonController : NewPatchEditorController {
    
    override func loadView() {
      let paddedView = PaddedContainer()
      let view = paddedView.mainView
      
      addChild(DelayController(), withPanel: "delay")
      createPanels(forKeys: ["clock", "out", "space"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("clock", 1), ("out", 2), ("space", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("delay", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("clock", 1), ("delay", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      grid(panel: "clock", items: [[
        (PBKnob(label: "Clock"), [.clock])
      ]])
      
      grid(panel: "out", items: [[
        (PBSelect(label: "Delay Out"), [.delay, .out])
      ]])
      
      layout.activateConstraints()
      self.view = paddedView
      addColorToAll()
    }
  }
  
  class DelayController : VirusCVoiceController.DelayController {
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSelect(label: "Delay"), [.mode]),
        (clock, [.clock]),
        (time, [.time]),
        (feedbk, [.feedback]),
        ],[
        (color, [.color]),
        (wave, [.shape]),
        (rate, [.rate]),
        (depth, [.depth]),
      ]])
    }
  }
  
  class PartsController : NewPatchEditorController {
    
    override var index: Int {
      didSet { (0..<8).forEach { parts[$0].index = $0 + (8 * index) } }
    }
    
    let parts = (0..<8).map { _ in PartController() }
    
    override func loadView(_ view: PBView) {
      (0..<8).forEach { addChild(parts[$0], withPanel: "part\($0)")}
      addPanelsToLayout(andView: view)
      layout.addGridConstraints([(0..<8).map { ("part\($0)", 1) }], pinMargin: "", spacing: "-s1-")
      addColorToAll()
    }
  }
  
  class PartController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.part, .i(index)] }

    override var index: Int {
      didSet { on.label = "Part \(index + 1)" }
    }
    
    private let on = PBCheckbox(label: "On")

    private var patchNameOptions: [[Int:String]] = (0..<2).map { _ in [:] }

    override func loadView(_ view: PBView) {
      let patchSelect = PBSelect(label: "Patch")
      grid(view: view, items: [[
        (on, [.on]),
        (PBKnob(label: "Channel"), [.channel]),
        ],[
        (PBSelect(label: "Bank"), [.bank]),
        (patchSelect, [.pgm]),
        ],[
        (PBKnob(label: "Key Lo"), [.key, .lo]),
        (PBKnob(label: "Key Hi"), [.key, .hi]),
        ],[
        (PBKnob(label: "Transpose"), [.transpose]),
        (PBKnob(label: "Detune"), [.detune]),
        ],[
        (PBKnob(label: "Volume"), [.volume]),
        (PBKnob(label: "Pan"), [.pan]),
        ],[
        (PBKnob(label: "FX Send"), [.fx]),
        (PBKnob(label: "Init Vol"), [.innit, .volume]),
        ],[
        (PBSelect(label: "Output"), [.out]),
        (PBCheckbox(label: "Volume RX"), [.rcv, .volume]),
        ],[
        (PBCheckbox(label: "Hold Pdl"), [.hold]),
        (PBSwitch(label: "Priority"), [.priority]),
        (PBCheckbox(label: "Pgm Ch"), [.rcv, .pgmChange]),
      ]])
      
      addPatchChangeBlock(path: [.on]) {
        view.alpha = $0 == 0 ? 0.4 : 1
      }
      
      let updatePatchOptions: ((Int) -> Void) = { [weak self] (bank) in
        switch bank {
        case 0...1:
          patchSelect.options = self?.patchNameOptions[bank] ?? [:]
        default:
          patchSelect.options = OptionsParam.makeOptions(VirusCMultiPatch.presetNames[bank - 2]) 
        }
      }
      addParamChangeBlock { [weak self] (params) in
        (0..<2).forEach {
          guard let param = params.params[[.patch, .name, .i($0)]] as? OptionsParam else { return }
          self?.patchNameOptions[$0] = param.options
          guard let bank = self?.latestValue(path: [.bank]) else { return }
          updatePatchOptions(bank)
        }
      }
      addPatchChangeBlock(path: [.bank]) {
        updatePatchOptions($0)
      }
    }
  }
  
}
