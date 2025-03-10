
class ProphecyArpController : NewPatchEditorController {
  
  override var index: Int {
    didSet {
      pushPatchChange(.paramsChange([[.number] : index]))
      arpController.arp = index
    }
  }
  
  private let arpController = ArpController()
  
  override func loadView(_ view: PBView) {
    addChild(arpController, withPanel: "arp")
    
    switchCtrl = PBSegmentedControl(items: ProphecyArpBank.names)
    grid(panel: "switch", items: [[(switchCtrl, nil)]])

    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([
      (row: [("switch", 1)], height: 1),
      (row: [("arp", 1)], height: 8),
    ], spacing: "-s1-")
    
    addColor(panels: ["switch"], clearBackground: true)
    addBorder(panel: "arp")
  }
      
  
  class ArpController : NewPatchEditorController {
    private let offsets = (0..<12).map { _ in PBKnob(label: "Offset") }
    private let tones = (0..<12).map { _ in PBKnob(label: "Tone") }
    private let velos = (0..<12).map { _ in PBKnob(label: "Velo") }
    private let gates = (0..<12).map { _ in PBKnob(label: "Gate") }
    private let veloParam = PBKnob(label: "Velo Param")
    private let gateParam = PBKnob(label: "Gate")
    
    var arp: Int = 0 {
      didSet {
//        let notUser = arp < 5
//        ["offset", "tone", "velo", "gate"].forEach { panels[$0]?.isHidden = notUser }
//        veloParam.maximumValue = notUser ? 128 : 129
//        gateParam.maximumValue = notUser ? 100 : 101
      }
    }
    
    override var index: Int {
      didSet {
        (0..<12).forEach {
          let i = index * 12 + 1 + $0
          offsets[$0].label = "Offset \(i)"
          tones[$0].label = "Tone \(i)"
          velos[$0].label = "Velo \(i)"
          gates[$0].label = "Gate \(i)"
        }
      }
    }

    override func loadView(_ view: PBView) {
      let labeledSwitch = LabeledSegmentedControl(label: "Steps", items: ["1-12", "13-24"])
      switchCtrl = labeledSwitch.segmentedControl
      grid(panel: "switch", items: [[(labeledSwitch, nil)]])
      
      grid(panel: "main", items: [[
        (PBSelect(label: "Step Base"), [.step, .time]),
        (PBCheckbox(label: "Sort"), [.sortOrder]),
        (PBKnob(label: "Scan Lo"), [.key, .lo]),
        (PBKnob(label: "Scan Hi"), [.key, .hi]),
        (veloParam, [.velo]),
        (PBKnob(label: "←Int"), [.velo, .ctrl, .amt]),
        (gateParam, [.gate]),
        (PBKnob(label: "←Int"), [.gate, .ctrl, .amt]),
        (PBSwitch(label: "Type"), [.type]),
        (PBSwitch(label: "Oct Alt"), [.octave, .alt]),
      ]])
      
      grid(panel: "offset", items: [(0..<12).map { (offsets[$0], nil) }])
      grid(panel: "tone", items: [(0..<12).map { (tones[$0], nil) }])
      grid(panel: "velo", items: [(0..<12).map { (velos[$0], nil) }])
      grid(panel: "gate", items: [(0..<12).map { (gates[$0], nil) }])

      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        [("switch", 4), ("main", 10.5)],
        [("offset", 12)],
        [("tone", 12)],
        [("velo", 12)],
        [("gate", 12)],
      ], spacing: "-s1-")
            
      func setupCtrl(_ ctrl: PBLabeledControl, step: Int, path: SynthPathItem) {
        defaultConfigure(control: ctrl, forParam: ProphecyArpPatch.params[[.step, .i(0), path]]!)
        addPatchChangeBlock { [weak self] changes in
          let index = self?.index ?? 0
          guard let value = Self.updatedValue(path: [.step, .i(index * 12 + step), path], state: changes) else { return }
          ctrl.value = value
        }
        addControlChangeBlock(control: ctrl) { [weak self] in
          let index = self?.index ?? 0
          let path: SynthPath = [.step, .i(index * 12 + step), path]
          return .paramsChange([path : ctrl.value])
        }
      }
      
      (0..<12).forEach { k in
        setupCtrl(offsets[k], step: k, path: .offset)
        setupCtrl(tones[k], step: k, path: .tone)
        setupCtrl(velos[k], step: k, path: .velo)
        setupCtrl(gates[k], step: k, path: .gate)
      }
      
      index += 0
      arp = 0
      
      addColorToAll(except: ["switch"])
      addColor(panels: ["switch"], clearBackground: true)

    }
    
  }
  

}
