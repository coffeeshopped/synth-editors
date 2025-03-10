
class DX200SeqAndPartController<SeqController:NewPatchEditorController, SeqPatch:SysexPatch> : NewPatchEditorController {

  let seqController = SeqController()
  let partController = PartController<SeqPatch>()
  let menuController = MenuController<SeqPatch>()

  override var index: Int {
    didSet {
      partController.index = index
      seqController.index = index
      menuController.index = index
    }
  }
    
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0
    paddedView.verticalPadding = 0.07
    let view = paddedView.mainView
    
    addChild(partController, withPanel: "part")
    addChild(seqController, withPanel: "seq")
    addChild(menuController, withPanel: "menu")
    createPanels(forKeys: ["space"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("part", 5), ("menu", 2), ("space", 9)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("seq",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("part",1),("seq",6)], pinned: true, spacing: "-s1-")
    
    layout.activateConstraints()
    self.view = paddedView
    
    addColor(panels: ["part"], level: 2)
    addColor(panels: ["menu"], level: 2, clearBackground: true)
  }
  
  
  class PartController<SeqPatch:SysexPatch> : NewPatchEditorController {
    
    private var voice: Bool {
      return SeqPatch.self == DX200VoiceSeqPatch.self
    }
    
    override var prefix: SynthPath? {
      return [.part, voice ? .voice : .i(index)]
    }
        
    override func loadView(_ view: PBView) {
      let cutoff = PBKnob(label: "Cutoff")
      let reson = PBKnob(label: "Reson")
      quickGrid(view: view, items: [[
        (PBKnob(label: "Volume"), [.volume], nil),
        (PBKnob(label: "Pan"), [.pan], nil),
        (PBKnob(label: "FX Send"), [.fx, .send], nil),
        (cutoff, [.cutoff], nil),
        (reson, [.reson], nil),
        ]])
      
      if voice {
        cutoff.isHidden = true
        reson.isHidden = true
      }
    }
  }
  
  
      
  class MenuController<SeqPatch:SysexPatch> : NewPatchEditorController {

    private var voice: Bool {
      return SeqPatch.self == DX200VoiceSeqPatch.self
    }

    override var prefix: SynthPath? {
      return voice ? [.voice, .seq] : [.rhythm, .i(index)]
    }

    fileprivate var menuButton = createMenuButton(titled: "Sequence")

    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[(menuButton, nil, "menuButton")]])
      
      let paths: [SynthPath] = voice ? [
        [.note], [.velo], [.gate, .lo], [.ctrl], [.gate, .hi], [.mute],
      ] : [
        [.voice], [.velo], [.gate, .lo], [.pitch], [.gate, .hi], [.mute],
      ]
      registerMenu(paths: paths)
    }
    
    func registerMenu(paths: [SynthPath]) {
      let copyPastePaths: [SynthPath] = {
        let pathArrs: [[SynthPath]] = (0..<16).map { step in
          paths.map { [.i(step)] + $0 }
        }
        return [SynthPath](pathArrs.joined())
      }()
      registerForEditMenu(menuButton, bundle: (
        paths: { copyPastePaths },
        pasteboardType: "com.cfshpd.DX200Sequence",
        initialize: nil,
        randomize: { [] }
      ))
    }
    
    override func randomize(_ sender: Any?) {
      pushPatchChange(.replace(SeqPatch.random()))
    }
  }

}


class DX200SeqController : NewPatchEditorController {
  
  fileprivate let veloKnobs: [PBVertSlider] = (0..<16).map { PBVertSlider(label: "Velo \($0+1)") }
  fileprivate let gateKnobs: [PBKnob] = (0..<16).map { PBKnob(label: "Gate \($0+1)") }
  fileprivate let muteChecks: [PBCheckbox] = (0..<16).map { PBCheckbox(label: "\($0+1)") }
  fileprivate let groupChecks: [PBCheckbox] = (0..<16).map { PBCheckbox(label: "⛓ \($0+1)") }
  
  var stepControls: [SynthPath:[PBLabeledControl]] { return [:] }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupKnobs()
    groupChecks.forEach { $0.addValueChangeTarget(self, action: #selector(linkToggle(_:))) }
  }
  
  func quickGrid(panel: String, ctrls: [PBLabeledControl]) {
    quickGrid(panel: panel, items: [(0..<16).map { (ctrls[$0], nil, "\(panel)\($0)") }])
  }

  func setupKnobs() {
    let stepControls = self.stepControls
    let gateKnobs = self.gateKnobs
    let muteChecks = self.muteChecks
    let groupChecks = self.groupChecks
    
    (0..<16).forEach { step in
      // gateKnobs
      let gateKnob = gateKnobs[step]
      gateKnob.maximumValue = 1023
      gateKnob.valueMap = DX200RhythmSeqPatch.gateOptions.sorted{ $0.0 < $1.0 }.map{ $0.1 }
      let loPath: SynthPath = [.i(step), .gate, .lo]
      let hiPath: SynthPath = [.i(step), .gate, .hi]
      addPatchChangeBlock(paths: [loPath, hiPath]) { (values) in
        let lo = values[loPath] ?? 0
        let hi = values[hiPath] ?? 0
        gateKnob.value = (hi << 7) + lo
      }
      addControlChangeBlock(control: gateKnob) {
        let value = gateKnob.value
        var changes: [SynthPath:Int] = [:]
        if groupChecks[step].checked {
          let groupSteps: [Int] = groupChecks.enumerated().compactMap { $0.element.value == 1 ? $0.offset : nil }
          groupSteps.forEach {
            changes[[.i($0), .gate, .lo]] = value & 0x7f
            changes[[.i($0), .gate, .hi]] = value >> 7
          }
        }
        else {
          changes[[.i(step), .gate, .lo]] = value & 0x7f
          changes[[.i(step), .gate, .hi]] = value >> 7
        }
        return MakeParamsChange(changes)
      }
      
      // muteChecks
      let muteCheck = muteChecks[step]
      let mutePath: SynthPath = [.i(step), .mute]
      addPatchChangeBlock(path: mutePath) { muteCheck.value = $0 == 0 ? 1 : 0 }
      addPatchChangeBlock(path: [.i(step), .mute]) {
        let alpha: CGFloat = $0 == 1 ? 0.2 : 1
        stepControls.forEach { $0.value[step].alpha = alpha }
      }
      addControlChangeBlock(control: muteCheck) {
        let value = muteCheck.value
        var changes: [SynthPath:Int] = [:]
        if groupChecks[step].checked {
          let groupSteps: [Int] = groupChecks.enumerated().compactMap { $0.element.value == 1 ? $0.offset : nil }
          groupSteps.forEach {
            changes[[.i($0), .mute]] = 1 - value
          }
        }
        else {
          changes[[.i(step), .mute]] = 1 - value
        }
        return MakeParamsChange(changes)
      }

      
      // the rest
      let skipKeys: [SynthPathItem] = [.gate, .mute]
      stepControls.forEach { (p, ctrls) in
        guard !skipKeys.contains(p.first!) else { return }
        let ctrl = ctrls[step]
        let path = [.i(step)] + p
        addDefaultParamChangeBlock(control: ctrl, path: path)
        addDefaultPatchChangeBlock(control: ctrl, path: path)
        addControlChangeBlock(control: ctrl) {
          let value = ctrl.value
          var changes: [SynthPath:Int] = [:]
          if groupChecks[step].checked {
            let groupSteps: [Int] = groupChecks.enumerated().compactMap { $0.element.value == 1 ? $0.offset : nil }
            groupSteps.forEach { changes[[.i($0)] + p] = value }
          }
          else {
            changes[path] = value
          }
          return MakeParamsChange(changes)
        }
      }
      
    }
  }

  @IBAction func linkToggle(_ sender: PBCheckbox) {
    guard let step = groupChecks.firstIndex(of: sender) else { return }
    let color = sender.checked ? lastTintColor : lastTextColor
    stepControls.forEach { $0.value[step].labelView.textColor = color }
  }
    
  var lastTintColor: PBColor = .blue
  var lastTextColor: PBColor = .blue
}

class DX200VoiceSeqController : DX200SeqController {
  
  override var prefix: SynthPath? { return [.voice, .seq] }
  
  fileprivate let noteKnobs: [PBKnob] = (0..<16).map { PBKnob(label: "Note \($0+1)") }
  fileprivate let ctrlKnobs: [PBKnob] = (0..<16).map { PBKnob(label: "Ctrl \($0+1)") }
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["note", "velo", "gate", "ctrl", "mute", "group"])
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([
      [("note", 1)],
      [("velo", 1)],
      [("gate", 1)],
      [("ctrl", 1)],
      [("mute", 1)],
      [("group", 1)],
      ], spacing: "-s1-")
    
    quickGrid(panel: "note", ctrls: noteKnobs)
    quickGrid(panel: "velo", ctrls: veloKnobs)
    quickGrid(panel: "gate", ctrls: gateKnobs)
    quickGrid(panel: "ctrl", ctrls: ctrlKnobs)
    quickGrid(panel: "mute", ctrls: muteChecks)
    quickGrid(panel: "group", ctrls: groupChecks)
    
    addColorToAll(except: ["group"])
    addColor(panels: ["group"], level: 3)
    addColorBlock { [weak self] in
      self?.lastTintColor = Self.tintColor(forColorGuide: $0)
      self?.lastTextColor = Self.textColor(forColorGuide: $0)
    }

  }
  
  override var stepControls: [SynthPath:[PBLabeledControl]] {
    return [
      [.velo] : veloKnobs,
      [.gate] : gateKnobs,
      [.mute] : muteChecks,
      [.note] : noteKnobs,
      [.ctrl] : ctrlKnobs,
    ]
  }
  
}


class DX200RhythmSeqController : DX200SeqController {
  
  override var prefix: SynthPath? { return [.rhythm, .i(index)] }
    
  private let noteSelects: [PBLabeledControl] = (0..<16).map { PBSelect(label: "Inst \($0 + 1)") }
  private let pitchKnobs: [PBKnob] = (0..<16).map { PBKnob(label: "Pitch \($0 + 1)") }

  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["note", "velo", "gate", "pitch", "mute", "group"])
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([
      [("note", 1)],
      [("velo", 1)],
      [("gate", 1)],
      [("pitch", 1)],
      [("mute", 1)],
      [("group", 1)],
      ], spacing: "-s1-")
    
    quickGrid(panel: "note", ctrls: noteSelects)
    quickGrid(panel: "velo", ctrls: veloKnobs)
    quickGrid(panel: "gate", ctrls: gateKnobs)
    quickGrid(panel: "pitch", ctrls: pitchKnobs)
    quickGrid(panel: "mute", ctrls: muteChecks)
    quickGrid(panel: "group", ctrls: groupChecks)
    
    addColorToAll(except: ["group"])
    addColor(panels: ["group"], level: 3)
    addColorBlock { [weak self] in
      self?.lastTintColor = Self.tintColor(forColorGuide: $0)
      self?.lastTextColor = Self.textColor(forColorGuide: $0)
    }
  }
  
  override var stepControls: [SynthPath:[PBLabeledControl]] {
    return [
      [.velo] : veloKnobs,
      [.gate] : gateKnobs,
      [.mute] : muteChecks,
      [.voice] : noteSelects,
      [.pitch] : pitchKnobs,
    ]
  }

}

