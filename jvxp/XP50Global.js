
extension XP50 {
  
  enum Global {
    
    static let patchWerk = JVXP.Global.patchWerk(params, size: 0x52, initFile: "xp50-global-init")
    
    static let parms = JV1080.Global.parms + [
      .p([.send, .pgmChange], 0x28, .max(1)),
      .p([.send, .bank, .select], 0x29, .max(1)),
      .p([.patch, .send, .channel], 0x2a, .opts(18.map {
        switch $0 {
        case 16: return "Rcv Channel"
        case 17: return "Off"
        default: return "\($0+1)"
        }
      })),
      .p([.transpose], 0x2b, .max(1)),
      .p([.transpose, .amt], 0x2c, .max(11, dispOff: -5)),
      .p([.octave, .shift], 0x2d, .max(6, dispOff: -3)),
      .p([.key, .velo], 0x2e, .opts(keyVeloOptions)),
      .p([.key, .sens], 0x2f, .opts(["Light","Stanard","Heavy"])),
      .p([.aftertouch, .sens], 0x30, .max(100)),
      .p([.pedal, .i(0), .assign], 0x31, .options(pedalAssignOptions)),
      .p([.pedal, .i(0), .out, .mode], 0x32, .options(ctrlOutModeOptions)),
      .p([.pedal, .i(0), .polarity], 0x33, .options(polarityOptions)),
      .p([.pedal, .i(1), .assign], 0x34, .options(pedalAssignOptions)),
      .p([.pedal, .i(1), .out, .mode], 0x35, .options(ctrlOutModeOptions)),
      .p([.pedal, .i(1), .polarity], 0x36, .options(polarityOptions)),
      .p([.ctrl, .i(0), .assign], 0x37, .options(ctrlAssignOptions)),
      .p([.ctrl, .i(0), .out, .mode], 0x38, .options(ctrlOutModeOptions)),
      .p([.ctrl, .i(1), .assign], 0x39, .options(ctrlAssignOptions)),
      .p([.ctrl, .i(1), .out, .mode], 0x3a, .options(ctrlOutModeOptions)),
      .p([.hold, .out, .mode], 0x3b, .options(ctrlOutModeOptions)),
      .p([.hold, .polarity], 0x3c, .options(polarityOptions)),
    ] + .prefix([.bank, .select], count: 7, bx: 3, block: { index, offset in
      [
        .p([.on], 0x3d, .max(1)),
        .p([.hi], 0x3e),
        .p([.lo], 0x3f),
      ]
    })
    static let params = parms.params()
    
    static let keyVeloOptions = 128.map { $0 == 0 ? "Real" : "\($0)" }
    static let pedalAssignOptions: [Int:String] = {
      var options = (0...95).map { "CC \($0)" }
      options += ["Bender","Aftertouch","Pgm Up","Pgm Down","Start/Stop","Punch In/Out","Tap Tempo"]
      return OptionsParam.makeOptions(options)
    }()
    
    static let ctrlOutModeOptions = OptionsParam.makeOptions(["Off","Int","MIDI","Int/MIDI"])
    
    static let ctrlAssignOptions: [Int:String] = {
      var options = (0...95).map { "CC \($0)" }
      options += ["Bender","Aftertouch"]
      return OptionsParam.makeOptions(options)
    }()
    
    static let polarityOptions = OptionsParam.makeOptions(["Standard","Reverse"])
  }
}
