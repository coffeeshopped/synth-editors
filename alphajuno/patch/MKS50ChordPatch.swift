
class MKS50ChordPatch : ByteBackedSysexPatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = MKS50ChordBank.self
  static func location(forData data: Data) -> Int {
    return Int(data[8]) // this is the general block location, not specific patch
  }

  // 14 bytes - 3.1.3 All Params // transmitted when patch change on synth
  // 12 bytes - 3.2.3 Bulk Dump: an entire bulk dump has 16 patches. The 12 bytes will be just the data bytes for 1 chord (as nibbles)
  // 45 - 31 patch bytes then 14 chord bytes
  
  // internal PB bytes are in 3.2.3 format (BULK)
  // 6 bytes
  
  static let fileDataCount = 14
  // TODO: need actual init file
  static let initFileName = "mks50-chord-init"

  var bytes: [UInt8]
  var name = ""

  static func isValid(fileSize: Int) -> Bool {
    return [14,12,45].contains(fileSize)
  }

  required init(data: Data) {
    switch data.count {
    case 45:
      bytes = [UInt8](data[38..<44])
    case 14:
      bytes = [UInt8](data[7..<13])
    case 12:
      // bulk data
      bytes = (0..<6).map {
        // LSB first
        let lsb = data[$0 * 2] & 0xf
        let msb = (data[$0 * 2 + 1] & 0xf) << 4
        let b = lsb + msb
        return b == 255 ? 127 : (b + 60) % 128
      }
    default:
      debugPrint("MKS-50 Chord: Unknown data count for init")
      bytes = [UInt8](repeating: 0, count: 6)
    }
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  /// Chord as sysex for edit buffer - 4.1.6
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x41, 0x35, UInt8(channel), 0x23, 0x40, 0x01])
    data.append(contentsOf: bytes)
    data.append(0xf7)
    return data
  }

  func randomize() {
    randomizeAllParams()
  }

  static let params : SynthPathParam = {
    var p = SynthPathParam()
    (0..<6).forEach {
      p[[.note, .i($0)]] = OptionsParam(byte: $0, options: noteOptions)
    }
    return p
  }()

  static let noteOptions: [Int:String] = {
    var options = [Int:String]()
    (36...84).forEach {
      options[$0] = "\($0)"
    }
    options[127] = "Off"
    return options
  }()
  
}
