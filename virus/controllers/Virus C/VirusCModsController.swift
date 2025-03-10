
extension VirusCVoiceController {
  
  class ModsController : NewPatchEditorController {
    
    private var multipart: Bool = false
    
    convenience init(multipart: Bool = false) {
      self.init()
      self.multipart = multipart
    }

    override func loadView(_ view: PBView) {
      addChild(ModController(index: 3), withPanel: "mod3")
      addChild(ModController(index: 4), withPanel: "mod4")
      addChild(ModController(index: 5), withPanel: "mod5")
      addChild(LFO0Controller(), withPanel: "lfo0")
      addChild(LFO1Controller(), withPanel: "lfo1")
      addChild(LFO2Controller(), withPanel: "lfo2")
            
      addChild(ChorusController(), withPanel: "chorus")
      addChild(PhasorController(), withPanel: "phasor")
      addChild(DistortionController(), withPanel: "distort")
      addChild(VocoderController(), withPanel: "vocoder")
      addChild(CharacterController(), withPanel: "char")
      addChild(DelayController(), withPanel: "delay")
      addChild(EQController(), withPanel: "eq")
            
      createPanels(forKeys: ["knob"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("lfo0", 8), ("lfo1", 8)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("lfo2", 12), ("knob", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod3", 3.5), ("mod4", 3.5), ("mod5", 3.5)], pinned: false, spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["lfo2", "mod5"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["mod5", "knob"], attribute: .bottom)
      
      layout.addRowConstraints([("delay", 5), ("chorus", 7), ("eq", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("chorus", 1), ("phasor", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["delay", "phasor", "eq"], attribute: .bottom)
      layout.addRowConstraints([("vocoder", 10.5), ("distort", 2.5), ("char", 2)], pinned: true, pinMargin: "", spacing: "-s1-")

      layout.addColumnConstraints([("lfo0", 2), ("lfo2", 1), ("mod3", 1), ("delay", 2), ("vocoder", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      panels["delay"]?.alpha = multipart ? 0.4 : 1

      grid(panel: "knob", items: [[
        (PBSelect(label: "Knob 1 Func"), [.knob, .i(0), .dest]),
        (PBSelect(label: "Knob 2 Func"), [.knob, .i(1), .dest]),
        ],[
        (PBSelect(label: "Knob 1 Name"), [.knob, .i(0), .name]),
        (PBSelect(label: "Knob 2 Name"), [.knob, .i(1), .name]),
      ]])

      addColor(panels: ["lfo0", "lfo1", "lfo2"], level: 3)
      addColor(panels: ["mod3", "mod4", "mod5" , "knob"], level: 1)
      addColor(panels: ["chorus", "phasor", "distort", "vocoder", "char", "delay", "eq"], level: 2)
    }
        
  }
  
  class LFOController : NewPatchEditorController {
    
    let rate = PBKnob(label: "Rate")
    let dest = PBSelect(label: "Dest")
    let amt = PBKnob(label: "Amt")
    
    override func viewDidLoad() {
      super.viewDidLoad()
      addPatchChangeBlock(path: [.clock]) { [weak self] in
        self?.rate.isHidden = $0 > 0
      }
      addPatchChangeBlock(path: [.dest]) { [weak self] in
        guard self?.index != 2 else { return } // doesn't apply to LFO 3
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
        (PBSwitch(label: "Mode"), [.mode]),
        (PBKnob(label: "Fade In"), [.fade]),
        (dest, [.dest]),
        (amt, [.dest, .amt]),
      ]])

    }
  }
  
  class ModController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.mod, .i(index)] }
        
    convenience init(index: Int) {
      self.init()
      self.index = index
    }
    
    override func loadView(_ view: PBView) {
      let src = PBSelect(label: "Mod \(index + 1) Src")
      let dests: [PBSelect] = (0..<3).map { PBSelect(label: "Dest \($0 + 1)") }
      let amts: [PBKnob] = (0..<3).map { _ in PBKnob(label: "← Amt") }

      var items: [(PBView, SynthPath?)] = [
        (src, [.src]),
        (dests[0], [.dest, .i(0)]),
        (amts[0], [.amt, .i(0)]),
      ]
      if [1,2].contains(index) {
        items.append(contentsOf: [
          (dests[1], [.dest, .i(1)]),
          (amts[1], [.amt, .i(1)]),
        ] as [(PBView, SynthPath?)])
      }
      if index == 2 {
        items.append(contentsOf: [
          (dests[2], [.dest, .i(2)]),
          (amts[2], [.amt, .i(2)]),
        ] as [(PBView, SynthPath?)])
      }
      
      grid(view: view, items: [items])
      
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
      addPatchChangeBlock(path: [.src]) { view.alpha = $0 == 0 ? 0.4 : 1 }
    }
  }
  
  
}
