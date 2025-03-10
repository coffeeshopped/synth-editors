
extension DX21.Voice {
  
  enum Controller {
    
    static var controller: PatchController {
      return .patch([
        .child(Op4.algoCtrlr(DX100.Voice.Controller.MiniOp.controller), "algo", color: 2, clearBG: true),
        .child(DX100.Voice.Controller.Op.controller(index: 0), "op0", color: 1),
        .child(DX100.Voice.Controller.Op.controller(index: 1), "op1", color: 1),
        .child(DX100.Voice.Controller.Op.controller(index: 2), "op2", color: 1),
        .child(DX100.Voice.Controller.Op.controller(index: 3), "op3", color: 1),
        .child(pitch(prefix: [.voice, .pitch, .env]), "pitch", color: 2),
        .panel("algoKnob", prefix: [.voice], color: 2, [[
          .knob("Algorithm", [.algo]),
        ],[
          .knob([.feedback]),
        ],[
          .checkbox("Mono", [.poly]),
        ],[
          .checkbox("Chorus", [.chorus]),
        ]]),
        .panel("transpose", prefix: [.voice], color: 2, [[
          .knob("Transpose", [.transpose]),
        ],[
          .knob("P Bend", [.bend]),
        ],[
          .knob([.porta, .time]),
        ],[
          .checkbox("Fingered", [.porta, .mode]),
        ]]),
        .panel("lfo", prefix: [.voice], color: 2, [[
          .switsch("LFO Wave", [.lfo, .wave]),
          .knob("Speed", [.lfo, .speed]),
        ],[
          .checkbox("Key Sync", [.lfo, .sync]),
          .knob("Pitch Depth", [.pitch, .mod, .depth]),
          .knob("Pitch Sens", [.pitch, .mod, .sens]),
        ],[
          .knob("Delay", [.lfo, .delay]),
          .knob("Amp Depth", [.amp, .mod, .depth]),
          .knob("Amp Sens", [.amp, .mod, .sens]),
        ]]),
        .panel("mods", prefix: [.voice], color: 2, [[
          .knob("Mod→Pitch", [.modWheel, .pitch]),
          .knob("Mod→Amp", [.modWheel, .amp]),
        ],[
          .knob("Foot→Volume", [.foot, .volume]),
        ],[
          .knob("Breath→Pitch", [.breath, .pitch]),
          .knob("Breath→Amp", [.breath, .amp]),
        ],[
          .knob("Breath→P Bias", [.breath, .pitch, .bias]),
          .knob("Breath→EG Bias", [.breath, .env, .bias]),
        ]]),
        ], layout: [
          .row([("algo",5),("algoKnob",1),("transpose",1),("lfo",3),("mods",2), ("pitch", 3)]),
          .row([("op0",1),("op1",1),("op2",1),("op3",1)]),
          .col([("algo",4),("op0",4)]),
        ])
    }
    
    static func pitch(prefix: SynthPath) -> PatchController {
      return .patch(prefix: .fixed(prefix), [
        .grid([[
          .display(.rateLevelEnv(pointCount: 3, sustain: 999, bipolar: true), "Pitch", 3.flatMap {
            [
              .src([.rate, .i($0)], { $0 / 99 }),
              .src([.level, .i($0)], { ($0 - 50) / 50 }),
            ]
          }, id: [.env]),
          ],[
          .knob("R1", [.rate, .i(0)]),
          .knob("R2", [.rate, .i(1)]),
          .knob("R3", [.rate, .i(2)]),
          ],[
          .knob("L1", [.level, .i(0)]),
          .knob("L2", [.level, .i(1)]),
          .knob("L3", [.level, .i(2)]),
        ]])
      ])
    }
  }
  
}
