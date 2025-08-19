
class TG77SystemController : NewPatchEditorController {
  
  private let upperGreeting = LabeledTextField(label: "Upper Greeting")
  private let lowerGreeting = LabeledTextField(label: "Lower Greeting")

  override func loadView(_ view: PBView) {
    upperGreeting.textField.delegate = self
    lowerGreeting.textField.delegate = self
    grid(panel: "greeting", items: [[
      (upperGreeting, nil),
      ],[
      (lowerGreeting, nil),
      ]])
    
    grid(panel: "main", items: [[
      (PBKnob(label: "Note Shift"), [.note, .shift]),
      (PBKnob(label: "Fine Tune"), [.fine]),
      (PBKnob(label: "Fixed Velo"), [.fixed, .velo]),
      (PBKnob(label: "Velo Curve"), [.velo, .curve]),
      (PBKnob(label: "Mod Wheel 2"), [.modWheel]),
      (PBKnob(label: "Foot Switch"), [.foot]),
      (PBCheckbox(label: "Edit Confirm"), [.edit]),
      ],[
      (PBKnob(label: "Transmit Channel"), [.send, .channel]),
      (PBKnob(label: "Receive Channel"), [.rcv, .channel]),
      (PBCheckbox(label: "Local Switch"), [.local]),
      (PBKnob(label: "Device ID"), [.deviceId]),
      (PBSwitch(label: "Even/Odd Note"), [.note, .select]),
      (PBCheckbox(label: "Bulk Protect"), [.protect]),
      (PBSelect(label: "Pgm Ch Mode"), [.pgm, .mode]),
      ]])
    
    createPanels(forKeys: ["space"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("greeting", 5), ("space", 2)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("main", 1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("greeting",2), ("main",2)], pinned: true, spacing: "-s1-")

    addPatchChangeBlock { [weak self] (changes) in
      if let name = self?.updatedName(path: [.hi], state: changes) {
        self?.upperGreeting.textField.text = name
      }
      if let name = self?.updatedName(path: [.lo], state: changes) {
        self?.lowerGreeting.textField.text = name
      }
    }
    
    addColorToAll(except: ["space"])
  }
    
  override func handleNameChange(_ textField: PBTextField) {
    guard let name = textField.text else { return }
    switch textField {
    case upperGreeting.textField:
      pushPatchChange(.nameChange([.hi], name))
    default:
      pushPatchChange(.nameChange([.lo], name))
    }
  }


}
