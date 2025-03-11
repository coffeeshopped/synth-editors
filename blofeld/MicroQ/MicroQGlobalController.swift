
struct MicroQGlobalController {
  
  static func controller() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.grid(panel: "chan", items: [[
        (PBKnob(label: "SysEx ID"), [.deviceId]),
        (PBKnob(label: "MIDI Chan"), [.channel]),
        (PBSwitch(label: "Mode"), [.mode]),
      ]])
      
      vc.grid(panel: "tune", items: [[
        (PBKnob(label: "Tune"), [.tune]),
        (PBKnob(label: "Transpose"), [.transpose]),
        (PBSwitch(label: "FX2 Link"), [.link, .fx]),
      ]])
      
      vc.grid(panel: "sr", items: [[
        (PBSwitch(label: "Ctrl Send"), [.ctrl, .send]),
        (PBCheckbox(label: "Ctrl Rcv"), [.ctrl, .rcv]),
        (PBCheckbox(label: "Arp Send"), [.arp]),
        (PBSwitch(label: "Clock"), [.clock]),
        (PBCheckbox(label: "Local"), [.local]),
        (PBSwitch(label: "PgmCh Send"), [.pgmChange, .send]),
        (PBSwitch(label: "PgmCh Rcv"), [.pgmChange, .rcv]),
      ]])
      
      vc.grid(panel: "display", items: [[
        (PBKnob(label: "Popup Time"), [.popup, .time]),
        (PBKnob(label: "Label Time"), [.extra, .time]),
        (PBKnob(label: "Contrast"), [.contrast]),
      ]])
      
      vc.grid(panel: "ctrl", items: [[
        (PBKnob(label: "Ctrl W"), [.ctrl, .i(0)]),
        (PBKnob(label: "Ctrl X"), [.ctrl, .i(1)]),
        (PBKnob(label: "Ctrl Y"), [.ctrl, .i(2)]),
        (PBKnob(label: "Ctrl Z"), [.ctrl, .i(3)]),
      ]])
      
      vc.grid(panel: "mix", items: [[
        (PBKnob(label: "Input Gain"), [.input, .gain]),
        (PBSelect(label: "Mix In to"), [.mix, .send]),
        (PBKnob(label: "Level"), [.mix, .level]),
      ]])
      
      vc.grid(panel: "pedal", prefix: [.pedal], items: [[
        (PBSelect(label: "Pedal Ctrl"), [.ctrl]),
        (PBKnob(label: "Offset"), [.offset]),
        (PBKnob(label: "Gain"), [.gain]),
        (PBKnob(label: "Curve"), [.curve]),
      ]])
      
      vc.grid(panel: "curve", items: [[
        (PBSelect(label: "On Velo Crv"), [.on, .velo, .curve]),
        (PBSelect(label: "Rel Velo Crv"), [.release, .velo, .curve]),
        (PBSelect(label: "Press Crv"), [.pressure, .curve]),
      ]])
      
      vc.addLayoutConstraints { layout in
        layout.addGridConstraints([
          [("chan", 3), ("tune", 3), ("display", 3)],
          [("sr", 7), ("ctrl", 4),],
          [("mix", 3.5), ("pedal", 4.5), ("curve", 4.5),]
        ], spacing: "-s1-")
      }
      
      vc.addColorToAll()
    }
  }
}
