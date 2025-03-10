
class VirusCGlobalPatch : ByteBackedSysexPatch, GlobalPatch {
    
  static let initFileName = "virusc-global-init"
  static let fileDataCount = 267

  var bytes: [UInt8]

  required init(data: Data) {
    bytes = [UInt8](data.safeBytes(9..<265))
  }
    
  func sysexData(deviceId: UInt8) -> Data {
    var data = Data(VirusTI.sysexHeader)
    // the 01 66 are just in the dump I got from the synth... dunno if they're right
    var b1 = [deviceId, 0x12, 0x01, 0x66] // these are included in checksum
    b1.append(contentsOf: bytes)
    data.append(contentsOf: b1)
    
    let checksum = b1.map{ Int($0) }.reduce(0, +) & 0x7f
    data.append(UInt8(checksum))
    
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data { return sysexData(deviceId: 16) }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()

    p[[.alt, .out]] = MisoParam.make(byte: 45, options: ["Off"] + VirusCMultiPatch.outOptions)
    p[[.key, .transpose, .ctrl]] = MisoParam.make(byte: 63, options: ["Patch", "Keyb"])
    p[[.key, .local]] = RangeParam(byte: 64, maxVal: 1)
    p[[.key, .mode]] = MisoParam.make(byte: 65, options: ["1 Chan", "Multi Chan"])
    p[[.key, .transpose]] = RangeParam(byte: 66, displayOffset: -64)
    p[[.key, .modWheel]] = MisoParam.make(byte: 67, options: keyDests)
    p[[.key, .pedal, .i(0)]] = MisoParam.make(byte: 68, options: keyDests)
    p[[.key, .pedal, .i(1)]] = MisoParam.make(byte: 69, options: keyDests)
    p[[.key, .pressure, .sens]] = MisoParam.make(byte: 70, iso: keyPressIso)
    p[[.tune, .mode]] = MisoParam.make(byte: 76, iso: tuneModeIso)
    p[[.global, .pgmChange, .on]] = RangeParam(byte: 85, maxVal: 1)
    p[[.multi, .pgmChange, .on]] = RangeParam(byte: 86, maxVal: 1)
    p[[.global, .volume, .on]] = RangeParam(byte: 87, maxVal: 1) // global midi volume ena
    p[[.input, .level]] = RangeParam(byte: 90)
    p[[.input, .booster]] = RangeParam(byte: 91)
    p[[.tune]] = RangeParam(byte: 92, displayOffset: -64)
    p[[.deviceId]] = RangeParam(byte: 93, maxVal: 15, displayOffset: 1) // 16 = Omni but ctrl shouldn't allow selecting that
    p[[.midi, .part, .lo]] = MisoParam.make(byte: 94, options: ["Sysex", "Ctrl"])
    p[[.midi, .part, .hi]] = MisoParam.make(byte: 95, options: ["Sysex", "PolyPrs"])
    p[[.midi, .arp]] = RangeParam(byte: 96, maxVal: 1)
    p[[.knob, .vib]] = OptionsParam(byte: 97, options: [
                                      0: "Off",
                                      7: "Short",
                                      66: "Long",
                                      127: "On"]) // knob display
//    p[[.multi, .pgmChange]] = RangeParam(byte: 0)
    p[[.midi, .clock, .rcv]] = MisoParam.make(byte: 106, options: ["Disable", "Auto", "Send"])
    p[[.knob, .i(0), .mode]] = MisoParam.make(byte: 110, options: ["Single", "Global", "MIDI"])
    p[[.knob, .i(1), .mode]] = MisoParam.make(byte: 111, options: ["Single", "Global", "MIDI"])
    p[[.knob, .i(0), .global]] = MisoParam.make(byte: 112, options: VirusCVoicePatch.knobOptions)
    p[[.knob, .i(1), .global]] = MisoParam.make(byte: 113, options: VirusCVoicePatch.knobOptions)
    p[[.knob, .i(0), .midi]] = RangeParam(byte: 114)
    p[[.knob, .i(1), .midi]] = RangeParam(byte: 115)
    p[[.extra, .mode]] = MisoParam.make(byte: 116, options: ["Off", "On", "All"]) // expert mode
    p[[.knob, .mode]] = MisoParam.make(byte: 117, options: ["Off", "Jump", "iSnap", "Snap", "iRel", "Rel"])
    p[[.memory, .protect]] = MisoParam.make(byte: 118, options: ["Off", "On", "Warn"])
    p[[.thru]] = RangeParam(byte: 120, maxVal: 1)
    p[[.ctrl, .dest]] = MisoParam.make(byte: 121, options: ["Int", "Int+MIDI", "MIDI"]) // panel dest

    p[[.play, .mode]] = MisoParam.make(byte: 122, options: ["Single", "MultiSing", "Multi"])
    p[[.channel]] = RangeParam(byte: 124, maxVal: 15, displayOffset: 1)
    p[[.light, .mode]] = MisoParam.make(byte: 125, options: ["LFO", "Input", "Auto"])
    p[[.contrast]] = RangeParam(byte: 126)
    p[[.volume]] = RangeParam(byte: 127)

    return p
  }()
  
  class var params: SynthPathParam { return _params }
  
  static let keyDests = ["Off"] + (1..<128).map { "\($0)" }
  
  static let keyPressIso = Miso.switcher([
    .int(0, "Off")
  ], default: Miso.str())
  
  static let tuneModeIso = Miso.switcher([
    .int(0, "Temper"),
    .int(64, "Natural"),
    .int(127, "Pure")
  ], default: Miso.str())

}
