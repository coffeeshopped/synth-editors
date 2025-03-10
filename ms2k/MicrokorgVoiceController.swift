
class MicrokorgVoiceController : KorgMVoiceController<MicrokorgTimbreController, MicrokorgVocoderController> {
  
  override func loadView(_ view: PBView) {
    addChild(pageController, withPanel: "page")
    addChild(ArpController(), withPanel: "arp")
    createPanels(forKeys: ["mode","fx","delay","eq"])
    addPanelsToLayout(andView: view)

    initCommonPanels()

    layout.addRowConstraints([
      ("mode", 2), ("delay", 5), ("arp", 9)
    ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([
      ("eq", 4), ("fx", 3)
    ], pinned: false, spacing: "-s1-")
    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([
      ("mode",1),("eq",1),("page",6),
      ], pinned: true, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["mode", "delay"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["fx", "arp"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["delay", "fx"], attribute: .trailing)
    
    addColorToAll(except: ["switch", "page"], level: 2)
    addColor(panels: ["switch"], level: 2, clearBackground: true)
    addBorder(view: view, level: 2)

  }
  
  class ArpController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      let target = PBSwitch(label: "Target")
      let steps = (0..<8).map { PBCheckbox(label: "\($0+1)") }
      quickGrid(view: view, items: [[
        (PBCheckbox(label: "Arp"), [.arp, .on], nil),
        (PBSelect(label: "Type"), [.arp, .type], nil),
        (PBKnob(label: "Range"), [.arp, .range], nil),
        (PBKnob(label: "Tempo"), [.arp, .tempo], nil),
        (PBKnob(label: "Gate"), [.arp, .gate, .time], nil),
        (target, [.arp, .dest], nil),
        (PBCheckbox(label: "Key Sync"), [.arp, .key, .sync], nil),
        (PBSelect(label: "Resolution"), [.arp, .resolution], nil),
        (PBKnob(label: "Swing"), [.arp, .swing], nil),
        ],[
        (PBCheckbox(label: "Latch"), [.arp, .latch], nil),
        (PBKnob(label: "Steps"), [.trigger, .length], nil),
        (steps[0], [.trigger, .i(0)], nil),
        (steps[1], [.trigger, .i(1)], nil),
        (steps[2], [.trigger, .i(2)], nil),
        (steps[3], [.trigger, .i(3)], nil),
        (steps[4], [.trigger, .i(4)], nil),
        (steps[5], [.trigger, .i(5)], nil),
        (steps[6], [.trigger, .i(6)], nil),
        (steps[7], [.trigger, .i(7)], nil),
        ]])
      
      dims(view: view, forPath: [.arp, .on])
      addPatchChangeBlock(path: [.trigger, .length]) { value in
        steps.enumerated().forEach {
          $0.element.isHidden = value < $0.offset
        }
      }
      addPatchChangeBlock(path: [.voice, .mode]) { target.isHidden = $0 != 2 }

    }
  }
    
}
