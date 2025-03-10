
struct MophoKeysMainController {
  
  static func controller() -> FnPagedEditorController {
    MophoMainController.controller(voiceController: MophoKeysVoiceController.controller) { (vc) in
      vc.grid(panel: "vol", items: [[(PBKnob(label: "Voice Vol"), [.volume])]])

      vc.grid(panel: "ctrl", items: [[
        (PBKnob(label: "Tempo"), [.tempo]),
        (PBSelect(label: "Clock Divide"), [.clock, .divide]),
        (PBCheckbox(label: "Sequencer"), [.seq, .on]),
        (PBSelect(label: "Seq Trigger"), [.seq, .trigger]),
        (PBCheckbox(label: "Arp"), [.arp, .on]),
        (PBSelect(label: "Arp Mode"), [.arp, .mode]),
        ]])
    }
  }

}
