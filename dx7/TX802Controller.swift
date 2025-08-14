
//open class TX802Controller<ExtraController:PBViewController> : NewPagedEditorController {
//  
//  private let opsController = OpsController()
//  private let extraController = ExtraController()
//      
//  open override func loadView(_ view: PBView) {
//    let algoController = NewFMAlgoController<TX802MiniOpController>()
//    addChild(algoController, withPanel: "algo")
//    algoController.initContainer(opCount: 6, algorithms: DX7Patch.algorithms(), algoPath: [.voice, .algo])
//    createPanels(forKeys: ["algoKnob","opSwitch","pitch","lfo"])
//    addPanelsToLayout(andView: view)
//    
//    layout.addRowConstraints([
//      ("algo",7),("algoKnob",2),("lfo",3),("pitch",4)
//      ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
//    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
//    layout.addColumnConstraints([
//      ("algo",4),("page",5)
//      ], pinned: true, spacing: "-s1-")
//    layout.addColumnConstraints([
//      ("algoKnob",3),("opSwitch",1)
//      ], pinned: false, spacing: "-s1-")
//    layout.addEqualConstraints(forItemKeys: ["algo","opSwitch","pitch"], attribute: .bottom)
//    layout.addEqualConstraints(forItemKeys: ["algoKnob","lfo"], attribute: .bottom)
//    layout.addEqualConstraints(forItemKeys: ["opSwitch","lfo"], attribute: .trailing)
//    layout.addEqualConstraints(forItemKeys: ["pitch","page"], attribute: .trailing)
//    
//    
//    quickGrid(panel: "algoKnob", items: [[
//      (PBKnob(label: "Algorithm"), [.voice, .algo], nil),
//      (PBSwitch(label: "Mode"), [.extra, .mono], nil),
//      ],[
//      (PBKnob(label: "Feedback"), [.voice, .feedback], nil),
//      (PBCheckbox(label: "Osc Sync"), [.voice, .osc, .sync], nil),
//      ]])
//    
//    switchCtrl = PBSegmentedControl(items: ["Ops 1–3", "Ops 4–6", "Other"])
//    quickGrid(panel: "opSwitch", items: [[(switchCtrl, nil, "opCtrl")]])
//
//    
//    let pitchEnv = PBRateLevelEnvelopeControl(label: "Pitch")
//    pitchEnv.sustainPoint = 2
//    pitchEnv.bipolar = true
//    
//    quickGrid(panel: "pitch", items: [[
//      (PBSwitch(label: "Env Range"), [.extra, .pitch, .env, .range], nil),
//      (pitchEnv, nil, "pitchEnv"),
//      (PBKnob(label: "Rate Scale"), [.extra, .pitch, .env, .rate, .scale], nil),
//      ],[
//      (PBKnob(label: "R1"), [.voice, .pitch, .env, .rate, .i(0)], nil),
//      (PBKnob(label: "R2"), [.voice, .pitch, .env, .rate, .i(1)], nil),
//      (PBKnob(label: "R3"), [.voice, .pitch, .env, .rate, .i(2)], nil),
//      (PBKnob(label: "R4"), [.voice, .pitch, .env, .rate, .i(3)], nil),
//      ],[
//      (PBKnob(label: "L1"), [.voice, .pitch, .env, .level, .i(0)], nil),
//      (PBKnob(label: "L2"), [.voice, .pitch, .env, .level, .i(1)], nil),
//      (PBKnob(label: "L3"), [.voice, .pitch, .env, .level, .i(2)], nil),
//      (PBKnob(label: "L4"), [.voice, .pitch, .env, .level, .i(3)], nil),
//      ],[
//      (PBKnob(label: "Transpose"), [.voice, .transpose], nil),
//      (PBKnob(label: "Random"), [.extra, .random, .pitch], nil),
//      (PBKnob(label: "Bend Range"), [.extra, .bend, .range], nil),
//      (PBKnob(label: "Bend Step"), [.extra, .bend, .step], nil),
//      ]])
//    
//    quickGrid(panel: "lfo", items: [[
//      (PBSelect(label: "LFO Wave"), [.voice, .lfo, .wave], nil),
//      (PBKnob(label: "Speed"), [.voice, .lfo, .speed], nil),
//      ],[
//      (PBKnob(label: "Delay"), [.voice, .lfo, .delay], nil),
//      (PBCheckbox(label: "Key Sync"), [.voice, .lfo, .sync], nil),
//      (PBSwitch(label: "Trig Mode"), [.extra, .lfo, .trigger, .mode], nil),
//      ],[
//      (PBKnob(label: "AMD"), [.voice, .lfo, .amp, .mod, .depth], nil),
//      (PBKnob(label: "PMD"), [.voice, .lfo, .pitch, .mod, .depth], nil),
//      (PBKnob(label: "Pitch Mod"), [.voice, .lfo, .pitch, .mod], nil),
//      ]])
//
//    (0..<4).forEach { step in
//      addPatchChangeBlock(path: [.voice, .pitch, .env, .rate, .i(step)]) {
//        pitchEnv.set(rate: 1 - CGFloat($0) / 99, forIndex: step)
//      }
//      addPatchChangeBlock(path: [.voice, .pitch, .env, .level, .i(step)]) {
//        pitchEnv.set(level: CGFloat($0 - 50) / 50, forIndex: step)
//      }
//    }
//    
//    let paths: [SynthPath] = (0..<4).map { [.voice, .pitch, .env, .rate, .i($0)] } +
//      (0..<4).map { [.voice, .pitch, .env, .level, .i($0)] }
//    registerForEditMenu(pitchEnv, bundle: (
//      paths: { paths },
//      pasteboardType: "com.cfshpd.DX7PitchEnv",
//      initialize: nil,
//      randomize: nil
//    ))
//    
//    addColor(panels: ["algoKnob", "pitch", "lfo"], level: 2)
//    addColor(panels: ["opSwitch"], level: 2, clearBackground: true)
//
//  }
//  
//
//  open override func viewController(forIndex index: Int) -> PBViewController? {
//    switch index {
//    case 2:
//      return extraController
//    default:
//      opsController.hi = index > 0
//      return opsController
//    }
//  }
//  
//  
//  class OpsController : NewPatchEditorController {
//    
//    private var opControllers: [TX802OpController]!
//    
//    var hi = false {
//      didSet {
//        opControllers?.enumerated().forEach { $0.element.index = $0.offset + (hi ? 3 : 0) }
//      }
//    }
//    
//    override func loadView(_ view: PBView) {
//      opControllers = addChildren(count: 3, panelPrefix: "op")
//      addPanelsToLayout(andView: view)
//      
//      layout.addGridConstraints([[("op0",1), ("op1",1), ("op2",1)]], pinMargin: "", spacing: "-s1-")
//      addColorToAll()
//    }
//        
//  }
//
//}
