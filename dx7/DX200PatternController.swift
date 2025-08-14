
class DX200PatternController : NewPagedEditorController {
  
  private let voiceController = DX200VoiceController()
  private let panelController = DX200PanelController()
  private let freeEnvController = DX200FreeEnvController()
  private let voiceSeqController = DX200SeqAndPartController<DX200VoiceSeqController, DX200VoiceSeqPatch>()
  private let rhythmSeqController = DX200SeqAndPartController<DX200RhythmSeqController, DX200RhythmSeqPatch>()
  
  private var synthButton: PBButton!
  

  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch","tempo","fx","file"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("file", 1.5), ("switch", 10.5), ("tempo", 3), ("fx", 2.5)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("file",1),("page",8)], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Synth", "Common", "Free EG", "Synth Seq", "Rhythm 1", "Rhythm 2", "Rhythm 3"])
    quickGrid(panel: "switch", items: [[(switchCtrl, nil, "switchCtrl")]])
    
    quickGrid(panel: "tempo", items: [[
      (PBKnob(label: "Tempo"), [.common, .extra, .tempo], nil),
      (PBKnob(label: "Swing"), [.common, .extra, .swing], nil),
      (PBKnob(label: "Scene"), [.common, .extra, .scene], nil),
      ]])
    
    let fxType = PBSelect(label: "FX Type")
    let fxParam = PBKnob(label: "Param")
    quickGrid(panel: "fx", items: [[
      (fxParam, [.voice, .fx, .param], nil),
      (fxType, nil, "fxType"),
      ]])

    synthButton = createButton(titled: "Synth")
    synthButton.addClickTarget(self, action: #selector(fileTap(_:)))
    quickGrid(panel: "file", items: [[(synthButton, nil, "synthButton")]])
    
    fxType.options = DX200RhythmFXPatch.FX.typeOptions
    addPatchChangeBlock(paths: [[.voice, .fx, .type, .hi], [.voice, .fx, .type, .lo]]) { [weak self] (values) in
      guard let lo = values[[.voice, .fx, .type, .lo]],
            let hi = values[[.voice, .fx, .type, .hi]] else { return }
      let t = (hi << 8) + lo
      fxType.value = t

      guard let fx = DX200RhythmFXPatch.FX.fxValueMap[t] else { return }
      fxParam.label = fx.param.0
      self?.defaultConfigure(control: fxParam, forParam: fx.param.1)
    }
    addControlChangeBlock(control: fxType) {
      return .paramsChange([
        [.voice, .fx, .type, .lo] : fxType.value & 0xff,
        [.voice, .fx, .type, .hi] : fxType.value >> 8,
      ])
    }
    
    addColor(panels: ["tempo", "fx"])
    addColor(panels: ["switch", "file"], clearBackground: true)
  }
    
  
  var synthPopover: FnPopoverPatchBrowserController!

  #if os(iOS)
    
  @objc func fileTap(_ sender: Any) {
    guard let synthPopover = synthPopover else { return }
    synthPopover.setStyle()
    synthPopover.popoverPresentationController?.sourceView = synthButton
    synthPopover.popoverPresentationController?.sourceRect = synthButton.bounds
    present(synthPopover, animated: true)
  }
  
  #else
    
  @objc func fileTap(_ sender: Any) {
    guard let synthPopover = synthPopover else { return }
    present(synthPopover, asPopoverRelativeTo: synthButton.bounds, of: synthButton, preferredEdge: .maxX, behavior: .semitransient)
  }
  
  #endif
  
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return voiceController
    case 1:
      return panelController
    case 2:
      return freeEnvController
    case 3:
      return voiceSeqController
    default:
      rhythmSeqController.index = index - 4
      return rhythmSeqController
    }
  }
    
}

class DX200VoiceController : TX802Controller<DX200VoiceExtraController> {
  
  override var prefix: SynthPath? { return [.voice, .voice] }
  
}

class DX200VoiceExtraController : NewPatchEditorController {
  
  public override var prefix: SynthPath? { return [.extra] }
    
  public override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0.2
    paddedView.verticalPadding = 0.3
    let view = paddedView.mainView
    
    createPanels(forKeys: ["porta", "bend", "other"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("porta",3),("bend",3), ("other", 1),
      ], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("porta",1),
      ], pinned: true, spacing: "-s1-")
        
    quickGrid(panel: "porta", items: [[
      (PBSwitch(label: "Porta"), [.porta, .mode], nil),
      (PBKnob(label: "Time"), [.porta, .time], nil),
      (PBKnob(label: "Step"), [.porta, .step], nil)],
      ])

    quickGrid(panel: "bend", items: [[
      (PBKnob(label: "Bend Range"), [.bend, .range], nil),
      (PBKnob(label: "Step"), [.bend, .step], nil),
      (PBKnob(label: "Mode"), [.bend, .mode], nil)],
      ])

    quickGrid(panel: "other", items: [[
      (PBKnob(label: "Unison Detune"), [.unison, .detune], nil),
      ]])

    layout.activateConstraints()
    self.view = paddedView
    
    addColorToAll(level: 2)
  }
    
}

class DX200PanelController : NewPatchEditorController {
  
  
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0
    paddedView.verticalPadding = 0.05
    let view = paddedView.mainView
    
    let scene1Controller = DX200SceneController()
    let scene2Controller = DX200SceneController()
    scene1Controller.index = 0
    scene2Controller.index = 1
    addChild(DX200CommonController(), withPanel: "common")
    addChild(scene1Controller, withPanel: "scene1")
    addChild(scene2Controller, withPanel: "scene2")
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("common", 1)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("scene1",1), ("scene2",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("common",3),("scene1",4)], pinned: true, spacing: "-s1-")
    
    layout.activateConstraints()
    self.view = paddedView
  }
  
}

class DX200CommonController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["dist", "eq", "volume", "lfo", "filter", "amp", "mods", "noise"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("filter",5), ("dist", 6), ("lfo", 2), ("mods", 3)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("eq", 5), ("volume", 3)], pinned: false, spacing: "-s1-")
    layout.addRowConstraints([("amp",5),("noise",2.5)], pinned: false, spacing: "-s1-")
    layout.addColumnConstraints([("dist",1),("eq",1),("amp",1)], pinned: true, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["dist","eq","amp"], attribute: .leading)
    layout.addEqualConstraints(forItemKeys: ["lfo","volume","noise"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["filter","amp","mods"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["dist","lfo"], attribute: .bottom)

    
    quickGrid(panel: "dist", items: [[
      (PBCheckbox(label: "Distortion"), [.voice, .common, .dist, .on], nil),
      (PBKnob(label: "Drive"), [.voice, .common, .dist, .drive], nil),
      (PBSwitch(label: "Type"), [.voice, .common, .dist, .type], nil),
      (PBKnob(label: "Cutoff"), [.voice, .common, .dist, .cutoff], nil),
      (PBKnob(label: "Level"), [.voice, .common, .dist, .level], nil),
      (PBKnob(label: "Mix"), [.voice, .common, .dist, .amt], nil),
      ]])

    quickGrid(panel: "eq", items: [[
      (PBKnob(label: "Lo Freq"), [.voice, .common, .eq, .lo, .freq], nil),
      (PBKnob(label: "Lo Gain"), [.voice, .common, .eq, .lo, .gain], nil),
      (PBKnob(label: "Mid Freq"), [.voice, .common, .eq, .mid, .freq], nil),
      (PBKnob(label: "Mid Gain"), [.voice, .common, .eq, .mid, .gain], nil),
      (PBKnob(label: "Mid Q"), [.voice, .common, .eq, .mid, .q], nil),
      ]])

    quickGrid(panel: "volume", items: [[
      (PBKnob(label: "Volume"), [.part, .voice, .volume], nil),
      (PBKnob(label: "Pan"), [.part, .voice, .pan], nil),
      (PBKnob(label: "FX Send"), [.part, .voice, .fx, .send], nil),
      ]])

    quickGrid(panel: "lfo", items: [[
      (PBKnob(label: "LFO Speed"), [.voice, .voice, .voice, .lfo, .speed], nil),
      (PBKnob(label: "Porta T"), [.voice, .voice, .extra, .porta, .time], nil),
      ]])

    let filterEnv = PBDadsrEnvelopeControl(label: "Filter")
    quickGrid(panel: "filter", items: [[
      (PBSwitch(label: "Filter"), [.voice, .common, .filter, .type], nil),
      (PBKnob(label: "Velo"), [.voice, .common, .filter, .env, .velo], nil),
      (PBKnob(label: "Scal Depth"), [.voice, .common, .filter, .cutoff, .scale, .amt], nil),
      (PBKnob(label: "Mod Depth"), [.voice, .common, .filter, .cutoff, .mod, .amt], nil),
      ],[
      (filterEnv, nil, "filterEnv"),
      (PBKnob(label: "Cutoff"), [.voice, .common, .cutoff], nil),
      (PBKnob(label: "Reson"), [.voice, .common, .reson], nil),
      (PBKnob(label: "Env Amt"), [.voice, .common, .filter, .env, .amt], nil),
      ],[
      (PBKnob(label: "Attack"), [.voice, .common, .filter, .env, .attack], nil),
      (PBKnob(label: "Decay"), [.voice, .common, .filter, .env, .decay], nil),
      (PBKnob(label: "Sustain"), [.voice, .common, .filter, .env, .sustain], nil),
      (PBKnob(label: "Release"), [.voice, .common, .filter, .env, .release], nil),
      (PBKnob(label: "Gain"), [.voice, .common, .filter, .gain], nil),
      ]])

    quickGrid(panel: "amp", items: [[
      (PBKnob(label: "Amp Attack"), [.voice, .common, .amp, .env, .attack], nil),
      (PBKnob(label: "Decay"), [.voice, .common, .amp, .env, .decay], nil),
      (PBKnob(label: "Sustain"), [.voice, .common, .amp, .env, .sustain], nil),
      (PBKnob(label: "Release"), [.voice, .common, .amp, .env, .release], nil),
      (PBKnob(label: "Voice Level"), [.voice, .common, .voice, .level], nil),
      ]])

    quickGrid(panel: "noise", items: [[
      (PBSelect(label: "Noise Type"), [.voice, .common, .noise, .type], nil),
      (PBKnob(label: "Level"), [.voice, .common, .noise, .level], nil),
      ]])

    quickGrid(panel: "mods", items: [[
      (PBKnob(label: "Harmonic 1"), [.voice, .common, .mod, .i(0), .harmonic], nil),
      (PBKnob(label: "FM Depth 1"), [.voice, .common, .mod, .i(0), .fm, .amt], nil),
      (PBKnob(label: "Env Decay 1"), [.voice, .common, .mod, .i(0), .env, .decay], nil),
      ],[
      (PBKnob(label: "Harmonic 2"), [.voice, .common, .mod, .i(1), .harmonic], nil),
      (PBKnob(label: "FM Depth 2"), [.voice, .common, .mod, .i(1), .fm, .amt], nil),
      (PBKnob(label: "Env Decay 2"), [.voice, .common, .mod, .i(1), .env, .decay], nil),
      ],[
      (PBKnob(label: "Harmonic 3"), [.voice, .common, .mod, .i(2), .harmonic], nil),
      (PBKnob(label: "FM Depth 3"), [.voice, .common, .mod, .i(2), .fm, .amt], nil),
      (PBKnob(label: "Env Decay 3"), [.voice, .common, .mod, .i(2), .env, .decay], nil),
      ]])
    
    addPatchChangeBlock(path: [.voice, .common, .filter, .env, .attack]) {
      filterEnv.attack = CGFloat($0) / 127
    }
    addPatchChangeBlock(path: [.voice, .common, .filter, .env, .decay]) {
      filterEnv.decay = CGFloat($0) / 127
    }
    addPatchChangeBlock(path: [.voice, .common, .filter, .env, .sustain]) {
      filterEnv.sustain = CGFloat($0) / 127
    }
    addPatchChangeBlock(path: [.voice, .common, .filter, .env, .release]) {
      filterEnv.rrelease = CGFloat($0) / 127
    }
    
    addColorToAll()
  }
}


class DX200FreeEnvController : NewPatchEditorController {
  
  private let paramController = DX200FreeEnvParamController()
  private let envController = EnvController()
  private let menuController = MenuController()

  override var prefix: SynthPath? { return [.voice, .env] }
  
  override var index: Int {
    didSet {
      paramController.index = index
      envController.index = index
      menuController.index = index
    }
  }
  
  override func loadView(_ view: PBView) {
    addChild(paramController, withPanel: "param")
    addChild(envController, withPanel: "env")
    addChild(menuController, withPanel: "menu")
    createPanels(forKeys: ["trig", "switch"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch", 6), ("menu", 2), ("param", 2.5), ("trig", 5)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("env", 1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("switch", 1), ("env",7)], pinned: true, spacing: "-s1-")

    quickGrid(panel: "trig", items: [[
      (PBSelect(label: "Trigger"), [.trigger], nil),
      (PBSelect(label: "Loop Type"), [.loop, .type], nil),
      (PBSelect(label: "Length"), [.length], nil),
      (PBKnob(label: "Key Trk"), [.keyTrk], nil),
      ]])

    let switcher = LabeledSegmentedControl(label: "Track", items: ["1","2","3","4"])
    switchCtrl = switcher.segmentedControl
    quickGrid(panel: "switch", items: [[(switcher, nil, "trackSwitch")]])
    
    addColorToAll(except: ["trig", "switch", "menu"], level: 2)
    addColor(panels: ["switch", "trig"], level: 2, clearBackground: true)
    addColor(panels: ["trig"], level: 1)
  }
  

  class MenuController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.trk, .i(index)] }

    override func loadView(_ view: PBView) {
      let menuButton = createMenuButton(titled: "Free EG")
      quickGrid(view: view, items: [[(menuButton, nil, "menuButton")]])
      
      registerForEditMenu(menuButton, bundle: (
        paths: { (0..<192).map { [.data, .i($0)] } },
        pasteboardType: "com.cfshpd.DX200-FreeEG",
        initialize: { [Int](repeating: 128, count: 192) },
        randomize: nil
      ))
    }
  }
  
  class EnvController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.trk, .i(index)] }
    
    private let arrayCtrl = PBArrayControl(label: "Free EG")
    private let gridCtrl = PBGridSelectControl(label: "")

    override func loadView(_ view: PBView) {
      createPanels(forKeys: ["modes" , "array"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("modes", 1), ("array", 14)], pinned: true, spacing: "-s1-")
      layout.addColumnConstraints([("modes",1)], pinned: true, spacing: "-s1-")

      let gridCtrlOptions: [Int:String] = [
        PBArrayControl.Mode.pen.rawValue : "✏️",
        PBArrayControl.Mode.line.rawValue : "📏",
        PBArrayControl.Mode.smooth.rawValue : "🍑",
        PBArrayControl.Mode.randomize.rawValue : "🤪",
        PBArrayControl.Mode.shiftX.rawValue : "⏩",
        PBArrayControl.Mode.shiftY.rawValue : "⏫",
        PBArrayControl.Mode.scaleY.rawValue : "↕️",
      ]
      gridCtrl.fontSize = 30
      gridCtrl.options = gridCtrlOptions
      gridCtrl.columnCount = 1
      gridCtrl.addValueChangeTarget(self, action: #selector(modeChange(_:)))
      quickGrid(panel: "modes", items: [[(gridCtrl, nil, "gridCtrl")]])
      
      arrayCtrl.count = 192
      arrayCtrl.range = -127...127
      quickGrid(panel: "array", items: [[(arrayCtrl, nil, "array")]])
      
      let arrayCtrl = self.arrayCtrl
      (0..<192).forEach { step in
        addPatchChangeBlock(path: [.data, .i(step)]) { arrayCtrl[step] = $0 - 127 }
      }
      addControlChangeBlock(control: arrayCtrl) {
        var changes = [SynthPath:Int]()
        (0..<192).forEach { changes[[.data, .i($0)]] = arrayCtrl[$0] + 127}
        return MakeParamsChange(changes)
      }
      
      addColorToAll(level: 2)
    }
    
    @IBAction func modeChange(_ sender: PBGridSelectControl) {
      arrayCtrl.mode = PBArrayControl.Mode(rawValue: sender.value)!
    }

  }
}

class DX200FreeEnvParamController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.trk, .i(index)] }

  override func loadView(_ view: PBView) {
    quickGrid(view: view, items: [[
      (PBSelect(label: "Param"), [.param], nil),
      (PBCheckbox(label: "On"), [.scene, .on], nil),
      ]])
    
    addColorToAll(level: 2)
  }
  
}
