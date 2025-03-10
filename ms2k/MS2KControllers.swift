
class KorgMVoiceController<TimbreController:KorgMTimbreController, VocoderController: PBViewController> : NewPatchEditorController {
  
  let timbreViewController = TimbreController()
  let vocoderViewController = VocoderController()
  let pageController = RxPatchPageController()
  private var lastIndex = 0
  
  func initCommonPanels() {
    quickGrid(panel: "mode", items: [[
      (PBSwitch(label: "Mode"), [.voice, .mode], nil),
      ]])
    
    quickGrid(panel: "fx", items: [[
      (PBSwitch(label: "Mod FX"), [.mod, .type], nil),
      (PBKnob(label: "Speed"), [.mod, .speed], nil),
      (PBKnob(label: "Depth"), [.mod, .depth], nil),
      ]])
    
    let delayTime = PBKnob(label: "Time")
    let delaySyncNote = PBKnob(label: "Note")
    quickGrid(panel: "delay", items: [[
      (PBSwitch(label: "Delay FX"), [.delay, .type], nil),
      (PBCheckbox(label: "Sync"), [.delay, .tempo, .sync], nil),
      (delayTime, [.delay, .time], nil),
      (delaySyncNote, [.delay, .sync, .note], nil),
      (PBKnob(label: "Depth"), [.delay, .depth], nil),
      ]])
    
    quickGrid(panel: "eq", items: [[
      (PBKnob(label: "Lo Freq"), [.lo, .freq], nil),
      (PBKnob(label: "Lo Gain"), [.lo, .gain], nil),
      (PBKnob(label: "Hi Freq"), [.hi, .freq], nil),
      (PBKnob(label: "Hi Gain"), [.hi, .gain], nil),
      ]])
    
    addPatchChangeBlock(path: [.delay, .tempo, .sync]) {
      delayTime.isHidden = $0 == 1
      delaySyncNote.isHidden = $0 == 0
    }
    // not doing this as normal page controller bc of feedback loop from param value setting index
    addPatchChangeBlock(path: [.voice, .mode]) { [weak self] in
      guard let lastIndex = self?.lastIndex else { return }
      guard let c = self?.viewController(forIndex: $0) else { return }
      let dir: RxPatchPageController.NavigationDirection = $0 > lastIndex ? .forward : .reverse
      self?.pageController.setViewControllers([c], direction: dir, animated: true)
    }    
  }
    
  func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 3:
      return vocoderViewController
    default:
      return timbreViewController
    }
  }

}

class MS2KPartController : NewPatchEditorController {
    
  let detune = PBKnob(label: "Detune")
  let dwgs = PBSelect(label: "DWGS")
  let trigger = PBSwitch(label: "Trigger")

  func initCommonPanels() {
    let detune = self.detune
    let dwgs = self.dwgs
    let trigger = self.trigger

    let ctrl1 = PBKnob(label: "Ctrl 1")
    let ctrl2 = PBKnob(label: "Ctrl 2")
    
    quickGrid(panel: "transpose", items: [[
      (PBKnob(label: "Transpose"), [.transpose], nil),
      (PBKnob(label: "Tune"), [.tune], nil),
      (PBKnob(label: "Vibrato"), [.vib, .amt], nil),
      (PBKnob(label: "Bend"), [.bend], nil),
      (PBKnob(label: "Porta"), [.porta], nil),
      ]])
    
    quickGrid(panel: "osc1", items: [[
      (PBSelect(label: "Osc 1"), [.osc, .i(0), .wave, .mode], nil),
      (dwgs, [.osc, .i(0), .wave], nil),
      (ctrl1, [.osc, .i(0), .ctrl, .i(0)], nil),
      (ctrl2, [.osc, .i(0), .ctrl, .i(1)], nil),
      ]])
    
    addPatchChangeBlock(path: [.voice, .assign]) {
      trigger.isHidden = $0 == 1
      detune.isHidden = $0 != 2
    }
    addPatchChangeBlock(path: [.osc, .i(0), .wave, .mode]) {
      ctrl1.isHidden = $0 == 5
      ctrl2.isHidden = $0 == 5
      dwgs.isHidden = $0 != 5
      let c1: String
      let c2: String
      switch $0 {
      case 0: // saw
        c1 = "Wave Mod"
        c2 = "← LFO1"
      case 1: // pulse
        c1 = "PW"
        c2 = "← LFO1"
      case 2: // tri
        c1 = "Wave Mod"
        c2 = "← LFO1"
      case 3: // sin (cross)
        c1 = "Cross Mod"
        c2 = "← LFO1"
      case 4: // vox
        c1 = "Wave Mod"
        c2 = "← LFO1"
      case 5: // dwgs
        c1 = "Wave Mod"
        c2 = "← LFO1"
      case 6: // noise
        c1 = "Cutoff"
        c2 = "Reson"
      default: // audio in
        c1 = "Balance"
        c2 = "← LFO1"
      }
      ctrl1.label = c1
      ctrl2.label = c2
    }
  }
}

class KorgMTimbreController : MS2KPartController {
  
  override var prefix: SynthPath? { return [.tone, .i(index)] }
    
  let button = createMenuButton(titled: "Timbre")

  override func initCommonPanels() {
    super.initCommonPanels()
    
    let timbreSelect = LabeledSegmentedControl(label: "Timbre", items: ["1","2"])
    switchCtrl = timbreSelect.segmentedControl

    quickGrid(panel: "switch", items: [[
      (timbreSelect, nil, "switch"),
      (button, nil, "button")
      ]])
    
    quickGrid(panel: "osc2", items: [[
      (PBSwitch(label: "Osc 2"), [.osc, .i(1), .wave], nil),
      (PBKnob(label: "Semi"), [.osc, .i(1), .semitone], nil),
      (PBKnob(label: "Tune"), [.osc, .i(1), .tune], nil),
      (PBSwitch(label: "Mod"), [.mod, .select], nil),
      ]])
    
    quickGrid(panel: "mix", items: [[
      (PBKnob(label: "Osc 1"), [.osc, .i(0), .level], nil),
      (PBKnob(label: "Osc 2"), [.osc, .i(1), .level], nil),
      (PBKnob(label: "Noise"), [.noise, .level], nil),
      ]])
    
    addPatchChangeBlock { [weak self] in
      guard let voiceMode = Self.updatedValueForFullPath([.voice, .mode], state: $0) else { return }
      if voiceMode < 1 {
        timbreSelect.isHidden = true
        timbreSelect.segmentedControl.selectedSegmentIndex = 0
        if self?.index != 0 {
          self?.index = 0
        }
      }
      else {
        timbreSelect.isHidden = false
      }
    }
  }
    
}


class KorgMVocoderController : MS2KPartController {
  
  override var prefix: SynthPath? { return [.vocoder] }
  
  override func initCommonPanels() {
    super.initCommonPanels()
    quickGrid(panel: "audio", items: [[
      (PBKnob(label: "Gate Sens"), [.extAudio, .gate, .sens], nil),
      (PBKnob(label: "Thresh"), [.extAudio, .threshold], nil),
      (PBKnob(label: "HPF Level"), [.hi, .pass, .level], nil),
      (PBCheckbox(label: "HP Gate"), [.hi, .pass, .gate], nil),
      ]])
    
    quickGrid(panel: "mix", items: [[
      (PBKnob(label: "Osc 1"), [.osc, .i(0), .level], nil),
      (PBKnob(label: "Inst"), [.extAudio, .level], nil),
      (PBKnob(label: "Noise"), [.noise, .level], nil),
      ]])
    
  }
      
}

class MS2KLFOController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.lfo, .i(index)] }

  override var index: Int {
    didSet { waveSwitch.label = "LFO \(index + 1)" }
  }
  
  private let waveSwitch = PBSwitch(label: "LFO 1")
  
  override func loadView(_ view: PBView) {
    let freq = PBKnob(label: "Freq")
    let syncNote = PBKnob(label: "Sync Note")
    quickGrid(view: view, items: [[
      (waveSwitch, [.wave], nil),
      (freq, [.freq], nil),
      ],[
      (PBSwitch(label: "Key Sync"), [.key, .sync], nil),
      (PBCheckbox(label: "T Sync"), [.tempo, .sync], nil),
      (syncNote, [.sync, .note], nil),
      ]])
    
    addPatchChangeBlock(path: [.tempo, .sync]) {
      freq.isHidden = $0 != 0
      syncNote.isHidden = $0 == 0
    }
  }
  
}

class MS2KEnvController : NewPatchEditorController {
  
  let envCtrl = PBDadsrEnvelopeControl()
  
  func adsrItems() -> [(PBView,SynthPath?,String?)] {
    return [
      (envCtrl, nil, "env"),
      (PBKnob(label: "A"), [.env, .i(index), .attack], nil),
      (PBKnob(label: "D"), [.env, .i(index), .decay], nil),
      (PBKnob(label: "S"), [.env, .i(index), .sustain], nil),
      (PBKnob(label: "R"), [.env, .i(index), .release], nil),
      (PBCheckbox(label: "Reset"), [.env, .i(index), .reset], nil)
    ]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let env = self.envCtrl
    addPatchChangeBlock(path: [.env, .i(index), .attack]) { env.attack = CGFloat($0) / 127 }
    addPatchChangeBlock(path: [.env, .i(index), .decay]) { env.decay = CGFloat($0) / 127 }
    addPatchChangeBlock(path: [.env, .i(index), .sustain]) { env.sustain = CGFloat($0) / 127 }
    addPatchChangeBlock(path: [.env, .i(index), .release]) { env.rrelease = CGFloat($0) / 127 }
    
    registerForEditMenu(env, bundle: (
      paths: { [weak self] in
        let index = self?.index ?? 0
        return [
          [.env, .i(index), .attack],
          [.env, .i(index), .decay],
          [.env, .i(index), .sustain],
          [.env, .i(index), .release],
        ]
        
      },
      pasteboardType: "com.cfshpd.KorgMEnvelope",
      initialize: { [0,64,127,0] },
      randomize: { (0..<4).map { _ in (0...127).random()! } }
    ))
  }
  
}
