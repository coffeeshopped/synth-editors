
class TG77VoiceAWMController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.element, .i(index), .wave] }

  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0
    paddedView.verticalPadding = 0.07
    let view = paddedView.mainView
        
    addChild(TG77FiltersController(), withPanel: "filter")
    addChild(PitchController(), withPanel: "pitch")
    addChild(AmpController(), withPanel: "amp")
    
    grid(panel: "lfo", items: [[
      (PBSelect(label: "LFO"), [.lfo, .i(0), .wave]),
      (PBKnob(label: "Speed"), [.lfo, .i(0), .speed]),
      (PBKnob(label: "Delay"), [.lfo, .i(0), .delay]),
      (PBKnob(label: "Phase"), [.lfo, .i(0), .phase]),
      ],[
      (PBKnob(label: "Pitch"), [.lfo, .i(0), .pitch]),
      (PBKnob(label: "Amp"), [.lfo, .i(0), .amp]),
      (PBKnob(label: "Filter"), [.lfo, .i(0), .filter]),
      ]])
    
    let menuButton = createMenuButton(titled: "AWM Element")
    grid(panel: "space", items: [[(menuButton, nil)]])

    createPanels(forKeys: ["space2"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("pitch", 5), ("filter", 7), ("space", 5)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("pitch", 4), ("lfo", 2)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("filter", 5), ("space2", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("space", 1), ("amp", 5)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")

    layout.activateConstraints()
    self.view = paddedView
    
    registerForEditMenu(menuButton, bundle: (
      paths: { Self.AllPaths },
      pasteboardType: "com.cfshpd.TG77AWMElement",
      initialize: nil,
      randomize: nil
    ))
    
    addColor(panels: ["pitch", "amp", "lfo"], level: 2)
    addColor(panels: ["space"], level: 2, clearBackground: true)
  }
    
  static let AllPaths: [SynthPath] = TG77VoicePatch.paramKeys().compactMap {
    guard $0.starts(with: [.element, .i(0), .wave]) else { return nil }
    return $0.subpath(from: 3)
  }
  
  
  class PitchController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      let env = PitchEnvController()
      addChild(env)
      let waveSrc = PBSwitch(label: "Wave Src")
      let wave = PBSelect(label: "Wave")
      let fixedNote = PBKnob(label: "Fixed Note")

      grid(view: view, items: [[
        (waveSrc, [.src]),
        (wave, nil),
        (PBSwitch(label: "Freq Mode"), [.freq, .mode]),
        (PBKnob(label: "Fine"), [.freq, .fine]),
        (fixedNote, [.fixed, .note]),
        ],[
        (env.view, nil),
        (PBCheckbox(label: "Velo"), [.pitch, .velo]),
        (PBSwitch(label: "Range"), [.pitch, .env, .range]),
        (PBKnob(label: "Pitch Mod"), [.pitch, .mod]),
        ],[
        (PBKnob(label: "L0"), [.pitch, .env, .level, .i(-1)]),
        (PBKnob(label: "L1"), [.pitch, .env, .level, .i(0)]),
        (PBKnob(label: "L2"), [.pitch, .env, .level, .i(1)]),
        (PBKnob(label: "L3"), [.pitch, .env, .level, .i(2)]),
        (PBKnob(label: "RL"), [.pitch, .env, .release, .level, .i(0)]),
        ],[
        (PBKnob(label: "Rate Scale"), [.pitch, .rate, .scale]),
        (PBKnob(label: "R1"), [.pitch, .env, .rate, .i(0)]),
        (PBKnob(label: "R2"), [.pitch, .env, .rate, .i(1)]),
        (PBKnob(label: "R3"), [.pitch, .env, .rate, .i(2)]),
        (PBKnob(label: "RR"), [.pitch, .env, .release, .rate, .i(0)]),
        ]])
      
      addDefaultPatchChangeBlock(control: wave, path: [.wave])
      addDefaultControlChangeBlock(control: wave, path: [.wave])
      addPatchChangeBlock(path: [.src]) {
        switch $0 {
        case 0:
          wave.options = TG77VoicePatch.waveOptions
          wave.isHidden = false
        case 1:
          wave.options = TG77VoicePatch.blankWaveOptions
          wave.isHidden = false
        default:
          wave.isHidden = true
        }
      }
      addPatchChangeBlock(path: [.freq, .mode]) { fixedNote.isHidden = $0 == 0 }
    }
  }
  
  class PitchEnvController : NewPatchEditorController, TG77EnvelopeController {
    let env = TG77EnvelopeControl(label: "Pitch")

    override var prefix: SynthPath? { return [.pitch, .env] }
    
    override func loadView() {
      env.pointCount = 3
      env.sustainPoint = 2
      env.releaseCount = 1
      env.bipolar = true
      self.view = env
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      addRateLevelBlocks()
      
      registerForEditMenu(env, bundle: (
        paths: { [
          [.rate, .i(0)], [.rate, .i(1)], [.rate, .i(2)],
          [.release, .rate, .i(0)],
          [.level, .i(0)], [.level, .i(1)], [.level, .i(2)],
          [.level, .i(-1)],
          [.release, .level, .i(0)],
        ] },
        pasteboardType: "com.cfshpd.TG77PitchEnv",
        initialize: nil,
        randomize: nil
      ))
    }
  }
  
  
  class AmpController : NewPatchEditorController {
    override var prefix: SynthPath? { [.amp] }
    override func loadView(_ view: PBView) {
      let env = AmpEnvController()
      addChild(env)

      grid(view: view, items: [[
        (env.view, nil),
        (PBKnob(label: "Velo Sens"), [.velo]),
        (PBKnob(label: "Amp Mod"), [.mod]),
        ],[
        (PBSwitch(label: "EG Mode"), [.env, .mode]),
        (PBKnob(label: "L2"), [.env, .level, .i(1)]),
        (PBKnob(label: "L3"), [.env, .level, .i(2)]),
        (PBKnob(label: "Rate Scale"), [.rate, .scale]),
        (PBCheckbox(label: "Attack Velo"), [.attack, .velo]),
        ],[
        (PBKnob(label: "R1"), [.env, .rate, .i(0)]),
        (PBKnob(label: "R2"), [.env, .rate, .i(1)]),
        (PBKnob(label: "R3"), [.env, .rate, .i(2)]),
        (PBKnob(label: "R4"), [.env, .rate, .i(3)]),
        (PBKnob(label: "RR"), [.env, .release, .rate, .i(0)]),
        ],[
        (PBKnob(label: "BP 1"), [.level, .scale, .pt, .i(0)]),
        (PBKnob(label: "BP 2"), [.level, .scale, .pt, .i(1)]),
        (PBKnob(label: "BP 3"), [.level, .scale, .pt, .i(2)]),
        (PBKnob(label: "BP 4"), [.level, .scale, .pt, .i(3)]),
        ],[
        (PBKnob(label: "Offset 1"), [.level, .scale, .offset, .i(0)]),
        (PBKnob(label: "Offset 2"), [.level, .scale, .offset, .i(1)]),
        (PBKnob(label: "Offset 3"), [.level, .scale, .offset, .i(2)]),
        (PBKnob(label: "Offset 4"), [.level, .scale, .offset, .i(3)]),
        ]])
    }
  }
  
  class AmpEnvController : NewPatchEditorController, TG77EnvelopeController {
    let env = TG77EnvelopeControl(label: "Amp")

    override var prefix: SynthPath? { return [.env] }
    
    override func loadView() {
      env.pointCount = 4
      env.releaseCount = 1
      env.set(level: 1, forIndex: 0)
      self.view = env
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      addRateLevelBlocks()

      let env = self.env
      addPatchChangeBlock(paths: [[.rate, .i(0)], [.mode]]) { values in
        guard let r0 = values[[.rate, .i(0)]],
              let mode = values[[.mode]] else { return }
        let scaledR0 = CGFloat(r0) / 63
        if mode == 1 { // hold mode
          env.startLevel = 1
          env.holdTime = scaledR0
          env.set(rate: 63, forIndex: 0)
        }
        else {
          env.startLevel = 0
          env.holdTime = 0
          env.set(rate: scaledR0, forIndex: 0)
        }
      }

      registerForEditMenu(env, bundle: (
        paths: { [
          [.rate, .i(0)], [.rate, .i(1)], [.rate, .i(2)], [.rate, .i(3)],
          [.mode],
          [.release, .rate, .i(0)],
          [.level, .i(1)], [.level, .i(2)],
        ] },
        pasteboardType: "com.cfshpd.TG77AmpEnv",
        initialize: nil,
        randomize: nil
      ))
    }
    
  }
}
