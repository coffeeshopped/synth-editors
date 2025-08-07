
class ESQTypeBank<Patch:ESQPatch> : TypicalTypedSysexPatchBank<Patch>, ChannelizedSysexible {

  override class var patchCount: Int { return 40 }
  override class var fileDataCount: Int { return 8166 }
  override class var initFileName: String { return "esq-bank-init" }
  
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x0f, 0x02, UInt8(channel), 0x02])
    patches.forEach { data.append($0.bankSysexData()) }
    data.append(0xf7)
    return data
  }
  
  override func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  required init(data: Data) {
    let p = type(of: self).compactPatches(fromData: data, offset: 5, patchByteCount: 204)
    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
}

class ESQBank : ESQTypeBank<ESQPatch> { }

class SQ80Bank : ESQTypeBank<SQ80Patch> { }
