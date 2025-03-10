
class Deepmind12GlobalController : NewPatchEditorController {
  
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0
    paddedView.verticalPadding = 0.1
    let view = paddedView.mainView
    
    grid(panel: "dev", items: [[
      (PBKnob(label: "Device ID"), [.deviceId]),
      (PBKnob(label: "Tune"), [.tune]),
    ]])
    
    grid(panel: "midi", prefix: [.midi], items: [[
      (LabelItem(text: "MIDI", gridWidth: 7/3, textAlignment: .center), nil),
      (PBKnob(label: "Rx Ch"), [.channel, .rcv]),
      (PBKnob(label: "Tx Ch"), [.channel, .send]),
      (PBSwitch(label: "Pgm Chng"), [.pgm]),
      (PBSwitch(label: "Ctrl"), [.ctrl]),
      (PBCheckbox(label: "Soft Thru"), [.thru]),
      (PBCheckbox(label: ">USB-Thru"), [.usb, .thru]),
      (PBCheckbox(label: ">Wifi-Thru"), [.wifi, .thru]),
    ]])
    
    grid(panel: "usb", prefix: [.usb], items: [[
      (LabelItem(text: "USB", gridWidth: 2, textAlignment: .center), nil),
      (PBKnob(label: "Rx Ch"), [.channel, .rcv]),
      (PBKnob(label: "Tx Ch"), [.channel, .send]),
      (PBSwitch(label: "Pgm Chng"), [.pgm]),
      (PBSwitch(label: "Ctrl"), [.ctrl]),
      (PBCheckbox(label: ">MIDI-Thru"), [.midi, .thru]),
      (PBCheckbox(label: ">Wifi-Thru"), [.wifi, .thru]),
    ]])

    grid(panel: "wifi", prefix: [.wifi], items: [[
      (LabelItem(text: "Wifi", gridWidth: 2, textAlignment: .center), nil),
      (PBKnob(label: "Rx Ch"), [.channel, .rcv]),
      (PBKnob(label: "Tx Ch"), [.channel, .send]),
      (PBSwitch(label: "Pgm Chng"), [.pgm]),
      (PBSwitch(label: "Ctrl"), [.ctrl]),
      (PBCheckbox(label: ">MIDI-Thru"), [.midi, .thru]),
      (PBCheckbox(label: ">USB-Thru"), [.usb, .thru]),
    ]])
    
    grid(panel: "key", items: [[
      (PBCheckbox(label: "Key Local"), [.local]),
      (PBKnob(label: "Fix On Velo"), [.fixed, .velo, .on]),
      (PBKnob(label: "Fix Off Velo"), [.fixed, .velo, .off]),
      (PBSwitch(label: "Velo Curve"), [.velo, .curve]),
      (PBSwitch(label: "After Curve"), [.aftertouch, .curve]),
      (PBSwitch(label: "Wheel LEDs"), [.modWheel, .light]),
      (PBKnob(label: "Key Trans"), [.key, .transpose]),
      (PBSwitch(label: "P-Bend Mode"), [.bend, .mode]),
    ]])
    
    grid(panel: "pedal", items: [[
      (PBSelect(label: "Pedal"), [.pedal]),
      (PBSelect(label: "Sustain"), [.sustain]),
      (PBSwitch(label: "Mode"), [.sustain, .mode]),
    ]])

    grid(panel: "amp", items: [[
      (PBSwitch(label: "VCA Mode"), [.amp, .mode]),
    ]])

    grid(panel: "panel", items: [[
      (PBCheckbox(label: "Panel Local"), [.panel, .local]),
      (PBSwitch(label: "Fader Mode"), [.fade, .mode]),
      (PBCheckbox(label: "Info Dialogs"), [.info]),
      (PBCheckbox(label: "Cycle 2 Pgm"), [.cycle, .pgm]),
      (PBCheckbox(label: "Remem Pages"), [.memory, .panel]),
      (PBKnob(label: "Brightness"), [.brilliance]),
      (PBKnob(label: "Contrast"), [.contrast]),
    ]])

    grid(panel: "chain", prefix: [.chain], items: [[
      (PBCheckbox(label: "Poly Chain"), [.poly]),
      (PBCheckbox(label: "Pgm Link"), [.pgm, .link]),
      (PBCheckbox(label: "Key Range"), [.key, .range]),
      (PBKnob(label: "Key Lo"), [.key, .range, .lo]),
      (PBKnob(label: "Key Hi"), [.key, .range, .hi]),
    ]])
    
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([
      [("dev", 2), ("key", 8)],
      [("midi", 9)],
      [("usb", 8)],
      [("wifi", 8)],
      [("panel", 7), ("amp", 1)],
      [("pedal", 4), ("chain", 5)],
    ], spacing: "-s1-")
    
    layout.activateConstraints()
    self.view = paddedView
    
    addColorToAll()
  }
  
}
