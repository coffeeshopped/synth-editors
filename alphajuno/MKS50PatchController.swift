
class MKS50PatchController : NewPatchEditorController {

  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0.1
    paddedView.verticalPadding = 0.1
    let view = paddedView.mainView

    let tone = PBSelect(label: "Tone")
    let chord = PBKnob(label: "Chord Mem")

    grid(panel: "tone", items: [[
      (tone, [.tone]),
      ]])

    grid(panel: "key", items: [[
      (PBKnob(label: "Key Lo"), [.key, .lo]),
      (PBKnob(label: "Key Hi"), [.key, .hi]),
      ]])
    
    grid(panel: "porta", items: [[
      (PBCheckbox(label: "Porta"), [.porta]),
      (PBKnob(label: "Time"), [.porta, .time]),
      ]])
    
    grid(panel: "assign", items: [[
      (PBSwitch(label: "Key Assign"), [.key, .assign]),
      ]])
    
    grid(panel: "transpose", items: [[
      (PBKnob(label: "Key Shift"), [.transpose]),
      (PBKnob(label: "Detune"), [.detune]),
      ]])
    
    grid(panel: "bend", items: [[
      (PBKnob(label: "Mono Bend"), [.bend]),
      (PBKnob(label: "Mod Sens"), [.mod, .amt]),
      (PBKnob(label: "Volume"), [.volume]),
      (chord, [.chord]),
      ]])
    
    grid(panel: "ctrl", items: [[
      (PBCheckbox(label: "MIDI After"), [.aftertouch]),
      (PBCheckbox(label: "MIDI Bend"), [.bend, .ctrl]),
      (PBCheckbox(label: "MIDI Hold"), [.hold]),
      (PBCheckbox(label: "MIDI Mod Wh"), [.modWheel]),
      (PBCheckbox(label: "MIDI Volume"), [.volume, .ctrl]),
      (PBCheckbox(label: "MIDI Porta"), [.porta, .ctrl]),
      ]])
    
    addPanelsToLayout(andView: view)

    layout.addRowConstraints([("tone", 1.5), ("key", 2), ("porta", 2), ("assign", 1)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("transpose", 2), ("bend", 4.5)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("ctrl", 1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("tone", 1), ("transpose", 1), ("ctrl", 1)], pinned: true, spacing: "-s1-")
    
    layout.activateConstraints()
    self.view = paddedView
    
    addPatchChangeBlock(path: [.key, .assign]) { chord.isHidden = $0 != 2 }
    
    addParamChangeBlock { (params) in
      var toneNameOptions = tone.options
      (0..<2).forEach { bank in
        guard let param = params.params[[.tone, .name, .i(bank)]] as? OptionsParam else { return }
        param.options.forEach { toneNameOptions[$0.key + (bank * 64)] = $0.value }
      }
      tone.options = toneNameOptions
    }

    addColorToAll()
  }
      
}
