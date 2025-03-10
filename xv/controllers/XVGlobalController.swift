
extension XV {
  
  enum Global {
    
    enum Controller {
      
      static func controller5050() -> PatchController {
        return .patch([
          .child(common(), "common"),
          .child(eq(count: 4), "eq"),
        ], effects: [
        ], layout: [
          .grid([
            (row: [("common", 1)], height: 4),
            (row: [("eq", 1)], height: 2),
          ])
        ])
      }

      static func controller2020() -> PatchController {
        return .patch([
          .child(common(), "common"),
        ], effects: [
        ], layout: [
          .simpleGrid([[("common", 1)]])
        ])
      }
      
      static func controller3080() -> PatchController {
        return .patch([
          .child(common3080(), "common"),
          .child(part(count: 16), "part"),
        ], effects: [
        ], layout: [
          .row([("common",1)]),
          .row([("part",1)]),
          .col([("common",2), ("part",4)]),
        ])
      }
      
      static func controller5080() -> PatchController {
        return .patch([
          .child(common3080(), "common"),
          .child(eq(count: 8), "eq"),
          .child(part(count: 32), "part"),
        ], effects: [
        ], layout: [
          .row([("common",1)]),
          .row([("eq",1)]),
          .row([("part",1)]),
          .col([("common",2), ("eq", 2), ("part",3)]),
        ])
      }

      static func common() -> PatchController {
        return .patch(prefix: .fixed([.common]), color: 1, [
          .panel("tune", [[
            .knob("Tune", [.tune]),
            .knob("Key Shift", [.key, .shift]),
            .knob("Level", [.level]),
            .checkbox("Patch Remain", [.patch, .remain]),
            .switsch("Mix/Para", [.mix]),
            .knob("Perf Ctrl Chan", [.perf, .channel]),
            .knob("Patch Chan", [.patch, .channel]),
            ],[
            .knob("Ctrl 1", [.ctrl, .i(0), .src]),
            .knob("Ctrl 2", [.ctrl, .i(1), .src]),
            .knob("Ctrl 3", [.ctrl, .i(2), .src]),
            .knob("Ctrl 4", [.ctrl, .i(3), .src]),
            .checkbox("Rx Pgm Ch", [.rcv, .pgmChange]),
            .checkbox("Rx Bank Sel", [.rcv, .bank]),
            .switsch("Clock Src", [.clock, .src]),
            .knob("Tempo", [.tempo]),
            ]]),
          .panel("scaleSwitch", [[
            .checkbox("Scale Tune", [.scale, .tune]),
            ]]),
          .panel("scale", [[
            .knob("C", [.scale, .tune, .i(0)]),
            .knob("C#", [.scale, .tune, .i(1)]),
            .knob("D", [.scale, .tune, .i(2)]),
            .knob("D#", [.scale, .tune, .i(3)]),
            .knob("E", [.scale, .tune, .i(4)]),
            .knob("F", [.scale, .tune, .i(5)]),
            ],[
            .knob("F#", [.scale, .tune, .i(6)]),
            .knob("G", [.scale, .tune, .i(7)]),
            .knob("G#", [.scale, .tune, .i(8)]),
            .knob("A", [.scale, .tune, .i(9)]),
            .knob("A#", [.scale, .tune, .i(10)]),
            .knob("B", [.scale, .tune, .i(11)]),
            ]]),
        ], effects: [
        ], layout: [
          .simpleGrid([
            [("tune",1)],
            [("scaleSwitch",1), ("scale",6)],
          ])
        ])
      }
      
      static func common3080() -> PatchController {
        return .patch(prefix: .fixed([.common]), [
          .grid(color: 1, [[
            .switsch("Mode", [.mode]),
            .knob("Tune", [.tune]),
            .knob("Key Shift", [.key, .shift]),
            .knob("Level", [.level]),
            .checkbox("Scale Tune", [.scale, .tune]),
            .checkbox("Patch Remain", [.patch, .remain]),
            .switsch("Mix/Para", [.mix]),
            .checkbox("MFX", [.fx]),
            .checkbox("Chorus", [.chorus]),
            .checkbox("Reverb", [.reverb]),
            ],[
            .knob("Perf Ctrl Chan", [.perf, .channel]),
            .knob("Patch Chan", [.patch, .channel]),
            .knob("Ctrl 1", [.ctrl, .i(0), .src]),
            .knob("Ctrl 2", [.ctrl, .i(1), .src]),
            .knob("Ctrl 3", [.ctrl, .i(2), .src]),
            .knob("Ctrl 4", [.ctrl, .i(3), .src]),
            .checkbox("Rx Pgm Ch", [.rcv, .pgmChange]),
            .checkbox("Rx Bank Sel", [.rcv, .bank]),
            .switsch("Clock Src", [.clock, .src]),
            .knob("Tempo", [.tempo]),
            ]])
        ])
      }
      
      static func eq(count: Int) -> PatchController {
        .patch(prefix: .fixed([.eq]), [
          .children(count, "eq", eqSub()),
          .panel("switch", color: 1, [[
            .checkbox("EQ On", [.on]),
          ]]),
          .panel("space", [[]]),
        ], effects: [
          .dimsOn([.on], id: nil),
        ], layout: [
          .simpleGrid([
            [("switch", 1)] + (0..<(count/2)).map { ("eq\($0)", 4) },
            [("space", 1)] + ((count/2)..<count).map { ("eq\($0)", 4) },
          ])
        ])
      }
      
      static func eqSub() -> PatchController {
        .index([], label: [.lo, .freq], { "EQ \($0 + 1) Lo Freq" }, [
          .grid(color: 1, [[
            .switsch("Lo Freq", [.lo, .freq]),
            .knob("Lo Gain", [.lo, .gain]),
            .switsch("Hi Freq", [.hi, .freq]),
            .knob("Hi Gain", [.hi, .gain]),
          ]])
        ])
      }
      
      static func part(count: Int) -> PatchController {
        .patch(prefix: .index([.part]), border: 2, [
          .switcher(label: "Part Scale", count.map { "\($0 + 1)" }, cols: count / 2, color: 2),
          .panel("scale", prefix: [.scale, .tune], color: 2, [[
            .knob("C", [.i(0)]),
            .knob("C#", [.i(1)]),
            .knob("D", [.i(2)]),
            .knob("D#", [.i(3)]),
            .knob("E", [.i(4)]),
            .knob("F", [.i(5)]),
            ],[
            .knob("F#", [.i(6)]),
            .knob("G", [.i(7)]),
            .knob("G#", [.i(8)]),
            .knob("A", [.i(9)]),
            .knob("A#", [.i(10)]),
            .knob("B", [.i(11)]),
            ]]),
        ], layout: [
          .simpleGrid([
            [("switch",1)],
            [("scale",1)],
          ]),
        ])
      }
      
    }
    
  }
}
