
func TetraGlobalController() -> FnPatchEditorController {
  ActivatedFnEditorController { (vc) in
    vc.grid(panel: "tune", items: [[
        (PBKnob(label: "Transpose"), [.semitone]),
        (PBKnob(label: "Detune"), [.detune]),
        (PBKnob(label: "MIDI Ch"), [.channel]),
      (PBSelect(label: "Poly Chain"), [.chain]),
        (PBSelect(label: "MIDI Clock"), [.clock]),
        (PBSwitch(label: "MIDI Out"), [.midi, .out]),
    ]])

    vc.grid(panel: "param", items: [[
        (PBSwitch(label: "Param Send"), [.param, .send]),
        (PBSwitch(label: "Param Rcv"), [.param, .rcv]),
      (PBCheckbox(label: "Local"), [.local]),
        (PBSwitch(label: "Audio Out"), [.out]),
      (PBSwitch(label: "Arp Latch"), [.arp, .latch]),
      (PBSwitch(label: "Pot Mode"), [.knob]),
      (PBCheckbox(label: "Multi Mode"), [.multi]),
    ]])

    vc.addLayoutConstraints { (layout) in
      layout.addGridConstraints([
        [("tune",1)],
        [("param",1)],
        ], spacing: "-s1-")
    }

    vc.addColorToAll()
  }
}
