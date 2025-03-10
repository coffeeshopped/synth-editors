
class MS2KVocoderViewController : KorgMVocoderController {
  
  override func loadView(_ view: PBView) {
    let _: [MS2KLFOController] = addChildren(count: 2, panelPrefix: "lfo")
    addChild(MS2KVocoderEnv1Controller(), withPanel: "env1")
    addChild(MS2KVocoderEnv2Controller(), withPanel: "env2")
    createPanels(forKeys: ["switch", "assign", "transpose", "osc1", "audio", "mix","level","pan"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch",2), ("assign",7), ("transpose",5), ("lfo0",4),
      ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("osc1",5), ("audio",5), ("mix",3),
      ], pinned: false, spacing: "-s1-")
    layout.addRowConstraints([
      ("env1",6), ("env2",6),
      ], pinned: false, spacing: "-s1-")
    layout.addRowConstraints([
      ("level",1),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("pan",1),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1), ("osc1",1), ("env1",2), ("level",1), ("pan",1)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["lfo0","lfo1","level","pan"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["transpose","mix"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["switch","assign","transpose"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["lfo0","mix"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["mix","env2"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["lfo0","lfo1"], attribute: .leading)
    layout.addEqualConstraints(forItemKeys: ["lfo0","lfo1"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["env2","lfo1"], attribute: .top)
    layout.addEqualConstraints(forItemKeys: ["env2","lfo1"], attribute: .bottom)

    initCommonPanels()

    quickGrid(panel: "assign", items: [[
      (PBSwitch(label: "Assign"), [.voice, .assign], nil),
      (PBKnob(label: "MIDI Ch"), [.channel], nil),
      (PBSwitch(label: "Priority"), [.voice, .priority], nil),
      (trigger, [.trigger, .mode], nil),
      (detune, [.unison, .tune], nil),
      ]])

    quickGrid(panel: "level", items: [(0..<16).map {
      let label = $0 == 0 ? "Level 1" : "\($0+1)"
      return (PBKnob(label: label), [.level, .i($0)], nil)
      }])
    
    quickGrid(panel: "pan", items: [(0..<16).map {
      let label = $0 == 0 ? "Pan 1" : "\($0+1)"
      return (PBKnob(label: label), [.pan, .i($0)], nil)
      }])
    
    addColorToAll(except: ["switch"], level: 2)
    addColor(panels: ["switch"], level: 2, clearBackground: true)
    addBorder(view: view, level: 2)

  }
  
}

class MS2KVocoderEnv1Controller : MS2KEnvController {
  
  override func loadView(_ view: PBView) {
    index = 0
    envCtrl.label = "Filter"
    
    quickGrid(view: view, items: [[
      (PBKnob(label: "Formant Shift"), [.formant, .shift], nil),
      (PBKnob(label: "Cutoff"), [.cutoff], nil),
      (PBKnob(label: "Reson"), [.reson], nil),
      (PBSelect(label: "Mod Source"), [.filter, .mod, .src], nil),
      (PBKnob(label: "Mod Int"), [.filter, .mod, .amt], nil),
      (PBKnob(label: "EF Sens"), [.env, .follow, .sens], nil),
      ],
      adsrItems()
      ])
  }
  
}

class MS2KVocoderEnv2Controller : MS2KEnvController {
  
  override func loadView(_ view: PBView) {
    index = 1
    envCtrl.label = "Amp"
    
    quickGrid(view: view, items: [[
      (PBKnob(label: "Level"), [.amp, .level], nil),
      (PBKnob(label: "Direct"), [.direct, .level], nil),
      (PBCheckbox(label: "Distort"), [.dist], nil),
      (PBKnob(label: "Velo"), [.amp, .velo], nil),
      (PBKnob(label: "Key Track"), [.amp, .key, .trk], nil),
      ],
      adsrItems()
      ])
  }
}
