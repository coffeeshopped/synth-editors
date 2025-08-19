
class TG77MultiBank : TypicalTypedSysexPatchBank<TG77MultiPatch> {
  
  override class var patchCount: Int { return 16 }
  override class var initFileName: String { return "tg77-multi-bank-init" }
  
  override func fileData() -> Data {
    return sysexData { $0.sysexData(channel: 0, location: $1) }
  }
  
  static let emptyBankOptions = OptionsParam.makeOptions((1...16).map { "\($0)" })

}


class TG77MultiCommonBank : TypicalTypedSysexPatchBank<TG77MultiCommonPatch> {
  
  override class var patchCount: Int { return 16 }
  override class var initFileName: String { return "tg77-multi-common-bank-init" }
  
  override func fileData() -> Data {
    return sysexData { $0.sysexData(channel: 0, location: $1) }
  }
  
  static let emptyBankOptions = OptionsParam.makeOptions((1...16).map { "\($0)" })
  
}

