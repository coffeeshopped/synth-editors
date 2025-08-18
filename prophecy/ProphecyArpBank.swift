
class ProphecyArpBank : TypicalTypedSysexPatchBank<ProphecyArpPatch> {

  override class var fileDataCount: Int { return 1471 }
  override class var patchCount: Int { return 10 }
  override class var initFileName: String { return "prophecy-arp-bank-init" }

  static let contentByteCount = 1463
  
  static let names = ["Up", "Down", "Alt 1", "Alt 2", "Random", "Pat1", "Pat2", "Pat3", "Pat4", "Pat5"]
  
  required init(data: Data) {
    let byteOffset = 7
    let bytesPerPatch = 128
    let rawData = Data(data.unpack87(count: bytesPerPatch * Self.patchCount, inRange: byteOffset..<(byteOffset + Self.contentByteCount)))
    let patches = Self.patches(fromData: rawData, offset: 0, bytesPerPatch: bytesPerPatch) {
      Patch(rawBytes: [UInt8]($0))
    }
    Self.names.enumerated().forEach { patches[$0.offset].name = $0.element }
    super.init(patches: patches)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  

  func sysexData(channel: Int) -> Data {
    var data = Data(Prophecy.sysexHeader(deviceId: UInt8(channel)) + [0x69, 0x10, 0x00])
    let bytesToPack = [UInt8](patches.map { $0.bytes }.joined())
    data.append(Data.pack78(bytes: bytesToPack, count: Self.contentByteCount))
    data.append(0xf7)
    return data
  }
  
  override func fileData() -> Data {
    return sysexData(channel: 0)
  }
    
}
