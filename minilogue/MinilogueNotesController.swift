
class MinilogueNotesController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.seq, .i(index)] }

  override func loadView(_ view: PBView) {
    (0..<16).forEach { step in
      let gate = PBKnob(label: "Gate")
      grid(panel: "p\(step)", items: [
        [(PBKnob(label: "Note"), [.step, .i(step), .note])],
        [(PBKnob(label: "Velo"), [.step, .i(step), .velo])],
        [(gate, [.step, .i(step), .gate])],
        [(PBCheckbox(label: "\(step + 1)"), [.step, .i(step), .trigger])],
        ])
      
      addBlocks(control: gate, path: [.step, .i(step), .gate], paramAfterBlock: nil) {
        gate.value = min($0, 73)
      } controlChangeValueBlock: {
        gate.value > 72 ? 127 : gate.value
      }
      addPatchChangeBlock(path: [.step, .i(step), .trigger]) { [weak self] in
        self?.panels["p\(step)"]?.alpha = $0 == 0 ? 0.4 : 1
      }
    }
    
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([(0..<16).map { ("p\($0)", 1) }], pinMargin: "", spacing: "-s1-")
    
    addColorToAll(level: 2)
  }
  
//  override func controlChange(_ control: PBLabeledControl) {
//    guard let step = step(forGateControl: control) else {
//      super.controlChange(control)
//      return }
//
//    // update both gate time and trigger
//    let gateTimeValue = (control.value > 72 ? 127 : control.value)
//    editor?.set(value: gateTimeValue, forKey: "Step\(step)Gate\(part)")
//
//    // gate > 72 means a value of TIE. set to never retrigger NEXT STEP on TIE
//    if let stepNum = Int(step) {
//      if stepNum < 16 {
//        editor?.set(value: (gateTimeValue > 72 ? 0 : 1), forKey: "Step\(stepNum+1)Trigger\(part)")
//      }
//    }
//  }

  class ActionController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.seq, .i(index)] }

    override func loadView() {
      let button = createMenuButton(titled: "Notes")
      self.view = button
      
      registerForEditMenu(button, bundle: (
        paths: { Self.AllPaths },
        pasteboardType: "com.cfshpd.Minilogue-NotesSeq",
        initialize: { [Int](repeating: 0, count: 64) },
        randomize: {
          return [Int]((0..<16).map { _ in
            [
              (0...127).random()!,
              (0...127).random()!,
              (0...127).random()!,
              (0...1).random()!,
            ]
          }.joined())
        }
      ))
    }
    
    static let AllPaths = [SynthPath]((0..<16).map {
      return [[.step, .i($0), .note],
              [.step, .i($0), .velo],
              [.step, .i($0), .gate],
              [.step, .i($0), .trigger]] as [SynthPath]
      }.joined())
  }
  
}
