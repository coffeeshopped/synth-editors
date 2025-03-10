
class MS2KVoiceController : KorgMVoiceController<MS2KTimbreViewController, MS2KVocoderViewController> {
  
  override func loadView(_ view: PBView) {
    addChild(pageController, withPanel: "page")
    createPanels(forKeys: ["mode","scale","fx","delay","eq","arp"])
    addPanelsToLayout(andView: view)

    initCommonPanels()

    layout.addRowConstraints([
      ("mode", 2), ("fx", 4), ("delay", 5), ("eq", 4)
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([
      ("scale",4),("arp",10)
      ], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("mode",1),("scale",1),("page",7),
      ], pinned: true, spacing: "-s1-")

    let splitPt = PBKnob(label: "Split Pt")
    quickGrid(panel: "scale", items: [[
      (PBSwitch(label: "Timbre Vc"), [.timbre, .voice], nil),
      (splitPt, [.split, .pt], nil),
      (PBSelect(label: "Scale"), [.scale, .type], nil),
      (PBKnob(label: "Key"), [.scale, .key], nil),
      ]])

    quickGrid(panel: "arp", items: [[
      (PBCheckbox(label: "Arp"), [.arp, .on], nil),
      (PBCheckbox(label: "Latch"), [.arp, .latch], nil),
      (PBSelect(label: "Type"), [.arp, .type], nil),
      (PBKnob(label: "Range"), [.arp, .range], nil),
      (PBKnob(label: "Tempo"), [.arp, .tempo], nil),
      (PBKnob(label: "Gate"), [.arp, .gate, .time], nil),
      (PBSwitch(label: "Target"), [.arp, .dest], nil),
      (PBCheckbox(label: "Key Sync"), [.arp, .key, .sync], nil),
      (PBSelect(label: "Resolution"), [.arp, .resolution], nil),
      (PBKnob(label: "Swing"), [.arp, .swing], nil),
      ]])
    
    addPatchChangeBlock(path: [.voice, .mode]) { splitPt.isHidden = $0 != 1 }
    
    addColorToAll(except: ["switch", "page"], level: 2)
    addColor(panels: ["switch"], level: 2, clearBackground: true)
    addBorder(view: view, level: 2)

  }
  
  
}
