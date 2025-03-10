
class JD990VoiceController : NewPagedEditorController {
  
  convenience init(perfPart: Bool = false) {
    self.init()
  }
  
  private let commonController = CommonController()
  private let toneController = ToneController()
  private let pitchController = FourTonePaletteController<PalettePitchWaveController>()
  private let filterController = FourTonePaletteController<PaletteFilterController>()
  private let ampController = FourTonePaletteController<PaletteAmpController>()
  private let lfoController = FourTonePaletteController<PaletteLFOController>()
  private let ctrlController = FourTonePaletteController<PaletteCtrlController>()

  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch", "on"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch", 12), ("on", 4),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",8),
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Common", "A", "B", "C", "D", "Pitch", "Filter", "Amp", "LFO", "Ctrl"])
    grid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil)]])

    grid(panel: "on", items: [[
      (PBCheckbox(label: "A"), [.common, .tone, .i(0), .on]),
      (PBCheckbox(label: "B"), [.common, .tone, .i(1), .on]),
      (PBCheckbox(label: "C"), [.common, .tone, .i(2), .on]),
      (PBCheckbox(label: "D"), [.common, .tone, .i(3), .on]),
      ]])
    
    addColor(panels: ["on"])
    addColor(panels: ["switch"], clearBackground: true)
  }
  
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return commonController
    case 5:
      return pitchController
    case 6:
      return filterController
    case 7:
      return ampController
    case 8:
      return lfoController
    case 9:
      return ctrlController
    default:
      toneController.index = index - 1
      return toneController
    }
  }

  
  class CommonController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.common] }
    
    override func loadView(_ view: PBView) {
      createPanels(forKeys: ["level", "toneCtrl", "enhance", "groupA", "groupB", "solo", "dist", "phaser", "porta", "spectrum", "lohi", "delay", "chorus", "eq", "reverb", "active", "fxCtrl0", "fxCtrl1", "struct"])
      addPanelsToLayout(andView: view)

      layout.addRowConstraints([("level", 7), ("dist", 3), ("groupA", 5.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("solo", 3), ("porta", 4), ("enhance", 3), ("groupB", 5.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("lohi", 4), ("eq", 4), ("phaser", 6.5)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("active", 4), ("toneCtrl", 3), ("fxCtrl0", 4), ("fxCtrl1", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("level", 1), ("solo", 1), ("lohi", 5), ("active", 1)], pinned: true, pinMargin: "", spacing: "-s1-")

      layout.addColumnConstraints([("eq", 2), ("struct", 3)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      layout.addColumnConstraints([("phaser", 1), ("spectrum", 1), ("delay", 1), ("chorus", 1), ("reverb", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      
      layout.addEqualConstraints(forItemKeys: ["lohi", "struct", "reverb"], attribute: .bottom)
      
      
      grid(panel: "level", items: [[
        (PBKnob(label: "Level"), [.level]),
        (PBKnob(label: "Pan"), [.pan]),
        (PBKnob(label: "Analog Feel"), [.analogFeel]),
        (PBSwitch(label: "Priority"), [.priority]),
        (PBKnob(label: "Bend Down"), [.bend, .down]),
        (PBKnob(label: "Bend Up"), [.bend, .up]),
        (PBSwitch(label: "Octave"), [.octave]),
        ]])

      grid(panel: "toneCtrl", items: [[
        (PBSelect(label: "Tone Ctrl 1"), [.ctrl, .src, .i(0)]),
        (PBSelect(label: "Tone Ctrl 2"), [.ctrl, .src, .i(1)]),
        ]])

      grid(panel: "lohi", items: [[
        (PBKnob(label: "(A) Lo Key"), [.tone, .i(0), .key, .lo]),
        (PBKnob(label: "(B) Lo Key"), [.tone, .i(1), .key, .lo]),
        (PBKnob(label: "(C) Lo Key"), [.tone, .i(2), .key, .lo]),
        (PBKnob(label: "(D) Lo Key"), [.tone, .i(3), .key, .lo]),
        ],[
        (PBKnob(label: "Hi Key"), [.tone, .i(0), .key, .hi]),
        (PBKnob(label: "Hi Key"), [.tone, .i(1), .key, .hi]),
        (PBKnob(label: "Hi Key"), [.tone, .i(2), .key, .hi]),
        (PBKnob(label: "Hi Key"), [.tone, .i(3), .key, .hi]),
        ],[
        (PBSwitch(label: "Velo Range"), [.velo, .range, .i(0)]),
        (PBSwitch(label: "Velo Range"), [.velo, .range, .i(1)]),
        (PBSwitch(label: "Velo Range"), [.velo, .range, .i(2)]),
        (PBSwitch(label: "Velo Range"), [.velo, .range, .i(3)]),
        ],[
        (PBKnob(label: "Velo Pt"), [.velo, .pt, .i(0)]),
        (PBKnob(label: "Velo Pt"), [.velo, .pt, .i(1)]),
        (PBKnob(label: "Velo Pt"), [.velo, .pt, .i(2)]),
        (PBKnob(label: "Velo Pt"), [.velo, .pt, .i(3)]),
        ],[
        (PBKnob(label: "Velo Fade"), [.velo, .fade, .i(0)]),
        (PBKnob(label: "Velo Fade"), [.velo, .fade, .i(1)]),
        (PBKnob(label: "Velo Fade"), [.velo, .fade, .i(2)]),
        (PBKnob(label: "Velo Fade"), [.velo, .fade, .i(3)]),
        ]])

      grid(panel: "solo", items: [[
        (PBCheckbox(label: "Solo"), [.solo]),
        (PBCheckbox(label: "Legato"), [.solo, .legato]),
        (PBSwitch(label: "Sync Master"), [.solo, .sync]),
        ]])

      grid(panel: "porta", items: [[
        (PBCheckbox(label: "Porta"), [.porta]),
        (PBSwitch(label: "Mode"), [.porta, .mode]),
        (PBSwitch(label: "Type"), [.porta, .type]),
        (PBKnob(label: "Time"), [.porta, .time]),
        ]])

      grid(panel: "fxCtrl0", items: [[
        (PBSelect(label: "FX Ctrl 1"), [.fx, .ctrl, .src, .i(0)]),
        (PBKnob(label: "Depth"), [.fx, .ctrl, .depth, .i(0)]),
        (PBSelect(label: "Destination"), [.fx, .ctrl, .dest, .i(0)]),
        ]])

      grid(panel: "fxCtrl1", items: [[
        (PBSelect(label: "FX Ctrl 2"), [.fx, .ctrl, .src, .i(1)]),
        (PBKnob(label: "Depth"), [.fx, .ctrl, .depth, .i(1)]),
        (PBSelect(label: "Destination"), [.fx, .ctrl, .dest, .i(1)]),
        ]])

      let struct1 = PBImageSelect(label: "Struct A/B", imageSize: CGSize(width: 300, height: 105), imageSpacing: 12)
      let struct3 = PBImageSelect(label: "Struct C/D", imageSize: CGSize(width: 300, height: 105), imageSpacing: 12)
      grid(panel: "struct", items: [[
        (struct1, nil),
        ],[
        (struct3, nil),
        ]])

      grid(panel: "eq", items: [[
        (PBKnob(label: "Lo Gain"), [.lo, .gain]),
        (PBKnob(label: "Mid Gain"), [.mid, .gain]),
        (PBKnob(label: "Hi Gain"), [.hi, .gain]),
        ],[
        (PBSwitch(label: "Lo Freq"), [.lo, .freq]),
        (PBKnob(label: "Mid Freq"), [.mid, .freq]),
        (PBKnob(label: "Mid Q"), [.mid, .q]),
        (PBSwitch(label: "Hi Freq"), [.hi, .freq]),
        ]])

      grid(panel: "active", items: [[
        (PBCheckbox(label: "Active A"), [.common, .tone, .i(0), .active]),
        (PBCheckbox(label: "B"), [.common, .tone, .i(1), .active]),
        (PBCheckbox(label: "C"), [.common, .tone, .i(2), .active]),
        (PBCheckbox(label: "D"), [.common, .tone, .i(3), .active]),
        ]])

      
      let aBlocks = [
        PBCheckbox(label: "Block 1"),
        PBCheckbox(label: "Block 2"),
        PBCheckbox(label: "Block 3"),
        PBCheckbox(label: "Block 4"),
      ]
      grid(panel: "groupA", items: [[
        (PBSelect(label: "Group A"), [.fx, .i(0), .seq]),
        (aBlocks[0], [.fx, .i(0), .part, .i(0), .on]),
        (aBlocks[1], [.fx, .i(0), .part, .i(1), .on]),
        (aBlocks[2], [.fx, .i(0), .part, .i(2), .on]),
        (aBlocks[3], [.fx, .i(0), .part, .i(3), .on]),
        ]])

      let bBlocks = [
        PBCheckbox(label: "Block 1"),
        PBCheckbox(label: "Block 2"),
        PBCheckbox(label: "Block 3"),
      ]
      grid(panel: "groupB", items: [[
        (PBSelect(label: "Group B"), [.fx, .i(1), .seq]),
        (bBlocks[0], [.fx, .i(1), .part, .i(0), .on]),
        (bBlocks[1], [.fx, .i(1), .part, .i(1), .on]),
        (bBlocks[2], [.fx, .i(1), .part, .i(2), .on]),
        (PBKnob(label: "FX Balance"), [.fx, .i(1), .balance]),
        ]])

      grid(panel: "enhance", items: [[
        (LabelItem(text: "Enhance", gridWidth: 3), nil),
        (PBKnob(label: "Sens"), [.extra, .sens]),
        (PBKnob(label: "Mix"), [.extra, .mix]),
        ]])

      grid(panel: "dist", items: [[
        (LabelItem(text: "Dist", gridWidth: 3), nil),
        (PBSelect(label: "Type"), [.dist, .type]),
        (PBKnob(label: "Drive"), [.dist, .drive]),
        (PBKnob(label: "Level"), [.dist, .level]),
        ]])

      grid(panel: "phaser", items: [[
        (LabelItem(text: "Phaser", gridWidth: 3), nil),
        (PBKnob(label: "Manual"), [.phase, .freq]),
        (PBKnob(label: "Rate"), [.phase, .rate]),
        (PBKnob(label: "Depth"), [.phase, .depth]),
        (PBKnob(label: "Reson"), [.phase, .reson]),
        (PBKnob(label: "Mix"), [.phase, .mix]),
        ]])
      
      grid(panel: "spectrum", items: [[
        (LabelItem(text: "Spectrum", gridWidth: 3), nil),
        (PBKnob(label: "250"), [.spectral, .i(0)]),
        (PBKnob(label: "500"), [.spectral, .i(1)]),
        (PBKnob(label: "1k"), [.spectral, .i(2)]),
        (PBKnob(label: "2k"), [.spectral, .i(3)]),
        (PBKnob(label: "4k"), [.spectral, .i(4)]),
        (PBKnob(label: "8k"), [.spectral, .i(5)]),
        (PBKnob(label: "Bandwidth"), [.spectral, .skirt]),
        ]])
      
      grid(panel: "delay", items: [[
        (LabelItem(text: "Delay", gridWidth: 3), nil),
        (PBKnob(label: "C Tap"), [.delay, .mid, .time]),
        (PBKnob(label: "C Level"), [.delay, .mid, .level]),
        (PBKnob(label: "L Tap"), [.delay, .left, .time]),
        (PBKnob(label: "L Level"), [.delay, .left, .level]),
        (PBKnob(label: "R Tap"), [.delay, .right, .time]),
        (PBKnob(label: "R Level"), [.delay, .right, .level]),
        (PBKnob(label: "Feedback"), [.delay, .feedback]),
        ]])

      grid(panel: "chorus", items: [[
        (LabelItem(text: "Chorus", gridWidth: 3), nil),
        (PBKnob(label: "Rate"), [.chorus, .rate]),
        (PBKnob(label: "Depth"), [.chorus, .depth]),
        (PBKnob(label: "Delay"), [.chorus, .delay]),
        (PBKnob(label: "Feedback"), [.chorus, .feedback]),
        (PBKnob(label: "Level"), [.chorus, .level]),
        ]])

      grid(panel: "reverb", items: [[
        (LabelItem(text: "Reverb", gridWidth: 3), nil),
        (PBSelect(label: "Type"), [.reverb, .type]),
        (PBKnob(label: "Pre Delay"), [.reverb, .pre]),
        (PBKnob(label: "Early Ref"), [.reverb, .early]),
        (PBKnob(label: "HF Damp"), [.reverb, .hi, .cutoff]),
        (PBKnob(label: "Time"), [.reverb, .time]),
        (PBKnob(label: "Level"), [.reverb, .level]),
        ]])
      
      addPatchChangeBlock(path: [.common, .solo]) { [weak self] (value) in
        self?.panels["porta"]?.alpha = value == 0 ? 0.5 : 1
      }
      addPatchChangeBlock(path: [.fx, .i(0), .seq]) { (value) in
        let labelMap: [SynthPathItem:String] = [
          .dist : "Dist",
          .phase : "Phaser",
          .spectral : "Spectrum",
          .extra : "Enhancer",
        ]
        (0..<aBlocks.count).forEach {
          let fx = JD800FXPatch.fxA[value][$0]
          guard let label = labelMap[fx] else { return }
          aBlocks[$0].label = label
        }
      }
      addPatchChangeBlock(path: [.fx, .i(1), .seq]) { (value) in
        let labelMap: [SynthPathItem:String] = [
          .chorus : "Chorus",
          .delay : "Delay",
          .reverb : "Reverb",
        ]
        (0..<bBlocks.count).forEach {
          let fx = JD800FXPatch.fxB[value][$0]
          guard let label = labelMap[fx] else { return }
          bBlocks[$0].label = label
        }
      }

      addPatchChangeBlock(paths: [[.fx, .i(0), .seq],
                                  [.fx, .i(0), .part, .i(0), .on],
                                  [.fx, .i(0), .part, .i(1), .on],
                                  [.fx, .i(0), .part, .i(2), .on],
                                  [.fx, .i(0), .part, .i(3), .on],
      ]) { [weak self] (values) in
        let seq = values[[.fx, .i(0), .seq]]!
        let blocksOn: [Bool] = (0..<4).map { values[[.fx, .i(0), .part, .i($0), .on]] == 1 }
        let panelMap: [SynthPathItem:String] = [
          .dist : "dist",
          .phase : "phaser",
          .spectral : "spectrum",
          .extra : "enhance",
        ]
        panelMap.forEach {
          guard let blockIndex = JD800FXPatch.fxA[seq].firstIndex(of: $0.key) else { return }
          self?.panels[$0.value]?.alpha = blocksOn[blockIndex] ? 1 : 0.4
        }
      }
      
      addPatchChangeBlock(paths: [[.fx, .i(1), .seq],
                                  [.fx, .i(1), .part, .i(0), .on],
                                  [.fx, .i(1), .part, .i(1), .on],
                                  [.fx, .i(1), .part, .i(2), .on],
      ]) { [weak self] (values) in
        let seq = values[[.fx, .i(1), .seq]]!
        let blocksOn: [Bool] = (0..<3).map { values[[.fx, .i(1), .part, .i($0), .on]] == 1 }
        let panelMap: [SynthPathItem:String] = [
          .chorus : "chorus",
          .delay : "delay",
          .reverb : "reverb",
        ]
        panelMap.forEach {
          guard let blockIndex = JD800FXPatch.fxB[seq].firstIndex(of: $0.key) else { return }
          self?.panels[$0.value]?.alpha = blocksOn[blockIndex] ? 1 : 0.4
        }
      }
      
      addBlocks(control: struct1, path: [.structure, .i(0)], paramAfterBlock: {
        struct1.options = CommonController.structureOptions
      })
      addBlocks(control: struct3, path: [.structure, .i(1)], paramAfterBlock: {
        struct3.options = CommonController.structureOptions
      })

      addColorToAll(except: Self.fxPanels, level: 1)
      addColor(panels: Self.fxPanels, level: 2)
    }

    static let structureOptions = OptionsParam.makeOptions((1...6).map { "jd990-struct-\($0)" })

    private static let fxPanels = ["enhance", "groupA", "groupB", "dist", "phaser", "spectrum", "delay", "chorus", "reverb", "fxCtrl0", "fxCtrl1"]

  }

  
  
  class ToneController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.tone, .i(index)] }
    
    private var menuButton: PBButton!

    override func loadView(_ view: PBView) {
      let _: [LFOController] = addChildren(count: 2, panelPrefix: "lfo")
      let _: [CtrlController] = addChildren(count: 2, panelPrefix: "ctrl")
      addChild(WaveController(), withPanel: "src")
      addChild(PitchController(), withPanel: "pitch")
      addChild(FilterController(), withPanel: "filter")
      addChild(AmpController(), withPanel: "amp")
      createPanels(forKeys: ["fxm", "sync", "delay", "bend", "velo", "pan", "level", "menu"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("src", 2.5), ("fxm", 2), ("sync", 1), ("delay", 2.5), ("bend", 1), ("velo", 3), ("pan", 2), ("level", 1), ("menu", 1.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("pitch", 5), ("filter", 6), ("amp", 5), ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("lfo0", 1), ("lfo1", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("ctrl0", 1), ("ctrl1", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("src", 1), ("pitch", 4), ("lfo0", 1), ("ctrl0", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      grid(panel: "fxm", items: [[
        (PBKnob(label: "FXM Color"), [.fxm, .color]),
        (PBKnob(label: "Depth"), [.fxm, .depth]),
        ]])

      grid(panel: "sync", items: [[
        (PBCheckbox(label: "Sync Slave"), [.sync, .on]),
        ]])

      grid(panel: "delay", items: [[
        (PBSelect(label: "Tone Delay"), [.tone, .delay, .mode]),
        (PBKnob(label: "Time"), [.tone, .delay, .time]),
        ]])

      grid(panel: "bend", items: [[
        (PBCheckbox(label: "Bend"), [.bend, .on]),
        ]])

      let veloCurve = PBImageSelect(label: "Velo Curve", imageSize: CGSize(width: 200, height: 70), imageSpacing: 12)
      grid(panel: "velo", items: [[
        (veloCurve, nil),
        (PBCheckbox(label: "Hold Ctrl"), [.hold, .ctrl]),
        ]])

      grid(panel: "pan", items: [[
        (PBKnob(label: "Pan"), [.pan]),
        (PBKnob(label: "Key > Pan"), [.pan, .keyTrk]),
        ]])

      grid(panel: "level", items: [[
        (PBKnob(label: "Level"), [.level]),
        ]])

      menuButton = createMenuButton(titled: "Tone")
      grid(panel: "menu", items: [[(menuButton, nil)]])
      
      let paths = JD990TonePatch.paramKeys()
      registerForEditMenu(menuButton, bundle: (
        paths: { paths },
        pasteboardType: "com.cfshpd.JD990VoiceTone",
        initialize: nil,
        randomize: { return [] } // this will register that randomize exists
      ))

      addPatchChangeBlock { [weak self] (changes) in
        guard let values = self?.updatedValuesForFullPaths(fullPaths: [
          [.common, .tone, .i(0), .on],
          [.common, .tone, .i(1), .on],
          [.common, .tone, .i(2), .on],
          [.common, .tone, .i(3), .on],
        ], changes: changes),
          let index = self?.index else { return }
        view.alpha = values[[.common, .tone, .i(index), .on]] == 1 ? 1 : 0.4
      }
      addBlocks(control: veloCurve, path: [.velo, .curve], paramAfterBlock: {
        veloCurve.options = Self.veloOptions
      })
      
      addColorToAll(except: ["menu"])
      addColor(panels: ["menu"], clearBackground: true)

    }
    
    static let veloOptions = OptionsParam.makeOptions((1...7).map { "jd990-velo-\($0)" })

    override func randomize(_ sender: Any?) {
      pushPatchChange(.replace(JD990TonePatch.random()))
    }
    
  }
  
  
  // MARK: Palette
  
  // TODO: update RolandFourTonePaletteController to accommdodate this
  class FourTonePaletteController<T:NewPatchEditorController> : NewPatchEditorController {
    open override func loadView(_ view: PBView) {
      let _: [PaletteWrapperController<T>] = addChildren(count: 4, panelPrefix: "pal")
      addPanelsToLayout(andView: view)
      layout.addGridConstraints([(0..<4).map { ("pal\($0)", 1) }], pinMargin: "", spacing: "-s1-")
    }
      
    class PaletteWrapperController<T:NewPatchEditorController> : NewPatchEditorController {
      override var prefix: SynthPath? { [.tone, .i(index)] }

      override var index: Int {
        didSet { button.setTitleKeepingColor(["A", "B", "C", "D"][index]) }
      }
      
      let button = createMenuButton(titled: "?")

      override func loadView(_ view: PBView) {
        let vc = T.init()
        addChild(vc, withPanel: "vc")
        createPanels(forKeys: ["label"])
        addPanelsToLayout(andView: view)
        
        layout.addGridConstraints([
          (row: [("label", 1)], height: 1),
          (row: [("vc", 1)], height: 10),
        ], pinMargin: "", spacing: "-s1-")
        
        grid(panel: "label", items: [[(button, nil)]])
        
        addPatchChangeBlock { [weak self] (changes) in
          guard let values = self?.updatedValuesForFullPaths(fullPaths: [
            [.common, .tone, .i(0), .on],
            [.common, .tone, .i(1), .on],
            [.common, .tone, .i(2), .on],
            [.common, .tone, .i(3), .on],
          ], changes: changes) else { return }
          self?.panels["vc"]?.alpha = values[[.common, .tone, .i(self?.index ?? 0), .on]] == 1 ? 1 : 0.4
        }

        // TODO: Paths is a hack to remove the prefix...
        registerForEditMenu(button, bundle: (
          paths: { vc.controlledPaths.map { $0.subpath(from: 2) } },
          pasteboardType: "com.cfshpd.\(T.self)",
          initialize: nil,
          randomize: nil
        ))

        addColor(panels: ["label"], clearBackground: true)
        addBorder(panel: "vc")
      }
      
    }
  }
  
  
  // MARK: Wave
  
  class WaveController : NewPatchEditorController {

    fileprivate let wave = PBSelect(label: "Wave")
    private var cardOptions = [Int:String]()
    private var boardOptions = [Int:String]()

    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSwitch(label: "Source"), [.wave, .group]),
        (wave, [.wave, .number]),
        ]])

      addPatchChangeBlock(path: [.wave, .group]) { [weak self] (value) in
        self?.updateWave(group: value)
      }

      // Card/Board Options
      addParamChangeBlock { [weak self] (params) in
        if let param = params.params[[.pcm]] as? OptionsParam {
          self?.cardOptions = param.options
          guard let group = self?.latestValue(path: [.wave, .group]) else { return }
          self?.updateWave(group: group)
        }
        if let param = params.params[[.extra]] as? OptionsParam {
          self?.boardOptions = param.options
          guard let group = self?.latestValue(path: [.wave, .group]) else { return }
          self?.updateWave(group: group)
        }
      }
      
    }
    
    private func updateWave(group: Int) {
      switch group {
      case 0:
        wave.options = JD990TonePatch.waveOptions
      case 1:
        wave.options = cardOptions
      default:
        wave.options = boardOptions
      }
    }
  }
  
  
  // MARK: Pitch
  
  class PitchController : NewPatchEditorController {
    
    fileprivate let env = PBRateLevelEnvelopeControl(label: "Pitch")
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBKnob(label: "Coarse"), [.pitch, .coarse]),
        (PBKnob(label: "Fine"), [.pitch, .fine]),
        (PBKnob(label: "Random"), [.pitch, .random]),
        (PBKnob(label: "Keyfollow"), [.pitch, .keyTrk]),
        (PBKnob(label: "LFO 1"), [.lfo, .i(0), .pitch]),
        (PBKnob(label: "LFO 2"), [.lfo, .i(1), .pitch]),
        ],[
        (env, nil),
        (PBKnob(label: "Env > Pitch"), [.pitch, .env, .depth]),
        (PBKnob(label: "Velo Sens"), [.pitch, .env, .velo]),
        (PBKnob(label: "Key > Time"), [.pitch, .env, .time, .keyTrk]),
        ],[
        (SpacerItem(), nil),
        (PBKnob(label: "T1"), [.pitch, .env, .time, .i(0)]),
        (PBKnob(label: "T2"), [.pitch, .env, .time, .i(1)]),
        (PBKnob(label: "T3"), [.pitch, .env, .time, .i(2)]),
        (PBKnob(label: "Velo > Time"), [.pitch, .env, .time, .velo]),
        ],[
        (PBKnob(label: "L0"), [.pitch, .env, .level, .i(-1)]),
        (PBKnob(label: "L1"), [.pitch, .env, .level, .i(0)]),
        (PBKnob(label: "Sus L"), [.pitch, .env, .level, .i(1)]),
        (PBKnob(label: "L3"), [.pitch, .env, .level, .i(2)]),
        (SpacerItem(), nil),
        ]])
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()

      let env = self.env
      env.bipolar = true
      env.sustainPoint = 2
      env.pointCount = 4

      (0..<3).forEach { time in
        addPatchChangeBlock(path: [.pitch, .env, .time, .i(time)]) {
          env.set(rate: CGFloat($0) / 100, forIndex: time)
        }
      }
      (0..<3).forEach { level in
        addPatchChangeBlock(path: [.pitch, .env, .level, .i(level)]) {
          env.set(level: CGFloat($0 - 50) / 50, forIndex: level)
        }
      }
      addPatchChangeBlock(path: [.pitch, .env, .level, .i(-1)]) {
        env.startLevel = CGFloat($0 - 50) / 50
      }

      registerForEditMenu(env, bundle: (
        paths: {[[.pitch, .env, .time, .i(0)],
                [.pitch, .env, .time, .i(1)],
                [.pitch, .env, .time, .i(2)],
                [.pitch, .env, .level, .i(-1)],
                [.pitch, .env, .level, .i(0)],
                [.pitch, .env, .level, .i(1)],
                [.pitch, .env, .level, .i(2)],
        ]},
        pasteboardType: "com.cfshpd.JD990PitchEnvelope",
        initialize: nil,
        randomize: nil
      ))
    }
  }
  
  
  class PalettePitchWaveController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      addChild(WaveController(), withPanel: "wave")
      addChild(PalettePitchController(), withPanel: "pitch")
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        (row: [(key: "wave", width: 1)], height: 1),
        (row: [(key: "pitch", width: 1)], height: 6),
      ], pinMargin: "", spacing: "-s1-")
      
      addColorToAll()
    }
  }
  
  class PalettePitchController : PitchController {
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBKnob(label: "Coarse"), [.pitch, .coarse]),
        (PBKnob(label: "Fine"), [.pitch, .fine]),
        (PBKnob(label: "Random"), [.pitch, .random]),
        (PBKnob(label: "Keyfollow"), [.pitch, .keyTrk]),
        ],[
        (env, nil),
        (PBKnob(label: "Env > Pitch"), [.pitch, .env, .depth]),
        (PBKnob(label: "Key > Time"), [.pitch, .env, .time, .keyTrk]),
        ],[
        (SpacerItem(), nil),
        (PBKnob(label: "T1"), [.pitch, .env, .time, .i(0)]),
        (PBKnob(label: "T2"), [.pitch, .env, .time, .i(1)]),
        (PBKnob(label: "T3"), [.pitch, .env, .time, .i(2)]),
        ],[
        (PBKnob(label: "L0"), [.pitch, .env, .level, .i(-1)]),
        (PBKnob(label: "L1"), [.pitch, .env, .level, .i(0)]),
        (PBKnob(label: "Sus L"), [.pitch, .env, .level, .i(1)]),
        (PBKnob(label: "L3"), [.pitch, .env, .level, .i(2)]),
        ],[
        (PBKnob(label: "Velo Sens"), [.pitch, .env, .velo]),
        (PBKnob(label: "Velo > Time"), [.pitch, .env, .time, .velo]),
        ],[
        (PBKnob(label: "LFO 1"), [.lfo, .i(0), .pitch]),
        (PBKnob(label: "LFO 2"), [.lfo, .i(1), .pitch]),
        ]])
      
      addColorToAll()
    }
  }
  
  
  
  // MARK: Filter

  class FilterController : NewPatchEditorController {
    
    fileprivate let env = PBRateLevelEnvelopeControl(label: "Filter")

    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSwitch(label: "Filter"), [.filter, .type]),
        (PBKnob(label: "Cutoff"), [.cutoff]),
        (PBKnob(label: "Reson"), [.reson]),
        (PBKnob(label: "Key > Cutoff"), [.cutoff, .keyTrk]),
        (PBKnob(label: "LFO 1"), [.lfo, .i(0), .filter]),
        (PBKnob(label: "LFO 2"), [.lfo, .i(1), .filter]),
        ],[
        (env, nil),
        (PBKnob(label: "Env Depth"), [.filter, .env, .depth]),
        (PBKnob(label: "Velo > Env"), [.filter, .env, .velo]),
        (PBKnob(label: "Key > Time"), [.filter, .env, .time, .keyTrk]),
        ],[
        (PBKnob(label: "T1"), [.filter, .env, .time, .i(0)]),
        (PBKnob(label: "T2"), [.filter, .env, .time, .i(1)]),
        (PBKnob(label: "T3"), [.filter, .env, .time, .i(2)]),
        (PBKnob(label: "T4"), [.filter, .env, .time, .i(3)]),
        (PBKnob(label: "Velo > Time"), [.filter, .env, .time, .velo]),
        ],[
        (PBKnob(label: "L1"), [.filter, .env, .level, .i(0)]),
        (PBKnob(label: "L2"), [.filter, .env, .level, .i(1)]),
        (PBKnob(label: "Sus L"), [.filter, .env, .level, .i(2)]),
        (PBKnob(label: "L4"), [.filter, .env, .level, .i(3)]),
        (SpacerItem(), nil),
        ]])
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()

      let env = self.env
      (0..<4).forEach { index in
        addPatchChangeBlock(path: [.filter, .env, .time, .i(index)]) {
          env.set(rate: CGFloat($0) / 100, forIndex: index)
        }
        addPatchChangeBlock(path: [.filter, .env, .level, .i(index)]) {
          env.set(level: CGFloat($0) / 100, forIndex: index)
        }
      }

      registerForEditMenu(env, bundle: (
        paths: {[[.filter, .env, .time, .i(0)],
                [.filter, .env, .time, .i(1)],
                [.filter, .env, .time, .i(2)],
                [.filter, .env, .time, .i(3)],
                [.filter, .env, .level, .i(0)],
                [.filter, .env, .level, .i(1)],
                [.filter, .env, .level, .i(2)],
                [.filter, .env, .level, .i(3)],
        ]},
        pasteboardType: "com.cfshpd.JD990FilterAmpEnvelope",
        initialize: nil,
        randomize: nil
      ))
    }
  }
  
  class PaletteFilterController : FilterController {
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSwitch(label: "Filter"), [.filter, .type]),
        (PBKnob(label: "Cutoff"), [.cutoff]),
        (PBKnob(label: "Reson"), [.reson]),
        (PBKnob(label: "Key > Cutoff"), [.cutoff, .keyTrk]),
        ],[
        (env, nil),
        (PBKnob(label: "Env Depth"), [.filter, .env, .depth]),
        (PBKnob(label: "Key > Time"), [.filter, .env, .time, .keyTrk]),
        ],[
        (PBKnob(label: "T1"), [.filter, .env, .time, .i(0)]),
        (PBKnob(label: "T2"), [.filter, .env, .time, .i(1)]),
        (PBKnob(label: "T3"), [.filter, .env, .time, .i(2)]),
        (PBKnob(label: "T4"), [.filter, .env, .time, .i(3)]),
        ],[
        (PBKnob(label: "L1"), [.filter, .env, .level, .i(0)]),
        (PBKnob(label: "L2"), [.filter, .env, .level, .i(1)]),
        (PBKnob(label: "Sus L"), [.filter, .env, .level, .i(2)]),
        (PBKnob(label: "L4"), [.filter, .env, .level, .i(3)]),
        ],[
        (PBKnob(label: "Velo > Env"), [.filter, .env, .velo]),
        (PBKnob(label: "Velo > Time"), [.filter, .env, .time, .velo]),
        ],[
        (PBKnob(label: "LFO 1"), [.lfo, .i(0), .filter]),
        (PBKnob(label: "LFO 2"), [.lfo, .i(1), .filter]),
        ]])
      
      addColor(view: view)
    }
  }
  
  
  // MARK: Amp

  class AmpController : NewPatchEditorController {
    
    fileprivate let env = PBRateLevelEnvelopeControl(label: "Amp")

    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSwitch(label: "Bias Dir"), [.bias, .direction]),
        (PBKnob(label: "Bias Pt"), [.bias, .pt]),
        (PBKnob(label: "Bias Lvl"), [.bias, .level]),
        (PBKnob(label: "LFO 1"), [.lfo, .i(0), .amp]),
        (PBKnob(label: "LFO 2"), [.lfo, .i(1), .amp]),
        ],[
        (env, nil),
        (PBKnob(label: "Velo > Env"), [.amp, .env, .velo]),
        (PBKnob(label: "Velo > Time"), [.amp, .env, .time, .velo]),
        (PBKnob(label: "Key > Time"), [.amp, .env, .time, .keyTrk]),
        ],[
        (PBKnob(label: "T1"), [.amp, .env, .time, .i(0)]),
        (PBKnob(label: "T2"), [.amp, .env, .time, .i(1)]),
        (PBKnob(label: "T3"), [.amp, .env, .time, .i(2)]),
        (PBKnob(label: "T4"), [.amp, .env, .time, .i(3)]),
        ],[
        (PBKnob(label: "L1"), [.amp, .env, .level, .i(0)]),
        (PBKnob(label: "L2"), [.amp, .env, .level, .i(1)]),
        (PBKnob(label: "Sus L"), [.amp, .env, .level, .i(2)]),
        (SpacerItem(), nil),
        ]])
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()

      let env = self.env
      (0..<4).forEach { index in
        addPatchChangeBlock(path: [.amp, .env, .time, .i(index)]) {
          env.set(rate: CGFloat($0) / 100, forIndex: index)
        }
      }
      (0..<3).forEach { index in
        addPatchChangeBlock(path: [.amp, .env, .level, .i(index)]) {
          env.set(level: CGFloat($0) / 100, forIndex: index)
        }
      }

      registerForEditMenu(env, bundle: (
        paths: {[[.amp, .env, .time, .i(0)],
                [.amp, .env, .time, .i(1)],
                [.amp, .env, .time, .i(2)],
                [.amp, .env, .time, .i(3)],
                [.amp, .env, .level, .i(0)],
                [.amp, .env, .level, .i(1)],
                [.amp, .env, .level, .i(2)],
        ]},
        pasteboardType: "com.cfshpd.JD990FilterAmpEnvelope",
        initialize: nil,
        randomize: nil
      ))
    }
    
  }
  
  class PaletteAmpController : AmpController {
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBKnob(label: "Level"), [.level]),
        (PBSwitch(label: "Bias Dir"), [.bias, .direction]),
        (PBKnob(label: "Bias Pt"), [.bias, .pt]),
        (PBKnob(label: "Bias Lvl"), [.bias, .level]),
        ],[
        (env, nil),
        (PBKnob(label: "Key > Time"), [.amp, .env, .time, .keyTrk]),
        ],[
        (PBKnob(label: "T1"), [.amp, .env, .time, .i(0)]),
        (PBKnob(label: "T2"), [.amp, .env, .time, .i(1)]),
        (PBKnob(label: "T3"), [.amp, .env, .time, .i(2)]),
        (PBKnob(label: "T4"), [.amp, .env, .time, .i(3)]),
        ],[
        (PBKnob(label: "L1"), [.amp, .env, .level, .i(0)]),
        (PBKnob(label: "L2"), [.amp, .env, .level, .i(1)]),
        (PBKnob(label: "Sus L"), [.amp, .env, .level, .i(2)]),
        (SpacerItem(), nil),
        ],[
        (PBKnob(label: "Velo > Env"), [.amp, .env, .velo]),
        (PBKnob(label: "Velo > Time"), [.amp, .env, .time, .velo]),
        (PBKnob(label: "Pan"), [.pan]),
        (PBKnob(label: "Key > Pan"), [.pan, .keyTrk]),
        ],[
        (PBKnob(label: "LFO 1"), [.lfo, .i(0), .amp]),
        (PBKnob(label: "LFO 2"), [.lfo, .i(1), .amp]),
        ]])
      
      addColor(view: view)
    }
  }
  
  
  // MARK: LFO
    
  class LFOController : NewPatchEditorController {
    
    let wave = PBSelect(label: "LFO")
    
    override var index: Int {
      didSet { wave.label = "LFO \(index + 1)" }
    }
    
    override var prefix: SynthPath? { return [.lfo, .i(index)] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (wave, [.wave]),
        (PBKnob(label: "Rate"), [.rate]),
        (PBKnob(label: "Delay"), [.delay]),
        (PBSwitch(label: "Offset"), [.offset]),
        (PBCheckbox(label: "Key Trig"), [.key, .trigger]),
        (PBKnob(label: "Fade"), [.fade]),
        ]])
      
      addColor(view: view)
    }
  }
  
  class PaletteLFOController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      let _: [PLFOController] = addChildren(count: 2, panelPrefix: "vc")
      addPanelsToLayout(andView: view)
      layout.addGridConstraints([[("vc0", 1)], [("vc1", 1)]], pinMargin: "", spacing: "-s1-")
      
      addColorToAll()
    }
        
    class PLFOController : LFOController {
      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (wave, [.wave]),
          (PBKnob(label: "Rate"), [.rate]),
          (PBCheckbox(label: "Key Trig"), [.key, .trigger]),
          ],[
          (PBKnob(label: "Delay"), [.delay]),
          (PBKnob(label: "Fade"), [.fade]),
          (PBSwitch(label: "Offset"), [.offset]),
          ],[
          (PBKnob(label: "Pitch"), [.pitch]),
          (PBKnob(label: "Filter"), [.filter]),
          (PBKnob(label: "Amp"), [.amp]),
          ]])
      }
    }
  }
  
  
  
  // MARK: Ctrl

  class CtrlController : NewPatchEditorController {
    
    var label = LabelItem(text: "Ctrl", gridWidth: 2)
    var dynLabel = LabelItem(text: "", gridWidth: 3)
    let amts = (0..<4).map { PBKnob(label: "Amt \($0 + 1)") }
    let dests = (0..<4).map { PBSelect(label: "Dest \($0 + 1)") }

    override var index: Int {
      didSet { label.text = "Ctrl \(index + 1)" }
    }
    
    override var prefix: SynthPath? { return [.ctrl, .i(index)] }
    
    override func loadView(_ view: PBView) {
      label.textAlignment = .center
      dynLabel.textAlignment = .center
      
      grid(view: view, items: [[
        (label, nil),
        ] + amtItems(),[
        (dynLabel, nil),
        ] + destItems()])
    }
    
    func amtItems() -> [(PBView, SynthPath?)] {
      return (0..<4).map { (amts[$0], [.depth, .i($0)]) }
    }

    func destItems() -> [(PBView, SynthPath?)] {
      return (0..<4).map { (dests[$0], [.dest, .i($0)]) }
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      (0..<4).forEach { i in
        addPatchChangeBlock(path: [.depth, .i(i)]) { [weak self] in
          let alpha: CGFloat = $0 == 50 ? 0.4 : 1
          self?.amts[i].alpha = alpha
          self?.dests[i].alpha = alpha
        }
      }
      
      addPatchChangeBlock { [weak self] (changes) in
        guard let values = self?.updatedValuesForFullPaths(fullPaths: [
          [.common, .ctrl, .src, .i(0)],
          [.common, .ctrl, .src, .i(1)],
        ], changes: changes),
          let index = self?.index,
          let newSrc = values[[.common, .ctrl, .src, .i(index)]] else { return }
        let ctrl = JD990CommonPatch.ctrlSrcOptions[newSrc] ?? "?"
        self?.dynLabel.text = "(\(ctrl))"
      }
      
      addColor(view: view)
    }
  }
  
  class PaletteCtrlController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      let _: [PCtrlController] = addChildren(count: 2, panelPrefix: "vc")
      addPanelsToLayout(andView: view)
      layout.addGridConstraints([[("vc0", 1)], [("vc1", 1)]], pinMargin: "", spacing: "-s1-")
      
      addColorToAll()
    }

    
    class PCtrlController : CtrlController {
      override func loadView(_ view: PBView) {
        label.textAlignment = .center
        dynLabel.textAlignment = .center
        
        grid(view: view, items: [[
          (label, nil),
          (dynLabel, nil),
          ],
          amtItems(),
          destItems(),
          ])
      }
    }
  }

}

