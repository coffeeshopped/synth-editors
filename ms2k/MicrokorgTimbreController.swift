
class MicrokorgTimbreController : KorgMTimbreController {
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch", "assign", "transpose", "osc1", "osc2", "mix","mod"])
    let _: [MS2KLFOController] = addChildren(count: 2, panelPrefix: "lfo")
    addChild(MicrokorgTimbreEnv1Controller(), withPanel: "env1")
    addChild(MicrokorgTimbreEnv2Controller(), withPanel: "env2")

    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch",4), ("assign",5), ("transpose",5),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("osc1",5), ("osc2",5), ("mix",3),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("env1",6), ("env2",6),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("lfo0",3),("lfo1",3),("mod",8),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1), ("osc1",1), ("env1",2), ("lfo0",2)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["transpose","mix","env2","mod"], attribute: .trailing)
    
    initCommonPanels()
    
    quickGrid(panel: "assign", items: [[
      (PBSwitch(label: "Assign"), [.voice, .assign], nil),
      (trigger, [.trigger, .mode], nil),
      (detune, [.unison, .tune], nil),
      ]])

    quickGrid(panel: "mod", items: [[
      (PBSelect(label: "Src 1"), [.patch, .i(0), .src], nil),
      (PBKnob(label: "Int 1"), [.patch, .i(0), .amt], nil),
      (PBSelect(label: "Dest 1"), [.patch, .i(0), .dest], nil),
      (PBSelect(label: "Src 2"), [.patch, .i(1), .src], nil),
      (PBKnob(label: "Int 2"), [.patch, .i(1), .amt], nil),
      (PBSelect(label: "Dest 2"), [.patch, .i(1), .dest], nil),
      ],[
      (PBSelect(label: "Src 3"), [.patch, .i(2), .src], nil),
      (PBKnob(label: "Int 3"), [.patch, .i(2), .amt], nil),
      (PBSelect(label: "Dest 3"), [.patch, .i(2), .dest], nil),
      (PBSelect(label: "Src 4"), [.patch, .i(3), .src], nil),
      (PBKnob(label: "Int 4"), [.patch, .i(3), .amt], nil),
      (PBSelect(label: "Dest 4"), [.patch, .i(3), .dest], nil),
      ]])
    
    registerForEditMenu(button, bundle: (
      paths: { Self.AllPaths },
      pasteboardType: "com.cfshpd.microkorgTimbre",
      initialize: { [] },
      randomize: { [] }
    ))

    addColorToAll(except: ["switch"], level: 2)
    addColor(panels: ["switch"], level: 2, clearBackground: true)
    addBorder(view: view, level: 2)

  }
  
  static let AllPaths: [SynthPath] = MicrokorgPatch.paramKeys().compactMap {
    guard $0.starts(with: [.tone, .i(0)]) else { return nil }
    return $0.subpath(from: 2)
  }
  
  override func initialize(_ sender: Any?) {
    pushChange(fromPatch: MicrokorgPatch())
  }
  
  override func randomize(_ sender: Any?) {
    pushChange(fromPatch: MicrokorgPatch.random())
  }
  
  private func pushChange(fromPatch p: SysexPatch) {
    var changes = [SynthPath:Int]()
    Self.AllPaths.forEach {
      guard let value = p[[.tone, .i(0)] + $0] else { return }
      changes[$0] = value
    }
    pushPatchChange(MakeParamsChange(changes))
  }

}

class MicrokorgTimbreEnv1Controller : MS2KEnvController {
  
  override func loadView(_ view: PBView) {
    index = 0
    envCtrl.label = "Filter"
    
    quickGrid(view: view, items: [[
      (PBSwitch(label: "Filter"), [.filter, .type], nil),
      (PBKnob(label: "Cutoff"), [.cutoff], nil),
      (PBKnob(label: "Env Depth"), [.filter, .env, .amt], nil),
      (envCtrl, nil, "env"),
      (PBCheckbox(label: "Reset"), [.env, .i(index), .reset], nil),
      ],[
      (PBKnob(label: "Reson"), [.reson], nil),
      (PBKnob(label: "Key Track"), [.filter, .key, .trk], nil),
      (PBKnob(label: "A"), [.env, .i(index), .attack], nil),
      (PBKnob(label: "D"), [.env, .i(index), .decay], nil),
      (PBKnob(label: "S"), [.env, .i(index), .sustain], nil),
      (PBKnob(label: "R"), [.env, .i(index), .release], nil),
      ]])
  }
  
}

class MicrokorgTimbreEnv2Controller : MS2KEnvController {
  
  override func loadView(_ view: PBView) {
    index = 1
    envCtrl.label = "Amp"
    
    quickGrid(view: view, items: [[
      (PBKnob(label: "Level"), [.amp, .level], nil),
      (PBKnob(label: "Pan"), [.pan], nil),
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
