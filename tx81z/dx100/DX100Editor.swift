
extension DX100 {
  
  enum Editor  {
    
    static let werk = TX81Z.EditorWerk(voiceTruss: Voice.patchTruss, voiceBankTruss: Voice.bankTruss)

    static let truss: BasicEditorTruss = {
      var t = BasicEditorTruss("DX100", truss: werk.coreSysexMap)
      t.fetchTransforms = [
        [.patch] : Op4.fetch([0x03]),
        [.bank] : Op4.fetch([0x04]),
      ]
      
      t.midiOuts = [
        ([.patch], Op4.patchChangeTransform(truss: Voice.patchTruss, map: Voice.map)),
        ([.bank], Op4.patchBankTransform(map: Voice.map)),
      ]

      Op4.editorTrussSetup(&t)
      return t
    }()
        
  }
}
