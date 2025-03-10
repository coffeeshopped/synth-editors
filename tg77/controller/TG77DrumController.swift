
class TG77DrumController : NewPatchEditorController {
  
  let noteController = NoteController()
    
  override func loadView(_ view: PBView) {
    addChild(noteController, withPanel: "note")
    
    let gridControl = PBGridSelectControl()
    let noteMiso = Miso.noteName(zeroNote: "C1")
    gridControl.options = OptionsParam.makeOptions((0..<61).map { noteMiso.forward(Float($0)) })
    gridControl.columnCount = 16
    gridControl.wantsGridWidth = 16
    gridControl.value = 0
    gridControl.addValueChangeTarget(self, action: #selector(selectNote(_:)))
    
    grid(panel: "switch", items: [[(gridControl, nil)]])
    
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([
      (row: [("switch", 1)], height: 4),
      (row: [("note", 1)], height: 4),
    ], pinMargin: "", spacing: "-s1-")
    
    addColor(panels: ["switch"], clearBackground: true)
  }
    
  var transmitter: MIDINoteTransmitter? { return firstTypedAncestor() }
  
  @IBAction func noteOn(_ sender: Any) {
    transmitter?.noteOn(36 + noteController.index, velocity: 100, channel: nil)
  }
  
  @IBAction func noteOff(_ sender: Any) {
    transmitter?.noteOff(36 + noteController.index, channel: nil)
  }
  
  @IBAction func selectNote(_ sender: PBGridSelectControl) {
    noteController.index = sender.value
    playNote(sender)
  }
  
  @IBAction func playNote(_ sender: Any) {
    noteOn(sender)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.noteOff(sender)
    }
  }
  

  class NoteController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.rhythm, .i(index)] }
    
    override func loadView() {
      let paddedView = PaddedContainer()
      let view = paddedView.mainView
      
      let wave = PBSelect(label: "Wave")
      grid(panel: "main", items: [[
        (PBSwitch(label: "Wave Src"), [.wave, .src]),
        (wave, [.wave, .wave]),
        (PBKnob(label: "Note Shift"), [.note, .shift]),
        (PBKnob(label: "Tune"), [.fine]),
        (PBKnob(label: "Volume"), [.volume]),
        (PBKnob(label: "Pan"), [.pan]),
        (PBCheckbox(label: "Alt Group"), [.alt, .group]),
        (PBCheckbox(label: "Out 1"), [.out, .i(0)]),
        (PBCheckbox(label: "Out 2"), [.out, .i(1)]),
        (PBKnob(label: "Indiv Out"), [.out, .select]),
        ]])
      
      let menuButton = createMenuButton(titled: "Drum")
      grid(panel: "button", items: [[(menuButton, nil)]])

      createPanels(forKeys: ["space"])
      addPanelsToLayout(andView: view)

      layout.addRowConstraints([("space",5),("button",1)], pinned: true, spacing: "-s1-")
      layout.addRowConstraints([("main",1)], pinned: true, spacing: "-s1-")
      layout.addColumnConstraints([("space",1), ("main", 1)], pinned: true, spacing: "-s1-")

      layout.activateConstraints()
      self.view = paddedView
      
      addPatchChangeBlock(path: [.src]) {
        wave.isHidden = $0 > 1
        wave.options = $0 == 0 ? TG77VoicePatch.waveOptions : TG77VoicePatch.blankWaveOptions
      }
      
      registerForEditMenu(menuButton, bundle: (
        paths: { [
          [.wave, .src], [.wave, .wave], [.note, .shift], [.fine], [.volume], [.pan], [.alt, .group],
          [.out, .i(0)], [.out, .i(1)], [.out, .select]
        ] },
        pasteboardType: "com.cfshpd.TG77Drum",
        initialize: nil,
        randomize: nil
      ))
      
      addColorToAll(except: ["button", "space"])
      addColor(panels: ["button"], clearBackground: true)
    }

  }

}
