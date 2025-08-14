
class JD990PerfController : NewPagedEditorController {
  
  private let commonController = CommonController()
  private let partsController = PartsController()
    
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch","sync", "reserve"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch",6), ("sync", 1.5), ("reserve", 8)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("switch",1),("page",8)], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Common","Parts"])
    grid(panel: "switch", items: [[(switchCtrl, nil)]])

    grid(panel: "sync", items: [[
      (PBSelect(label: "Sync Part"), [.common, .sync, .part]),
      ]])

    grid(panel: "reserve", items: [(0..<8).map {
      let label = $0 == 0 ? "Vc Rsrv 1" : $0 == 7 ? "Rhythm" : "\($0 + 1)"
      return (PBKnob(label: label), [.common, .voice, .reserve, .i($0)])
    }])
    
    addColorToAll(except: ["switch"])
    addColor(panels: ["switch"], clearBackground: true)

  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    return index == 0 ? commonController : partsController
  }
  
  class CommonController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.common] }
    
    override func loadView() {
      let paddedView = PaddedContainer()
      paddedView.horizontalPadding = 0.25
      paddedView.verticalPadding = 0.25
      let view = paddedView.mainView
      
      createPanels(forKeys: ["delay", "reverb", "chorus"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("delay", 8)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("reverb", 6.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("chorus", 5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("delay", 1), ("reverb", 1), ("chorus", 1)], pinned: true, pinMargin: "", spacing: "-s1-")

      grid(panel: "delay", items: [[
        (PBSwitch(label: "Delay"), [.delay, .mode]),
        (PBKnob(label: "Center Tap"), [.delay, .mid, .time]),
        (PBKnob(label: "Center Lvl"), [.delay, .mid, .level]),
        (PBKnob(label: "Left Tap"), [.delay, .left, .time]),
        (PBKnob(label: "Left Lvl"), [.delay, .left, .level]),
        (PBKnob(label: "Right Tap"), [.delay, .right, .time]),
        (PBKnob(label: "Right Lvl"), [.delay, .right, .level]),
        (PBKnob(label: "Feedbk"), [.delay, .feedback]),
        ]])

      grid(panel: "reverb", items: [[
        (PBSelect(label: "Reverb"), [.reverb, .type]),
        (PBKnob(label: "Pre Delay"), [.reverb, .pre]),
        (PBKnob(label: "Early Ref"), [.reverb, .early]),
        (PBKnob(label: "HF Damp"), [.reverb, .hi, .cutoff]),
        (PBKnob(label: "Time"), [.reverb, .time]),
        (PBKnob(label: "Level"), [.reverb, .level]),
        ]])

      grid(panel: "chorus", items: [[
        (PBKnob(label: "Chorus Rate"), [.chorus, .rate]),
        (PBKnob(label: "Depth"), [.chorus, .depth]),
        (PBKnob(label: "Delay T"), [.chorus, .delay]),
        (PBKnob(label: "Feedbk"), [.chorus, .feedback]),
        (PBKnob(label: "Level"), [.chorus, .level]),
        ]])
      
      layout.activateConstraints()
      self.view = paddedView
      
      addColorToAll()
    }
  }
  
  class PartsController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      let _: [PartController] = addChildren(count: 7, panelPrefix: "part")
      addChild(RhythmPartController(), withPanel: "rhythm")
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        (0..<7).map { ("part\($0)", 1) } + [("rhythm",1)]
      ], pinMargin: "", spacing: "-s1-")
      
      addColorToAll()
    }    
  }
  
  class PartController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.part, .i(index)] }
    
    override var index: Int {
      didSet { on.label = "\(index + 1)" }
    }
    
    fileprivate let on = PBCheckbox(label: "On")
    fileprivate let patchNumber = PBSelect(label: "Patch")

    fileprivate let fxMode = PBSwitch(label: "FX Mode")
    fileprivate let fxLevel = PBKnob(label: "FX Level")
    fileprivate let outAssign = PBSwitch(label: "Output")
    
    private var internalPatchOptions = [Int:String]()
    private var cardPatchOptions = [Int:String]()
    private var patchOptions = [Int:String]()
    
    private var internalRhythmOptions = [Int:String]()
    private var cardRhythmOptions = [Int:String]()
    private var rhythmOptions = [Int:String]()

    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (on, [.on]),
        (PBKnob(label: "Channel"), [.channel]),
        ], [
        (PBSwitch(label: "Bank"), [.bank]),
        ], [
        (patchNumber, [.pgm, .number]),
        ], [
        (PBKnob(label: "Level"), [.level]),
        (PBKnob(label: "Pan"), [.pan]),
        ], [
        (PBKnob(label: "Coarse"), [.coarse]),
        (PBKnob(label: "Fine"), [.fine]),
        ], [
        (fxMode, [.fx, .mode]),
        ], [
        (fxLevel, [.fx, .level]),
        ], [
        (outAssign, [.out, .assign]),
        ]])
      
      addParamChangeBlock { [weak self] (params) in
        if let param = params.params[[.patch, .name, .i(0)]] as? OptionsParam {
          self?.internalPatchOptions = param.options
          self?.updatePatchOptions()
        }
        if let param = params.params[[.patch, .name, .i(1)]] as? OptionsParam {
          self?.cardPatchOptions = param.options
          self?.updatePatchOptions()
        }
        if let param = params.params[[.rhythm, .name, .i(0)]] as? OptionsParam {
          self?.internalRhythmOptions = param.options
          self?.updateRhythmOptions()
        }
        if let param = params.params[[.rhythm, .name, .i(1)]] as? OptionsParam {
          self?.cardRhythmOptions = param.options
          self?.updateRhythmOptions()
        }
      }
      addPatchChangeBlock(path: [.bank]) { [weak self] (value) in
        self?.updatePatchNumberOptions(bank: value)
      }
      
      addPatchChangeBlock(path: [.on]) { (value) in
        view.alpha = value == 0 ? 0.5 : 1
      }
    }
    
    private func updatePatchNumberOptions(bank: Int) {
      var options = [Int:String]()
      let isRhythm = index == 7
      if bank == 0 { // internal/card
        options = isRhythm ? rhythmOptions : patchOptions
      }
      else {
        options = isRhythm ? JD990PerfPartPatch.presetRhythmOptions : JD990PerfPartPatch.presetOptions
      }
      patchNumber.options = options
    }
    
    private func updatePatchOptions() {
      patchOptions = internalPatchOptions
      cardPatchOptions.forEach { patchOptions[64 + $0.key] = $0.value }
      if let value = latestValue(path: [.bank]) {
        updatePatchNumberOptions(bank: value)
      }
    }
    
    private func updateRhythmOptions() {
      rhythmOptions = internalRhythmOptions
      cardRhythmOptions.forEach { rhythmOptions[64 + $0.key] = $0.value }
      if let value = latestValue(path: [.bank]) {
        updatePatchNumberOptions(bank: value)
      }
    }
    
  }

  class RhythmPartController : PartController {
    override var prefix: SynthPath? { return [.part, .i(7)] }
    
    override func loadView(_ view: PBView) {
      super.loadView(view)
      on.label = "Rhythm"
      fxMode.isHidden = true
      fxLevel.isHidden = true
      outAssign.isHidden = true
    }
  }
}


