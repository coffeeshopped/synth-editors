
class Deepmind12ArpPatch : ByteBackedSysexPatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = Deepmind12ArpBank.self
  static func location(forData data: Data) -> Int { return Int(data[8]) }

  static let initFileName = "deepmind12-arp-init"
  static let fileDataCount = 90
    
  var bytes: [UInt8]
  var name = ""
  
  required init(data: Data) {
    let range = data.count == 89 ? 8..<88 : 9..<89
    bytes = data.unpack87(count: 65, inRange: range)
  }
  
  // 74 is edit buffer, 75 is stored program
  static func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, 89].contains(fileSize)
  }
  
  private func sysexData(channel: Int, headerBytes: [UInt8]) -> Data {
    var data = Data(Deepmind12.sysexHeader(deviceId: UInt8(channel)))
    data.append(contentsOf: headerBytes)
    data.append(Data.pack78(bytes: bytes, count: 80))
    data.append(0xf7)
    return data
  }
  
  /// Edit buffer sysex
  func sysexData(channel: Int) -> Data {
    return sysexData(channel: channel, headerBytes: [0x0f, 0x07])
  }
  
  func sysexData(channel: Int, program: Int) -> Data {
    return sysexData(channel: channel, headerBytes: [0x08, 0x07, UInt8(program)])
  }

  func fileData() -> Data {
    return sysexData(channel: 0)
  }

  func randomize() {
    randomizeAllParams()
//
//    self[[.extra]] = 0
//    self[[.micro, .tune]] = 0
//    self[[.arp, .on]] = 0
  }

    
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    p[[.length]] = RangeParam(byte: 0, maxVal: 31, displayOffset: 1)
    (0..<32).forEach {
      p[[.i($0), .velo]]  = RangeParam(byte: $0 + 1, maxVal: 128)
      p[[.i($0), .gate]]  = MisoParam.make(byte: $0 + 33, maxVal: 128, iso: Miso.switcher([
        .int(128, "Tie")
      ], default: Miso.str()))
    }
    return p
  }()
  
}
