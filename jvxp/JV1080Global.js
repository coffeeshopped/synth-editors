
extension JV1080 {
  
  enum Global {
    
    static let patchWerk = JVXP.Global.patchWerk(parms.params(), size: 0x28, initFile: "jv1080-global-init")

    static let parms: [Parm] = [
      // Switching to GM mode makes the synth stop responding to sysex!
      .p([.mode], 0x00, .opts(["Performance","Patch"])), //,"GM"])
      .p([.perf], 0x01),
      .p([.patch, .group], 0x02, .opts(["User","PCM","Exp"])),
      .p([.patch, .group, .id], 0x03),
      .p([.patch, .number], 0x04, .max(254)),
      .p([.tune], 0x06, .max(126)),
      .p([.scale, .tune], 0x07, .max(1)),
      .p([.fx], 0x08, .max(1)),
      .p([.chorus], 0x09, .max(1)),
      .p([.reverb], 0x0a, .max(1)),
      .p([.patch, .remain], 0x0b, .max(1)),
      .p([.clock], 0x0c, .opts(["Internal","Ext MIDI"])),
      .p([.tap], 0x0d, .opts(tapSourceOptions)),
      .p([.hold], 0x0e, .opts(tapSourceOptions)),
      .p([.peak], 0x0f, .opts(tapSourceOptions)),
      .p([.volume], 0x10, .opts(["Volume","Vol & Exp"])),
      .p([.aftertouch], 0x11, .opts(["Channel After", "Poly After", "Ch & Poly"])),
      .p([.ctrl, .i(0)], 0x12, .opts(systemControlOptions)),
      .p([.ctrl, .i(1)], 0x13, .opts(systemControlOptions)),
      .p([.rcv, .pgmChange], 0x14, .max(1)),
      .p([.rcv, .bank, .select], 0x15, .max(1)),
      .p([.rcv, .ctrl, .change], 0x16, .max(1)),
      .p([.rcv, .mod], 0x17, .max(1)),
      .p([.rcv, .volume], 0x18, .max(1)),
      .p([.rcv, .hold], 0x19, .max(1)),
      .p([.rcv, .bend], 0x1a, .max(1)),
      .p([.rcv, .aftertouch], 0x1b, .max(1)),
      .p([.ctrl, .channel], 0x1c, .opts(17.map { $0 == 16 ? "Off" : "\($0 + 1)" })),
      .p([.patch, .channel], 0x1d, .max(15, dispOff: 1)),
      .p([.rhythm, .edit], 0x1e, .opts(["Panel","Panel & MIDI"])),
      .p([.preview, .mode], 0x1f, .opts(["Single","Chord"])),
      .p([.preview, .key, .i(0)], 0x20),
      .p([.preview, .velo, .i(0)], 0x21),
      .p([.preview, .key, .i(1)], 0x22),
      .p([.preview, .velo, .i(1)], 0x23),
      .p([.preview, .key, .i(2)], 0x24),
      .p([.preview, .velo, .i(2)], 0x25),
      .p([.preview, .key, .i(3)], 0x26),
      .p([.preview, .velo, .i(3)], 0x27),
    ]
    static let params = parms.params()

    static let tapSourceOptions = ["Off","Hold-1","Sustain","Soft","Hold-2"]
    static let systemControlOptions = 96.map { "CC \($0)" } + ["Bender","Aftertouch"]  
  }
  
}
