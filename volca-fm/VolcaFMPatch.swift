
//class VolcaFMPatch : DX7Patch {
//  
//  override class var bankType: SysexPatchBank.Type { return VolcaFMVoiceBank.self } 
//
//  override class var initFileName: String { return "volcafm-init" }
//
//  required init(data: Data) {
//    super.init(data: data)
//    bytes.append(data[161]) // add in checksum byte as op on/off data
//  }
//  
//  required init(bankData: Data) {
//    super.init(bankData: bankData)
//    bytes.append(0x3f) // all ops on
//  }
//  
//  override func sysexData(channel: Int) -> Data {
//    var data = Data([0xf0, 0x043, UInt8(channel), 0x00, 0x01, 0x1b])
//    // no checksum in Volca
//    data.append(contentsOf: bytes)
//    data.append(0xf7)
//    return data
//  }
//  
//  private static let _params: SynthPathParam = {
//    var p = DX7Patch.params
//    (0..<6).forEach { p[[.op, .i($0), .on]] = RangeParam(byte: 155, bit: $0) }
//    return p
//  }()
//  override class var params: SynthPathParam { return _params }
//  
//  
//  // params for reading from a bank
////  private static var classBankParams = [String:PatchParam]()
////  override class var bankParams: [String : PatchParam] {
////    if classBankParams.count == 0 {
////      for op in 1...6 {
////        classBankParams["Op\(op)On"] = PatchParam(byte: 155, bit: op-1, maxVal: 1)
////      }
////    }
////    return classBankParams
////  }
//
//  
//}
