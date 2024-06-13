
extension TX81Z.Perf {
  
  enum Controller {
    
    static func controller(_ presetVoices: [String]) -> PatchController {
      return .patch([
        .children(8, "part", partController(presetVoices)),
        .panel("other", color: 1, [[
          .switsch("Assign Mode", [.assign]),
          .select("Effect", [.fx]),
          .select("Microtune", [.micro, .scale]),
          .select("Key", [.micro, .key]),
        ]]),
        .panel("space", [[]])
      ], effects: [], layout: [
        .row(8.map { ("part\($0)", 1)}),
        .row([("other", 7), ("space", 9)]),
        .col([("part0", 6), ("other", 1)]),
      ])
    }
    
    static func partController(_ presetVoices: [String]) -> PatchController {
      let reservePaths: [SynthPath] = 8.map { [.part, .i($0), .voice, .reserve] }
      return .index([.part], label: [.voice, .number], { "Inst \($0 + 1)" }, color: 2, [
        .grid([[
          .select("Inst", [.voice, .number]),
        ],[
          .select([.channel]),
          .knob("Max Notes", nil, id: [.voice, .reserve]),
        ],[
          .knob([.volume]),
          .switsch("Out Assign", [.out, .select]),
        ],[
          .knob("Low Note", [.note, .lo]),
          .knob("High Note", [.note, .hi]),
        ],[
          .knob([.note, .shift]),
          .knob([.detune]),
        ],[
          .switsch("LFO Select", [.lfo]),
          .checkbox("Microtune", [.micro]),
        ]])
      ], effects: [
        .paramChange([.patch, .name], { param in
          let options = (param as? OptionsParam)?.options ?? [:]
          return [.configCtrl([.voice, .number], .opts(ParamOptions(opts: options <<< presetVoices.enumerated().dict {
            [$0.offset + 32 : $0.element]
          })))]
        }),
        .dimsOn([.voice, .reserve], id: nil),
      ] + .voiceReserve(paths: reservePaths, total: 8, ctrls: [[.voice, .reserve]])
      )
                        
    }
  }
  
}
