
extension VirusTISnowVoiceController {
  
  class ModsController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      let _: [ModController] = addChildren(count: 6, panelPrefix: "mod")
      addChild(LFO0Controller(), withPanel: "lfo0")
      addChild(LFO1Controller(), withPanel: "lfo1")
      addChild(LFO2Controller(), withPanel: "lfo2")
      addChild(EnvController(prefix: [.env, .i(2)], label: "Env 3"), withPanel: "env2")
      addChild(EnvController(prefix: [.env, .i(3)], label: "Env 4"), withPanel: "env3")
      createPanels(forKeys: ["knob"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("lfo0", 8), ("lfo1", 8)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("env2", 7), ("lfo2", 4.5), ("knob", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod0", 2.5), ("mod3", 2.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod1", 2.5), ("mod4", 2.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod2", 2.5), ("mod5", 2.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("lfo0", 2), ("env2", 1), ("env3", 1), ("mod0", 1), ("mod1", 1), ("mod2", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["env2", "env3"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["env3", "lfo2", "knob"], attribute: .bottom)
      
      grid(panel: "knob", items: [[
        (PBSelect(label: "Knob 1 Func"), [.knob, .i(0), .dest]),
        (PBSelect(label: "Knob 2 Func"), [.knob, .i(1), .dest]),
        (PBSelect(label: "Knob 3 Func"), [.knob, .i(2), .dest]),
        ],[
        (PBSelect(label: "Knob 1 Name"), [.knob, .i(0), .name]),
        (PBSelect(label: "Knob 2 Name"), [.knob, .i(1), .name]),
        (PBSelect(label: "Knob 3 Name"), [.knob, .i(2), .name]),
      ]])
      
      addColor(panels: ["lfo0", "lfo1", "lfo2"], level: 3)
      addColor(panels: ["mod0", "mod1", "mod2", "mod3", "mod4", "mod5"], level: 1)
      addColor(panels: ["knob", "env2", "env3"], level: 2)

    }
        
  }
  
  class LFOController : NewPatchEditorController {
    
    fileprivate let rate = PBKnob(label: "Rate")
    fileprivate let dest = PBSelect(label: "Dest")
    fileprivate let amt = PBKnob(label: "Amt")
    
    override func viewDidLoad() {
      super.viewDidLoad()
      addPatchChangeBlock(path: [.clock]) { [weak self] in
        self?.rate.isHidden = $0 > 0
      }
      addPatchChangeBlock(path: [.dest]) { [weak self] in
        let alpha: CGFloat = $0 == 0 ? 0.4 : 1
        self?.dest.alpha = alpha
        self?.amt.alpha = alpha
      }
    }
    
  }
  
  class LFO0Controller : LFOController {
    override var prefix: SynthPath? { return [.lfo, .i(0)] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSelect(label: "LFO 1 Shape"), [.shape]),
        (PBKnob(label: "Clock"), [.clock]),
        (rate, [.rate]),
        (PBKnob(label: "Contour"), [.curve]),
        (PBKnob(label: "Key Fol"), [.keyTrk]),
        (dest, [.dest]),
        (amt, [.dest, .amt]),
        ],[
        (PBSwitch(label: "Mode"), [.mode]),
        (PBCheckbox(label: "Env Mode"), [.env, .mode]),
        (PBKnob(label: "Trig Phase"), [.trigger]),
        (PBKnob(label: "O1 Ptch"), [.osc]),
        (PBKnob(label: "O2 Ptch"), [.osc, .i(1)]),
        (PBKnob(label: "PW"), [.pw]),
        (PBKnob(label: "Reson"), [.filter, .reson]),
        (PBKnob(label: "Filter Gain"), [.filter, .env]),
      ]])
    }
  }
  
  class LFO1Controller : LFOController {
    override var prefix: SynthPath? { return [.lfo, .i(1)] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSelect(label: "LFO 2 Shape"), [.shape]),
        (PBKnob(label: "Clock"), [.clock]),
        (rate, [.rate]),
        (PBKnob(label: "Contour"), [.curve]),
        (PBKnob(label: "Key Fol"), [.keyTrk]),
        (dest, [.dest]),
        (amt, [.dest, .amt]),
        ],[
        (PBSwitch(label: "Mode"), [.mode]),
        (PBCheckbox(label: "Env Mode"), [.env, .mode]),
        (PBKnob(label: "Trig Phase"), [.trigger]),
        (PBKnob(label: "Cutoff 1"), [.cutoff]),
        (PBKnob(label: "Cutoff 2"), [.cutoff, .i(1)]),
        (PBKnob(label: "Osc Shape 1/2"), [.osc, .shape]),
        (PBKnob(label: "Fm Amt"), [.fm]),
        (PBKnob(label: "Pan"), [.pan]),
      ]])
    }
  }
  
  class LFO2Controller : LFOController {
    override var prefix: SynthPath? { return [.lfo, .i(2)] }

    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSelect(label: "LFO 3 Shape"), [.shape]),
        (PBKnob(label: "Clock"), [.clock]),
        (rate, [.rate]),
        (PBKnob(label: "Key Fol"), [.keyTrk]),
        ],[
        (PBSwitch(label: "Mode"), [.mode]),
        (PBKnob(label: "Fade In"), [.fade]),
        (dest, [.dest]),
        (amt, [.dest, .amt]),
      ]])

    }
  }
  
  class ModController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.mod, .i(index)] }
    
    override var index: Int {
      didSet { src.label = "Mod \(index + 1) Src" }
    }
    
    private let src = PBSelect(label: "Src")
    
    override func loadView(_ view: PBView) {
      let dests: [PBSelect] = (0..<3).map { PBSelect(label: "Dest \($0 + 1)") }
      let amts: [PBKnob] = (0..<3).map { _ in PBKnob(label: "← Amt") }

      grid(view: view, items: [[
        (src, [.src]),
        (dests[0], [.dest, .i(0)]),
        (amts[0], [.amt, .i(0)]),
        (dests[1], [.dest, .i(1)]),
        (amts[1], [.amt, .i(1)]),
        (dests[2], [.dest, .i(2)]),
        (amts[2], [.amt, .i(2)]),
      ]])
      
      addPatchChangeBlock(path: [.src]) { value in
        (0..<3).forEach {
          dests[$0].isHidden = value == 0
          amts[$0].isHidden = value == 0
        }
      }
      (0..<3).forEach { d in
        addPatchChangeBlock(path: [.dest, .i(d)]) { value in
          dests[d].alpha = value == 0 ? 0.4 : 1
          amts[d].alpha = value == 0 ? 0.4 : 1
        }
      }
    }
  }
  
  
}
