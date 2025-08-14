
//public class DX7iiExtraController : NewPatchEditorController {
//  
//  public override var prefix: SynthPath? { return [.extra] }
//    
//  public override func loadView() {
//    let paddedView = PaddedContainer()
//    paddedView.horizontalPadding = 0.15
//    paddedView.verticalPadding = 0.1
//    let view = paddedView.mainView
//    
//    createPanels(forKeys: ["mods","porta","bend","mods2","other"])
//    addPanelsToLayout(andView: view)
//    
//    layout.addRowConstraints([
//      ("mods",6),("porta",3),("bend",3),
//      ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
//    layout.addColumnConstraints([
//      ("porta",1),("mods2",2),("other",1)
//      ], pinned: true, spacing: "-s1-")
//    layout.addEqualConstraints(forItemKeys: ["porta","bend"], attribute: .bottom)
//    layout.addEqualConstraints(forItemKeys: ["mods","other"], attribute: .bottom)
//    layout.addEqualConstraints(forItemKeys: ["bend","mods2","other"], attribute: .trailing)
//    
//    quickGrid(panel: "mods", items: [[
//      (LabelItem(text: "Mod Wheel"), nil, "modLabel"),
//      (PBKnob(label: "Pitch"), [.modWheel, .pitch], nil),
//      (PBKnob(label: "Amp"), [.modWheel, .amp], nil),
//      (PBKnob(label: "Env Bias"), [.modWheel, .env, .bias], nil),
//      (PBView(), nil, "modSpace"),
//      ],[
//      (LabelItem(text: "Foot Ctrl"), nil, "footLabel"),
//      (PBKnob(label: "Pitch"), [.foot, .pitch], nil),
//      (PBKnob(label: "Amp"), [.foot, .amp], nil),
//      (PBKnob(label: "Env Bias"), [.foot, .env, .bias], nil),
//      (PBKnob(label: "Volume"), [.foot, .volume], nil),
//      ],[
//      (LabelItem(text: "Breath Ctrl"), nil, "breathLabel"),
//      (PBKnob(label: "Pitch"), [.breath, .pitch], nil),
//      (PBKnob(label: "Amp"), [.breath, .amp], nil),
//      (PBKnob(label: "Env Bias"), [.breath, .env, .bias], nil),
//      (PBKnob(label: "P Bias"), [.breath, .pitch, .bias], nil),
//      ],[
//      (LabelItem(text: "Aftertouch"), nil, "afterLabel"),
//      (PBKnob(label: "Pitch"), [.aftertouch, .pitch], nil),
//      (PBKnob(label: "Amp"), [.aftertouch, .amp], nil),
//      (PBKnob(label: "Env Bias"), [.aftertouch, .env, .bias], nil),
//      (PBKnob(label: "P Bias"), [.aftertouch, .pitch, .bias], nil),
//      ]])
//    
//    quickGrid(panel: "porta", items: [[
//      (PBSwitch(label: "Porta"), [.porta, .mode], nil),
//      (PBKnob(label: "Time"), [.porta, .time], nil),
//      (PBKnob(label: "Step"), [.porta, .step], nil)],
//      ])
//
//    quickGrid(panel: "bend", items: [[
//      (PBKnob(label: "Bend Range"), [.bend, .range], nil),
//      (PBKnob(label: "Step"), [.bend, .step], nil),
//      (PBKnob(label: "Mode"), [.bend, .mode], nil)],
//      ])
//
//
//    quickGrid(panel: "mods2", items: [[
//      (LabelItem(text: "Foot 2 Ctrl"), nil, "foot2Label"),
//      (PBKnob(label: "Pitch"), [.foot, .i(1), .pitch], nil),
//      (PBKnob(label: "Amp"), [.foot, .i(1), .amp], nil),
//      (PBKnob(label: "Env Bias"), [.foot, .i(1), .env, .bias], nil),
//      (PBKnob(label: "Volume"), [.foot, .i(1), .volume], nil),
//      ],[
//      (LabelItem(text: "MIDI Ctrl"), nil, "midiLabel"),
//      (PBKnob(label: "Pitch"), [.midi, .ctrl, .pitch], nil),
//      (PBKnob(label: "Amp"), [.midi, .ctrl, .amp], nil),
//      (PBKnob(label: "Env Bias"), [.midi, .ctrl, .env, .bias], nil),
//      (PBKnob(label: "Volume"), [.midi, .ctrl, .volume], nil),
//      ]])
//
//    quickGrid(panel: "other", items: [[
//      (PBKnob(label: "Unison Detune"), [.unison, .detune], nil),
//      (PBCheckbox(label: "Foot 1 > CS 1"), [.foot, .slider], nil),
//      ]])
//
//    layout.activateConstraints()
//    self.view = paddedView
//    addColorToAll(level: 2)
//  }
//  
//}
//
