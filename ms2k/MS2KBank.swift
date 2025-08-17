
protocol KorgMBank : TypedSysexPatchBank where Patch: ByteBackedSysexPatch { }
extension KorgMBank {
  static var patchCount: Int { return 128 }
  static var fileDataCount: Int { return 37163 }
  static var contentByteCount: Int { return 37157 }

  // 37163: size as documented
  // 37392: a bank from Korg. wtf.
  static func isValid(fileSize: Int) -> Bool {
    return fileSize == fileDataCount || fileSize == 37392
  }
  
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, 0x4c])
    let bytesToPack = [UInt8](patches.map { $0.bytes }.joined())
    data.append(Data.pack78(bytes: bytesToPack, count: type(of: self).contentByteCount))
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  static func korgPatches(fromData data: Data) -> [Patch] {
    let bytesPerPatch = 254
    let rawBytes = data.unpack87(count: bytesPerPatch * patchCount, inRange: 5..<(5+contentByteCount))
    return (0..<patchCount).map {
      let offset = $0 * bytesPerPatch
      guard offset + bytesPerPatch <= rawBytes.count else { return Patch.init() }
      let p = Patch.init(rawBytes: [UInt8](rawBytes[offset..<(offset + bytesPerPatch)]))
      if p.name == "" {
        p.name = "Patch \($0+1)"
      }
      return p
    }
  }

}

class MS2KBank : KorgMBank {
  
  var patches: [MS2KPatch]
  static let initFileName = "ms2k-bank-init"
  var name = ""
  
  required init(data: Data) {
    patches = Self.korgPatches(fromData: data)
  }
  
  required init(patches p: [MS2KPatch]) {
    patches = p
  }
  
  func copy() -> Self {
    Self.init(patches: patches.map { $0.copy() })
  }

  
}
