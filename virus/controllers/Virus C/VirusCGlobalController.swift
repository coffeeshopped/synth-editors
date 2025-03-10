
class VirusCGlobalController : NewPatchEditorController {
  
  override func loadView() {
    let paddedView = PaddedContainer()
    let view = paddedView.mainView
    
    createPanels(forKeys: ["chan"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("chan", 1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("chan", 1)], pinned: true, spacing: "-s1-")
    
    grid(panel: "chan", items: [[
      (PBKnob(label: "Device ID"), [.deviceId]),
      (PBKnob(label: "Global Channel"), [.channel]),
      (PBKnob(label: "Master Tune"), [.tune]),
      (PBKnob(label: "Transpose"), [.key, .transpose]),
      (PBCheckbox(label: "Keyb Local"), [.key, .local]),
      (PBSwitch(label: "Keyb Mode"), [.key, .mode]),
      (PBKnob(label: "Key Press Sens"), [.key, .pressure, .sens]),
      ],[
      (PBSelect(label: "Mod Wheel"), [.key, .modWheel]),
      (PBSelect(label: "Pedal 1"), [.key, .pedal, .i(0)]),
      (PBSelect(label: "Pedal 2"), [.key, .pedal, .i(1)]),
      (PBCheckbox(label: "Glob PgmCh"), [.global, .pgmChange, .on]),
      (PBCheckbox(label: "Multi PgmCh"), [.multi, .pgmChange, .on]),
      (PBCheckbox(label: "MIDI Volume"), [.global, .volume, .on]),
      ],[
      (PBSelect(label: "2nd Out"), [.alt, .out]),
      (PBKnob(label: "Input Thru"), [.input, .level]),
      (PBKnob(label: "Input Boost"), [.input, .booster]),
      (PBSwitch(label: "MIDI Ctrl Lo Page"), [.midi, .part, .lo]),
      (PBSwitch(label: "MIDI Ctrl Hi Page"), [.midi, .part, .hi]),
      (PBCheckbox(label: "MIDI Arp Send"), [.midi, .arp]),
      (PBSwitch(label: "MIDI Clock Rx"), [.midi, .clock, .rcv]),
      ],[
      (PBSwitch(label: "Knob 1 Mode"), [.knob, .i(0), .mode]),
      (PBSwitch(label: "Knob 2 Mode"), [.knob, .i(1), .mode]),
      (PBSelect(label: "Knob 1 Global"), [.knob, .i(0), .global]),
      (PBSelect(label: "Knob 2 Global"), [.knob, .i(1), .global]),
      (PBSwitch(label: "Panel Dest"), [.ctrl, .dest]),
      (PBSwitch(label: "Play Mode"), [.play, .mode]),
    ]])
    
    layout.activateConstraints()
    self.view = paddedView
    addColorToAll()
  }
  
}
