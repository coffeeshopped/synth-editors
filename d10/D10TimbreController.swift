
extension D10.Timbre {
  
  enum Controller {
        
    static func timbre(hideOut: Bool) -> PatchController {
      
      var items: [[PatchController.PanelItem]] = [[
        .switsch("Tone Group", [.tone, .group]),
      ],[
        .select("Tone Number", nil, id: [.tone, .number]),
      ],[
        .knob("Key Shift", [.tune]),
        .knob("Fine Tune", [.fine]),
      ]]
      
      items += [[
        .knob("Bend Range", [.bend]),
      ],[
        .switsch("Assign Mode", [.assign, .mode]),
      ],[
        hideOut ? .spacer(2) : .checkbox("Reverb", [.out, .assign])
      ]]
      
      return .patch(color: 1, [
        .grid(items)
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
  }
  
}

// D10 keys: false, hideOut: false
// D5 keys: false, hideOut: true

