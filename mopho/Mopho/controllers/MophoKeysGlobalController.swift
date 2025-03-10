
func MophoKeysGlobalController() -> FnPatchEditorController {
  ActivatedFnEditorController { (vc) in
    vc.grid(panel: "poly", items: [[
      (PBSelect(label: "Poly Chain"), [.poly, .chain]),
      (PBSwitch(label: "Pot Mode"), [.knob, .mode]),
      (PBSelect(label: "Damper Polarity"), [.redamper, .polarity]),
      (PBSelect(label: "Pedal Dest"), [.pedal, .dest]),
      (PBKnob(label: "Pressure Crv"), [.pressure, .curve]),
      (PBKnob(label: "Velo Crv"), [.velo, .curve]),
      (PBKnob(label: "Balance Tweak"), [.balance]),
      ]])

    vc.grid(panel: "tune", items: [[
      (PBKnob(label: "Transpose"), [.semitone]),
      (PBKnob(label: "Detune"), [.detune]),
      (PBKnob(label: "MIDI Ch"), [.channel]),
      (PBSelect(label: "MIDI Clock"), [.clock]),
      (PBSwitch(label: "MIDI Out"), [.midi, .out]),
      (PBCheckbox(label: "Local Ctrl"), [.local]),
      ]])

    vc.grid(panel: "param", items: [[
      (PBSwitch(label: "Param Send"), [.param, .send]),
      (PBSwitch(label: "Param Rcv"), [.param, .rcv]),
      (PBCheckbox(label: "Ctrl"), [.ctrl]),
      (PBCheckbox(label: "Sysex"), [.sysex]),
      (PBCheckbox(label: "MIDI Pressure"), [.midi, .pressure]),
      (PBSwitch(label: "Audio Out"), [.out])]
      ])
    
    vc.addLayoutConstraints { (layout) in
      layout.addGridConstraints([
        [("tune",1)],
        [("param",1)],
        [("poly",1)],
        ], spacing: "-s1-")
    }

    vc.addColorToAll()
  }
}

