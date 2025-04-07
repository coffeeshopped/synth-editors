
extension RefaceDX.Voice {
  
  enum Controller {
    
    static func ctrlr() -> PatchController {
      let algo: PatchController = .fm(algorithms(), miniOp(), algoPath: [.common, .algo])
      
      return .patch([
        .child(algo, "algo", color: 1, clearBG: true),
        .children(4, "op", op()),
        .children(2, "fx", color: 2, fx()),
        .child(pitch(), "pitch", color: 2),
        .panel("algoKnob", color: 2, [[
          .knob("Algorithm", [.common, .algo]),
          .switsch("Mono", [.common, .mono]),
          .knob("Transpose", [.common, .transpose]),
          .knob("P Bend", [.common, .bend]),
          .knob("Porta", [.common, .porta]),
        ]]),
        .panel("lfo", color: 2, [[
          .select("LFO Wave", [.common, .lfo, .wave]),
          .knob("Speed", [.common, .lfo, .speed]),
        ],[
          .knob("Delay", [.common, .lfo, .delay]),
          .knob("Pitch Depth", [.common, .lfo, .pitch, .mod]),
        ]]),
      ], effects: [
      ], layout: [
        .row([("algo",6), ("algoKnob",6), ("pitch", 4),], opts: [.alignAllTop]),
        .rowPart([("lfo", 2.5), ("fx0", 3.5)], opts: [.alignAllTop]),
        .row([("op0",1),("op1",1),("op2",1),("op3",1)]),
        .col([("algo",3),("op0",6)]),
        .colPart([("fx0", 1), ("fx1", 1)], opts: [.alignAllLeading, .alignAllTrailing]),
        .colPart([("algoKnob", 1), ("lfo", 2)]),
        .eq(["algoKnob", "fx0", "fx1"], .trailing),
        .eq(["algo", "lfo", "fx1", "pitch"], .bottom),
      ])
    }
    
    static func fx() -> PatchController {
      return .patch(prefix: .index([.common, .fx]), [
        .grid([[
          .select("FX", [.type]),
          .knob("Param 1", [.param, .i(0)]),
          .knob("Param 2", [.param, .i(1)]),
        ]])
      ], effects: [
        .indexChange({ [.setCtrlLabel([.type], "FX \($0 + 1)")] }),
        .patchChange([.type], {
          let labels: [String]
          switch $0 {
          case 1:
            labels = ["Drive", "Tone"]
          case 2:
            labels = ["Sens", "Rez"]
          case 3, 4, 5:
            labels = ["Depth", "Rate"]
          case 6, 7:
            labels = ["Depth", "Time"]
          default:
            labels = ["", ""]
          }
          return [
            .setCtrlLabel([.param, .i(0)], labels[0]),
            .setCtrlLabel([.param, .i(1)], labels[1]),
            .dimItem($0 == 0, [.param, .i(0)], dimAlpha: 0),
            .dimItem($0 == 0, [.param, .i(1)], dimAlpha: 0),
          ]
        })
      ])
    }
    
    static func pitch() -> PatchController {
      let env: PatchController.PanelItem = .display(.rateLevelEnv(pointCount: 4, sustain: 2, bipolar: true), "Pitch", 4.map { .unit([.rate, .i($0)]) } + 4.map { .src([.level, .i($0)], { ($0 - 64) / 48 })}, id: [.env])
      return .patch(prefix: .fixed([.common, .pitch, .env]), [
        .grid([[
          env,
        ],[
          .knob("R1", [.rate, .i(0)]),
          .knob("R2", [.rate, .i(1)]),
          .knob("R3", [.rate, .i(2)]),
          .knob("R4", [.rate, .i(3)]),
        ],[
          .knob("L1", [.level, .i(0)]),
          .knob("L2", [.level, .i(1)]),
          .knob("L3", [.level, .i(2)]),
          .knob("L4", [.level, .i(3)]),
        ]])
      ], effects: [
      ])
    }
    
    static func op() -> PatchController {

      return .patch(prefix: .index([.op]), color: 1, border: 1, [
        .panel("on", [[
          .checkbox("On", [.on]),
          .switsch("Freq Mode", [.freq, .mode]),
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
        ],[
          .knob("Level", [.level]),
          .knob("Velocity", [.velo]),
          .knob("Feedback", nil, id: [.feedback]),
          .knob("Detune", [.detune]),
        ]]),
        .panel("env", [[
          .knob("R1", [.rate, .i(0)]),
          .knob("R2", [.rate, .i(1)]),
          .knob("R3", [.rate, .i(2)]),
          .knob("R4", [.rate, .i(3)]),
        ],[
          .knob("L1", [.level, .i(0)]),
          .knob("L2", [.level, .i(1)]),
          .knob("L3", [.level, .i(2)]),
          .knob("L4", [.level, .i(3)]),
          ]]),
        .panel("crv", [[
          .knob("LS Left", nil, id: [.level, .scale, .left, .depth]),
          .knob("LS Right", nil, id: [.level, .scale, .right, .depth]),
          .knob("Rate Scale", [.rate, .scale]),
          .knob("LFO Amp", [.lfo, .amp, .mod]),
        ],[
          .switsch("Crv Left", nil, id: [.level, .scale, .left, .curve]),
          .switsch("Crv Right", nil, id: [.level, .scale, .right, .curve]),
          .checkbox("LFO Pitch", [.lfo, .pitch, .mod]),
          .checkbox("Pitch EG", [.pitch, .env]),
        ]]),
      ], effects: [
        .setup([
          .configCtrl([.feedback], .span(.iso(Op.feedbackIso, -127...127))),
        ]),
        .indexChange({ index in
          [
            .setCtrlLabel([.on], "\(index + 1)"),
            .setCtrlLabel([.env], "\(index + 1)"),
          ]
        }),
        .patchChange(paths: [[.coarse], [.fine]], { values in
          guard let coarse = values[[.coarse]],
                let fine = values[[.fine]] else { return [] }
          return [
            .configCtrl([.freq, .mode], .span(.opts([
              freqRatio(fixedMode: false, coarse: coarse, fine: fine),
              freqRatio(fixedMode: true, coarse: coarse, fine: fine),
            ])))
          ]
        }),
        .patchChange(paths: [[.feedback, .type], [.feedback, .level]], { values in
          guard let type = values[[.feedback, .type]],
                let level = values[[.feedback, .level]] else { return [] }
          return [.setValue([.feedback], (type * 2 - 1) * level)]
        }),
        .controlChange([.feedback], fn: { state, locals in
          let feedback = locals[[.feedback]] ?? 0
          let type = feedback < 0 ? 0 : 1
          let level = abs(feedback)
          return [.paramsChange([
            [.feedback, .type] : type,
            [.feedback, .level] : level,
          ])]
        }),
        .patchChange([.freq, .mode], {
          [.setCtrlLabel([.freq, .mode], $0 == 0 ? "Ratio" : "Fixed (Hz)")]
        }),
        .editMenu([.env], paths: 4.map { [.rate, .i($0)] } + 4.map { [.level, .i($0)] }, type: "RefaceDXEnvelope", init: nil, rand: nil),
        .dimsOn([.on], id: nil),
      ] + levelScaleEffects(side: .left) + levelScaleEffects(side: .right), layout: [
        .grid([
          (row: [("on", 1)], height: 2),
          (row: [("env", 1)], height: 2),
          (row: [("crv", 1)], height: 2),
        ])
      ])
    }
    
    static func levelScaleEffects(side: SynthPathItem) -> [PatchController.Effect] {
      let depthId: SynthPath = [.level, .scale, side, .depth]
      let curveId: SynthPath = [.level, .scale, side, .curve]
      let ccFn: PatchController.ControlChangeFn = { state, locals in
        let depthVal = locals[depthId] ?? 0
        let curveVal = locals[curveId] ?? 0
        let curve: Int
        if depthVal < 0 {
          curve = curveVal == 0 ? 0 : 1
        }
        else {
          curve = curveVal == 0 ? 3 : 2
        }
        return [.paramsChange([
          depthId : abs(depthVal),
          curveId : curve,
        ])]
      }
      
      return [
        .setup([
          .configCtrl(depthId, .span(.rng(-127...127))),
          .configCtrl(curveId, .span(.opts(["Lin", "Exp"]))),
        ]),
        .controlChange(depthId, fn: ccFn),
        .controlChange(curveId, fn: ccFn),
        .patchChange(paths: [depthId, curveId], { values in
          guard let depth = values[depthId],
                let curve = values[curveId] else { return [] }
          let mult = curve < 2 ? -1 : 1
          return [.setValue(depthId, mult * depth)]
        }),
        .patchChange(curveId, {
          [.setValue(curveId, $0 == 0 || $0 == 3 ? 0 : 1)]
        }),
      ]
      
    }

    
    static let env: PatchController.PanelItem = {
      let env: PatchController.Display = .rateLevelEnv(pointCount: 4, sustain: 2, bipolar: false)
      return .display(env, "", 4.flatMap { [
        .unit([.rate, .i($0)]),
        .unit([.level, .i($0)]),
      ] } + [.unit([.level], dest: [.gain])], id: [.env])
    }()
    
    static func miniOp() -> PatchController {
      let paths = [SynthPath](Op.parms.params().keys)

      return .patch(prefix: .index([.op]), [
        .items(color: 1, [
          (env, "env"),
          (.label("?", align: .leading, size: 11, id: [.op]), "op"),
          (.label("x", align: .trailing, size: 11, bold: false, id: [.osc, .mode]), "freq"),
        ])
      ], effects: [
        .patchChange(paths: [[.coarse], [.fine], [.detune], [.freq, .mode]], { values in
          guard let coarse = values[[.coarse]],
                let fine = values[[.fine]],
                let detune = values[[.detune]] else { return [] }
          let fixedMode = values[[.freq, .mode]] == 1
          let valText = freqRatio(fixedMode: fixedMode, coarse: coarse, fine: fine)
          let detuneOff = detune - 64
          let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")
          
          return [
            .setCtrlLabel([.osc, .mode], fixedMode ? "\(valText) Hz" : "x \(valText)\(detuneString)")
          ]
        }),
        .indexChange({ [.setCtrlLabel([.op], "\($0 + 1)")] }),
        .dimsOn([.on], id: nil),
        .editMenu([.env], paths: paths, type: "RefaceDXOp", init: nil, rand: nil)
      ], layout: [
        .row([("op",1),("freq",4)]),//, spacing: 2),
        .row([("env", 1)]),//, spacing: 2),
        .colFixed(["op", "env"], fixed: "op", height: 11, spacing: 2),
      ])
    }
    
  }
}
