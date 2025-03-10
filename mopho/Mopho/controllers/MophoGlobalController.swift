
func MophoGlobalController() -> FnPatchEditorController {
  ActivatedFnEditorController { (vc) in
    vc.grid(panel: "tune", items: [[
        (PBKnob(label: "Transpose"), [.semitone]),
        (PBKnob(label: "Detune"), [.detune]),
        (PBKnob(label: "MIDI Ch"), [.channel]),
        (PBSelect(label: "MIDI Clock"), [.clock]),
        (PBSwitch(label: "MIDI Out"), [.midi, .out])]
      ])

    vc.grid(panel: "param", items: [[
        (PBSwitch(label: "Param Send"), [.param, .send]),
        (PBSwitch(label: "Param Rcv"), [.param, .rcv]),
        (PBCheckbox(label: "Ctrl"), [.ctrl]),
        (PBCheckbox(label: "Sysex"), [.sysex]),
        (PBSwitch(label: "Audio Out"), [.out])]
      ])
    
    vc.addLayoutConstraints { (layout) in
      layout.addGridConstraints([
        [("tune",1)],
        [("param",1)],
        ], spacing: "-s1-")
    }

    vc.addColorToAll()
  }
}
