
extension D110.Patch {
  
  enum Controller {
    
    static func ctrlr() -> PatchController {
      .patch([
        .panel("reverb", prefix: [.common, .reverb], color: 2, [[
          .select("Reverb", [.type]),
          .knob("Time", [.time]),
          .knob("Level", [.level]),
        ]]),
        .panel("rhythm", color: 1, [[
          .knob("R Chan", [.common, .part, .rhythm, .channel]),
          .knob("R Rsrv", [.common, .part, .rhythm, .reserve]),
          .knob("R Out Lvl", [.part, .rhythm, .out, .level]),
        ]]),
        .child(.oneRow(8, child: timbre()), "timbres"),
        .child(.oneRow(8, child: extra()), "extras"),
      ], effects: [
      ], layout: [
        .grid([
          (row: [("timbres", 1)], height: 7),
          (row: [("extras", 1)], height: 1),
          (row: [("reverb", 3.5), ("rhythm", 3)], height: 1),
        ])
      ])
    }
    
    static func timbre() -> PatchController {
      
      return .patch(prefix: .index([.part]), color: 1, [
        .grid([[
          .switsch("Tone Group", [.tone, .group]),
        ],[
          .select("Tone Number", nil, id: [.tone, .number]),
        ],[
          .knob("Level", [.out, .level]),
          .knob("Pan", [.pan]),
        ],[
          .knob("Key Shift", [.tune]),
          .knob("Fine Tune", [.fine]),
        ],[
          .knob("Lo Key", [.key, .lo]),
          .knob("Hi Key", [.key, .hi]),
        ],[
          .knob("Bend Range", [.bend]),
          .switsch("Assign Mode", [.assign, .mode]),
        ],[
          .select("Out Assign", [.out, .assign]),
        ]])
      ], effects: [
        .basicControlChange([.tone, .number]),
        .basicPatchChange([.tone, .number]),
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
    
    static func extra() -> PatchController {
      return .patch(prefix: .index([.common, .part]), color: 1, [
        .grid([[
          .knob("Chan", [.channel]),
          .knob("Rsrv", [.reserve]),
        ]])
      ], effects: [
      ])
    }

  }
  
}
