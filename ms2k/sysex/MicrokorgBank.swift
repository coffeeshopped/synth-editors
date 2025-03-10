
class MicrokorgBank : KorgMBank {
  
  required init(patches p: [MicrokorgPatch]) {
    patches = p
  }
  
  func copy() -> Self {
    Self.init(patches: patches.map { $0.copy() })
  }
  
  
  var patches: [MicrokorgPatch]
  static let initFileName = "ms2k-bank-init"
  var name = ""
  
  required init(data: Data) {
    let bytesPerPatch = 254
    let rawBytes = data.unpack87(count: bytesPerPatch * Self.patchCount, inRange: 5..<(5+Self.contentByteCount))
    patches = (0..<Self.patchCount).map {
      let offset = $0 * bytesPerPatch
      guard offset + bytesPerPatch <= rawBytes.count else { return Patch() }
      let p = Patch(rawBytes: [UInt8](rawBytes[offset..<(offset + bytesPerPatch)]))
      if p.name == "" {
        let letter = $0 < 64 ? "A" : "B"
        let bank = ($0 % 64) / 8 + 1
        let slot = $0 % 8 + 1
        p.name = "Patch \(letter)\(bank)\(slot)"
      }
      return p
    }
  }

}
