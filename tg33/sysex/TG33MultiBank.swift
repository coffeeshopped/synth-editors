
class TG33MultiBank : TypicalTypedSysexPatchBank<TG33MultiPatch>, ChannelizedSysexible {
  
  override class var patchCount: Int { return 16 }
  override class var fileDataCount: Int { return 3346 }
  override class var initFileName: String { return "tg33-multi-bank-init" }
  
  func sysexData(channel: Int) -> Data {
    var b = "LM  0012MU".unicodeScalars.map { UInt8($0.value) }
    (0..<16).forEach { b.append(contentsOf: patches[$0].bytes) }
    
    let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
    let byteCountLSB = UInt8(b.count & 0x7f)
    
    var data = Data([0xf0, 0x43, UInt8(channel), 0x7e, byteCountMSB, byteCountLSB])
    data.append(contentsOf: b)
    data.append(Patch.checksum(bytes: b))
    data.append(0xf7)
    return data
  }
  
  override func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  required init(data: Data) {
    let offset = 16
    let patchByteCount = 208
    
    let p: [Patch] = stride(from: offset, to: data.count, by: patchByteCount).compactMap { doff in
      let endex = doff + patchByteCount
      guard endex <= data.count else { return nil }
      let sysex = data.subdata(in: doff..<endex)
      return Patch(bankData: sysex)
    }
    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  

}
