
class EvolverGlobalPatch : ByteBackedSysexPatch, GlobalPatch {
  
  class var initFileName: String { return "evolver-global-init" }
  class var fileDataCount: Int { return 38 }
  class var actualDataByteCount: Int { return 16 }
  
  var bytes: [UInt8]
  var name = ""

  required init(data: Data) {
    bytes = [UInt8]()
    let nibbles = [UInt8](data[5..<(data.count-1)])
    let bc = type(of: self).actualDataByteCount
    bytes = (0..<bc).map { return nibbles[2 * $0] + (nibbles[2 * $0 + 1] << 4) as UInt8 }
  }
  
  var sysexHeader: Data {
    return Data([0xf0, 0x01, 0x20, 0x01, 0x0f])
  }
  
  func fileData() -> Data {
    var data = sysexHeader
    (0..<(type(of: self).actualDataByteCount)).forEach {
      data.append(bytes[$0] & 0x7f)
      data.append((bytes[$0] >> 7) & 0x7f)
    }
    data.append(0xf7)
    return data
  }
  
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.pgm]] = RangeParam(byte: 0, displayOffset: 1)
    p[[.bank]] = RangeParam(byte: 1, maxVal: 3, displayOffset: 1)
    p[[.volume]] = RangeParam(byte: 2, maxVal: 100)
    p[[.transpose]] = RangeParam(byte: 3, maxVal: 72, displayOffset: -36)
    p[[.tempo]] = RangeParam(byte: 4, range: 30...250)
    p[[.clock, .divide]] = OptionsParam(byte: 5, options: EvolverVoicePatch.clockDivOptions)
    p[[.pgm, .tempo]] = RangeParam(byte: 6, maxVal: 1)
    p[[.midi, .clock]] = OptionsParam(byte: 7, options: [
      0: "Internal",
      1: "MIDI Out",
      2: "MIDI In",
      3: "MIDI In/Out",
      6: "MIDI In, no Start/Stop"])
    p[[.lock, .seq]] = RangeParam(byte: 8, maxVal: 1)
    p[[.poly, .chain]] = OptionsParam(byte: 9, options: ["Normal", "Echo All", "Echo Notes"])
    p[[.input, .gain]] = RangeParam(byte: 10, maxVal: 8, formatter: { "+\(3 * $0)" })
    p[[.fine]] = RangeParam(byte: 11, maxVal: 100, displayOffset: -50)
    p[[.midi, .rcv]] = OptionsParam(byte: 12, options: ["Off", "All", "Pgm Ch Only", "Params Only"])
    p[[.midi, .send]] = OptionsParam(byte: 13, options: ["Off", "All", "Pgm Ch Only", "Params Only"])
    p[[.channel]] = RangeParam(byte: 14, maxVal: 16, formatter: {
      $0 == 0 ? "Omni" : "\($0)"
    })
    
    return p
  }()
  
  class var params: SynthPathParam { return _params }
}

