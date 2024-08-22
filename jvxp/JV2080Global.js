
extension JV2080 {
  
  enum Global {
    
    static let patchWerk = JVXP.Global.patchWerk(parms.params(), size: 0x62, initFile: "jv2080-global-init")
    
    static let parms = XP80.Global.parms + [
      .p([.system, .tempo], 0x60, packIso: JVXP.multiPack(0x60), .rng(20...250)),
    ]

  }
  
}
