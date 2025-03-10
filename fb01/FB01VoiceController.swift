
extension FB01.Voice {
  
  enum Controller {
    
    static let algo: PatchController = .fm(algorithms(), MiniOp.controller, algoPath: [.algo])

    static var controller: PatchController {
      return .patch([
        .child(algo, "algo", color: 2, clearBG: true),
        .children(4, "op", color: 1, Op.controller, indexFn: { p, offset in 3 - offset }),
        .panel("algoKnob", color: 2, [[
          .knob("Algorithm", [.algo]),
        ],[
          .knob("Feedback", [.feedback]),
          .checkbox("Mono", [.poly]),
        ]]),
        .panel("transpose", color: 2, [
          [.knob("Transpose", [.transpose])],
          [.knob("P Bend", [.bend])],
          [.knob("Porta Time", [.porta])],
        ]),
        .panel("lfo", color: 2, [[
          .checkbox("LFO Load", [.lfo, .load]),
          .select("LFO Wave", [.lfo, .wave]),
          .knob("Speed", [.lfo, .speed]),
        ],[
          .checkbox("Key Sync", [.lfo, .sync]),
          .knob("Pitch Depth", [.pitch, .mod, .depth]),
          .knob("Pitch Sens", [.pitch, .mod, .sens]),
        ],[
          .select("PMD Ctrl", [.pitch, .mod, .depth, .ctrl]),
          .knob("Amp Depth", [.amp, .mod, .depth]),
          .knob("Amp Sens", [.amp, .mod, .sens]),
        ]]),
      ], effects: [
      ], layout: [
        .row([("algo",5),("algoKnob",2),("transpose",1),("lfo",4)]),
        .row([("op0",1), ("op1",1), ("op2",1), ("op3",1)]),
        .col([("algo",3),("op0",5)]),
      ])
    }
    
    static func envItem() -> PatchController.PanelItem {
      return .display(.env(Op4.envPathFn), "", [
        .src([.attack], { $0 / 31 }),
        .src([.decay, .i(0)], { $0 / 31 }),
        .src([.decay, .i(1)], { $0 / 31 }),
        .src([.decay, .level], { (15 - $0) / 15 }),
        .src([.release], { $0 / 15 }),
        .src([.level], { (127 - $0) / 127 }),
      ], id: [.env])
    }

    enum MiniOp {
      
      static var controller: PatchController {

        let paths: [SynthPath] = parms.paths.compactMap {
          guard $0.starts(with: [.op, .i(0)]) else { return nil }
          return $0.subpath(from: 2)
        }

        return .patch(prefix: .index([.op]), [
          .items(color: 1, [
            (envItem(), "env"),
            (.label("?", align: .leading, size: 11, id: [.op]), "op"),
            (.label("x", align: .trailing, size: 11, bold: false, id: [.osc, .mode]), "freq"),
          ])
        ], effects: [
          .patchChange(paths: [[.coarse], [.fine]], { values in
            guard let coarse = values[[.coarse]],
                  let fine = values[[.fine]] else { return [] }
            return [
              .setCtrlLabel([.osc, .mode], String(format: "%2.2f", freqRatio(coarse: coarse, fine: fine))),
            ]
          }),
          .dimsOn([.on], id: nil),
          .editMenu([.env], paths: paths, type: "FB01Op", init: nil, rand: nil),
          .indexChange({ [.setCtrlLabel([.op], "\(4 - $0)")] }),
        ], layout: [
          .row([("op",1),("freq",4)]),
          .row([("env",1)]),
          .colFixed(["op", "env"], fixed: "op", height: 11, spacing: 2),
        ])
      }
      
    }
    
    enum Op {
      
      static var controller: PatchController {
        return .patch(prefix: .index([.op]), [
          .grid(color: 1, [[
            .switsch("Ratio", nil, id: [.ratio]),
            .knob("Coarse", [.coarse]),
            .knob("Fine", [.fine]),
            .knob("Detune", [.detune]),
          ],[
            .knob("Level", nil, id: [.level]),
            .knob("Velocity", [.velo]),
            .checkbox("Amp Mod", [.amp, .mod]),
            .knob("L Adjust", [.level, .adjust]),
          ],[
            .knob("Velo(A)", [.attack, .velo]),
            envItem(),
            .checkbox("On", [.on]),
          ],[
            .knob("Attack", [.attack]),
            .knob("Decay 1", [.decay, .i(0)]),
            .knob("Sustain", nil, id: [.decay, .level]),
            .knob("Release", [.release]),
          ],[
            .knob("L Scale", [.level, .scale]),
            .switsch("LS Type", [.level, .scale, .type]),
            .knob("Decay 2", [.decay, .i(1)]),
            .knob("R Scale", [.rate, .scale]),
          ]])
        ], effects: [
          .dimsOn([.on], id: nil),
          .indexChange({ [.setCtrlLabel([.env], "\(4 - $0)")] }),
          .patchChange(paths: [[.coarse],[.fine]], { values in
            guard let coarse = values[[.coarse]],
              let fine = values[[.fine]] else { return [] }
            return [
              .configCtrl([.ratio], .opts(ParamOptions(optArray: [
                String(format: "%2.2f", freqRatio(coarse: coarse, fine: fine)),
              ]))),
            ]
          }),
          .editMenu([.env], paths: [
            [.attack],
            [.decay, .i(0)],
            [.decay, .i(1)],
            [.decay, .level],
            [.release],
          ], type: "FB01Envelope", init: nil, rand: nil),
        ]
                      + .ctrlBlocks([.level], value: { 127 - $0 }, cc: { 127 - $0 })
                      + .ctrlBlocks([.decay, .level], value: { 15 - $0 }, cc: { 15 - $0 }))
      }
    }
    
  }
}

