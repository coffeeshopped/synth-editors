
class TG77MultiController : NewPagedEditorController {
  
  private let partsController = TG77MultiPartsController()
  private let fxController = TG77MultiFXController()
  private let extraController = TG77MultiExtraController()

  convenience init(hideIndivOut: Bool) {
    self.init()
    partsController.hideIndivOut = hideIndivOut
  }
  
  override func loadView(_ view: PBView) {
    switchCtrl = PBSegmentedControl(items: ["Parts 1–8", "9–16", "FX", "Assign Mode"])
    grid(panel: "switch", items: [[(switchCtrl, nil)]])

    createPanels(forKeys: ["space"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch", 8), ("space", 4)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("switch",1),("page",8)], pinned: true, spacing: "-s1-")
    
    addColor(panels: ["switch"], clearBackground: true)
  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 2:
      return fxController
    case 3:
      return extraController
    default:
      partsController.index = index
      return partsController
    }
  }
}

class TG77MultiPartsController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.common] }
  
  private var partControllers: [TG77MultiPartController]!
  var hideIndivOut = false

  override var index: Int {
    didSet {
      (0..<8).forEach { partControllers?[$0].index = $0 + (index * 8) }
    }
  }
  
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0
    paddedView.verticalPadding = 0.1
    let view = paddedView.mainView

    partControllers = addChildren(count: 8, panelPrefix: "p", setup: { [weak self] in
      $0.hideIndivOut = self?.hideIndivOut ?? false
    })
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([(0..<8).map { ("p\($0)", 1) }], pinMargin: "", spacing: "-s1-")

    layout.activateConstraints()
    self.view = paddedView
    addColorToAll()
  }

}


class TG77MultiPartController : NewPatchEditorController {
  
  fileprivate var hideIndivOut = false
    
  override var prefix: SynthPath? { return [.i(index)] }
  
  override var index: Int {
    didSet { partOn.label = "\(index+1)" }
  }
  
  private let partOn = PBCheckbox(label: "")
  private let indivOut = PBKnob(label: "Indiv Out")
  
  private var patchNameOptions = [Int:String]()
  
  override func loadView(_ view: PBView) {
    let voice = PBSelect(label: "Voice")
    let panMode = PBSwitch(label: "Pan Mode")
    let panKnob = PBKnob(label: "Pan")
    grid(view: view, items: [[
      (partOn, [.on]),
      (PBSwitch(label: "Bank"), [.voice, .bank]),
      ],[
      (voice, [.voice, .number]),
      ],[
      (PBKnob(label: "Volume"), [.volume]),
      (indivOut, [.out, .select]),
      ],[
      (PBCheckbox(label: "Grp 1"), [.out, .i(0)]),
      (PBCheckbox(label: "Grp 2"), [.out, .i(1)]),
      ],[
      (PBKnob(label: "Note Shift"), [.note, .shift]),
      (PBKnob(label: "Fine"), [.fine]),
      ],[
      (panMode, nil),
      (panKnob, nil),
      ]])
    
    indivOut.isHidden = hideIndivOut

    panMode.options = OptionsParam.makeOptions(["Voice", "Static"])
    panKnob.minimumValue = 1
    panKnob.maximumValue = 63
    panKnob.displayOffset = -32
    addPatchChangeBlock(path: [.pan]) {
      panMode.value = $0 == 0 ? 0 : 1
      if $0 > 0 {
        panKnob.value = $0
      }
      panKnob.isHidden = $0 == 0
    }
    addDefaultControlChangeBlock(control: panMode, path: [.pan]) { panMode.value == 0 ? 0 : panKnob.value }

    addPatchChangeBlock(path: [.on]) { view.alpha = $0 == 1 ? 1 : 0.4 }
    
    let updateSoundDropdown: (Int) -> Void = { [weak self] in
      let options: [Int:String]
      switch $0 {
      case 0:
        options = self?.patchNameOptions ?? [:]
      case 1:
        options = OptionsParam.makeOptions(TG77VoiceBank.preset1)
      case 2:
        options = OptionsParam.makeOptions(TG77VoiceBank.preset2)
      default:
        options = TG77VoiceBank.emptyBankOptions
      }
      voice.options = options
    }
    addPatchChangeBlock(path: [.voice, .bank]) { updateSoundDropdown($0) }
    addParamChangeBlock { [weak self] (params) in
      guard let param = params.params[[.patch, .name]] as? OptionsParam else { return }
      self?.patchNameOptions = param.options
      guard let bank = self?.latestValue(path: [.voice, .bank]) else { return }
      updateSoundDropdown(bank)
    }

  }
  
}

class TG77MultiFXController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.common] }
    
  override func loadView() {
    let paddedView = PaddedContainer()
    let view = paddedView.mainView
    
    let chorusControllers: [TG77ChorusController] = addChildren(count: 2, panelPrefix: "chorus")
    let reverbControllers: [TG77ReverbController] = addChildren(count: 2, panelPrefix: "reverb")
    
    grid(panel: "fx", items: [[
      (PBImageSelect(label: "FX Mode", imageSize: CGSize(width: 280, height: 60), imageSpacing: 12), [.fx, .mode]),
      (PBCheckbox(label: "St Mix 1"), [.fx, .mix, .i(0)]),
      (PBCheckbox(label: "St Mix 2"), [.fx, .mix, .i(1)]),
      ]])
    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("fx", 1),
      ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("fx", 1), ("chorus0", 1), ("chorus1", 1), ("reverb0", 1), ("reverb1", 1),
    ], options: [.alignAllLeading, .alignAllTrailing], pinned: true, spacing: "-s1-")

    layout.activateConstraints()
    self.view = paddedView
    
    addPatchChangeBlock(path: [.fx, .mode]) {
      let alpha: CGFloat = $0 == 0 ? 0.4 : 1
      chorusControllers.forEach { $0.view.alpha = alpha }
      reverbControllers.forEach { $0.view.alpha = alpha }
    }
    addColorToAll()
  }
  
}


class TG77MultiExtraController : NewPatchEditorController {

  override var prefix: SynthPath? { return [.extra] }
  
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0
    paddedView.verticalPadding = 0.25
    let view = paddedView.mainView
    
    let partControllers: [PartController] = addChildren(count: 16, panelPrefix: "p")
    
    grid(panel: "mode", items: [[(PBSwitch(label: "Assign Mode"), [.mode])]])

    createPanels(forKeys: ["space"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("mode", 2), ("space", 14)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints((0..<16).map { ("p\($0)", 1) }, pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("mode",1), ("p0", 3)], pinned: true, spacing: "-s1-")

    layout.activateConstraints()
    self.view = paddedView
    
    addPatchChangeBlock(path: [.mode]) {
      let alpha: CGFloat = $0 == 0 ? 0.4 : 1
      partControllers.forEach { $0.view.alpha = alpha }
    }
    addColorToAll(except: ["space"])
  }
    
  
  class PartController: NewPatchEditorController {
    
    override var index: Int {
      didSet { label.text = "\(index + 1)" }
    }
    
    override var prefix: SynthPath? { return [.i(index)] }
    private let label = LabelItem()
    
    override func loadView(_ view: PBView) {
      label.textAlignment = .center
      grid(view: view, items: [[
        (label, nil),
        ],[
        (PBKnob(label: "AFM Max"), [.fm]),
        ],[
        (PBKnob(label: "AWM Max"), [.wave]),
        ]])
    }
  }
}

