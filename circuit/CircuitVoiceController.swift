
class CircuitVoiceController : NewPagedEditorController {
  
  private let mainController = MainController()
  private let macroModController = MacroModController()
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch", "poly", "genre", "dist"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch", 4), ("poly", 4), ("genre", 3), ("dist", 3.5),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",8),
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Main","Macro/Mod"])
    quickGrid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil, "switchCtrl")]])

    quickGrid(panel: "poly", items: [[
      (PBSwitch(label: "Poly"), [.poly], nil),
      (PBKnob(label: "Porta"), [.porta], nil),
      (PBKnob(label: "Pre-Glide"), [.glide], nil),
      (PBKnob(label: "Octave"), [.octave], nil),
      ]])
    
    quickGrid(panel: "genre", items: [[
      (PBSelect(label: "Genre"), [.genre], nil),
      (PBSelect(label: "Category"), [.category], nil),
      ]])

    quickGrid(panel: "dist", items: [[
      (PBSelect(label: "Distortion"), [.dist, .type], nil),
      (PBKnob(label: "Level"), [.dist, .level], nil),
      (PBKnob(label: "Comp"), [.dist, .adjust], nil),
      ]])
    
    addColorToAll(except: ["switch"])
    addColor(panels: ["switch"], clearBackground: true)
  }
  
  override func viewController(forIndex index: Int) -> PBViewController? {
    return index == 0 ? mainController : macroModController
  }
  
  
  class MainController : NewPatchEditorController {
  
    override func loadView() {
      let paddedView = PaddedContainer()
      paddedView.horizontalPadding = 0
      paddedView.verticalPadding = 0.06
      let view = paddedView.mainView

      let _: [OscController] = addChildren(count: 2, panelPrefix: "osc")
      addChild(FilterController(), withPanel: "filter")
      addChild(AmpController(), withPanel: "amp")
      addChild(Env3Controller(), withPanel: "env3")
      addChild(ChorusController(), withPanel: "chorus")
      addChild(LFOController(), withPanel: "lfo")
      addChild(MultiModController(), withPanel: "mod")
      
      createPanels(forKeys: ["mix", "eq"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([
        ("osc0", 5), ("filter", 4.5), ("amp", 4), ("mix", 3),
        ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("env3", 4), ("eq", 3),
        ], spacing: "-s1-")
      layout.addRowConstraints([
        ("lfo", 8), ("mod", 8),
        ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("chorus", 7),
        ], spacing: "-s1-")
      layout.addColumnConstraints([
        ("osc0", 2), ("osc1", 2), ("lfo", 2), ("chorus", 1),
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([
        ("amp", 2), ("env3", 2),
        ], options: [.alignAllLeading, .alignAllTrailing], spacing: "-s1-")

      layout.addEqualConstraints(forItemKeys: ["osc0", "amp", "mix"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["osc1", "filter", "env3", "eq"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["osc0", "osc1"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["mix", "eq"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["lfo", "chorus"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["chorus", "mod"], attribute: .bottom)

      quickGrid(panel: "mix", items: [[
        (PBKnob(label: "Osc 1"), [.mix, .osc, .i(0)], nil),
        (PBKnob(label: "Noise"), [.mix, .noise], nil),
        (PBKnob(label: "Pre FX"), [.mix, .pre, .fx], nil),
        ],[
        (PBKnob(label: "Osc 2"), [.mix, .osc, .i(1)], nil),
        (PBKnob(label: "Ring Mod"), [.mix, .ringMod], nil),
        (PBKnob(label: "Post FX"), [.mix, .post, .fx], nil),
        ]])

      quickGrid(panel: "eq", items: [[
        (PBKnob(label: "Lo Freq"), [.eq, .lo, .freq], nil),
        (PBKnob(label: "Mid Freq"), [.eq, .mid, .freq], nil),
        (PBKnob(label: "Hi Freq"), [.eq, .hi, .freq], nil),
        ],[
        (PBKnob(label: "Lo Gain"), [.eq, .lo, .level], nil),
        (PBKnob(label: "Mid Gain"), [.eq, .mid, .level], nil),
        (PBKnob(label: "Hi Freq"), [.eq, .hi, .level], nil),
        ]])
      
      layout.activateConstraints()
      self.view = paddedView
      
      addColor(panels: ["osc0", "osc1", "filter", "amp", "env3", "eq", "mix", "lfo", "chorus"])

    }
        
    
    class ChorusController : NewPatchEditorController {
      
      override var prefix: SynthPath? { return [.chorus] }
            
      override func loadView(_ view: PBView) {
        let rate = PBKnob(label: "Rate")
        
        quickGrid(view: view, items: [[
          (PBSwitch(label: "Chorus"), [.type], nil),
          (rate, [.rate], nil),
          (PBSelect(label: "Rate Sync"), [.rate, .sync], nil),
          (PBKnob(label: "Feedbk"), [.feedback], nil),
          (PBKnob(label: "Depth"), [.mod, .depth], nil),
          (PBKnob(label: "Delay"), [.delay], nil),
          (PBKnob(label: "Level"), [.level], nil),
          ]])
        
        addPatchChangeBlock(path: [.rate, .sync]) { rate.isHidden = $0 != 0 }
      }
    }
    
    
    
    class OscController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.osc, .i(index)] }
      
      override var index: Int {
        didSet { wave.label = "Osc \(index + 1)" }
      }
      
      private let wave = PBSelect(label: "Osc X")
      
      override func loadView(_ view: PBView) {
        quickGrid(view: view, items: [[
          (wave, [.wave], nil),
          (PBKnob(label: "Index"), [.pw], nil),
          (PBKnob(label: "Interp"), [.wave, .mix], nil),
          (PBKnob(label: "VSync"), [.sync], nil),
          ],[
          (PBKnob(label: "Semi"), [.semitone], nil),
          (PBKnob(label: "Cents"), [.detune], nil),
          (PBKnob(label: "Density"), [.unison], nil),
          (PBKnob(label: "Detune"), [.unison, .detune], nil),
          (PBKnob(label: "Bend"), [.bend], nil),
          ]])
      }
    }
    
    class EnvController : NewPatchEditorController {
      fileprivate let env = PBAdsrEnvelopeControl()
      
      func setupEnv(pre: SynthPath) {
        let env = self.env
        addPatchChangeBlock(path: pre + [.attack]) { env.attack = CGFloat($0) / 127 }
        addPatchChangeBlock(path: pre + [.decay]) { env.decay = CGFloat($0) / 127 }
        addPatchChangeBlock(path: pre + [.sustain]) { env.sustain = CGFloat($0) / 127 }
        addPatchChangeBlock(path: pre + [.release]) { env.rrelease = CGFloat($0) / 127 }
        
        registerForEditMenu(env, bundle: (
          paths: {[
            pre + [.attack],
            pre + [.decay],
            pre + [.sustain],
            pre + [.release],
          ]},
          pasteboardType: "com.cfshpd.CircuitEnv",
          initialize: nil,
          randomize: nil
        ))
      }
    }
    
    class FilterController : EnvController {
      
      override func loadView(_ view: PBView) {
        index = 1
        env.label = "Env 2 (Filter)"
        
        quickGrid(view: view, items: [[
          (PBSelect(label: "Filter"), [.filter, .type], nil),
          (PBKnob(label: "Freq"), [.filter, .cutoff], nil),
          (PBKnob(label: "Reson"), [.filter, .reson], nil),
          (PBKnob(label: "Q Norm"), [.filter, .q, .normal], nil),
          ],[
          (PBKnob(label: "Key Trk"), [.filter, .trk], nil),
          (PBSelect(label: "Drive"), [.filter, .drive, .type], nil),
          (PBKnob(label: "Drive"), [.filter, .drive], nil),
          (PBSwitch(label: "Routing"), [.filter, .routing], nil),
          ],[
          (env, [], nil),
          (PBKnob(label: "Velo"), [.env, .i(index), .velo], nil),
          (PBKnob(label: "Env Amt"), [.filter, .env, .i(index), .cutoff], nil),
          ],[
          (PBKnob(label: "Attack"), [.env, .i(index), .attack], nil),
          (PBKnob(label: "Decay"), [.env, .i(index), .decay], nil),
          (PBKnob(label: "Sustain"), [.env, .i(index), .sustain], nil),
          (PBKnob(label: "Release"), [.env, .i(index), .release], nil),
          ]])
        
        setupEnv(pre: [.env, .i(index)])
      }
    }
    
    class AmpController : EnvController {
      
      override func loadView(_ view: PBView) {
        index = 0
        env.label = "Env 1 (Amp)"
        
        quickGrid(view: view, items: [[
          (env, [], nil),
          (PBKnob(label: "Velo"), [.env, .i(index), .velo], nil),
          ],[
          (PBKnob(label: "Attack"), [.env, .i(index), .attack], nil),
          (PBKnob(label: "Decay"), [.env, .i(index), .decay], nil),
          (PBKnob(label: "Sustain"), [.env, .i(index), .sustain], nil),
          (PBKnob(label: "Release"), [.env, .i(index), .release], nil),
          ]])
        
        setupEnv(pre: [.env, .i(index)])
      }
    }
    
    class Env3Controller : EnvController {
      
      override func loadView(_ view: PBView) {
        index = 2
        env.label = "Env 3"
        
        quickGrid(view: view, items: [[
          (env, [], nil),
          (PBKnob(label: "Delay"), [.env, .i(index), .delay], nil),
          ],[
          (PBKnob(label: "Attack"), [.env, .i(index), .attack], nil),
          (PBKnob(label: "Decay"), [.env, .i(index), .decay], nil),
          (PBKnob(label: "Sustain"), [.env, .i(index), .sustain], nil),
          (PBKnob(label: "Release"), [.env, .i(index), .release], nil),
          ]])
        
        setupEnv(pre: [.env, .i(index)])
      }
    }
    
    
    class LFOController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.lfo, .i(index)] }

      override func loadView(_ view: PBView) {
        let labeledSwitch = LabeledSegmentedControl(label: "LFO", items: ["1","2"])
        switchCtrl = labeledSwitch.segmentedControl
        
        let rate = PBKnob(label: "Rate")
        let delay = PBKnob(label: "Delay")
        
        quickGrid(view: view, items: [[
          (labeledSwitch, nil, "switchCtrl"),
          (PBSelect(label: "Wave"), [.wave], nil),
          (rate, [.rate], nil),
          (PBSelect(label: "Rate Sync"), [.rate, .sync], nil),
          (PBCheckbox(label: "Key Sync"), [.key, .sync], nil),
          ],[
          (PBKnob(label: "Slew"), [.slew], nil),
          (PBKnob(label: "Phase"), [.phase], nil),
          (delay, [.delay], nil),
          (PBSelect(label: "Delay Sync"), [.delay, .sync], nil),
          (PBSwitch(label: "Trigger"), [.delay, .trigger], nil),
          (PBCheckbox(label: "1-Shot"), [.oneShot], nil),
          (PBCheckbox(label: "Comn Sync"), [.common, .sync], nil),
          (PBSwitch(label: "Fade Mode"), [.fade], nil),
          ]])
        
        addPatchChangeBlock(path: [.rate, .sync]) { rate.isHidden = $0 != 0 }
        addPatchChangeBlock(path: [.delay, .sync]) { delay.isHidden = $0 != 0 }
      }
    }
    
    class MultiModController : NewPatchEditorController {
      
      private var modControllers: [ModController]!
      
      override var index: Int {
        didSet {
          modControllers.enumerated().forEach { $0.element.index = index * 3 + $0.offset }
        }
      }
      
      override func loadView(_ view: PBView) {
        modControllers = addChildren(count: 3, panelPrefix: "mod")
        createPanels(forKeys: ["switch"])
        addPanelsToLayout(andView: view)
        
        layout.addRowConstraints([
          ("switch",1),
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addRowConstraints([
          ("mod0",1), ("mod1",1), ("mod2",1),
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([
          ("switch",1), ("mod0",2),
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        
        let modSwitch = LabeledSegmentedControl(label: "Mod Matrix", items: ["1–3", "4–6", "7–9", "10–12", "13–15"])
        switchCtrl = modSwitch.segmentedControl
        quickGrid(panel: "switch", items: [[(modSwitch, nil, "modSwitch")]])
        
        index += 0
        
        addColor(panels: ["mod0", "mod1", "mod2"], level: 3)
        addColor(panels: ["switch"], level: 3, clearBackground: true)
      }
      
    }
    
  }
  
  
  class MacroModController : NewPatchEditorController {
    
    private let multiModController = MultiModController()
    
    override func loadView(_ view: PBView) {
      addChild(MacroController(), withPanel: "macro")
      addChild(multiModController, withPanel: "mod")
      
      createPanels(forKeys: ["switch", "knobs"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("macro",1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("switch",5), ("knobs", 11)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod",1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("macro",2), ("switch", 1), ("mod", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      let modSwitch = LabeledSegmentedControl(label: "Mod Matrix", items: ["1–10", "11–20"])
      modSwitch.segmentedControl.addValueChangeTarget(self, action: #selector(modSelect(_:)))
      quickGrid(panel: "switch", items: [[(modSwitch, nil, "modSwitch")]])
      
      quickGrid(panel: "knobs", items: [[
        (PBKnob(label: "Macro 1"), [.macro, .i(0), .level], nil),
        (PBKnob(label: "2"), [.macro, .i(1), .level], nil),
        (PBKnob(label: "3"), [.macro, .i(2), .level], nil),
        (PBKnob(label: "4"), [.macro, .i(3), .level], nil),
        (PBKnob(label: "5"), [.macro, .i(4), .level], nil),
        (PBKnob(label: "6"), [.macro, .i(5), .level], nil),
        (PBKnob(label: "7"), [.macro, .i(6), .level], nil),
        (PBKnob(label: "8"), [.macro, .i(7), .level], nil),
        ]])
      
      addColor(panels: ["switch"], level: 3)
      addColor(panels: ["knobs"], level: 2)

    }
    
    @IBAction func modSelect(_ sender: PBSegmentedControl) {
      multiModController.index = sender.selectedSegmentIndex
    }
        
    
    class MacroController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.macro, .i(index)] }
      
      override var index: Int {
        didSet { label.text = "Macro \(index + 1)"}
      }
      
      private let label = createLabel()
      
      override func loadView(_ view: PBView) {
        let _: [PartController] = addChildren(count: 4, panelPrefix: "dest")
        createPanels(forKeys: ["switch"])
        addPanelsToLayout(andView: view)
        
        layout.addRowConstraints([
          ("switch", 6), ("dest0", 2.5), ("dest1", 2.5), ("dest2", 2.5), ("dest3", 2.5),
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([("switch", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
        
        let gridCtrl = PBGridSelectControl(label: "")
        gridCtrl.addValueChangeTarget(self, action: #selector(selectIndex(_:)))
        gridCtrl.options = OptionsParam.makeOptions((1...8).map { "\($0)"})
        gridCtrl.columnCount = 4
        gridCtrl.wantsGridWidth = 6
        label.textAlignment = .center
        quickGrid(panel: "switch", items: [[
          (gridCtrl, nil, "gridCtrl"),
          (label, nil, "labelCtrl"),
          ]])
        
        index += 0
        
        addColorToAll(level: 2)
      }

      
      class PartController : NewPatchEditorController {
        override var prefix: SynthPath? { return [.part, .i(index)] }

        
        override func loadView(_ view: PBView) {
          let start = PBDragControl(label: "Start")
          let end = PBDragControl(label: "End")
          let range = PBHorizontalRangeDisplay(label: " ")

          quickGrid(view: view, items: [[
            (PBSelect(label: "Destination"), [.dest], nil),
            (PBKnob(label: "Depth"), [.depth], nil),
            ],[
            (start, [.start], nil),
            (range, [], nil),
            (end, [.end], nil),
            ]])
          
          addPatchChangeBlock(path: [.dest]) { view.alpha = $0 == 0 ? 0.5 : 1 }
          addPatchChangeBlock(path: [.start]) {
            end.minimumValue = $0
            range.lowerValue = $0
          }
          addPatchChangeBlock(path: [.end]) {
            start.maximumValue = $0
            range.upperValue = $0
          }
        }
      }
      
    }
    
    class MultiModController : NewPatchEditorController {
      
      private var modControllers: [ModController]!
      
      override var index: Int {
        didSet {
          modControllers.enumerated().forEach { $0.element.index = index * 10 + $0.offset }
        }
      }
      
      override func loadView(_ view: PBView) {
        modControllers = addChildren(count: 10, panelPrefix: "mod")
        addPanelsToLayout(andView: view)
        
        layout.addRowConstraints([
          ("mod0",1), ("mod1",1), ("mod2",1), ("mod3",1), ("mod4",1),
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addRowConstraints([
          ("mod5",1), ("mod6",1), ("mod7",1), ("mod8",1), ("mod9",1),
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([
          ("mod0",1), ("mod5",1),
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        
        index += 0
        
        addColorToAll(level: 3)
      }
    }
    
  }
  
  class ModController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.mod, .i(index)] }
    
    override var index: Int {
      didSet { src.label = "Mod \(index + 1) Src" }
    }
    
    private let src = PBSelect(label: "Source")
    private let src2 = PBSelect(label: "Source")
    
    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[
        (src, [.src, .i(0)], nil),
        (src2, [.src, .i(1)], nil),
        ],[
        (PBKnob(label: "Depth"), [.depth], nil),
        (PBSelect(label: "Destination"), [.dest], nil),
        ]])
      
      addPatchChangeBlock(path: [.src, .i(0)]) { [weak self] in
        self?.src.alpha = $0 == 0 ? 0.5 : 1
      }
      addPatchChangeBlock(path: [.src, .i(1)]) { [weak self] in
        self?.src2.alpha = $0 == 0 ? 0.5 : 1
      }
    }
  }

}
