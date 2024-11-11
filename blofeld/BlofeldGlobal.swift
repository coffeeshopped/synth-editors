
extension Blofeld {

  struct Global {
    typealias P = PatchTrussWerk

    static let patchTruss = createPatchTruss("Global", 73, initFile: "blofeld-global-init", params: paramOptions, parseOffset: 5, dumpByte: dumpByte, hasBankAndLocation: false)

    static let broadcastDeviceId = 0x7f
    static let dumpByte: UInt8 = 0x14
        
    static let paramOptions: [ParamOptions] = [
      P.o([.perf], 1, max: 1),
      P.o([.autoEdit], 35, max: 1),
      P.o([.channel], 36, max: 16, isoS: channelIso),
      P.o([.deviceId], 37, range: 0...126),
      P.o([.popup, .time], 38),
      P.o([.contrast], 39),
      P.o([.tune], 40, range: 54...74, dispOff: 376),
      P.o([.transpose], 41, range: 52...76, dispOff: -64),
      P.o([.ctrl, .send], 44, optArray: ["off","Ctrl","SysEx","Ctrl+SysEx"]),
      P.o([.ctrl, .rcv], 45, range: 0...1),
      P.o([.clock], 48, optArray: ["Auto","Internal"]),
      P.o([.velo, .curve], 50, optArray: ["linear","square","cubic","exponential","root","fix32","fix64","fix100","fix127"]),
      P.o([.ctrl, .i(0)], 51, max: 120),
      P.o([.ctrl, .i(1)], 52, max: 120),
      P.o([.ctrl, .i(2)], 53, max: 120),
      P.o([.ctrl, .i(3)], 54, max: 120),
      P.o([.volume], 55),
      P.o([.category], 56, max: 13),
    ]
    
    static let channelIso = Miso.switcher([
      .int(0, "Omni"),
    ], default: Miso.str())
    
  }

}
