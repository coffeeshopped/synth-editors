
struct TetraVoiceBank : SingleBankTemplate {
  typealias Template = TetraVoicePatch
  static let initFileName = "tetra-voice-bank-init"
}

struct TetraComboBank : SingleBankTemplate {
  typealias Template = TetraComboPatch
  static let initFileName = "tetra-combo-bank-init"
  
  static var fileDataCount: Int { patchCount * (Patch.fileDataCount + 1) }

  static func patchArray(fromData data: Data) -> [Patch] {
    patchArray(fromData: data) { $0.count > 4 ? Int($0[4]) : 0 }
  }
  
  static func fileData(_ patches: [FnSinglePatch<Template>]) -> [UInt8] {
    sysexData(patches: patches) { Template.sysexData($0.bytes, location: $1).bytes() }
  }


}
