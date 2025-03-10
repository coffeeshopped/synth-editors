
class DX200SceneController : NewPatchEditorController {
  
  override var prefix: SynthPath? { return [.scene, .i(index)] }
  
  override var index: Int {
    didSet { menuButton?.title = "Scene \(index + 1)" }
  }
  
  private var menuButton: PBButton!
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["fx", "lfo", "filter", "amp", "mods", "menu"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("filter", 4.5), ("mods", 3)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("fx", 2), ("lfo",4), ("menu", 2)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("filter",2),("amp",1),("fx",1)], pinned: true, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["filter","amp"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["mods","amp"], attribute: .bottom)
    
    quickGrid(panel: "filter", items: [[
      (PBSwitch(label: "Filter"), [.filter, .type], nil),
      (PBKnob(label: "Cutoff"), [.cutoff], nil),
      (PBKnob(label: "Reson"), [.reson], nil),
      (PBKnob(label: "Env Amt"), [.filter, .env, .amt], nil),
      ],[
      (PBKnob(label: "Attack"), [.filter, .env, .attack], nil),
      (PBKnob(label: "Decay"), [.filter, .env, .decay], nil),
      (PBKnob(label: "Sustain"), [.filter, .env, .sustain], nil),
      (PBKnob(label: "Release"), [.filter, .env, .release], nil),
      ]])
    
    quickGrid(panel: "fx", items: [[
      (PBKnob(label: "FX Send"), [.fx, .send], nil),
      (PBKnob(label: "Param"), [.param], nil),
      ]])
    
    quickGrid(panel: "amp", items: [[
      (PBKnob(label: "Amp Attack"), [.amp, .env, .attack], nil),
      (PBKnob(label: "Decay"), [.amp, .env, .decay], nil),
      (PBKnob(label: "Sustain"), [.amp, .env, .sustain], nil),
      (PBKnob(label: "Release"), [.amp, .env, .release], nil),
      (PBKnob(label: "Volume"), [.volume], nil),
      ]])
    
    quickGrid(panel: "mods", items: [[
      (PBKnob(label: "Harmonic 1"), [.mod, .i(0), .harmonic], nil),
      (PBKnob(label: "FM Depth 1"), [.mod, .i(0), .fm, .amt], nil),
      (PBKnob(label: "Env Decay 1"), [.mod, .i(0), .env, .decay], nil),
      ],[
      (PBKnob(label: "Harmonic 2"), [.mod, .i(1), .harmonic], nil),
      (PBKnob(label: "FM Depth 2"), [.mod, .i(1), .fm, .amt], nil),
      (PBKnob(label: "Env Decay 2"), [.mod, .i(1), .env, .decay], nil),
      ],[
      (PBKnob(label: "Harmonic 3"), [.mod, .i(2), .harmonic], nil),
      (PBKnob(label: "FM Depth 3"), [.mod, .i(2), .fm, .amt], nil),
      (PBKnob(label: "Env Decay 3"), [.mod, .i(2), .env, .decay], nil),
      ]])
    
    quickGrid(panel: "lfo", items: [[
      (PBKnob(label: "LFO Speed"), [.voice, .lfo, .speed], nil),
      (PBKnob(label: "Porta T"), [.extra, .porta, .time], nil),
      (PBKnob(label: "Noise Level"), [.noise, .level], nil),
      (PBKnob(label: "Pan"), [.pan], nil),
      ]])
    
    menuButton = createMenuButton(titled: "Scene")
    quickGrid(panel: "menu", items: [[(menuButton, nil, "menuButton")]])
    
    registerForEditMenu(menuButton, bundle: (
      paths: { Self.copyPastePaths },
      pasteboardType: "com.cfshpd.DX200Scene",
      initialize: nil,
      randomize: nil
    ))

    addColorToAll(except: ["menu"], level: 2)
    addColor(panels: ["menu"], level: 2, clearBackground: true)
    addBorder(view: view, level: 2)

  }

  
  private static let copyPastePaths = DX200VoiceScenePatch.paramKeys()
  
  #if os(iOS)
  func syncMenuItem() -> PBMenuItem {
    return PBMenuItem(title: "Sync", action: #selector(sync(_:)))
  }
  #else
  func syncMenuItem() -> PBMenuItem {
    return PBMenuItem(title: "Sync", action: #selector(sync(_:)), keyEquivalent: "")
  }
  #endif
  
//  override func menuItems() -> [PBMenuItem]? {
//    return [syncMenuItem()]
//  }
  
  static let syncPathMap: [SynthPath] = [
    [.voice, .common, .filter, .type],
    [.voice, .common, .cutoff],
    [.voice, .common, .reson],
    [.voice, .common, .filter, .env, .amt],
    [.voice, .common, .filter, .env, .attack],
    [.voice, .common, .filter, .env, .decay],
    [.voice, .common, .filter, .env, .sustain],
    [.voice, .common, .filter, .env, .release],
    [.voice, .common, .amp, .env, .attack],
    [.voice, .common, .amp, .env, .decay],
    [.voice, .common, .amp, .env, .sustain],
    [.voice, .common, .amp, .env, .release],
    [.voice, .common, .noise, .level],
    [.voice, .common, .mod, .i(0), .harmonic],
    [.voice, .common, .mod, .i(1), .harmonic],
    [.voice, .common, .mod, .i(2), .harmonic],
    [.voice, .common, .mod, .i(0), .fm, .amt],
    [.voice, .common, .mod, .i(1), .fm, .amt],
    [.voice, .common, .mod, .i(2), .fm, .amt],
    [.voice, .common, .mod, .i(0), .env, .decay],
    [.voice, .common, .mod, .i(1), .env, .decay],
    [.voice, .common, .mod, .i(2), .env, .decay],
    [.part, .voice, .fx, .send],
    [.part, .voice, .volume],
    [.part, .voice, .pan],
    [.voice, .fx, .param],
    [.voice, .voice, .voice, .lfo, .speed],
    [.voice, .voice, .extra, .porta, .time],
  ]
  
  @objc func sync(_ sender: Any?) {
//    var values = [SynthPath:Int]()
//    type(of: self).syncPathMap.forEach {
//      values[$0.subpath(from: 2)] = lastPatchState[$0]
//    }
//    changePatch(.paramsChange(values))
  }
  
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    switch action {
    case #selector(sync(_:)):
      return true
    default:
      return super.canPerformAction(action, withSender: sender)
    }
  }
}
