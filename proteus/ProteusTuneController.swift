
extension Proteus.Tuning {
  
  enum Controller {
    
    static func ctrlr() -> PatchController {
      let paths: [SynthPath] = 12.map { [.note, .i($0)] }

      return .patch(prefix: .index([.octave]), [
        .switcher(label: "Octave", ["-2", "-1", "0", "1", "2", "3", "4", "5", "6", "7", "8"], color: 1),
        .button("Octave", color: 1),
        .children(12, "key", color: 1, key()),
        .panel("space0", [[]]),
        .panel("space1", [[]]),
        .panel("space2", [[]]),
      ], effects: [
        .editMenu([.button], pathsFn: { _ in paths }, type: "ProteusOctave", init: { index in
          12.map { $0 * 64 + (index * 768) }
        }, rand: { index in
          12.map { ($0 * 64) + (-63...63).rand() + (index * 768) }
        }, pasteTransform: { values, state, locals in
          // adjust the values to the current octave
          SynthPathInts(values.map { path, value in
            let n = value / 64
            let newN = (n % 12) + (state.index * 12)
            return [path : (newN * 64) + (value % 64)]
          }.dict { $0 })
        }, items: [
          .custom("Paste to All Octaves", { values, state, locals in
            // adjust the values to the current octave
            let offsets = values.map { path, value in
              let newN = (value / 64) % 12
              return [path : (newN * 64) + (value % 64)]
            }.dict { $0 }
            return [.unprefixedParamsChange(SynthPathInts(128.dict {
              let octave = $0 / 12
              let note = $0 % 12
              let off = offsets[[.note, .i(note)]] ?? 0
              return [[.octave, .i(octave), .note, .i(note)] : off + (octave * 768)]
            }))]
          })
        ]),
        .indexChange({ index in
          4.map { .dimPanel(index == 10, "key\($0 + 8)", dimAlpha: 0) }
//          keyControllers.forEach { $0.octave = index }
        })
      ], layout: [
        .row([("switch", 14), ("button", 2)]),
        .row([("space0", 1), ("key1", 2), ("key3", 2), ("space1", 2), ("key6", 2), ("key8", 2), ("key10", 2), ("space2", 1)]),
        .row([("key0", 2), ("key2", 2), ("key4", 2), ("key5", 2), ("key7", 2), ("key9", 2), ("key11", 2)]),
        .col([("switch", 1), ("space0", 1), ("key0", 1)]),
      ])
    }
    

    
    static func key() -> PatchController {
      let cc: PatchController.ControlChangeFn = { state, locals in
        [.paramsChange([
          [] : (locals[[.note]] ?? 0) * 64 + (locals[[.detune]] ?? 0),
        ])]
      }
      return .patch(prefix: .index([.note]), [
        .grid([[
          .knob("Note", nil, id: [.note]),
          .knob("Detune", nil, id: [.detune]),
        ]])
      ], effects: [
        .setup([
          .configCtrl([.note], .span(.iso(Proteus1.Voice.noteIso))),
          .configCtrl([.detune], .span(.rng(0...63))),
        ]),
        .controlChange([.note], fn: cc),
        .controlChange([.detune], fn: cc),
        .patchChange([], { [
          .setValue([.note], $0 / 64),
          .setValue([.detune], $0 % 64),
        ] }),
        .indexChange(fn: { state, locals in
          let octave = state.prefix?.i(1) ?? 0
          let note = Float(octave * 12 + state.index)
          return [.setCtrlLabel([.note], "\(Proteus1.Voice.noteIso.forward(note)) →")]
        }),
      ])
    }
    
  }
  
}
