
extension JV1010 {
  
  enum Global {
    static let patchWerk = JVXP.Global.patchWerk(parms.params(), size: 0x66, initFile: "jv1010-global-init")
    
    static let parms = JV2080.Global.parms + [
      .p([.ctrl, .i(2), .assign], 0x62, .options(XP50.Global.ctrlAssignOptions)),
      .p([.ctrl, .i(2), .out, .mode], 0x63, .options(XP50.Global.ctrlOutModeOptions)),
      .p([.ctrl, .i(3), .assign], 0x64, .options(XP50.Global.ctrlAssignOptions)),
      .p([.ctrl, .i(3), .out, .mode], 0x65, .options(XP50.Global.ctrlOutModeOptions)),
    ]
  }
}
