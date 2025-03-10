
class TG77VoiceController : NewPagedEditorController {
  
  private let commonController = TG77VoiceCommonController()
  private let afmController = TG77VoiceAFMController()
  private let awmController = TG77VoiceAWMController()
  private let drumController = TG77DrumController()

  convenience init(hideIndivOut: Bool) {
    self.init()
    commonController.hideIndivOut = hideIndivOut
  }

  private let levels: [PBKnob] = (0..<4).map {
    return PBKnob(label: $0 == 0 ? "Level \($0+1)" : "\($0+1)")
  }
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch", "level"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch", 8), ("level", 4)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("switch",1),("page",8)], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Common","Elem 1","Elem 2","Elem 3","Elem 4","Drum"])
    grid(panel: "switch", items: [[(switchCtrl, nil)]])
    
    grid(panel: "level", items: [[
      (levels[0], [.element, .i(0), .common, .level]),
      (levels[1], [.element, .i(1), .common, .level]),
      (levels[2], [.element, .i(2), .common, .level]),
      (levels[3], [.element, .i(3), .common, .level])
      ]])
    
    addPatchChangeBlock(path: [.structure]) { [weak self] in
      let structure = UInt8($0)
      let elCount = TG77VoicePatch.elementCount(forStructure: structure)
      (0..<4).forEach {
        self?.switchCtrl.setEnabled($0 < elCount, forSegmentAt: $0 + 1)
        self?.levels[$0].isHidden = $0 >= elCount
      }
      self?.switchCtrl.setEnabled(structure == 10, forSegmentAt: 5)      
    }

    addColor(panels: ["level"])
    addColor(panels: ["switch"], clearBackground: true)
  }


  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return commonController
    case 5:
      return drumController
    default:
      guard let structure = latestValue(path: [.structure]) else { return nil }
      let el = index - 1
      let isFM = TG77VoicePatch.isElementFM(el, structure: UInt8(structure))
      let vc = isFM ? afmController : awmController
      vc.index = el
      return vc
    }
  }
    
//  override func randomize(_ sender: Any?) {
//    let p = TG77VoicePatch()
//    p.randomizeKeepingStructure()
//    changeCurrentElement(withPatch: p)
//  }
//
//  override func initialize(_ sender: Any?) {
//    let p = TG77VoicePatch()
//    changeCurrentElement(withPatch: p)
//  }
//
//  private func changeCurrentElement(withPatch p: TG77VoicePatch) {
//    let element = switchCtrl.selectedSegmentIndex - 1
//    let filterPre: SynthPath
//    let outPre: SynthPath
//    if currentController is TG77VoiceAFMController {
//      filterPre = [.element, .i(0), .fm]
//      outPre = [.element, .i(element), .fm]
//    }
//    else {
//      filterPre = [.element, .i(1), .wave]
//      outPre = [.element, .i(element), .wave]
//    }
//
//    var changes = [SynthPath:Int]()
//    p.paramKeys().forEach {
//      guard $0.starts(with: filterPre) else { return }
//      changes[$0.subpath(from: 3)] = p[$0]
//    }
//
//    changePatch(.paramsChange(changes.prefixed(outPre)))
//  }

}

class TG77VoiceCommonController : NewPatchEditorController {
  
  private var elementControllers: [ElementController]!
  
  fileprivate var hideIndivOut = false

  convenience init(hideIndivOut: Bool) {
    self.init()
    self.hideIndivOut = hideIndivOut
  }


  override func loadView(_ view: PBView) {
    elementControllers = addChildren(count: 4, panelPrefix: "el")
    let _: [TG77ChorusController] = addChildren(count: 2, panelPrefix: "chorus")
    let _: [TG77ReverbController] = addChildren(count: 2, panelPrefix: "reverb")
    
    let voiceMode = PBSelect(label: "Voice Mode")
    let volume = PBKnob(label: "Volume")

    let indivOut = PBKnob(label: "Indiv Out")
    indivOut.isHidden = hideIndivOut

    grid(panel: "common", items: [[
      (voiceMode, [.structure]),
      (volume, [.common, .volume]),
      (PBSwitch(label: "Porta"), [.common, .porta]),
      (PBKnob(label: "Porta Time"), [.common, .porta, .time]),
      ],[
      (PBSelect(label: "Microtune"), [.common, .micro]),
      (PBKnob(label: "Random Pitch"), [.common, .random, .pitch]),
      (indivOut, [.common, .out, .select]),
      (PBKnob(label: "Wh Bend"), [.common, .bend]),
      (PBKnob(label: "After Bend"), [.common, .aftertouch, .bend]),
    ]])

    grid(panel: "fx", items: [[
      (PBImageSelect(label: "FX Mode", imageSize: CGSize(width: 280, height: 60), imageSpacing: 12), [.fx, .mode]),
      ],[
      (PBCheckbox(label: "St Mix 1"), [.fx, .mix, .i(0)]),
      (PBCheckbox(label: "St Mix 2"), [.fx, .mix, .i(1)]),
      ]])
    
    grid(panel: "pitch", items: [[
      (PBKnob(label: "Depth"), [.common, .pitch, .range]),
      ],[
      (PBSelect(label: "Pitch Ctrl"), [.common, .pitch, .ctrl]),
      ]])
    
    grid(panel: "amp", items: [[
      (PBKnob(label: "Depth"), [.common, .amp, .range]),
      ],[
      (PBSelect(label: "Amp Ctrl"), [.common, .amp, .ctrl]),
      ]])
    
    grid(panel: "filter", items: [[
      (PBKnob(label: "Depth"), [.common, .filter, .range]),
      ],[
      (PBSelect(label: "Filter Ctrl"), [.common, .filter, .ctrl]),
      ]])

    grid(panel: "pan", items: [[
      (PBKnob(label: "Depth"), [.common, .pan, .range]),
      ],[
      (PBSelect(label: "Pan LFO Ctrl"), [.common, .pan, .ctrl]),
      ]])

    grid(panel: "filterBias", items: [[
      (PBKnob(label: "Depth"), [.common, .filter, .bias, .range]),
      ],[
      (PBSelect(label: "Filter Cutoff Ctrl"), [.common, .filter, .bias, .ctrl]),
      ]])

    grid(panel: "panBias", items: [[
      (PBKnob(label: "Depth"), [.common, .pan, .bias, .range]),
      ],[
      (PBSelect(label: "Pan Bias Ctrl"), [.common, .pan, .bias, .ctrl]),
      ]])

    grid(panel: "envBias", items: [[
      (PBKnob(label: "Depth"), [.common, .env, .bias, .range]),
      ],[
      (PBSelect(label: "EG Bias Ctrl"), [.common, .env, .bias, .ctrl]),
      ]])

    grid(panel: "vol", items: [[
      (PBKnob(label: "Vol Low Limit"), [.common, .volume, .range]),
      ],[
      (PBSelect(label: "Volume Ctrl"), [.common, .volume, .ctrl]),
      ]])
    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("common", 5), ("fx", 3), ("el0", 2), ("el1", 2), ("el2", 2), ("el3", 2)
      ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("vol", 2), ("pitch", 2), ("amp", 2), ("filter", 2), ("pan", 2), ("filterBias", 2), ("panBias", 2), ("envBias", 2)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("common", 2), ("chorus0", 1), ("chorus1", 1), ("reverb0", 1), ("reverb1", 1), ("vol", 2), ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["common", "fx"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["el0", "el1", "el2", "el3", "reverb1"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["fx", "chorus0", "chorus1", "reverb0", "reverb1"], attribute: .trailing)

    let hideIndivOut = self.hideIndivOut
    addPatchChangeBlock(path: [.structure]) { [weak self] in
      let structure = UInt8($0)
      let elCount = TG77VoicePatch.elementCount(forStructure: structure)
      (0..<4).forEach {
        self?.elementControllers[$0].view.isHidden = $0 >= elCount
      }
      let hidden = structure == 10
      let togglePanels = ["pitch","amp","filter","pan","filterBias","panBias","envBias"]
      togglePanels.forEach { self?.panels[$0]?.isHidden = hidden }
      self?.panels["common"]?.subviews.forEach {
        guard $0 != voiceMode && $0 != volume else { return }
        $0.isHidden = hidden || ($0 == indivOut && hideIndivOut)
      }
    }
    
    addColorToAll()
  }
  

  class ElementController : NewPatchEditorController {
    
    private let elementLabel = createLabel()
    
    override var index: Int {
      didSet { elementLabel.text = "Elem \(index + 1)" }
    }
    
    override var prefix: SynthPath? { return [.element, .i(index), .common] }
    
    private var panNameOptions = [Int:String]()

    override func loadView(_ view: PBView) {
      let panTable = PBSelect(label: "Pan Table")
      elementLabel.textAlignment = .center
      
      grid(view: view, items: [[
        (elementLabel, nil),
        (PBKnob(label: "Level"), [.level]),
        ],[
        (PBKnob(label: "Note Shift"), [.note, .shift]),
        (PBKnob(label: "Detune"), [.detune]),
        ],[
        (PBKnob(label: "Lo Note"), [.note, .lo]),
        (PBKnob(label: "Hi Note"), [.note, .hi]),
        ],[
        (PBKnob(label: "Lo Velo"), [.velo, .lo]),
        (PBKnob(label: "Hi Velo"), [.velo, .hi]),
        ],[
        (panTable, [.pan]),
        (PBCheckbox(label: "Microtun"), [.micro]),
        ],[
        (PBCheckbox(label: "Grp 1"), [.out, .i(0)]),
        (PBCheckbox(label: "Grp 2"), [.out, .i(1)]),
        ]])
      
      addParamChangeBlock { params in
        guard let param = params.params[[.pan, .name]] as? OptionsParam else { return }
        var options = param.options
        TG77PanBank.bankOptions.enumerated().forEach { options[$0.offset + 32] = $0.element }
        panTable.options = options
      }

      addColor(view: view, level: 2)
    }

  }
  
}

