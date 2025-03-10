
extension TX81Z {
  
  enum Editor {
    
    static let werk = EditorWerk(voiceTruss: Voice.patchTruss, voiceBankTruss: Voice.bankTruss)
    
    static let truss: BasicEditorTruss = {
      var t = BasicEditorTruss("TX81Z", truss: trussMap)
      t.fetchTransforms = [
        [.patch] : Op4.fetch(header: "8976AE"),
        [.perf] : Op4.fetch(header: "8976PE"),
        [.micro, .octave] : Op4.fetch(header: "MCRTE0"),
        [.micro, .key] : Op4.fetch(header: "MCRTE1"),
        [.bank] : Op4.fetch([0x04]),
        [.bank, .perf] : Op4.fetch(header: "8976PM"),
      ]

      t.midiOuts = [
        ([.patch], Op4.patchChangeTransform(truss: Voice.patchTruss, map: Voice.map)),
        ([.perf], Perf.patchTransform),
        ([.micro, .octave], Op4.Micro.Oct.werk.patchChangeTransform()),
        ([.micro, .key], Op4.Micro.Full.werk.patchChangeTransform()),
        ([.bank], Voice.bankTransform),
        ([.bank, .perf], Perf.wholeBankTransform(patchCount: Perf.bankTruss.patchCount, patchWerk: Perf.patchWerk))
      ]
      
      Op4.editorTrussSetup(&t)
      return t
    }()
    
    static let trussMap: [(SynthPath, any SysexTruss)] = werk.coreSysexMap +
    Op4.microSysexMap +
      [
        ([.perf], Perf.patchWerk.truss),
        ([.bank, .perf], Perf.bankTruss),
        ([.backup], backupTruss),
      ]
        
  }
  
}
