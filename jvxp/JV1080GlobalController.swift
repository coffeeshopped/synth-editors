
extension JV1080.Global {
  
  static var controller: PatchController {
    return .patch(color: 1, [
      .panel("modes", [[
        .switsch([.mode]),
        .knob([.tune]),
        .checkbox([.scale, .tune]),
        .checkbox("FX", [.fx]),
        .checkbox([.chorus]),
        .checkbox([.reverb]),
        .checkbox([.patch, .remain]),
        .switsch("Clock Src", [.clock]),
        .switsch([.rhythm, .edit]),
      ]]),
      .panel("src", [[
        .select("Tap Ctrl", [.tap]),
        .select("Hold Ctrl", [.hold]),
        .select("Peak Ctrl", [.peak]),
        .switsch("Vol Ctrl", [.volume]),
        .switsch("Aftert Ctrl", [.aftertouch]),
        .knob("Ctrl 1", [.ctrl, .i(0)]),
        .knob("Ctrl 2", [.ctrl, .i(1)]),
        .knob([.ctrl, .channel]),
        .knob([.patch, .channel])]
        ]),
      .panel("rcv", [[
        .checkbox("Rcv PgmCh", [.rcv, .pgmChange]),
        .checkbox("Rcv Bank Sel", [.rcv, .bank, .select]),
        .checkbox("Rcv Ctrl Ch", [.rcv, .ctrl, .change]),
        .checkbox([.rcv, .mod]),
        .checkbox("Rcv Vol", [.rcv, .volume]),
        .checkbox([.rcv, .hold]),
        .checkbox([.rcv, .bend]),
        .checkbox("Rcv After", [.rcv, .aftertouch])]
        ]),
      .panel("prev", [[
        .switsch("Preview", [.preview, .mode]),
        .knob("Key 1", [.preview, .key, .i(0)]),
        .knob("Velo 1", [.preview, .velo, .i(0)]),
        .knob("Key 2", [.preview, .key, .i(1)]),
        .knob("Velo 2", [.preview, .velo, .i(1)]),
        .knob("Key 3", [.preview, .key, .i(2)]),
        .knob("Velo 3", [.preview, .velo, .i(2)]),
        .knob("Key 4", [.preview, .key, .i(3)]),
        .knob("Velo 4", [.preview, .velo, .i(3)])]
        ])
    ], layout: [
      .simpleGrid([
        [("modes",1)],
        [("src",1)],
        [("rcv",1)],
        [("prev",1)],
      ])
    ])
  }
}
