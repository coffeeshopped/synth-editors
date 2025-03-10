
extension DX11 {
  
  enum Editor {

    static let werk = TX81Z.EditorWerk(voiceTruss: Voice.patchTruss, voiceBankTruss: Voice.bankTruss)

    static let truss: BasicEditorTruss = {
      var t = BasicEditorTruss("DX11", truss: trussMap)
      t.fetchTransforms = TX81Z.Editor.truss.fetchTransforms <<< [
        [.patch] : Op4.fetch(header: "8023AE")
      ]
      t.midiOuts = [
        ([.patch], Op4.patchChangeTransform(truss: Voice.patchTruss, map: Voice.map)),
        ([.perf], Perf.patchTransform),
        ([.micro, .octave], Op4.Micro.Oct.werk.patchChangeTransform()),
        ([.micro, .key], Op4.Micro.Full.werk.patchChangeTransform()),
        ([.bank], Voice.bankTransform),
        ([.bank, .perf], TX81Z.Perf.wholeBankTransform(patchCount: Perf.bankTruss.patchCount, patchWerk: Perf.patchWerk))
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
