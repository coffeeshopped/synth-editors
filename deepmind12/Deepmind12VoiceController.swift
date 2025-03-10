
class Deepmind12VoiceController : NewPagedEditorController {
  
  private let mainController = MainController()
  private let modsController = ModsController()
  private let arpSeqController = ArpSeqController()
  
  override func loadView(_ view: PBView) {
    switchCtrl = PBSegmentedControl(items: ["Main", "Mod/FX", "Arp/Seq"])
    grid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil)]])

    grid(panel: "tempo", items: [[
      (PBKnob(label: "Cutoff"), [.filter, .cutoff]),
      (PBKnob(label: "VCA Level"), [.amp, .level]),
      (PBCheckbox(label: "Arp"), [.arp, .on]),
      (PBKnob(label: "Tempo"), [.arp, .rate]),
      (PBCheckbox(label: "Sequencer"), [.seq, .on]),
    ]])
    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch", 11), ("tempo", 5),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",8)
      ], pinned: true, spacing: "-s1-")
  
    addColor(panels: ["switch"], clearBackground: true)
    addColor(panels: ["tempo"])

  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    let vcs = [mainController, modsController, arpSeqController]
    guard index < vcs.count else { return nil }
    return vcs[index]
  }
  
  
  class MainController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      addChild(EnvController(prefix: [.amp, .env], label: "VCA Env"), withPanel: "aEnv")
      addChild(EnvController(prefix: [.filter, .env], label: "VCF Env"), withPanel: "fEnv")
      addChild(EnvController(prefix: [.mod, .env], label: "Mod Env"), withPanel: "mEnv")
      addChild(ModSwitchController(), withPanel: "modSwitch")
      let _: [LFOController] = addChildren(count: 2, panelPrefix: "lfo")

      grid(panel: "osc0", prefix: [.osc, .i(0)], items: [[
        (PBSwitch(label: "Osc 1"), [.range]),
        (PBCheckbox(label: "Pulse"), [.pulse, .on]),
        (PBCheckbox(label: "Saw"), [.saw, .on]),
        (PBSelect(label: "Pitch Src"), [.pitch, .mod, .src]),
        (PBKnob(label: "Pitch Depth"), [.pitch, .mod, .depth]),
        (PBKnob(label: "←After"), [ .pitch, .aftertouch, .depth]),
        (PBKnob(label: "←ModWh"), [ .pitch, .modWheel, .depth]),
        (PBSelect(label: "PWM Src"), [.pw, .src]),
        (PBKnob(label: "← Depth"), [.pw, .depth]),
      ]])
      
      grid(panel: "osc1", prefix: [.osc, .i(1)], items: [[
        (PBSwitch(label: "Osc 2"), [.range]),
        (PBKnob(label: "Pitch"), [.pitch]),
        (PBKnob(label: "Level"), [.level]),
        (PBSelect(label: "Pitch Src"), [.pitch, .mod, .src]),
        (PBKnob(label: "Pitch Depth"), [.pitch, .mod, .depth]),
        (PBKnob(label: "←After"), [.pitch, .aftertouch, .depth]),
        (PBKnob(label: "←ModWh"), [.pitch, .modWheel, .depth]),
        (PBSelect(label: "Tone Mod Src"), [.tone, .src]),
        (PBKnob(label: "← Depth"), [.tone, .depth]),
      ]])

      grid(panel: "sync", items: [[
        (PBCheckbox(label: "Sync"), [.osc, .sync]),
        (PBKnob(label: "Noise"), [.noise]),
        (PBSwitch(label: "Pitch Mod Mode"), [.osc, .i(0), .pitch, .mod, .mode]),
        (PBKnob(label: "Bend Down"), [.bend, .down]),
        (PBKnob(label: "Bend Up"), [.bend, .up]),
        (PBCheckbox(label: "Osc Key Reset"), [.osc, .key, .reset]),
        (PBKnob(label: "Transpose"), [.transpose]),
      ]])

      grid(panel: "porta", items: [[
        (PBSelect(label: "Porta Mode"), [.porta, .mode]),
        (PBKnob(label: "Time"), [.porta, .time]),
        (PBKnob(label: "Balance"), [.porta, .balance]),
      ]])
      
      grid(panel: "filter", prefix: [.filter], items: [[
        (PBSwitch(label: "Filter Mode"), [.mode]),
        (PBKnob(label: "Cutoff"), [.cutoff]),
        (PBKnob(label: "Reson"), [.reson]),
        (PBKnob(label: "HP Freq"), [.hi, .cutoff]),
        (PBKnob(label: "Key Trk"), [.keyTrk]),
        ],[
        (PBKnob(label: "Bend>Freq"), [.cutoff, .bend]),
        (PBSwitch(label: "LFO"), [.lfo, .select]),
        (PBKnob(label: "LFO Depth"), [.lfo, .depth]),
        (PBKnob(label: "←After"), [.aftertouch, .lfo]),
        (PBKnob(label: "←ModWh"), [.modWheel, .lfo]),
        ],[
        (PBSwitch(label: "Env Pol"), [.env, .polarity]),
        (PBKnob(label: "Env Amt"), [.env, .depth]),
        (PBKnob(label: "Env Velo"), [.env, .velo]),
        (PBCheckbox(label: "Bass Boost"), [.booster]),
      ]])
      
      grid(panel: "level", items: [[
        (PBSelect(label: "Poly Mode"), [.poly]),
        (PBKnob(label: "Uni Detune"), [.unison, .detune]),
        (PBSwitch(label: "Voice Priority"), [.voice, .priority]),
        ],[
        (PBSwitch(label: "Env Trig Mode"), [.env, .trigger]),
        (PBKnob(label: "Voice Drift"), [.osc, .slop]),
        (PBKnob(label: "Param Drift"), [.param, .slop]),
        (PBKnob(label: "Drift Rate"), [.slop, .rate]),
      ]])

      grid(panel: "cat", items: [[
        (PBKnob(label: "VCA Level"), [.amp, .level]),
        (PBKnob(label: "Env Depth"), [.amp, .env, .depth]),
        (PBKnob(label: "Env Velo"), [.amp, .env, .velo]),
        (PBKnob(label: "Pan"), [.pan]),
        ],[
        (PBSelect(label: "Category"), [.category]),
      ]])
      
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("osc0", 10), ("filter", 5)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("sync", 7), ("porta", 3.5)], pinned: false, spacing: "-s1-")
      layout.addRowConstraints([("aEnv", 4), ("fEnv", 4), ("mEnv", 4), ("level", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("cat", 4), ("lfo0", 4), ("lfo1", 4)], pinned: false, spacing: "-s1-")
      layout.addColumnConstraints([("osc0", 1), ("osc1", 1), ("sync", 1), ("aEnv", 3), ("cat", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      layout.addColumnConstraints([("level", 2), ("modSwitch", 3)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      
      layout.addEqualConstraints(forItemKeys: ["osc0", "osc1", "porta"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["mEnv", "lfo1"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["sync", "filter"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["aEnv", "fEnv", "mEnv"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["modSwitch", "cat"], attribute: .bottom)

      addColor(panels: ["osc0", "osc1", "sync", "porta", "aEnv", "level", "cat"], level: 1)
      addColor(panels: ["filter", "fEnv"], level: 2)
      addColor(panels: ["mEnv", "lfo0", "lfo1", "modSwitch"], level: 3)
    }
    
  }
  
  class EnvController : NewPatchEditorController {
    let env = Deepmind12EnvelopeControl()
    
    override var prefix: SynthPath? { return _prefix }
    private var _prefix: SynthPath?
        
    convenience init(prefix: SynthPath, label: String) {
      self.init()
      _prefix = prefix
      env.label = label
    }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (env, nil),
        (PBSelect(label: "Trigger"), [.trigger]),
        ],[
        (PBKnob(label: "Attack"), [.attack]),
        (PBKnob(label: "Decay"), [.decay]),
        (PBKnob(label: "Sustain"), [.sustain]),
        (PBKnob(label: "Release"), [.release]),
        ],[
        (PBKnob(label: "A Crv"), [.attack, .curve]),
        (PBKnob(label: "D Crv"), [.decay, .curve]),
        (PBKnob(label: "S Crv"), [.sustain, .curve]),
        (PBKnob(label: "R Crv"), [.release, .curve]),
      ]])
            
      registerForEditMenu(env, bundle: (
        paths: { [[.attack], [.decay], [.sustain], [.release],
                  [.attack, .curve], [.decay, .curve], [.sustain, .curve], [.release, .curve],
        ] },
        pasteboardType: "com.cfshpd.Deepmind12Env",
        initialize: { [0, 0, 127, 0, 0, 0, 0, 0] },
        randomize: { (0..<8).map { _ in (0...127).random()! } }
      ))
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      let env = self.env
      addPatchChangeBlock(path: [.attack]) { env.attack = CGFloat($0) / 255 }
      addPatchChangeBlock(path: [.decay]) { env.decay = CGFloat($0) / 255 }
      addPatchChangeBlock(path: [.sustain]) { env.sustain = CGFloat($0) / 255 }
      addPatchChangeBlock(path: [.release]) { env.rrelease = CGFloat($0) / 255 }
      addPatchChangeBlock(path: [.attack, .curve]) { env.aCurve = CGFloat($0) / 255 }
      addPatchChangeBlock(path: [.decay, .curve]) { env.dCurve = CGFloat($0) / 255 }
      addPatchChangeBlock(path: [.sustain, .curve]) { env.sCurve = CGFloat($0) / 255 }
      addPatchChangeBlock(path: [.release, .curve]) { env.rCurve = CGFloat($0) / 255 }
    }
  }
  
  class LFOController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.lfo, .i(index)] }
    
    override func loadView(_ view: PBView) {
      let rate = PBKnob(label: "Rate")
      grid(view: view, items: [[
        (rate, [.rate]),
        (PBCheckbox(label: "Key Sync"), [.key, .sync]),
        (PBKnob(label: "Delay"), [.delay]),
        (PBKnob(label: "Slew"), [.slew]),
        ],[
        (PBSelect(label: "LFO \(index + 1)"), [.wave]),
        (PBCheckbox(label: "Arp Sync"), [.arp, .sync]),
        (PBSelect(label: "Mono Mode"), [.mono]),
      ]])
      
      addPatchChangeBlock(path: [.arp, .sync]) { [weak self] in
        if $0 == 0 {
          rate.label = "Rate"
          self?.defaultConfigure(control: rate, forParam: RangeParam(range: 0...255))
        }
        else {
          rate.label = "Clock"
          self?.defaultConfigure(control: rate, forParam: MisoParam.make(maxVal: 255, iso: Deepmind12VoicePatch.lfoClockIso))
        }
      }
    }
  }
  
  class ModSwitchController : NewPatchEditorController {
    
    private var modControllers: [ModController]!
    
    override var index: Int {
      didSet { modControllers?.enumerated().forEach { $0.element.index = $0.offset + index * 2 }}
    }
    
    override func loadView(_ view: PBView) {
      modControllers = addChildren(count: 2, panelPrefix: "mod")
      
      let labeledSwitch = LabeledSegmentedControl(label: "Mods", items: ["1/2", "3/4", "5/6", "7/8"])
      switchCtrl = labeledSwitch.segmentedControl
      grid(panel: "switch", items: [[(labeledSwitch, nil)]])
      
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        [("mod0", 1)],
        [("mod1", 1)],
        [("switch", 1)],
      ], spacing: "-s1-")

      addColor(panels: ["mod0", "mod1"], level: 3)
      addColor(panels: ["switch"], level: 3, clearBackground: true)
    }
    
  }
  
  class ModsController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      let _: [ModController] = addChildren(count: 8, panelPrefix: "mod")
      let _: [FXController] = addChildren(count: 4, panelPrefix: "fx")
      
      let routing = PBImageSelect(label: "Routing", imageSize: CGSize(width: 200, height: 70), imageSpacing: 12)
      grid(panel: "fxmode", items: [[
        (PBSwitch(label: "FX Mode"), [.fx, .mode]),
        (routing, nil)
      ]])
      
      createPanels(forKeys: ["space", "space2"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("mod0", 4), ("mod1", 4), ("mod2", 4), ("mod3", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod4", 4), ("mod5", 4), ("mod6", 4), ("mod7", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("fxmode", 2.5), ("space2", 10)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("fx0", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("fx1", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("fx2", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("fx3", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("space", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("mod0", 1), ("mod4", 1), ("fxmode", 1), ("fx0", 1), ("fx1", 1), ("fx2", 1), ("fx3", 1), ("space", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      addBlocks(control: routing, path: [.fx, .routing], paramAfterBlock: {
        routing.options = OptionsParam.makeOptions((1...10).map { "deepmind-fx-\($0)" })
      })

      addColor(panels: ["fxmode", "fx0", "fx1", "fx2", "fx3"], level: 2)
      addColor(panels: (0..<8).map { "mod\($0)" }, level: 3)
    }
    
  }
  
  class ModController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.mod, .i(index)] }
    
    override var index: Int {
      didSet { src.label = "Mod \(index + 1) Src" }
    }
    
    private let src = PBSelect(label: "Mod Src")
    private var fxDests = Deepmind12VoicePatch.modDestOptions
    // index of FX1 Param 1: 78
    
    override func loadView(_ view: PBView) {
      let dest = PBSelect(label: "Dest")
      grid(view: view, items: [[
        (src, [.src]),
        (PBKnob(label: "Amount"), [.depth]),
        (dest, nil),
      ]])
      
      addPatchChangeBlock(paths: [[.src], [.dest]]) {
        let dimmed = $0[[.src]] == 0 || $0[[.dest]] == 0
        view.alpha = dimmed ? 0.4 : 1
      }
      
      addDefaultPatchChangeBlock(control: dest, path: [.dest])
      addDefaultControlChangeBlock(control: dest, path: [.dest])
      (0..<4).forEach { fx in
        addPatchChangeBlock { [weak self] changes in
          guard let fxType = Self.updatedValueForFullPath([.fx, .i(fx), .type], state: changes) else { return }
          guard fxType < Deepmind12FX.params.count else { return }
          let fxParams = Deepmind12FX.params[fxType]
          (0..<12).forEach { parm in
            let parmLabel = parm < fxParams.count && fxParams[parm].2 ? "FX\(fx + 1): \(fxParams[parm].0)" : "---"
            self?.fxDests[78 + (fx * 12) + parm] = parmLabel
          }
          dest.options = self?.fxDests ?? [:]
        }
      }
    }
  }
  
  class FXController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.fx, .i(index)] }
    
    override var index: Int {
      didSet { type.label = "FX \(index + 1) Type" }
    }
    
    private let type = PBSelect(label: "FX Type")
    
    override func loadView(_ view: PBView) {
      let gain = PBKnob(label: "Gain")
      let knobs = (0..<12).map { PBKnob(label: "Param \($0 + 1)") }
      grid(view: view, items: [[
        (type, [.type]),
        (gain, [.level]),
      ] + (0..<12).map { (knobs[$0], nil) }])
      
      (0..<12).forEach {
        addDefaultPatchChangeBlock(control: knobs[$0], path: [.param, .i($0)])
        addDefaultControlChangeBlock(control: knobs[$0], path: [.param, .i($0)])
      }
      
      addPatchChangeBlock(path: [.type]) { [weak self] value in
        guard value < Deepmind12FX.params.count else { return }
        let parms = Deepmind12FX.params[value]
        (0..<12).forEach {
          let knob = knobs[$0]
          knob.isHidden = $0 >= parms.count
          guard $0 < parms.count else { return }
          let parm = parms[$0]
          knob.label = parm.0
          self?.defaultConfigure(control: knob, forParam: parm.1)
        }
      }
      
      addPatchChangeBlock { [weak self] (changes) in
        guard let routing = Self.updatedValueForFullPath([.fx, .routing], state: changes),
              routing < Deepmind12FX.routingLevels.count,
              let index = self?.index,
              index < 4 else { return }
        let maxLevel = Deepmind12FX.routingLevels[routing].max[index]
        gain.isHidden = maxLevel == 0
        gain.maximumValue = maxLevel
      }
    }
  }
  
  class ArpSeqController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      addChild(ArpController(), withPanel: "arp")
      addChild(SeqArrayController(), withPanel: "array")
      
      grid(panel: "seq", items: [[
        (PBCheckbox(label: "Sequencer"), [.seq, .on]),
        (PBSelect(label: "Clock Div"), [.seq, .clock]),
        (PBKnob(label: "Length"), [.seq, .length]),
        (PBKnob(label: "Swing"), [.seq, .swing]),
        (PBSwitch(label: "Key Sync/Loop"), [.seq, .key, .sync, .loop]),
        (PBKnob(label: "Slew Rate"), [.seq, .slew, .rate]),
      ]])
      
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("arp", 11.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("seq", 6)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("array", 16)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("arp", 1), ("seq", 1), ("array", 6)], pinned: true, pinMargin: "", spacing: "-s1-")

      addColor(panels: ["arp"])
      addColor(panels: ["seq", "array"], level: 2)
    }
    
  }
  
  class ArpController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.arp] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBCheckbox(label: "Arp"), [.on]),
        (PBSelect(label: "Mode"), [.mode]),
        (PBKnob(label: "Tempo"), [.rate]),
        (PBSelect(label: "Clock Div"), [.clock]),
        (PBCheckbox(label: "Key Sync"), [.key, .sync]),
        (PBKnob(label: "Gate Time"), [.gate]),
        (PBCheckbox(label: "Hold"), [.hold]),
        (PBSelect(label: "Pattern"), [.pattern]),
        (PBKnob(label: "Swing"), [.swing]),
        (PBKnob(label: "Octaves"), [.octave]),
      ]])
    }
  }
  
  class SeqArrayController : NewPatchEditorController {
    
    private let arrayCtrl = PBArrayControl(label: "Ctrl Sequencer")
    private let gridCtrl = PBGridSelectControl(label: "")

    override func loadView(_ view: PBView) {
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
      grid(panel: "modes", items: [[(gridCtrl, nil)]])
      
      arrayCtrl.count = 32
      arrayCtrl.range = -127...127
      grid(panel: "array", items: [[(arrayCtrl, nil)]])
      
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([[("modes", 1), ("array", 14)]], pinMargin: "", spacing: "-s1-")
      
      let arrayCtrl = self.arrayCtrl
      (0..<arrayCtrl.count).forEach { step in
        addPatchChangeBlock(path: [.seq, .step, .i(step)]) { arrayCtrl[step] = $0 - 128 }
      }
      addControlChangeBlock(control: arrayCtrl) {
        var changes = [SynthPath:Int]()
        (0..<arrayCtrl.count).forEach { changes[[.seq, .step, .i($0)]] = arrayCtrl[$0] + 128}
        return .paramsChange(SynthPathIntsMake(changes))
      }
      addPatchChangeBlock(path: [.seq, .length]) { arrayCtrl.visibleCount = $0 + 2 }
      
      addColorToAll(level: 2)
    }
    
    @IBAction func modeChange(_ sender: PBGridSelectControl) {
      arrayCtrl.mode = PBArrayControl.Mode(rawValue: sender.value)!
    }
  }
  
}
