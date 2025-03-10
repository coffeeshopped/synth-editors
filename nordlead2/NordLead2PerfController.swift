
class NordLead2PerfController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    let _: [NordLead2PerfPartController] = addChildren(count: 4, panelPrefix: "p")
    
    grid(panel: "top", items: [[
      (PBKnob(label: "Global Ch"), [.deviceId]),
      (PBKnob(label: "Uni Detune"), [.unison, .detune]),
      (PBSwitch(label: "Out Mode AB"), [.out, .mode, .i(0)]),
      (PBSwitch(label: "Out Mode CD"), [.out, .mode, .i(1)]),
      (PBSelect(label: "Bend Range"), [.bend]),
      (PBCheckbox(label: "Key Split"), [.split]),
      (PBKnob(label: "Split Pt"), [.split, .pt]),
      ]])

    addPanelsToLayout(andView: view)
    layout.addGridConstraints([
      (row: [("top", 1)], height: 1),
      (row: [("p0", 1)], height: 2),
      (row: [("p1", 1)], height: 2),
      (row: [("p2", 1)], height: 2),
      (row: [("p3", 1)], height: 2),
    ], spacing: "-s1-")
    
    addColorToAll()
  }
}

class NordLead2PerfPartController : NewPatchEditorController {
  override var prefix: SynthPath? { return [.part, .i(index)] }

  override var index: Int {
    didSet { onCheckbox.label = "Slot \(NordLead2Editor.slotNames[index])" }
  }

  private let onCheckbox = PBCheckbox(label: "On")
  
  override func loadView(_ view: PBView) {
    grid(view: view, items: [[
      (onCheckbox, [.on]),
      (PBKnob(label: "Channel"), [.channel]),
      (PBSelect(label: "LFO 1 Sync"), [.lfo, .i(0), .sync]),
      (PBSelect(label: "LFO 2 Sync"), [.lfo, .i(1), .sync]),
      (PBCheckbox(label: "Flt Env Ext"), [.filter, .env, .trigger]),
      (PBKnob(label: "Flt Chan"), [.filter, .env, .trigger, .channel]),
      (PBKnob(label: "Flt Note"), [.filter, .env, .trigger, .note]),
      (PBCheckbox(label: "Amp Env Ext"), [.amp, .env, .trigger]),
      (PBKnob(label: "Amp Chan"), [.amp, .env, .trigger, .channel]),
      (PBKnob(label: "Amp Note"), [.amp, .env, .trigger, .note]),
      ],[
      (PBCheckbox(label: "Morph Ext"), [.morph, .trigger]),
      (PBKnob(label: "Morph Chan"), [.morph, .trigger, .channel]),
      (PBKnob(label: "Morph Note"), [.morph, .trigger, .note]),
      (PBSwitch(label: "Bank"), [.bank]),
      (PBKnob(label: "Pgm"), [.pgm]),
      (PBKnob(label: "Ch Press Amt"), [.channel, .pressure, .amt]),
      (PBSwitch(label: "Ch Press Dest"), [.channel, .pressure, .dest]),
      (PBKnob(label: "Pedal Amt"), [.foot, .amt]),
      (PBSwitch(label: "Pedal Dest"), [.foot, .dest, .note]),
      ]])
    
    dims(view: view, forPath: [.on])
  }
  
}
