
class JD990RhythmController : NewPagedEditorController {
      
  override func loadView(_ view: PBView) {
    switchCtrl = PBSegmentedControl(items: ["Common","36–47","48–59","60–71","72–83","84–95", "96"])
    grid(panel: "switch", items: [[(switchCtrl, nil)]])

    grid(panel: "level", items: [[
      (PBKnob(label: "Level"), [.common, .level]),
      (PBKnob(label: "Pan"), [.common, .pan]),
      (PBKnob(label: "Analog Feel"), [.common, .analogFeel]),
      (PBKnob(label: "Bend Down"), [.common, .bend, .down]),
      (PBKnob(label: "Bend Up"), [.common, .bend, .up]),
      ]])
    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch", 11),("level", 5)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("switch",1),("page",8)], pinned: true, spacing: "-s1-")
    
    addColor(panels: ["level"])
    addColor(panels: ["switch"], clearBackground: true)
    
    let commonController = CommonController()
    let tonesController = RhythmTonesController()
    viewControllerBlock = {
      switch $0 {
      case 0:
        return commonController
      default:
        tonesController.groupIndex = $0 - 1
        return tonesController
      }
    }
  }
  
  
  class CommonController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.common] }
    
    override func loadView() {
      let paddedView = PaddedContainer()
      paddedView.horizontalPadding = 0.15
      paddedView.verticalPadding = 0.15
      let view = paddedView.mainView
      
      createPanels(forKeys: ["fxCtrl", "eq", "delay", "reverb", "chorus", "ctrl"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("fxCtrl", 4), ("eq", 4), ("ctrl", 1.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("delay", 8)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("reverb", 6.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("chorus", 5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("fxCtrl", 2), ("delay", 1), ("reverb", 1), ("chorus", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      grid(panel: "fxCtrl", items: [[
        (PBSelect(label: "FX Ctrl 1"), [.fx, .ctrl, .src, .i(0)]),
        (PBKnob(label: "Depth"), [.fx, .ctrl, .depth, .i(0)]),
        (PBSelect(label: "Destination"), [.fx, .ctrl, .dest, .i(0)]),
        ],[
        (PBSelect(label: "FX Ctrl 2"), [.fx, .ctrl, .src, .i(1)]),
        (PBKnob(label: "Depth"), [.fx, .ctrl, .depth, .i(1)]),
        (PBSelect(label: "Destination"), [.fx, .ctrl, .dest, .i(1)]),
        ]])

      grid(panel: "ctrl", items: [[
        (PBSelect(label: "Tone Ctrl 1"), [.ctrl, .src, .i(0)]),
        ],[
        (PBSelect(label: "Tone Ctrl 2"), [.ctrl, .src, .i(1)]),
        ]])

      grid(panel: "eq", items: [[
        (PBKnob(label: "Lo Gain"), [.lo, .gain]),
        (PBKnob(label: "Mid Gain"), [.mid, .gain]),
        (PBKnob(label: "Hi Gain"), [.hi, .gain]),
        ],[
        (PBSwitch(label: "Lo Freq"), [.lo, .freq]),
        (PBKnob(label: "Mid Freq"), [.mid, .freq]),
        (PBKnob(label: "Mid Q"), [.mid, .q]),
        (PBSwitch(label: "Hi Freq"), [.hi, .freq]),
        ]])

      grid(panel: "delay", items: [[
        (PBSwitch(label: "Delay"), [.delay, .mode]),
        (PBKnob(label: "Center Tap"), [.delay, .mid, .time]),
        (PBKnob(label: "Center Lvl"), [.delay, .mid, .level]),
        (PBKnob(label: "Left Tap"), [.delay, .left, .time]),
        (PBKnob(label: "Left Lvl"), [.delay, .left, .level]),
        (PBKnob(label: "Right Tap"), [.delay, .right, .time]),
        (PBKnob(label: "Right Lvl"), [.delay, .right, .level]),
        (PBKnob(label: "Feedbk"), [.delay, .feedback]),
        ]])

      grid(panel: "reverb", items: [[
        (PBSelect(label: "Reverb"), [.reverb, .type]),
        (PBKnob(label: "Pre Delay"), [.reverb, .pre]),
        (PBKnob(label: "Early Ref"), [.reverb, .early]),
        (PBKnob(label: "HF Damp"), [.reverb, .hi, .cutoff]),
        (PBKnob(label: "Time"), [.reverb, .time]),
        (PBKnob(label: "Level"), [.reverb, .level]),
        ]])

      grid(panel: "chorus", items: [[
        (PBKnob(label: "Chorus Rate"), [.chorus, .rate]),
        (PBKnob(label: "Depth"), [.chorus, .depth]),
        (PBKnob(label: "Delay T"), [.chorus, .delay]),
        (PBKnob(label: "Feedbk"), [.chorus, .feedback]),
        (PBKnob(label: "Level"), [.chorus, .level]),
        ]])
      
      layout.activateConstraints()
      self.view = paddedView
      
      addColorToAll()
    }
  }
  
  
  
  class RhythmTonesController : NewPatchEditorController {
    
    private let toneController = RhythmToneController()
    private let gridControl = PBGridSelectControl()

    override var prefix: SynthPath? { return [.tone, .i(index)] }
    override var namePath: SynthPath? { return [] }

    override func loadView(_ view: PBView) {
      createPanels(forKeys: ["switch", "name"])
      addChild(toneController, withPanel: "tone")
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("name", 2.5), ("switch", 13)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("tone",1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("name",1),("tone",7)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      let labeledNameField = LabeledTextField(label: "Key Name")
      nameTextField = labeledNameField.textField
      grid(panel: "name", items: [[(labeledNameField, nil)]])
      
      gridControl.options = OptionsParam.makeOptions((0..<12).map { "\($0+1)"})
      gridControl.columnCount = 12
      gridControl.wantsGridWidth = 12
      gridControl.value = 0
      gridControl.addValueChangeTarget(self, action: #selector(selectTone(_:)))
      grid(panel: "switch", items: [[(gridControl, nil)]])

      // to prime the switch
      groupIndex += 0
      
      addColorToAll(except: ["switch", "name"])
      addColor(panels: ["switch"], clearBackground: true)
      addColor(panels: ["name"], level: 2)
    }
    
    var groupIndex = 0 {
      didSet {
        if groupIndex == 5 {
          gridControl.options = OptionsParam.makeOptions((0..<1).map {
            let noteNumber = (groupIndex * 12) + $0 + 36
            let name = ParamHelper.noteName(noteNumber)
            return "\(name) (\(noteNumber))"
          })
        }
        else {
          gridControl.options = OptionsParam.makeOptions((0..<12).map {
            let noteNumber = (groupIndex * 12) + $0 + 36
            let name = ParamHelper.noteName(noteNumber)
            return "\(name) (\(noteNumber))"
          })
        }
        updateIndex()
      }
    }
    
    private func updateIndex() {
      index = gridControl.value + (groupIndex * 12)
    }
      
    @IBAction func selectTone(_ sender: PBGridSelectControl) {
      updateIndex()
      playNote()
    }
            
    var transmitter: MIDINoteTransmitter? { return firstTypedAncestor() }
    
    func playNote() {
      let note = 36 + index
      let transmitter = self.transmitter
      transmitter?.noteOn(note, velocity: 100, channel: nil)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        transmitter?.noteOff(note, channel: nil)
      }
    }
  }
  
  
  class RhythmToneController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      addChild(JD990VoiceController.WaveController(), withPanel: "src")
      addChild(JD990VoiceController.PitchController(), withPanel: "pitch")
      addChild(JD990VoiceController.FilterController(), withPanel: "filter")
      addChild(JD990VoiceController.AmpController(), withPanel: "amp")
      addChild(LFOController(), withPanel: "lfo")
      addChild(CtrlController(), withPanel: "ctrl")
      createPanels(forKeys: ["fxm", "sync", "delay", "bend", "velo", "pan", "level", "button", "env", "fx"])
      addPanelsToLayout(andView: view)

      layout.addRowConstraints([("src", 2.5), ("fxm", 2), ("sync", 1), ("delay", 2.5), ("bend", 1), ("velo", 3), ("pan", 2), ("level", 1), ("button", 1.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("pitch", 5), ("filter", 6), ("amp", 5), ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("lfo", 4.5), ("ctrl", 8), ("env", 1.5), ("fx", 1.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("src", 1), ("pitch", 4), ("lfo", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      grid(panel: "fxm", items: [[
        (PBKnob(label: "FXM Color"), [.fxm, .color]),
        (PBKnob(label: "Depth"), [.fxm, .depth]),
        ]])

      grid(panel: "sync", items: [[
        (PBCheckbox(label: "Sync Slave"), [.sync, .on]),
        ]])

      grid(panel: "delay", items: [[
        (PBSelect(label: "Tone Delay"), [.tone, .delay, .mode]),
        (PBKnob(label: "Time"), [.tone, .delay, .time]),
        ]])

      grid(panel: "bend", items: [[
        (PBCheckbox(label: "Bend"), [.bend, .on]),
        ]])

      let veloCurve = PBImageSelect(label: "Velo Curve", imageSize: CGSize(width: 200, height: 70), imageSpacing: 12)
      grid(panel: "velo", items: [[
        (veloCurve, nil),
        (PBCheckbox(label: "Hold Ctrl"), [.hold, .ctrl]),
        ]])

      grid(panel: "pan", items: [[
        (PBKnob(label: "Pan"), [.pan]),
        (PBKnob(label: "Key > Pan"), [.pan, .keyTrk]),
        ]])

      grid(panel: "level", items: [[
        (PBKnob(label: "Level"), [.level]),
        ]])

      grid(panel: "env", items: [[
        (PBKnob(label: "Mute Group"), [.mute, .group]),
        ],[
        (PBSwitch(label: "Env Mode"), [.env, .mode]),
        ]])

      grid(panel: "fx", items: [[
        (PBKnob(label: "FX Level"), [.fx, .level]),
        ],[
        (PBSelect(label: "FX Mode"), [.fx, .mode]),
        ]])
      
      let menuButton = createMenuButton(titled: "Note")
      grid(panel: "button", items: [[(menuButton, nil)]])
      
      addBlocks(control: veloCurve, path: [.velo, .curve], paramAfterBlock: {
        veloCurve.options = JD990VoiceController.ToneController.veloOptions
      })

      let paths = JD990RhythmTonePatch.paramKeys()
      registerForEditMenu(menuButton, bundle: (
        paths: { paths },
        pasteboardType: "com.cfshpd.JD990RhythmNote",
        initialize: nil,
        randomize: { return [] } // this will register that randomize exists
      ))
      
      addColorToAll(except: ["button"], level: 2)
      addColor(panels: ["button"], level: 2, clearBackground: true)

    }

    override func randomize(_ sender: Any?) {
      pushPatchChange(.replace(JD990RhythmTonePatch.random()))
    }

   
    
    class LFOController : JD990VoiceController.LFOController {
      override func loadView(_ view: PBView) {
        let labeledSwitch = LabeledSegmentedControl(label: "LFO", items: ["1", "2"])
        switchCtrl = labeledSwitch.segmentedControl

        grid(view: view, items: [[
          (wave, [.wave]),
          (PBKnob(label: "Rate"), [.rate]),
          (PBKnob(label: "Delay"), [.delay]),
          (PBKnob(label: "Fade"), [.fade]),
          ],[
          (labeledSwitch, nil),
          (PBCheckbox(label: "Key Trig"), [.key, .trigger]),
          (PBSwitch(label: "Offset"), [.offset]),
          ]])
      }
    }

    class CtrlController : JD990VoiceController.CtrlController {
      override func loadView(_ view: PBView) {
        createPanels(forKeys: ["switch", "ctrl"])
        addPanelsToLayout(andView: view)
        layout.addGridConstraints([[("switch", 4), ("ctrl", 6)]], pinMargin: "", spacing: "-s1-")
        
        let labeledSwitch = LabeledSegmentedControl(label: "Controller", items: ["1", "2"])
        labeledSwitch.wantsGridWidth = 4
        switchCtrl = labeledSwitch.segmentedControl

        label.textAlignment = .right
        dynLabel.textAlignment = .left

        grid(panel: "switch", items: [[
          (label, nil),
          (dynLabel, nil),
          ],[
          (labeledSwitch, nil),
        ]])
        
        grid(panel: "ctrl", items: [amtItems(), destItems()])
        
        addColorToAll(level: 2)
      }
    }

  }
}

