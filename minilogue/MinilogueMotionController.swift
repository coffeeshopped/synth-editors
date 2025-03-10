
class MinilogueMotionController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.seq, .i(index)] }

  override func loadView(_ view: PBView) {
    grid(panel: "switch", items: [[
      (PBCheckbox(label: "Motion"), [.motion, .on]),
      (PBSelect(label: "Parameter"), [.motion, .dest]),
      (PBCheckbox(label: "Smooth"), [.motion, .smooth])
      ]])

    let valueKnobs = (0..<16).map { _ in PBKnob(label: "Value") }
    (0..<16).forEach { step in
      grid(panel: "p\(step)", items: [
        [(valueKnobs[step], nil)],
        [(PBCheckbox(label: "\(step + 1)"), [.step, .i(step), .motion, .on])],
        ])
      
      addPatchChangeBlock(path: [.step, .i(step), .motion, .on]) { [weak self] in
        self?.panels["p\(step)"]?.alpha = $0 == 0 ? 0.4 : 1
      }
    }
    
    createPanels(forKeys: ["space", "bSpace"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch",1),("space",3)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints((0..<16).map { ("p\($0)",1) }, pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([("bSpace",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("switch",1),("p0",2),("bSpace",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["space","p15","bSpace"], attribute: .trailing)
    
    (0..<16).forEach { step in
      let knob = valueKnobs[step]
      knob.maximumValue = 255
      addPatchChangeBlock(path: [.step, .i(step), .motion, .data, .i(0)]) { knob.value = $0 }
      addControlChangeBlock(control: knob, block: {
        return .paramsChange([
          [.step, .i(step), .motion, .data, .i(0)] : knob.value,
          [.step, .i((step + 15) % 16), .motion, .data, .i(1)] : knob.value,
        ])
      })
    }
    
    addColorToAll(except: ["space", "bSpace"], level: 2)

  }
  
  
  class ActionController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.seq, .i(index)] }

    override func loadView() {
      let button = createMenuButton(titled: "Motion")
      self.view = button
      
      registerForEditMenu(button, bundle: (
        paths: { Self.AllPaths },
        pasteboardType: "com.cfshpd.Minilogue-MotionSeq",
        initialize: { [Int](repeating: 0, count: 48) },
        randomize: {
          return [Int]((0..<16).map { _ in
            [
              (0...1).random()!,
              (0...255).random()!,
              (0...255).random()!,
            ] }.joined())
        }
      ))
    }
    
    static let AllPaths = [SynthPath]((0..<16).map {
      return [
        [.step, .i($0), .motion, .on],
        [.step, .i($0), .motion, .data, .i(0)],
        [.step, .i($0), .motion, .data, .i(1)],
      ] as [SynthPath]
      }.joined())
  }

}
