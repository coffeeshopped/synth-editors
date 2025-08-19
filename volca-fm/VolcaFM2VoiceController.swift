
//extension VolcaFM2 {
//
//  struct VoiceController {
//    
//    static var ctrlr: PatchController {
//      let algo: PatchController = .fm(VolcaFM2.Voice.algorithms(), DX7OpControllers.miniOp)
//
//      let pitchDisplayMaps: [PatchController.DisplayMap] = 4.map { .src([.rate, .i($0)], { $0 / 99 }).srcPrefix([.pitch, .env]) } + 4.map { .src([.level, .i($0)], { ($0 - 50) / 50 }).srcPrefix([.pitch, .env]) }
//      let pitchEnv: PatchController.PanelItem = .display(.rateLevelEnv(pointCount: 4, sustain: 2, bipolar: true), "Pitch", pitchDisplayMaps, id: [.pitch, .env])
//
//      return .patch([
//        .child(algo, "algo", color: 1, clearBG: true),
//        .children(3, "op", DX7OpControllers.op(ampModPath: [.amp, .mod]), indexFn: { 3 * $0 + $1 }),
//        .panel("algoKnob", color: 2, [[
//          .knob("Algorithm", [.algo]),
//        ],[
//          .knob("Feedback", [.feedback]),
//          .knob("Osc Sync", [.osc, .sync]),
//        ]]),
//        .switcher(label: "Ops", ["1–3","4–6"], color: 1),
//        .panel("pitch", color: 2, [[
//          .knob("Octave", [.octave]),
//          pitchEnv,
//          .knob("Transpose", [.transpose]),
//        ],[
//          .knob("R1", [.pitch, .env, .rate, .i(0)]),
//          .knob("R2", [.pitch, .env, .rate, .i(1)]),
//          .knob("R3", [.pitch, .env, .rate, .i(2)]),
//          .knob("R4", [.pitch, .env, .rate, .i(3)]),
//        ],[
//          .knob("L1", [.pitch, .env, .level, .i(0)]),
//          .knob("L2", [.pitch, .env, .level, .i(1)]),
//          .knob("L3", [.pitch, .env, .level, .i(2)]),
//          .knob("L4", [.pitch, .env, .level, .i(3)]),
//        ]]),
//        .panel("lfo", prefix: [.lfo], color: 2, [[
//          .select("LFO Wave", [.wave]),
//          .knob("Speed", [.speed]),
//        ],[
//          .knob("Delay", [.delay]),
//          .checkbox("Key Sync", [.sync]),
//        ],[
//          .knob("AMD", [.amp, .mod, .depth]),
//          .knob("PMD", [.pitch, .mod, .depth]),
//          .knob("Pitch Mod", [.pitch, .mod]),
//        ]]),
//        .panel("ad", color: 2, [
//          [.knob("Mod A", [.mod, .attack])],
//          [.knob("Mod D", [.mod, .decay])],
//          [.knob("Car A", [.carrier, .attack])],
//          [.knob("Car D", [.carrier, .decay])],
//          [.spacer(2)],
//        ])
//      ], layout: [
//        .row([("algo",7),("algoKnob",2),("pitch",4),("lfo",3)], opts: [.alignAllTop]),
//        .row([("op0",5), ("op1",5), ("op2",5), ("ad", 1)]),
//        .col([("algo",3),("op0",5)]),
//        .colPart([("algoKnob",2),("switch",1)], opts: [.alignAllLeading, .alignAllTrailing]),
//        .eq(["algo","switch","pitch","lfo"], .bottom),
//      ])
//      
////        let paths: [SynthPath] = 4.map { [.pitch, .env, .rate, .i($0)] } + 4.map { [.pitch, .env, .level, .i($0)] }
////        vc.registerForEditMenu(pitchEnv, bundle: (
////          paths: { paths },
////          pasteboardType: "com.cfshpd.DX7PitchEnv",
////          initialize: nil,
////          randomize: nil
////        ))
//    }
//    
//  }
//
//}
