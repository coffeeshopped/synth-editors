
//public class DX7Controller : NewPatchEditorController {
//  
//  private var opControllers: [DX7OpController]!
//  
//  public override func loadView(_ view: PBView) {
//    let algoController = NewFMAlgoController<DX7MiniOpController>()
//    addChild(algoController, withPanel: "algo")
//    algoController.initContainer(opCount: 6, algorithms: DX7Patch.algorithms())
//
//    opControllers = addChildren(count: 3, panelPrefix: "op")
//    createPanels(forKeys: ["algoKnob","opSwitch","pitch","lfo"])
//    addPanelsToLayout(andView: view)
//
//    layout.addRowConstraints([
//      ("algo",7),("algoKnob",2),("pitch",4),("lfo",3)
//      ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
//    layout.addRowConstraints([
//      ("op0",1), ("op1",1), ("op2",1),
//      ], pinned: true, spacing: "-s1-")
//    layout.addColumnConstraints([
//      ("algo",3),("op0",5)
//      ], pinned: true, spacing: "-s1-")
//    layout.addColumnConstraints([
//      ("algoKnob",2),("opSwitch",1)
//      ], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
//    layout.addEqualConstraints(forItemKeys: ["algo","opSwitch","pitch","lfo"], attribute: .bottom)
//    
//    
//    quickGrid(panel: "algoKnob", items: [[
//      (PBKnob(label: "Algorithm"), [.algo], nil),
//      ],[
//      (PBKnob(label: "Feedback"), [.feedback], nil),
//      (PBCheckbox(label: "Osc Sync"), [.osc, .sync], nil),
//      ]])
//    
//    let opSwitch = LabeledSegmentedControl(label: "Ops", items: ["1–3","4–6"])
//    opSwitch.segmentedControl.addValueChangeTarget(self, action: #selector(selectOps(_:)))
//    quickGrid(panel: "opSwitch", items: [[(opSwitch, nil, "opCtrl")]])
//    
//    
//    let pitchEnv = PBRateLevelEnvelopeControl(label: "Pitch")
//    pitchEnv.sustainPoint = 2
//    pitchEnv.bipolar = true
//    
//    quickGrid(panel: "pitch", items: [[
//      (pitchEnv, nil, "pitchEnv"),
//      (PBKnob(label: "Transpose"), [.transpose], nil),
//      ],[
//      (PBKnob(label: "R1"), [.pitch, .env, .rate, .i(0)], nil),
//      (PBKnob(label: "R2"), [.pitch, .env, .rate, .i(1)], nil),
//      (PBKnob(label: "R3"), [.pitch, .env, .rate, .i(2)], nil),
//      (PBKnob(label: "R4"), [.pitch, .env, .rate, .i(3)], nil),
//      ],[
//      (PBKnob(label: "L1"), [.pitch, .env, .level, .i(0)], nil),
//      (PBKnob(label: "L2"), [.pitch, .env, .level, .i(1)], nil),
//      (PBKnob(label: "L3"), [.pitch, .env, .level, .i(2)], nil),
//      (PBKnob(label: "L4"), [.pitch, .env, .level, .i(3)], nil),
//      ]])
//        
//    quickGrid(panel: "lfo", items: [[
//      (PBSelect(label: "LFO Wave"), [.lfo, .wave], nil),
//      (PBKnob(label: "Speed"), [.lfo, .speed], nil),
//      ],[
//      (PBKnob(label: "Delay"), [.lfo, .delay], nil),
//      (PBCheckbox(label: "Key Sync"), [.lfo, .sync], nil),
//      ],[
//      (PBKnob(label: "AMD"), [.lfo, .amp, .mod, .depth], nil),
//      (PBKnob(label: "PMD"), [.lfo, .pitch, .mod, .depth], nil),
//      (PBKnob(label: "Pitch Mod"), [.lfo, .pitch, .mod], nil),
//      ]])
//
//    (0..<4).forEach { step in
//      addPatchChangeBlock(path: [.pitch, .env, .rate, .i(step)]) {
//        pitchEnv.set(rate: 1 - CGFloat($0) / 99, forIndex: step)
//      }
//      addPatchChangeBlock(path: [.pitch, .env, .level, .i(step)]) {
//        pitchEnv.set(level: CGFloat($0 - 50) / 50, forIndex: step)
//      }
//    }
//    
//    let paths: [SynthPath] = (0..<4).map { [.pitch, .env, .rate, .i($0)] } + (0..<4).map { [.pitch, .env, .level, .i($0)] }
//    registerForEditMenu(pitchEnv, bundle: (
//      paths: { paths },
//      pasteboardType: "com.cfshpd.DX7PitchEnv",
//      initialize: nil,
//      randomize: nil
//    ))
//
//    addColor(panels: ["op0", "op1", "op2"], level: 1)
//    addColor(panels: ["algoKnob", "pitch", "lfo"], level: 2)
//    addColor(panels: ["opSwitch"], level: 2, clearBackground: true)
//
//  }
//  
//  
//  @IBAction func selectOps(_ sender: PBSegmentedControl) {
//    opControllers.enumerated().forEach { $0.element.index = $0.offset + 3 * sender.selectedSegmentIndex }
//  }
//  
//
//}
