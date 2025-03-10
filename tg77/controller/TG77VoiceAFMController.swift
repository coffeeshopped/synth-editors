
class TG77VoiceAFMController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.element, .i(index), .fm] }
  
  override func loadView(_ view: PBView) {
    let innerController = TG77VoiceAFMInnerController()
    addChild(innerController)
    view.fill(withSubview: innerController.view)
  }
      
}

class TG77VoiceAFMInnerController : NewPagedEditorController {
  
  private let opsController = OpsController()
  private let otherController = OtherController()
  
  private let feedbacks: [PBSelect] = (0..<3).map { PBSelect(label: "FB\($0+1)") }

  private var opRouteControllers: [OpRouteController]!
  
  override func loadView(_ view: PBView) {
    addChild(AlgoController(), withPanel: "algo")

    switchCtrl = PBSegmentedControl(items: ["1/2", "3/4", "5/6", "Other"])
    grid(panel: "switch", items: [[(switchCtrl, nil)]])

    opRouteControllers = addChildren(count: 6, panelPrefix: "op")
    
    grid(panel: "algo2", items: [[
      (PBImageSelect(label: "Algorithm", imageSize: CGSize(width: 120, height: 120), imageSpacing: 4), [.common, .algo]),
      ]])

    grid(panel: "fb", items: [[
      (feedbacks[0], nil),
      ],[
      (feedbacks[1], nil),
      ],[
      (feedbacks[2], nil),
      ]])

    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("algo", 5), ("algo2", 2.5), ("fb", 1.5), ("op0", 4), ("op1", 4)],
                             options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([("op2", 4), ("op3", 4)], pinned: false, spacing: "-s1-")
    layout.addRowConstraints([("op4", 4), ("op5", 4)], pinned: false, spacing: "-s1-")
    layout.addRowConstraints([("page", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("algo", 3), ("page", 5)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("algo2",2.5), ("switch", 1)], pinned: false, spacing: "-s1-")
    layout.addColumnConstraints([("op0",1), ("op2", 1), ("op4", 1)], pinned: false, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["algo2","fb"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["op0","op1"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["op1","op3","op5"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["algo","switch", "op4"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["fb","switch"], attribute: .trailing)

    addPatchChangeBlock(path: [.common, .algo]) { [weak self] in
      guard $0 < TG77Algorithms.all.count else { return }
      self?.algorithm = TG77Algorithms.all[$0]
    }
    
    addPatchChangeBlock { [weak self] (changes) in
      guard let values = self?.updatedValues(paths: 6.map { [.op, .i($0), .dest] }, changes: changes) else { return }
      (0..<6).forEach {
        guard let dest = values[[.op, .i($0), .dest]],
              dest > 0 else { return }
        self?.feedbackSrc[dest - 1] = $0
        self?.inSrcOptions[5 + dest] = "Op\($0 + 1)"
        self?.feedbacks[dest - 1].value = $0
      }
      
      self?.updateFeedbackOptions()
      self?.updateInOptions()
    }
    
    feedbacks.forEach {
      addControlChangeBlock(control: $0) { [unowned self] in
        // compute the FB dest index for each op. It will be 0 if the op is not a FB dest. 1,2,3 if it is.
        // we could do this more efficiently (only send the op dests that changed, instead of all 6
        // but right now this triggers a full patch send anyway. if in the future we properly throttle
        // multiple param changes, we can change this.
        self.feedbackSourcesPatchChange()
      }
    }

    addColor(panels: ["fb", "op0", "op1", "op2", "op3", "op4", "op5", "algo2"], level: 2)
    addColor(panels: ["switch"], level: 3, clearBackground: true)
  }
  
  private func feedbackSourcesPatchChange() -> PatchChange {
    let dict: [SynthPath:Int] = (0..<6).dictionary { op in
      let dest = (feedbacks.enumerated().first(where: {$0.element.value == op})?.offset ?? -1) + 1
      return [[.op, .i(op), .dest] : dest]
    }
    return MakeParamsChange(dict)
  }
  
  private func updateInOptions() {
    opRouteControllers.forEach {
      $0.updateInOptions(algorithm: algorithm, feedbackSrc: feedbackSrc, inSrcOptions: inSrcOptions)
    }
  }
  
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 3:
      return otherController
    default:
      opsController.index = index
      return opsController
    }
  }
  
//    guard let colorGuide = firstColorGuide else { return }
//    colorPanel(panels["algo"]!,
//               background: .clear,
//               label: colorGuide.tints[2][4],
//               value: colorGuide.colors[2],
//               valueBackground: colorGuide.shades[2][4]
//    )
  
  private var feedbackSrc = [-1,-1,-1]
  private var inSrcOptions = TG77VoicePatch.inSrcOptions
  private var algorithm: DXAlgorithm = TG77Algorithms.all[0] {
    didSet {
      updateFeedbackOptions()
      updateInOptions()
    }
  }
      
  /// Update the 3 Feedback Src Selects
  private func updateFeedbackOptions() {
    feedbacks.enumerated().forEach { (fbIndex, fbCtrl) in
      if algorithm.feedbackSrcOps.contains(fbCtrl.value) {
        fbCtrl.isEnabled = false
        fbCtrl.options = [fbCtrl.value : "Op\(fbCtrl.value+1)"]
      }
      else {
        var options = [Int:String]()
        (0..<6).forEach { op in
          if !feedbackSrc.contains(op) || feedbackSrc[fbIndex] == op {
            options[op] = "Op\(op + 1)"
          }
        }
        fbCtrl.isEnabled = true
        fbCtrl.options = options
      }
    }
  }
  
  
  class OpRouteController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.op, .i(index)] }
    
    override var index: Int {
      didSet { (0..<2).forEach { opIns[$0].label = "Op\(index + 1) In\($0 + 1)" } }
    }
    
    private let opIns: [PBSelect] = (0..<2).map { _ in PBSelect() }
    private let levels: [PBKnob] = (0..<2).map { _ in PBKnob(label: "Level") }

    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (opIns[0], nil),
        (levels[0], [.src, .i(0), .shift]),
        (opIns[1], nil),
        (levels[1], [.src, .i(1), .shift]),
        ]])
      
      (0..<2).forEach { i in
        let opIn = opIns[i]
        let level = levels[i]
        addPatchChangeBlock(path: [.src, .i(i)]) { level.isHidden = $0 == 0 }

        addPatchChangeBlock(path: [.src, .i(i)]) { opIn.value = [1,3,4,5,9].contains($0) ? 1 : $0 }
        addDefaultControlChangeBlock(control: opIn, path: [.src, .i(i)])
      }
    }
    
    fileprivate func updateInOptions(algorithm: DXAlgorithm, feedbackSrc: [Int], inSrcOptions: [Int:String]) {
      (0..<2).forEach { inlet in
        let opIn = opIns[inlet]
        let level = levels[inlet]
        let value = latestValue(path: [.src, .i(inlet)]) ?? 0
        if [1,3,4,5,9].contains(value) {
          // Hard-coded value from algorithm
          opIn.isEnabled = false
          let dxop = algorithm.ops[index]
          let inOp = dxop.input(inlet) ?? -1
          opIn.options = inlet == 1 && dxop.input(2) != nil ? [1 : "OpA"] : [1 : "Op\(inOp + 1)"]
          level.isHidden = false
        }
        else if [6,7,8].contains(value) {
          // see if fb op is hard-coded
          let op = feedbackSrc[value - 6]
          let isHardCoded = algorithm.feedbackSrcOps.contains(op)
          opIn.isEnabled = !isHardCoded
          opIn.options = isHardCoded ? [value : "Op\(op+1)"] : inSrcOptions
          level.isHidden = false
        }
        else {
          // Off, AWM, or Noise
          opIn.isEnabled = true
          opIn.options = inSrcOptions
          level.isHidden = value == 0
        }
      }
    }

  }
  
  class AlgoController : NewPatchEditorController {
    
    let algoCtrl = TG77AlgorithmControl(label: "")
    
    override func loadView(_ view: PBView) {
      algoCtrl.algorithms = TG77VoicePatch.algorithms()
      
      grid(view: view, pinMargin: "", items: [[(algoCtrl, nil)]])
      
      let algoCtrl = self.algoCtrl
      let _: [TG77MiniOpController] = addChildren(count: 6, panelPrefix: "op") {
        $0.view.cornerRadius = 3
        algoCtrl.addOpContainer($0.view)
      }
      
      algoCtrl.value = 0
      addPatchChangeBlock(path: [.common, .algo]) { algoCtrl.value = $0 }
      (0..<6).forEach { op in
        addPatchChangeBlock(path: [.op, .i(op), .dest]) {
          guard $0 > 0 else { return }
          algoCtrl.set(feedbackSrc: $0 - 1, op: op)
        }
        (0..<2).forEach { i in
          addPatchChangeBlock(path: [.op, .i(op), .src, .i(i)]) {
            algoCtrl.set(op: op, input: i, src: $0)
          }
          addPatchChangeBlock(path: [.op, .i(op), .src, .i(i), .shift]) {
            algoCtrl.set(level: $0, forOp: op, input: i)
          }
        }
      }
      
      addColorBlock { [weak self] in
        self?.algoCtrl.valueColor = Self.tintColor(forColorGuide: $0, level: 2)
      }
    }
    
  }
  
  

  
  class OpsController : NewPatchEditorController {
    
    override var index: Int {
      didSet {
        opControllers?.enumerated().forEach { $0.element.index = index * 2 + $0.offset }
      }
    }
    
    private var opControllers: [OpController]!
    
    override func loadView(_ view: PBView) {
      opControllers = addChildren(count: 2, panelPrefix: "op")
      addPanelsToLayout(andView: view)
      layout.addRowConstraints([("op0",1), ("op1",1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("op0",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    }
    
    func selectOp(_ index: Int) {
      #if os(iOS)
      let opView = opControllers[index % 2].view!
      #else
      let opView = opControllers[index % 2].view
      #endif
      
      #if os(iOS)
      opView.superview?.bringSubviewToFront(opView)

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        PBView.animate(withDuration: 0.2, animations: {
          opView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
          PBView.animate(withDuration: 0.2) { opView.transform = .identity }
        })
      }
      #endif
      
    }
  }
  
  class OpController : NewPatchEditorController {
    
    override var index: Int {
      didSet {
        level.label = "Op \(index + 1) Level"
        opOn.label = "Op \(index + 1)"
        opEnvController.env.label = "Op \(index + 1)"
      }
    }
    
    override var prefix: SynthPath? { return [.op, .i(index)] }
    private var storedLevel: Int = 0
    private let level = PBKnob(label: "Level")
    private let opOn = PBCheckbox(label: "")


    private let opEnvController = TG77MiniOpController.EnvController()

    override func loadView(_ view: PBView) {
      addChild(opEnvController)
      createPanels(forKeys: ["env", "ratio" , "bp"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("env", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("ratio", 4), ("bp", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("env", 3), ("ratio", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      let holdTime = PBKnob(label: "Hold Time")
      let oscMode = PBSwitch(label: "Osc Mode")

      grid(panel: "env", items: [[
        (level, [.level]),
        (PBKnob(label: "Velo"), [.velo]),
        (opEnvController.view, nil),
        (PBKnob(label: "Loop Pt"), [.loop, .pt]),
        (PBKnob(label: "Rate Scale"), [.rate, .scale]),
        (PBImageSelect(label: "Wave", imageSize: CGSize(width: 55, height: 47.5), imageSpacing: 12), [.wave]),
        (opOn, nil),
        ],[
        (PBKnob(label: "L0"), [.level, .i(-1)]),
        (PBKnob(label: "L1"), [.level, .i(0)]),
        (PBKnob(label: "L2"), [.level, .i(1)]),
        (PBKnob(label: "L3"), [.level, .i(2)]),
        (PBKnob(label: "L4"), [.level, .i(3)]),
        (PBKnob(label: "RL1"), [.release, .level, .i(0)]),
        (PBKnob(label: "RL2"), [.release, .level, .i(1)]),
        (PBKnob(label: "Amp Mod"), [.amp, .mod]),
        ],[
        (holdTime, nil),
        (PBKnob(label: "R1"), [.rate, .i(0)]),
        (PBKnob(label: "R2"), [.rate, .i(1)]),
        (PBKnob(label: "R3"), [.rate, .i(2)]),
        (PBKnob(label: "R4"), [.rate, .i(3)]),
        (PBKnob(label: "RR1"), [.release, .rate, .i(0)]),
        (PBKnob(label: "RR2"), [.release, .rate, .i(1)]),
        (PBKnob(label: "Pitch Mod"), [.pitch, .mod]),
        ]])
      
      grid(panel: "ratio", items: [[
        (oscMode, [.osc, .mode]),
        (PBKnob(label: "Coarse"), [.coarse]),
        (PBKnob(label: "Fine"), [.fine]),
        (PBKnob(label: "Detune"), [.detune]),
        ],[
        (PBCheckbox(label: "Pitch Env"), [.pitch, .env]),
        (PBCheckbox(label: "Rate Velo"), [.rate, .velo]),
        (PBCheckbox(label: "Init Phase"), [.phase, .on]),
        (PBKnob(label: "Phase"), [.phase]),
        ]])

      grid(panel: "bp", items: [
        (0..<4).map { (PBKnob(label: "BP\($0+1)"), [.level, .scale, .pt, .i($0)]) },
        (0..<4).map { (PBKnob(label: "Offset \($0+1)"), [.level, .scale, .offset, .i($0)]) },
      ])
      
      addPatchChangeBlock(path: [.on]) { view.alpha = $0 == 1 ? 1 : 0.4 }
      
      addPatchChangeBlock(paths: [[.osc, .mode], [.coarse], [.fine]]) { values in
        guard let coarse = values[[.coarse]],
          let fine = values[[.fine]] else { return }
        let fixedMode = values[[.osc, .mode]] == 1
        oscMode.label = fixedMode ? "Freq (Hz)" : "Ratio"
        oscMode.options = OptionsParam.makeOptions([
          TG77VoicePatch.freqRatio(fixedMode: false, coarse: coarse, fine: fine),
          TG77VoicePatch.freqRatio(fixedMode: true, coarse: coarse, fine: fine)])
      }
      
      addPatchChangeBlock(path: [.hold, .time]) { holdTime.value = 63 - $0 }
      addDefaultControlChangeBlock(control: holdTime, path: [.hold, .time], valueBlock: { 63 - holdTime.value })
      holdTime.maximumValue = 63
      
      let opOn = self.opOn
      let level = self.level
      addPatchChangeBlock(path: [.level]) { opOn.checked = $0 > 0 }
      addControlChangeBlock(control: opOn) { [weak self] in
        let outLevel: Int
        if opOn.checked {
          outLevel = self?.storedLevel ?? 127
        }
        else {
          self?.storedLevel = level.value
          outLevel = 0
        }
        return .paramsChange([[.level] : outLevel])
      }
      
      registerForEditMenu(opEnvController.view, bundle: (
        paths: { [
          [.rate, .i(0)], [.rate, .i(1)], [.rate, .i(2)], [.rate, .i(3)],
          [.hold, .time],
          [.release, .rate, .i(0)], [.release, .rate, .i(1)],
          [.level, .i(0)], [.level, .i(1)], [.level, .i(2)], [.level, .i(3)],
          [.level, .i(-1)],
          [.release, .level, .i(0)], [.release, .level, .i(1)],
        ] },
        pasteboardType: "com.cfshpd.TG77OpEnv",
        initialize: nil,
        randomize: nil
      ))

      addColorToAll(level: 3)
      addBorder(view: view, level: 3)
    }
            
  }
  
  
  class OtherController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      addChild(PitchController(), withPanel: "pitch")
      addChild(TG77FiltersController(), withPanel: "filter")
      
      grid(panel: "lfo", items: [[
        (PBSelect(label: "Multi LFO"), [.common, .lfo, .i(0), .wave]),
        (PBKnob(label: "Speed"), [.common, .lfo, .i(0), .speed]),
        (PBKnob(label: "Delay"), [.common, .lfo, .i(0), .delay]),
        ],[
        (PBKnob(label: "Pitch"), [.common, .lfo, .i(0), .pitch]),
        (PBKnob(label: "Amp"), [.common, .lfo, .i(0), .amp]),
        (PBKnob(label: "Filter"), [.common, .lfo, .i(0), .filter]),
        (PBKnob(label: "Phase"), [.common, .lfo, .i(0), .phase]),
        ]])

      grid(panel: "lfo2", items: [[
        (PBSelect(label: "Sub LFO"), [.common, .lfo, .i(1), .wave]),
        (PBKnob(label: "Speed"), [.common, .lfo, .i(1), .speed]),
        (PBKnob(label: "Pitch"), [.common, .lfo, .i(1), .pitch]),
        ],[
        (PBSwitch(label: "Delay Mode"), [.common, .lfo, .i(1), .delay, .mode]),
        (PBKnob(label: "Delay Time"), [.common, .lfo, .i(1), .delay, .time]),
        ]])
      
      let menuButton = createMenuButton(titled: "AFM Element")
      grid(panel: "space2", items: [[(menuButton, nil)]])
      
      createPanels(forKeys: ["space1"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("pitch",5), ("lfo",4), ("filter",7)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("lfo",2), ("lfo2",2), ("space1",1)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("pitch", 3),("space2",2)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["filter","space1"], attribute: .bottom)
      
      registerForEditMenu(menuButton, bundle: (
        paths: { Self.AllPaths },
        pasteboardType: "com.cfshpd.TG77AFMElement",
        initialize: nil,
        randomize: nil
      ))
      
      addColor(panels: ["pitch", "lfo", "lfo2"])
      addColor(panels: ["space2"], clearBackground: true)

    }
    
    static let AllPaths: [SynthPath] = TG77VoicePatch.paramKeys().compactMap {
      guard $0.starts(with: [.element, .i(0), .fm]) else { return nil }
      return $0.subpath(from: 3)
    }
  }
  
  class PitchController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.common, .pitch] }
    
    override func loadView(_ view: PBView) {
      let envController = PitchEnvController()
      addChild(envController)

      grid(view: view, items: [[
        (envController.view, nil),
        (PBCheckbox(label: "Velo"), [.velo]),
        (PBSwitch(label: "Range"), [.env, .range]),
        (PBKnob(label: "Rate Scale"), [.rate, .scale]),
        ],[
        (PBKnob(label: "L0"), [.env, .level, .i(-1)]),
        (PBKnob(label: "L1"), [.env, .level, .i(0)]),
        (PBKnob(label: "L2"), [.env, .level, .i(1)]),
        (PBKnob(label: "L3"), [.env, .level, .i(2)]),
        (PBKnob(label: "RL"), [.env, .release, .level, .i(0)]),
        ],[
        (PBKnob(label: "R1"), [.env, .rate, .i(0)]),
        (PBKnob(label: "R2"), [.env, .rate, .i(1)]),
        (PBKnob(label: "R3"), [.env, .rate, .i(2)]),
        (PBKnob(label: "RR"), [.env, .release, .rate, .i(0)]),
        ]])
    }
  }
  
  class PitchEnvController : TG77VoiceAWMController.PitchEnvController {
    override var prefix: SynthPath? { return [.env] }
  }
}

class TG77FiltersController : NewPatchEditorController {
  
  private let filterController = TG77FilterController()
  
  override var index: Int {
    didSet { filterController.index = index }
  }
  
  override func loadView(_ view: PBView) {
    addChild(filterController, withPanel: "filter")
    
    let sw = LabeledSegmentedControl(label: "Filter", items: ["1","2"])
    switchCtrl = sw.segmentedControl
    grid(panel: "switch", items: [[(sw, nil)]])
    
    let menuButton = createMenuButton(titled: "Filter")
    grid(panel: "menu", items: [[(menuButton, nil)]])
    
    grid(panel: "common", items: [[
      (PBKnob(label: "Reson"), [.filter, .common, .reson]),
      (PBKnob(label: "Velo"), [.filter, .common, .velo]),
      (PBKnob(label: "Mod Sens"), [.filter, .common, .mod]),
      ]])
    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("filter",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([("switch", 2.5), ("menu", 1.5), ("common", 3)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("filter",4), ("switch",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    
    registerForEditMenu(menuButton, bundle: (
      paths: { [weak self] in
        let partialPrefix: SynthPath = [.filter, .i(self?.index ?? 0)]
        return Self.AllPaths.map { $0.prefixed(by: partialPrefix) }
      },
      pasteboardType: "com.cfshpd.TG77Filter",
      initialize: nil,
      randomize: nil
    ))

    addColor(panels: ["common"])
    addColor(panels: ["switch", "menu"], clearBackground: true)
    addBorder(view: view)
  }
    
  static let AllPaths: [SynthPath] = TG77VoicePatch.paramKeys().compactMap {
    guard $0.starts(with: [.element, .i(0), .fm, .filter, .i(0)]) else { return nil }
    return $0.subpath(from: 5)
  }
      
}

class TG77FilterController : NewPatchEditorController {
  
  override var index: Int {
    didSet { filter.label = "Filter \(index + 1)" }
  }
  
  override var prefix: SynthPath? { return [.filter, .i(index)] }

  let filter = PBSwitch(label: "Filter")

  override func loadView(_ view: PBView) {
    let envController = FilterEnvController()
    envController.env.wantsGridWidth = 6
    addChild(envController)

    let levels: [PBKnob] = [PBKnob(label: "L0"),
                            PBKnob(label: "L1"),
                            PBKnob(label: "L2"),
                            PBKnob(label: "L3"),
                            PBKnob(label: "L4"),
                            PBKnob(label: "RL1"),
                            PBKnob(label: "RL2")]
    let rates: [PBKnob] = [PBKnob(label: "Rate Scale"),
                           PBKnob(label: "R1"),
                           PBKnob(label: "R2"),
                           PBKnob(label: "R3"),
                           PBKnob(label: "R4"),
                           PBKnob(label: "RR1"),
                           PBKnob(label: "RR2")]

    grid(panel: "type", items: [[
      (filter, nil),
      (PBKnob(label: "Cutoff"), [.cutoff]),
      (PBSwitch(label: "Mode"), [.mode]),
      ],[
      (envController.view, nil),
      ]])

    grid(panel: "bp", items: [
      (0..<4).map { (PBKnob(label: "BP \($0 + 1)"), [.level, .scale, .pt, .i($0)]) },
      (0..<4).map { (PBKnob(label: "Offset \($0 + 1)"), [.level, .scale, .offset, .i($0)]) },
    ])
    
    grid(panel: "ratelevel", items: [[
      (levels[0], [.env, .level, .i(-1)]),
      (levels[1], [.env, .level, .i(0)]),
      (levels[2], [.env, .level, .i(1)]),
      (levels[3], [.env, .level, .i(2)]),
      (levels[4], [.env, .level, .i(3)]),
      (levels[5], [.env, .release, .level, .i(0)]),
      (levels[6], [.env, .release, .level, .i(1)]),
      ],[
      (rates[0], [.rate, .scale]),
      (rates[1], [.env, .rate, .i(0)]),
      (rates[2], [.env, .rate, .i(1)]),
      (rates[3], [.env, .rate, .i(2)]),
      (rates[4], [.env, .rate, .i(3)]),
      (rates[5], [.env, .release, .rate, .i(0)]),
      (rates[6], [.env, .release, .rate, .i(1)]),
      ]])
    
    addPanelsToLayout(andView: view)
    layout.addGridConstraints([
      (row: [("type", 3), ("bp", 4)], height: 2),
      (row: [("ratelevel", 1)], height: 2),
    ], pinMargin: "", spacing: "-s1-")
    
    let filter = self.filter
    addBlocks(control: filter, path: [.type], paramAfterBlock: { [weak self] in
      guard self?.index == 1 else { return }
      filter.options = OptionsParam.makeOptions(["Thru", "LPF"])
    }, patchChangeAssignBlock: nil, controlChangeValueBlock: nil)
    
    addPatchChangeBlock(path: [.mode]) {
      let alpha: CGFloat = $0 == 1 ? 0.4 : 1
      envController.view.alpha = alpha
      levels.forEach { $0.alpha = alpha }
      rates.forEach { $0.alpha = alpha }
    }
    addColorToAll()
  }


  class FilterEnvController : NewPatchEditorController, TG77EnvelopeController {
    let env = TG77EnvelopeControl(label: "Filter")
    
    override var prefix: SynthPath? { return [.env] }
    
    override func loadView() {
      env.pointCount = 4
      env.sustainPoint = 3
      env.releaseCount = 2
      env.bipolar = true
      self.view = env
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      addRateLevelBlocks()

      registerForEditMenu(env, bundle: (
        paths: { [
          [.rate, .i(0)], [.rate, .i(1)], [.rate, .i(2)], [.rate, .i(3)],
          [.release, .rate, .i(0)], [.release, .rate, .i(1)],
          [.level, .i(0)], [.level, .i(1)], [.level, .i(2)], [.level, .i(3)],
          [.level, .i(-1)],
          [.release, .level, .i(0)], [.release, .level, .i(1)],
        ] },
        pasteboardType: "com.cfshpd.TG77FilterEnv",
        initialize: nil,
        randomize: nil
      ))
    }
  }
}
