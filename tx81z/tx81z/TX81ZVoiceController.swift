
extension TX81Z.Voice {
  
  public enum Controller {
    
    static var controller: PatchController {

      return .patch([
        .child(Op4.algoCtrlr(MiniOp.controller), "algo", color: 2, clearBG: true),
        .child(Op.controller(index: 0), "op0", color: 1),
        .child(Op.controller(index: 1), "op1", color: 1),
        .child(Op.controller(index: 2), "op2", color: 1),
        .child(Op.controller(index: 3), "op3", color: 1),
        .panel("algoKnob", prefix: [.voice], color: 1, [[
          .knob("Algorithm", [.algo]),
        ],[
          .knob("Feedback", [.feedback]),
          .checkbox("Mono", [.poly])
        ]]),
        .panel("transpose", color: 2, [[
          .knob("Transpose", [.voice, .transpose]),
          .knob("P Bend", [.voice, .bend]),
        ],[
          .knob("Reverb", [.extra, .reverb]),
        ],[
          .knob("Porta Time", [.voice, .porta, .time]),
          .checkbox("Fingered", [.voice, .porta, .mode]),
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
        .panel("mods", color: 2, [[
          .knob("Mod→Amp", [.voice, .modWheel, .amp]),
          .knob("Pitch", [.voice, .modWheel, .pitch]),
          .spacer(2),
          .spacer(2),
        ],[
          .knob("Foot→Amp", [.extra, .foot, .amp]),
          .knob("Pitch", [.extra, .foot, .pitch]),
          .knob("Volume", [.voice, .foot, .volume]),
          .spacer(2),
        ],[
          .knob("Breath→Amp", [.voice, .breath, .amp]),
          .knob("Pitch", [.voice, .breath, .pitch]),
          .knob("P Bias", [.voice, .breath, .pitch, .bias]),
          .knob("EG Bias", [.voice, .breath, .env, .bias]),
        ]])
      ], effects: [
      ], layout: [
        .row([("algo",5),("algoKnob",2),("transpose",2),("lfo",3),("mods",4)]),
        .row([("op0",1),("op1",1),("op2",1),("op3",1)]),
        .col([("algo",3),("op0",5)]),
      ])
    }
        
    public enum MiniOp {
      
      static func controller(index: Int) -> PatchController {
        let modePath = Op4.opPath(index, [.extra, .osc, .mode])
        let rangePath = Op4.opPath(index, [.extra, .fixed, .range])
        let coarsePath = Op4.opPath(index, [.coarse])
        let finePath = Op4.opPath(index, [.extra, .fine])
        let detunePath = Op4.opPath(index, [.detune])

        return Op4.MiniOp.controller(index: index, ratioEffect: .patchChange(paths: [modePath, rangePath, coarsePath, finePath, detunePath], { values in
          guard let range = values[rangePath],
            let coarse = values[coarsePath],
            let fine = values[finePath],
            let detune = values[detunePath] else { return [] }
          let fixedMode = values[modePath] == 1
          let valText = Op4.freqRatio(fixedMode: fixedMode, range: range, coarse: coarse, fine: fine)
          let detuneOff = detune - 3
          let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")
          
          return [
            .setCtrlLabel([.osc, .mode], fixedMode ? "\(valText) Hz" : "x \(valText)\(detuneString)"),
          ]
        }), opType: "TX81ZOp", allPaths: AllPaths)
      }
            
      static let AllPaths: [SynthPath] = [[.attack], [.decay, .i(0)], [.decay, .i(1)], [.release], [.decay, .level], [.level, .scale], [.rate, .scale], [.env, .bias, .sens], [.amp, .mod], [.velo], [.level], [.coarse], [.detune], [.extra, .wave], [.extra, .osc, .mode], [.extra, .fixed, .range], [.extra, .fine], [.extra, .shift]]

    }
    
    enum Op {
      
      static func controller(index: Int) -> PatchController {
        
        let modePath: SynthPath = Op4.opPath(index, [.extra, .osc, .mode])
        let rangePath: SynthPath = Op4.opPath(index, [.extra, .fixed, .range])
        let coarsePath: SynthPath = Op4.opPath(index, [.coarse])
        let finePath: SynthPath = Op4.opPath(index, [.extra, .fine])

        return .patch([
          .grid(Op4.opItems(index, [[
            .checkbox("On", [.on]),
            .imgSelect("wave", [.extra, .wave], w: 75, h: 64),
            .switsch("Fixed", [.extra, .osc, .mode]),
          ],[
            .knob("Range", [.extra, .fixed, .range]),
            .knob("Coarse", [.coarse]),
            .knob("Fine", [.extra, .fine]),
            .knob("Detune", [.detune]),
          ],[
            Op4.envItem(index: index),
            .knob("Level", [.level]),
            .knob("Velocity", [.velo]),
          ],[
            .knob("Attack", [.attack]),
            .knob("Decay 1", [.decay, .i(0)]),
            .knob("Sustain", [.decay, .level]),
            .knob("Decay 2", [.decay, .i(1)]),
            .knob("Release", [.release]),
          ],[
            .knob("L Scale", [.level, .scale]),
            .knob("Shift (dB)", [.extra, .shift]),
            .knob("EBS", [.env, .bias, .sens]),
            .checkbox("Amp Mod", [.amp, .mod]),
            .knob("R Scale", [.rate, .scale]),
          ]]))
        ], effects: [
          .dimsOn(Op4.opPath(index, [.on]), id: nil),
          .patchChange(paths: [modePath, rangePath, coarsePath, finePath], { values in
            guard let range = values[rangePath],
              let coarse = values[coarsePath],
              let fine = values[finePath] else { return [] }
            let fixedMode = values[modePath] == 1
            return [
              .setCtrlLabel(modePath, fixedMode ? "Freq (Hz)" : "Ratio"),
              .configCtrl(modePath, .opts(ParamOptions(optArray: [
                Op4.freqRatio(fixedMode: false, range: range, coarse: coarse, fine: fine),
                Op4.freqRatio(fixedMode: true, range: range, coarse: coarse, fine: fine)]))),
              .dimItem(!fixedMode, [.extra, .fixed, .range]),
            ]
          }),
          .editMenu([.env], paths: Op4.opPaths(index, [
            [.attack],
            [.decay, .i(0)],
            [.decay, .i(1)],
            [.decay, .level],
            [.release],
          ]), type: "TX81ZEnvelope", init: nil, rand: nil)
        ])
      }
    }
  }
  
}

