
class VirusTISnowEmbeddedMultiPatch : VirusTISeriesEmbeddedMultiPatch<VirusTISnowVoicePatch, VirusTISnowMultiPatch>, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = VirusTISnowEmbeddedMultiBank.self

  override class var initFileName: String { return "virusti-snow-embedded-multi-init"}
  override class var partCount: Int { return 4 }
}
