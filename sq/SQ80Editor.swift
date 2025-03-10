
class SQ80Editor : ESQ1Editor {
  
  private static let _patchMap: [SynthPath:Sysexible.Type] = [
    [.global] : ChannelSettingsPatch.self,
    [.patch] : SQ80Patch.self,
    [.bank] : SQ80Bank.self,
  ]
  class override var patchMap: [SynthPath:Sysexible.Type] { return _patchMap }
}
