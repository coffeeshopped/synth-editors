
extension SingleBankTemplate where Template : MophoVoiceTypePatch {
  static var patchCount: Int { 128 }
  static var fileDataCount: Int { patchCount * (Patch.fileDataCount + 2) }

  static func patchArray(fromData data: Data) -> [Patch] {
    patchArray(fromData: data) { location($0, fromByte: 5) }
  }
  
  static func fileData(_ patches: [Patch]) -> [UInt8] {
    sysexData(patches: patches) { Template.sysexData($0.bytes, bank: 0, location: $1).bytes() }
  }
}

struct MophoVoiceBank : SingleBankTemplate {
  typealias Template = MophoVoicePatch
  static let initFileName = "mopho-bank-init"
}

struct MophoKeyVoiceBank : SingleBankTemplate {
  typealias Template = MophoKeyVoicePatch
  static let initFileName = "mopho-bank-init"
}
