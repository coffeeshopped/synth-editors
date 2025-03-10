
extension TX81Z {
  
  struct EditorWerk<PT: PatchTruss> {
    let voiceTruss: PT
    let voiceBankTruss: SomeBankTruss<PT>
    
    let coreSysexMap: [(SynthPath, any SysexTruss)]

    init(voiceTruss: PT, voiceBankTruss: SomeBankTruss<PT>) {
      self.voiceTruss = voiceTruss
      self.voiceBankTruss = voiceBankTruss
      
      self.coreSysexMap = [
        ([.global], ChannelSettingsTruss),
        ([.patch], voiceTruss),
        ([.bank], voiceBankTruss),
      ]

    }

  }
}
