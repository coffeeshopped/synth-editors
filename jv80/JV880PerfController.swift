
extension JV880.Perf {
  
  enum Controller {
  
    static func ctrlr() -> PatchController {
      return .paged([
        .switcher(["Common","Parts"], color: 1),
        .panel("space", [[]]),
      ], effects: [
      ], layout: [
        .row([("switch",6), ("space", 10)]),
        .row([("page",1)]),
        .col([("switch",1), ("page",8)]),
      ], pages: .controllers([common(), parts(hideOut: false)]))
    }
    
    static func common() -> PatchController {
      let reservePaths: [SynthPath] = 8.map { [.part, .i($0), .voice, .reserve] }
      return .patch(prefix: .fixed([.common]), color: 1, [
        .panel("reverb", [[
          .select("Reverb", [.reverb, .type]),
          .knob("Level", [.reverb, .level]),
          .knob("Time", [.reverb, .time]),
          .knob("Feedback", [.reverb, .feedback]),
          ]]),
        .panel("chorus", [[
          .switsch("Chorus", [.chorus, .type]),
          .knob("Level", [.chorus, .level]),
          .knob("Depth", [.chorus, .depth]),
          .knob("Rate", [.chorus, .rate]),
          .knob("Feedback", [.chorus, .feedback]),
          .switsch("Output", [.chorus, .out, .assign]),
          ]]),
        .panel("reserve", [[
          .knob("Voice Reserve 1", nil, id: [.part, .i(0), .voice, .reserve]),
          .knob("2", nil, id: [.part, .i(1), .voice, .reserve]),
          .knob("3", nil, id: [.part, .i(2), .voice, .reserve]),
          .knob("4", nil, id: [.part, .i(3), .voice, .reserve]),
        ], [
          .knob("5", nil, id: [.part, .i(4), .voice, .reserve]),
          .knob("6", nil, id: [.part, .i(5), .voice, .reserve]),
          .knob("7", nil, id: [.part, .i(6), .voice, .reserve]),
          .knob("8", nil, id: [.part, .i(7), .voice, .reserve]),
        ]]),
      ], effects: [
      ] + .voiceReserve(paths: reservePaths.map { [.common] + $0 }, total: 28, ctrls: reservePaths), layout: [
        .row([("reverb",4.5)]),
        .row([("chorus",6)]),
        .row([("reserve",4)]),
        .col([("reverb",1), ("chorus",1), ("reserve",2)]),
      ])
    }
    
    static func parts(hideOut: Bool) -> PatchController {
      .oneRow(8, child: part(hideOut: hideOut))
    }

    static func part(hideOut: Bool) -> PatchController {
      let effects: [PatchController.Effect] = .patchSelector(id: [.patch, .number], bankValues: [[.patch, .number]], paramMapWithContext: { values, state, locals in
        let v = (values[[.patch, .number]] ?? 0) / 64
        let opts: [Int:String]
        switch v {
        case 0:
          return .fullPath([.patch, .name])
        case 1:
          opts = JV80.Perf.Part.blankPatchOptions
        case 2:
          opts = JV80.Perf.Part.presetAOptions
        default:
          opts = JV80.Perf.Part.presetBOptions
        }
        return .opts(ParamOptions(opts: opts))
      })
      
      return .index([.part], label: [.on], { $0 == 7 ? "Rhythm" : "\($0 + 1)" }, [
        .grid(color: 1, [[
          .checkbox("On", [.on]),
          .knob("Channel", [.channel]),
        ], [
          .switsch("Group", nil, id: [.patch, .group]),
        ], [
          .select("Patch", nil, id: [.patch, .number]),
        ], [
          .knob("Level", [.level]),
          .knob("Pan", [.pan]),
        ], [
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
        ], [
          .checkbox("Reverb", [.reverb]),
          .checkbox("Chorus", [.chorus]),
        ], [
          .checkbox("Rx Pgm Ch", [.rcv, .pgmChange]),
          .checkbox("Rx Volume", [.rcv, .volume]),
        ], [
          .checkbox("Rx Hold", [.rcv, .hold]),
          .switsch("Output", [.out, .assign]),
        ]]),
      ], effects: effects + [
        .setup([
          .configCtrl([.patch, .group], .opts(ParamOptions(opts: JV80.Perf.Part.patchGroupOptions))),
          .dimItem(hideOut, [.out, .assign], dimAlpha: 0),
        ]),
        .patchChange([.patch, .number], { [
          .setValue([.patch, .group], $0 / 64),
          .setValue([.patch, .number], $0 % 64),
        ] }),
        .indexChange({ [
          .dimItem($0 == 7, [.patch, .number], dimAlpha: 0),
        ] }),
      ] + .controlChange(ids: [[.patch, .group], [.patch, .number]], { state, locals in
        let group = locals[[.patch, .group]] ?? 0
        let number = locals[[.patch, .number]] ?? 0
        return [[.patch, .number] : group * 64 + number]
      }))
    }
    
  }
  
}
