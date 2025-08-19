
//extension VolcaFM2.Sequence {
//  
//  struct Controller {
//    
//    static func controller() -> PatchController {
//      return .paged([
//        .switcher(["Main", "Motion", "Notes"], color: 1),
//        .panel("pgm", color: 1, [[.select("Program", nil, id: [.pgm])]]),
//      ], effects: .ctrlBlocks([.pgm], param: .fullPath([.patch, .name])) + [
//      ], layout: [
//        .grid([
//          (row: [("switch", 14.5), ("pgm", 1.5)], height: 1),
//          (row: [("page", 1)], height: 8),
//        ])
//      ], pages: .controllers([main(), motion(), notes()]))
//    }
//    
//    static func main() -> PatchController {
//      return .patch([
//        .child(mainSub(), "sub", color: 3, clearBG: true),
//        .panel("ctrls", color: 2, [[
//          .checkbox([.motion, .on]),
//          .checkbox([.smooth]),
//          .checkbox("Warp AS", [.warp, .active]),
//          .checkbox("Xpos Note", [.transpose, .note]),
//          .switsch("Tempo", [.tempo]),
//        ]]),
//        .panel("mono", color: 2, [[
//          .checkbox([.mono]),
//          .checkbox([.unison]),
//        ]]),
//        .panel("chorus", prefix: [.chorus], color: 2, [[
//          .checkbox("Chorus", [.on]),
//          .knob([.depth]),
//        ]]),
//        .panel("reverb", prefix: [.reverb], color: 2, [[
//          .checkbox("Reverb", [.on]),
//          .knob([.depth]),
//        ]]),
//        .panel("arp", prefix: [.arp], color: 2, [[
//          .checkbox("Arp", [.on]),
//          .select([.type]),
//          .select([.divide]),
//        ]]),
//        .panel("step", color: 2, [
//          16.map { .checkbox("Active \($0 + 1)", [.i($0), .active]) },
//          16.map { .checkbox("Step \($0 + 1)", [.i($0), .on]) },
//        ]),
//      ], effects: [
//        .dimsOn([.chorus, .on], id: "chorus"),
//        .dimsOn([.reverb, .on], id: "reverb"),
//        .dimsOn([.arp, .on], id: "arp"),
//      ], layout: [
//        .grid([
//          (row: [("ctrls", 5), ("mono", 2), ("chorus", 2), ("reverb", 2), ("arp", 4)], height: 1),
//          (row: [("step", 1)], height: 2),
//          (row: [("sub", 1)], height: 5),
//        ])
//      ])
////        onActiveChange(vc) { vc, step, on, active in
////          steps[step].isHidden = !active
////        }
//    }
//
//    static func mainSub() -> PatchController {
//      let paths: [SynthPath] = 16.map { [.pitch, .i($0)] } +
//        16.map { [.velo, .i($0)] } +
//        16.map { [.gate, .i($0)] } +
//        16.map { [.trigger, .i($0)] }
//
//      return .patch(prefix: .index([.note]), border: 3, [
//        .switcher(label: "Notes", 6.map { "\($0 + 1)" }, color: 3),
//        .panel("notes", color: 3, [
//          16.map { .fullSlider("Note \($0 + 1)", [.pitch, .i($0)]) },
//          16.map { .fullSlider("Velo \($0 + 1)", [.velo, .i($0)]) },
//          16.map { .knob("Gate \($0 + 1)", [.gate, .i($0)]) },
//          16.map { .checkbox("Trig \($0 + 1)", [.trigger, .i($0)]) },
//        ]),
//        .button("Note", color: 3),
//      ], effects: [
//        .indexChange({ [.setCtrlLabel([.button], "Note \($0 + 1)")] }),
//        .editMenu([.button], paths: paths, type: "VolcaFM2NoteSeq", init: [Int](repeating: 0, count: 64), rand: {
//          ranges.flatMap { range in 16.map { _ in range.rand() } }
//        })
//      ] + pathParts.flatMap { veloActiveChange($0) }, layout: [
//        .grid([
//          (row: [("notes", 1)], height: 4),
//          (row: [("switch", 13), ("button", 3)], height: 1),
//        ]),
//      ])
//        
////        onActiveChange(vc) { vc, step, on, active in
////          ([notes, velos, gates, trigs] as [[PBLabeledControl]]).forEach {
////            $0[step].isHidden = !active || !on
////          }
////        }
//    }
//    
//    static func motion() -> PatchController {
//      let sectionTitles = ["Transpose", "Velo", "Algo", "Mod A", "Mod D", "Car A", "Car D", "LFO Rate", "LFO Pitch", "Arp Type", "Arp Div", "Chorus", "Reverb"]
//      
//      let dataCtrl: PatchController = .data(80, 0...127, { [.step, .i($0 / 5), .data, .i($0 % 5)] }, effects: [
//        .indexChange(fn: { state, locals in
//          let opts: ParamOptions?
//          switch state.index {
//          case 0:
//            let isNote = (state.values[[.transpose, .note]] ?? 0) == 1
//            opts = isNote ? noteFormat : octaveFormat
//          default:
//            opts = motionSections[state.index].1
//          }
//          guard let opts = opts else { return [] }
//          return [.configCtrl([.data, .ctrl], .opts(opts))]
//        }),
//      ])
//      
//      return .patch(prefix: .indexFn({ motionSections[$0].0 }), [
//        .switcher(label: "Motion Data", sectionTitles, color: 2),
//        .panel("steps", color: 2, [
//          [.checkbox("?", [.on])] + 16.map { .checkbox("\($0 + 1)", [.i($0)]) }
//        ]),
//        .child(dataCtrl, "array", color: 2, clearBG: true),
//      ], effects: [
//        .indexChange({ [.setCtrlLabel([.on], sectionTitles[$0])] }),
//        .indexChange({ [.setIndex("array", $0)] }),
//      ], layout: [
//        .grid([
//          (row: [("steps", 17)], height: 1),
//          (row: [("array", 1)], height: 6),
//          (row: [("switch", 1)], height: 1),
//        ])
//      ])
//    }
//    
//
//    static func notes() -> PatchController {
//      let activeCmds: [PatchController.Effect] = 16.map { step in
//        .patchChange(paths: [[.i(step), .on], [.i(step), .active]]) { values in
//          guard let on = values[[.i(step), .on]],
//                let active = values[[.i(step), .active]] else { return [] }
//          let dim = !(active > 0) || !(on > 0)
//          return 6.flatMap { note in
//            pathParts.map { .dimItem(dim, pathFn($0)(note, step), dimAlpha: 0) }
//          }
//        }
//      }
//      
//      return .patch(border: 3, [
//        .child(notesSub(), "sub", color: 3),
//        .panel("step", color: 2, [16.map { .checkbox("Step \($0 + 1)", [.i($0), .on]) }]),
//      ], effects: activeCmds, layout: [
//        .grid([
//          (row: [("step", 1)], height: 1),
//          (row: [("sub", 1)], height: 7),
//        ])
//      ])
//    }
//    
//    static func pathFn(_ pathPart: SynthPathItem) -> ((_ note: Int, _ step: Int) -> SynthPath) {
//      { [.note, .i($0), pathPart, .i($1)] }
//    }
//    static let pathParts: [SynthPathItem] = [.pitch, .velo, .gate, .trigger]
//    static let ranges = [128, 128, 73, 2]
//
//    static func notesSub() -> PatchController {
//      let labels = ["Notes", "Velocity", "Gate", "Trigger"]
//      let initZeros = [Int](repeating: 0, count: 96)
//      return .paged([
//        .switcher(labels, color: 3),
//        .button("Note", color: 3),
//      ], effects: [
//        .indexChange({ [.setCtrlLabel([.button], labels[$0])] }),
//        .editMenu([.button], pathsFn: {
//          let part = pathParts[$0]
//          return 96.map { [.note, .i($0 / 16), part, .i($0 % 16)] }
//        }, type: "VolcaFM2NoteSeqPanel", init: { _ in initZeros }, rand: {
//          let range = ranges[$0]
//          return 96.map { _ in range.rand() }
//        })
//      ], layout: [
//        .grid([
//          (row: [("page", 1)], height: 6),
//          (row: [("switch", 13), ("button", 3)], height: 1),
//        ])
//      ], pages: .controllers([notesPanel, veloPanel, gatePanel, trigPanel]))
//    }
//        
//    static func panel(_ ctrl: PatchController.Control, _ pathPart: SynthPathItem) -> PatchController {
//      let pathFn = pathFn(pathPart)
//      return .patch([
//        .grid(color: 3, 6.map { note in
//          16.map { step in
//              .basic(ctrl, "\(step + 1)-\(note + 1)", pathFn(note, step), id: nil)
//          }
//        }),
//      ], effects: veloActiveChange(pathPart))
//    }
//    
//    static let notesPanel: PatchController = panel(.fullSlider, .pitch)
//    static let veloPanel: PatchController = panel(.fullSlider, .velo)
//    static let gatePanel: PatchController = panel(.knob, .gate)
//    static let trigPanel: PatchController = panel(.checkbox, .trigger)
//
//    static func veloActiveChange(_ pathPart: SynthPathItem) -> [PatchController.Effect] {
//      let pathFn = pathFn(pathPart)
//      return 6.flatMap { note in
//        16.map { step in
//          .patchChange(paths: [[.i(step), .on], [.i(step), .active], [.note, .i(note), .velo, .i(step)]]) { values in
//            guard let on = values[[.i(step), .on]],
//                  let active = values[[.i(step), .active]],
//                  let velo = values[[.note, .i(note), .velo, .i(step)]] else { return [] }
//            let dim: (Bool, CGFloat)
//            if !(active > 0) || !(on > 0) {
//              dim = (true,0)
//            }
//            else if velo == 0 {
//              dim = (true,0.2)
//            }
//            else {
//              dim = (false,0.4)
//            }
//            return [.dimItem(dim.0, pathFn(note, step), dimAlpha: dim.1)]
//          }
//        }
//      }
//    }
//
//  }
//
//
//}
