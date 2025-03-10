
class D50MainController : NewPagedEditorController {

  private let commonController = CommonController()
  private let toneController = FullToneController()
  private let pitchController = TwoToneController<PitchWaveController>()
  private let filterController = TwoToneController<ToneFilterController>()
  private let ampController = TwoToneController<ToneAmpController>()

  override func loadView(_ view: PBView) {
    switchCtrl = PBSegmentedControl(items: ["Common/FX", "Upper", "Lower", "Pitch/Wave", "Filter", "Amp"])
    grid(panel: "switch", items: [[(switchCtrl, nil)]])

    let tBal = PBKnob(label: "Tone Bal")
    let lp1 = PBCheckbox(label: "Lower P1")
    let lBal = PBKnob(label: "Lower Bal")
    let lp2 = PBCheckbox(label: "Lower P2")
    grid(panel: "hi", prefix: [.hi, .common, .partial], items: [[
      (PBCheckbox(label: "Upper P1"), [.i(0), .on]),
      (PBKnob(label: "Upper Bal"), [.balance]),
      (PBCheckbox(label: "Upper P2"), [.i(1), .on]),
      ]])
    grid(panel: "bal", items: [[
      (tBal, [.common, .tone, .balance]),
      ]])
    grid(panel: "lo", prefix: [.lo, .common, .partial], items: [[
      (lp1, [.i(0), .on]),
      (lBal, [.balance]),
      (lp2, [.i(1), .on]),
      ]])

    addPanelsToLayout(andView: view)

    layout.addGridConstraints([
      (row: [("switch", 9), ("hi", 3), ("bal", 1), ("lo", 3)], height: 1),
      (row: [("page", 1)], height: 8),
    ], spacing: "-s1-")

    addPatchChangeBlock(path: [.common, .key, .mode]) {
      let lowerActive = ![0, 4].contains($0)
      [tBal, lp1, lBal, lp2].forEach { $0.alpha = lowerActive ? 1 : 0.4 }
    }
    
    addColor(panels: ["hi", "bal", "lo"])
    addColor(panels: ["switch"], clearBackground: true)
  }

  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return commonController
    case 1, 2:
      toneController.index = index - 1
      return toneController
    case 3:
      return pitchController
    case 4:
      return filterController
    default:
      return ampController
    }
  }
  
  class CommonController : NewPatchEditorController {

    private let outDropdown = PBImageSelect(label: "Output Mode", imageSize: CGSize(width: 220, height: 80), imageSpacing: 12)

    override func loadView() {
      let paddedView = PaddedContainer()
      paddedView.horizontalPadding = 0
      let view = paddedView.mainView
      
      let _: [CommonToneController] = addChildren(count: 2, panelPrefix: "tone")

      let split = PBKnob(label: "Split")
      grid(panel: "key", items: [[
        (PBSelect(label: "Key Mode"), [.common, .key, .mode]),
        (split, [.common, .split]),
        ]])
  
      let lTrans = PBKnob(label: "L Trans")
      let lFine = PBKnob(label: "L Fine")
      grid(panel: "trans", items: [[
        (PBKnob(label: "U Trans"), [.common, .hi, .transpose]),
        (PBKnob(label: "U Fine"), [.common, .hi, .fine]),
        (lTrans, [.common, .lo, .transpose]),
        (lFine, [.common, .lo, .fine]),
        ]])
  
      grid(panel: "chase", items: [[
        (PBSwitch(label: "Chase"), [.common, .chase, .mode]),
        (PBKnob(label: "Level"), [.common, .chase, .level]),
        (PBKnob(label: "Time"), [.common, .chase, .time]),
        ]])
  
      grid(panel: "porta", items: [[
        (PBSwitch(label: "Porta"), [.common, .porta]),
        (PBKnob(label: "Time"), [.common, .porta, .time]),
        ]])
  
      grid(panel: "midi", items: [[
        (PBKnob(label: "MIDI Tx"), [.common, .midi, .send]),
        (PBKnob(label: "MIDI Rx"), [.common, .midi, .rcv]),
        (PBKnob(label: "Prog Ch"), [.common, .midi, .pgmChange]),
        ]])
    
      grid(panel: "hold", items: [[
        (PBSwitch(label: "Hold"), [.common, .hold]),
        (PBKnob(label: "Bend"), [.common, .bend]),
        (PBKnob(label: "Aftert. Bend"), [.common, .aftertouch, .bend]),
        ]])
  
      grid(panel: "reverb", items: [[
        (outDropdown, [.common, .out, .mode]),
        (PBSelect(label: "Reverb"), [.common, .reverb]),
        (PBKnob(label: "Balance"), [.common, .reverb, .balance]),
        ]])
  
      grid(panel: "balance", items: [[
        (PBKnob(label: "Volume"), [.common, .volume]),
        ]])
      
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("key", 2.5), ("trans", 4), ("chase", 3), ("porta", 2), ("midi", 3)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("hold", 3), ("reverb", 4.5), ("balance", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("tone0", 1), ("tone1", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("key", 1), ("hold", 1), ("tone0", 2)], pinned: true, pinMargin: "", spacing: "-s1-")

      layout.activateConstraints()
      self.view = paddedView

      addPatchChangeBlock(path: [.common, .key, .mode]) {
        let splitAlpha: CGFloat = [2, 6, 7].contains($0) ? 1 : 0.4
        split.alpha = splitAlpha
      }

      addColor(panels: ["key", "trans", "chase", "porta", "midi", "hold", "reverb", "balance"])

    }
    
  }

  class CommonToneController : ToneController {

    override func loadView(_ view: PBView) {
      addChild(EQController(), withPanel: "eq")
      addChild(ChorusController(), withPanel: "chorus")
      addChild(StructureController(), withPanel: "structure")

      grid(panel: "name", items: [[(labeledNameField, nil)]])
      
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([
        ("name", 4), ("eq", 5),
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("structure" , 3), ("chorus" , 4.5),
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([
        ("name", 1), ("structure", 1)
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      
      addColorToAll(level: 2)
    }
  }
  
  class StructureController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      let structDropdown = PBImageSelect(label: "Structure", imageSize: CGSize(width: 200, height: 70), imageSpacing: 12)
      grid(view: view, items: [[(structDropdown, [.common, .structure])]])
    }
  }
  
  class EQController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBKnob(label: "Lo Freq"), [.common, .lo, .freq]),
        (PBKnob(label: "Lo Gain"), [.common, .lo, .gain]),
        (PBKnob(label: "Hi Freq"), [.common, .hi, .freq]),
        (PBKnob(label: "Hi Q"), [.common, .hi, .q]),
        (PBKnob(label: "Hi Gain"), [.common, .hi, .gain]),
        ]])
    }
  }
  
  class ChorusController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSelect(label: "Chorus"), [.common, .chorus, .type]),
        (PBKnob(label: "Rate"), [.common, .chorus, .rate]),
        (PBKnob(label: "Depth"), [.common, .chorus, .depth]),
        (PBKnob(label: "Balance"), [.common, .chorus, .balance]),
        ]])
    }
  }
  

  class FullToneController : ToneController {

    override func loadView(_ view: PBView) {
      addChild(MyPitchController(), withPanel: "pitch")
      addChild(EQController(), withPanel: "eq")
      addChild(ChorusController(), withPanel: "chorus")
      addChild(OneLineLFOController(), withPanel: "lfo")
      addChild(StructureController(), withPanel: "structure")
      
      let waveController = MyWaveController()
      let filterController = MyFilterController()
      let ampController = MyAmpController()
      let menuController = MyMenuController()
      addChild(waveController, withPanel: "wave")
      addChild(filterController, withPanel: "filter")
      addChild(ampController, withPanel: "amp")
      addChild(menuController, withPanel: "menu")
      partialControllers.append(contentsOf: [menuController, waveController, filterController, ampController])
      
      grid(panel: "name", items: [[(labeledNameField, nil)]])

      let button = createButton(titled: "Tone + Partials")
      grid(panel: "toneMenu", items: [[(button, nil)]])

      let partialSwitch = LabeledSegmentedControl(label: "Partial", items: ["1", "2"])
      partialSwitch.segmentedControl.addValueChangeTarget(self, action: #selector(selectPartial(_:)))
      selectPartial(partialSwitch.segmentedControl)
      grid(panel: "switch", items: [[(partialSwitch, nil)]])
      
      createPanels(forKeys: ["space"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("name", 3), ("eq", 5), ("pitch", 6)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("toneMenu", 3), ("chorus", 5)], pinned: false, spacing: "-s1-")
      layout.addRowConstraints([("structure", 2), ("lfo", 6)], pinned: false, spacing: "-s1-")
      layout.addRowConstraints([("switch", 2.5), ("menu", 2), ("filter", 5), ("amp", 5)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("name", 1), ("toneMenu", 1), ("structure", 1), ("switch", 1), ("wave", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["eq", "chorus", "lfo"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["name", "eq"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["lfo", "pitch"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["switch", "menu"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["menu", "wave"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["wave", "filter", "amp"], attribute: .bottom)
      
      let toneKeys = D50ToneCommonPatch.paramKeys().map { [.common] + $0 }
      let p1Keys = D50TonePartialPatch.paramKeys().map { [.partial, .i(0)] + $0 }
      let p2Keys = D50TonePartialPatch.paramKeys().map { [.partial, .i(1)] + $0 }
      let bundlePaths = toneKeys + p1Keys + p2Keys
      registerForEditMenu(button, bundle: (
        paths: { bundlePaths },
        pasteboardType: "com.cfshpd.D50ToneAndPartials",
        initialize: nil,
        randomize: defaultRandomizeBlock()
      ))
      
      addColor(panels: ["pitch", "eq", "chorus", "lfo", "structure", "name"], level: 2)
      addColor(panels: ["toneMenu"], level: 2, clearBackground: true)
      addColor(panels: ["wave", "filter", "amp"], level: 3)
      addColor(panels: ["switch", "menu"], level: 3, clearBackground: true)
    }
    
    @IBAction func selectPartial(_ sender: PBSegmentedControl) {
      partialControllers.forEach { $0.index = sender.selectedSegmentIndex }
    }
    

    class MyPitchController : PitchController {
      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (env, nil),
          (PBKnob(label: "Velo→Pitch"), [.env, .velo]),
          (PBKnob(label: "LFO1→Pitch"), [.lfo]),
          (PBKnob(label: "After→Vib"), [.aftertouch]),
          (PBKnob(label: "Lever→Vib"), [.bend]),
          ], [
          (PBKnob(label: "Key > Env T"), [.env, .time, .keyTrk]),
          (PBKnob(label: "T1"), [.env, .time, .i(0)]),
          (PBKnob(label: "T2"), [.env, .time, .i(1)]),
          (PBKnob(label: "T3"), [.env, .time, .i(2)]),
          (PBKnob(label: "T4"), [.env, .time, .i(3)]),
          ], [
          (PBKnob(label: "L0"), [.env, .level, .i(-1)]),
          (PBKnob(label: "L1"), [.env, .level, .i(0)]),
          (PBKnob(label: "L2"), [.env, .level, .i(1)]),
          (PBKnob(label: "Sus L"), [.env, .level, .i(2)]),
          (PBKnob(label: "End L"), [.env, .level, .i(3)]),
          ]])
      }
    }
    
    class MyMenuController : PartialController {
      override func loadView(_ view: PBView) {
        let menuButton = createButton(titled: "Partial")
        grid(view: view, items: [[(menuButton, nil)]])
        
        let paths = D50TonePartialPatch.paramKeys()
        registerForEditMenu(menuButton, bundle: (
          paths: { paths },
          pasteboardType: "com.cfshpd.D50Partial",
          initialize: nil,
          randomize: patchRandomizeBlock(D50TonePartialPatch.self)
        ))
      }
    }
                
    class MyWaveController : WaveController {
      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (wave, [.wave]),
          (pcmDropdown, [.pcm, .wave]),
          (PBSwitch(label: "Pitch Env"), [.pitch, .env, .mode]),
          ],[
          (PBKnob(label: "Pitch"), [.coarse]),
          (PBKnob(label: "Fine"), [.fine]),
          (PBKnob(label: "Keyfollow"), [.pitch, .keyTrk]),
          (PBSwitch(label: "Bend"), [.bend, .mode]),
          ],[
          (pw, [.pw]),
          (veloPw, [.pw, .velo]),
          (PBSwitch(label: "LFO1→Pitch"), [.pitch, .lfo, .mode]),
          ],[
          (lfoPw, [.pw, .lfo]),
          (lfoAmt, [.pw, .lfo, .depth]),
          (afterPw, [.pw, .aftertouch]),
          ]])
      }
    }
    
    class MyFilterController : FilterController {
      override func loadView(_ view: PBView) {
        env.label = "Filter"
        grid(view: view, items: [[
          (PBKnob(label: "Cutoff"), [.cutoff]),
          (PBKnob(label: "Reson"), [.reson]),
          (PBKnob(label: "Keyfollow"), [.keyTrk]),
          (PBKnob(label: "Bias Pt"), [.bias, .pt]),
          (PBKnob(label: "Bias Level"), [.bias, .level]),
          ],[
          (env, nil),
          (PBKnob(label: "Env Amt"), [.env, .depth]),
          (PBKnob(label: "Velocity"), [.env, .velo]),
          (PBKnob(label: "After→Cutoff"), [.aftertouch]),
          ],[
          (PBKnob(label: "T1"), [.env, .time, .i(0)]),
          (PBKnob(label: "T2"), [.env, .time, .i(1)]),
          (PBKnob(label: "T3"), [.env, .time, .i(2)]),
          (PBKnob(label: "T4"), [.env, .time, .i(3)]),
          (PBKnob(label: "T5"), [.env, .time, .i(4)]),
          ],[
          (PBKnob(label: "L1"), [.env, .level, .i(0)]),
          (PBKnob(label: "L2"), [.env, .level, .i(1)]),
          (PBKnob(label: "L3"), [.env, .level, .i(2)]),
          (PBKnob(label: "Sus L"), [.env, .level, .i(3)]),
          (PBKnob(label: "End L"), [.env, .level, .i(4)]),
          ],[
          (PBKnob(label: "Key→Env D"), [.env, .depth, .keyTrk]),
          (PBKnob(label: "Key→Env T"), [.env, .time, .keyTrk]),
          (PBSelect(label: "LFO→Cutoff"), [.lfo]),
          (PBKnob(label: "LFO Depth"), [.lfo, .depth]),
          ]])
      }
    }
    
    class MyAmpController : AmpController {
      override func loadView(_ view: PBView) {
        env.label = "Amp"
        grid(view: view, items: [[
          (PBKnob(label: "Level"), [.level]),
          (PBKnob(label: "Velo"), [.velo]),
          (PBKnob(label: "Bias Pt"), [.bias, .pt]),
          (PBKnob(label: "Bias Level"), [.bias, .level]),
          ],[
          (env, nil),
          (PBKnob(label: "After→Level"), [.aftertouch]),
          ],[
          (PBKnob(label: "T1"), [.env, .time, .i(0)]),
          (PBKnob(label: "T2"), [.env, .time, .i(1)]),
          (PBKnob(label: "T3"), [.env, .time, .i(2)]),
          (PBKnob(label: "T4"), [.env, .time, .i(3)]),
          (PBKnob(label: "T5"), [.env, .time, .i(4)]),
          ],[
          (PBKnob(label: "L1"), [.env, .level, .i(0)]),
          (PBKnob(label: "L2"), [.env, .level, .i(1)]),
          (PBKnob(label: "L3"), [.env, .level, .i(2)]),
          (PBKnob(label: "Sus L"), [.env, .level, .i(3)]),
          (PBKnob(label: "End L"), [.env, .level, .i(4)]),
          ],[
          (PBKnob(label: "Key→Velo"), [.env, .velo, .keyTrk]),
          (PBKnob(label: "Key→Time"), [.env, .time, .keyTrk]),
          (PBSelect(label: "LFO→Level"), [.lfo]),
          (PBKnob(label: "LFO Depth"), [.lfo, .depth]),
          ]])
      }
    }
  }
  
  
  // MARK: Reusable Controller Classes

  class ToneController : NewPatchEditorController {

    override var prefix: SynthPath? { return index == 0 ? [.hi] : [.lo] }
    override var namePath: SynthPath? { return [.common] }

    fileprivate let toneLabel = createLabel()
    fileprivate var partialControllers = [PartialController]()

    fileprivate let labeledNameField = LabeledTextField(label: "Tone Name")

    override var index: Int {
      didSet {
        let hiLo = index == 0 ? "Upper" : "Lower"
        toneLabel.text = "\(hiLo) Tone"
        partialControllers.forEach { $0.isUpper = index == 0 }
        labeledNameField.label.text = "\(hiLo) Tone Name"
      }
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()

      nameTextField = labeledNameField.textField

      addPatchChangeBlock(path: [.common, .structure]) { [weak self] (value) in
        self?.partialControllers.forEach { $0.structure = value }
      }
      
      addPatchChangeBlock { [weak self] (changes) in
        guard let mode = Self.updatedValueForFullPath([.common, .key, .mode], state: changes) else { return }
        let lowerAlpha: CGFloat = (self?.index == 1 && [0, 4].contains(mode)) ? 0.4 : 1
        self?.view.alpha = lowerAlpha
      }

      addBorder(view: view, level: 2)
    }

  }
  
  class PartialController : NewPatchEditorController {

    override var prefix: SynthPath? { return defaultPrefix }
    var defaultPrefix: SynthPath { return [.partial, .i(index)] }

    override var index: Int {
      didSet {
        updateButton()
        updateIsSynth()
      }
    }

    fileprivate var menuButton = createButton(titled: "? P?")
    
    var isUpper = true {
      didSet { updateButton() }
    }
    
    fileprivate func updateButton() {
      let hilo = isUpper ? "Upper" : "Lower"
      menuButton.title = "\(hilo) P\(index + 1)"
    }
    
    var structure = 0 {
      didSet { updateIsSynth() }
    }

    private func updateIsSynth() {
      updateIsSynth(D50ToneCommonPatch.isSynth(structure: structure, partial: index))
    }
    
    fileprivate func updateIsSynth(_ isSynth: Bool) { }

    func addOnBlock() {
      addPatchChangeBlock { [weak self] (state) in
        guard let hiLo = state.prefix?.first,
              let partial = state.prefix?.i(2),
              let on = Self.updatedValueForFullPath([hiLo, .common, .partial, .i(partial), .on], state: state) else { return }
        self?.view.alpha = on == 0 ? 0.4 : 1
      }
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      addBorder(view: view, level: 3)
    }

  }
  
  class TwoToneController<T:ToneController> : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      let _: [T] = addChildren(count: 2, panelPrefix: "t")
      addPanelsToLayout(andView: view)
      layout.addGridConstraints([[("t0", 1), ("t1", 1)]], pinMargin: "", spacing: "-s1-")
    }
  }
    
  class OneLineLFOController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.common, .lfo, .i(index)] }

    override func loadView(_ view: PBView) {
      let labeledSwitchCtrl = LabeledSegmentedControl(label: "LFO", items: ["1","2","3"])
      switchCtrl = labeledSwitchCtrl.segmentedControl
      
      grid(view: view, items: [[
        (labeledSwitchCtrl, nil),
        (PBSwitch(label: "Wave"), [.wave]),
        (PBKnob(label: "Rate"), [.rate]),
        (PBKnob(label: "Delay"), [.delay]),
        (PBSwitch(label: "Sync"), [.sync]),
        ]])
    }
  }
  
  class EnvController : PartialController {

    fileprivate let env: PBRateLevelEnvelopeControl = {
      let env = PBRateLevelEnvelopeControl()
      env.pointCount = 5
      env.sustainPoint = 3
      return env
    }()
              
    override func viewDidLoad() {
      super.viewDidLoad()
      
      let env = self.env
      (0..<5).forEach { step in
        addPatchChangeBlock(path: [.env, .time, .i(step)]) {
          env.set(rate: CGFloat($0) / 100, forIndex: step)
        }
        addPatchChangeBlock(path: [.env, .level, .i(step)]) {
          env.set(level: step == 4 ? CGFloat($0) : CGFloat($0) / 100, forIndex: step)
        }
      }
      
      let paths: [SynthPath] = (0..<5).map { [.env, .time, .i($0)] } + (0..<5).map { [.env, .level, .i($0)] }
      registerForEditMenu(env, bundle: (
        paths: { paths },
        pasteboardType: "com.cfshpd.D50Envelope",
        initialize: nil,
        randomize: nil
      ))
    }
  }
  
  
  // MARK: Pitch Waves

  class PitchWaveController : ToneController {
        
    private let pitchController = PitchController()
    
    override func loadView(_ view: PBView) {
      addChild(PitchController(), withPanel: "pitch")
      addChild(LFOController(), withPanel: "lfo")
      partialControllers.append(contentsOf: addChildren(count: 2, panelPrefix: "wave") as [WaveController])
      
      toneLabel.textAlignment = .center
      grid(panel: "label", items: [[(toneLabel, nil)]])
      
      grid(panel: "mod", prefix: [.common, .pitch], items: [[
        (PBKnob(label: "Velo→Pitch"), [.env, .velo]),
        (PBKnob(label: "LFO1→Pitch"), [.lfo]),
        ],[
        (PBKnob(label: "After→Vib"), [.aftertouch]),
        (PBKnob(label: "Lever→Vib"), [.bend]),
        ]])
      
      let structDropdown = PBImageSelect(label: "Structure", imageSize: CGSize(width: 200, height: 70), imageSpacing: 12)
      grid(panel: "structure", items: [[(structDropdown, [.common, .structure])]])
      
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("label", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("pitch", 4), ("mod", 2), ("lfo", 2)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("wave0", 1), ("wave1", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("label", 0.33), ("pitch", 3), ("wave0", 5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("mod", 2), ("structure", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["pitch", "structure", "lfo"], attribute: .bottom)

      // prime the wavecontroller labels
      index += 0
      
      addColor(panels: ["label"], level: 2, clearBackground: true)
      addColor(panels: ["pitch", "structure", "lfo", "mod"], level: 2)
      addColor(panels: ["wave0", "wave1"], level: 3)

    }
    
    
    class LFOController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.common, .lfo, .i(index)] }

      override func loadView(_ view: PBView) {
        let labeledSwitchCtrl = LabeledSegmentedControl(label: "LFO", items: ["1","2","3"])
        switchCtrl = labeledSwitchCtrl.segmentedControl
        
        grid(view: view, items: [[
          (labeledSwitchCtrl, nil),
          ],[
          (PBSwitch(label: "Wave"), [.wave]),
          (PBKnob(label: "Rate"), [.rate]),
          ],[
          (PBKnob(label: "Delay"), [.delay]),
          (PBSwitch(label: "Sync"), [.sync]),
          ]])
      }
    }
  }
  
  class PitchController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.common, .pitch] }
    
    fileprivate let env = PBRateLevelEnvelopeControl(label: "Pitch")

    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBKnob(label: "L0"), [.env, .level, .i(-1)]),
        (env, nil),
        (PBKnob(label: "Key > Env T"), [.env, .time, .keyTrk]),
        ], [
        (PBKnob(label: "T1"), [.env, .time, .i(0)]),
        (PBKnob(label: "T2"), [.env, .time, .i(1)]),
        (PBKnob(label: "T3"), [.env, .time, .i(2)]),
        (PBKnob(label: "T4"), [.env, .time, .i(3)]),
        ], [
        (PBKnob(label: "L1"), [.env, .level, .i(0)]),
        (PBKnob(label: "L2"), [.env, .level, .i(1)]),
        (PBKnob(label: "Sus L"), [.env, .level, .i(2)]),
        (PBKnob(label: "End L"), [.env, .level, .i(3)]),
        ]])
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      let env = self.env
      env.bipolar = true
      (0..<4).forEach { step in
        addPatchChangeBlock(path: [.env, .time, .i(step)]) {
          env.set(rate: CGFloat($0) / 50, forIndex: step)
        }
        addPatchChangeBlock(path: [.env, .level, .i(step)]) {
          env.set(level: CGFloat($0 - 50) / 50, forIndex: step)
        }
      }
      addPatchChangeBlock(path: [.env, .level, .i(-1)]) {
        env.startLevel = CGFloat($0 - 50) / 50
      }

      registerForEditMenu(env, bundle: (
        paths: {[[.env, .time, .i(0)],
                [.env, .time, .i(1)],
                [.env, .time, .i(2)],
                [.env, .time, .i(3)],
                [.env, .level, .i(-1)],
                [.env, .level, .i(0)],
                [.env, .level, .i(1)],
                [.env, .level, .i(2)],
                [.env, .level, .i(3)],
        ]},
        pasteboardType: "com.cfshpd.D50PitchEnv",
        initialize: nil,
        randomize: nil
      ))
    }
  }
  
  class WaveController : PartialController {
    
    fileprivate var synthControls = [PBView]()
    fileprivate let pcmDropdown = PBSelect(label: "PCM")
    fileprivate let wave = PBSwitch(label: "Wave")
    fileprivate let pw = PBKnob(label: "PW")
    fileprivate let veloPw = PBKnob(label: "Velo→PW")
    fileprivate let lfoPw = PBSelect(label: "LFO→PW")
    fileprivate let lfoAmt = PBKnob(label: "LFO Amt")
    fileprivate let afterPw = PBKnob(label: "After→PW")

    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (wave, [.wave]),
        (pcmDropdown, [.pcm, .wave]),
        (PBSwitch(label: "Pitch Env"), [.pitch, .env, .mode]),
        ],[
        (PBKnob(label: "Pitch"), [.coarse]),
        (PBKnob(label: "Fine"), [.fine]),
        (PBKnob(label: "Keyfollow"), [.pitch, .keyTrk]),
        (PBSwitch(label: "Bend"), [.bend, .mode]),
        ],[
        (pw, [.pw]),
        (veloPw, [.pw, .velo]),
        (PBSwitch(label: "LFO1→Pitch"), [.pitch, .lfo, .mode]),
        ],[
        (lfoPw, [.pw, .lfo]),
        (lfoAmt, [.pw, .lfo, .depth]),
        (afterPw, [.pw, .aftertouch]),
        ],[
        (menuButton, nil),
        ]])
      
      registerForEditMenu(menuButton, bundle: (
        paths: {[[.wave],
                [.pcm, .wave],
                [.pitch, .env, .mode],
                [.coarse],
                [.fine],
                [.pitch, .keyTrk],
                [.bend, .mode],
                [.pw],
                [.pw, .velo],
                [.pitch, .lfo, .mode],
                [.pw, .lfo],
                [.pw, .lfo, .depth],
                [.pw, .aftertouch],
        ]},
        pasteboardType: "com.cfshpd.D50PartialWave",
        initialize: nil,
        randomize: defaultRandomizeBlock()
      ))
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      synthControls = [wave, pw, veloPw, lfoPw, lfoAmt, afterPw]
      addOnBlock()
    }
        
    override func updateIsSynth(_ isSynth: Bool) {
      synthControls.forEach { $0.alpha = isSynth ? 1 : 0.2 }
      pcmDropdown.alpha = isSynth ? 0.2 : 1
    }
    
  }
  
  
  class ToneFilterController : ToneController {

    override func loadView(_ view: PBView) {
      addChild(OneLineLFOController(), withPanel: "lfo")
      partialControllers.append(contentsOf: addChildren(count: 2, panelPrefix: "filter") as [FilterController])
      
      toneLabel.textAlignment = .center
      grid(panel: "label", items: [[(toneLabel, nil)]])

      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("label", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("lfo", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("filter0", 1), ("filter1", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("label", 0.33), ("lfo", 1), ("filter0", 7)], pinned: true, pinMargin: "", spacing: "-s1-")

      // prime the filtercontroller labels
      index += 0
      
      addColor(panels: ["label"], level: 2, clearBackground: true)
      addColor(panels: ["lfo"], level: 2)
      addColor(panels: ["filter0", "filter1"], level: 3)
    }

  }
  
  class FilterController : EnvController {

    override var prefix: SynthPath? { return  defaultPrefix + [.filter] }

    override func loadView(_ view: PBView) {
      env.label = "Filter"
      grid(view: view, items: [[
        (PBKnob(label: "Cutoff"), [.cutoff]),
        (PBKnob(label: "Reson"), [.reson]),
        (PBKnob(label: "Keyfollow"), [.keyTrk]),
        (PBKnob(label: "After→Cutoff"), [.aftertouch]),
        ],[
        (env, nil),
        (PBKnob(label: "Env Amt"), [.env, .depth]),
        (PBKnob(label: "Velocity"), [.env, .velo]),
        ],[
        (PBKnob(label: "T1"), [.env, .time, .i(0)]),
        (PBKnob(label: "T2"), [.env, .time, .i(1)]),
        (PBKnob(label: "T3"), [.env, .time, .i(2)]),
        (PBKnob(label: "T4"), [.env, .time, .i(3)]),
        (PBKnob(label: "T5"), [.env, .time, .i(4)]),
        ],[
        (PBKnob(label: "L1"), [.env, .level, .i(0)]),
        (PBKnob(label: "L2"), [.env, .level, .i(1)]),
        (PBKnob(label: "L3"), [.env, .level, .i(2)]),
        (PBKnob(label: "Sus L"), [.env, .level, .i(3)]),
        (PBKnob(label: "End L"), [.env, .level, .i(4)]),
        ],[
        (PBKnob(label: "Key→Env D"), [.env, .depth, .keyTrk]),
        (PBKnob(label: "Key→Env T"), [.env, .time, .keyTrk]),
        (PBKnob(label: "Bias Pt"), [.bias, .pt]),
        (PBKnob(label: "Bias Level"), [.bias, .level]),
        ],[
        (PBSelect(label: "LFO→Cutoff"), [.lfo]),
        (PBKnob(label: "LFO Depth"), [.lfo, .depth]),
        ],[
        (menuButton, nil),
        ]])
      
      registerForEditMenu(menuButton, bundle: (
        paths: {[[.cutoff],
                [.reson],
                [.keyTrk],
                [.aftertouch],
                [.env, .depth],
                [.env, .velo],
                [.env, .time, .i(0)],
                [.env, .time, .i(1)],
                [.env, .time, .i(2)],
                [.env, .time, .i(3)],
                [.env, .time, .i(4)],
                [.env, .level, .i(0)],
                [.env, .level, .i(1)],
                [.env, .level, .i(2)],
                [.env, .level, .i(3)],
                [.env, .level, .i(4)],
                [.env, .depth, .keyTrk],
                [.env, .time, .keyTrk],
                [.bias, .pt],
                [.bias, .level],
                [.lfo],
                [.lfo, .depth],
        ]},
        pasteboardType: "com.cfshpd.D50PartialFilter",
        initialize: nil,
        randomize: defaultRandomizeBlock()
      ))
    }
        
    override func viewDidLoad() {
      super.viewDidLoad()
      addPatchChangeBlock { [weak self] (state) in
        guard let hiLo = state.prefix?.first,
              let partial = state.prefix?.i(2) else { return }
        let onPath = [hiLo, .common, .partial, .i(partial), .on]
        let structurePath = [hiLo, .common, .structure]
        guard let values = self?.updatedValuesForFullPaths(fullPaths: [onPath, structurePath], changes: state),
              let on = values[onPath],
              let structure = values[structurePath] else { return }
        let isSynth = D50ToneCommonPatch.isSynth(structure: structure, partial: partial)
        self?.view.alpha = on == 0 || !isSynth ? 0.4 : 1
      }
    }

  }

  
  class ToneAmpController : ToneController {

    override func loadView(_ view: PBView) {
      addChild(OneLineLFOController(), withPanel: "lfo")
      partialControllers.append(contentsOf: addChildren(count: 2, panelPrefix: "amp") as [AmpController])
      
      toneLabel.textAlignment = .center
      grid(panel: "label", items: [[(toneLabel, nil)]])

      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("label", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("lfo", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("amp0", 1), ("amp1", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("label", 0.33), ("lfo", 1), ("amp0", 7)], pinned: true, pinMargin: "", spacing: "-s1-")

      // prime the filtercontroller labels
      index += 0
      
      addColor(panels: ["label"], level: 2, clearBackground: true)
      addColor(panels: ["lfo"], level: 2)
      addColor(panels: ["amp0", "amp1"], level: 3)

    }

  }
  
  class AmpController : EnvController {

    override var prefix: SynthPath? { return defaultPrefix + [.amp] }

    override func loadView(_ view: PBView) {
      env.label = "Amp"
      grid(view: view, items: [[
        (PBKnob(label: "Level"), [.level]),
        (PBKnob(label: "Velo"), [.velo]),
        (PBKnob(label: "Bias Pt"), [.bias, .pt]),
        (PBKnob(label: "Bias Level"), [.bias, .level]),
        ],[
        (env, nil),
        (PBKnob(label: "After→Level"), [.aftertouch]),
        ],[
        (PBKnob(label: "T1"), [.env, .time, .i(0)]),
        (PBKnob(label: "T2"), [.env, .time, .i(1)]),
        (PBKnob(label: "T3"), [.env, .time, .i(2)]),
        (PBKnob(label: "T4"), [.env, .time, .i(3)]),
        (PBKnob(label: "T5"), [.env, .time, .i(4)]),
        ],[
        (PBKnob(label: "L1"), [.env, .level, .i(0)]),
        (PBKnob(label: "L2"), [.env, .level, .i(1)]),
        (PBKnob(label: "L3"), [.env, .level, .i(2)]),
        (PBKnob(label: "Sus L"), [.env, .level, .i(3)]),
        (PBKnob(label: "End L"), [.env, .level, .i(4)]),
        ],[
        (PBKnob(label: "Key→Velo"), [.env, .velo, .keyTrk]),
        (PBKnob(label: "Key→Time"), [.env, .time, .keyTrk]),
        ],[
        (PBSelect(label: "LFO→Level"), [.lfo]),
        (PBKnob(label: "LFO Depth"), [.lfo, .depth]),
        ],[
        (menuButton, nil),
        ]])
      
      registerForEditMenu(menuButton, bundle: (
        paths: {[[.level],
                [.velo],
                [.bias, .pt],
                [.bias, .level],
                [.lfo],
                [.lfo, .depth],
                [.env, .velo, .keyTrk],
                [.env, .time, .keyTrk],
                [.aftertouch],
                [.env, .time, .i(0)],
                [.env, .time, .i(1)],
                [.env, .time, .i(2)],
                [.env, .time, .i(3)],
                [.env, .time, .i(4)],
                [.env, .level, .i(0)],
                [.env, .level, .i(1)],
                [.env, .level, .i(2)],
                [.env, .level, .i(3)],
                [.env, .level, .i(4)],
        ]},
        pasteboardType: "com.cfshpd.D50PartialAmp",
        initialize: nil,
        randomize: defaultRandomizeBlock()
      ))
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      addOnBlock()
    }
    
  }
}
