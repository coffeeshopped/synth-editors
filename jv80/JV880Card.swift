
extension JV880 {
  
  enum Card {
    
    static let truss = JSONPatchTruss("JV-880 Card", parms: parms, initFile: "jv880-cards")
 
    static let parms: [Parm] = [
      .p([.int], 0, .options(SRJVBoard.boardNameOptions)),
      .p([.pcm], 1, .options(SOPCMCard.cardNameOptions)),
    ]

  }
}
