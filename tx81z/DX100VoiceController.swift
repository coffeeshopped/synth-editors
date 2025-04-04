
extension DX100.Voice {
  
  public enum Controller {
    
    static var controller: PatchController {

      return .patch([
        .child(Op4.algoCtrlr(MiniOp.controller), "algo", color: 2, clearBG: true),
        .child(Op.controller(index: 0), "op0", color: 1),
        .child(Op.controller(index: 1), "op1", color: 1),
        .child(Op.controller(index: 2), "op2", color: 1),
        .child(Op.controller(index: 3), "op3", color: 1),
        .panel("algoKnob", prefix: [.voice], color: 2, [[
          .knob("Algorithm", [.algo]),
        ],[
          .knob("Feedback", [.feedback]),
          .checkbox("Mono", [.poly]),
        ]]),
        .panel("transpose", prefix: [.voice], color: 2, [[
          .knob([.transpose]),
          .knob("P Bend", [.bend]),
        ],[
          .knob([.porta, .time]),
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
          .knob("Amp", [.modWheel, .amp]),
        ],[
          .knob("Foot→Volume", [.foot, .volume]),
        ],[
          .knob("Breath→Pitch", [.breath, .pitch]),
          .knob("Amp", [.breath, .amp]),
          .knob("P Bias", [.breath, .pitch, .bias]),
          .knob("EG Bias", [.breath, .env, .bias]),
        ]])
      ], layout: [
        .row([("algo",5),("algoKnob",2),("transpose",2),("lfo",3),("mods",4)]),
        .row([("op0",1),("op1",1),("op2",1),("op3",1)]),
        .col([("algo",3),("op0",4)]),
      ])
    }
        
    enum MiniOp {
      
      static func controller(index: Int) -> PatchController {
        let coarsePath: SynthPath = Op4.opPath(index, [.coarse])
        let detunePath: SynthPath = Op4.opPath(index, [.detune])

        return Op4.MiniOp.controller(index: index, ratioEffect: .patchChange(paths: [coarsePath, detunePath], { values in
          guard let coarse = values[coarsePath],
            let detune = values[detunePath] else { return [] }
          let detuneOff = detune - 3
          let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")

          return [
            .setCtrlLabel([.osc, .mode],  "\(Op4.coarseRatio(coarse))\(detuneString)"),
          ]
        }), opType: "DX100Op", allPaths: AllPaths)
      }
      
      static let AllPaths: [SynthPath] = [[.attack], [.decay, .i(0)], [.decay, .i(1)], [.release], [.decay, .level], [.level, .scale], [.rate, .scale], [.env, .bias, .sens], [.amp, .mod], [.velo], [.level], [.coarse], [.detune]]

    }
    
    enum Op {
      
      static func controller(index: Int) -> PatchController {
        let coarseLookup = Op4.coarseRatioLookup.map { "\($0)" }
        let coarsePath = Op4.opPath(index, [.coarse])
        return .patch([
          .grid(Op4.opItems(index, [[
            .checkbox("On", [.on]),
            .knob("Coarse", nil, id: coarsePath),
            .knob("Detune", [.detune]),
            .checkbox("Amp Mod", [.amp, .mod]),
          ],[
            Op4.envItem(index: index),
            .knob("Level", [.level]),
            .knob("Velocity", [.velo]),
          ],[
            .knob("Attack", [.attack]),
            .knob("Decay 1", [.decay, .i(0)]),
            .knob("Sustain", [.decay, .level]),
            .knob("Release", [.release]),
          ],[
            .knob("L Scale", [.level, .scale]),
            .knob("EBS", [.env, .bias, .sens]),
            .knob("Decay 2", [.decay, .i(1)]),
            .knob("R Scale", [.rate, .scale]),
          ]]))
        ], effects: .ctrlBlocks(Op4.opPath(index, [.coarse]), param: .opts(ParamOptions(optArray: coarseLookup))) + [
          .dimsOn(Op4.opPath(index, [.on]), id: nil),
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
