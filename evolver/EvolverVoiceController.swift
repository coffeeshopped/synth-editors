
class EvolverVoiceController : NewPagedEditorController {
  
  init() {
    super.init(nibName: nil, bundle: nil)
    initMainController()
  }
  
  func initMainController() {
    mainController = MainController(keyModeControllerType: MainController.KeyModeController.self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var mainController: MainController!
  private let modsController = ModsController()
  private let seqController = SeqController()
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch","level"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch", 8), ("level", 8)
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",8),
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Voice","Mods","Seq"])
    quickGrid(panel: "switch", items: [[(switchCtrl, nil, "switchCtrl")]])
    
    quickGrid(panel: "level", items: [[
      (PBKnob(label: "Volume"), [.amp, .volume], nil),
      (PBKnob(label: "Cutoff"), [.filter, .cutoff], nil),
      (PBKnob(label: "Reson"), [.filter, .reson], nil),
      (PBCheckbox(label: "4-Pole"), [.filter, .fourPole], nil),
      (PBKnob(label: "Tempo"), [.tempo], nil),
      (PBSelect(label: "Clock Div"), [.clock, .divide], nil),
      ]])

    addColor(panels: ["level"])
    addColor(panels: ["switch"], clearBackground: true)

  }
  
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return mainController
    case 1:
      return modsController
    default:
      return seqController
    }
  }
  
  
  
  class MainController : NewPatchEditorController {
    
    init(keyModeControllerType: NewPatchEditorController.Type) {
      self.keyModeControllerType = keyModeControllerType
      super.init(nibName: nil, bundle: nil)
    }
    
    private let keyModeControllerType: NewPatchEditorController.Type
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView(_ view: PBView) {
      addChild(OscillatorsController(), withPanel: "oscs")
      addChild(FilterController(), withPanel: "filter")
      addChild(AmpController(), withPanel: "amp")
      addChild(Env2Controller(), withPanel: "env2")
      addChild(HiPassController(), withPanel: "hipass")
      addChild(DistortionController(), withPanel: "dist")
      addChild(DelaysController(), withPanel: "delays")
      addChild(LFOsController(), withPanel: "lfos")
      addChild(ModsController(), withPanel: "mods")
      addChild(keyModeControllerType.init(), withPanel: "transpose")

      createPanels(forKeys: ["pan", "ext", "feedbk", "tempo", "trig", "envMode", "env2Amt"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("oscs", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("filter", 7), ("hipass", 2), ("amp", 5), ("ext", 3)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("delays", 7), ("transpose", 3), ("tempo", 2.5), ("env2", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("trig", 1.5), ("dist", 3), ("envMode", 1)], options: [.alignAllTop], pinned: false, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("lfos", 9), ("mods", 4), ("env2Amt", 1.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      layout.addColumnConstraints([("oscs", 2), ("filter", 2), ("delays", 2), ("lfos", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("hipass", 1), ("pan", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      layout.addColumnConstraints([("ext", 1), ("feedbk", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      layout.addColumnConstraints([("transpose", 1), ("trig", 1)], pinned: false, spacing: "-s1-")
      
      layout.addEqualConstraints(forItemKeys: ["filter", "pan", "amp", "feedbk"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["transpose", "tempo"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["delays", "trig", "dist", "envMode", "env2"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["tempo", "envMode"], attribute: .trailing)

      quickGrid(panel: "pan", items: [[
        (PBSelect(label: "Pan"), [.pan], nil),
        ]])

      quickGrid(panel: "ext", items: [[
        (PBKnob(label: "Ext Vol"), [.extAudio], nil),
        (PBSwitch(label: "Ext Mode"), [.extAudio, .volume], nil),
        (PBKnob(label: "In Hack"), [.extAudio, .hack], nil),
        ]])

      quickGrid(panel: "feedbk", items: [[
        (PBKnob(label: "Feed Freq"), [.feedback, .freq], nil),
        (PBKnob(label: "Level"), [.feedback, .amt], nil),
        (PBCheckbox(label: "Grunge"), [.grunge], nil),
        ]])

      quickGrid(panel: "tempo", items: [[
        (PBKnob(label: "Tempo"), [.tempo], nil),
        (PBSelect(label: "Clock Div"), [.clock, .divide], nil),
        ]])

      quickGrid(panel: "trig", items: [[
        (PBSelect(label: "Trig Select"), [.trigger], nil),
        ]])

      quickGrid(panel: "envMode", items: [[
        (PBSwitch(label: "Env Mode"), [.env, .mode], nil),
        ]])

      quickGrid(panel: "env2Amt", items: [[
        (PBKnob(label: "Env 3 Amt"), [.env, .i(2), .amt], nil),
        ],[
        (PBSelect(label: "Env 3 Dest"), [.env, .i(2), .dest], nil),
        ]])

      addPatchChangeBlock(path: [.env, .i(2), .dest]) { [weak self] in
        self?.panels["env2Amt"]?.alpha = $0 == 0 ? 0.5 : 1
      }
      
      addColor(panels: ["pan", "ext", "feedbk", "tempo", "trig", "envMode", "hipass", "dist", "transpose", "env2"])
      addColor(panels: ["filter", "amp", "env2Amt"], level: 3)

    }
    
    
    class OscillatorsController : NewPatchEditorController {
      
      override func loadView(_ view: PBView) {

        addChild(Osc0Controller(), withPanel: "osc0")
        addChild(Osc1Controller(), withPanel: "osc1")
        createPanels(forKeys: ["osc2", "osc3", "bend", "slop"])
        addPanelsToLayout(andView: view)

        layout.addRowConstraints([("osc0", 7), ("bend", 1), ("osc1", 6), ("slop", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addRowConstraints([("osc2", 8), ("osc3", 8)], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([("osc0", 1), ("osc2", 1)], pinned: true, pinMargin: "", spacing: "-s1-")

        quickGrid(panel: "bend", items: [[
          (PBKnob(label: "Bend"), [.bend], nil),
          ]])

        quickGrid(panel: "slop", items: [[
          (PBKnob(label: "Slop"), [.slop], nil),
          (PBKnob(label: "Noise"), [.noise], nil),
          ]])

        quickGrid(panel: "osc2", items: [[
          (PBKnob(label: "O3 Shape"), [.osc, .i(2), .shape], nil),
          (PBSwitch(label: "Shape Seq"), [.osc, .i(2), .shape, .mod], nil),
          (PBKnob(label: "Freq"), [.osc, .i(2), .semitone], nil),
          (PBKnob(label: "Fine"), [.osc, .i(2), .detune], nil),
          (PBKnob(label: "Glide"), [.osc, .i(2), .glide], nil),
          (PBKnob(label: "Level"), [.osc, .i(2), .level], nil),
          (PBKnob(label: "FM 4>3"), [.osc, .i(2), .fm], nil),
          (PBKnob(label: "Ring 4>3"), [.osc, .i(2), .ringMod], nil),
          ]])

        quickGrid(panel: "osc3", items: [[
          (PBKnob(label: "O4 Shape"), [.osc, .i(3), .shape], nil),
          (PBSwitch(label: "Shape Seq"), [.osc, .i(3), .shape, .mod], nil),
          (PBKnob(label: "Freq"), [.osc, .i(3), .semitone], nil),
          (PBKnob(label: "Fine"), [.osc, .i(3), .detune], nil),
          (PBKnob(label: "Glide"), [.osc, .i(3), .glide], nil),
          (PBKnob(label: "Level"), [.osc, .i(3), .level], nil),
          (PBKnob(label: "FM 3>4"), [.osc, .i(3), .fm], nil),
          (PBKnob(label: "Ring 3>4"), [.osc, .i(3), .ringMod], nil),
          ]])
        
        addColorToAll()
        addBorder(view: view)
      }
    }
    
    class OscController : NewPatchEditorController {
      
      override var prefix: SynthPath? { return [.osc, .i(index)] }
      
      override var index: Int {
        didSet { wave.label = "O\(index + 1) Shape" }
      }
      
      fileprivate let wave = PBSwitch(label: "Osc")
      fileprivate let pw = PBKnob(label: "PW")
      
      override func viewDidLoad() {
        super.viewDidLoad()
        
        let wave = self.wave
        let pw = self.pw
        wave.options = EvolverVoicePatch.waveOptions
        pw.displayOffset = -3
        pw.minimumValue = 3

        addPatchChangeBlock(path: [.shape]) {
          wave.value = min($0, 3)
          pw.value = $0
          pw.isHidden = ($0 < 3)
        }
        addDefaultControlChangeBlock(control: wave, path: [.shape])
        addDefaultControlChangeBlock(control: pw, path: [.shape])
      }
    }
    
    class Osc0Controller : OscController {
      override func loadView(_ view: PBView) {
        quickGrid(view: view, items: [[
          (wave, nil, "oscWave"),
          (pw, nil, "pw"),
          (PBKnob(label: "Freq"), [.semitone], nil),
          (PBKnob(label: "Fine"), [.detune], nil),
          (PBKnob(label: "Glide"), [.glide], nil),
          (PBKnob(label: "Level"), [.level], nil),
          (PBCheckbox(label: "Sync 2>1"), [.sync], nil),
          ]])
        index = 0
      }
    }

    class Osc1Controller : OscController {
      override func loadView(_ view: PBView) {
        quickGrid(view: view, items: [[
          (wave, nil, "oscWave"),
          (pw, nil, "pw"),
          (PBKnob(label: "Freq"), [.semitone], nil),
          (PBKnob(label: "Fine"), [.detune], nil),
          (PBKnob(label: "Glide"), [.glide], nil),
          (PBKnob(label: "Level"), [.level], nil),
          ]])
        index = 1
      }
    }
    
    class EnvController : NewPatchEditorController {
      fileprivate let env = PBDadsrEnvelopeControl(label: "Env")

      override func viewDidLoad() {
        super.viewDidLoad()
        let env = self.env
        addPatchChangeBlock(path: [.env, .attack]) { env.attack = CGFloat($0) / 110 }
        addPatchChangeBlock(path: [.env, .decay]) { env.decay = CGFloat($0) / 110 }
        addPatchChangeBlock(path: [.env, .sustain]) { env.sustain = CGFloat($0) / 100 }
        addPatchChangeBlock(path: [.env, .release]) { env.rrelease = CGFloat($0) / 110 }
        
        registerForEditMenu(env, bundle: (
          paths: {[
            [.env, .attack],
            [.env, .decay],
            [.env, .sustain],
            [.env, .release],
          ]},
          pasteboardType: "com.cfshpd.EvolverEnv",
          initialize: nil,
          randomize: nil
        ))
      }
    }
    
    class FilterController : EnvController {
     
      override var prefix: SynthPath? { return [.filter] }
      
      override func loadView(_ view: PBView) {
        env.label = "Filter (Env 1)"

        quickGrid(view: view, items: [[
          (env, nil, "env"),
          (PBKnob(label: "Env Amt"), [.env, .amt], nil),
          (PBKnob(label: "Velo"), [.env, .velo], nil),
          (PBKnob(label: "Cutoff"), [.cutoff], nil),
          (PBKnob(label: "Reson"), [.reson], nil),
          (PBKnob(label: "Audio Mod"), [.mod], nil),
          ],[
          (PBKnob(label: "Attack"), [.env, .attack], nil),
          (PBKnob(label: "Decay"), [.env, .decay], nil),
          (PBKnob(label: "Sustain"), [.env, .sustain], nil),
          (PBKnob(label: "Release"), [.env, .release], nil),
          (PBKnob(label: "Key Amt"), [.keyTrk], nil),
          (PBCheckbox(label: "4-Pole"), [.fourPole], nil),
          (PBKnob(label: "Split"), [.split], nil),
          ]])
      }
    }
    
    class AmpController : EnvController {
      
      override var prefix: SynthPath? { return [.amp] }
      
      override func loadView(_ view: PBView) {
        env.label = "Amp (Env 2)"

        quickGrid(view: view, items: [[
          (env, nil, "env"),
          (PBKnob(label: "Env Amt"), [.env, .amt], nil),
          (PBKnob(label: "Velo"), [.env, .velo], nil),
          (PBKnob(label: "Level"), [.level], nil),
          ],[
          (PBKnob(label: "Attack"), [.env, .attack], nil),
          (PBKnob(label: "Decay"), [.env, .decay], nil),
          (PBKnob(label: "Sustain"), [.env, .sustain], nil),
          (PBKnob(label: "Release"), [.env, .release], nil),
          (PBKnob(label: "Volume"), [.volume], nil),
          ]])
      }
    }
    
    class Env2Controller : EnvController {
      
      override var prefix: SynthPath? { return [.env, .i(2)] }
      
      override func loadView(_ view: PBView) {
        env.label = "Env 3"

        quickGrid(view: view, items: [[
          (env, nil, "env"),
          (PBKnob(label: "Delay"), [.delay], nil),
          (PBKnob(label: "Velo"), [.velo], nil),
          ],[
          (PBKnob(label: "Attack"), [.env, .attack], nil),
          (PBKnob(label: "Decay"), [.env, .decay], nil),
          (PBKnob(label: "Sustain"), [.env, .sustain], nil),
          (PBKnob(label: "Release"), [.env, .release], nil),
          ]])
      }
    }
    
    class HiPassController : NewPatchEditorController {
            
      override func loadView(_ view: PBView) {
        let freq = PBKnob(label: "Hi Pass")
        let mode = PBSwitch(label: "Mode")

        quickGrid(view: view, items: [[
          (freq, nil, "freq"),
          (mode, nil, "mode"),
          ]])
        
        freq.maximumValue = 99
        mode.options = [0 : "Post Lo", 1 : "Ext In"]
        addPatchChangeBlock(path: [.hi, .cutoff]) {
          freq.value = $0 % 100
          mode.value = $0 / 100
        }
        let ctrlBlock: (() -> Int) = { freq.value + (mode.value * 100) }
        addDefaultControlChangeBlock(control: freq, path: [.hi, .cutoff], valueBlock: ctrlBlock)
        addDefaultControlChangeBlock(control: mode, path: [.hi, .cutoff], valueBlock: ctrlBlock)
      }
    }

    
    class DistortionController : NewPatchEditorController {
            
      override func loadView(_ view: PBView) {
        let dist = PBKnob(label: "Distortion")
        let mode = PBSwitch(label: "Mode")

        quickGrid(view: view, items: [[
          (dist, nil, "dist"),
          (mode, nil, "mode"),
          (PBKnob(label: "Out Hack"), [.out, .hack], nil),
          ]])

        dist.maximumValue = 99
        mode.options = [0 : "Post Filter", 1 : "Ext In"]
        addPatchChangeBlock(path: [.dist]) {
          dist.value = $0 % 100
          mode.value = $0 / 100
        }
        let ctrlBlock: (() -> Int) = { dist.value + (mode.value * 100) }
        addDefaultControlChangeBlock(control: dist, path: [.dist], valueBlock: ctrlBlock)
        addDefaultControlChangeBlock(control: mode, path: [.dist], valueBlock: ctrlBlock)
      }
    }
    
    class KeyModeController : NewPatchEditorController {
      override func loadView(_ view: PBView) {
        quickGrid(view: view, items: [[
          (PBKnob(label: "Transpose"), [.transpose], nil),
          (PBSelect(label: "Key Mode"), [.key, .mode], nil),
          ]])
      }
    }
    
    
    class DelaysController : NewPatchEditorController {
      
      override func loadView(_ view: PBView) {
        let _: [DelayController] = addChildren(count: 3, panelPrefix: "delay")
        createPanels(forKeys: ["delayFeed"])
        addPanelsToLayout(andView: view)

        layout.addRowConstraints([("delay0", 2), ("delay1", 2), ("delay2", 2), ("delayFeed", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([("delay0", 1)], pinned: true, pinMargin: "", spacing: "-s1-")

        quickGrid(panel: "delayFeed", items: [[
          (PBKnob(label: "Delay > Delay"), [.delay, .feedback, .delay], nil),
          ],[
          (PBKnob(label: "Delay > Filt"), [.delay, .feedback, .filter], nil),
          ]])
        
        addColorToAll()
        addBorder(view: view)
      }
      
    }
    
    class DelayController : NewPatchEditorController {
      
      private let timeKnob = PBKnob(label: "Time")
      private let timeSelect = PBSelect(label: "Time")
      private let level = PBKnob(label: "Level")

      override var prefix: SynthPath? { return [.delay, .i(index)] }
      
      override var index: Int {
        didSet {
          timeKnob.label = "Time \(index + 1)"
          timeSelect.label = "Delay Time \(index + 1)"
          level.label = "Level \(index + 1)"
        }
      }
      
      override func loadView(_ view: PBView) {
        let timeKnob = self.timeKnob
        let timeSelect = self.timeSelect
        
        quickGrid(view: view, items: [[
          (timeKnob, nil, "timeKnob"),
          (level, [.level], nil),
          ],[
          (timeSelect, nil, "timeSel"),
          ]])

        timeSelect.options = EvolverVoicePatch.syncDelayOptions
        timeKnob.maximumValue = 150
        addPatchChangeBlock(path: [.time]) {
          timeSelect.value = ($0 < 151 ? 0 : $0 - 150)
          timeKnob.isHidden = $0 > 150
          timeKnob.value = $0
        }
        addDefaultControlChangeBlock(control: timeKnob, path: [.time])
        addDefaultControlChangeBlock(control: timeSelect, path: [.time]) {
          timeSelect.value == 0 ? 75 : timeSelect.value + 150
        }
      }
    }
    
    class LFOsController : NewPatchEditorController {
      
      private var lfos: [LFOController]!
      
      override var index: Int {
        didSet {
          lfos?.enumerated().forEach {
            $0.element.index = (2 * index) + $0.offset
          }
        }
      }
      
      override func loadView(_ view: PBView) {
        let segCtrl = LabeledSegmentedControl(label: "LFO", items: ["1/2", "3/4"])
        switchCtrl = segCtrl.segmentedControl
        lfos = addChildren(count: 2, panelPrefix: "lfo")
        createPanels(forKeys: ["switch"])
        addPanelsToLayout(andView: view)
        
        layout.addRowConstraints([("switch", 3), ("lfo0", 3.5), ("lfo1", 3.5)], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([("switch", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
        
        quickGrid(panel: "switch", items: [[
          (segCtrl, nil, "switchCtrl"),
          ],[
          (PBView(), nil, "spacer"),
          ]])
        
        index = 0

        addColorToAll(except: ["switch"], level: 2)
        addColor(panels: ["switch"], level: 2, clearBackground: true)
        addBorder(view: view, level: 2)

      }
      
    }
    
    class LFOController : NewPatchEditorController {
      
      private let wave = PBSwitch(label: "LFO")
      
      override var prefix: SynthPath? { return [.lfo, .i(index)] }

      override var index: Int {
        didSet { wave.label = "LFO \(index + 1)" }
      }

      override func loadView(_ view: PBView) {
        let freqKnob = PBKnob(label: "Freq")
        let freqSelect = PBSelect(label: "Freq")
        let sync = PBCheckbox(label: "Sync")
        let amt = PBKnob(label: "Amount")

        quickGrid(view: view, items: [[
          (freqSelect, nil, "freq"),
          (freqKnob, nil, "Freq2"),
          (amt, nil, "amt"),
          ],[
          (wave, [.shape], nil),
          (sync, nil, "sync"),
          (PBSelect(label: "Destination"), [.dest], nil),
          ]])
        
        freqSelect.options = EvolverVoicePatch.lfoFreqOptions
        freqKnob.maximumValue = 150
        amt.maximumValue = 100

        dims(view: view, forPath: [.dest])
        addPatchChangeBlock(path: [.freq]) {
          freqSelect.value = ($0 < 151 ? 0 : $0 - 150)
          freqKnob.isHidden = $0 > 150
          freqKnob.value = $0
        }
        addPatchChangeBlock(path: [.amt]) {
          amt.value = $0 == 100 ? 100 : $0 % 100
          sync.value = $0 == 0 ? 0 : ($0 - 1) / 100
          sync.isHidden = $0 == 0
        }
        addDefaultControlChangeBlock(control: freqKnob, path: [.freq])
        addDefaultControlChangeBlock(control: freqSelect, path: [.freq]) {
          freqSelect.value == 0 ? 75 : freqSelect.value + 150
        }
        let ctrlBlock: (() -> Int) = { amt.value == 0 ? 0 : amt.value + (sync.value * 100) }
        addDefaultControlChangeBlock(control: sync, path: [.amt], valueBlock: ctrlBlock)
        addDefaultControlChangeBlock(control: amt, path: [.amt], valueBlock: ctrlBlock)
      }
    }
    
    class ModsController : NewPatchEditorController {
      
      private let mod = ModController()
      
      override var index: Int {
        didSet { mod.index = index }
      }
      
      override func loadView(_ view: PBView) {
        let segCtrl = LabeledSegmentedControl(label: "Mod", items: ["1", "2", "3", "4"])
        switchCtrl = segCtrl.segmentedControl
        addChild(mod, withPanel: "mod")
        createPanels(forKeys: ["switch"])
        addPanelsToLayout(andView: view)
        
        layout.addGridConstraints(forKeys: [["mod"], ["switch"]], pinMargin: "", spacing: "-s1-")
        
        quickGrid(panel: "switch", items: [[(segCtrl, nil, "switchCtrl")]])

        index = 0
        
        addColorToAll(except: ["switch"], level: 2)
        addColor(panels: ["switch"], level: 2, clearBackground: true)
        addBorder(view: view, level: 2)
      }
      
    }
    
    class ModController : NewPatchEditorController {
      
      private let src = PBSelect(label: "Src")
      
      override var prefix: SynthPath? { return [.mod, .i(index)] }

      override var index: Int {
        didSet { src.label = "Mod Src \(index+1)" }
      }

      override func loadView(_ view: PBView) {
        quickGrid(view: view, items: [[
          (src, [.src], nil),
          (PBKnob(label: "Amount"), [.amt], nil),
          (PBSelect(label: "Dest"), [.dest], nil),
          ]])
        
        dims(view: view, forPath: [.dest])
      }
    }
  }
  
  class ModsController : NewPatchEditorController {
    
    private func quickGrid(panel: String, label: String, path: SynthPath) {
      quickGrid(panel: panel, items: [[
        (PBKnob(label: label), path + [.amt], nil),
        ],[
        (PBSelect(label: "Dest"), path + [.dest], nil),
        ]])
      addPatchChangeBlock(path: path + [.dest]) { [weak self] in
        self?.panels[panel]?.alpha = $0 == 0 ? 0.5 : 1
      }
    }
    
    override func loadView() {
      let paddedView = PaddedContainer()
      paddedView.verticalPadding = 0.1
      paddedView.horizontalPadding = 0.1
      let view = paddedView.mainView
      
      let _: [MainController.LFOController] = addChildren(count: 4, panelPrefix: "lfo")
      let _: [MainController.ModController] = addChildren(count: 4, panelPrefix: "mod")
      createPanels(forKeys: ["wheel", "press", "breath", "foot", "peak", "follow", "velo", "env2"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("lfo0", 3.5), ("lfo1", 3.5), ("mod0", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("lfo2", 3.5), ("lfo3", 3.5), ("mod2", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("wheel", 1), ("press", 1), ("breath", 1), ("foot", 1), ("peak", 1), ("follow", 1), ("velo", 1), ("env2", 1)], pinned: true, pinMargin: "", spacing: "-s1-")

      layout.addColumnConstraints([("lfo0", 2), ("lfo2", 2), ("wheel", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("mod0", 1), ("mod1", 1), ("mod2", 1), ("mod3", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      
      layout.addEqualConstraints(forItemKeys: ["lfo0", "lfo1", "mod1"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["lfo2", "lfo3", "mod3"], attribute: .bottom)
      
      quickGrid(panel: "wheel", label: "Mod Wheel", path: [.modWheel])
      quickGrid(panel: "press", label: "Pressure", path: [.pressure])
      quickGrid(panel: "breath", label: "Breath Ctrl", path: [.breath])
      quickGrid(panel: "foot", label: "Foot Ctrl", path: [.foot])
      quickGrid(panel: "peak", label: "In Peak", path: [.extAudio, .peak])
      quickGrid(panel: "follow", label: "Env Follow", path: [.extAudio, .follow])
      quickGrid(panel: "velo", label: "Velocity", path: [.velo])
      quickGrid(panel: "env2", label: "Env 3", path: [.env, .i(2)])
      
      layout.activateConstraints()
      self.view = paddedView
      
      addColorToAll(level: 2)
    }
  }
  
  
  /// Controller for all 4 sequences..
  class SeqController : NewPatchEditorController {

    override func loadView(_ view: PBView) {
      let _: [TrackController] = addChildren(count: 4, panelPrefix: "trk")
      createPanels(forKeys: ["seq"])
      addPanelsToLayout(andView: view)

      layout.addRowConstraints([
        ("seq",3),("trk0",20),
        ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
      layout.addColumnConstraints([
        ("trk0",2),("trk1",2),("trk2",2),("trk3",2)
        ], options: [.alignAllLeading, .alignAllTrailing], pinned: true, spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["seq","trk1"], attribute: .bottom)
      
      quickGrid(panel: "seq", items: [
        [(PBKnob(label: "Tempo"), [.tempo], nil)],
        [(PBSelect(label: "Clock Divide"), [.clock, .divide], nil)],
        [(PBSelect(label: "Trigger Select"), [.trigger], nil)],
        ])
      
      addColorToAll()

    }
        
    class TrackController : NewPatchEditorController {

      override var prefix: SynthPath? { return [.seq, .i(index)] }

      private let label = createLabel()
      private let editButton = createMenuButton(titled: "Edit")
      
      override var index: Int {
        didSet { label.text = "Sequence \(index + 1)" }
      }
      
      override func loadView(_ view: PBView) {
        label.textAlignment = .center
        view.addSubview(label)
        layout.addView(label, forLayoutKey: "label")
        
        let dest = PBSelect(label: "Destination")
        view.addSubview(dest)
        layout.addView(dest, forLayoutKey: "Dest")
        addBlocks(control: dest, path: [.dest])
        
        view.addSubview(editButton)
        layout.addView(editButton, forLayoutKey: "edit")
        
        var items: [(String,CGFloat)] = [("label",3)]
        
        (0..<16).forEach { i in
          let s = PBFullSlider(label: "")
          s.tag = i
          view.addSubview(s)
          let key  = "Step\(i)"
          layout.addView(s, forLayoutKey: key)
          addBlocks(control: s, path: [.step, .i(i)])
          items.append((key,1))
        }
        
        layout.addRowConstraints(items, options: [.alignAllTop], pinned: true, spacing: "-s1-")
        layout.addColumnConstraints([
          ("label",2),("Dest",2),("edit",2)
          ], options: [.alignAllLeading, .alignAllTrailing], pinned: true)
        layout.addEqualConstraints(forItemKeys: (0...16).map { $0 == 0 ? "edit" : "Step\($0-1)" }, attribute: .bottom)
        
        registerForEditMenu(editButton, bundle: (
          paths: { (0..<16).map { [.step, .i($0)] } },
          pasteboardType: "com.cfshpd.EvolverSeqTrack",
          initialize: { [Int](repeating: 0, count: 16) },
          randomize: { (0..<16).map { _ in (0...127).random()! } }
        ))
        
//        let alt = tertiaryBackgroundColor(forColorGuide: colorGuide).tinted(amount: 0.06)
//        view.subviews.forEach {
//          guard let s = $0 as? PBFullSlider else { return }
//          if (s.tag / 4) % 2 == 0 {
//            addColor(view: s, level: 2)
//          }
//        }
      }
    }

  }
  
}
