
class EvolverWaveController : NewPatchEditorController {
  
  private let arrayCtrl = PBArrayControl(label: "")
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["number", "modes" , "array"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("number", 1), ("array", 14)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("number", 1), ("modes",7)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["modes", "array"], attribute: .bottom)

    let waveNumber = PBKnob(label: "Wave #")
    quickGrid(panel: "number", items: [[(waveNumber, nil, "waveNumber")]])
    waveNumber.displayOffset = 1
    addDefaultControlChangeBlock(control: waveNumber, path: [.number])

    let gridCtrlOptions: [Int:String] = [
      PBArrayControl.Mode.pen.rawValue : "✏️",
      PBArrayControl.Mode.line.rawValue : "📏",
      PBArrayControl.Mode.smooth.rawValue : "🍑",
      PBArrayControl.Mode.randomize.rawValue : "🤪",
      PBArrayControl.Mode.shiftX.rawValue : "⏩",
      PBArrayControl.Mode.shiftY.rawValue : "⏫",
      PBArrayControl.Mode.scaleY.rawValue : "↕️",
    ]
    let gridCtrl = PBGridSelectControl(label: "")
    gridCtrl.fontSize = 30
    gridCtrl.options = gridCtrlOptions
    gridCtrl.columnCount = 1
    gridCtrl.addValueChangeTarget(self, action: #selector(modeChange(_:)))
    quickGrid(panel: "modes", items: [[(gridCtrl, nil, "gridCtrl")]])
    
    arrayCtrl.count = 128
    arrayCtrl.range = -32768...32767
    quickGrid(panel: "array", items: [[(arrayCtrl, nil, "arr")]])
    
    let arrayCtrl = self.arrayCtrl
    (0..<128).forEach { step in
      addPatchChangeBlock(path: [.data, .i(step)]) { arrayCtrl[step] = $0 }
    }
    addControlChangeBlock(control: arrayCtrl) {
      var changes = [SynthPath:Int]()
      (0..<128).forEach { changes[[.data, .i($0)]] = arrayCtrl[$0] }
      return .paramsChange(SynthPathIntsMake(changes))
    }

    addColorToAll(level: 2)
  }

  @IBAction func modeChange(_ sender: PBGridSelectControl) {
    arrayCtrl.mode = PBArrayControl.Mode(rawValue: sender.value)!
  }
      
}
