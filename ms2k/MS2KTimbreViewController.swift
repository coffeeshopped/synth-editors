
class MS2KTimbreViewController : KorgMTimbreController {
  
  override func loadView(_ view: PBView) {
    let _: [MS2KLFOController] = addChildren(count: 2, panelPrefix: "lfo")
    addChild(MS2KTimbreEnv1Controller(), withPanel: "env1")
    addChild(MS2KTimbreEnv2Controller(), withPanel: "env2")
    addChild(MS2KTimbreSeqController(), withPanel: "seqTrk")
    createPanels(forKeys: ["switch", "assign", "transpose", "osc1", "osc2", "mix","mod","seq"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([
      ("switch",4), ("assign",5), ("transpose",5), ("lfo0",3),
      ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([
      ("osc1",5), ("osc2",5), ("mix",3),
      ], pinned: false, spacing: "-s1-")
    layout.addRowConstraints([
      ("env1",6), ("env2",6),
      ], pinned: false, spacing: "-s1-")
    layout.addRowConstraints([
      ("mod",4), ("seqTrk",10), ("seq",2),
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([
      ("switch",1), ("osc1",1), ("env1",2), ("mod",3)
      ], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["lfo0","lfo1","seq"], attribute: .trailing)
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
    
    let m = LabelItem(text: "Source", gridWidth: 3)
    m.textAlignment = .center
    let a = LabelItem(text: "Int", gridWidth: 2)
    a.textAlignment = .center
    let d = LabelItem(text: "Destination", gridWidth: 3)
    d.textAlignment = .center
    let modItems: [(row: [(PBView,SynthPath?,String?)], height: CGFloat)] = (0..<5).map {
      if $0 == 0 {
        return ([
          (m, nil, "srcLabel"),
          (a, nil, "amtLabel"),
          (d, nil, "destLabel")
        ], 0.5)
      }
      else {
        return ([
          (PBSelect(label: ""), [.patch, .i($0-1), .src], nil),
          (PBKnob(label: ""), [.patch, .i($0-1), .amt], nil),
          (PBSelect(label: ""), [.patch, .i($0-1), .dest], nil),
        ], 1)
      }
    }

    quickGrid(panel: "mod", itemsAndHeights: modItems)

    quickGrid(panel: "seq", items: [[
      (PBKnob(label: "Last Step"), [.seq, .last, .step], nil),
      (PBSwitch(label: "Seq Type"), [.seq, .type], nil),
      ],[
      (PBCheckbox(label: "Loop"), [.run, .mode], nil),
      (PBSwitch(label: "Key Sync"), [.seq, .key, .sync], nil),
      ],[
      (PBCheckbox(label: "Seq On"), [.seq, .on], nil),
      (PBSelect(label: "Resolution"), [.seq, .resolution], nil),
      ]])
    
    registerForEditMenu(button, bundle: (
      paths: { Self.AllPaths },
      pasteboardType: "com.cfshpd.MS2KTimbre",
      initialize: { [] },
      randomize: { [] }
    ))
    
    addColorToAll(except: ["switch"], level: 2)
    addColor(panels: ["switch"], level: 2, clearBackground: true)
    addBorder(view: view, level: 2)

  }
  
  private static let AllPaths: [SynthPath] = MS2KPatch.paramKeys().compactMap {
    guard $0.starts(with: [.tone, .i(0)]) else { return nil }
    return $0.subpath(from: 2)
  }
  
  override func initialize(_ sender: Any?) {
    pushChange(fromPatch: MS2KPatch())
  }
  
  override func randomize(_ sender: Any?) {
    pushChange(fromPatch: MS2KPatch.random())
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

class MS2KTimbreEnv1Controller : MS2KEnvController {
  
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
      (PBKnob(label: "Velo"), [.filter, .velo], nil),
      (PBKnob(label: "Key Track"), [.filter, .key, .trk], nil),
      (PBKnob(label: "A"), [.env, .i(index), .attack], nil),
      (PBKnob(label: "D"), [.env, .i(index), .decay], nil),
      (PBKnob(label: "S"), [.env, .i(index), .sustain], nil),
      (PBKnob(label: "R"), [.env, .i(index), .release], nil),
      ]])
  }
  
}

class MS2KTimbreEnv2Controller : MS2KEnvController {
  
  override func loadView(_ view: PBView) {
    index = 1
    envCtrl.label = "Amp"
    
    quickGrid(view: view, items: [[
      (PBKnob(label: "Level"), [.amp, .level], nil),
      (PBKnob(label: "Pan"), [.pan], nil),
      (PBSwitch(label: "Amp Sw"), [.amp, .mode], nil),
      (envCtrl, nil, "env"),
      (PBCheckbox(label: "Reset"), [.env, .i(index), .reset], nil)
      ],[
      (PBCheckbox(label: "Distort"), [.dist], nil),
      (PBKnob(label: "Velo"), [.amp, .velo], nil),
      (PBKnob(label: "Key Track"), [.amp, .key, .trk], nil),
      (PBKnob(label: "A"), [.env, .i(index), .attack], nil),
      (PBKnob(label: "D"), [.env, .i(index), .decay], nil),
      (PBKnob(label: "S"), [.env, .i(index), .sustain], nil),
      (PBKnob(label: "R"), [.env, .i(index), .release], nil),
      ]])
  }
}

class MS2KTimbreSeqController : NewPatchEditorController {
  
  private let seqSwitch = PBSwitch(label: "Sequence")
  
  override var prefix: SynthPath? { return [.seq, .i(index)] }
  
  override func loadView(_ view: PBView) {
    createPanels(forKeys: ["switch","seq"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("switch",2),("seq",16)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("switch",1)], pinned: true, pinMargin: "", spacing: "-s1-")
    
    seqSwitch.options = OptionsParam.makeOptions(["1","2","3"])
    seqSwitch.addValueChangeTarget(self, action: #selector(selectIndex(_:)))
    
    quickGrid(panel: "switch", items: [
      [(seqSwitch, nil, "seqSwitch")],
      [(PBSelect(label: "Knob"), [.knob], nil)],
      [(PBSwitch(label: "Motion"), [.motion, .type], nil)]
      ])
    
    let seqItems: [(PBLabeledControl,SynthPath)] = (0..<16).map {
      return (MS2KSeqSlider(label: ""), [.step, .i($0)])
    }
    var rowItems = [String]()
    seqItems.forEach { (ctrl, path) in
      addBlocks(control: ctrl, path: path)
      panels["seq"]!.addSubview(ctrl)
      layout.addView(ctrl, forPath: path)
      rowItems.append(path.layoutKey)
    }
    layout.addGridConstraints(forKeys: [rowItems], pinMargin: "-s1-", spacing: "-s1-")
    
    addColorToAll()
    addColorBlock { [weak self] in
      let bg1 = Self.tertiaryBackgroundColor(forColorGuide: $0).tinted(amount: 0.04)
      let bg2 = Self.tertiaryBackgroundColor(forColorGuide: $0).tinted(amount: 0.07)
      let altValueColor = Self.tintColor(forColorGuide: $0).shaded(amount: 0.5)
      var i = 0
      self?.panels["seq"]?.subviews.forEach {
        guard let s = $0 as? MS2KSeqSlider else { return }
        s.altValueColor = altValueColor
        s.backgroundColor = (i / 4) % 2 == 0 ? bg1 : bg2
        i += 1
      }
    }
  }
      
  // copy/paste/clear/randomize
}

