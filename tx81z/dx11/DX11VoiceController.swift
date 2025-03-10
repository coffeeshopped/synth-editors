
extension DX11.Voice {
  
  enum Controller {
    
    static var controller: PatchController {
      return .patch([
        .child(Op4.algoCtrlr(TX81Z.Voice.Controller.MiniOp.controller), "algo", color: 2, clearBG: true),
        .child(TX81Z.Voice.Controller.Op.controller(index: 0), "op0", color: 1),
        .child(TX81Z.Voice.Controller.Op.controller(index: 1), "op1", color: 1),
        .child(TX81Z.Voice.Controller.Op.controller(index: 2), "op2", color: 1),
        .child(TX81Z.Voice.Controller.Op.controller(index: 3), "op3", color: 1),
        .child(DX21.Voice.Controller.pitch(prefix: [.voice, .pitch, .env]), "pitch", color: 2),
        .panel("algoKnob", color: 2, [[
          .knob("Algorithm", [.voice, .algo]),
          .knob("Feedback", [.voice, .feedback]),
          .checkbox("Mono", [.voice, .poly]),
          .knob("Transpose", [.voice, .transpose]),
          .knob("P Bend", [.voice, .bend]),
          .knob("Reverb", [.extra, .reverb]),
        ]]),
        .panel("porta", color: 2, [[
          .knob("Porta Time", [.voice, .porta, .time]),
          .checkbox("Fingered", [.voice, .porta, .mode]),
        ]]),
        .panel("lfo", color: 2, [[
          .switsch("LFO Wave", [.voice, .lfo, .wave]),
          .knob("Speed", [.voice, .lfo, .speed]),
        ],[
          .checkbox("Key Sync", [.voice, .lfo, .sync]),
          .knob("Pitch Depth", [.voice, .pitch, .mod, .depth]),
          .knob("Pitch Sens", [.voice, .pitch, .mod, .sens]),
        ],[
          .knob("Delay", [.voice, .lfo, .delay]),
          .knob("Amp Depth", [.voice, .amp, .mod, .depth]),
          .knob("Amp Sens", [.voice, .amp, .mod, .sens]),
        ]]),
        .panel("mod", color: 2, [[
          .knob("Mod→Amp", [.voice, .modWheel, .amp]),
          .knob("Pitch", [.voice, .modWheel, .pitch]),
        ]]),
        .panel("foot", color: 2, [[
          .knob("Foot→Amp", [.extra, .foot, .amp]),
          .knob("Pitch", [.extra, .foot, .pitch]),
          .knob("Volume", [.voice, .foot, .volume]),
          .spacer(2),
        ]]),
        .panel("breath", color: 2, [[
          .knob("Breath→Amp", [.voice, .breath, .amp]),
          .knob("Pitch", [.voice, .breath, .pitch]),
          .knob("P Bias", [.voice, .breath, .pitch, .bias]),
          .knob("EG Bias", [.voice, .breath, .env, .bias]),
        ]]),
        .panel("after", color: 2, [[
          .knob("AfterT→Amp", [.aftertouch, .aftertouch, .amp]),
          .knob("Pitch", [.aftertouch, .aftertouch, .pitch]),
          .knob("P Bias", [.aftertouch, .aftertouch, .pitch, .bias]),
          .knob("EG Bias", [.aftertouch, .aftertouch, .env, .bias]),
        ]]),
      ], layout: [
        .row([("algo",6), ("algoKnob",6), ("mod",2), ("porta",2)], opts: [.alignAllTop]),
        .row([("op0",1),("op1",1),("op2",1),("op3",1)]),
        .col([("algo",4), ("op0",5)]),
        .rowPart([("lfo", 3), ("pitch", 3), ("foot", 4)], opts: [.alignAllTop]),
        .colPart([("foot", 1), ("breath", 1), ("after", 1)], opts: [.alignAllLeading, .alignAllTrailing]),
        .colPart([("algoKnob", 1), ("lfo", 3)]),
        .eq(["porta", "foot"], .trailing),
        .eq(["algoKnob", "mod", "porta"], .bottom),
        .eq(["algo", "lfo", "pitch", "after"], .bottom),
      ])      
    }
    
  }
  
}

