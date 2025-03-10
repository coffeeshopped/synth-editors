
class TG33MultiController : NewPatchEditorController {
  
  private let partsController = TG33MultiPartsController()

  override var index: Int {
    didSet { partsController.index = index }
  }
  
  override func loadView(_ view: PBView) {
    addChild(partsController, withPanel: "parts")
    createPanels(forKeys: ["switch","fx"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch", 4), ("fx", 12),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([
      ("parts", 1),
      ], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1), ("parts", 8),
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["1-8","9-16"])
    quickGrid(panel: "switch", items: [[(switchCtrl, nil, "switchCtrl")]])
    
    quickGrid(panel: "fx", items: [[
      (PBSelect(label: "Effect"), [.common, .fx, .type], nil),
      (PBKnob(label: "Balance"), [.common, .fx, .balance], nil),
      (PBKnob(label: "G1 > FX"), [.common, .fx, .send, .i(0)], nil),
      (PBKnob(label: "G2 > FX"), [.common, .fx, .send, .i(1)], nil),
      (PBSwitch(label: "Group 1"), [.common, .out, .i(0)], nil),
      (PBSwitch(label: "Group 2"), [.common, .out, .i(1)], nil),
      (PBSwitch(label: "Assign"), [.common, .assign], nil),
      ]])
    
    addColor(panels: ["fx"])
    addColor(panels: ["switch"], clearBackground: true)

  }
      
}


class TG33MultiPartsController : NewPatchEditorController {
  
  override var index: Int {
    didSet {
      vcs.enumerated().forEach { $0.element.index = $0.offset + (8 * index) }
    }
  }

  private var vcs: [TG33MultiPartController]!
  
  override func loadView(_ view: PBView) {
    vcs = addChildren(count: 8, panelPrefix: "vc")
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([(0..<8).map { ("vc\($0)", 1) }], pinMargin: "", spacing: "-s1-")
    addColorToAll()
  }
}

class TG33MultiPartController : NewPatchEditorController {
  
  private let on = PBSwitch(label: "1")
  
  override var index: Int {
    didSet { on.label = "\(index + 1)" }
  }
  
  override var prefix: SynthPath? { return [.part, .i(index)] }
  
  override func loadView(_ view: PBView) {
    let pgmDropdown = PBSelect(label: "Voice")
    quickGrid(view: view, items: [
      [(PBSwitch(label: "Memory"), [.bank], nil)],
      [(pgmDropdown, [.number], nil)],
      [(PBInvertedKnob(label: "Volume"), [.volume], nil)],
      [(PBSelect(label: "Pan"), [.pan], nil)],
      [(PBKnob(label: "Note Shift"), [.note, .shift], nil)],
      [(PBKnob(label: "Detune"), [.detune], nil)],
      [(PBSwitch(label: "Group"), [.group], nil)],
      [(on, [.on], nil)],
      ])
    
    let pgmOptionsBlock: ((Int) -> Void) = { [weak self] (value) in
      let options: [Int:String]
      switch value {
      case 0:
        guard let internalOptions = self?.internalOptions else { return }
        options = internalOptions
      default:
        guard value < 3 else { return }
        options = OptionsParam.makeOptions(TG33VoiceBank.ramBanks[value - 1])
      }
      pgmDropdown.options = options
    }
    addParamChangeBlock { [weak self] in
      guard let param = $0.params[[.patch, .name]] as? OptionsParam else { return }
      self?.internalOptions = param.options
      if let bank = self?.latestValue(path: [.bank]) {
        pgmOptionsBlock(bank)
      }
    }
    addPatchChangeBlock(path: [.on]) { view.alpha = $0 == 0 ? 0.5 : 1 }
    addPatchChangeBlock(path: [.bank], valueChangeBlock: pgmOptionsBlock)
  }
  
  private var internalOptions = [Int:String]()
  
}
