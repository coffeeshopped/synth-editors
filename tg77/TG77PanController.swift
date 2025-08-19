
class TG77PanController : NewPatchEditorController {
  
  private var panNameOptions = [Int:String]()

  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0.1
    paddedView.verticalPadding = 0.1
    let view = paddedView.mainView
    
    let envController = PanEnvController()
    addChild(envController)
        
    let panSelect = PBSelect(label: "Pan")
    grid(panel: "sel", items: [[(panSelect, nil)]])

    let holdTime = PBKnob(label: "Hold Time")
    grid(panel: "main", items: [[
      (PBSwitch(label: "Source"), [.src]),
      (PBKnob(label: "Src Depth"), [.depth]),
      (envController.view, nil),
      (PBKnob(label: "Loop Pt"), [.loop, .pt]),
      ],[
      (PBKnob(label: "L0"), [.level, .i(-1)]),
      (PBKnob(label: "L1"), [.level, .i(0)]),
      (PBKnob(label: "L2"), [.level, .i(1)]),
      (PBKnob(label: "L3"), [.level, .i(2)]),
      (PBKnob(label: "L4"), [.level, .i(3)]),
      (PBKnob(label: "RL1"), [.release, .level, .i(0)]),
      (PBKnob(label: "RL2"), [.release, .level, .i(1)]),
      ],[
      (holdTime, nil),
      (PBKnob(label: "R1"), [.rate, .i(0)]),
      (PBKnob(label: "R2"), [.rate, .i(1)]),
      (PBKnob(label: "R3"), [.rate, .i(2)]),
      (PBKnob(label: "R4"), [.rate, .i(3)]),
      (PBKnob(label: "RR1"), [.release, .rate, .i(0)]),
      (PBKnob(label: "RR2"), [.release, .rate, .i(1)]),
      ]])
    
    createPanels(forKeys: ["space"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("sel", 2), ("space", 5)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("main", 1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("sel",1), ("main",3)], pinned: true, spacing: "-s1-")

    layout.activateConstraints()
    self.view = paddedView
    
    addPatchChangeBlock(path: [.hold, .time]) { holdTime.value = 63 - $0 }
    addDefaultControlChangeBlock(control: holdTime, path: [.hold, .time], valueBlock: { 63 - holdTime.value })
    holdTime.maximumValue = 63
    
    panSelect.options = OptionsParam.makeOptions((0..<32).map { "I-\($0 + 1)" })
    
//    addParamChangeBlock { params in
//      guard let param = params.params[[.pan, .name]] as? OptionsParam else { return }
//      panSelect.options = param.options
//    }
    
    addDefaultPatchChangeBlock(control: panSelect, path: [.number])
    addDefaultControlChangeBlock(control: panSelect, path: [.number])
    
    addColorToAll(except: ["space"])

  }
      
  
  class PanEnvController : NewPatchEditorController, TG77EnvelopeController {
    let env = TG77EnvelopeControl(label: "Pan")

    override var prefix: SynthPath? { return [] }
    
    override func loadView() {
      env.pointCount = 4
      env.releaseCount = 2
      env.bipolar = true
      self.view = env
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      addHoldBlock()
      (0..<env.pointCount).forEach {
        addRateBlock(step: $0)
        addLevelBlock(step: $0)
      }
      (0..<env.releaseCount).forEach {
        addRateBlock(step: $0, release: true)
        addLevelBlock(step: $0, release: true)
      }
      addStartLevelBlock()
      let env = self.env
      addPatchChangeBlock(path: [.loop, .pt]) { env.sustainPoint = $0 }
    }
    
    func addLevelBlock(step: Int, release: Bool = false) {
      let env = self.env
      let transform: ((Int) -> CGFloat) =  { CGFloat($0 - 32) / 31 }
      if release {
        addPatchChangeBlock(path: [.release, .level, .i(step)]) {
          env.set(releaseLevel: transform($0), forIndex: step)
        }
      }
      else {
        addPatchChangeBlock(path: [.level, .i(step)]) {
          env.set(level: transform($0), forIndex: step)
        }
      }
    }

    func addStartLevelBlock() {
      let env = self.env
      addPatchChangeBlock(path: [.level, .i(-1)]) { env.startLevel = CGFloat($0 - 32) / 31 }
    }

  }
}
