
extension Blofeld.MultiMode {

  struct Controller {
    
    static var ctrlr: PatchController {
      return .paged([
        .switcher(["Main 1–8","Main 9–16","Receive"], color: 1),
        .panel("ctrl", color: 1, [[
          .knob("Volume", [.volume]),
          .knob("Tempo", [.tempo]),
        ]])
      ], layout: [
        .row([("switch",8),("ctrl",8)]),
        .row([("page",1)]),
        .col([("switch",1),("page",8)]),
      ], pages: .map([[.part, .i(0)], [.part, .i(1)], [.rcv]], [
        [.part] : .oneRow(8, child: part, indexMap: { $0 * 8 + $1 }),
        [.rcv] : receive,
      ]))
    }
    
    static var part: PatchController {
      return .patch(prefix: .index([.part]), color: 1, [
        .grid([
          [.select("Bank", [.bank])],
          [.select("Sound", [.sound])],
          [
            .knob("Volume", [.volume]),
            .knob("Pan", [.pan]),
          ],
          [.knob("Channel", [.channel])],
          [
            .knob("Transpose", [.transpose]),
            .knob("Detune", [.detune]),
          ],
          [
            .knob("Velo Lo", [.velo, .lo]),
            .knob("Velo Hi", [.velo, .hi]),
          ],
          [
            .knob("Key Lo", [.key, .lo]),
            .knob("Key Hi", [.key, .hi]),
          ],
          [.switsch(nil, [.mute])],
        ]),
      ], effects: [
        .dimsOn([.mute], id: nil, dimWhen: { $0 == 1 }),
        .indexChange({
          [.setCtrlLabel([.mute], "\($0 + 1)")]
        }),
      ] + .patchSelector(id: [.sound], bankValue: [.bank], paramMap: {
        .fullPath([.patch, .name, .i($0)])
      })
      )
    }
    
    static var receive: PatchController {
      .oneRow(16, child:
        .patch(prefix: .index([.part]), color: 1, [
          .grid([
            [.label("?", id: [.part])],
            [.checkbox("MIDI", [.midi])],
            [.checkbox("USB", [.usb])],
            [.checkbox("Local", [.local])],
            [.checkbox("Bend", [.bend])],
            [.checkbox("Mod W", [.modWheel])],
            [.checkbox("Pressure", [.pressure])],
            [.checkbox("Sustain", [.sustain])],
            [.checkbox("Edits", [.edits])],
            [.checkbox("Pgm Ch", [.pgmChange])],
          ])
        ], effects: [
          .indexChange({ [.setCtrlLabel([.part], "\($0 + 1)")] })
        ])
      )
    }
  }

}
