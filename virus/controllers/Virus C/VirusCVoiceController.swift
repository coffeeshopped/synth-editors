
class VirusCVoiceController : NewPagedEditorController {
  
  private let mainController = MainController()
  private var modsController: ModsController!
  
  private var multipart: Bool = false
  
  convenience init(multipart: Bool = false) {
    self.init()
    self.multipart = multipart
    self.modsController = ModsController(multipart: multipart)
  }
  
  override func loadView(_ view: PBView) {
    addChild(LFO0MiniController(), withPanel: "lfo0")
    addChild(LFO1MiniController(), withPanel: "lfo1")
    createPanels(forKeys: ["switch"])
    addPanelsToLayout(andView: view)

    layout.addRowConstraints([
      ("switch", 4), ("lfo0", 6.5), ("lfo1", 6.5)
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",7)
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Main", "Mod/FX"])
    quickGrid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil, "switchCtrl")]])
    
    addColor(panels: ["switch"], clearBackground: true)
    addColor(panels: ["lfo0", "lfo1"], level: 3)

  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return mainController
    default:
      return modsController
    }
  }
  
  class LFO0MiniController : LFOController {
    override var prefix: SynthPath? { return [.lfo, .i(0)] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSelect(label: "LFO 1 Shape"), [.shape]),
        (PBKnob(label: "Clock"), [.clock]),
        (rate, [.rate]),
        (PBKnob(label: "O1 Ptch"), [.osc]),
        (PBKnob(label: "O2 Ptch"), [.osc, .i(1)]),
        (PBKnob(label: "PW"), [.pw]),
      ]])
    }
  }
  
  class LFO1MiniController : LFOController {
    override var prefix: SynthPath? { return [.lfo, .i(1)] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSelect(label: "LFO 2 Shape"), [.shape]),
        (PBKnob(label: "Clock"), [.clock]),
        (rate, [.rate]),
        (PBKnob(label: "Cutoff 1"), [.cutoff]),
        (PBKnob(label: "Cutoff 2"), [.cutoff, .i(1)]),
        (PBKnob(label: "Osc Shape 1/2"), [.osc, .shape]),
      ]])
    }
  }
  
  class MainController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      addChild(OscController(osc: 0), withPanel: "osc0")
      addChild(OscController(osc: 1), withPanel: "osc1")
      addChild(Osc3Controller(), withPanel: "osc2")
      addChild(Filter2Controller(), withPanel: "filter1")
      addChild(FilterCommonController(), withPanel: "filterKey")
      addChild(EnvController(prefix: [.filter, .env], label: "Filter"), withPanel: "fEnv")
      addChild(EnvController(prefix: [.amp, .env], label: "Amp"), withPanel: "amp")
      addChild(ArpController(), withPanel: "arp")
      addChild(ModController(index: 0), withPanel: "mod0")
      addChild(ModController(index: 1), withPanel: "mod1")
      addChild(ModController(index: 2), withPanel: "mod2")
      createPanels(forKeys: ["det", "sync", "punch", "sub", "noise", "ring", "fm", "key", "filter0", "common", "smooth", "cat"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("osc0", 6.5), ("sync", 5), ("arp", 4.5)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("osc1", 6.5), ("det", 1), ("punch", 4)], pinned: false, spacing: "-s1-")
      layout.addRowConstraints([("osc2", 4.5), ("sub", 2), ("noise", 2), ("ring", 1), ("fm", 4.5), ("key", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("filter0", 9), ("fEnv", 7)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("filter1", 9), ("filterKey", 7)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("common", 9), ("amp", 7)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("smooth", 1.5), ("cat", 3), ("mod0", 4)], pinned: false, spacing: "-s1-")
      layout.addRowConstraints([("mod1", 6.5), ("mod2", 9)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("osc0", 1), ("osc1", 1), ("osc2", 1), ("filter0", 1), ("filter1", 1), ("common", 2), ("mod1", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("amp", 1), ("smooth", 1)]  , pinned: false, spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["sync", "punch"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["osc0", "sync"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["punch", "arp"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["amp", "mod0"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["common", "smooth"], attribute: .bottom)


      grid(panel: "det", items: [[
        (PBKnob(label: "Osc 2 Detune"), [.osc, .i(1), .detune]),
      ]])
      
      grid(panel: "sync", items: [[
        (PBCheckbox(label: "Sync"), [.osc, .i(0), .sync]),
        (PBKnob(label: "← F.Env"), [.filter, .env, .fm]),
        (PBKnob(label: "Osc Bal"), [.osc, .balance]),
        (PBKnob(label: "Osc Vol"), [.osc, .level]),
        (PBKnob(label: "F.Env→Ptch"), [.filter, .env, .pitch]),
      ]])
      
      grid(panel: "punch", items: [[
        (PBKnob(label: "Punch"), [.osc, .pushIt]),
        (PBKnob(label: "Phase Init"), [.osc, .innit, .phase]),
        (PBKnob(label: "Transpose"), [.transpose]),
        (PBKnob(label: "Porta"), [.porta]),
      ]])
      
      grid(panel: "sub", items: [[
        (PBSwitch(label: "Sub Shape"), [.sub, .shape]),
        (PBKnob(label: "Volume"), [.sub, .level]),
      ]])

      grid(panel: "noise", items: [[
        (PBKnob(label: "Noise"), [.noise, .level]),
        (PBKnob(label: "Color"), [.noise, .color]),
      ]])
      
      grid(panel: "ring", items: [[
        (PBKnob(label: "Ring Mod"), [.ringMod, .level]),
      ]])

      grid(panel: "fm", items: [[
        (PBSelect(label: "FM Mode"), [.fm, .mode]),
        (PBKnob(label: "Amount"), [.fm, .amt]),
        (PBKnob(label: "← Velo"), [.velo, .fm]),
        (PBKnob(label: "F.Env→FM"), [.filter, .env, .fm]),
      ]])

      grid(panel: "key", items: [[
        (PBKnob(label: "Velo→PW"), [.velo, .pw]),
      ]])
      
      grid(panel: "filter0", items: [[
        (PBSelect(label: "Filter 1 Mode"), [.filter, .i(0), .mode]),
        (PBKnob(label: "Cutoff"), [.filter, .i(0), .cutoff]),
        (PBKnob(label: "Reson"), [.filter, .reson]),
        (PBKnob(label: "← Velo"), [.velo, .filter, .i(0), .reson]),
        (PBKnob(label: "Env Amt"), [.filter, .env, .amt]),
        (PBKnob(label: "← Velo"), [.velo, .filter, .i(0), .env]),
        (PBSwitch(label: "Env Polar"), [.filter, .i(0), .env, .polarity]),
        (PBKnob(label: "Key Trk"), [.filter, .keyTrk]),
      ]])
      
      let uniDet = PBKnob(label: "Detune")
      let uniPan = PBKnob(label: "Pan Spread")
      let uniPhase = PBKnob(label: "LFO Phase")
      grid(panel: "common", items: [[
        (PBKnob(label: "Tempo"), [.tempo]),
        (PBKnob(label: "Patch Vol"), [.volume]),
        (PBKnob(label: "← Velo"), [.velo, .volume]),
        (PBKnob(label: "Pan"), [.pan]),
        (PBKnob(label: "← Velo"), [.velo, .pan]),
        (PBKnob(label: "Bend Dn"), [.bend, .down]),
        (PBKnob(label: "Bend Up"), [.bend, .up]),
        (PBSwitch(label: "Bend Scale"), [.bend, .scale]),
//        (PBSelect(label: "Surround Out"), [.]),
        (PBKnob(label: "Surr Bal"), [.surround, .balance]),
        ],[
        (PBSelect(label: "Key Mode"), [.osc, .key, .mode]),
        (PBKnob(label: "Unison"), [.unison, .mode]),
        (uniDet, [.unison, .detune]),
        (uniPan, [.unison, .pan]),
        (uniPhase, [.unison, .phase]),
        (PBSwitch(label: "Input Mode"), [.input, .mode]),
        (PBSelect(label: "Input Sel"), [.input, .select]),
      ]])
      
      addPatchChangeBlock(path: [.unison, .mode]) {
        let hidden = $0 == 0
        uniDet.isHidden = hidden
        uniPan.isHidden = hidden
        uniPhase.isHidden = hidden
      }
      
      grid(panel: "smooth", items: [[
        (PBSelect(label: "Smooth Mode"), [.param, .smooth]),
      ]])
            
      grid(panel: "cat", items: [[
        (PBSelect(label: "Cat 1"), [.category, .i(0)]),
        (PBSelect(label: "Cat 2"), [.category, .i(1)]),
      ]])
      
      addPatchChangeBlock(path: [.vocoder, .mode]) { [weak self] vocoderMode in
        ["filter0", "filter1", "filterKey", "fEnv"].forEach {
          self?.panels[$0]?.isHidden = vocoderMode > 0
        }
      }

      addColor(panels: ["osc0", "osc1", "osc2", "sync", "punch", "det", "sub", "noise", "ring", "fm", "key"], level: 1)
      addColor(panels: ["filter0", "filter1", "filterKey", "fEnv"], level: 2)
      addColor(panels: ["amp", "arp", "mod0", "mod1", "mod2", "common", "smooth", "cat"], level: 3)
    }
        
  }
  
  
  class OscController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.osc, .i(index)] }
    
    convenience init(osc: Int) {
      self.init()
      index = osc
    }

    override func loadView(_ view: PBView) {
      let shape = PBKnob(label: "Osc \(index + 1) Shape")
      let wave = PBSelect(label: "Wave Select")
      let pw = PBKnob(label: "PW")
      let semi = PBKnob(label: "Semitone")
      let key = PBKnob(label: "Keyfollow")
      
      grid(view: view, items: [[
        (shape, [.shape]),
        (PBKnob(label: "← Velo"), [.shape, .velo]),
        (wave, [.wave]),
        (pw, [.pw]),
        (semi, [.semitone]),
        (key, [.keyTrk]),
      ]])
      
      addPatchChangeBlock(paths: [[.shape]]) {
        guard let dShape = $0[[.shape]] else { return }
        
        pw.isHidden = dShape < 64
        wave.isHidden = dShape >= 64
      }
    }
  }
  
  class Osc3Controller : NewPatchEditorController {
    override var prefix: SynthPath? { return [.osc, .i(2)] }
    override func loadView(_ view: PBView) {
      let mode = PBSelect(label: "Osc 3 Mode")
      grid(view: view, items: [[
        (mode, [.mode]),
        (PBKnob(label: "Semitone"), [.semitone]),
        (PBKnob(label: "Volume"), [.level]),
        (PBKnob(label: "Detune"), [.fine]),
      ]])
      
      addPatchChangeBlock(path: [.mode]) { value in
        view.subviews.filter({ $0 != mode }).forEach { $0.isHidden = value < 2 }
      }
    }
  }
  
  
  class Filter2Controller : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      let cutoff = PBKnob(label: "Cutoff")
      
      grid(view: view, items: [[
        (PBSelect(label: "Filter 2 Mode"), [.filter, .i(1), .mode]),
        (cutoff, [.filter, .i(1), .cutoff]),
        (PBKnob(label: "Reson"), [.filter, .reson, .extra]),
        (PBKnob(label: "← Velo"), [.velo, .filter, .i(1), .reson]),
        (PBKnob(label: "Env Amt"), [.filter, .env, .extra]),
        (PBKnob(label: "← Velo"), [.velo, .filter, .i(1), .env]),
        (PBSwitch(label: "Env Polar"), [.filter, .i(1), .env, .polarity]),
        (PBKnob(label: "Key Trk"), [.filter, .keyTrk, .extra]),
      ]])
      
      addPatchChangeBlock(path: [.filter, .cutoff, .link]) { [weak self] in
        switch $0 {
        case 0:
          cutoff.label = "Cutoff"
          self?.defaultConfigure(control: cutoff, forParam: RangeParam())
        default:
          cutoff.label = "Offset"
          self?.defaultConfigure(control: cutoff, forParam: RangeParam(displayOffset: -64))
        }
      }
    }
  }
  
  class FilterCommonController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBCheckbox(label: "Cutoff Link"), [.filter, .cutoff, .link]),
        (PBSwitch(label: "Filter Sel"), [.filter, .select]),
        (PBSwitch(label: "Routing"), [.filter, .routing]),
        (PBKnob(label: "KeyFolBase"), [.filter, .keyTrk, .start]),
        (PBKnob(label: "Balance"), [.filter, .balance]),
        (PBSelect(label: "Saturation"), [.saturation, .type]),
      ]])
    }
  }
  
  
  class EnvController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return _prefix }
    private var _prefix: SynthPath?
    
    private let env = PBDadsrEnvelopeControl()
    
    convenience init(prefix: SynthPath, label: String) {
      self.init()
      _prefix = prefix
      env.label = label
    }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (env, nil),
        (PBKnob(label: "Attack"), [.attack]),
        (PBKnob(label: "Decay"), [.decay]),
        (PBKnob(label: "Sustain"), [.sustain]),
        (PBKnob(label: "Sus Time"), [.sustain, .slop]),
        (PBKnob(label: "Release"), [.release]),
      ]])
      
      let env = self.env
      addPatchChangeBlock(path: [.attack]) { env.attack = CGFloat($0) / 127 }
      addPatchChangeBlock(path: [.decay]) { env.decay = CGFloat($0) / 127 }
      addPatchChangeBlock(path: [.sustain]) { env.sustain = CGFloat($0) / 127 }
      addPatchChangeBlock(path: [.release]) { env.rrelease = CGFloat($0) / 127 }
      
      registerForEditMenu(env, bundle: (
        paths: {[[.attack], [.decay], [.sustain], [.sustain, .slop], [.release]]},
        pasteboardType: "com.cfshpd.VirusEnvelope",
        initialize: { [0, 127, 127, 64, 4] },
        randomize: { (0..<5).map { _ in (0...127).random()! } }
      ))
    }
  }
  
  
  class ArpController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.arp] }
    
    override func loadView(_ view: PBView) {
      let octave = PBKnob(label: "Octaves")
      let noteLen = PBKnob(label: "Note Len")
      let hold = PBCheckbox(label: "Hold")
      grid(view: view, items: [[
        (PBSelect(label: "Arp Mode"), [.mode]),
        (octave, [.range]),
        (PBKnob(label: "Pattern"), [.pattern]),
        ],[
        (PBSelect(label: "Resolution"), [.clock]),
        (noteLen, [.note, .length]),
        (PBKnob(label: "Swing"), [.swing]),
        (hold, [.hold]),
      ]])
      
      addPatchChangeBlock(path: [.mode]) { view.alpha = $0 == 0 ? 0.4 : 1 }
    }
  }

  
}
