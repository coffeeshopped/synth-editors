
class MinilogueMainController : NewPagedEditorController {
  
  private let notesViewController = MinilogueNotesController()
  private let motionViewController = MinilogueMotionController()
  private let notesActionController = MinilogueNotesController.ActionController()
  private let motionActionController = MinilogueMotionController.ActionController()
  
  override func loadView(_ view: PBView) {
    addChild(notesActionController)
    addChild(motionActionController)

    grid(panel: "osc1", items: [[
      (PBSwitch(label: "VCO 1"), [.osc, .i(0), .wave]),
      (PBSwitch(label: "Octave"), [.osc, .i(0), .octave]),
      (PBKnob(label: "Pitch", pixelsPerUnit: 1), [.osc, .i(0), .pitch]),
      (PBKnob(label: "Shape", pixelsPerUnit: 1), [.osc, .i(0), .shape]),
      ]])
    
    grid(panel: "osc2", items: [[
      (PBSwitch(label: "VCO 2"), [.osc, .i(1), .wave]),
      (PBSwitch(label: "Octave"), [.osc, .i(1), .octave]),
      (PBKnob(label: "Pitch", pixelsPerUnit: 1), [.osc, .i(1), .pitch]),
      (PBKnob(label: "Shape", pixelsPerUnit: 1), [.osc, .i(1), .shape]),
      ],[
      (PBKnob(label: "Cross Mod", pixelsPerUnit: 1), [.cross, .mod, .depth]),
      (PBKnob(label: "Pitch Env", pixelsPerUnit: 1), [.osc, .i(1), .pitch, .env, .amt]),
      (PBCheckbox(label: "Sync"), [.sync]),
      (PBCheckbox(label: "Ring"), [.ringMod]),
      ]])
    
    grid(panel: "mix", items: [
      [(PBKnob(label: "V1 Level", pixelsPerUnit: 1), [.osc, .i(0), .level])],
      [(PBKnob(label: "V2 Level", pixelsPerUnit: 1), [.osc, .i(1), .level])],
      [(PBKnob(label: "Noise", pixelsPerUnit: 1), [.noise, .level])]
      ])
    
    grid(panel: "filter", items: [[
      (PBKnob(label: "Cutoff", pixelsPerUnit: 1), [.cutoff]),
      (PBKnob(label: "Resonance", pixelsPerUnit: 1), [.reson]),
      ],[
      (PBSwitch(label: "Velocity"), [.cutoff, .velo]),
      (PBKnob(label: "Env Amt", pixelsPerUnit: 1), [.cutoff, .env, .amt]),
      ],[
      (PBCheckbox(label: "4-Pole"), [.cutoff, .type]),
      (PBSwitch(label: "Key Track"), [.cutoff, .key, .trk]),
      ]])
    
    grid(panel: "ampEnv", items: [[
      (PBKnob(label: "Amp Attack", pixelsPerUnit: 1), [.amp, .env, .attack]),
      (PBKnob(label: "Decay", pixelsPerUnit: 1), [.amp, .env, .decay]),
      (PBKnob(label: "Sustain", pixelsPerUnit: 1), [.amp, .env, .sustain]),
      (PBKnob(label: "Release", pixelsPerUnit: 1), [.amp, .env, .release]),
      ]])
    
    grid(panel: "env", items: [[
      (PBKnob(label: "EG Attack", pixelsPerUnit: 1), [.env, .attack]),
      (PBKnob(label: "Decay", pixelsPerUnit: 1), [.env, .decay]),
      (PBKnob(label: "Sustain", pixelsPerUnit: 1), [.env, .sustain]),
      (PBKnob(label: "Release", pixelsPerUnit: 1), [.env, .release]),
      ]])
    
    grid(panel: "porta", items: [[
      (PBSwitch(label: "Porta"), [.porta, .mode]),
      (PBKnob(label: "Porta Time"), [.porta, .time]),
      (PBCheckbox(label: "Porta BPM"), [.porta, .tempo]),
      ]])
    
    grid(panel: "lfo", items: [[
      (PBSwitch(label: "LFO Wave"), [.lfo, .wave]),
      (PBSwitch(label: "EG Mod"), [.lfo, .env]),
      ],[
      (PBKnob(label: "Rate", pixelsPerUnit: 1), [.lfo, .rate]),
      (PBKnob(label: "Int", pixelsPerUnit: 1), [.lfo, .amt]),
      (PBSwitch(label: "Target"), [.lfo, .dest]),
      ],[
      (PBCheckbox(label: "Key Sync"), [.lfo, .key, .sync]),
      (PBCheckbox(label: "BPM Sync"), [.lfo, .tempo, .sync]),
      (PBCheckbox(label: "Voice Sync"), [.lfo, .voice, .sync])
      ]])
    
    grid(panel: "delay", items: [[
      (PBSwitch(label: "Delay"), [.delay, .out]),
      (PBKnob(label: "HPF", pixelsPerUnit: 1), [.delay, .hi, .pass]),
      (PBKnob(label: "Time", pixelsPerUnit: 1), [.delay, .time]),
      (PBKnob(label: "Feedback", pixelsPerUnit: 1), [.delay, .feedback]),
      ]])
    
    let voiceModeDepthDropdown = PBSelect(label: "Chord")
    let voiceModeDepthKnob = PBKnob(label: "Chord", pixelsPerUnit: 1)
    grid(panel: "mode", items: [[
      (PBSelect(label: "Voice Mode"), [.voice, .mode]),
      (voiceModeDepthKnob, nil),
      (voiceModeDepthDropdown, nil),
      (PBSelect(label: "Slider"), [.slider]),
      (PBKnob(label: "Bend Up"), [.bend, .up]),
      (PBKnob(label: "Bend Down"), [.bend, .down]),
      ]])
    
    grid(panel: "oct", items: [[
      (PBKnob(label: "Keybd Oct"), [.key, .octave]),
      (PBKnob(label: "Level"), [.pgm, .level]),
      (PBKnob(label: "Velo"), [.amp, .velo]),
      ]])
    
    let ctrlSwitch = LabeledSegmentedControl(label: "Sequencer", items: ["Notes","Motion"])
    let partSwitch = LabeledSegmentedControl(label: "Part", items: ["1","2","3","4"])
    switchCtrl = ctrlSwitch.segmentedControl
    partSwitch.segmentedControl.addValueChangeTarget(self, action: #selector(selectPart(_:)))
    grid(panel: "switch", items: [[
      (ctrlSwitch, nil),
      (partSwitch, nil),
      (notesActionController.view, nil),
      (motionActionController.view, nil),
      ]])
    
    let tempoKnob = PBKnob(label: "Tempo")
    grid(panel: "tempo", items: [[
      (tempoKnob, nil),
      (PBKnob(label: "Step Length"), [.step, .length]),
      (PBSelect(label: "Step Resolution"), [.step, .resolution]),
      (PBKnob(label: "Swing"), [.swing]),
      (PBKnob(label: "Def Gate Time"), [.gate, .time]),
      ]])

    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("osc1",4), ("mix",1), ("filter",2), ("ampEnv",4), ("lfo",3),
      ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([
      ("delay",4), ("mode",7), ("oct",3),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([
      ("switch",8), ("tempo",5),
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([
      ("page",1),
      ], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("osc1",1),("osc2",2),("delay",1),("switch",1),("page",4)
      ], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("ampEnv",1),("env",1),("porta",1)
      ], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["lfo","oct","tempo","page"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["osc1","osc2"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["osc2","mix","filter","porta","lfo"], attribute: .bottom)

    tempoKnob.minimumValue = 50
    tempoKnob.maximumValue = 300
    addPatchChangeBlock(path: [.tempo]) { tempoKnob.value = $0 / 10 }
    addDefaultControlChangeBlock(control: tempoKnob, path: [.tempo]) { tempoKnob.value * 10 }
    
    addPatchChangeBlock(paths: [[.voice, .mode], [.voice, .mode, .depth]]) { (values) in
      guard let mode = values[[.voice, .mode]],
            let voiceMode = MinilogueVoiceMode(rawValue: mode),
            let depth = values[[.voice, .mode, .depth]] else { return }
      let range = Self.voiceModeDepthRange(voiceMode: voiceMode)
      
      var dropdownHidden = false
      let label = Self.voiceModeDepthLabel(voiceMode: voiceMode)
      voiceModeDepthKnob.label = label
      voiceModeDepthDropdown.label = label
      switch voiceMode {
      case .poly, .duo, .unison, .mono, .sidechain:
        voiceModeDepthKnob.minimumValue = range.lowerBound
        voiceModeDepthKnob.maximumValue = range.upperBound
        dropdownHidden = true
      case .chord:
        voiceModeDepthDropdown.options = MiniloguePatch.chordModeOptions
      case .delay:
        voiceModeDepthDropdown.options = MiniloguePatch.delayModeOptions
      case .arp:
        voiceModeDepthDropdown.options = MiniloguePatch.arpModeOptions
      }
      
      voiceModeDepthDropdown.isHidden = dropdownHidden
      voiceModeDepthKnob.isHidden = !dropdownHidden

      let v = depth.map(inRange: 0...1023, outRange: range)
      voiceModeDepthKnob.value = v
      voiceModeDepthDropdown.value = v
    }
    
    let ccBlock: ((PBLabeledControl) -> (() -> Int)) = { control in
      return { [weak self] in
        guard let mode = self?.latestValue(path: [.voice, .mode]),
              let voiceMode = MinilogueVoiceMode(rawValue: mode) else { return 0 }
        let range = Self.voiceModeDepthRange(voiceMode: voiceMode)
        return control.value.map(inRange: range, outRange: 0...1023)
      }
    }
    addDefaultControlChangeBlock(control: voiceModeDepthKnob, path: [.voice, .mode, .depth], valueBlock: ccBlock(voiceModeDepthKnob))
    addDefaultControlChangeBlock(control: voiceModeDepthDropdown, path: [.voice, .mode, .depth], valueBlock: ccBlock(voiceModeDepthDropdown))

    addColorToAll(except: ["switch"])
    addColor(panels: ["switch"], clearBackground: true)

  }
      
  @IBAction func selectPart(_ sender: PBSegmentedControl) {
    [notesViewController, motionViewController, notesActionController, motionActionController].forEach {
      $0.index = sender.selectedSegmentIndex
    }
  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    guard index < 2 else { return nil }
    [notesActionController, motionActionController].enumerated().forEach {
      $0.element.view.isHidden = $0.offset != index
    }
    return [notesViewController, motionViewController][index]
  }
  
  static func voiceModeDepthRange(voiceMode: MinilogueVoiceMode) -> ClosedRange<Int> {
    switch voiceMode {
    case .chord:
      return 0...(MiniloguePatch.chordModeOptions.count-1)
    case .delay:
      return 0...(MiniloguePatch.delayModeOptions.count-1)
    case .arp:
      return 0...(MiniloguePatch.arpModeOptions.count-1)
    case .poly:
      return 0...8
    case .duo, .unison:
      return 0...50
    case .mono, .sidechain:
      return 0...1023
    }
  }
  
  static func voiceModeDepthLabel(voiceMode: MinilogueVoiceMode) -> String {
    switch voiceMode {
    case .poly:
      return "Invert"
    case .duo, .unison:
      return "Detune"
    case .mono:
      return "Sub"
    case .sidechain:
      return "Sidechain"
    case .chord:
      return "Chord"
    case .delay:
      return "Delay"
    case .arp:
      return "Arp"
    }
  }
    
}
