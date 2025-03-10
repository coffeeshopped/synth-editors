
class MKS50ChordBank : TypicalTypedSysexPatchBank<MKS50ChordPatch> {
  
  override class var fileDataCount: Int { return 202 }
  override class var patchCount: Int { return 16 }
  // TODO: need actual init file
  override class var initFileName: String { return "mks50-chord-bank-init" }
    
  required init(data: Data) {
    var i = 1
    var p: [Patch] = stride(from: 9, to: data.count, by: 12).compactMap { doff in
      let endex = doff + 12
      guard endex <= data.count else { return nil }
      let sysex = data.subdata(in: doff..<endex)
      let p = Patch(data: sysex)
      p.name = "Chord \(i)"
      i += 1
      return p
    }
    
    (0..<(type(of: self).patchCount-p.count)).forEach { _ in
      p.append(Patch())
    }
    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  func sysexData(channel: Int) -> Data {
    var d = Data([0xf0, 0x41, 0x37, UInt8(channel), 0x23, 0x40, 0x01, 0x00, 0x00])
    patches.forEach { patch in
      d.append(contentsOf: patch.bytes.map { (byte) -> [UInt8] in
        let b: UInt8 = byte == 127 ? 255 : (byte + 68) % 128
        return [b & 0x0f, (b >> 4) & 0x0f]
      }.joined())
    }
    d.append(0xf7)
    return d
  }
  
  override open func fileData() -> Data {
    return sysexData(channel: 0)
  }

}
