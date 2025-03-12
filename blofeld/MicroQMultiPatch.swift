
struct MicroQMultiPatch : MicroQPatch, PerfPatch {
    
  static let relatedBankType: SysexPatchBank.Type? = FnSingleBank<MicroQMultiBank>.self
  static let nameByteRange: CountableRange<Int>? = 16..<32
  static let initFileName: String = "microq-multi-init"
  static let fileDataCount: Int = 393
  
  static func bytes(data: Data) -> [UInt8] { data.safeBytes(7..<391) }
  
  static func sysexData(_ bytes: [UInt8], deviceId: UInt8, bank: UInt8, location: UInt8) -> MidiMessage {
    sysexData(bytes, deviceId: deviceId, dumpByte: 0x11, bank: bank, location: location)
  }
  
  static let paramOptions: [ParamOptions] =
    [
      o([.volume], 0, range: 1...127),
    ]
    <<< prefix([.ctrl], count: 4, bx: 1) { _ in [
      o([], 1, max: 121, isoS: ctrlIso),
    ]}
    <<< prefix([.part], count: 16, bx: 22) { _ in
      inc(b: 32) { [
        o([.bank], p: -1, opts: banks),
        o([.number], p: -1, max: 99, dispOff: 1),
        o([.channel], max: 17, isoS: channelIso),
        o([.volume]),
        o([.transpose], range: 16...112, dispOff: -64),
        o([.detune], dispOff: -64),
        o([.out], opts: outs),
        o([.on], opts: status),
        o([.pan], dispOff: -64),
      ] }
      <<< inc(b: 44) { [
        o([.velo, .lo], range: 1...127),
        o([.velo, .hi], range: 1...127),
        o([.key, .lo], isoS: noteIso),
        o([.key, .hi], isoS: noteIso),
      ] }
    }
  
  static let params = paramsFromOpts(paramOptions)
  
  static let banks = [
    0 : "A",
    1 : "B",
    2 : "C",
    4 : "D",
  ]
  
  static let ctrlIso = Miso.switcher([.int(121, "Global")], default: Miso.str())
  
  static let channelIso = Miso.switcher([
    .int(0, "Global"),
    .int(1, "Omni"),
  ], default: Miso.a(-1) >>> Miso.str())
  
  static let outs = opts(["Main", "Sub1", "Sub2", "FX1", "FX2", "FX3", "FX4", "Aux"])
  
  static let status = opts(["Off", "Midi"])
  
  static let patternIso = Miso.switcher([.int(0, "Off")], default: Miso.str())
  static let noteIso = Miso.noteName(zeroNote: "C-2")
}
