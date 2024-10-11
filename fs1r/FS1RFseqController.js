
//  private let arrayCtrl = FS1RFseqControl(label: "")
//  private let toolCtrl = PBGridSelectControl(label: "")
//
//  private var vn: SynthPathItem = .voiced {
//    didSet { index += 0 }
//  }
//
//  private var freqLevel: SynthPathItem = .freq {
//    didSet { index += 0 }
//  }
//
//  override var prefix: SynthPath? {
//    guard index > 0 else { return [.pitch] }
//    return [.trk, .i(index - 1), vn, freqLevel]
//  }
  
//  override func loadView(_ view: PBView) {
//    createPanels(forKeys: ["trk", "vn", "freqLev", "menu", "modes", "array"])
//    addPanelsToLayout(andView: view)
//    
//    layout.addRowConstraints([("trk", 6), ("vn", 3), ("freqLev", 3), ("menu", 2)], pinned: true, spacing: "-s1-")
//    layout.addRowConstraints([("modes", 1), ("array", 14)], pinned: true, spacing: "-s1-")
//    layout.addColumnConstraints([("trk", 1), ("modes",7)], pinned: true, spacing: "-s1-")
//    
//    let switcher = LabeledSegmentedControl(label: "Track", items: ["Pitch","1","2","3","4","5","6","7","8"])
//    switchCtrl = switcher.segmentedControl
//    
//    let vnSwitch = PBSegmentedControl(items: ["Voiced", "Unvoiced"])
//    vnSwitch.addValueChangeTarget(self, action: #selector(selectVN(_:)))
//    
//    let freqLevelSwitch = PBSegmentedControl(items: ["Freq", "Level"])
//    freqLevelSwitch.addValueChangeTarget(self, action: #selector(selectFreqLevel(_:)))
//    
//    quickGrid(panel: "trk", items: [[(switcher, nil, "trackSwitch")]])
//
//    quickGrid(panel: "vn", items: [[(vnSwitch, nil, "vnSwitch")]])
//
//    quickGrid(panel: "freqLev", items: [[(freqLevelSwitch, nil, "freqSwitch")]])
//
////    menuButton = createMenuButton(titled: "Free EG")
////    quickGrid(panel: "menu", items: [[(menuButton, nil, "menuButton")]])
//
//    let gridCtrlOptions: [Int:String] = [
//      FS1RFseqControl.Mode.pen.rawValue : "✏️",
//      FS1RFseqControl.Mode.line.rawValue : "📏",
//      FS1RFseqControl.Mode.smooth.rawValue : "🍑",
//      FS1RFseqControl.Mode.randomize.rawValue : "🤪",
//      FS1RFseqControl.Mode.shiftX.rawValue : "⏩",
//      FS1RFseqControl.Mode.shiftY.rawValue : "⏫",
//      FS1RFseqControl.Mode.scaleY.rawValue : "↕️",
//    ]
//    toolCtrl.fontSize = 30
//    toolCtrl.options = gridCtrlOptions
//    toolCtrl.columnCount = 1
//    toolCtrl.addValueChangeTarget(self, action: #selector(modeChange(_:)))
//    quickGrid(panel: "modes", items: [[(toolCtrl, nil, "gridCtrl")]])
//    
//    arrayCtrl.count = 128
//    arrayCtrl.range = 0...16383
//    quickGrid(panel: "array", items: [[(arrayCtrl, nil, "arr")]])
//    
//    
//  }
//  
//  @IBAction func modeChange(_ sender: PBGridSelectControl) {
//    arrayCtrl.mode = FS1RFseqControl.Mode(rawValue: sender.value)!
//  }
//  
//  @IBAction func selectVN(_ sender: PBSegmentedControl) {
//    vn = sender.selectedSegment == 0 ? .voiced : .unvoiced
//  }
//  
//  @IBAction func selectFreqLevel(_ sender: PBSegmentedControl) {
//    freqLevel = sender.selectedSegment == 0 ? .freq : .level
//  }
//  
//  override func apply(colorGuide: ColorGuide) {
//    view.backgroundColor = backgroundColor(forColorGuide: colorGuide, level: 2)
//    colorAllPanels(colorGuide: colorGuide, level: 2)
//    panels["switch"]?.backgroundColor = .clear
//    panels["menu"]?.backgroundColor = .clear
//  }
