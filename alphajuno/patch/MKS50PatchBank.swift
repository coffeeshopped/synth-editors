
class MKS50PatchBank : TypicalTypedSysexPatchBank<MKS50PatchPatch> {
  
  // 266 * 16
  override class var fileDataCount: Int { return 4256 }
  override class var patchCount: Int { return 64 }
  // TODO: need actual init file
  override class var initFileName: String { return "mks50-patch-bank-init" }
    
  required init(data: Data) {
    let sysex = SysexData(data: data)
    var p = [Patch]()
    (0..<sysex.count).forEach {
      let msg = sysex[$0]
      let dOff = 9
      let next4 = (0..<4).compactMap { subindex -> Patch? in
        let thisOff = dOff + subindex * 64
        guard thisOff + 64 <= msg.count else { return nil }
        return Patch(data: Data(msg[thisOff..<(thisOff+64)]))
      }
      p.append(contentsOf: next4)
    }
    
    (0..<(type(of: self).patchCount-p.count)).forEach { _ in
      p.append(Patch.init())
    }
    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  func sysexData(channel: Int) -> [Data] {
    return (0..<16).map { msgIndex -> Data in
      let pOff = msgIndex * 4
      var d = Data([0xf0, 0x41, 0x37, UInt8(channel), 0x23, 0x30, 0x01, 0x00, UInt8(pOff)])
      (0..<4).forEach { subindex in
        let bytes = patches[pOff + subindex].bytes
        d.append(contentsOf: bytes.map {
          [$0 & 0x0f, ($0 >> 4) & 0x0f]
          }.joined())
      }
      d.append(0xf7)
      return d
    }
  }
  
  // put here bc TypicalTypedRolandAddressableBank has same impl, but calls protocol version of
  // sysexData(deviceId: for some reason
  override open func fileData() -> Data {
    return Data(sysexData(channel: 0).joined())
  }

}
