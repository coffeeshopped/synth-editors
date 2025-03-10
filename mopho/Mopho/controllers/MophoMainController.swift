
struct MophoMainController {
  
  static func controller() -> FnPagedEditorController {
    controller(voiceController: MophoVoiceController.controller) { (vc) in
      vc.grid(panel: "vol", items: [[(PBKnob(label: "Voice Vol"), [.volume])]])

      vc.grid(panel: "ctrl", items: [[
        (PBKnob(label: "Tempo"), [.tempo]),
        (PBSelect(label: "Clock Divide"), [.clock, .divide]),
        (PBCheckbox(label: "Sequencer"), [.seq, .on]),
        (PBSelect(label: "Seq Trigger"), [.seq, .trigger]),
        (PBCheckbox(label: "Arp"), [.arp, .on]),
        (PBSwitch(label: "Arp Mode"), [.arp, .mode]),
        ]])
    }
  }
  
  static func controller(voiceController: @escaping () -> FnPatchEditorController, ctrlPanel: (FnPatchEditorController) -> Void) -> FnPagedEditorController {
    ActivatedFnEditorController { (vc) in
      ctrlPanel(vc)

      vc.switchCtrl = PBSegmentedControl(items: ["Voice", "Sequencer"])
      vc.grid(panel: "switch", pinMargin: "", items: [[(vc.switchCtrl, nil)]])

      vc.addLayoutConstraints { (layout) in
        layout.addRowConstraints([("switch", 4), ("vol", 2), ("ctrl", 12)], pinned: true, spacing: "-s1-")
        layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
        layout.addColumnConstraints([
          ("switch",1),("page",8),
        ], pinned: true, spacing: "-s1-")
      }
      
      vc.addColor(panels: ["vol", "ctrl"], level: 1)
      vc.addColor(panels: ["switch"], level: 1, clearBackground: true)
      
      vc.setControllerBlocks([
        voiceController,
        MophoSeqController.controller
      ])
    }
  }
  
}

