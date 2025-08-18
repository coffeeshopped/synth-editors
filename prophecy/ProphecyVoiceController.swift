
class ProphecyVoiceController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    addChild(MainController(), withPanel: "main")
    addChild(LFOController(), withPanel: "lfo")
    addChild(EnvController(), withPanel: "env")
    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("main", 11), ("env", 5)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("env", 5), ("lfo", 4)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["main", "lfo"], attribute: .bottom)
  }
    
  class MainController : NewPagedEditorController {
    private let oscController = ProphecyOscController()
    private let filterAmpController = FilterAmpController()
    private let fxCtrlController = FXCtrlController()
    private let perfController = PerfController()
    
    override func loadView(_ view: PBView) {
      switchCtrl = PBSegmentedControl(items: ["Osc", "Filter/Amp", "FX/Ctrl", "Perf"])
      grid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil)]])

      let routing = PBImageSelect(label: "Filter Routing", imageSize: CGSize(width: 209, height: 62), imageSpacing: 12)
      grid(panel: "routing", items: [[(routing, nil)]])
      addBlocks(control: routing, path: [.filter, .routing], paramAfterBlock: {
        routing.options = OptionsParam.makeOptions((1...3).map { "prophecy-routing-\($0)" })
      })
      
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        (row: [("switch", 8), ("routing", 2)], height: 1),
        (row: [("page", 11)], height: 8),
      ], pinMargin: "", spacing: "-s1-")
      
      addColor(panels: ["switch"], clearBackground: true)
      addColor(panels: ["routing"])

    }
        
    override func viewController(forIndex index: Int) -> PBViewController? {
      let vcs = [oscController, filterAmpController, fxCtrlController, perfController]
      guard index < vcs.count else { return nil }
      return vcs[index]
    }
  }
  
  
  class FilterAmpController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      let _: [FilterController] = addChildren(count: 2, panelPrefix: "filter")
      let _: [AmpController] = addChildren(count: 2, panelPrefix: "amp")

      grid(panel: "porta", items: [[
        (PBCheckbox(label: "Porta"), [.porta, .on]),
        (PBSwitch(label: "Mode"), [.porta, .mode]),
        (PBKnob(label: "Time"), [.porta, .time]),
        (PBKnob(label: "←Velo"), [.porta, .time, .velo]),
        (PBSelect(label: "Pgm Cat"), [.pgm, .category]),
        (PBCheckbox(label: "Hold"), [.hold]),
      ],[
        (PBSwitch(label: "Key Prior"), [.key, .priority]),
        (PBSwitch(label: "Trig Mode"), [.trigger, .mode]),
        (PBKnob(label: "Thresh Velo"), [.retrigger, .threshold, .velo]),
        (PBSwitch(label: "Rtrg Dir"), [.retrigger, .direction]),
        (PBSelect(label: "Scale"), [.scale, .type]),
        (PBKnob(label: "Key"), [.scale, .key]),
        (PBKnob(label: "Rand Pitch"), [.random, .pitch]),
      ]])
      
      let routing = PBImageSelect(label: "Filter Routing", imageSize: CGSize(width: 209, height: 62), imageSpacing: 12)
      grid(panel: "routing", items: [[
        (routing, nil),
      ]])
      
      grid(panel: "pan", items: [[
        (PBKnob(label: "Pan"), [.pan]),
        (PBKnob(label: "Out Level"), [.out, .level]),
      ],[
        (PBSelect(label: "Mod Src"), [.pan, .mod, .src]),
        (PBKnob(label: "←Int"), [.pan, .mod, .amt]),
      ]])
      
      addPanelsToLayout(andView: view)

      layout.addRowConstraints([("porta", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("filter0", 9), ("routing", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("filter1", 9), ("pan", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("amp0", 5), ("amp1", 5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("porta", 2), ("filter0", 2), ("filter1", 2), ("amp0", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      addBlocks(control: routing, path: [.filter, .routing], paramAfterBlock: {
        routing.options = OptionsParam.makeOptions((1...3).map { "prophecy-routing-\($0)" })
      })

      addColor(panels: ["porta", "amp0", "amp1", "pan"], level: 1)
      addColor(panels: ["filter0", "filter1", "routing"], level: 2)

    }
        
    class FilterController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.filter, .i(index)] }
      
      private let fType = PBSwitch(label: "Filter 1")
      
      override var index: Int {
        didSet { fType.label = "Filter \(index + 1)" }
      }
      
      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (fType, [.type]),
          (PBKnob(label: "Cutoff"), [.cutoff]),
          (PBSelect(label: "Cutoff Env"), [.cutoff, .env]),
          (PBKnob(label: "←Int"), [.cutoff, .env, .amt]),
          (PBSelect(label: "Cutoff Mod"), [.cutoff, .mod, .src]),
          (PBKnob(label: "←Int"), [.cutoff, .mod, .amt]),
          (PBSwitch(label: "Cutoff LFO"), [.cutoff, .lfo]),
          (PBKnob(label: "←Int"), [.cutoff, .lfo, .amt]),
        ],[
          (PBKnob(label: "Input Trim"), [.input, .gain]),
          (PBKnob(label: "Reson"), [.reson]),
          (PBKnob(label: "Cut Lo Key"), [.cutoff, .key, .lo]),
          (PBKnob(label: "Cut Hi Key"), [.cutoff, .key, .hi]),
          (PBKnob(label: "Cut Lo Int"), [.cutoff, .amt, .lo]),
          (PBKnob(label: "Cut Hi Int"), [.cutoff, .amt, .hi]),
          (PBSelect(label: "Reson Mod"), [.reson, .mod, .src]),
          (PBKnob(label: "←Int"), [.reson, .mod, .amt]),
        ]])
        
        dims(view: view, forPath: [.type])
      }
    }
    
    class AmpController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.amp, .i(index)] }
      
      private let level = PBKnob(label: "Amp 1 Level")
      
      override var index: Int {
        didSet { level.label = "Amp \(index + 1) Level" }
      }
      
      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (level, [.level]),
          (PBKnob(label: "Key Lo"), [.key, .lo]),
          (PBKnob(label: "Key Hi"), [.key, .hi]),
          (PBKnob(label: "Int Lo"), [.amt, .lo]),
          (PBKnob(label: "Int Hi"), [.amt, .hi]),
        ],[
          (PBSelect(label: "Amp Env"), [.env]),
          (PBKnob(label: "←Int"), [.env, .amt]),
          (PBSelect(label: "Mod Src"), [.mod, .src]),
          (PBKnob(label: "←Int"), [.mod, .amt]),
        ]])
      }
    }
  }
  
  class FXCtrlController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      grid(panel: "dist", prefix: [.dist], items: [[
        (PBKnob(label: "Dist Gain"), [.gain]),
        (PBKnob(label: "Tone"), [.tone]),
        (PBKnob(label: "Level"), [.level]),
        (PBKnob(label: "Balance"), [.balance]),
        (PBSelect(label: "Balance Mod"), [.balance, .mod, .src]),
        (PBKnob(label: "←Int"), [.balance, .mod, .amt]),
      ]])
      
      grid(panel: "wah", prefix: [.wah], items: [[
        (PBKnob(label: "Wah Level"), [.level]),
        (PBKnob(label: "Reson"), [.reson]),
        (PBSelect(label: "Sweep Src"), [.swing, .src]),
        (PBSwitch(label: "Sweep Dir"), [.swing, .direction]),
        (PBKnob(label: "Freq Lo"), [.freq, .lo]),
        (PBKnob(label: "Freq Hi"), [.freq, .hi]),
        (PBKnob(label: "Balance"), [.balance]),
        (PBSelect(label: "Balance Mod"), [.balance, .mod, .src]),
        (PBKnob(label: "←Int"), [.balance, .mod, .amt]),
      ]])
      
      grid(panel: "fxsel", items: [[
        (PBSwitch(label: "FX Select"), [.fx, .select]),
      ]])

      grid(panel: "chorus", prefix: [.chorus], items: [[
        (PBKnob(label: "Chorus Dly"), [.delay]),
        (PBKnob(label: "Feedbk"), [.feedback]),
        (PBSwitch(label: "Mod LFO"), [.lfo]),
        (PBKnob(label: "←Int"), [.lfo, .amt]),
        (PBSelect(label: "Mod Src"), [.mod, .src]),
        (PBKnob(label: "←Int"), [.mod, .amt]),
        (PBKnob(label: "Balance"), [.balance]),
        (PBSelect(label: "Balance Mod"), [.balance, .mod, .src]),
        (PBKnob(label: "←Int"), [.balance, .mod, .amt]),
      ]])

      grid(panel: "delay", prefix: [.delay], items: [[
        (PBKnob(label: "Delay Time"), [.time]),
        (PBKnob(label: "Feedbk"), [.feedback]),
        (PBKnob(label: "HiDamp"), [.hi]),
        (PBKnob(label: "Balance"), [.balance]),
        (PBSelect(label: "Balance Mod"), [.balance, .mod, .src]),
        (PBKnob(label: "←Int"), [.balance, .mod, .amt]),
      ]])

      grid(panel: "reverb", prefix: [.reverb], items: [[
        (PBKnob(label: "Reverb Dly"), [.delay]),
        (PBKnob(label: "Time"), [.time]),
        (PBKnob(label: "HiDamp"), [.hi]),
        (PBKnob(label: "Balance"), [.balance]),
        (PBSelect(label: "Balance Mod"), [.balance, .mod, .src]),
        (PBKnob(label: "←Int"), [.balance, .mod, .amt]),
      ]])

      grid(panel: "eq", prefix: [.eq], items: [[
        (PBKnob(label: "EQ Hi Freq"), [.hi, .freq]),
        (PBKnob(label: "Hi Q"), [.hi, .q]),
        (PBKnob(label: "Hi Gain"), [.hi, .gain]),
      ],[
        (PBKnob(label: "Lo Freq"), [.lo, .freq]),
        (PBKnob(label: "Lo Q"), [.lo, .q]),
        (PBKnob(label: "Lo Gain"), [.lo, .gain]),
      ]])
      
      grid(panel: "ctrl", items: [[
        (PBSelect(label: "Wheel 1"), [.modWheel, .i(0)]),
        (PBSelect(label: "Wheel 2"), [.modWheel, .i(1)]),
        (PBSelect(label: "Wheel 3+"), [.modWheel, .i(2), .up]),
        (PBSelect(label: "Wheel 3-"), [.modWheel, .i(2), .down]),
      ],[
        (PBSelect(label: "Ribbon X"), [.ctrl, .x]),
        (PBCheckbox(label: "X Var Ctr"), [.ctrl, .x, .brk]),
        (PBSelect(label: "Ribbon Z"), [.ctrl, .z]),
        (PBSelect(label: "Foot Pedal"), [.foot, .pedal]),
        (PBSelect(label: "Foot Switch"), [.foot, .mode]),
      ]])

      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("dist", 6.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("wah", 10)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("fxsel", 1.5), ("chorus", 10)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("delay", 6.5), ("eq", 3)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("ctrl", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("dist", 1), ("wah", 1), ("fxsel", 1), ("delay", 1), ("reverb", 1), ("ctrl", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["delay", "reverb"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["reverb", "eq"], attribute: .bottom)
      
      addPatchChangeBlock(path: [.fx, .select]) { [weak self] in
        self?.panels["chorus"]?.isHidden = $0 == 1
        self?.panels["delay"]?.isHidden = $0 == 1
        self?.panels["reverb"]?.isHidden = $0 == 0
      }
      
      addColorToAll()
    }

  }
  
  class PerfController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      let _: [SetController] = addChildren(count: 4, panelPrefix: "perf")
      addPanelsToLayout(andView: view)
      layout.addGridConstraints((0..<4).map { [("perf\($0)", 2)] }, pinMargin: "", spacing: "-s1-")
    }
    
    class SetController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.perf, .i(index)] }
      private let on = PBCheckbox(label: "Perf 1")
      
      override var index: Int {
        didSet { on.label = "Perf \(index + 1)" }
      }

      override func loadView(_ view: PBView) {
        let _: [KnobController] = addChildren(count: 5, panelPrefix: "knob")
        grid(panel: "on", items: [[(on, [.on])]])
        
        addPanelsToLayout(andView: view)
        layout.addGridConstraints([[("on", 1)] + (0..<5).map { ("knob\($0)", 2) }], pinMargin: "", spacing: "-s1-")
        
        dims(view: view, forPath: [.on])

        addColorToAll()
        addBorder(view: view)
      }
      
      
      
      class KnobController : NewPatchEditorController {
        override var prefix: SynthPath? { return [.knob, .i(index)] }
        
        private let knob = PBSelect(label: "Knob 1")
        
        override var index: Int {
          didSet { knob.label = "Knob \(index + 1)" }
        }
        
        override func loadView(_ view: PBView) {
          grid(view: view, items: [[
            (PBKnob(label: "Low"), [.lo]),
            (PBKnob(label: "High"), [.hi]),
          ],[
            (knob, [.param]),
            (PBSwitch(label: "Curve"), [.curve]),
          ]])
          
          dims(view: view, forPath: [.param])
        }
      }
    }
  }
  
  
  class LFOController : NewPatchEditorController {
    override var prefix: SynthPath? { [.lfo, .i(index)] }
    
    private let wave = PBSelect(label: "LFO 1")
    
    override var index: Int {
      didSet { wave.label = "LFO \(index + 1)" }
    }
    
    override func loadView(_ view: PBView) {
      let labeledGrid = LabeledGridSelectControl(label: "LFO")
      labeledGrid.label.textAlignment = .center
      let gridSelect = labeledGrid.gridControl
      gridSelect.columnCount = 1
      gridSelect.options = OptionsParam.makeOptions((1...4).map { "\($0)" })
      gridSelect.value = 0
      gridSelect.addValueChangeTarget(self, action: #selector(selectIndex(_:)))

      grid(panel: "switch", items: [[(labeledGrid, nil)]])
      
      grid(panel: "ctrl", items: [[
        (wave, [.wave]),
        (PBKnob(label: "Freq"), [.freq]),
        (PBKnob(label: "←Key Trk"), [.freq, .key, .trk]),
        ],[
        (PBSelect(label: "Freq Mod"), [.freq, .mod, .src]),
        (PBKnob(label: "←Int"), [.freq, .mod, .amt]),
        (PBKnob(label: "CC1→Freq"), [.freq, .ctrl]),
        ],[
        (PBKnob(label: "Offset"), [.offset]),
        (PBKnob(label: "Fade In"), [.fade]),
        (PBKnob(label: "Delay"), [.delay]),
        (PBCheckbox(label: "Key Sync"), [.key, .sync]),
        ],[
        (PBSelect(label: "Amp Mod"), [.amp, .mod, .src]),
        (PBKnob(label: "←Int"), [.amp, .mod, .depth]),
        (PBSwitch(label: "Mode"), [.mode]),
      ]])
      
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([[("switch", 1), ("ctrl", 4)]], pinMargin: "", spacing: "-s1-")
      
      addColor(panels: ["ctrl"], level: 3)
      addColor(panels: ["switch"], level: 3, clearBackground: true)
      addBorder(view: view, level: 3)
    }
    
  }
  
  class EnvController : NewPatchEditorController {
    override var prefix: SynthPath? {
      switch index {
      case 0...3:
        return [.env, .i(index)]
      case 4:
        return [.amp, .env]
      default:
        return [.pitch, .env]
      }
    }
    
    private let env = PBRateLevelEnvelopeControl(label: "Env 1")
    private let aLevel = PBKnob(label: "A Lvl")
    private let dLevel = PBKnob(label: "Brk Lvl")
    private let sLevel = PBKnob(label: "S Lvl")
    private let rLevel = PBKnob(label: "R Lvl")
    private let velos: [PBKnob] = (0..<4).map { _ in PBKnob(label: "Velo↑") }
    private let keys: [PBKnob] = (0..<4).map { _ in PBKnob(label: "Key Trk↑") }

    override var index: Int {
      didSet { updateIndex() }
    }
    
    override func loadView(_ view: PBView) {
      let labeledGrid = LabeledGridSelectControl(label: "Envs")
      labeledGrid.label.textAlignment = .center
      let gridSelect = labeledGrid.gridControl
      gridSelect.columnCount = 1
      gridSelect.options = OptionsParam.makeOptions((1...4).map { "\($0)" } + ["Amp", "Pitch"])
      gridSelect.value = 0
      gridSelect.addValueChangeTarget(self, action: #selector(selectIndex(_:)))

      env.bipolar = true
      env.pointCount = 4
      env.sustainPoint = 2
      
      grid(panel: "switch", items: [[(labeledGrid, nil)]])
            
      grid(panel: "ctrl", items: [[
        (PBKnob(label: "Start"), [.start, .level]),
        (env, nil),
        (PBKnob(label: "Velo Lvl"), [.velo, .level]),
      ],[
        (aLevel, [.attack, .level]),
        (dLevel, [.decay, .level]),
        (sLevel, [.sustain, .level]),
        (rLevel, [.release, .level]),
      ],[
        (PBKnob(label: "Attack"), [.attack, .time]),
        (PBKnob(label: "Decay"), [.decay, .time]),
        (PBKnob(label: "Slope"), [.sustain, .time]),
        (PBKnob(label: "Release"), [.release, .time]),
      ],[
        (keys[0], nil),
        (keys[1], [.key, .decay]),
        (keys[2], [.key, .slop]),
        (keys[3], nil),
      ],[
        (velos[0], nil),
        (velos[1], [.velo, .decay]),
        (velos[2], [.velo, .slop]),
        (velos[3], [.velo, .release]),
      ]])
      
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([[("switch", 1), ("ctrl", 4)]], pinMargin: "", spacing: "-s1-")
      
      let env = self.env
      addPatchChangeBlock(path: [.start, .level]) {
        env.startLevel = CGFloat($0) / 99
      }
      let pres: [SynthPathItem] = [.attack, .decay, .sustain, .release]
      pres.enumerated().forEach { (offset, pre) in
        addPatchChangeBlock(path: [pre] + [.time]) {
          env.set(rate: CGFloat($0) / 99, forIndex: offset)
        }
        addPatchChangeBlock(path: [pre] + [.level]) {
          env.set(level: CGFloat($0) / 99, forIndex: offset)
        }
      }
      
      func setupKnob(_ knob: PBKnob, _ pLabel: String, oLabel: String, _ pPath: SynthPath, _ oPath: SynthPath) {
        addParamChangeBlock { params in
          let isPitch = params.prefix == [.pitch, .env]
          knob.label = isPitch ? pLabel : oLabel
          knob.minimumValue = -99
          knob.maximumValue = 99
        }
        addPatchChangeBlock { changes in
          let isPitch = changes.prefix == [.pitch, .env]
          guard let value = Self.updatedValue(path: isPitch ? pPath : oPath, state: changes) else { return }
          knob.value = value
        }
        addControlChangeBlock(control: knob) { [weak self] in
          let isPitch = self?.prefix == [.pitch, .env]
          return .paramsChange([isPitch ? pPath : oPath : knob.value])
        }
      }
      setupKnob(keys[0], "Key→Time", oLabel: "Key Trk↑", [.key, .time], [.key, .attack])
      setupKnob(velos[0], "Velo→Time", oLabel: "Velo↑", [.velo, .time], [.velo, .attack])
      setupKnob(keys[3], "Key→Level", oLabel: "Key Trk↑", [.key, .level], [.key, .release])
      
      registerForEditMenu(env, bundle: (
        paths: { [weak self] in
          var paths: [SynthPath] = [
            [.attack, .time], [.decay, .time], [.sustain, .time], [.release, .time],
            [.start, .level],
            [.attack, .level], [.decay, .level],
          ]
          switch self?.prefix ?? [] {
          case [.amp, .env]:
            paths += [[.sustain, .level], []]
          case [.pitch, .env]:
            paths += [[], [.release, .level]]
          default:
            paths += [[.sustain, .level], [.release, .level]]
          }
          return paths
        },
        pasteboardType: "com.cfsphd.ProphecyEnv",
        initialize: { [weak self] in
          if self?.prefix == [.pitch, .env] {
            return [10, 10, 10, 10, 0, 0, 0, 0, 0]
          }
          else {
            return [20, 20, 20, 20, 99, 99, 99, 99, 0]
          }
        },
        randomize: { [weak self] in
          let isAmp = self?.prefix == [.amp, .env]
          return (0..<4).map { _ in (0...99).random()! } +
            (0..<5).map { _ in (isAmp ? (0...99) : (-99...99)).random()! }
        }
      ))
      
      addColor(panels: ["ctrl"], level: 3)
      addColor(panels: ["switch"], level: 3, clearBackground: true)
      addBorder(view: view, level: 3)
    }
    
    private func updateIndex() {
      let label: String
      switch index {
      case 0...3:
        label = "Env \(index + 1)"
      case 4:
        label = "Amp EG"
      default:
        label = "Pitch EG"
      }
      env.label = label
            
      // Amp env
      let isAmp = index == 4
      rLevel.isHidden = isAmp
      let levels = [aLevel, dLevel, sLevel, rLevel]
      levels.forEach { $0.minimumValue = isAmp ? 0 : -99 }
      env.bipolar = !isAmp
      if isAmp {
        env.set(level: 0, forIndex: 3)
      }
      
      // Pitch Env
      let isPitch = index == 5
      sLevel.isHidden = isPitch
      keys[1..<3].forEach { $0.isHidden = isPitch }
      velos[1..<4].forEach { $0.isHidden = isPitch }
      if isPitch {
        env.set(level: 0, forIndex: 2)
      }
    }
  }
}
