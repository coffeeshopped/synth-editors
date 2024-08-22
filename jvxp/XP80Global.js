
extension XP80 {
  
  enum Global {
    
    static let patchWerk = JVXP.Global.patchWerk(parms.params(), size: 0x60, initFile: "xp80-global-init")
    
    static let parms = XP50.Global.parms + .inc(b: 0x52) { [
      .p([.pedal, .i(2), .assign], .options(XP50.Global.pedalAssignOptions)),
      .p([.pedal, .i(2), .out, .mode], .options(XP50.Global.ctrlOutModeOptions)),
      .p([.pedal, .i(2), .polarity], .options(XP50.Global.polarityOptions)),
      .p([.pedal, .i(3), .assign], .options(XP50.Global.pedalAssignOptions)),
      .p([.pedal, .i(3), .out, .mode], .options(XP50.Global.ctrlOutModeOptions)),
      .p([.pedal, .i(3), .polarity], .options(XP50.Global.polarityOptions)),
      .p([.arp, .style], .max(32, dispOff: 1)),
      .p([.arp, .motif], .max(33, dispOff: 1)),
      .p([.arp, .pattern], .max(60, dispOff: 1)),
      .p([.arp, .accent, .rate], .max(100)),
      .p([.arp, .shuffle, .rate], .rng(50...90)),
      .p([.arp, .key, .velo], .opts(XP50.Global.keyVeloOptions)),
      .p([.arp, .octave, .range], .max(3, dispOff: -3)),
      .p([.arp, .part, .number], .opts(16.map { "Part \($0+1)" })),
    ] }
    
  }
  
}
