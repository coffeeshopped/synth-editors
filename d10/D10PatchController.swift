
extension D10.Patch {
  
  enum Controller {
    
    static func ctrlr(hideReverb: Bool) -> PatchController {
      .patch([
        .children(2, "t", timbre()),
        .panel("mode", color: 1, [[
          .switsch("Key Mode", [.key, .mode]),
          .knob("Split Pt", [.split, .pt]),
          .knob("Balance", [.balance]),
          .knob("Level", [.level]),
        ]]),
        .panel("reverb", prefix: [.reverb], color: 1, [[
          .select("Reverb", [.type]),
          .knob("Time", [.time]),
          .knob("Level", [.level]),
        ]]),
      ], effects: [
        .setup([.dimPanel(hideReverb, "reverb", dimAlpha: 0)]),
      ], layout: [
        .grid([
          (row: [("mode", 4), ("reverb", 3.5)], height: 1),
          (row: [("t0", 2), ("t1", 2)], height: 5),
        ])
      ])
    }
    
    static func timbre() -> PatchController {
      return .patch(prefix: .indexFn({ $0 == 0 ? [.lo] : [.hi] }), color: 2, [
        .grid([[
          .switsch("Tone Group", [.tone, .group]),
        ],[
          .select("Tone Number", nil, id: [.tone, .number]),
        ],[
          .knob("Key Shift", [.tune]),
          .knob("Fine Tune", [.fine]),
        ],[
          .knob("Bend Range", [.bend]),
          .switsch("Assign Mode", [.assign, .mode]),
        ],[
          .checkbox("Reverb", [.out, .assign]),
        ]])
      ], effects: [
        .basicControlChange([.tone, .number]),
        .basicPatchChange([.tone, .number]),
        .indexChange({
          [.setCtrlLabel([.tone, .group], $0 == 0 ? "Lower" : "Upper")]
        })
      ] + .patchSelector(id: [.tone, .number], bankValue: [.tone, .group], paramMap: {
        switch $0 {
        case 0:
          return .span(.opts(DXX.presetA))
        case 1:
          return .span(.opts(DXX.presetB))
        case 2:
          return .fullPath([.tone, .name])
        default:
          return .span(.opts(DXX.presetR))
        }
      }))
    }
  }
  
}
