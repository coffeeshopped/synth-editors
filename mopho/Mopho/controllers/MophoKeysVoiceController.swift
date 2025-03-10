
struct MophoKeysVoiceController {

  static func controller() -> FnPatchEditorController {
    MophoVoiceController.controller { (vc) in
      let oscs = MophoVoiceController.oscsController {
        $0.grid(panel: "sync", items: [[
          (PBCheckbox(label: "Sync 2→1"), [.sync]),
          (PBKnob(label: "Slop"), [.slop]),
          (PBKnob(label: "Bend"), [.bend]),
          (PBSelect(label: "Key Assign Mode"), [.keyAssign]),
          ],[
          (PBKnob(label: "Mix"), [.mix]),
          (PBKnob(label: "Noise"), [.noise]),
          (PBKnob(label: "Ext Aud Vol"), [.extAudio]),
          (PBKnob(label: "Ext Aud Gain"), [.extAudio, .gain]),
          (PBSwitch(label: "Glide Mode"), [.glide]),
          ]])
      }
      vc.addChild(oscs, withPanel: "oscs")

      vc.grid(panel: "uni", items: [[
        (PBCheckbox(label: "Unison"), [.unison]),
        ],[
        (PBSelect(label: "Unison Mode"), [.unison, .mode]),
        ]])

      vc.addLayoutConstraints {
        $0.addRowConstraints([
          ("oscs",12), ("mods",4)
          ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addRowConstraints([
          ("fEnv", 7), ("aEnv",5)
          ], pinned: false, spacing: "-s1-")
        $0.addRowConstraints([
          ("lfos",6), ("env3", 6.5), ("push", 3.5)
        ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addRowConstraints([
          ("uni", 2), ("controls", 7)
        ], pinned: false, spacing: "-s1-")

        $0.addColumnConstraints([
          ("oscs",2),("fEnv",2),("lfos",4)
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addColumnConstraints([
          ("env3",2),("uni",2),
          ], pinned: false, spacing: "-s1-")

        $0.addEqualConstraints(forItemKeys: ["aEnv","oscs"], attribute: .trailing)
        $0.addEqualConstraints(forItemKeys: ["aEnv","mods"], attribute: .bottom)
        $0.addEqualConstraints(forItemKeys: ["push","controls"], attribute: .trailing)
        $0.addEqualConstraints(forItemKeys: ["lfos","uni"], attribute: .bottom)
        $0.addEqualConstraints(forItemKeys: ["env3","push"], attribute: .bottom)
      }
    }
  }
      
}
