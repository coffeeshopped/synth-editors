
class JD800VoiceController : NewPagedEditorController {
  
  private let commonController = CommonController()
  private let toneController = ToneController()
  private let pitchesController = PaletteController<PalettePitchController>()
  private let filtersController = PaletteController<PaletteFilterController>()
  private let ampsController = PaletteController<PaletteAmpController>()
  private let lfosController = PaletteController<PaletteLFOController>()
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch", "on"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch", 12), ("on", 4)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",8),
      ], pinned: true, spacing: "-s1-")

    switchCtrl = PBSegmentedControl(items: ["Common","A","B","C","D", "Pitch", "Filter", "Amp", "LFO"])
    quickGrid(panel: "switch", items: [[(switchCtrl, nil, "switchCtrl")]])
    
    quickGrid(panel: "on", items: [[
      (PBCheckbox(label: "A"), [.common, .tone, .i(0), .on], nil),
      (PBCheckbox(label: "B"), [.common, .tone, .i(1), .on], nil),
      (PBCheckbox(label: "C"), [.common, .tone, .i(2), .on], nil),
      (PBCheckbox(label: "D"), [.common, .tone, .i(3), .on], nil)
      ]])
    
    addColorToAll(except: ["switch"])
    addColor(panels: ["switch"], clearBackground: true)
  }
  
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return commonController
    case 1...4:
      toneController.index = index - 1
      return toneController
    case 5:
      return pitchesController
    case 6:
      return filtersController
    case 7:
      return ampsController
    default:
      return lfosController
    }
  }
  
  func hideFX() {
    commonController.hideFX()
  }

  
  
  class CommonController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      createPanels(forKeys: ["level", "enhance", "groupA", "groupB", "solo", "dist", "phaser", "porta", "spectrum", "lohi", "delay", "chorus", "eq", "reverb", "active", "split"])
      addPanelsToLayout(andView: view)
      
      layout.addColumnConstraints([("level", 1), ("solo", 1), ("porta", 1), ("lohi", 2), ("eq", 2), ("active", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([
        ("dist",1), ("enhance",1), ("phaser",1), ("spectrum",1), ("delay",1), ("chorus",1), ("reverb",1), ("split",1),
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("level", 4), ("dist", 4), ("groupA", 4.5)
      ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("enhance", 4), ("groupB", 4.5)
      ], pinned: false, spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["dist", "groupA"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["groupA", "groupB", "phaser", "spectrum", "delay", "chorus", "reverb", "split"], attribute: .trailing)
      
      quickGrid(panel: "level", items: [[
        (PBKnob(label: "Level"), [.common, .level], nil),
        (PBKnob(label: "Bend Down"), [.common, .bend, .down], nil),
        (PBKnob(label: "Bend Up"), [.common, .bend, .up], nil),
        (PBKnob(label: "AfterT Bend"), [.common, .aftertouch, .bend], nil),
        ]])
      
      let aBlocks = [
        PBCheckbox(label: "Block 1"),
        PBCheckbox(label: "Block 2"),
        PBCheckbox(label: "Block 3"),
        PBCheckbox(label: "Block 4"),
      ]
      quickGrid(panel: "groupA", items: [[
        (PBSelect(label: "Group A"), [.fx, .i(0), .seq], nil),
        (aBlocks[0], [.fx, .i(0), .part, .i(0), .on], nil),
        (aBlocks[1], [.fx, .i(0), .part, .i(1), .on], nil),
        (aBlocks[2], [.fx, .i(0), .part, .i(2), .on], nil),
        (aBlocks[3], [.fx, .i(0), .part, .i(3), .on], nil),
        ]])

      let bBlocks = [
        PBCheckbox(label: "Block 1"),
        PBCheckbox(label: "Block 2"),
        PBCheckbox(label: "Block 3"),
      ]
      quickGrid(panel: "groupB", items: [[
        (PBSelect(label: "Group B"), [.fx, .i(1), .seq], nil),
        (bBlocks[0], [.fx, .i(1), .part, .i(0), .on], nil),
        (bBlocks[1], [.fx, .i(1), .part, .i(1), .on], nil),
        (bBlocks[2], [.fx, .i(1), .part, .i(2), .on], nil),
        (PBKnob(label: "FX Balance"), [.fx, .i(1), .balance], nil),
        ]])

      quickGrid(panel: "solo", items: [[
        (PBCheckbox(label: "Solo"), [.common, .solo], nil),
        (PBCheckbox(label: "Legato"), [.common, .solo, .legato], nil),
        ]])
      
      quickGrid(panel: "enhance", items: [[
        (LabelItem(text: "Enhance", gridWidth: 3), nil, "enhanceCheck"),
        (PBKnob(label: "Sens"), [.fx, .extra, .sens], nil),
        (PBKnob(label: "Mix"), [.fx, .extra, .mix], nil),
        ]])

      quickGrid(panel: "dist", items: [[
        (LabelItem(text: "Dist", gridWidth: 3), nil, "distCheck"),
        (PBSelect(label: "Type"), [.fx, .dist, .type], nil),
        (PBKnob(label: "Drive"), [.fx, .dist, .drive], nil),
        (PBKnob(label: "Level"), [.fx, .dist, .level], nil),
        ]])
      
      quickGrid(panel: "porta", items: [[
        (PBCheckbox(label: "Porta"), [.common, .porta], nil),
        (PBSwitch(label: "Mode"), [.common, .porta, .mode], nil),
        (PBKnob(label: "Time"), [.common, .porta, .time], nil),
        ]])
      
      quickGrid(panel: "phaser", items: [[
        (LabelItem(text: "Phaser", gridWidth: 3), nil, "phaserCheck"),
        (PBKnob(label: "Manual"), [.fx, .phase, .manual], nil),
        (PBKnob(label: "Rate"), [.fx, .phase, .rate], nil),
        (PBKnob(label: "Depth"), [.fx, .phase, .depth], nil),
        (PBKnob(label: "Reson"), [.fx, .phase, .reson], nil),
        (PBKnob(label: "Mix"), [.fx, .phase, .mix], nil),
        ]])
      
      quickGrid(panel: "lohi", items: [[
        (PBKnob(label: "A Low"), [.common, .tone, .i(0), .key, .lo], nil),
        (PBKnob(label: "B Low"), [.common, .tone, .i(1), .key, .lo], nil),
        (PBKnob(label: "C Low"), [.common, .tone, .i(2), .key, .lo], nil),
        (PBKnob(label: "D Low"), [.common, .tone, .i(3), .key, .lo], nil),
        ],[
        (PBKnob(label: "A Hi"), [.common, .tone, .i(0), .key, .hi], nil),
        (PBKnob(label: "B Hi"), [.common, .tone, .i(1), .key, .hi], nil),
        (PBKnob(label: "C Hi"), [.common, .tone, .i(2), .key, .hi], nil),
        (PBKnob(label: "D Hi"), [.common, .tone, .i(3), .key, .hi], nil),
        ]])
      
      quickGrid(panel: "spectrum", items: [[
        (LabelItem(text: "Spectrum", gridWidth: 3), nil, "spectrumCheck"),
        (PBKnob(label: "Band 1"), [.fx, .spectral, .i(0)], nil),
        (PBKnob(label: "2"), [.fx, .spectral, .i(1)], nil),
        (PBKnob(label: "3"), [.fx, .spectral, .i(2)], nil),
        (PBKnob(label: "4"), [.fx, .spectral, .i(3)], nil),
        (PBKnob(label: "5"), [.fx, .spectral, .i(4)], nil),
        (PBKnob(label: "6"), [.fx, .spectral, .i(5)], nil),
        (PBKnob(label: "Bandwidth"), [.fx, .spectral, .skirt], nil),
        ]])
      
      quickGrid(panel: "delay", items: [[
        (LabelItem(text: "Delay", gridWidth: 3), nil, "delayCheck"),
        (PBKnob(label: "C Tap"), [.fx, .delay, .mid, .time], nil),
        (PBKnob(label: "C Level"), [.fx, .delay, .mid, .level], nil),
        (PBKnob(label: "L Tap"), [.fx, .delay, .left, .time], nil),
        (PBKnob(label: "L Level"), [.fx, .delay, .left, .level], nil),
        (PBKnob(label: "R Tap"), [.fx, .delay, .right, .time], nil),
        (PBKnob(label: "R Level"), [.fx, .delay, .right, .level], nil),
        (PBKnob(label: "Feedback"), [.fx, .delay, .feedback], nil),
        ]])

      quickGrid(panel: "eq", items: [[
        (PBKnob(label: "Lo Gain"), [.common, .lo, .gain], nil),
        (PBKnob(label: "Mid Gain"), [.common, .mid, .gain], nil),
        (PBKnob(label: "Hi Gain"), [.common, .hi, .gain], nil),
        ],[
        (PBSwitch(label: "Lo Freq"), [.common, .lo, .freq], nil),
        (PBKnob(label: "Mid Freq"), [.common, .mid, .freq], nil),
        (PBKnob(label: "Mid Q"), [.common, .mid, .q], nil),
        (PBSwitch(label: "Hi Freq"), [.common, .hi, .freq], nil),
        ]])
          
      quickGrid(panel: "chorus", items: [[
        (LabelItem(text: "Chorus", gridWidth: 3), nil, "chorusCheck"),
        (PBKnob(label: "Rate"), [.fx, .chorus, .rate], nil),
        (PBKnob(label: "Depth"), [.fx, .chorus, .depth], nil),
        (PBKnob(label: "Delay"), [.fx, .chorus, .delay], nil),
        (PBKnob(label: "Feedback"), [.fx, .chorus, .feedback], nil),
        (PBKnob(label: "Level"), [.fx, .chorus, .level], nil),
        ]])

      quickGrid(panel: "reverb", items: [[
        (LabelItem(text: "Reverb", gridWidth: 3), nil, "reverbCheck"),
        (PBSelect(label: "Type"), [.fx, .reverb, .type], nil),
        (PBKnob(label: "Pre Delay"), [.fx, .reverb, .pre], nil),
        (PBKnob(label: "Early Ref"), [.fx, .reverb, .early], nil),
        (PBKnob(label: "HF Damp"), [.fx, .reverb, .hi, .cutoff], nil),
        (PBKnob(label: "Time"), [.fx, .reverb, .time], nil),
        (PBKnob(label: "Level"), [.fx, .reverb, .level], nil),
        ]])

      quickGrid(panel: "active", items: [[
        (PBCheckbox(label: "Active A"), [.common, .tone, .i(0), .active], nil),
        (PBCheckbox(label: "B"), [.common, .tone, .i(1), .active], nil),
        (PBCheckbox(label: "C"), [.common, .tone, .i(2), .active], nil),
        (PBCheckbox(label: "D"), [.common, .tone, .i(3), .active], nil),
        ]])

      quickGrid(panel: "split", items: [[
        (PBSwitch(label: "Key Mode"), [.common, .key, .mode], nil),
        (PBSwitch(label: "Hold Mode"), [.common, .hold], nil),
        (PBKnob(label: "Split Pt"), [.common, .split, .pt], nil),
        (PBKnob(label: "Lo Chan"), [.common, .channel, .lo], nil),
        (PBKnob(label: "Hi Chan"), [.common, .channel, .hi], nil),
        (PBKnob(label: "Lo Pgm"), [.common, .pgmChange, .lo], nil),
        (PBKnob(label: "Hi Pgm"), [.common, .pgmChange, .hi], nil),
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
      
      if shouldHideFX {
        hideFX()
      }

      addColorToAll(except: Self.fxPanels)
      addColor(panels: Self.fxPanels, level: 2)
    }
    
    private static let fxPanels = ["enhance", "groupA", "groupB", "dist", "phaser", "spectrum", "delay", "chorus", "reverb"]
    
    private var shouldHideFX = false
    
    func hideFX() {
      shouldHideFX = true
      type(of: self).fxPanels.forEach {
        panels[$0]?.isHidden = true
      }
    }
  }
  
  
  class ToneController : NewPatchEditorController {

    override var prefix: SynthPath? { return [.tone, .i(index)] }

    override func loadView(_ view: PBView) {
      addChild(PitchController(), withPanel: "pitch")
      addChild(FilterController(), withPanel: "filter")
      addChild(AmpController(), withPanel: "amp")
      (0..<2).forEach {
        let vc = LFOController()
        vc.index = $0
        addChild(vc, withPanel: "lfo\($0)")
      }
      createPanels(forKeys: ["velo"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([
        ("pitch", 5), ("filter", 5), ("amp", 5)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("lfo0", 3.5), ("lfo1", 3.5), ("velo", 1)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("pitch", 5), ("lfo0", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      quickGrid(panel: "velo", items: [[
        (PBKnob(label: "Velo Curve"), [.velo, .curve], nil),
        ],[
        (PBCheckbox(label: "Hold"), [.hold, .ctrl], nil),
        ]])
      
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
      
      addColor(panels: ["pitch", "filter", "amp"])
      addColor(panels: ["lfo0", "lfo1", "velo"], level: 2)
    }
        
  }
  
  
  // MARK: Palette
  
  class PaletteController<T:NewPatchEditorController> : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      (0..<4).forEach {
        let vc = T.init()
        vc.index = $0
        addChild(vc, withPanel: "vc\($0)")
        
        let labelKey = "label\($0)"
        createPanels(forKeys: [labelKey])
        let label = LabelItem(text: ["A", "B", "C", "D"][$0])
        label.textAlignment = .center
        quickGrid(panel: labelKey, items: [[(label, nil, "\(labelKey)view")]])
      }
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([
        ("label0", 1), ("label1", 1), ("label2", 1), ("label3", 1),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("vc0", 1), ("vc1", 1), ("vc2", 1), ("vc3", 1)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("label0", 1), ("vc0", 8)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      addPatchChangeBlock { [weak self] (changes) in
        guard let values = self?.updatedValuesForFullPaths(fullPaths: [
          [.common, .tone, .i(0), .on],
          [.common, .tone, .i(1), .on],
          [.common, .tone, .i(2), .on],
          [.common, .tone, .i(3), .on],
        ], changes: changes) else { return }
        (0..<4).forEach {
          self?.panels["vc\($0)"]?.alpha = values[[.common, .tone, .i($0), .on]] == 1 ? 1 : 0.4
        }
      }

      addColorToAll()
      (0..<4).forEach {
        guard let v = panels["vc\($0)"] else { return }
        addBorder(view: v)
      }

    }
    
  }
  
  
  // MARK: Pitch
  
  class PitchController : NewPatchEditorController {
    
    fileprivate let env = PBRateLevelEnvelopeControl(label: "Pitch")
    fileprivate let wave = PBSelect(label: "Wave")
    private var cardOptions = [Int:String]()

    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[
        (PBSwitch(label: "Source"), [.wave, .group], nil),
        (wave, [.wave, .number], nil),
        (PBKnob(label: "Pitch"), [.pitch, .coarse], nil),
        (PBKnob(label: "Fine"), [.pitch, .fine], nil),
        ],[
        (PBKnob(label: "Keyfollow"), [.pitch, .keyTrk], nil),
        (env, nil, "pitchEnv"),
        (PBKnob(label: "Velo"), [.pitch, .env, .velo], nil),
        (PBKnob(label: "Random"), [.pitch, .random], nil),
        ],[
        (PBKnob(label: "Lever Sens"), [.pitch, .ctrl, .depth], nil),
        (PBKnob(label: "T1"), [.pitch, .env, .time, .i(0)], nil),
        (PBKnob(label: "T2"), [.pitch, .env, .time, .i(1)], nil),
        (PBKnob(label: "T3"), [.pitch, .env, .time, .i(2)], nil),
        ],[
        (PBKnob(label: "L0"), [.pitch, .env, .level, .i(-1)], nil),
        (PBKnob(label: "L1"), [.pitch, .env, .level, .i(0)], nil),
        (PBKnob(label: "L2"), [.pitch, .env, .level, .i(1)], nil),
        (PBKnob(label: "Bend"), [.bend], nil),
        (PBKnob(label: "Bend AfterT"), [.pitch, .aftertouch], nil),
        ],[
        (PBKnob(label: "Velo > Time"), [.pitch, .env, .time, .velo], nil),
        (PBKnob(label: "Key > Time"), [.pitch, .env, .time, .keyTrk], nil),
        (PBKnob(label: "AfterT Mod"), [.pitch, .aftertouch, .mod], nil),
        (PBKnob(label: "LFO 1"), [.pitch, .lfo, .i(0), .depth], nil),
        (PBKnob(label: "LFO 2"), [.pitch, .lfo, .i(1), .depth], nil),
        ]])
      
      setupBlocks()
    }
    
    private func updateWave(group: Int) {
      switch group {
      case 0:
        wave.options = JD800TonePatch.internalWaveOptions
      default:
        wave.options = cardOptions
      }
    }
    
    fileprivate func setupBlocks() {
      addPatchChangeBlock(path: [.wave, .group]) { [weak self] (value) in
        self?.updateWave(group: value)
      }

      // Card Options
      addParamChangeBlock { [weak self] (params) in
        guard let param = params.params[[.pcm]] as? OptionsParam else { return }
        self?.cardOptions = param.options
        guard let group = self?.latestValue(path: [.wave, .group]) else { return }
        self?.updateWave(group: group)
      }

      let env = self.env
      env.bipolar = true
      env.sustainPoint = 2
      env.pointCount = 3

      (0..<3).forEach { time in
        addDefaultPatchChangeBlock(control: env, path: [.pitch, .env, .time, .i(time)]) {
          env.set(rate: CGFloat($0) / 100, forIndex: time)
        }
      }
      (0..<2).forEach { level in
        addDefaultPatchChangeBlock(control: env, path: [.pitch, .env, .level, .i(level)]) {
          env.set(level: CGFloat($0 - 50) / 50, forIndex: level)
        }
      }
      addDefaultPatchChangeBlock(control: env, path: [.pitch, .env, .level, .i(-1)]) {
        env.startLevel = CGFloat($0 - 50) / 50
      }

      registerForEditMenu(env, bundle: (
        paths: {[[.pitch, .env, .time, .i(0)],
                [.pitch, .env, .time, .i(1)],
                [.pitch, .env, .time, .i(2)],
                [.pitch, .env, .level, .i(0)],
                [.pitch, .env, .level, .i(1)],
                [.pitch, .env, .level, .i(-1)],
        ]},
        pasteboardType: "com.cfshpd.JD800PitchEnvelope",
        initialize: nil,
        randomize: nil
      ))
    }
    
  }

  
  class PalettePitchController : PitchController {
    
    override var prefix: SynthPath? { return [.tone, .i(index)] }
    
    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[
        (PBSwitch(label: "Source"), [.wave, .group], nil),
        (wave, [.wave, .number], nil),
        (PBKnob(label: "Pitch"), [.pitch, .coarse], nil),
        (PBKnob(label: "Fine"), [.pitch, .fine], nil),
        ],[
        (PBKnob(label: "Keyfollow"), [.pitch, .keyTrk], nil),
        (env, nil, "pitchEnv"),
        (PBKnob(label: "Velo"), [.pitch, .env, .velo], nil),
        (PBKnob(label: "Random"), [.pitch, .random], nil),
        ],[
        (PBKnob(label: "Lever Sens"), [.pitch, .ctrl, .depth], nil),
        (PBKnob(label: "T1"), [.pitch, .env, .time, .i(0)], nil),
        (PBKnob(label: "T2"), [.pitch, .env, .time, .i(1)], nil),
        (PBKnob(label: "T3"), [.pitch, .env, .time, .i(2)], nil),
        ],[
        (PBKnob(label: "L0"), [.pitch, .env, .level, .i(-1)], nil),
        (PBKnob(label: "L1"), [.pitch, .env, .level, .i(0)], nil),
        (PBKnob(label: "L2"), [.pitch, .env, .level, .i(1)], nil),
        ],[
        (PBKnob(label: "Velo > Time"), [.pitch, .env, .time, .velo], nil),
        (PBKnob(label: "Key > Time"), [.pitch, .env, .time, .keyTrk], nil),
        (PBKnob(label: "AfterT Mod"), [.pitch, .aftertouch, .mod], nil),
        ],[
        (PBKnob(label: "Bend"), [.bend], nil),
        (PBKnob(label: "Bend AfterT"), [.pitch, .aftertouch], nil),
        (PBKnob(label: "LFO 1"), [.pitch, .lfo, .i(0), .depth], nil),
        (PBKnob(label: "LFO 2"), [.pitch, .lfo, .i(1), .depth], nil),
        ]])
      
      setupBlocks()
    }
    
  }
  
  // MARK: Filter

  class FilterController : NewPatchEditorController {
    
    fileprivate let env = PBRateLevelEnvelopeControl(label: "Filter")

    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[
        (PBSwitch(label: "Filter"), [.filter, .type], nil),
        (PBKnob(label: "Cutoff"), [.cutoff], nil),
        (PBKnob(label: "Reson"), [.reson], nil),
        (PBKnob(label: "Key > Cutoff"), [.filter, .keyTrk], nil),
        ],[
        (env, nil, "filterEnv"),
        (PBKnob(label: "Velo"), [.filter, .env, .velo], nil),
        (PBKnob(label: "Env Depth"), [.filter, .env, .depth], nil),
        ],[
        (PBKnob(label: "T1"), [.filter, .env, .time, .i(0)], nil),
        (PBKnob(label: "T2"), [.filter, .env, .time, .i(1)], nil),
        (PBKnob(label: "T3"), [.filter, .env, .time, .i(2)], nil),
        (PBKnob(label: "T4"), [.filter, .env, .time, .i(3)], nil),
        ],[
        (PBKnob(label: "L1"), [.filter, .env, .level, .i(0)], nil),
        (PBKnob(label: "L2"), [.filter, .env, .level, .i(1)], nil),
        (PBKnob(label: "L3"), [.filter, .env, .level, .i(2)], nil),
        (PBKnob(label: "L4"), [.filter, .env, .level, .i(3)], nil),
        ],[
        (PBKnob(label: "Velo > Time"), [.filter, .env, .time, .velo], nil),
        (PBKnob(label: "Key > Time"), [.filter, .env, .time, .keyTrk], nil),
        (PBKnob(label: "AfterT"), [.filter, .aftertouch, .depth], nil),
        (PBSwitch(label: "LFO"), [.filter, .lfo], nil),
        (PBKnob(label: "Depth"), [.filter, .lfo, .depth], nil),
        ]])
      
      setupEnvs()
    }
    
    fileprivate func setupEnvs() {
      let env = self.env

      (0..<4).forEach { index in
        addDefaultPatchChangeBlock(control: env, path: [.filter, .env, .time, .i(index)]) {
          env.set(rate: CGFloat($0) / 100, forIndex: index)
        }
        addDefaultPatchChangeBlock(control: env, path: [.filter, .env, .level, .i(index)]) {
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
        pasteboardType: "com.cfshpd.JD800RateLevelEnvelope",
        initialize: nil,
        randomize: nil
      ))
    }
    
  }

  
  class PaletteFilterController : FilterController {
    
    override var prefix: SynthPath? { return [.tone, .i(index)] }
    
    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[
        (PBSwitch(label: "Filter"), [.filter, .type], nil),
        (PBKnob(label: "Cutoff"), [.cutoff], nil),
        (PBKnob(label: "Reson"), [.reson], nil),
        (PBKnob(label: "Key > Cutoff"), [.filter, .keyTrk], nil),
        ],[
        (env, nil, "filterEnv"),
        (PBKnob(label: "Velo"), [.filter, .env, .velo], nil),
        (PBKnob(label: "Env Depth"), [.filter, .env, .depth], nil),
        ],[
        (PBKnob(label: "T1"), [.filter, .env, .time, .i(0)], nil),
        (PBKnob(label: "T2"), [.filter, .env, .time, .i(1)], nil),
        (PBKnob(label: "T3"), [.filter, .env, .time, .i(2)], nil),
        (PBKnob(label: "T4"), [.filter, .env, .time, .i(3)], nil),
        ],[
        (PBKnob(label: "L1"), [.filter, .env, .level, .i(0)], nil),
        (PBKnob(label: "L2"), [.filter, .env, .level, .i(1)], nil),
        (PBKnob(label: "L3"), [.filter, .env, .level, .i(2)], nil),
        (PBKnob(label: "L4"), [.filter, .env, .level, .i(3)], nil),
        ],[
        (PBKnob(label: "Velo > Time"), [.filter, .env, .time, .velo], nil),
        (PBKnob(label: "Key > Time"), [.filter, .env, .time, .keyTrk], nil),
        (PBKnob(label: "AfterT"), [.filter, .aftertouch, .depth], nil),
        ],[
        (PBSwitch(label: "LFO"), [.filter, .lfo], nil),
        (PBKnob(label: "Depth"), [.filter, .lfo, .depth], nil),
        ]])
      
      setupEnvs()
    }
    
  }

  
  // MARK: Amp

  class AmpController : NewPatchEditorController {
    
    fileprivate let env = PBRateLevelEnvelopeControl(label: "Amp")

    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[
        (PBKnob(label: "Level"), [.level], nil),
        (PBSwitch(label: "Bias Dir"), [.bias, .direction], nil),
        (PBKnob(label: "Bias Pt"), [.bias, .pt], nil),
        (PBKnob(label: "Bias Level"), [.bias, .level], nil),
        ],[
        (env, nil, "ampEnv"),
        (PBKnob(label: "Velo"), [.amp, .env, .velo], nil),
        ],[
        (PBKnob(label: "T1"), [.amp, .env, .time, .i(0)], nil),
        (PBKnob(label: "T2"), [.amp, .env, .time, .i(1)], nil),
        (PBKnob(label: "T3"), [.amp, .env, .time, .i(2)], nil),
        (PBKnob(label: "T4"), [.amp, .env, .time, .i(3)], nil),
        ],[
        (PBKnob(label: "L1"), [.amp, .env, .level, .i(0)], nil),
        (PBKnob(label: "L2"), [.amp, .env, .level, .i(1)], nil),
        (PBKnob(label: "L3"), [.amp, .env, .level, .i(2)], nil),
        ],[
        (PBKnob(label: "Velo > Time"), [.amp, .env, .time, .velo], nil),
        (PBKnob(label: "Key > Time"), [.amp, .env, .time, .keyTrk], nil),
        (PBKnob(label: "AfterT"), [.amp, .aftertouch, .depth], nil),
        (PBSwitch(label: "LFO"), [.amp, .lfo], nil),
        (PBKnob(label: "Depth"), [.amp, .lfo, .depth], nil),
        ]])
      
      setupEnvs()
    }
    
    fileprivate func setupEnvs() {
      let env = self.env

      (0..<4).forEach { index in
        addDefaultPatchChangeBlock(control: env, path: [.amp, .env, .time, .i(index)]) {
          env.set(rate: CGFloat($0) / 100, forIndex: index)
        }
      }
      (0..<3).forEach { index in
        addDefaultPatchChangeBlock(control: env, path: [.amp, .env, .level, .i(index)]) {
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
        pasteboardType: "com.cfshpd.JD800RateLevelEnvelope",
        initialize: nil,
        randomize: nil
      ))
    }
    
  }

  
  class PaletteAmpController : AmpController {
    
    override var prefix: SynthPath? { return [.tone, .i(index)] }
    
    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[
        (PBKnob(label: "Level"), [.level], nil),
        (PBSwitch(label: "Bias Dir"), [.bias, .direction], nil),
        (PBKnob(label: "Bias Pt"), [.bias, .pt], nil),
        (PBKnob(label: "Bias Level"), [.bias, .level], nil),
        ],[
        (env, nil, "ampEnv"),
        (PBKnob(label: "Velo"), [.amp, .env, .velo], nil),
        ],[
        (PBKnob(label: "T1"), [.amp, .env, .time, .i(0)], nil),
        (PBKnob(label: "T2"), [.amp, .env, .time, .i(1)], nil),
        (PBKnob(label: "T3"), [.amp, .env, .time, .i(2)], nil),
        (PBKnob(label: "T4"), [.amp, .env, .time, .i(3)], nil),
        ],[
        (PBKnob(label: "L1"), [.amp, .env, .level, .i(0)], nil),
        (PBKnob(label: "L2"), [.amp, .env, .level, .i(1)], nil),
        (PBKnob(label: "L3"), [.amp, .env, .level, .i(2)], nil),
        ],[
        (PBKnob(label: "Velo > Time"), [.amp, .env, .time, .velo], nil),
        (PBKnob(label: "Key > Time"), [.amp, .env, .time, .keyTrk], nil),
        (PBKnob(label: "AfterT"), [.amp, .aftertouch, .depth], nil),
        ],[
        (PBSwitch(label: "LFO"), [.amp, .lfo], nil),
        (PBKnob(label: "Depth"), [.amp, .lfo, .depth], nil),
        ]])
      
      setupEnvs()
    }
    
  }
  
  
  // MARK: LFO
  
  class LFOController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.lfo, .i(index)] }
    
    private let wave = PBSelect(label: "LFO")
    
    override var index: Int {
      didSet { wave.label = "LFO \(index + 1)" }
    }
    
    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[
        (PBKnob(label: "Rate"), [.rate], nil),
        (PBKnob(label: "Delay"), [.delay], nil),
        (PBKnob(label: "Fade"), [.fade], nil),
        ],[
        (wave, [.wave], nil),
        (PBSwitch(label: "Offset"), [.offset], nil),
        (PBCheckbox(label: "Key Trig"), [.key, .sync], nil),
        ]])
    }
  }
  
  class PaletteLFOController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.tone, .i(index)] }

    override func loadView(_ view: PBView) {
      (0..<2).forEach {
        let vc = LFOController()
        vc.index = $0
        addChild(vc, withPanel: "lfo\($0)")
      }
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([[("lfo0", 1)], [("lfo1", 1)]], pinMargin: "", spacing: "-s1-")
      
      addColorToAll()
    }

  }
}
