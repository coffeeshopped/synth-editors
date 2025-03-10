
class BassStationIIVoiceController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    addChild(OscController(prefix: [.osc, .i(0)], label: "Osc 1"), withPanel: "osc0")
    addChild(OscController(prefix: [.osc, .i(1)], label: "Osc 2"), withPanel: "osc1")
    addChild(OscController(prefix: [.sub], label: "Osc 3"), withPanel: "osc2")
    addChild(SubController(), withPanel: "sub")
    
    let _: [LFOController] = addChildren(count: 2, panelPrefix: "lfo")
    addChild(EnvController(prefix: [.mod, .env], label: "Mod"), withPanel: "mod")
    addChild(EnvController(prefix: [.amp, .env], label: "Amp"), withPanel: "amp")

    grid(panel: "mix", items: [[
      (PBKnob(label: "Osc 1"), [.osc, .i(0), .level]),
      (PBKnob(label: "Noise"), [.noise, .level]),
      ],[
      (PBKnob(label: "Osc 2"), [.osc, .i(1), .level]),
      (PBKnob(label: "Ring"), [.ringMod, .level]),
      ],[
      (PBKnob(label: "Sub"), [.sub, .level]),
      (PBKnob(label: "Ext"), [.ext, .level]),
    ]])
    
    grid(panel: "afx", items: [[
      (PBSwitch(label: "Sub Mode"), [.sub, .mode]),
      (PBKnob(label: "Overlay"), [.extra]),
    ]])

    grid(panel: "para", items: [[
      (PBCheckbox(label: "Paraphonic"), [.paraphonic]),
      (PBKnob(label: "Glide"), [.porta]),
      (PBKnob(label: "Divergence"), [.glide, .split]),
      (PBKnob(label: "Bend"), [.bend]),
      (PBKnob(label: "Osc Error"), [.osc, .slop]),
      (PBCheckbox(label: "Osc Sync"), [.sync]),
    ]])

    let shape = PBSwitch(label: "Shape")
    let slope = PBSwitch(label: "Slope")
    grid(panel: "filter", items: [[
      (PBSwitch(label: "Filter Type"), [.filter, .type]),
      (shape, [.filter, .shape]),
      (slope, [.filter, .slop]),
      (PBKnob(label: "Cutoff"), [.filter, .cutoff]),
      (PBKnob(label: "Reson"), [.filter, .reson]),
      (PBKnob(label: "Overdrive"), [.filter, .drive]),
      (PBSelect(label: "Track"), [.filter, .trk]),
      (PBKnob(label: "Env Amt"), [.filter, .mod, .env, .cutoff, .amt]),
      (PBKnob(label: "LFO2 Amt"), [.filter, .lfo, .i(1), .cutoff, .amt]),
    ]])
    
    addPatchChangeBlock(path: [.filter, .type]) {
      let alpha: CGFloat = $0 == 0 ? 1 : 0.2
      shape.alpha = alpha
      slope.alpha = alpha
    }
    
    grid(panel: "fx", items: [[
      (PBKnob(label: "Distortion"), [.dist]),
      (PBKnob(label: "Osc Filter Mod"), [.osc, .filter, .mod]),
      ],[
      (PBKnob(label: "Limiter"), [.limiter]),
      (PBKnob(label: "MicroTune"), [.micro, .tune]),
    ]])
        
    let wheelLabel = LabelItem(text: "Mod Wheel", gridWidth: 1)
    wheelLabel.textAlignment = .center
    grid(panel: "wheel", items: [[
      (PBKnob(label: "LFO1>Pitch"), [.mod, .lfo, .i(0), .pitch]),
      (PBKnob(label: "LFO2>Cutoff"), [.mod, .lfo, .i(1), .filter, .cutoff]),
      (PBKnob(label: "Cutoff"), [.mod, .filter, .cutoff]),
      (PBKnob(label: "Osc2 Pitch"), [.mod, .osc, .i(1), .pitch]),
      ],[
      (wheelLabel, nil),
      ]])

    let afterLabel = LabelItem(text: "Aftertouch", gridWidth: 1)
    afterLabel.textAlignment = .center
    grid(panel: "after", items: [[
      (PBKnob(label: "LFO1>Pitch"), [.aftertouch, .lfo, .i(0), .pitch]),
      (PBKnob(label: "LFO2 Speed"), [.aftertouch, .lfo, .i(1), .speed]),
      (PBKnob(label: "Cutoff"), [.aftertouch, .filter, .cutoff]),
      ],[
      (afterLabel, nil),
      ]])

    let rhythm = PBKnob(label: "Rhythm")
    let arpOct = PBSwitch(label: "Octave")
    let arpSwing = PBKnob(label: "Swing")
    let arpMode = PBSelect(label: "Note Mode")
    let latch = PBCheckbox(label: "Latch")
    let retrig = PBCheckbox(label: "Retrig")
    grid(panel: "arp", items: [[
      (PBCheckbox(label: "Arp"), [.arp, .on]),
      (rhythm, [.arp, .rhythm]),
      ],[
      (arpOct, [.arp, .octave]),
      (arpSwing, [.arp, .swing]),
      ],[
      (arpMode, [.arp, .note, .mode]),
      ],[
      (latch, [.arp, .latch]),
      (retrig, [.arp, .seq, .retrigger]),
    ]])
    
    addPatchChangeBlock(path: [.arp, .on]) {
      let alpha: CGFloat = $0 == 1 ? 1 : 0.2
      [rhythm, arpOct, arpSwing, arpMode, latch, retrig].forEach { $0.alpha = alpha }
    }
    addPatchChangeBlock(path: [.sub, .mode]) { [weak self] in
      self?.panels["osc2"]?.alpha = $0 == 1 ? 1 : 0.2
    }
    
    addPatchChangeBlock(path: [.sub, .mode]) { [weak self] in
      self?.panels["osc2"]?.alpha = $0 == 1 ? 1 : 0.2
      self?.panels["sub"]?.alpha = $0 == 0 ? 1 : 0.2
    }

    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("mix", 2), ("osc0", 9), ("sub", 2)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("filter", 9), ("para", 6)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("mod", 6), ("amp", 6), ("fx", 2), ("arp", 2)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("lfo0", 3), ("lfo1", 3), ("wheel", 4), ("after", 3)], pinned: false, spacing: "-s1-")
    
    layout.addColumnConstraints([("mix", 3), ("filter", 1), ("mod", 2), ("lfo0", 2)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("osc0", 1), ("osc1", 1), ("osc2", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
    layout.addColumnConstraints([("sub", 2), ("afx", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
    
    layout.addEqualConstraints(forItemKeys: ["fx", "after"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["mix", "osc2", "afx"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["mod", "amp", "fx"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["after", "arp"], attribute: .bottom)
    
    addColor(panels: ["osc0", "osc1", "osc2", "mix", "sub", "afx", "para"])
    addColor(panels: ["filter", "fx"], level: 2)
    addColor(panels: ["mod", "amp", "lfo0", "lfo1", "wheel", "after", "arp"], level: 3)
  }
    
  
  class OscController : NewPatchEditorController {
    override var prefix: SynthPath? { return _prefix }
    private var _prefix: SynthPath?
        
    convenience init(prefix: SynthPath, label: String) {
      self.init()
      _prefix = prefix
      osc.label = label
    }

    private let osc = PBSwitch(label: "Osc")

    override func loadView(_ view: PBView) {
      let pwEnv = PBKnob(label: "Mod Env→")
      let pw = PBKnob(label: "PW")
      let pwLFO = PBKnob(label: "←LFO 2")

      grid(view: view, items: [[
        (osc, [.wave]),
        (PBSwitch(label: "Range"), [.octave]),
        (PBKnob(label: "Coarse"), [.coarse]),
        (PBKnob(label: "Fine"), [.fine]),
        (PBKnob(label: "Env Amt"), [.mod, .env, .pitch, .amt]),
        (PBKnob(label: "LFO 1 Amt"), [.lfo, .i(0), .pitch, .amt]),
        (pwEnv, [.mod, .env, .pw, .amt]),
        (pw, [ .pw]),
        (pwLFO, [.lfo, .i(1), .pw, .amt]),
      ]])
      
      addPatchChangeBlock(path: [.wave]) {
        let alpha: CGFloat = $0 == 3 ? 1 : 0.2
        [pwEnv, pw, pwLFO].forEach { $0.alpha = alpha }
      }
    }
  }
  
  class SubController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.sub] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSwitch(label: "Sub Shape"), [.sub, .wave]),
        (PBSwitch(label: "Octave"), [.sub, .octave]),
        ],[
        (PBKnob(label: "Coarse"), [.coarse]),
        (PBKnob(label: "Fine"), [.fine]),
      ]])
    }
  }
  
  class EnvController : NewPatchEditorController {
    let env = PBAdsrEnvelopeControl()
    
    override var prefix: SynthPath? { return _prefix }
    private var _prefix: SynthPath?
        
    convenience init(prefix: SynthPath, label: String) {
      self.init()
      _prefix = prefix
      env.label = label
    }
    
    override func loadView(_ view: PBView) {
      let retrig = PBCheckbox(label: "Retrigger")
      let rCount = PBKnob(label: "Retrig #")
      let decay = PBKnob(label: "Decay")
      grid(view: view, items: [[
        (env, nil),
        (PBSwitch(label: "Mode"), [.trigger]),
        (retrig, [.retrigger]),
        (rCount, [.retrigger, .number]),
        ],[
        (PBKnob(label: "Attack"), [.attack]),
        (decay, [.decay]),
        (PBKnob(label: "Sustain"), [.sustain]),
        (PBKnob(label: "Release"), [.release]),
        (PBCheckbox(label: "Fixed Dur"), [.fixed]),
        (PBKnob(label: "Velo"), [.velo]),
      ]])
      
      addPatchChangeBlock(path: [.fixed]) {
        retrig.alpha = $0 == 0 ? 1 : 0.2
        decay.label = $0 == 0 ? "Decay" : "Duration"
      }
      addPatchChangeBlock(paths: [[.fixed], [.retrigger]]) {
        guard let fixed = $0[[.fixed]],
              let r = $0[[.retrigger]] else { return }
        rCount.alpha = fixed == 0 && r == 1 ? 1 : 0.2
      }
      
      registerForEditMenu(env, bundle: (
        paths: { [[.attack], [.decay], [.sustain], [.release]] },
        pasteboardType: "com.cfshpd.BSIIEnv",
        initialize: { [0, 0, 127, 0] },
        randomize: { (0..<4).map { _ in (0...127).random()! } }
      ))
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      let env = self.env
      addPatchChangeBlock(path: [.attack]) { env.attack = CGFloat($0) / 127 }
      addPatchChangeBlock(path: [.decay]) { env.decay = CGFloat($0) / 127 }
      addPatchChangeBlock(path: [.sustain]) { env.sustain = CGFloat($0) / 127 }
      addPatchChangeBlock(path: [.release]) { env.rrelease = CGFloat($0) / 127 }
    }
  }
  
  class LFOController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.lfo, .i(index)] }
    
    override func loadView(_ view: PBView) {
      let rate = PBKnob(label: "Speed")
      grid(view: view, items: [[
        (PBSwitch(label: "LFO \(index + 1)"), [.wave]),
        (PBKnob(label: "Delay"), [.delay]),
        (rate, nil),
        ],[
        (PBCheckbox(label: "Key Sync"), [.key, .sync]),
        (PBKnob(label: "Slew"), [.slew]),
        (PBSwitch(label: "Mode"), [.time, .sync]),
      ]])
      
      addPatchChangeBlock(path: [.time, .sync]) { [weak self] in
        let label: String
        let path: SynthPath
        switch $0 {
        case 0:
          label = "Speed"
          path = [.speed]
        default:
          label = "Sync"
          path = [.sync]
        }
        rate.label = label
        rate.value = self?.latestValue(path: path) ?? 0
        if let param = self?.latestParam(path: path) {
          self?.defaultConfigure(control: rate, forParam: param)
        }
      }
      addPatchChangeBlock(paths: [[.speed], [.sync]]) { [weak self] in
        let mode = self?.latestValue(path: [.time, .sync]) ?? 0
        rate.value = $0[mode == 0 ? [.speed] : [.sync]] ?? 0
      }
      addControlChangeBlock(control: rate) { [weak self] in
        let mode = self?.latestValue(path: [.time, .sync]) ?? 0
        let path: SynthPath = mode == 0 ? [.speed] : [.sync]
        return .paramsChange([path : rate.value])
      }
    }
  }
  
}
