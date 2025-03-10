
class NordLead2SensController : NewPatchEditorController {
  
  var sensEditMode = false {
    didSet { sensPaths.keys.forEach { $0.sensMode = sensEditMode } }
  }
  
  private var sensPaths = [NordSensKnob:SynthPath]()
  
  override func addBlocks(control: PBLabeledControl, path: SynthPath, paramAfterBlock: (() -> Void)? = nil, patchChangeAssignBlock: ((Int) -> Void)? = nil, controlChangeValueBlock: (() -> Int?)? = nil) {
    super.addBlocks(control: control, path: path, paramAfterBlock: paramAfterBlock, patchChangeAssignBlock: patchChangeAssignBlock, controlChangeValueBlock: controlChangeValueBlock)
    
    guard let control = control as? NordSensKnob else { return }
    let sensPath = path + [.sens]
    addPatchChangeBlock(path: sensPath) { control.sensValue = $0 }
    // macOS version of the knob has the action baked in
    #if os(iOS)
    control.addTarget(self, action: #selector(sensChange(_:)), for: .value2Changed)
    #endif
    sensPaths[control] = sensPath
    
    addColorBlock { [weak self] in
      let sensColor = $0.colors[2]
      self?.sensPaths.keys.forEach { $0.sensColor = sensColor }
    }
  }
  
  @IBAction final func sensChange(_ control: NordSensKnob) {
    guard let path = sensPaths[control] else { return }
    pushPatchChange(.paramsChange([path:control.sensValue]))
  }
  
}

class NordLead2PaddedMainController : NewPatchEditorController {
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.verticalPadding = 0.25
    paddedView.horizontalPadding = 0
    
    let vc = NordLead2MainController()
    addChild(vc)
    paddedView.mainView.fill(withSubview: vc.view)
    
    self.view = paddedView
  }
}

class NordLead2MainController : NordLead2SensController {
    
  private var sensControllers: [NordLead2SensController]!
  
  override var sensEditMode: Bool {
    didSet { sensControllers?.forEach { $0.sensEditMode = sensEditMode } }
  }

  override func loadView(_ view: PBView) {
    let lfo2Controller = NordLead2LFO2Controller()
    let ampController = NordLead2AmpController()
    let filterController = NordLead2FilterController()
    sensControllers = [lfo2Controller, ampController, filterController]
        
    addChild(lfo2Controller, withPanel: "lfo2")
    addChild(ampController, withPanel: "amp")
    addChild(filterController, withPanel: "filter")
    
    grid(panel: "lfo1", items: [[
      (NordSensKnob(label: "LFO 1 Rate"), [.lfo, .i(0), .rate]),
      (PBSelect(label: "Wave"), [.lfo, .i(0), .wave]),
      (PBSelect(label: "Destination"), [.lfo, .i(0), .dest]),
      (NordSensKnob(label: "Amount"), [.lfo, .i(0), .amt]),
      ]])

    grid(panel: "modEnv", items: [[
      (NordSensKnob(label: "Attack"), [.mod, .env, .attack]),
      (NordSensKnob(label: "Decay"), [.mod, .env, .decay]),
      (PBSelect(label: "Env Dest"), [.mod, .env, .dest]),
      (NordSensKnob(label: "Amount"), [.mod, .env, .amt]),
      ]])

    let fmKnob = NordSensKnob(label: "FM Amount")
    grid(panel: "osc1", items: [[
      (PBSwitch(label: "Osc 1 Wave"), [.osc, .i(0), .wave]),
      ],[
      (fmKnob, [.fm, .amt])
      ]])
    
    let semitonesKnob = NordSensKnob(label: "Semitones")
    let osc2WaveDropdown = PBSwitch(label: "Osc 2 Wave")
    grid(panel: "osc2", items: [[
      (osc2WaveDropdown, [.osc, .i(1), .wave]),
      (semitonesKnob, [.osc, .i(1), .pitch]),
      ],[
      (PBCheckbox(label: "Key Track"), [.osc, .i(1), .keyTrk]),
      (NordSensKnob(label: "Fine"), [.osc, .i(1), .fine]),
      ]])
    
    grid(panel: "oscMod", items: [[
      (NordSensKnob(label: "PW"), [.pw]),
      (PBCheckbox(label: "Ring Mod"), [.ringMod]),
      (PBCheckbox(label: "Sync"), [.sync]),
      (NordSensKnob(label: "Mix"), [.mix]),
      ]])
    
    grid(panel: "mod", items: [[
      (NordSensKnob(label: "Octave Shift"), [.octave, .shift]),
      (PBSelect(label: "Mod Wheel"), [.modWheel, .dest]),
      (PBCheckbox(label: "Unison"), [.unison]),
      (PBSwitch(label: "Voice Mode"), [.voice, .mode]),
      (PBCheckbox(label: "Auto"), [.auto]),
      (NordSensKnob(label: "Portamento"), [.porta]),
      ]])
    
    let sensToggleCheckbox = PBCheckbox(label: "Morph/Velocity Edit")
    sensToggleCheckbox.addValueChangeTarget(self, action: #selector(toggleSensMode(_:)))
    grid(panel: "morph", items: [[(sensToggleCheckbox, nil)]])
    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("lfo1" , 10), ("osc1" , 3), ("osc2" , 5), ("amp" , 14),
      ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([
      ("mod", 6), ("morph", 10),
      ], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("lfo1", 1), ("lfo2", 1), ("modEnv", 1), ("mod", 1),
      ], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("amp",1), ("filter", 2),
      ], pinned: false, spacing: "-s1-")
    
    layout.addEqualConstraints(forItemKeys: ["lfo1","lfo2","modEnv"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["amp","filter"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["lfo2", "osc1", "osc2"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["osc1","oscMod"], attribute: .leading)
    layout.addEqualConstraints(forItemKeys: ["osc2","oscMod"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["modEnv","oscMod"], attribute: .top)
    layout.addEqualConstraints(forItemKeys: ["modEnv","oscMod","filter"], attribute: .bottom)
    
    addPatchChangeBlock(paths: [[.osc, .i(1), .wave], [.sync]]) { (values) in
      guard let wave = values[[.osc, .i(1), .wave]],
            let sync = values[[.sync]] else { return }
      if wave == 3 {
        // if noise selected
        semitonesKnob.label = sync == 1 ? "Sync Wave" : "Noise Colour"
        semitonesKnob.displayOffset = 0
      }
      else {
        // no noise, no sync
        semitonesKnob.label = "Semitones"
        semitonesKnob.displayOffset = -60
      }
      
      var options = NordLead2VoicePatch.osc2WaveOptions
      if sync == 1 { options[3] = "Sync Wave" }
      osc2WaveDropdown.options = options
    }
    
    addPatchChangeBlock(path: [.ringMod]) { fmKnob.label = $0 == 1 ? "Ring Mod Tune" : "FM Amount" }

    addColorToAll(except: ["morph"])
    addColor(panels: ["morph"], level: 2)

  }
    
  
  @IBAction func toggleSensMode(_ sender: PBLabeledControl) {
    sensEditMode = sender.value == 1
  }

}


class NordLead2LFO2Controller : NordLead2SensController {
  
  override func loadView(_ view: PBView) {
    let rangeKnob = NordSensKnob(label:"")
    grid(view: view, items: [[
      (NordSensKnob(label: "Rate"), [.lfo, .i(1), .rate]),
      (PBSelect(label: "Arp/LFO"), [.lfo, .i(1), .dest]),
      (rangeKnob, [.arp, .range]),
      ]])

    addPatchChangeBlock(path: [.lfo, .i(1), .dest]) {
      let isArp = $0 < 3 || $0 == 5 || $0 == 6
      rangeKnob.label = isArp ? "Arp Range" : "Amount"
      rangeKnob.valueMap = isArp ? Self.arpRangeOptions : nil
    }
  }
  
  private static let arpRangeOptions: [String] = {
    // 1, 32, 64, 102
    var options = [Int:String]()
    options[0] = "Off"
    (1...31).forEach { options[$0] = "1" }
    (32...63).forEach { options[$0] = "2" }
    (64...101).forEach { options[$0] = "3" }
    (102...127).forEach { options[$0] = "4" }
    return options.sorted{ $0.0 < $1.0 }.map{ $0.1 }
  }()
}


class NordLead2AmpController : NordLead2SensController {
  override var prefix: SynthPath? { return [.amp] }
  
  override func loadView(_ view: PBView) {
    let envController = NordLead2EnvController()
    envController.env.label = "Amp"
    addChild(envController)
    grid(view: view, items: [[
      (envController.view, nil),
      (NordSensKnob(label: "Attack"), [.env, .attack]),
      (NordSensKnob(label: "Decay"), [.env, .decay]),
      (NordSensKnob(label: "Sustain"), [.env, .sustain]),
      (NordSensKnob(label: "Release"), [.env, .release]),
      (NordSensKnob(label: "Gain"), [.gain]),
      ]])
  }
}


class NordLead2FilterController : NordLead2SensController {
  override var prefix: SynthPath? { return [.filter] }
  
  override func loadView(_ view: PBView) {
    let envController = NordLead2EnvController()
    envController.env.label = "Filter"
    addChild(envController)
    grid(view: view, items: [[
      (envController.view, nil),
      (NordSensKnob(label: "Attack"), [.env, .attack]),
      (NordSensKnob(label: "Decay"), [.env, .decay]),
      (NordSensKnob(label: "Sustain"), [.env, .sustain]),
      (NordSensKnob(label: "Release"), [.env, .release]),
      (PBSelect(label: "Filter Type"), [.type]),
      ],[
      (NordSensKnob(label: "Frequency"), [.cutoff]),
      (NordSensKnob(label: "Resonance"), [.reson]),
      (NordSensKnob(label: "Amount"), [.env, .amt]),
      (PBCheckbox(label: "Velo"), [.velo]),
      (PBSwitch(label: "Key Track"), [.keyTrk]),
      (PBCheckbox(label: "Distortion"), [.dist]),
      ]])
  }
}

class NordLead2EnvController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.env] }
  
  fileprivate let env = PBAdsrEnvelopeControl(label: "")

  override func loadView() {
    let env = self.env
    addPatchChangeBlock(path: [.attack]) { env.attack = CGFloat($0) / 127 }
    addPatchChangeBlock(path: [.decay]) { env.decay = CGFloat($0) / 127 }
    addPatchChangeBlock(path: [.sustain]) { env.sustain = CGFloat($0) / 127 }
    addPatchChangeBlock(path: [.release]) { env.rrelease = CGFloat($0) / 127 }
    
    registerForEditMenu(env, bundle: (
      paths: { [[.attack], [.decay], [.sustain], [.release]] },
      pasteboardType: "com.cfshpd.NordLead2Envelope",
      initialize: nil,
      randomize: nil
    ))

    self.view = env

  }
}
