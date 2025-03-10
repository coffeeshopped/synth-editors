
class TG33VoiceController : NewPagedEditorController {
  
  private let commonController = TG33VoiceCommonController()
  private let elementsController = TG33VoiceElementsController()
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch","config"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch", 4), ("config", 12),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([
      ("page", 1),
      ], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1), ("page", 8),
      ], pinned: true, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["config","page"], attribute: .trailing)
    
    switchCtrl = PBSegmentedControl(items: ["A/B","C/D","Common"])
    quickGrid(panel: "switch", items: [[(switchCtrl, nil, "switchCtrl")]])
    
    let volC = PBInvertedKnob(label: "C")
    let volD = PBInvertedKnob(label: "D")
    let panC = PBSwitch(label: "C")
    let panD = PBSwitch(label: "D")
    let cdCtrls = [volC, volD, panC, panD]
    
    quickGrid(panel: "config", items: [[
      (PBSwitch(label: "Config"), [.common, .structure], nil),
      (PBInvertedKnob(label: "Level A"), [.element, .i(0), .volume], nil),
      (PBInvertedKnob(label: "B"), [.element, .i(1), .volume], nil),
      (volC, [.element, .i(2), .volume], nil),
      (volD, [.element, .i(3), .volume], nil),
      (PBSwitch(label: "Pan A"), [.element, .i(0), .pan], nil),
      (PBSwitch(label: "B"), [.element, .i(1), .pan], nil),
      (panC, [.element, .i(2), .pan], nil),
      (panD, [.element, .i(3), .pan], nil),
      ]])
    
    addPatchChangeBlock(path: [.common, .structure]) { value in
      cdCtrls.forEach { $0.alpha = value == 0 ? 0.4 : 1 }
    }
    
    addColor(panels: ["config"])
    addColor(panels: ["switch"], clearBackground: true)
  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 2:
      return commonController
    default:
      elementsController.index = index
      return elementsController
    }
  }
}

class TG33VoiceCommonController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["fx","bend","bias","env"])
    addChild(TG33VoiceVectorController(), withPanel: "vector")
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("fx", 3.5), ("bend", 6), ("bias", 1), ("env", 3),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("vector", 1),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([
      ("fx",1), ("vector", 7),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["env","vector"], attribute: .trailing)
    
    quickGrid(panel: "fx", items: [[
      (PBSelect(label: "Effect"), [.common, .fx, .type], nil),
      (PBKnob(label: "Balance"), [.common, .fx, .balance], nil),
      (PBKnob(label: "Send"), [.common, .fx, .send], nil),
      ]])
    
    quickGrid(panel: "bend", items: [[
      (PBKnob(label: "Bend"), [.common, .bend], nil),
      (PBCheckbox(label: "AfterT Level"), [.common, .aftertouch, .level, .mod], nil),
      (PBCheckbox(label: "AfterT PM"), [.common, .aftertouch, .pitch, .mod], nil),
      (PBCheckbox(label: "AfterT AM"), [.common, .aftertouch, .amp, .mod], nil),
      (PBCheckbox(label: "ModW PM"), [.common, .modWheel, .pitch, .mod], nil),
      (PBCheckbox(label: "ModW AM"), [.common, .modWheel, .amp, .mod], nil),
      ]])
    
    quickGrid(panel: "bias", items: [[
      (PBKnob(label: "Pitch Bias"), [.common, .pitch, .bias], nil),
      ]])
    
    quickGrid(panel: "env", items: [[
      (PBKnob(label: "Env Delay"), [.common, .env, .delay], nil),
      (PBKnob(label: "Attack"), [.common, .env, .attack], nil),
      (PBKnob(label: "Release"), [.common, .env, .release], nil),
      ]])
    
    addColor(panels: ["fx","bend","bias","env"])
  }
  
}

class TG33VoiceVectorController : NewPatchEditorController {

  private let stepsController = StepsController()
  
  override var prefix: SynthPath? { return [.vector] }
  
  override var index: Int {
    didSet { stepsController.index = index }
  }
  
  override func loadView(_ view: PBView) {
    addChild(stepsController, withPanel: "steps")
    createPanels(forKeys: ["switch","speed","space"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch", 5), ("speed", 4), ("space", 7),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("steps", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1), ("steps", 6),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    
    let segmentedControl = LabeledSegmentedControl(label: "Vector Steps", items: ["1-17","18-34","35-50"])
    switchCtrl = segmentedControl.segmentedControl
    quickGrid(panel: "switch", items: [[(segmentedControl, nil, "switchCtrl")]])
    
    quickGrid(panel: "speed", items: [[
      (PBSelect(label: "Level Speed"), [.level, .speed], nil),
      (PBSelect(label: "Detune Speed"), [.detune, .speed], nil),
      ]])
    
    addColor(panels: ["speed"])
    addColor(panels: ["switch", "space"], clearBackground: true)
    addBorder(view: view)
  }
    
  
  class StepsController : NewPatchEditorController {
    
    private func quickGrid(panel: String, label: String, path: SynthPath) {
      let items: [(PBView,SynthPath?,String?)] = (0..<17).map { step in
        let label: String = step == 0 ? label : "\(step + 1)"
        let stepPath: SynthPath = path + [.i(step)]
        let knob = PBKnob(label: label)
        addDefaultParamChangeBlock(control: knob, path: stepPath) { [weak self] in
          guard let index = self?.index,
                step > 0 else { return }
          let newIndex = step + (index * 17)
          knob.isHidden = newIndex >= 50
          knob.label = "\(newIndex + 1)"
        }
        addPatchChangeBlock { [weak self] (changes) in
          guard let index = self?.index,
                let value = Self.updatedValue(path: path + [.i(step + (index * 17))], state: changes) else { return }
          knob.value = value
        }
        addControlChangeBlock(control: knob) { [weak self] in
          guard let index = self?.index else { return nil }
          return .paramsChange([path + [.i(step + (index * 17))]: knob.value])
        }
        return (knob, nil, "\(panel)\(step)")
      }
      quickGrid(panel: panel, items: [items])
    }
    
    override func loadView(_ view: PBView) {
      createPanels(forKeys: ["levelT","levelX","levelY","detuneT","detuneX","detuneY"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("levelT", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("levelX", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("levelY", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("detuneT", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("detuneX", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("detuneY", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([
        ("levelT", 1), ("levelX", 1), ("levelY", 1), ("detuneT", 1), ("detuneX", 1), ("detuneY", 1),
        ], pinned: true, pinMargin: "", spacing: "-s1-")

      quickGrid(panel: "levelT", label: "Level Time", path: [.level, .time])
      quickGrid(panel: "levelX", label: "Level X", path: [.level, .x])
      quickGrid(panel: "levelY", label: "Level Y", path: [.level, .y])
      quickGrid(panel: "detuneT", label: "Detune Time", path: [.detune, .time])
      quickGrid(panel: "detuneX", label: "Detune X", path: [.detune, .time])
      quickGrid(panel: "detuneY", label: "Detune Y", path: [.detune, .time])
      
      addColorToAll()
    }
  }
  
}

class TG33VoiceElementsController : NewPatchEditorController {
  
  override var index: Int {
    didSet {
      let hi = index > 0
      pcm.index = hi ? 2 : 0
      fm.index = hi ? 3 : 1
    }
  }
  
  private let pcm = TG33VoicePCMElementController()
  private let fm = TG33VoiceFMElementController()
  
  override func loadView(_ view: PBView) {
    addChild(pcm, withPanel: "pcm")
    addChild(fm, withPanel: "fm")
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("pcm", 1),("fm",2)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("pcm",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    
    addPatchChangeBlock(path: [.common, .structure]) { [weak self] in
      let hi = (self?.index ?? 0) > 0
      let alpha: CGFloat = $0 == 0 && hi ? 0.4 : 1
      self?.fm.view.alpha = alpha
      self?.pcm.view.alpha = alpha
    }
  }
  
}

class TG33VoiceElementController : NewPatchEditorController {
  
  private let letters = ["A","B","C","D"]
  
  override var index: Int {
    didSet {
      menuButton.setTitleKeepingColor("Element \(letters[index])")
    }
  }

  override var prefix: SynthPath? { return [.element, .i(index)] }
  
  fileprivate let menuButton = createMenuButton(titled: "Element")
    
  func setupEnv(envCtrl: PBRateLevelEnvelopeControl, pre: SynthPath) {
    addPatchChangeBlock(path: pre + [.attack, .rate]) { envCtrl.set(rate: 1 - CGFloat($0) / 63, forIndex: 0) }
    addPatchChangeBlock(path: pre + [.decay, .i(0), .rate]) { envCtrl.set(rate: 1 - CGFloat($0) / 63, forIndex: 1) }
    addPatchChangeBlock(path: pre + [.decay, .i(1), .rate]) { envCtrl.set(rate: 1 - CGFloat($0) / 63, forIndex: 2) }
    addPatchChangeBlock(path: pre + [.release, .rate]) { envCtrl.set(rate: 1 - CGFloat($0) / 63, forIndex: 3) }
    addPatchChangeBlock(path: pre + [.innit, .level]) { envCtrl.startLevel = 1 - CGFloat($0) / 127 }
    addPatchChangeBlock(path: pre + [.attack, .level]) { envCtrl.set(level: 1 - CGFloat($0) / 127, forIndex: 0) }
    addPatchChangeBlock(path: pre + [.decay, .i(0), .level]) { envCtrl.set(level: 1 - CGFloat($0) / 127, forIndex: 1) }
    addPatchChangeBlock(path: pre + [.decay, .i(1), .level]) { envCtrl.set(level: 1 - CGFloat($0) / 127, forIndex: 2) }
    
    registerForEditMenu(envCtrl, bundle: (
      paths: {[
        pre + [.attack, .rate],
        pre + [.decay, .i(0), .rate],
        pre + [.decay, .i(1), .rate],
        pre + [.release, .rate],
        pre + [.innit, .level],
        pre + [.attack, .level],
        pre + [.decay, .i(0), .level],
        pre + [.decay, .i(1), .level]
      ]},
      pasteboardType: "com.cfshpd.TG33Envelope",
      initialize: nil,
      randomize: nil // TODO
    ))
  }
    
}

class TG33VoicePCMElementController : TG33VoiceElementController {
  
  private let envCtrl = PBRateLevelEnvelopeControl()

  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["label","wave","after","lfo","env"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("label",2), ("wave", 2.5),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("after",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([("lfo",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([("env",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([
      ("label",1), ("after", 1), ("lfo", 2), ("env", 4),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    
    quickGrid(panel: "label", items: [[(menuButton, nil, "button")]])
    
    quickGrid(panel: "wave", items: [[
      (PBSelect(label: "Wave Type"), [.wave], nil),
      (PBKnob(label: "Freq Shift"), [.note, .shift], nil),
      ]])
    
    quickGrid(panel: "after", items: [[
      (PBKnob(label: "Aftertouch"), [.aftertouch], nil),
      (PBKnob(label: "Velo"), [.velo], nil),
      (PBKnob(label: "Scale"), [.scale], nil),
      (PBKnob(label: "Detune"), [.detune], nil),
      ]])
    
    quickGrid(panel: "lfo", items: [[
      (PBSelect(label: "LFO"), [.lfo], nil),
      (PBKnob(label: "Speed"), [.lfo, .speed], nil),
      (PBKnob(label: "Delay"), [.lfo, .delay], nil),
      (PBInvertedKnob(label: "Rate"), [.lfo, .rate], nil),
      ],[
      (PBCheckbox(label: "AM"), [.lfo, .amp, .mod, .on], nil),
      (PBKnob(label: "AM Depth"), [.lfo, .amp, .mod], nil),
      (PBCheckbox(label: "PM"), [.lfo, .pitch, .mod, .on], nil),
      (PBKnob(label: "PM Depth"), [.lfo, .pitch, .mod], nil),
      ]])
        
    let levelScale = PBImageSelect(label: "Level Scale")
    let rateScale = PBImageSelect(label: "Rate Scale")
    quickGrid(panel: "env", items: [[
      (PBSelect(label: "Env Type"), [.env], nil),
      (levelScale, nil, "levScale"),
      (rateScale, nil, "rateScale"),
      ],[
      (PBCheckbox(label: "Delay"), [.env, .delay], nil),
      (PBKnob(label: "Attack R"), [.env, .attack, .rate], nil),
      (PBKnob(label: "D1 R"), [.env, .decay, .i(0), .rate], nil),
      (PBKnob(label: "D2 R"), [.env, .decay, .i(1), .rate], nil),
      (PBKnob(label: "Release"), [.env, .release, .rate], nil),
      ],[
      (PBInvertedKnob(label: "Init L"), [.env, .innit, .level], nil),
      (PBInvertedKnob(label: "Attack L"), [.env, .attack, .level], nil),
      (PBInvertedKnob(label: "D1 L"), [.env, .decay, .i(0), .level], nil),
      (PBInvertedKnob(label: "D2 L"), [.env, .decay, .i(1), .level], nil),
      ],[
      (envCtrl, nil, "envCtrl")
      ]])

    addBlocks(control: levelScale, path: [.env, .level, .scale]) {
      levelScale.options = TG33VoicePatch.levelScalingImageOptions
    }
    addBlocks(control: rateScale, path: [.env, .rate, .scale]) {
      rateScale.options = TG33VoicePatch.rateScalingImageOptions
    }

    setupEnv(envCtrl: envCtrl, pre: [.env])
    
    registerForEditMenu(menuButton, bundle: (
      paths: { Self.AllPaths },
      pasteboardType: "com.cfshpd.TG33PCMElement",
      initialize: nil,
      randomize: { [] }
    ))
    
    addColorToAll(except: ["label"], level: 2)
    addColor(panels: ["label"], level: 2, clearBackground: true)
    addBorder(view: view, level: 2)

  }
  
  static let AllPaths: [SynthPath] = TG33VoicePatch.paramKeys().compactMap {
    guard $0.starts(with: [.element, .i(0)]) else { return nil }
    return $0.subpath(from: 2)
  }
  
  override func randomize(_ sender: Any?) {
    var changes = [SynthPath:Int]()
    TG33VoicePatch.params.forEach {
      guard $0.key.starts(with: [.element, .i(0)]) else { return }
      changes[$0.key.subpath(from: 2)] = $0.value.randomize()
    }
    pushPatchChange(MakeParamsChange(changes))
  }
  
}

class TG33VoiceFMElementController : TG33VoiceElementController {
      
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["label","wave","fm","lfo","mWave","mEnv","cWave","cEnv"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("label",2), ("wave", 5.5), ("fm", 2),
      ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([
      ("mWave",1), ("cWave", 1),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("mEnv",1), ("cEnv", 1),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([
      ("label",1), ("lfo", 1), ("mWave",2), ("mEnv",4),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["label","wave"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["lfo","fm"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["wave","lfo"], attribute: .trailing)

    quickGrid(panel: "label", items: [[(menuButton, nil, "button")]])
    
    quickGrid(panel: "wave", items: [[
      (PBSelect(label: "Wave Type"), [.wave], nil),
      (PBKnob(label: "Freq Shift"), [.note, .shift], nil),
      (PBKnob(label: "Aftertouch"), [.aftertouch], nil),
      (PBKnob(label: "Velo"), [.velo], nil),
      ]])

    quickGrid(panel: "fm", items: [[
      (PBKnob(label: "Feedback"), [.feedback], nil),
      (PBInvertedKnob(label: "Tone Level"), [.tone, .level], nil),
      ],[
      (PBSwitch(label: "Op Mode"), [.algo], nil),
      ]])

    quickGrid(panel: "lfo", items: [[
      (PBSelect(label: "LFO"), [.lfo], nil),
      (PBKnob(label: "Speed"), [.lfo, .speed], nil),
      (PBKnob(label: "Delay"), [.lfo, .delay], nil),
      (PBInvertedKnob(label: "Rate"), [.lfo, .rate], nil),
      (PBKnob(label: "AM"), [.lfo, .amp, .mod], nil),
      (PBKnob(label: "PM"), [.lfo, .pitch, .mod], nil),
      ]])

    quickGrid(panel: "mWave", items: [[
      (PBSelect(label: "Mod Wave"), [.mod, .wave, .type], nil),
      (PBKnob(label: "Mult"), [.mod, .ratio], nil),
      (PBKnob(label: "Detune"), [.mod, .detune], nil),
      (PBCheckbox(label: "Fixed"), [.mod, .fixed], nil),
      ],[
      (PBKnob(label: "Scale"), [.mod, .scale], nil),
      (PBCheckbox(label: "Amp Mod"), [.mod, .amp, .mod], nil),
      (PBCheckbox(label: "Pitch Mod"), [.mod, .pitch, .mod], nil),
      ]])
    
    let mEnvCtrl = PBRateLevelEnvelopeControl(label: "Mod Env")
    let mLevelScale = PBImageSelect(label: "Level Scale")
    let mRateScale = PBImageSelect(label: "Rate Scale")

    quickGrid(panel: "mEnv", items: [[
      (LabelItem(text: "Mod Env", gridWidth: 2), nil, "mEnvLabel"),
      (mLevelScale, nil, "mLev"),
      (mRateScale, nil, "mRate"),
      ],[
      (PBCheckbox(label: "Delay"), [.mod, .env, .delay], nil),
      (PBKnob(label: "Attack R"), [.mod, .env, .attack, .rate], nil),
      (PBKnob(label: "D1 R"), [.mod, .env, .decay, .i(0), .rate], nil),
      (PBKnob(label: "D2 R"), [.mod, .env, .decay, .i(1), .rate], nil),
      (PBKnob(label: "Release"), [.mod, .env, .release, .rate], nil),
      ],[
      (PBInvertedKnob(label: "Init L"), [.mod, .env, .innit, .level], nil),
      (PBInvertedKnob(label: "Attack L"), [.mod, .env, .attack, .level], nil),
      (PBInvertedKnob(label: "D1 L"), [.mod, .env, .decay, .i(0), .level], nil),
      (PBInvertedKnob(label: "D2 L"), [.mod, .env, .decay, .i(1), .level], nil),
      ],[
      (mEnvCtrl, nil, "modEnvCtrl"),
      ]])

    quickGrid(panel: "cWave", items: [[
      (PBSelect(label: "Carrier Wave"), [.wave, .type], nil),
      (PBKnob(label: "Mult"), [.ratio], nil),
      (PBKnob(label: "Detune"), [.detune], nil),
      (PBCheckbox(label: "Fixed"), [.fixed], nil),
      ],[
      (PBKnob(label: "Scale"), [.scale], nil),
      (PBCheckbox(label: "Amp Mod"), [.amp, .mod], nil),
      (PBCheckbox(label: "Pitch Mod"), [.pitch, .mod], nil),
      ]])
    
    let levelScale = PBImageSelect(label: "Level Scale")
    let rateScale = PBImageSelect(label: "Rate Scale")
    let cEnvCtrl = PBRateLevelEnvelopeControl(label: "Carrier Env")
    quickGrid(panel: "cEnv", items: [[
      (PBSelect(label: "Env Type"), [.env], nil),
      (levelScale, nil, "levScale"),
      (rateScale, nil, "rateScale"),
      ],[
      (PBCheckbox(label: "Delay"), [.env, .delay], nil),
      (PBKnob(label: "Attack R"), [.env, .attack, .rate], nil),
      (PBKnob(label: "D1 R"), [.env, .decay, .i(0), .rate], nil),
      (PBKnob(label: "D2 R"), [.env, .decay, .i(1), .rate], nil),
      (PBKnob(label: "Release"), [.env, .release, .rate], nil),
      ],[
      (PBInvertedKnob(label: "Init L"), [.env, .innit, .level], nil),
      (PBInvertedKnob(label: "Attack L"), [.env, .attack, .level], nil),
      (PBInvertedKnob(label: "D1 L"), [.env, .decay, .i(0), .level], nil),
      (PBInvertedKnob(label: "D2 L"), [.env, .decay, .i(1), .level], nil),
      ],[
      (cEnvCtrl, nil, "carrierEnvCtrl"),
      ]])
    
    addBlocks(control: levelScale, path: [.env, .level, .scale]) {
      levelScale.options = TG33VoicePatch.levelScalingImageOptions
    }
    addBlocks(control: rateScale, path: [.env, .rate, .scale]) {
      rateScale.options = TG33VoicePatch.rateScalingImageOptions
    }
    addBlocks(control: mLevelScale, path: [.mod, .env, .level, .scale]) {
      mLevelScale.options = TG33VoicePatch.levelScalingImageOptions
    }
    addBlocks(control: mRateScale, path: [.mod, .env, .rate, .scale]) {
      mRateScale.options = TG33VoicePatch.rateScalingImageOptions
    }

    setupEnv(envCtrl: mEnvCtrl, pre: [.mod, .env])
    setupEnv(envCtrl: cEnvCtrl, pre: [.env])
    
    registerForEditMenu(menuButton, bundle: (
      paths: { Self.AllPaths },
      pasteboardType: "com.cfshpd.TG33FMElement",
      initialize: nil,
      randomize: { [] }
    ))
    
    addColorToAll(except: ["label"], level: 2)
    addColor(panels: ["label"], level: 2, clearBackground: true)
    addBorder(view: view, level: 2)

  }
    
  static let AllPaths: [SynthPath] = TG33VoicePatch.paramKeys().compactMap {
    guard $0.starts(with: [.element, .i(1)]) else { return nil }
    return $0.subpath(from: 2)
  }
  
  override func randomize(_ sender: Any?) {
    var changes = [SynthPath:Int]()
    TG33VoicePatch.params.forEach {
      guard $0.key.starts(with: [.element, .i(1)]) else { return }
      changes[$0.key.subpath(from: 2)] = $0.value.randomize()
    }
    pushPatchChange(MakeParamsChange(changes))
  }

}
