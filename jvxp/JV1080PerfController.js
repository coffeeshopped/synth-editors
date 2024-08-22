
extension JV1080.Perf {
  
  struct CtrlConfig {
    let voicePresets: [Int:[Int:String]]
    let rhythmPresets: [Int:[Int:String]]
    let blank: [Int:String]
    let patchGroups: [Int:String]
    let hasOutSelect: Bool
  }
  
  enum Controller {

//    let showXP = PerfPart.self is XP50PerfPartPatch.Type
//    let show2080 = PerfPart.self is JV2080PerfPartPatch.Type
    static func controller(showXP: Bool = false, show2080: Bool = false, config: CtrlConfig) -> PatchController {
      
      var hides = [PatchController.AttrChange]()
      if !showXP {
        hides += [
          .dimItem(true, [.key, .mode], dimAlpha: 0),
          .dimItem(true, [.clock, .src], dimAlpha: 0),
        ]
      }
      if !show2080 {
        hides += [
          .dimItem(true, [.fx, .i(1), .src], dimAlpha: 0),
          .dimItem(true, [.fx, .i(2), .src], dimAlpha: 0),
        ]
      }
      
      return .paged([
        .switcher(["Common","Parts 1–8","Parts 9–16"], color: 1),
        .panel("tempo", prefix: [.common], color: 1, [[
          .knob("Tempo", [.tempo]),
          .checkbox("Key Range", [.key, .range]),
          .switsch("Key Mode", [.key, .mode]),
          .switsch("Clock Src", [.clock, .src]),
          .select(show2080 ? "FX A Src" : "FX Src", [.fx, .src]),
          .select("FX B Src", [.fx, .i(1), .src]),
          .select("FX C Src", [.fx, .i(2), .src]),
          ]]),
      ], effects: [
        .setup(hides),
      ], layout: [
        .row([("switch",8),("tempo",8)]),
        .row([("page", 1)]),
        .col([("switch",1),("page",8)]),
      ], pages: .map([
        [.common],
        [.part, .i(0)],
        [.part, .i(1)],
      ], [
        [.common] : common(show2080: show2080),
        [.part] : parts(config: config)
      ]))
    }
    
    
    static func parts(config: CtrlConfig) -> PatchController {
      return .oneRow(8, child: part(config: config)) { parentIndex, offset in
         offset + (parentIndex * 8)
      }
    }

    static func common(show2080: Bool) -> PatchController {
      let fxDim: PatchController.Effect
      if show2080 {
        fxDim = .patchChange(paths: [[.common, .fx, .src], [.common, .fx, .i(1), .src], [.common, .fx, .i(2), .src]], { values in
          [.dimPanel(values.reduce(true, { $0 && $1.value > 0 }), "fx")]
        })
      }
      else {
        fxDim = .dimsOn([.common, .fx, .src], id: "fx", dimWhen: { $0 > 0 })
      }
      return .patch([
        .child(.patch(prefix: .fixed([.common]), [
          .child(JV1080.Voice.Controller.fx(), "p"),
        ], layout: [
          .simpleGrid([[("p", 1)]]),
        ]), "fx"),
        .child(reserve(), "reserve"),
        .panel("chorus", prefix: [.common, .chorus], color: 1, [[
          .knob("Chorus", [.level]),
          .knob("Rate", [.rate]),
          .knob("Depth", [.depth]),
          .knob("Pre-Delay", [.predelay]),
          .knob("Feedback", [.feedback]),
          .switsch("Output", [.out, .assign]),
        ]]),
        .panel("reverb", prefix: [.common, .reverb], color: 1, [[
          .select("Reverb", [.type]),
          .knob("Level", [.level]),
          .knob("Time", [.time]),
          .select("HF Damp", [.hfdamp]),
          .knob("Feedback", [.feedback]),
        ]]),
        .panel("range", prefix: [.part], color: 1, [
          16.map { .knob($0 == 0 ? "Key Lo" : "\($0 + 1)", [.i($0), .key, .range, .lo]) },
          16.map { .knob($0 == 0 ? "Key Hi" : "\($0 + 1)", [.i($0), .key, .range, .hi]) }
        ]),
        .panel("midi", prefix: [.part], color: 1, [
          16.map { .knob($0 == 0 ? "Midi Ch" : "\($0 + 1)", [.i($0), .channel]) },
          16.map { .checkbox($0 == 0 ? "Midi Rcv" : "\($0 + 1)", [.i($0), .midi, .rcv]) }
        ]),
      ], effects: [
        .dimsOn([.common, .key, .range], id: "range"),
        fxDim,
      ], layout: [
        .row([("fx", 1)]),
        .row([("chorus", 1),("reverb", 1)]),
        .row([("reserve", 1)]),
        .row([("range", 1)]),
        .row([("midi", 1)]),
        .col([("fx", 2), ("chorus", 1), ("reserve", 1), ("range", 2), ("midi", 2)]),
      ])
    }
    
    static func reserve() -> PatchController {
      let ctrls: [SynthPath] = 16.map { [.i($0), .voice, .reserve] }
      let reservePaths = ctrls.map { [.common, .part] + $0 }
      return .patch(prefix: .fixed([.common, .part]), color: 1, [
        .grid([
          16.map { .knob($0 == 0 ? "Voice Resrv" : "\($0 + 1)", nil, id: [.i($0), .voice, .reserve]) }
        ])
      ], effects: .voiceReserve(paths: reservePaths, total: 64, ctrls: ctrls))
    }
        
    // JV-2080 = hasOutSelect
    static func part(config: CtrlConfig) -> PatchController {

      // Out Assign options/handling
      let outEffects: [PatchController.Effect]
      if config.hasOutSelect {
        outEffects = [
          .setup([
            .configCtrl([.out, .assign], .opts(ParamOptions(optArray: ["Mix", "EFX A", "EFX B", "EFX C", "Dir 1", "Dir 2", "Patch A", "Patch B", "Patch C"])))
          ]),
          .patchChange(paths: [[.out, .assign], [.out, .select]], { values in
            guard let assign = values[[.out, .assign]],
                  let sel = values[[.out, .select]] else { return [] }
            let v: Int
            switch assign {
            case 0:
              v = 0
            case 1:
              v = 1 + sel // fx
            case 2, 3:
              v = assign + 2
            default:
              v = 6 + sel // patch
            }
            return [.setValue([.out, .assign], v)]
          }),
          .controlChange([.out, .assign], { state, locals in
            let v = locals[[.out, .assign]] ?? 0
            let assign: Int
            let sel: Int
            switch v {
            case 0:
              assign = 0
              sel = 0
            case 1, 2, 3:
              assign = 1
              sel = v - 1
            case 4, 5:
              assign = v - 2
              sel = 0
            default:
              assign = 4
              sel = v - 6
            }
            return [
              [.out, .assign] : assign,
              [.out, .select] : sel
            ]
          })
        ]
      }
      else {
        outEffects = .ctrlBlocks([.out, .assign])
      }
      
      return .index([.part], label: [.part], { "\($0 + 1)" }, color: 1, [
        .grid([[
          .label("Part", align: .center, id: [.part], width: 1),
          .select("Patch Group", nil, id: [.patch, .group]),
        ],[
          .select("Patch", nil, id: [.patch, .number]),
        ],[
          .knob("Level", [.level]),
          .knob("Pan", [.pan]),
        ],[
          .knob("Tune", [.coarse]),
          .knob("Fine", [.fine]),
        ],[
          .select("Out Assign", nil, id: [.out, .assign]),
          .knob("Out Level", [.out, .level]),
        ],[
          .knob("Chorus", [.chorus]),
          .knob("Reverb", [.reverb]),
        ],[
          .checkbox("Pgm Change", [.rcv, .pgmChange]),
          .checkbox("Volume", [.rcv, .volume]),
        ],[
          .checkbox("Hold", [.rcv, .hold]),
        ]]),
      ], effects: [
        // patch group
        .setup([
          .configCtrl([.patch, .group], .opts(ParamOptions(opts: config.patchGroups))),
        ]),
        .patchChange(paths: [[.patch, .group], [.patch, .group, .id]], { values in
          guard let group = values[[.patch, .group]],
            let groupId = values[[.patch, .group, .id]] else { return [] }
          return [.setValue([.patch, .group], group == 0 ? groupId - 100 : groupId)]
        }),
        .controlChange([.patch, .group], { state, locals in
          let v = locals[[.patch, .group]] ?? 0
          return [
            [.patch, .group] : v < 0 ? 0 : 2,
            [.patch, .group, .id] : v < 0 ? v + 100 : v,
          ]
        }),
        // patchNumber
        .basicPatchChange([.patch, .number]),
        .basicControlChange([.patch, .number]),
      ] + .patchSelector(id: [.patch, .number], bankValues: [[.patch, .group], [.patch, .group, .id]], paramMapWithContext: { values, state, locals in
        guard let group = values[[.patch, .group]],
              let groupId = values[[.patch, .group, .id]] else { return .fullPath([]) }
        let isRhythm = state.index == 9
        if group == 0 {
          guard groupId != 1 else {
            return .fullPath(isRhythm ? [.rhythm, .name] : [.patch, .name])
          }
          let presets = isRhythm ? config.rhythmPresets : config.voicePresets
          return .opts(ParamOptions(opts: presets[groupId] ?? [:]))
        }
        else if let board = SRJVBoard.boards[groupId] {
          return .opts(ParamOptions(optArray: isRhythm ? board.rhythms : board.patches))
        }
        else {
          return .opts(ParamOptions(opts: config.blank))
        }
      }) + outEffects)
    }

  }
  
}

