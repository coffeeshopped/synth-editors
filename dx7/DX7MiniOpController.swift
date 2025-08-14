
//class DX7MiniOpController : DX7ProtoOpController {
//  
//  private let opLabel = PBLabel()
//
//  override var index: Int {
//    didSet { opLabel.text = "\(index + 1)" }
//  }
//  
//  override func loadView(_ view: PBView) {
//    view.addSubview(envControl)
//    layout.addView(envControl, forLayoutKey: "env")
//    
//    opLabel.textAlignment = .left
//    opLabel.font = PBFont.boldSystemFont(ofSize: 11)
//    view.addSubview(opLabel)
//    layout.addView(opLabel, forLayoutKey: "op")
//
//    let freqRatioLabel = PBLabel()
//    freqRatioLabel.textAlignment = .right
//    freqRatioLabel.font = PBFont.systemFont(ofSize: 11)
//    freqRatioLabel.adjustsFontSizeToFitWidth = true
//    freqRatioLabel.minimumScaleFactor = 0.5
//    view.addSubview(freqRatioLabel)
//    layout.addView(freqRatioLabel, forLayoutKey: "freq")
//
//    let spacing = "-2-"
//    layout.addRowConstraints([("op",1),("freq",4)], pinned: true, pinMargin: spacing, spacing: spacing)
//    layout.addRowConstraints([("env",1)], pinned: true, pinMargin: spacing, spacing: spacing)
//    layout.addConstraints(withVisualFormat: "V:|-s1-[op]-2-[env]-s1-|", options: [])
//    layout.addConstraint(itemKey: "op", attribute: .height, relatedBy: .equal, toItemKey: nil, attribute: .notAnAttribute, multiplier: 1, constant: 11, priority: .defaultHigh)
//
//    addPatchChangeBlock(paths: [[.osc, .mode], [.coarse], [.fine], [.detune]]) { (values) in
//      guard let coarse = values[[.coarse]],
//        let fine = values[[.fine]],
//        let detune = values[[.detune]] else { return }
//      let fixedMode = values[[.osc, .mode]] == 1
//      let valText = DX7Patch.freqRatio(fixedMode: fixedMode, coarse: coarse, fine: fine)
//      let detuneOff = detune - 7
//      let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")
//      freqRatioLabel.text = (fixedMode ? "\(valText) Hz" : "x \(valText)") + detuneString
//    }
//    dims(view: view, forPath: [.on])
//    let envControl = self.envControl
//    addPatchChangeBlock(path: [.level]) { envControl.gain = CGFloat($0) / 99 }
//    addEnvCtrlBlocks()
//    
//    let paths: [SynthPath] = DX7Patch.paramKeys().compactMap {
//      guard $0.starts(with: [.op, .i(0)]) else { return nil }
//      return $0.subpath(from: 2)
//    }
//    registerForEditMenu(envControl, bundle: (
//      paths: { paths },
//      pasteboardType: "com.cfshpd.DX7Op",
//      initialize: nil,
//      randomize: nil
//    ))
//    
//    addColor(view: view)
//  }
//  
//}
