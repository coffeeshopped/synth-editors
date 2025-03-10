
class WavestationSRWaveSeqBankController : NewPatchEditorController {
  
  private let seqController = SeqController()
  private let hiSwitch = PBSegmentedControl(items: ["0-15", "16-31"])
  private let loSwitch = PBSegmentedControl(items: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"])

  override func loadView(_ view: PBView) {
    addChild(seqController, withPanel: "seq")
    createPanels(forKeys: ["hi", "lo"])
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([
      (row: [("hi", 2), ("lo", 14)], height: 1),
      (row: [("seq", 1)], height: 8),
    ], spacing: "-s1-")
    
    hiSwitch.addValueChangeTarget(self, action: #selector(switchChanged(_:)))
    loSwitch.addValueChangeTarget(self, action: #selector(switchChanged(_:)))
    hiSwitch.selectedSegmentIndex = 0
    loSwitch.selectedSegmentIndex = 0

    quickGrid(panel: "hi", items: [[(hiSwitch, nil, "his")]])
    quickGrid(panel: "lo", items: [[(loSwitch, nil, "los")]])
  }
  
  @IBAction func switchChanged(_ sender: Any) {
    let hiOff = hiSwitch.selectedSegmentIndex * 16
    seqController.index = hiOff + loSwitch.selectedSegmentIndex
    (0..<16).forEach { loSwitch.setTitle("\($0 + hiOff)", forSegmentAt: $0) }
  }
  
//  override func apply(colorGuide: ColorGuide) {
//    view.backgroundColor = backgroundColor(forColorGuide: colorGuide)
//    colorPanels(["hi", "lo"], colorGuide: colorGuide)
//  }

  
  class SeqController : NewPatchEditorController {

    private let labeledNameField = LabeledTextField(label: "Sequence Name")

    override var index: Int {
      didSet { labeledNameField.label.text = "Sequence \(index)" }
    }
    
    override var prefix: SynthPath? { return [.seq, .i(index)] }

    override var namePath: SynthPath? { return [.name] }

    override func loadView(_ view: PBView) {
//      addChild(WavestationSRWaveSeqBankStepController(), withPanel: "steps")
      createPanels(forKeys: ["name", "loop", "mod"])
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        (row: [("name", 6), ("loop", 4), ("mod", 3.5)], height: 1),
        (row: [("steps", 1)], height: 7),
      ], pinMargin: "", spacing: "-s1-")

      nameTextField = labeledNameField.textField
      quickGrid(panel: "name", items: [[(labeledNameField, nil, "nameTF")]])
      
      let loopStart = PBKnob(label: "Loop Start")
      let loopEnd = PBKnob(label: "End")
      let modStart = PBKnob(label: "Mod Start")
      
      quickGrid(panel: "loop", items: [[
        (loopStart, [.loop, .start], nil),
        (loopEnd, [.loop, .end], nil),
        (PBSwitch(label: "Dir"), [.loop, .direction], nil),
        (PBKnob(label: "Repeat"), [.loop, .number], nil),
        ]])

      quickGrid(panel: "mod", items: [[
        (modStart, [.mod, .start, .step], nil),
        (PBSelect(label: "Source"), [.mod, .src], nil),
        (PBKnob(label: "Amount"), [.mod, .amt], nil),
        ]])
      
      let updateMaxVals: (Int) -> Void = {
        loopStart.maximumValue = $0 - 1
        loopEnd.maximumValue = $0 - 1
        modStart.maximumValue = $0 - 1
      }
      
      addPatchChangeBlock(path: [.step, .number]) { (value) in
        updateMaxVals(value)
      }
      addPatchChangeBlock(path: [.step, .insert]) { [weak self] _ in
        guard let value = self?.latestValue(path: [.step, .number]) else { return }
        updateMaxVals(value)
      }
      addPatchChangeBlock(path: [.step, .dump]) { [weak self] _ in
        guard let value = self?.latestValue(path: [.step, .number]) else { return }
        updateMaxVals(value)
      }

      index += 0
    }
        
//    override func apply(colorGuide: ColorGuide) {
//      colorAllPanels(colorGuide: colorGuide)
//    }
    
  }
  
}
