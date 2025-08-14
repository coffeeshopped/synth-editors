
class JD800SpecialSetupController : NewPagedEditorController {
  
  private let commonController = CommonController()
  private let tonesController = TonesController()

  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch","bend"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch",12),("bend",3)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("switch",1),("page",8)], pinned: true, spacing: "-s1-")
    
    switchCtrl = PBSegmentedControl(items: ["Common","36–47","48–59","60–71","72–83","84–95","96"])
    quickGrid(panel: "switch", items: [[(switchCtrl, nil, "switchCtrl")]])

    quickGrid(panel: "bend", items: [[
      (PBKnob(label: "Bend Down"), [.common, .bend, .down], nil),
      (PBKnob(label: "Bend Up"), [.common, .bend, .up], nil),
      (PBKnob(label: "Aftertouch"), [.common, .aftertouch, .bend], nil),
      ]])
    
    addColorToAll(except: ["switch"])
    addColor(panels: ["switch"], clearBackground: true)
  }
    
  override func viewController(forIndex index: Int) -> PBViewController? {
    switch index {
    case 0:
      return commonController
    default:
      tonesController.groupIndex = index - 1
      return tonesController
    }
  }

  
  
  class CommonController : NewPatchEditorController {
    
    override func loadView() {
      let paddedView = PaddedContainer()
      paddedView.horizontalPadding = 0.3
      paddedView.verticalPadding = 0.3
      let view = paddedView.mainView
      
      createPanels(forKeys: ["eq"])
      addPanelsToLayout(andView: view)

      layout.addGridConstraints([[("eq", 1)]], pinMargin: "", spacing: "-s1-")
      
      quickGrid(panel: "eq", items: [[
        (PBKnob(label: "Lo Gain"), [.common, .lo, .gain], nil),
        (PBKnob(label: "Mid Gain"), [.common, .mid, .gain], nil),
        (PBKnob(label: "Hi Gain"), [.common, .hi, .gain], nil),
        ],[
        (PBSwitch(label: "Lo Freq"), [.common, .lo, .freq], nil),
        (PBKnob(label: "Mid Freq"), [.common, .mid, .freq], nil),
        (PBKnob(label: "Mid Q"), [.common, .mid, .q], nil),
        (PBSwitch(label: "Hi Freq"), [.common, .hi, .freq], nil),
        ]])

      layout.activateConstraints()
      self.view = paddedView
      
      addColorToAll()
    }
  }
  
  
  
  class TonesController : NewPatchEditorController {
    
    private let toneController = ToneController()
    private let gridControl = PBGridSelectControl()
    private let labeledNameField = LabeledTextField(label: "Key Name")

    override var prefix: SynthPath? { return [.note, .i(index)] }
    override var namePath: SynthPath? { return [] }
    
    override func loadView(_ view: PBView) {
      createPanels(forKeys: ["switch","name"])
      addChild(toneController, withPanel: "tone")
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("name", 2.5), ("switch",13.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("tone",1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("name",1),("tone",7)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      nameTextField = labeledNameField.textField
      quickGrid(panel: "name", items: [[(labeledNameField,nil,"nameTF")]])
      
      gridControl.options = OptionsParam.makeOptions((0..<12).map { "\($0+1)"})
      gridControl.columnCount = 12
      gridControl.wantsGridWidth = 12
      gridControl.value = 0
      gridControl.addValueChangeTarget(self, action: #selector(selectTone(_:)))
      quickGrid(panel: "switch", items: [[(gridControl, nil, "switchCtrl")]])
          
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
  
  
  
  class ToneController : NewPatchEditorController {
    
    private var menuButton: PBButton!

    override func loadView(_ view: PBView) {
      addChild(JD800VoiceController.PitchController(), withPanel: "pitch")
      addChild(JD800VoiceController.FilterController(), withPanel: "filter")
      addChild(JD800VoiceController.AmpController(), withPanel: "amp")
      (0..<2).forEach {
        let vc = JD800VoiceController.LFOController()
        vc.index = $0
        addChild(vc, withPanel: "lfo\($0)")
      }
      createPanels(forKeys: ["velo", "group", "button"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([
        ("pitch", 5), ("filter", 5), ("amp", 5)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([
        ("lfo0", 3.5), ("lfo1", 3.5), ("velo", 1), ("group", 3.5), ("button", 2),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("pitch", 5), ("lfo0", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      quickGrid(panel: "velo", items: [[
        (PBKnob(label: "Velo Curve"), [.velo, .curve], nil),
        ],[
        (PBCheckbox(label: "Hold"), [.hold, .ctrl], nil),
        ]])
      
      quickGrid(panel: "group", items: [[
        (PBSelect(label: "Mute Group"), [.mute, .group], nil),
        (PBSwitch(label: "Env Mode"), [.env, .mode], nil),
        (PBKnob(label: "Pan"), [.pan], nil),
        ],[
        (PBSwitch(label: "FX Mode"), [.fx, .mode], nil),
        (PBKnob(label: "FX Level"), [.fx, .level], nil),
        ]])

      menuButton = createMenuButton(titled: "Key")
      quickGrid(panel: "button", items: [[(menuButton, nil, "keyButton")]])
      
      registerForEditMenu(menuButton, bundle: (
        paths: { Self.AllTonePaths },
        pasteboardType: "com.cfshpd.JD800SpecialSetupKey",
        initialize: nil,
        randomize: { [] } // this will register that randomize exists
      ))

      addColorToAll(except: ["button"], level: 2)
      addColor(panels: ["button"], level: 2, clearBackground: true)
    }
            
    private static let AllTonePaths = JD800SpecialSetupKeyPatch.paramKeys()
    
    override func randomize(_ sender: Any?) {
      pushPatchChange(.replace(JD800SpecialSetupKeyPatch.random()))
    }

  }
}

