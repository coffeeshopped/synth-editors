
//class WavestationSRPatchBank : TypicalTypedSysexPatchBank<WavestationSRPatchPatch>, VoiceBank {
//  
//  override class var patchCount: Int { return 35 }
//  override class var fileDataCount: Int { return 29828 }
//  // TODO: need actual init file
//  override class var initFileName: String { return "wavestationsr-patch-bank-init" }
//
//  required public init(data: Data) {
//    let p = Self.patches(fromData: data, offset: 6, bytesPerPatch: 852, transform: {
//      Patch.init(bodyData: $0)
//    })
//    super.init(patches: p)
//  }
//  
//  required init(patches p: [Patch]) {
//    super.init(patches: p)
//  }
//
//  func sysexData(channel: Int, bank: Int) -> Data {
//    var data = Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x28, 0x4c, UInt8(bank)])
//    let bodyData = sysexData { (patch, location) in patch.sysexBodyData() }
//    data.append(bodyData)
//    data.append(bodyData.reduce(0) { ($0 + $1) & 0x7f })
//    data.append(0xf7)
//    return data
//  }
//
//  override func fileData() -> Data {
//    return sysexData(channel: 0, bank: 0)
//  }
//  
//}
//
//
