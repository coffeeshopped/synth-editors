
extension JV880.Global {
  
  enum Controller {
    
    static func ctrlr() -> PatchController {
      return .patch(color: 1, [
        .child(scale(), "scale"),
        .panel("mode", [[
          .switsch("Mode", [.mode]),
          .knob("Tune", [.tune]),
        ]]),
        .panel("fx", [[
          .checkbox("Reverb", [.reverb]),
          .checkbox("Chorus", [.chorus]),
        ]]),
        .panel("rx", [[
          .checkbox("RX Volume", [.rcv, .volume]),
          .checkbox("CC", [.rcv, .ctrl, .change]),
          .checkbox("Ch Press", [.rcv, .aftertouch]),
          .checkbox("Mod", [.rcv, .mod]),
          .checkbox("Bend", [.rcv, .bend]),
          .checkbox("Pgm Ch", [.rcv, .pgmChange]),
          .checkbox("Bank Sel", [.rcv, .bank, .select]),
          .knob("Patch Channel", [.patch, .channel]),
        ]]),
        .panel("etc", [[
          .knob("Ctrl Chan", [.ctrl, .channel]),
          .switsch("Out Mode", [.out, .mode]),
          .switsch("Rhythm Edit K", [.rhythm, .edit, .key]),
        ]]),
        .panel("scaleSwitch", [[
          .checkbox("Scale Tune", [.scale, .tune]),
        ]]),
      ], effects: [
      ], layout: [
        .row([("mode",4), ("fx",2), ("etc",3)]),
        .row([("rx",8)]),
        .row([("scaleSwitch",1), ("scale",12)]),
        .col([("mode",1), ("rx",1), ("scaleSwitch",2)]),
      ])
    }
    
    static func scale() -> PatchController {
      return .patch(prefix: .indexFn({ [.scale, .tune, $0 == 0 ? .patch : .i($0 - 1)] }), [
        .grid([[
          .switcher(label: "Scale Part", ["Patch", "1", "2", "3", "4", "5", "6", "7", "8"]),
        ],[
          .knob("C", [.note, .i(0)]),
          .knob("C#", [.note, .i(1)]),
          .knob("D", [.note, .i(2)]),
          .knob("D#", [.note, .i(3)]),
          .knob("E", [.note, .i(4)]),
          .knob("F", [.note, .i(5)]),
          .knob("F#", [.note, .i(6)]),
          .knob("G", [.note, .i(7)]),
          .knob("G#", [.note, .i(8)]),
          .knob("A", [.note, .i(9)]),
          .knob("A#", [.note, .i(10)]),
          .knob("B", [.note, .i(11)]),
        ]])
      ])
    }

  }
  
}
