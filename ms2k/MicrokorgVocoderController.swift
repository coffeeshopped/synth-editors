
class MicrokorgVocoderController : KorgMVocoderController {
  
  override func loadView(_ view: PBView) {
    let _: [MS2KLFOController] = addChildren(count: 2, panelPrefix: "lfo")
    createPanels(forKeys: ["assign", "transpose", "osc1", "audio", "mix","level","pan","ef"])
    let ctrls: [String:PBViewController.Type] = [
      "env1": MicrokorgVocoderEnv1Controller.self,
      "env2": MicrokorgVocoderEnv2Controller.self,
      ]
    ctrls.forEach { addChild($0.value.init(), withPanel: $0.key) }

    addPanelsToLayout(andView: view)

    layout.addRowConstraints([
      ("assign",6), ("transpose",7), ("lfo0",3),
      ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("osc1",5), ("audio",4), ("mix",3),
      ], pinned: false, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("env1",4), ("env2",6),
      ], pinned: false, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("level",1), ("pan",1),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("ef",1)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([
      ("assign",1), ("osc1",1), ("env1",2), ("level",1), ("ef",1)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["lfo0","lfo1","pan","ef"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["transpose","mix"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["assign","transpose"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["lfo0","mix"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["mix","env2"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["lfo0","lfo1"], attribute: .leading)
    layout.addEqualConstraints(forItemKeys: ["lfo0","lfo1"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["env2","lfo1"], attribute: .top)
    layout.addEqualConstraints(forItemKeys: ["env2","lfo1"], attribute: .bottom)
    
    initCommonPanels()
    
    quickGrid(panel: "assign", items: [[
      (PBSwitch(label: "Assign"), [.voice, .assign], nil),
      (trigger, [.trigger, .mode], nil),
      (detune, [.unison, .tune], nil),
      ]])
    
    quickGrid(panel: "level", items: [(0..<8).map {
      let label: String = $0 == 0 ? "Level 1" : "\($0 + 1)"
      return (PBKnob(label: label), [.level, .i($0)], nil)
      }])
    
    quickGrid(panel: "pan", items: [(0..<8).map {
      let label: String = $0 == 0 ? "Pan 1" : "\($0 + 1)"
      return (PBKnob(label: label), [.pan, .i($0)], nil)
      }])
    quickGrid(panel: "ef", items: [(0..<16).map {
      let label: String = $0 == 0 ? "EF Hold 1" : "\($0 + 1)"
      return (PBKnob(label: label), [.env, .follow, .hold, .i($0)], nil)
      }])
    
    addPatchChangeBlock(path: [.env, .follow, .sens]) { [weak self] in
      self?.panels["ef"]!.alpha = $0 == 127 ? 1 : 0.5
    }
    
    addColorToAll(except: ["switch"], level: 2)
    addColor(panels: ["switch"], level: 2, clearBackground: true)
    addBorder(view: view, level: 2)

  }
    
}

class MicrokorgVocoderEnv1Controller : MS2KEnvController {
  
  override func loadView(_ view: PBView) {
    quickGrid(view: view, items: [[
      (PBKnob(label: "Formant Shift"), [.formant, .shift], nil),
      (PBKnob(label: "Cutoff"), [.cutoff], nil),
      (PBKnob(label: "Reson"), [.reson], nil),
      (PBCheckbox(label: "Reset"), [.env, .i(index), .reset], nil)
      ],[
      (PBSelect(label: "Mod Source"), [.filter, .mod, .src], nil),
      (PBKnob(label: "Mod Int"), [.filter, .mod, .amt], nil),
      (PBKnob(label: "EF Sens"), [.env, .follow, .sens], nil),
      ]])
  }
  
}

class MicrokorgVocoderEnv2Controller : MS2KEnvController {
  
  override func loadView(_ view: PBView) {
    index = 1
    envCtrl.label = "Amp"

    quickGrid(view: view, items: [[
      (PBKnob(label: "Level"), [.amp, .level], nil),
      (PBKnob(label: "Direct"), [.direct, .level], nil),
      (envCtrl, nil, "env"),
      (PBCheckbox(label: "Reset"), [.env, .i(index), .reset], nil)
      ],[
      (PBCheckbox(label: "Distort"), [.dist], nil),
      (PBKnob(label: "Key Track"), [.amp, .key, .trk], nil),
      (PBKnob(label: "A"), [.env, .i(index), .attack], nil),
      (PBKnob(label: "D"), [.env, .i(index), .decay], nil),
      (PBKnob(label: "S"), [.env, .i(index), .sustain], nil),
      (PBKnob(label: "R"), [.env, .i(index), .release], nil),
      ]])
  }
}
