
protocol MophoGlobalTypePatch : SinglePatchTemplate, GlobalPatch { }

extension MophoGlobalTypePatch {
  static var nameByteRange: CountableRange<Int>? { nil }
  static var relatedBankType: SysexPatchBank.Type? { nil }
  
  static func bytes(data: Data, byteRange: Range<Int>) -> [UInt8] {
    let nibbles = data.safeBytes(byteRange)
    return (0..<(byteRange.count / 2)).map { nibbles[2 * $0] + (nibbles[2 * $0 + 1] << 4) as UInt8 }
  }

  static func fileData(_ bytes: [UInt8], idByte: UInt8) -> [UInt8] {
    var data = [0xf0, 0x01, idByte, 0x0f]
    data.append(contentsOf: bytes.flatMap { [$0 & 0x0f, ($0 >> 4) & 0x0f] })
    data.append(0xf7)
    return data
  }

}

struct MophoGlobalPatch : MophoGlobalTypePatch {
  
  static let fileDataCount = 31 // manual says 25 bytes but it looks like newer firmware added some.
  static let initFileName = "mopho-global-init"

  static func bytes(data: Data) -> [UInt8] {
    bytes(data: data, byteRange: 4..<30)
  }
  
  static func fileData(_ bytes: [UInt8]) -> [UInt8] {
    fileData(bytes, idByte: 0x25)
  }
  
  static let paramOptions: [ParamOptions] =
    inc(b: 0) {[
      o([.semitone], p: 384, max: 24, dispOff: -12),
      o([.detune], p: 385, max: 100, dispOff: -50),
      o([.channel], p: 386, max: 16, isoS: channelIso),
      o([.clock], p: 388, optArray: ["Internal","MIDI Out", "MIDI In", "MIDI In/Out"]),
      o([.param, .send], p: 390, optArray: ["NRPN","CC","Off"]),
      o([.param, .rcv], p: 391, optArray: ["All","NRPN only","CC only", "Off"]),
      o([.ctrl], p: 394, max: 1),
      o([.sysex], p: 395, max: 1),
      o([.out], p: 405, optArray: ["Stereo","Mono"]),
      o([.midi, .out], p: 406, optArray: ["MIDI Out","MIDI Thru"]),
    ]}

  static let params: SynthPathParam = paramsFromOpts(paramOptions)
  
  static let channelIso = Miso.switcher([
    .int(0, "Omni"),
    .range(1...16, Miso.str()),
  ])
}

