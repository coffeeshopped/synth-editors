
class MicronVoiceController : NewPagedEditorController {

  private let mainController = MainController()
  private let modController = ModController()
  private let fxController = FXController()
  
  override func loadView(_ view: PBView) {
    switchCtrl = PBSegmentedControl(items: ["Main","Mods","FX"])
    grid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil)]])

    let lfo0 = PBKnob(label: "LFO 1")
    let lfo0sync = PBKnob(label: "LFO 1")
    let lfo1 = PBKnob(label: "LFO 2")
    let lfo1sync = PBKnob(label: "LFO 2")
    let sh = PBKnob(label: "S&H")
    let shsync = PBKnob(label: "S&H")
    grid(panel: "lfo", items: [[
      (lfo0, [.lfo, .i(0), .rate]),
      (lfo0sync, [.lfo, .i(0), .sync, .rate]),
      (lfo1, [.lfo, .i(1), .rate]),
      (lfo1sync, [.lfo, .i(1), .sync, .rate]),
      (sh, [.sample, .rate]),
      (shsync, [.sample, .sync, .rate]),
      ]])
    
//    grid(panel: "arp", items: [[
//      (PBSwitch(label: "Arp"), [.arp, .mode]),
//      (PBSelect(label: "Pattern"), [.arp, .pattern]),
//      (PBKnob(label: "Octave"), [.arp, .octave, .range]),
//      (PBSwitch(label: "Span"), [.arp, .octave, .direction]),
//      (PBKnob(label: "Tempo"), [.arp, .tempo]),
//      (PBKnob(label: "Length"), [.arp, .length]),
//      (PBKnob(label: "Tempo Mult"), [.arp, .tempo, .multi]),
//      ]])

    grid(panel: "knob", items: [[
      (PBSelect(label: "Knob X"), [.knob, .i(0), .param]),
      (PBSelect(label: "Knob Y"), [.knob, .i(1), .param]),
      (PBSelect(label: "Knob Z"), [.knob, .i(2), .param]),
      ]])

    grid(panel: "cat", items: [[
      (PBSelect(label: "Category"), [.category]),
      ]])
    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch", 4), ("lfo", 6), ("knob", 4.5), ("cat", 1.5),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("switch",1),("page",8)], pinned: true, spacing: "-s1-")
    
    addPatchChangeBlock(path: [.lfo, .i(0), .tempo, .sync]) {
      lfo0.isHidden = $0 != 0
      lfo0sync.isHidden = $0 == 0
    }
    addPatchChangeBlock(path: [.lfo, .i(1), .tempo, .sync]) {
      lfo1.isHidden = $0 != 0
      lfo1sync.isHidden = $0 == 0
    }
    addPatchChangeBlock(path: [.sample, .tempo, .sync]) {
      sh.isHidden = $0 != 0
      shsync.isHidden = $0 == 0
    }
    
    addColor(panels: ["knob", "cat", "lfo"])
    addColor(panels: ["switch"], clearBackground: true)
  }

  override func viewController(forIndex index: Int) -> PBViewController? {
    guard index < 3 else { return nil }
    return [mainController, modController, fxController][index]
  }
  
  
  class MainController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      let _: [OscController] = addChildren(count: 3, panelPrefix: "osc")
      let _: [EnvController] = addChildren(count: 3, panelPrefix: "env")
      addChild(ModsController(), withPanel: "mods")
      addChild(Filter2Controller(), withPanel: "f2")
      
      grid(panel: "sync", items: [[
        (PBSwitch(label: "Osc Sync"), [.osc, .sync]),
        ]])
            
      grid(panel: "fm", items: [[
        (PBSelect(label: "Type"), [.fm, .type]),
        (PBKnob(label: "FM Level"), [.fm, .amt]),
        ]])

      grid(panel: "porta", items: [[
        (PBSwitch(label: "Porta"), [.porta]),
        (PBSwitch(label: "Type"), [.porta, .type]),
        (PBKnob(label: "Time"), [.porta, .time]),
        ]])

      grid(panel: "f1", items: [[
        (PBSelect(label: "Filter 1"), [.filter, .i(0), .type]),
        (PBKnob(label: "Cutoff"), [.filter, .i(0), .cutoff]),
        (PBKnob(label: "Reson"), [.filter, .i(0), .reson]),
        (PBKnob(label: "Key Trk"), [.filter, .i(0), .key, .trk]),
        (PBKnob(label: "Env 2 Amt"), [.filter, .i(0), .env, .amt]),
        (PBKnob(label: "-> F2"), [.filter, .balance]),
        (PBSwitch(label: "Polarity"), [.filter, .i(0), .polarity]),
        ]])

      grid(panel: "unison", items: [[
        (PBCheckbox(label: "Poly"), [.poly]),
        (PBSwitch(label: "P Wheel"), [.bend]),
        (PBKnob(label: "Analog"), [.analogFeel]),
        ],[
        (PBSwitch(label: "Unison"), [.unison]),
        (PBKnob(label: "Uni Detune"), [.unison, .detune]),
        (PBKnob(label: "Pgm Level"), [.out, .level]),
        ]])

      grid(panel: "noise", items: [[
        (PBSwitch(label: "Noise Type"), [.noise, .type]),
        ]])

      grid(panel: "premix", items: [[
        (PBKnob(label: "O1 Lev"), [.osc, .i(0), .level]),
        (PBKnob(label: "O2 Lev"), [.osc, .i(1), .level]),
        (PBKnob(label: "O3 Lev"), [.osc, .i(2), .level]),
        (PBKnob(label: "Ring Lev"), [.ringMod, .level]),
        (PBKnob(label: "Ns Lev"), [.noise, .level]),
        (PBKnob(label: "Ext Lev"), [.ext, .level]),
        ],[
        (PBKnob(label: "O1 Bal"), [.osc, .i(0), .balance]),
        (PBKnob(label: "O2 Bal"), [.osc, .i(1), .balance]),
        (PBKnob(label: "O3 Bal"), [.osc, .i(2), .balance]),
        (PBKnob(label: "Ring Bal"), [.ringMod, .balance]),
        (PBKnob(label: "Ns Bal"), [.noise, .balance]),
        (PBKnob(label: "Ext Bal"), [.ext, .balance]),
        ]])
      
      grid(panel: "postmix", items: [[
        (PBKnob(label: "F1 Lev"), [.filter, .i(0), .level]),
        (PBKnob(label: "F2 Lev"), [.filter, .i(1), .level]),
        (PBKnob(label: "Pre Lev"), [.pre, .filter, .level]),
        ],[
        (PBKnob(label: "F1 Pan"), [.filter, .i(0), .pan]),
        (PBKnob(label: "F2 Pan"), [.filter, .i(1), .pan]),
        (PBKnob(label: "Pre Pan"), [.pre, .filter, .pan]),
        ]])
      
      grid(panel: "presig", items: [[
        (PBSelect(label: "Pre Signal"), [.pre, .filter, .src]),
        ]])
      
      grid(panel: "fx", items: [[
        (PBKnob(label: "FX Send"), [.fx, .i(0), .mix]),
        ]])
      
      grid(panel: "drive", items: [[
        (PBSelect(label: "Drive Type"), [.drive, .type]),
        (PBKnob(label: "Level"), [.drive, .level]),
        ]])

      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([
        ("osc0", 6), ("sync", 2), ("noise", 1), ("fm", 3), ("porta", 4),
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("osc1", 6), ("f1", 7.5), ("unison", 3),
      ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("osc2", 6), ("f2", 7.5),
        ], pinned: false, spacing: "-s1-")
      layout.addRowConstraints([
        ("premix", 6), ("postmix", 3), ("presig", 1.5), ("fx", 1), ("mods", 4.5),
        ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("env0", 1), ("env1", 1), ("env2", 1),
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([
        ("osc0",1), ("osc1",1), ("osc2",1), ("premix",2), ("env0",3),
        ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([
        ("presig",1), ("drive",1),
        ], pinned: false, spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["osc1","f1"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["unison","f2"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["presig","fx"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["premix","postmix","drive","mods"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["f1","f2"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["fx","drive"], attribute: .trailing)
      
      addColor(panels: ["osc0", "osc1", "osc2", "sync", "noise", "fm", "porta", "f1", "f2", "unison", "presig", "drive", "premix", "postmix", "fx"])
      addColor(panels: ["env0", "env1", "env2"], level: 3)

    }
    
    
    class OscController : NewPatchEditorController {
      
      override var prefix: SynthPath? { [.osc, .i(index)] }
      
      override var index: Int {
        didSet { osc.label = "Osc \(index + 1)" }
      }
      
      private let osc = PBSwitch(label: "Osc")
      
      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (osc, [.wave]),
          (PBKnob(label: "Shape"), [.shape]),
          (PBKnob(label: "Octave"), [.octave]),
          (PBKnob(label: "Semi"), [.semitone]),
          (PBKnob(label: "Fine"), [.fine]),
          (PBKnob(label: "Bend"), [.bend]),
          ]])
      }
    }
    
    class Filter2Controller : NewPatchEditorController {
      override var prefix: SynthPath? { return [.filter, .i(1)] }
            
      override func loadView(_ view: PBView) {
        let cutoff = PBKnob(label: "Cutoff")
        let offsetFreq = PBKnob(label: "Cutoff (Oct)")
        grid(view: view, items: [[
          (PBSelect(label: "Filter 2"), [.type]),
          (cutoff, [.cutoff]),
          (PBKnob(label: "Reson"), [.reson]),
          (PBKnob(label: "Key Trk"), [.key, .trk]),
          (PBKnob(label: "Env 2 Amt"), [.env, .amt]),
          (PBSwitch(label: "Offset"), [.offset, .type]),
          (offsetFreq, [.offset, .freq]),
          ]])
        
        addPatchChangeBlock(path: [.offset, .type]) {
          cutoff.isHidden = $0 != 0
          offsetFreq.isHidden = $0 == 0
        }
      }
    }
    
    class EnvController : NewPatchEditorController {
      override var prefix: SynthPath? { [.env, .i(index)] }
      
      override var index: Int {
        didSet {
          env.label = ["Env 1 (Amp)", "Env 2 (Filter)", "Env 3"][index]
        }
      }
      
      private let env = MicronEnvelopeControl(label: "Env")
      
      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (PBKnob(label: "Velo"), [.velo]),
          (env, nil),
          (PBSwitch(label: "Reset"), [.reset]),
          (PBCheckbox(label: "Freerun"), [.run]),
          ],[
          (PBKnob(label: "Attack"), [.attack]),
          (PBKnob(label: "Decay"), [.decay]),
          (PBKnob(label: "Sustain"), [.sustain]),
          (PBKnob(label: "Release"), [.release]),
          (PBSwitch(label: "Loop"), [.loop]),
          ],[
          (PBSwitch(label: "A Slope"), [.attack, .slew]),
          (PBSwitch(label: "D Slope"), [.decay, .slew]),
          (PBKnob(label: "S Time"), [.sustain, .time]),
          (PBSwitch(label: "R Slope"), [.release, .slew]),
          (PBCheckbox(label: "Sus Ped"), [.pedal]),
          ]])
        
        let env = self.env
        addPatchChangeBlock(path: [.attack]) { env.attack = CGFloat($0) / 255 }
        addPatchChangeBlock(path: [.decay]) { env.decay = CGFloat($0) / 255 }
        addPatchChangeBlock(path: [.sustain]) { env.sustain = CGFloat($0) / 100 }
        addPatchChangeBlock(path: [.release]) { env.rrelease = CGFloat($0) / 256 }
        addPatchChangeBlock(path: [.attack, .slew]) {
          env.attackSlope = MicronEnvelopeControl.Slope(rawValue: $0) ?? .linear
        }
        addPatchChangeBlock(path: [.decay, .slew]) {
          env.decaySlope = MicronEnvelopeControl.Slope(rawValue: $0) ?? .linear
        }
        addPatchChangeBlock(path: [.sustain, .time]) { env.sustainTime = CGFloat($0) / 256 }
        addPatchChangeBlock(path: [.release, .slew]) {
          env.releaseSlope = MicronEnvelopeControl.Slope(rawValue: $0) ?? .linear
        }
        addPatchChangeBlock(path: [.run]) { env.freeRun = $0 != 0 }

        let EnvPaths: [SynthPath] = [[.attack], [.decay], [.sustain], [.release],
                                  [.attack, .slew], [.decay, .slew], [.release, .slew],
                                  [.sustain, .time], [.run]]
        registerForEditMenu(env, bundle: (
          paths: { EnvPaths },
          pasteboardType: "com.cfshpd.MicronEnvelope",
          initialize: nil,
          randomize: nil
        ))
      }
    }
    
    
    class ModsController : NewPatchEditorController {
      
      override var prefix: SynthPath? { return [.mod, .i(index)] }
      
      override func loadView(_ view: PBView) {
        let sw = LabeledSegmentedControl(label: "Mod", items: ["1","2","3","4","5","6"])
        switchCtrl = sw.segmentedControl
        grid(panel: "switch", items: [[(sw, nil)]])
        
        grid(panel: "mod", items: [[
          (PBSelect(label: "Src"), [.src]),
          (PBKnob(label: "Level"), [.level]),
          (PBKnob(label: "Offset"), [.offset]),
          (PBSelect(label: "Dest"), [.dest]),
          ]])
        
        addPanelsToLayout(andView: view)
        layout.addGridConstraints([[("switch",1)],[("mod",1)]], pinMargin: "", spacing: "-s1-")
        
        addPatchChangeBlock(paths: [[.src], [.dest]]) { [weak self] (values) in
          guard let src = values[[.src]],
                let dest = values[[.dest]] else { return }
          self?.panels["mod"]?.alpha = src == 0 || dest == 0 ? 0.4 : 1
        }

        addColorToAll(except: ["switch"], level: 2)
        addColor(panels: ["switch"], level: 2, clearBackground: true)
        addBorder(view: view, level: 2)

      }
      
    }
  }
  
  class ModController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      let _: [LFOController] = addChildren(count: 2, panelPrefix: "lfo")
      addChild(SHController(), withPanel: "sh")
      addChild(TrackingController(), withPanel: "track")
      let _: [ModController] = addChildren(count: 12, panelPrefix: "mod")
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("lfo0", 5), ("lfo1", 5), ("sh", 5.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("track", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod0",1), ("mod1",1), ("mod2",1)],
                               pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod3",1), ("mod4",1), ("mod5",1)],
                               pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod6",1), ("mod7",1), ("mod8",1)],
                               pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("mod9",1), ("mod10",1), ("mod11",1)],
                               pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("lfo0",1), ("track",3), ("mod0",1), ("mod3",1), ("mod6",1), ("mod9",1), ], pinned: true, pinMargin: "", spacing: "-s1-")
      
      addColorToAll()
    }

    
    class LFOController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.lfo, .i(index)] }
      
      override var index: Int {
        didSet {
          rate.label = "LFO \(index + 1) Rate"
          syncRate.label = "LFO \(index + 1) Rate"
        }
      }
      
      fileprivate let rate = PBKnob(label: "Rate")
      fileprivate let syncRate = PBKnob(label: "Rate")
      
      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (rate, [.rate]),
          (syncRate, [.sync, .rate]),
          (PBCheckbox(label: "Sync"), [.tempo, .sync]),
          (PBSwitch(label: "Reset"), [.reset]),
          (PBKnob(label: "Mod 1"), [.modWheel]),
          ]])
        
        let rate = self.rate
        let syncRate = self.syncRate
        addPatchChangeBlock(path: [.tempo, .sync]) {
          rate.isHidden = $0 > 0
          syncRate.isHidden = $0 == 0
        }
      }
    }
    
    class SHController : LFOController {
      override var prefix: SynthPath? { return [.sample] }
      
      override var index: Int {
        didSet { rate.label = "S&H Rate"}
      }
            
      override func loadView(_ view: PBView) {
        rate.label = "S&H Rate"
        syncRate.label = "S&H Rate"
        grid(view: view, items: [[
          (rate, [.rate]),
          (syncRate, [.sync, .rate]),
          (PBCheckbox(label: "Sync"), [.tempo, .sync]),
          (PBSwitch(label: "Reset"), [.reset]),
          (PBSelect(label: "Input"), [.src]),
          (PBKnob(label: "Smooth"), [.smooth]),
          ]])
      }
    }
    
    class TrackingController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.trk] }
            
      override func loadView(_ view: PBView) {
        
        grid(panel: "src", items: [[
          (PBSelect(label: "Track Input"), [.src]),
          (PBSwitch(label: "Grid Pts"), [.pt, .number]),
          ]])
        
        let track = MicronTrackingControl(label: "Tracking Gen")
        grid(panel: "trk", items: [[(track, nil)]])

        grid(panel: "preset", items: [[(PBSelect(label: "Track Preset"), [.preset])]])

        grid(panel: "knob1", items: [
          (-8...(-1)).map { (PBKnob(label: "\($0)"), [.pt, .i($0)]) } +
          [(PBKnob(label: "C"), [.pt, .i(0)])] +
          (1...8).map { (PBKnob(label: "\($0)"), [.pt, .i($0)]) }
          ])

        grid(panel: "knob2", items: [
             (-16...(-9)).map { (PBKnob(label: "\($0)"), [.pt, .i($0)]) } +
             (9...16).map { (PBKnob(label: "\($0)"), [.pt, .i($0)]) }
             ])
        
        addPanelsToLayout(andView: view)
        
        layout.addRowConstraints([("src",3), ("trk", 7), ("preset",3)], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addRowConstraints([("knob1",1)], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addRowConstraints([("knob2",1)], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([("src",1), ("knob1",1), ("knob2",1)], pinned: true, pinMargin: "", spacing: "-s1-")
        
        addPatchChangeBlock(path: [.pt, .number]) { track.pointCount = $0 == 0 ? 12 : 16 }
        (-16...16).forEach { step in
          addPatchChangeBlock(path: [.pt, .i(step)]) { track.set(point: step, level: CGFloat($0) / 100) }
        }
        
        addColorToAll(level: 3)
      }
    }
    
    
    class ModController : NewPatchEditorController {
      override var prefix: SynthPath? { return [.mod, .i(index)] }
      
      private let src = PBSelect(label: "Src")
      
      override var index: Int {
        didSet { src.label = "Mod \(index + 1) Src" }
      }
      
      override func loadView(_ view: PBView) {
        grid(view: view, items: [[
          (src, [.src]),
          (PBKnob(label: "Level"), [.level]),
          (PBKnob(label: "Offset"), [.offset]),
          (PBSelect(label: "Dest"), [.dest]),
          ]])
        
        addPatchChangeBlock(paths: [[.src], [.dest]]) { (values) in
          guard let src = values[[.src]],
                let dest = values[[.dest]] else { return }
          view.alpha = src == 0 || dest == 0 ? 0.4 : 1
        }
        
        addColor(view: view, level: 2)
      }
      
    }
  }
  
  class FXController : NewPatchEditorController {
    
    override func loadView() {
      let view = PaddedContainer()
      addChild(FX0Controller(), withPanel: "fx0")
      addChild(FX1Controller(), withPanel: "fx1")
      addPanelsToLayout(andView: view.mainView)
      
      layout.addGridConstraints([
        [("fx0", 1)],
        [("fx1", 1)],
      ], spacing: "-s1-")
                  
      layout.activateConstraints()
      self.view = view
      addColorToAll()
    }

    
    class FX0Controller : NewPatchEditorController, MicronFXController {
      override var prefix: SynthPath? { return [.fx, .i(0)] }

      let paramKnobs: [PBKnob] = (0..<8).map { PBKnob(label: "\($0)") }
      
      override func loadView(_ view: PBView) {
        grid(panel: "mix", items: [[(PBKnob(label: "FX Mix"), [.mix])]])

        grid(panel: "fx", items: [[
          (PBSelect(label: "FX 1"), [.type]),
        ] + (0..<8).map { (paramKnobs[$0], [.param, .i($0)]) }
        ])
        
        addPanelsToLayout(andView: view)
        layout.addGridConstraints([[("mix", 1.5), ("fx", 10)]], pinMargin: "", spacing: "-s1-")
        
        addPatchChangeBlock(path: [.type]) { [weak self] in
          self?.updateParamKnobs(info: MicronFX.allFX0[$0].params)
        }
        
        addColorToAll()
      }
    }

    class FX1Controller : NewPatchEditorController, MicronFXController {
      override var prefix: SynthPath? { return [.fx, .i(1)] }

      let paramKnobs: [PBKnob] = (0..<5).map { PBKnob(label: "\($0)") }

      override func loadView(_ view: PBView) {
        grid(panel: "mix", items: [[(PBKnob(label: "Bal (1/2)"), [.balance])]])

        grid(panel: "fx", items: [[
          (PBSelect(label: "FX 2"), [.type]),
        ] + (0..<5).map { (paramKnobs[$0], [.param, .i($0)]) }
        ])
        
        addPanelsToLayout(andView: view)
        layout.addGridConstraints([[("mix", 1.5), ("fx", 10)]], pinMargin: "", spacing: "-s1-")

        addPatchChangeBlock(path: [.type]) { [weak self] in
          self?.updateParamKnobs(info: MicronFX.allFX1[$0].params)
        }
        addColorToAll()
      }
    }
  }
}

protocol MicronFXController where Self: NewPatchEditorController {
  var paramKnobs: [PBKnob] { get }

  func updateParamKnobs(info: [Int:(String,Param)])
}

extension MicronFXController {
  func updateParamKnobs(info: [Int:(String,Param)]) {
    paramKnobs.enumerated().forEach { (i, ctrl) in
      guard let pair = info[i] else {
        return ctrl.isHidden = true
      }
      ctrl.label = pair.0
      defaultConfigure(control: ctrl, forParam: pair.1)
      ctrl.isHidden = false
    }
  }
}

