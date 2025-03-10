
struct MophoKeyGlobalPatch : MophoGlobalTypePatch {
  
  static let fileDataCount = 47
  static let initFileName = "mopho-key-global-init"

  static func bytes(data: Data) -> [UInt8] {
    bytes(data: data, byteRange: 4..<46)
  }
  
  static func fileData(_ bytes: [UInt8]) -> [UInt8] {
    fileData(bytes, idByte: 0x27)
  }
  
  static let paramOptions: [ParamOptions] =
    inc(b: 0) {[
      o([.semitone], p: 384, max: 24, dispOff: -12),
      o([.detune], p: 385, max: 100, dispOff: -50),
      o([.channel], p: 386, isoS: MophoGlobalPatch.channelIso),
      o([.clock], p: 388, optArray: ["Internal","MIDI Out", "MIDI In", "MIDI In/Out"]),
      o([.param, .send], p: 390, optArray: ["NRPN","CC","Off"]),
      o([.param, .rcv], p: 391, optArray: ["All","NRPN only","CC only", "Off"]),
      o([.ctrl], p: 394, max: 1),
      o([.sysex], p: 395, max: 1),
      o([.midi, .out], p: 406, optArray: ["MIDI Out","MIDI Thru"]),
      o([.poly, .chain], p: 387, optArray: ["Off", "Out 1", "Out 4", "Out 5", "Out 8", "Out 12", "Out 16"]),
      o([.local], p: 389, max: 1),
      o([.out], p: 400, optArray: ["Stereo","Mono"]),
      o([.knob, .mode], p: 404, optArray: ["Relative", "PassThru", "Jump"]),
      o([.redamper, .polarity], p: 397, optArray: ["Sus (open)", "Sus (close)", "Arp (open)", "Arp (close)"]),
      o([.pedal, .dest], p: 396, optArray: ["Foot", "Breath", "Expression", "Volume", "Filter Freq", "Filter Freq/2"]),
      o([.midi, .pressure], p: 393, max: 1),
      o([.pressure, .curve], p: 399, max: 3),
      o([.velo, .curve], p: 398, max: 3),
      o([.balance], p: 403, max: 28),
    ]}
  
  static let params: SynthPathParam = paramsFromOpts(paramOptions)
}
