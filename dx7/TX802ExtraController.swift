
//class TX802ExtraController : NewPatchEditorController {
//  
//  override var prefix: SynthPath? { return [.extra] }
//    
//  override func loadView() {
//    let paddedView = PaddedContainer()
//    paddedView.horizontalPadding = 0.15
//    paddedView.verticalPadding = 0.1
//    let view = paddedView.mainView
//    
//    createPanels(forKeys: ["mods","porta","bend","space"])
//    addPanelsToLayout(andView: view)
//    
//    layout.addRowConstraints([
//      ("mods",6),("porta",3),("bend",3),
//      ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
//    layout.addColumnConstraints([
//      ("porta",1),("space",3)
//      ], pinned: true, spacing: "-s1-")
//    layout.addEqualConstraints(forItemKeys: ["porta","bend"], attribute: .bottom)
//    layout.addEqualConstraints(forItemKeys: ["mods","space"], attribute: .bottom)
//    layout.addEqualConstraints(forItemKeys: ["bend","space"], attribute: .trailing)
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
//    layout.activateConstraints()
//    self.view = paddedView
//    
//    addColorToAll(except: ["space"], level: 2)
//  }  
//}
//
