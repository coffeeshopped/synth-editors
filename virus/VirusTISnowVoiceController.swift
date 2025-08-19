
class VirusTISnowVoiceController : NewPagedEditorController {
  
  private let mainController = MainController()
  private let modsController = ModsController()
  private let fxController = FXController()
  private let arpController = ArpController()
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch", "bottom"])
    addPanelsToLayout(andView: view)

    layout.addRowConstraints([
      ("switch", 4),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("bottom",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1),("page",7), ("bottom", 1)
      ], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Main", "Mod", "FX", "Arp"])
    quickGrid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil, "switchCtrl")]])
    
    addColor(panels: ["switch", "bottom"], clearBackground: true)
  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return mainController
    case 1:
      return modsController
    case 2:
      return fxController
    default:
      return arpController
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
      createPanels(forKeys: ["det", "sync", "punch", "sub", "noise", "ring", "fm", "key", "filter0", "common", "smooth", "cat"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("osc0", 11), ("sync", 5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("osc1", 11), ("det", 1), ("punch", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("osc2", 4.5), ("sub", 2), ("noise", 2), ("ring", 1), ("fm", 4.5), ("key", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("filter0", 9), ("fEnv", 7)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("filter1", 9), ("filterKey", 7)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("common", 9), ("amp", 7)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("smooth", 1.5), ("cat", 3)], pinned: false, spacing: "-s1-")
      layout.addColumnConstraints([("osc0", 1), ("osc1", 1), ("osc2", 1), ("filter0", 1), ("filter1", 1), ("common", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("amp", 1), ("smooth", 1)]  , pinned: false, spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["amp", "cat"], attribute: .trailing)
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
        (PBKnob(label: "Detune"), [.unison, .detune]),
        (PBKnob(label: "Pan Spread"), [.unison, .pan]),
        (PBKnob(label: "LFO Phase"), [.unison, .phase]),
        (PBKnob(label: "Atomizer"), [.loop]),
        (PBSwitch(label: "Input Mode"), [.input, .mode]),
        (PBSwitch(label: "Input Sel"), [.input, .select]),
      ]])
      
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
      addColor(panels: ["amp", "common", "smooth", "cat"], level: 3)
    }
    
  }
  
  
  class OscController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.osc, .i(index)] }
    
    convenience init(osc: Int) {
      self.init()
      index = osc
    }

    override func loadView(_ view: PBView) {
      let shape = PBKnob(label: "Shape")
      let wave = PBSelect(label: "Wave Select")
      let pw = PBKnob(label: "PW")
      let semi = PBKnob(label: "Semitone")
      let key = PBKnob(label: "Keyfollow")
      let local = PBKnob(label: "Local Detune")
      let fshift = PBKnob(label: "Frmt Shift")
      let fspread = PBKnob(label: "Frmt Spread")
      let interp = PBKnob(label: "Interp")
      
      grid(view: view, items: [[
        (PBSelect(label: "Osc \(index + 1) Mode"), [.mode]),
        (shape, [.shape]),
        (PBKnob(label: "← Velo"), [.shape, .velo]),
        (wave, [.wave]),
        (pw, [.pw]),
        (semi, [.semitone]),
        (key, [.keyTrk]),
        (local, [.local, .detune]),
        (fshift, [.formant, .shift]),
        (fspread, [.formant, .pan]),
        (interp, [.int]),
      ]])
      
      addPatchChangeBlock(paths: [[.mode], [.shape]]) { [weak self] in
        guard let dMode = $0[[.mode]],
              let dShape = $0[[.shape]] else { return }
        var parms: [PBLabeledControl:Param?] = [:]
        
        switch dMode {
        case 0: // classic
          [local, fshift, fspread, interp].forEach { $0.isHidden = true }
          pw.isHidden = dShape < 64
          wave.isHidden = dShape >= 64
          shape.label = "Shape"
          parms[shape] = VirusTIVoicePatch.params[[.osc, .i(0), .shape]]
          parms[pw] = VirusTIVoicePatch.params[[.osc, .i(0), .pw]]
        case 1: // hypersaw
          [pw].forEach { $0.isHidden = false }
          [local, wave, fshift, fspread, interp].forEach { $0.isHidden = true }
          shape.label = "Density"
          parms[shape] = MisoParam.make(iso: VirusTIVoicePatch.oscDensityIso)
          parms[pw] = RangeParam()
        case 2: // wavetable
          [wave, interp].forEach { $0.isHidden = false }
          [local, pw, fshift, fspread].forEach { $0.isHidden = true }
        case 3: // wave pwm
          [wave, interp, pw, local].forEach { $0.isHidden = false }
          [fshift, fspread].forEach { $0.isHidden = true }
          parms[pw] = RangeParam()
        case 4, 6: // grain simple, formant simple
          [wave, interp, fshift].forEach { $0.isHidden = false }
          [local, pw, fspread].forEach { $0.isHidden = true }
        case 5, 7: // grain complex, formant complex
          [wave, interp, local, fshift, fspread].forEach { $0.isHidden = false }
          [pw].forEach { $0.isHidden = true }
        default:
          [wave, pw, local, fshift, fspread, interp].forEach { $0.isHidden = false }
        }
        
        wave.label = dMode == 0 ? "WaveSelect" : "WaveTable"
        parms[wave] = dMode == 0 ? VirusTIVoicePatch.params[[.osc, .i(0), .wave]] : MisoParam.make(options: VirusTIVoicePatch.wavetableOptions)
        pw.label = dMode == 1 ? "Local Detune" : "PW"
        if dMode > 1 {
          shape.label = "Index"
          parms[shape] = RangeParam()
        }

        
        parms.forEach {
          guard let parm = $0.value else { return }
          self?.defaultConfigure(control: $0.key, forParam: parm)
        }
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
      let spread = PBKnob(label: "Pan Sprd")
      
      grid(view: view, items: [[
        (PBCheckbox(label: "Cutoff Link"), [.filter, .cutoff, .link]),
        (PBSwitch(label: "Filter Sel"), [.filter, .select]),
        (PBSwitch(label: "Routing"), [.filter, .routing]),
        (PBKnob(label: "KeyFolBase"), [.filter, .keyTrk, .start]),
        (PBKnob(label: "Balance"), [.filter, .balance]),
        (spread, [.unison, .pan]),
        (PBSelect(label: "Saturation"), [.saturation, .type]),
      ]])

      addPatchChangeBlock(path: [.filter, .routing]) {
        spread.isHidden = $0 != 3
      }
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
        (PBKnob(label: "Sus Slope"), [.sustain, .slop]),
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
  
}
