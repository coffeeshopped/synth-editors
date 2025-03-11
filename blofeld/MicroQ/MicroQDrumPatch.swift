
struct MicroQDrumPatch : MicroQPatch, RhythmPatch {
    
  static let relatedBankType: SysexPatchBank.Type? = FnSingleBank<MicroQDrumBank>.self
  static let nameByteRange: CountableRange<Int>? = 368..<384
  static let initFileName: String = "microq-drum-init"
  static let fileDataCount: Int = 393
  
  static func bytes(data: Data) -> [UInt8] { data.safeBytes(7..<391) }
  
  static func sysexData(_ bytes: [UInt8], deviceId: UInt8, bank: UInt8, location: UInt8) -> MidiMessage {
    sysexData(bytes, deviceId: deviceId, dumpByte: 0x12, bank: bank, location: location)
  }
  
  static let paramOptions: [ParamOptions] =
    prefix([.part], count: 32, bx: 9) { _ in
      inc(b: 0) { [
        o([.bank], opts: banks),
        o([.number], max: 99, dispOff: 1),
        o([.out], opts: outs),
        o([.pan], dispOff: -64),
        o([.key], isoS: noteIso),
        o([.transpose], range: 4...124, dispOff: -64),
        o([.volume]),
      ] }
    }
    <<< fxParams(288)
    <<< arpParams(320)

  static let params = paramsFromOpts(paramOptions)
  
  static let banks = opts(["A", "B", "C"])
  static let outs = opts(["Main", "Sub1", "Sub2"])
  static let noteIso = Miso.noteName(zeroNote: "C-2")
}
