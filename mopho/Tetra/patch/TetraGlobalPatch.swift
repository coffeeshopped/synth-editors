
struct TetraGlobalPatch : MophoGlobalTypePatch {
  
  static let fileDataCount = 47 // manual says 25 bytes but it looks like newer firmware added some.
  static let initFileName = "tetra-global-init"

  static func bytes(data: Data) -> [UInt8] {
    bytes(data: data, byteRange: 4..<46)
  }
  
  static func fileData(_ bytes: [UInt8]) -> [UInt8] {
    fileData(bytes, idByte: 0x26)
  }
  
  static let paramOptions: [ParamOptions] =
    [
      o([.semitone], 0,  p: 384, max: 24, dispOff: -12),
      o([.detune], 1, p: 385, max: 100, dispOff: -50),
      o([.channel], 2, p: 386, max: 16, isoS: channelIso),
      o([.clock], 3, p: 388, optArray: ["Internal", "V1 Master", "MIDI Out", "MIDI In", "MIDI In/Out"]),
      o([.param, .send], 4, p: 390, optArray: ["NRPN","CC","Off"]),
      o([.param, .rcv], 5, p: 391, optArray: ["All","NRPN only","CC only", "Off"]),
//      o([.ctrl], 6, p: 394, max: 1),
//      o([.sysex], 7, p: 395, max: 1),
      o([.midi, .out], 8, p: 406, optArray: ["MIDI Out","MIDI Thru"]),
      o([.chain], 9, p: 387, optArray: ["Off", "Out 1", "Out 4", "Out 8", "Out 12", "In End", "InOut4", "InOut8"]),
      o([.multi], 10, p: 407, max: 1),
      o([.local], 11, p: 389, max: 1),
//      o([.mode, .lock], 12, optArray: ["Off", "Prog", "Combo"]),
      o([.out], 13, p: 400, optArray: ["Stereo","Mono", "Quad", "Q LR34"]),
      o([.knob], 14, p: 404, optArray: ["Relative", "Passthru", "Jump"]),
    ]
//    <<< inc(b: 15, p: 403) {[
//      o([.balance, .i(0)], max: 28, dispOff: -14),
//      o([.balance, .i(1)], max: 28, dispOff: -14),
//      o([.balance, .i(2)], max: 28, dispOff: -14),
//      o([.balance, .i(3)], max: 28, dispOff: -14),
//    ]}
    <<< [
//      o([.pgmChange], 19, optArray: ["Enable", "Disable"]),
      o([.arp, .latch], 20, p: 416, optArray: ["Normal", "ReLatch"]),
    ]

  static let params: SynthPathParam = paramsFromOpts(paramOptions)
  
  static let channelIso = Miso.switcher([
    .int(0, "Omni"),
    .range(1...16, Miso.str()),
  ])
}

