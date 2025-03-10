
extension Op4.Micro {
  
  enum Controller {

    static func noteController(showOctave: Bool) -> PatchController {
      let ccFn: (PatchControllerState, [SynthPath:Int]) -> SynthPathInts? = { state, locals in
        let f = locals[[.fine]] ?? 0
        let n = locals[[.note]] ?? 0
        return noteFine(n: n, f: f)
      }
      
      return .patch(prefix: .index([]), [
        .grid(color: 1, [
          [.label("?", id: [.id])],
          [.knob("Note", nil, id: [.note])],
          [.knob("Fine", nil, id: [.fine])],
        ])
      ], effects: [
        .indexChange({ [
          .dimPanel($0 > 127, nil, dimAlpha: 0),
          .setCtrlLabel([.id], ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"][$0 % 12] + (showOctave ? "\(($0 / 12) - 2)" : "")),
        ] }),
        .patchChange(paths: [[.note], [.fine]], { values in
          let n = values[[.note]] ?? 0
          let f = values[[.fine]] ?? 0
          return [
            .setValue([.note], f > 32 ? n + 1 : n),
            .setValue([.fine], f > 32 ? f - 64 : f),
          ]
        }),
        .controlChange([.note], ccFn),
        .controlChange([.fine], ccFn),
        .setup([
          .configCtrl([.note], .opts(ParamOptions(max: 109))),
          .configCtrl([.fine], .opts(ParamOptions(range: -31...32))),
        ]),
      ])
    }
    
    static func noteFine(n: Int, f: Int) -> SynthPathInts {
      [
        [.note] : f < 0 ? n - 1 : n,
        [.fine] : f < 0 ? f + 64 : f,
      ]
    }
    
    static var octController: PatchController {
      .oneRow(12, child: noteController(showOctave: false))
    }
  
    
    static var fullController: PatchController {
      return .patch([
        .children(12, "p", noteController(showOctave: true), indexFn: { parentIndex, offset in
          12 * parentIndex + offset
        }),
        .switcher(label: "Octave", (-2...8).map { "\($0)" }, color: 1)
      ], effects: [
      ], layout: [
        .grid([
          (row: [("switch", 11)], height: 1),
          (row: 12.map { ("p\($0)", 1) }, height: 3),
        ])
      ])
    }
    
  }
  
}
