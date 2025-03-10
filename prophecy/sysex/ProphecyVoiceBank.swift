
class ProphecyVoiceBank : TypicalTypedSysexPatchBank<ProphecyVoicePatch>, VoiceBank {

  override class var fileDataCount: Int { return 39141 }
  override class var patchCount: Int { return 64 }
  override class var initFileName: String { return "prophecy-voice-bank-init" }

  static let contentByteCount = 39132

  static func bankLetter(_ index: Int) -> String {
    return ["A","B"][index]
  }
  
  required init(data: Data) {
    let byteOffset = 8
    let bytesPerPatch = 535 // 34240
    let rawData = Data(data.unpack87(count: bytesPerPatch * Self.patchCount, inRange: byteOffset..<(byteOffset + Self.contentByteCount)))
    let patches = Self.patches(fromData: rawData, offset: 0, bytesPerPatch: bytesPerPatch) {
      Patch(rawBytes: [UInt8]($0))
    }
    super.init(patches: patches)
  }

  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  

  func sysexData(channel: Int, bank: Int) -> Data {
    var data = Data(Prophecy.sysexHeader(deviceId: UInt8(channel)) + [0x4c, 0x10 + UInt8(bank), 0x00, 0x00])
    let bytesToPack = [UInt8](patches.map { $0.bytes }.joined())
    data.append(Data.pack78(bytes: bytesToPack, count: Self.contentByteCount))
    data.append(0xf7)
    return data
  }
  
  override func fileData() -> Data {
    return sysexData(channel: 0, bank: 0)
  }
    
}
