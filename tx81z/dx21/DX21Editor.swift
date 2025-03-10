
extension DX21 {
  
  enum Editor {
    
    static let werk = TX81Z.EditorWerk(voiceTruss: Voice.patchTruss, voiceBankTruss: Voice.bankTruss)

    static let truss: BasicEditorTruss = {
      var t = BasicEditorTruss("DX21", truss: werk.coreSysexMap)
      t.fetchTransforms = DX100.Editor.truss.fetchTransforms
      t.midiOuts = DX100.Editor.truss.midiOuts
      Op4.editorTrussSetup(&t)
      return t
    }()
    
  }
}

