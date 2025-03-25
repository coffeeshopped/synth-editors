
extension JV80 {
  
  enum Global {
    
    static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Global", parms.params(), size: 0x21, start: 0x00000000, initFile: "jv880-global")
    
    static let parms: [Parm] = [
      // Switching to GM mode makes the synth stop responding to sysex!
      .p([.mode], 0x00, .opts(["Performance","Patch"])), //,"GM"])
      .p([.tune], 0x01, .rng(1...127, dispOff: -64)),
      .p([.key, .transpose], 0x02, .rng(28...100, dispOff: -64)),
      .p([.transpose], 0x03, .max(1)),
      .p([.reverb], 0x04, .max(1)),
      .p([.chorus], 0x05, .max(1)),
      .p([.hold, .polarity], 0x06, .opts(polarityOptions)),
      .p([.pedal, .i(0), .polarity], 0x07, .opts(polarityOptions)),
      .p([.pedal, .i(0), .mode], 0x08, .opts(pedalModeOptions)),
      .p([.pedal, .i(0), .assign], 0x09, .opts(pedalAssigns)),
      .p([.pedal, .i(1), .polarity], 0x0a, .opts(polarityOptions)),
      .p([.pedal, .i(1), .mode], 0x0b, .opts(pedalModeOptions)),
      .p([.pedal, .i(1), .assign], 0x0c, .opts(pedalAssigns)),
      .p([.ctrl, .mode], 0x0d, .opts(pedalModeOptions)),
      .p([.ctrl, .assign], 0x0e, .opts(pedalAssigns)),
      .p([.aftertouch, .threshold], 0x0f),

      .p([.rcv, .volume], 0x10, .max(1)),
      .p([.rcv, .ctrl, .change], 0x11, .max(1)),
      .p([.rcv, .aftertouch], 0x12, .max(1)),
      .p([.rcv, .mod], 0x13, .max(1)),
      .p([.rcv, .bend], 0x14, .max(1)),
      .p([.rcv, .pgmChange], 0x15, .max(1)),
      .p([.rcv, .bank, .select], 0x16, .max(1)),

      .p([.send, .volume], 0x17, .max(1)),
      .p([.send, .ctrl, .change], 0x18, .max(1)),
      .p([.send, .aftertouch], 0x19, .max(1)),
      .p([.send, .mod], 0x1a, .max(1)),
      .p([.send, .bend], 0x1b, .max(1)),
      .p([.send, .pgmChange], 0x1c, .max(1)),
      .p([.send, .bank, .select], 0x1d, .max(1)),

      .p([.patch, .channel], 0x1e, .max(15, dispOff: 1)),
      .p([.patch, .send, .channel], 0x1f, .opts(sendChannelOptions)),
      .p([.ctrl, .channel], 0x20, .opts(17.map { $0 == 16 ? "Off" : "\($0+1)" })),
    ]
    
    static let polarityOptions = ["Standard", "Reverse"]
    
    static let pedalModeOptions = ["Off","Int","MIDI","Int+MIDI"]
    
    static let pedalAssigns = 96.map { "CC\($0)" } + ["Aftertouch", "Bend Up", "Bend Down", "Pgm Up", "Pgm Down"]

    static let sendChannelOptions = 16.map { "\($0 + 1)" } + ["Rx Ch", "Off"]
  }
}
