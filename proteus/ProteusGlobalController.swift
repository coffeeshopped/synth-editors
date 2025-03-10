
extension Proteus.Global {
  
  enum Controller {

    static func ctrlr() -> PatchController {
      return .patch(color: 1, [
        .children(16, "midi", channel),
        .panel("device", [[
          .knob("Device ID", [.deviceId]),
        ]]),
        .panel("channel", [[
          .knob("Channel", [.channel]),
          .knob("Volume", [.volume]),
          .knob("Pan", [.pan]),
          .knob("Preset", [.preset]),
        ]]),
        .panel("tune", [[
          .knob("Master Tune", [.tune]),
          .knob("Transpose", [.transpose]),
          .knob("Bend Range", [.bend]),
          .knob("Velo Curve", [.velo, .curve]),
        ]]),
        .panel("mode", [[
          .switsch("MIDI Mode", [.midi, .mode]),
          .checkbox("Mode Change", [.mode, .change, .on]),
          .checkbox("Overflow", [.midi, .extra]),
        ]]),
        .panel("ctrl", [[
          .knob("Ctrl A", [.ctrl, .i(0)]),
          .knob("Ctrl B", [.ctrl, .i(1)]),
          .knob("Ctrl C", [.ctrl, .i(2)]),
          .knob("Ctrl D", [.ctrl, .i(3)]),
        ]]),
        .panel("foot", [[
          .knob("Foot 1", [.foot, .i(0)]),
          .knob("Foot 2", [.foot, .i(1)]),
          .knob("Foot 3", [.foot, .i(2)]),
        ]])
      ], effects: [
      ], layout: [
        .row([("device", 1), ("channel", 4), ("tune", 4), ("mode", 3)]),
        .row([("ctrl", 4), ("foot", 3)]),
        .row(16.map { ("midi\($0)", 1) }),
        .col([("device", 1), ("ctrl", 1), ("midi0", 3)]),
      ])
    }
    
    static let channel: PatchController = .index([], label: [.midi, .on], { "MIDI \($0 + 1)" }, [
      .grid([[
        .checkbox("MIDI Ch", [.midi, .on]),
      ],[
        .checkbox("Pgm Ch", [.pgmChange, .on]),
      ],[
        .switsch("Mix Out", [.mix]),
      ]])
    ])
    
  }
}
