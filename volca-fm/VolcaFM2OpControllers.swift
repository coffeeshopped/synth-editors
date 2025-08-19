
//struct DX7OpControllers {
//  
//  static func env(withGain: Bool = false) -> PatchController.PanelItem {
//    let env: PatchController.Display = .rateLevelEnv(pointCount: 4, sustain: 2)
//    
//    var maps: [PatchController.DisplayMap] = 4.map { .src([.rate, .i($0)], { $0 / 99 }) } + 4.map { .src([.level, .i($0)], { $0 / 99 })}
//    if withGain {
//      maps.append(.src([.level], dest: [.gain], { $0 / 99 }))
//    }
//
//    return .display(env, nil, maps, id: [.env])
//  }
//  
//  static func op(ampModPath: SynthPath) -> PatchController {
//    
//    let levelMaps: [PatchController.DisplayMap] = [
//      .ident([.left, .curve]),
//      .ident([.right, .curve]),
//      .src([.left, .depth], { $0 / 99 }),
//      .src([.right, .depth], { $0 / 99 }),
//      .src([.brk, .pt], { $0 / 99 })
//    ]
//    let levelScale: PatchController.PanelItem = .display(.levelScaling(), nil, levelMaps.map { $0.srcPrefix([.level, .scale]) }, id: [.level, .scale], width: 4)
//    
//    return .patch(prefix: .index([.op]), color: 1, [
//      .grid([[
//        .checkbox("On", [.on]),
//        .switsch("Fixed", [.osc, .mode]),
//        .knob("Coarse", [.coarse]),
//        .knob("Fine", [.fine]),
//        .knob("Detune", [.detune]),
//      ],[
//        env(),
//        levelScale,
//        .knob("Level", [.level]),
//        .knob("Velo", [.velo]),
//      ],[
//        .knob("L1", [.level, .i(0)]),
//        .knob("L2", [.level, .i(1)]),
//        .knob("L3", [.level, .i(2)]),
//        .knob("L4", [.level, .i(3)]),
//        .knob("Amp Mod", ampModPath),
//      ],[
//        .knob("R1", [.rate, .i(0)]),
//        .knob("R2", [.rate, .i(1)]),
//        .knob("R3", [.rate, .i(2)]),
//        .knob("R4", [.rate, .i(3)]),
//        .knob("Rate Scale", [.rate, .scale]),
//      ],[
//        .switsch("L Curve", [.level, .scale, .left, .curve]),
//        .knob("L Depth", [.level, .scale, .left, .depth]),
//        .knob("R Depth", [.level, .scale, .right, .depth]),
//        .switsch("R Curve", [.level, .scale, .right, .curve]),
//        .knob("Break", [.level, .scale, .brk, .pt]),
//      ]]),
//    ], effects: [
//      .indexChange({ index in
//        [
//          .setCtrlLabel([.on], "\(index + 1)"),
//          .setCtrlLabel([.env], "\(index + 1)"),
//        ]
//      }),
//      .dimsOn([.on], id: nil),
//      .patchChange(paths: [[.osc, .mode], [.coarse], [.fine]], { values in
//        guard let coarse = values[[.coarse]],
//          let fine = values[[.fine]] else { return [] }
//        let fixedMode = values[[.osc, .mode]] == 1
//        let opts = [
//          DX7Patch.freqRatio(fixedMode: false, coarse: coarse, fine: fine),
//          DX7Patch.freqRatio(fixedMode: true, coarse: coarse, fine: fine),
//        ]
//        return [
//          .setCtrlLabel([.osc, .mode], fixedMode ? "Freq (Hz)" : "Ratio"),
//          .configCtrl([.osc, .mode], .opts(ParamOptions(optArray: opts)))
//        ]
//      }),
//      .editMenu([.env], paths: 4.map { [.rate, .i($0)] } + 4.map { [.level, .i($0)] }, type: "DX7Envelope", init: nil, rand: nil),
//    ])
//    
//    //
////    vc.registerForEditMenu(levelScalingControl, bundle: (
////      paths: { [[.level, .scale, .brk, .pt],
////              [.level, .scale, .left, .depth], [.level, .scale, .right, .depth],
////              [.level, .scale, .left, .curve], [.level, .scale, .right, .curve]] },
////      pasteboardType: "com.cfshpd.DX7LevelScaling",
////      initialize: nil,
////      randomize: nil
////    ))
//  }
//
//  
//  
//  static var miniOp: PatchController {
//    let paths: [SynthPath] = DX7Patch.paramKeys().compactMap {
//      guard $0.starts(with: [.op, .i(0)]) else { return nil }
//      return $0.subpath(from: 2)
//    }
//
//    return .patch(prefix: .index([.op]), [
//      .items(color: 1, [
//        (env(withGain: true), "env"),
//        (.label("?", align: .leading, size: 11, id: [.op]), "op"),
//        (.label("x", align: .trailing, size: 11, bold: false, id: [.osc, .mode]), "freq"),
//      ]),
//    ], effects: [
//      .patchChange(paths: [[.osc, .mode], [.coarse], [.fine], [.detune]], { values in
//        guard let coarse = values[[.coarse]],
//          let fine = values[[.fine]],
//          let detune = values[[.detune]] else { return [] }
//        let fixedMode = values[[.osc, .mode]] == 1
//        let valText = DX7Patch.freqRatio(fixedMode: fixedMode, coarse: coarse, fine: fine)
//        let detuneOff = detune - 7
//        let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")
//        return [
//          .setCtrlLabel([.osc, .mode], (fixedMode ? "\(valText) Hz" : "x \(valText)") + detuneString)
//        ]
//      }),
//      .indexChange({ [.setCtrlLabel([.op], "\($0 + 1)")] }),
//      .dimsOn([.on], id: nil),
//      .editMenu([.env], paths: paths, type: "DX7Op", init: nil, rand: nil)
//    ], layout: [
//      .row([("op",1),("freq",4)]),//, spacing: 2),
//      .row([("env", 1)]),//, spacing: 2),
//      .colFixed(["op", "env"], fixed: "op", height: 11, spacing: 2),
//    ])
//
//  }
//}
