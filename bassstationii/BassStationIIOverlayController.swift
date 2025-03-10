
class BassStationIIOverlayController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.key, .i(index)] }
  
  // doing this for popover loading (which uses index, see below
  override var index: Int {
    didSet { keyController.index = index }
  }
  
  let keyController = KeyController()
  
  override func loadView(_ view: PBView) {
    addChild(keyController, withPanel: "key")
    
    let noteSelect = BSIINoteSelectControl()
    noteSelect.columnCount = 25
    var opts = [Int:String]()
    (0..<25).forEach { opts[$0] = "\($0 + 1)" }
    noteSelect.options = opts
    noteSelect.value = 0
    noteSelect.addValueChangeTarget(self, action: #selector(selectNote(_:)))
    grid(panel: "switch", items: [[(noteSelect, nil)]])

    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([
      (row: [("switch", 1)], height: 1),
      (row: [("key", 1)], height: 8),
    ], spacing: "-s1-")
    
    addColor(panels: ["switch"], level: 3, clearBackground: true)
  }
  
  @IBAction func selectNote(_ sender: PBGridSelectControl) {
    index = sender.value
    playNote()
  }
    
  var transmitter: MIDINoteTransmitter? { return firstTypedAncestor() }
  
  func playNote() {
    let note = 48 + index
    let transmitter = self.transmitter
    transmitter?.noteOn(note, velocity: 100, channel: nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
      transmitter?.noteOff(note, channel: nil)
    }
  }
    
  
  class KeyController : NewPatchEditorController {
        
    override var namePath: SynthPath? { return [] }

    private let patchesButton = createButton(titled: "Patches")
    
    override func loadView(_ view: PBView) {
      addChild(BassStationIIVoiceController.OscController(prefix: [.osc, .i(0)], label: "Osc 1"), withPanel: "osc0")
      addChild(BassStationIIVoiceController.OscController(prefix: [.osc, .i(1)], label: "Osc 2"), withPanel: "osc1")
      addChild(BassStationIIVoiceController.OscController(prefix: [.sub], label: "Osc 3"), withPanel: "osc2")
      
      let _: [BassStationIIVoiceController.LFOController] = addChildren(count: 2, panelPrefix: "lfo")
      addChild(BassStationIIVoiceController.EnvController(prefix: [.mod, .env], label: "Mod"), withPanel: "mod")
      addChild(BassStationIIVoiceController.EnvController(prefix: [.amp, .env], label: "Amp"), withPanel: "amp")

      grid(panel: "mix", items: [[
        (PBKnob(label: "Osc 1"), [.osc, .i(0), .level]),
        (PBKnob(label: "Noise"), [.noise, .level]),
        ],[
        (PBKnob(label: "Osc 2"), [.osc, .i(1), .level]),
        (PBKnob(label: "Ring"), [.ringMod, .level]),
        ],[
        (PBKnob(label: "Sub"), [.sub, .level]),
        (PBKnob(label: "Ext"), [.ext, .level]),
      ]])

      grid(panel: "para", items: [[
        (PBKnob(label: "Out Level"), [.level]),
        (PBKnob(label: "Pitch"), [.pitch]),
        (PBCheckbox(label: "Osc Sync"), [.sync]),
        (PBSwitch(label: "Sub Mode"), [.sub, .mode]),
      ]])
      
      grid(panel: "sub", items: [[
        (PBSwitch(label: "Sub Shape"), [.sub, .sub, .wave]),
        (PBSwitch(label: "Octave"), [.sub, .sub, .octave]),
        (PBKnob(label: "Coarse"), [.sub, .coarse]),
        (PBKnob(label: "Fine"), [.sub, .fine]),
      ]])

      let shape = PBSwitch(label: "Shape")
      let slope = PBSwitch(label: "Slope")
      grid(panel: "filter", items: [[
        (PBSwitch(label: "Filter Type"), [.filter, .type]),
        (shape, [.filter, .shape]),
        (slope, [.filter, .slop]),
        (PBKnob(label: "Cutoff"), [.filter, .cutoff]),
        (PBKnob(label: "Reson"), [.filter, .reson]),
        (PBKnob(label: "Overdrive"), [.filter, .drive]),
        (PBKnob(label: "Env Amt"), [.filter, .mod, .env, .cutoff, .amt]),
        (PBKnob(label: "LFO2 Amt"), [.filter, .lfo, .i(1), .cutoff, .amt]),
      ]])
      
      addPatchChangeBlock(path: [.filter, .type]) {
        let alpha: CGFloat = $0 == 0 ? 1 : 0.2
        shape.alpha = alpha
        slope.alpha = alpha
      }

      let labeledNameField = LabeledTextField(label: "Key Name")
      self.nameTextField = labeledNameField.textField
      grid(panel: "name", items: [[
        (labeledNameField, nil),
      ]])
      
      let on = PBCheckbox(label: "On")
      let menuButton = createButton(titled: "Key")
      grid(panel: "menu", items: [[
        (menuButton, nil),
        (patchesButton, nil),
        (on, nil),
      ]])
      
      grid(panel: "fx", items: [[
        (PBKnob(label: "Distortion"), [.dist]),
        (PBKnob(label: "Osc Filter Mod"), [.osc, .filter, .mod]),
        (PBKnob(label: "Limiter"), [.limiter]),
      ]])
            
      let afterLabel = LabelItem(text: "Aftertouch", gridWidth: 1)
      afterLabel.textAlignment = .center
      grid(panel: "after", itemsAndHeights: [
        (row: [(afterLabel, nil)], height: 0.5),
        (row: [
          (PBKnob(label: "LFO1>Pitch"), [.aftertouch, .lfo, .i(0), .pitch]),
          (PBKnob(label: "LFO2 Speed"), [.aftertouch, .lfo, .i(1), .speed]),
          (PBKnob(label: "Cutoff"), [.aftertouch, .filter, .cutoff]),
        ], height: 2),
      ])

      addPatchChangeBlock(path: [.sub, .mode]) { [weak self] in
        self?.panels["osc2"]?.alpha = $0 == 1 ? 1 : 0.2
        self?.panels["sub"]?.alpha = $0 == 0 ? 1 : 0.2
      }
      
      addPatchChangeBlock(path: [.mute]) { on.checked = $0 == 0 }
      addControlChangeBlock(control: on, block: {
        .paramsChange([[.mute] : on.checked ? 0 : 1])
      }, controlledPaths: [[.mute]])
            
      addPatchChangeBlock(path: [.mute]) { [weak self] in
        let hidden = $0 != 0
        ["mix", "osc0", "osc1", "osc2", "filter", "para", "mod", "amp", "lfo0", "lfo1", "sub", "name", "after", "fx"].forEach { self?.panels[$0]?.isHidden = hidden }
      }

      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("mix", 2), ("osc0", 9), ("name", 5)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
      layout.addRowConstraints([("filter", 8), ("para", 4)], pinned: true, spacing: "-s1-")
      layout.addRowConstraints([("mod", 6), ("lfo0", 3), ("fx", 3)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
      layout.addRowConstraints([("amp", 6), ("lfo1", 3)], pinned: false, spacing: "-s1-")
      
      layout.addColumnConstraints([("mix", 3), ("filter", 1), ("mod", 2), ("amp", 2)], pinned: true, spacing: "-s1-")
      layout.addColumnConstraints([("osc0", 1), ("osc1", 1), ("osc2", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      layout.addColumnConstraints([("name", 1), ("menu", 1), ("sub", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      layout.addColumnConstraints([("fx", 2), ("after", 2.5)], pinned: false, spacing: "-s1-")
      
      layout.addEqualConstraints(forItemKeys: ["lfo0", "lfo1"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["fx", "after"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["mix", "osc2", "sub"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["mod", "lfo0"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["amp", "after"], attribute: .bottom)
      
      let paths = BassStationIIOverlayKeyPatch.paramKeys()
      registerForEditMenu(menuButton, bundle: (
        paths: { paths },
        pasteboardType: "com.cfshpd.BSIIOverlay",
        initialize: { [] },
        randomize: { [] }
      ))
//      addMenuItem(PBMenuItem(title: "Clear", action: #selector(clear(_:)), keyEquivalent: ""))

      patchesButton.addClickTarget(self, action: #selector(showPatches(_:)))
      
      addColor(panels: ["name", "menu"], level: 0)
      addColor(panels: ["osc0", "osc1", "osc2", "mix", "sub", "para", "tune"])
      addColor(panels: ["filter", "fx"], level: 2)
      addColor(panels: ["mod", "amp", "lfo0", "lfo1", "after"], level: 3)
    }
    
    override func initialize(_ sender: Any?) {
      pushPatchChange(.replace(BassStationIIOverlayKeyPatch.fromVoicePatch(BassStationIIVoicePatch.init())))
    }
    
    override func randomize(_ sender: Any?) {
      pushPatchChange(.replace(BassStationIIOverlayKeyPatch.random()))
    }
    
    @IBAction func clear(_ sender: Any?) {
      pushPatchChange(.paramsChange([[.mute] : 1]))
    }
    
    var popover: PopoverPatchBrowserController! {
      didSet {
        popover?.sysexibleSelectedHandler = { [weak self] (patch, module) in
          guard let index = self?.index,
                let voicePatch = patch as? BassStationIIVoicePatch else { return }
          let pc: PatchChange = .replace(BassStationIIOverlayKeyPatch.fromVoicePatch(voicePatch))
          module.synthEditor.changePatch(forPath: [.extra], pc.prefixed([.key, .i(index)]), transmit: true)
          let nameChange: PatchChange = .nameChange([.key, .i(index)], patch.name)
          module.synthEditor.changePatch(forPath: [.extra], nameChange, transmit: true)
        }
      }
    }

      
    @IBAction func showPatches(_ sender: Any?) {
      guard let popover = popover else { return }
      popover.savePath = [.extra, .key, .i(index)]
      
      #if os(iOS)
      popover.setStyle()
      popover.popoverPresentationController?.sourceView = patchesButton
      popover.popoverPresentationController?.sourceRect = patchesButton.bounds
      present(popover, animated: true)
      #else
      present(popover, asPopoverRelativeTo: patchesButton.bounds, of: patchesButton, preferredEdge: .maxX, behavior: .semitransient)
      #endif
    }
        
  }
}
