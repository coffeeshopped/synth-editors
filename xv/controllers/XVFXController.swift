
extension XV.FX {
  
  enum Controller {
    
    static func mfx(index: Int, config: XV.CtrlConfig) -> PatchController {
      let prefix: SynthPath = index < 0 ? [.fx] : [.fx, .i(index)]
      let suffix = (0...2).contains(index) ? ["A", "B", "C"][index] : "Type"
      let paramCount = 32

      var effects = [PatchController.Effect]()
          
      if config.is5050 {
        effects += [
          .basicPatchChange([.type]),
          .basicControlChange([.type]),
          .setup([
            .configCtrl([.type], .opts(ParamOptions(opts: index <= 0 ? XV5050.FX.aTypeOptions : XV5050.FX.bcTypeOptions)))
          ])
        ]
      }
      else {
        effects += .ctrlBlocks([.type])
      }
      
      // For B, C FX, dim when A selects a beefier type.
      if index > 0 {
        effects.append(.patchChange(fullPath: [.fx, .i(0), .type], { [
          .dimPanel(!XV5050.FX.isBCFX(index: $0), nil),
        ] }))
      }
      
      let ctrl: PatchController = .index([.ctrl], label: [.src], { "Src \($0 + 1)" }, [
        .grid(color: 2, [[
          .select("Src", [.src]),
          .knob("Amt", [.amt]),
          .select("Dest", nil, id: [.assign]),
        ]])
      ], effects: [
        .indexChange({ [
          .setCtrlLabel([.assign], "Dest \($0 + 1)"),
        ] }),
        .basicPatchChange([.assign]),
        .basicControlChange([.assign]),
        .dimsOn([.assign], id: nil),
        .patchChange(fullPath: prefix + [.type], { [
          .configCtrl([.assign], .opts(ParamOptions(opts: XV.FX.allFx[$0].destOptions))),
        ] }),
      ])
      
      return .patch(prefix: .fixed(prefix), [
        .children(4, "ctrl", ctrl),
        .panel("type", color: 2, [[
          .select("MFX \(suffix)", nil, id: [.type]),
          .switsch("Output", [.out]),
        ],[
          .knob("Dry", [.dry]),
          .knob("Chorus", [.chorus]),
          .knob("Reverb", [.reverb]),
        ]]),
        .panel("param", color: 2, [
          (0..<16).map { .knob("?", nil, id: [.param, .i($0)]) },
          (16..<32).map { .knob("?", nil, id: [.param, .i($0)]) },
        ]),
        .button("MFX", color: 2),
      ], effects: [
        typeChangeEffect(paramCount, { XV.FX.allFx[$0].params }),
        .editMenu([.button], paths: config.fxTruss.paramKeys(), type: "XVMFX", init: nil, rand: nil, items: [
          .filePopover("Load/Save...", [.fx]),
        ]),
        .dimsOn([.type], id: "param"),
      ] + effects + paramCount.flatMap { [
        .basicPatchChange([.param, .i($0)]),
        .basicControlChange([.param, .i($0)]),
      ] }, layout: [
        .row([("type", 3), ("ctrl0", 4), ("ctrl1", 4), ("button", 2)], opts: [.alignAllTop]),
        .row([("param", 1)]),
        .col([("type", 2), ("param", 2)]),
        .rowPart([("ctrl2", 4), ("ctrl3", 4)]),
        .colPart([("ctrl0", 1), ("ctrl2", 1)], opts: [.alignAllLeading, .alignAllTrailing]),
        .eq(["ctrl0", "ctrl1"], .bottom),
        .eq(["type", "ctrl2", "ctrl3", "button"], .bottom),
      ])
    }
    
    static func chorus() -> PatchController {
      let paramCount = 8
      return .patch(prefix: .fixed([.chorus]), color: 3, border: 3, [
        .panel("type", [[
          .switsch("Chorus", [.type]),
          .knob("Level", [.level]),
          .switsch("Out Assign", [.out, .assign]),
          .switsch("Out Select", [.out, .select]),
        ]]),
        .panel("param", [paramCount.map { .knob("?", nil, id: [.param, .i($0)]) }]),
      ], effects: [
        .dimsOn([.type], id: nil),
        typeChangeEffect(paramCount, { XV.Chorus.paramMap[$0] }),
      ] + paramCount.flatMap { [
        .basicPatchChange([.param, .i($0)]),
        .basicControlChange([.param, .i($0)]),
      ] }, layout: [
        .simpleGrid([
          [("type", 5), ("param", 12)],
        ])
      ])
    }

    static func reverb() -> PatchController {
      let paramCount = 10
      return .patch(prefix: .fixed([.reverb]), color: 3, border: 3, [
        .panel("type", [[
          .switsch("Reverb", [.type]),
          .knob("Level", [.level]),
          .switsch("Out Assign", [.out, .assign])
        ]]),
        .panel("param", [paramCount.map { .knob("?", nil, id: [.param, .i($0)]) }]),
      ], effects: [
        .dimsOn([.type], id: nil),
        typeChangeEffect(paramCount, { XV.Reverb.paramMap[$0] }),
      ] + paramCount.flatMap { [
        .basicPatchChange([.param, .i($0)]),
        .basicControlChange([.param, .i($0)]),
      ] }, layout: [
        .simpleGrid([
          [("type", 5), ("param", 12)],
        ])
      ])
    }
    
    private static func typeChangeEffect(_ paramCount: Int, _ paramBlock: @escaping (Int) -> [Int:(String,Param)]) -> PatchController.Effect {
      .patchChange(paths: [[.type]]) { values, state, locals in
        let info = paramBlock(values[[.type]] ?? 0)
        return paramCount.flatMap { i in
          let id: SynthPath = [.param, .i(i)]
          guard let pair = info[i] else { return [.dimItem(true, id, dimAlpha: 0)] }
          return [
            .configCtrl(id, .param(pair.1)),
            .setValue(id, state.prefixedValue(id) ?? 0),
            .setCtrlLabel(id, pair.0),
            .dimItem(false, id),
          ]
        }
      }
    }
    
  }


}
