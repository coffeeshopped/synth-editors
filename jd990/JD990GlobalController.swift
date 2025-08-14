
class JD990GlobalController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["mode", "channel", "eq", "prev", "ctrl", "rx"])
    addPanelsToLayout(andView: view)

    layout.addGridConstraints([
      [("mode", 1)],
      [("channel", 3), ("eq", 3)],
      [("prev", 1)],
      [("ctrl", 1)],
      [("rx", 1)],
      ], spacing: "-s1-")
    
    quickGrid(panel: "mode", items: [[
      (PBSwitch(label: "Mode"), [.mode], nil),
      (PBKnob(label: "Tune"), [.tune], nil),
      (PBKnob(label: "Contrast"), [.contrast], nil),
      (PBSwitch(label: "Text Style"), [.text, .style], nil),
      (PBSwitch(label: "Rhythm Out"), [.rhythm, .out], nil),
      (PBCheckbox(label: "Patch Remain"), [.patch, .remain], nil),
      (PBSwitch(label: "Start Mode"), [.start, .mode], nil),
      ]])
    
    quickGrid(panel: "channel", items: [[
      (PBKnob(label: "Patch Ch"), [.patch, .channel], nil),
      (PBKnob(label: "Rhythm Ch"), [.rhythm, .channel], nil),
      (PBKnob(label: "Ctrl Ch"), [.ctrl, .channel], nil),
      ]])

    quickGrid(panel: "eq", items: [[
      (PBKnob(label: "EQ Low"), [.eq, .lo], nil),
      (PBKnob(label: "Mid"), [.eq, .mid], nil),
      (PBKnob(label: "High"), [.eq, .hi], nil),
      ]])

    quickGrid(panel: "prev", items: [[
      (PBSwitch(label: "Preview"), [.preview, .mode], nil),
      (PBKnob(label: "Note 1"), [.preview, .note, .i(0)], nil),
      (PBKnob(label: "Note 2"), [.preview, .note, .i(1)], nil),
      (PBKnob(label: "Note 3"), [.preview, .note, .i(2)], nil),
      (PBKnob(label: "Note 4"), [.preview, .note, .i(3)], nil),
      (PBKnob(label: "Velo 1"), [.preview, .velo, .i(0)], nil),
      (PBKnob(label: "Velo 2"), [.preview, .velo, .i(1)], nil),
      (PBKnob(label: "Velo 3"), [.preview, .velo, .i(2)], nil),
      (PBKnob(label: "Velo 4"), [.preview, .velo, .i(3)], nil),
      ]])

    quickGrid(panel: "ctrl", items: [[
      (PBCheckbox(label: "Tone Ctrl 1"), [.tone, .ctrl, .src, .i(0)], nil),
      (PBCheckbox(label: "Tone Ctrl 2"), [.tone, .ctrl, .src, .i(1)], nil),
      (PBCheckbox(label: "FX Ctrl 1"), [.fx, .ctrl, .src, .i(0)], nil),
      (PBCheckbox(label: "FX Ctrl 2"), [.fx, .ctrl, .src, .i(1)], nil),
      (PBCheckbox(label: "Chorus"), [.fx, .chorus, .on], nil),
      (PBCheckbox(label: "Delay"), [.fx, .delay, .on], nil),
      (PBCheckbox(label: "Reverb"), [.fx, .reverb, .on], nil),
      (PBCheckbox(label: "FX A"), [.fx, .i(0), .on], nil),
      ]])

    quickGrid(panel: "rx", items: [[
      (PBCheckbox(label: "Rx Pgm Ch"), [.rcv, .pgmChange], nil),
      (PBCheckbox(label: "Rx Vol"), [.rcv, .volume], nil),
      (PBCheckbox(label: "Rx Bend"), [.rcv, .bend], nil),
      (PBCheckbox(label: "Rx After"), [.rcv, .aftertouch], nil),
      (PBCheckbox(label: "Rx Mod"), [.rcv, .mod], nil),
      (PBCheckbox(label: "Rx Breath"), [.rcv, .breath], nil),
      (PBCheckbox(label: "Rx Expr"), [.rcv, .expression], nil),
      (PBCheckbox(label: "Rx Foot"), [.rcv, .foot], nil),
      ]])
    
    addColorToAll()
  }
    
}
