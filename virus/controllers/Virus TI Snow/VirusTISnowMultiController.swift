
class VirusTISnowMultiController : NewPagedEditorController {
  
  private let commonController = CommonController()
  let partController = VoiceWrapperController()
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch"])
    addPanelsToLayout(andView: view)

    layout.addRowConstraints([("switch", 4)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page", 1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",8)
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Common", "1", "2", "3", "4"])
    grid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil)]])
    
    addColor(panels: ["switch"], level: 2, clearBackground: true)
  }
  
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return commonController
    default:
      partController.index = index - 1
      return partController
    }
  }
  
  
  class CommonController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.common] }
    
    override func loadView(_ view: PBView) {
      let _: [PartController] = addChildren(count: 4, panelPrefix: "part")
      createPanels(forKeys: ["clock", "space"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("clock", 1), ("part0", 2), ("part1", 2), ("part2", 2), ("part3", 2), ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("clock", 1), ("space", 6)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["space", "part0", "part1", "part2", "part3"], attribute: .bottom)
      
      grid(panel: "clock", items: [[
        (PBKnob(label: "Clock"), [.clock])
      ]])
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
          (PBSwitch(label: "Output"), [.out]),
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
          guard let index = self?.index else { return }
          let pc: PatchChange = .replace(patch)
          module.synthEditor.changePatch(forPath: [.multi], pc.prefixed([.part, .i(index)]), transmit: true)
          let nameChange: PatchChange = .nameChange([.part, .i(index)], patch.name)
          module.synthEditor.changePatch(forPath: [.multi], nameChange, transmit: true)
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
