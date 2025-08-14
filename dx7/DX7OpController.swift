
//class DX7OpController : DX7ProtoOpController {
//    
//  private let onSwitch = PBCheckbox(label: "On")
//  let ampModKnob = PBKnob(label: "Amp Mod")
//
//  override var index: Int {
//    didSet {
//      onSwitch.label = "\(index + 1)"
//      envControl.label = "\(index + 1)"
//    }
//  }
//
//  override func loadView(_ view: PBView) {
//    let levelScalingControl = DXLevelScalingControl(label: "")
//    let oscModeSwitch = PBSwitch(label: "Fixed")
//
//    quickGrid(view: view, items: [[
//      (onSwitch, [.on], nil),
//      (oscModeSwitch, [.osc, .mode], nil),
//      (PBKnob(label: "Coarse"), [.coarse], nil),
//      (PBKnob(label: "Fine"), [.fine], nil),
//      (PBKnob(label: "Detune"), [.detune], nil),
//      ],[
//      (envControl, nil, "env"),
//      (levelScalingControl, [.level, .scale], nil),
//      (PBKnob(label: "Level"), [.level], nil),
//      (PBKnob(label: "Velo"), [.velo], nil),
//      ],[
//      (PBKnob(label: "L1"), [.level, .i(0)], nil),
//      (PBKnob(label: "L2"), [.level, .i(1)], nil),
//      (PBKnob(label: "L3"), [.level, .i(2)], nil),
//      (PBKnob(label: "L4"), [.level, .i(3)], nil),
//      (ampModKnob, nil, "ampMod"),
//      ],[
//      (PBKnob(label: "R1"), [.rate, .i(0)], nil),
//      (PBKnob(label: "R2"), [.rate, .i(1)], nil),
//      (PBKnob(label: "R3"), [.rate, .i(2)], nil),
//      (PBKnob(label: "R4"), [.rate, .i(3)], nil),
//      (PBKnob(label: "Rate Scale"), [.rate, .scale], nil),
//      ],[
//      (PBSwitch(label: "L Curve"), [.level, .scale, .left, .curve], nil),
//      (PBKnob(label: "L Depth"), [.level, .scale, .left, .depth], nil),
//      (PBKnob(label: "R Depth"), [.level, .scale, .right, .depth], nil),
//      (PBSwitch(label: "R Curve"), [.level, .scale, .right, .curve], nil),
//      (PBKnob(label: "Break"), [.level, .scale, .brk, .pt], nil),
//      ]])
//    
//    addEnvCtrlBlocks()
//    addPatchChangeBlock(paths: [[.osc, .mode], [.coarse], [.fine]]) { (values) in
//      guard let coarse = values[[.coarse]],
//        let fine = values[[.fine]] else { return }
//      let fixedMode = values[[.osc, .mode]] == 1
//      oscModeSwitch.label = fixedMode ? "Freq (Hz)" : "Ratio"
//      oscModeSwitch.options = OptionsParam.makeOptions([
//        DX7Patch.freqRatio(fixedMode: false, coarse: coarse, fine: fine),
//        DX7Patch.freqRatio(fixedMode: true, coarse: coarse, fine: fine)])
//    }
//    dims(view: view, forPath: [.on])
//    addPatchChangeBlock(path: [.level, .scale, .left, .depth]) { levelScalingControl.leftDepth = $0 }
//    addPatchChangeBlock(path: [.level, .scale, .right, .depth]) { levelScalingControl.rightDepth = $0 }
//    addPatchChangeBlock(path: [.level, .scale, .left, .curve]) { levelScalingControl.leftCurve = $0 }
//    addPatchChangeBlock(path: [.level, .scale, .right, .curve]) { levelScalingControl.rightCurve = $0 }
//    addPatchChangeBlock(path: [.level, .scale, .brk, .pt]) { levelScalingControl.breakpoint = $0 }
//    initAmpMod()
//    
//    registerForEditMenu(envControl, bundle: (
//      paths: { [[.rate, .i(0)], [.rate, .i(1)], [.rate, .i(2)], [.rate, .i(3)],
//              [.level, .i(0)], [.level, .i(1)], [.level, .i(2)], [.level, .i(3)]] },
//      pasteboardType: "com.cfshpd.DX7Envelope",
//      initialize: nil,
//      randomize: nil
//    ))
//
//    registerForEditMenu(levelScalingControl, bundle: (
//      paths: { [[.level, .scale, .brk, .pt],
//              [.level, .scale, .left, .depth], [.level, .scale, .right, .depth],
//              [.level, .scale, .left, .curve], [.level, .scale, .right, .curve]] },
//      pasteboardType: "com.cfshpd.DX7LevelScaling",
//      initialize: nil,
//      randomize: nil
//    ))
//  }
//  
//  func initAmpMod() {
//    // in DX7ii, this is stored in the "extra"
//    addBlocks(control: ampModKnob, path: [.amp, .mod])
//  }
//}
