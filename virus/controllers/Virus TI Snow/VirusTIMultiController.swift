
class VirusTIMultiController : NewPagedEditorController {
  
  private let commonController = CommonController()
  let partController = VoiceWrapperController()
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch", "tempo"])
    addPanelsToLayout(andView: view)

    layout.addRowConstraints([("switch", 16), ("tempo", 1)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page", 1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",8)
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["1–8", "9–16"] + (1...16).map { "\($0)" })
    grid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil)]])
    
    grid(panel: "tempo", items: [[(PBKnob(label: "Clock"), [.common, .clock])]])

    addColor(panels: ["switch"], level: 2, clearBackground: true)
    addColor(panels: ["tempo"], level: 2)

  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0, 1:
      commonController.index = index
      return commonController
    default:
      partController.index = index - 2
      return partController
    }
  }
  
  
  class CommonController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.common] }
    
    override var index: Int {
      didSet { (0..<8).forEach { parts?[$0].index = $0 + (index * 8) } }
    }
    
    private var parts: [PartController]!
    
    override func loadView(_ view: PBView) {
      parts = addChildren(count: 8, panelPrefix: "part")
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([(0..<8).map { ("part\($0)", 1) }], pinMargin: "", spacing: "-s1-")
      addColorToAll()
    }
    
    
    class PartController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.part, .i(index)] }

      override var index: Int {
        didSet { on.label = "Part \(index + 1)" }
      }
      
      private let on = PBCheckbox(label: "On")

      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (on, [.on]),
          (PBKnob(label: "Channel"), [.channel]),
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
          (PBKnob(label: "Init Volume"), [.innit, .volume]),
          (PBSelect(label: "Output"), [.out]),
          ],[
          (PBCheckbox(label: "Volume RX"), [.rcv, .volume]),
          (PBCheckbox(label: "Hold Pedal"), [.hold]),
          ],[
          (PBSwitch(label: "Priority"), [.priority]),
          (PBCheckbox(label: "Pgm Change"), [.rcv, .pgmChange]),
        ]])
        
        addPatchChangeBlock(path: [.on]) {
          view.alpha = $0 == 0 ? 0.4 : 1
        }
      }
    }
  }
  
  class VoiceWrapperController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.part, .i(index)] }
    let voiceController = VoiceController()

    override func loadView(_ view: PBView) {
      addChild(voiceController, withPanel: "voice")
      addPanelsToLayout(andView: view)
      layout.addGridConstraints([[("voice", 1)]], pinMargin: "", spacing: "-s1-")
    }
  }
  
  class VoiceController : VirusTISnowVoiceController {
    
    private let labeledNameField = LabeledTextField(label: "Name")
    override var namePath: SynthPath? { return [] }

    override func loadView(_ view: PBView) {
      createPanels(forKeys: ["name", "switch", "popover"])
      addPanelsToLayout(andView: view)

      layout.addRowConstraints([
        ("name", 4), ("switch", 8), ("popover", 2),
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("page",1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([
        ("name",1),("page",7)
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      
      nameTextField = labeledNameField.textField
      grid(panel: "name", items: [[(labeledNameField, nil)]])

      switchCtrl = PBSegmentedControl(items: ["Main", "Mod", "FX", "Arp"])
      grid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil)]])
      
      popoverButton = createButton(titled: "Patch")
      popoverButton.addClickTarget(self, action: #selector(popoverTap(_:)))
      grid(panel: "popover", items: [[(popoverButton, nil)]])

      addColor(panels: ["name"])
      addColor(panels: ["switch", "popover"], clearBackground: true)
    }
        
    private var popoverButton: PBButton!
    var popover: PopoverPatchBrowserController! {
      didSet {
        popover?.sysexibleSelectedHandler = { [weak self] (patch, module) in
          self?.pushPatchChange(.paramsChange(patch.allValues()))
          self?.pushPatchChange(.nameChange([], patch.name))
        }
      }
    }

    #if os(iOS)
      
    @objc func popoverTap(_ sender: Any) {
      guard let popover = popover else { return }
      popover.setStyle()
      popover.popoverPresentationController?.sourceView = popoverButton
      popover.popoverPresentationController?.sourceRect = popoverButton.bounds
      present(popover, animated: true)
    }
    
    #else
      
    @objc func popoverTap(_ sender: Any) {
      guard let popover = popover else { return }
      present(popover, asPopoverRelativeTo: popoverButton.bounds, of: popoverButton, preferredEdge: .maxX, behavior: .semitransient)
    }
    
    #endif
    
  }
}
