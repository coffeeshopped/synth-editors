
//class VolcaFMVoiceBank : TypicalTypedSysexPatchBank<VolcaFMPatch>, ChannelizedSysexible {
//  
//  override class var patchCount: Int { return 32 }
//  override class var fileDataCount: Int { return 4104 }
//  // TODO: need actual init file
//  override class var initFileName: String { return "dx7-bank-init" }
//  
//  func sysexData(channel: Int) -> Data {
//    var data = Data([0xf0, 0x43, UInt8(channel), 0x09, 0x20, 0x00])
//    let patchData = [UInt8](patches.map{ $0.bankSysexData() }.reduce(Data(), +))
//    data.append(contentsOf: patchData)
//    data.append(DX7Patch.checksum(bytes: patchData))
//    data.append(0xf7)
//    return data
//  }
//  
//  override func fileData() -> Data {
//    return sysexData(channel: 0)
//  }
//  
//  required init(data: Data) {
//    let p = type(of: self).compactPatches(fromData: data, offset: 6, patchByteCount: 128)
//    super.init(patches: p)
//  }
//  
//  required init(patches p: [Patch]) {
//    super.init(patches: p)
//  }
//
//}
