
extension Blofeld.Global {

  enum Controller {
    
    static let ctrlr: PatchController = .patch(color: 1, [
      .panel("device", [[
        .knob("Device ID", [.deviceId]),
        .knob("MIDI Channel", [.channel]),
        .checkbox("Auto Edit", [.autoEdit]),
        .knob("Popup Time", [.popup, .time]),
        .knob("Contrast", [.contrast]),
      ]]),
      .panel("tune", [[
        .knob("Master Tune", [.tune]),
        .knob("Transpose", [.transpose]),
        .switsch("Clock", [.clock]),
        .select("Velo Curve", [.velo, .curve]),
      ]]),
      .panel("ctrl", [[
        .switsch("Ctrl Send", [.ctrl, .send]),
        .checkbox("Ctrl Rcv", [.ctrl, .rcv]),
        .knob("Ctrl W", [.ctrl, .i(0)]),
        .knob("Ctrl X", [.ctrl, .i(1)]),
        .knob("Ctrl Y", [.ctrl, .i(2)]),
        .knob("Ctrl Z", [.ctrl, .i(3)]),
        ]])
    ], layout: [
      .simpleGrid([[("device", 1)], [("tune", 1)], [("ctrl", 1)]]),
    ])
    
  }

}
