
extension VolcaFM2 {

  enum Global {
    
    static let patchTruss = JSONPatchTruss("Volca FM2 Global", parms: [
      .p([.channel], 0, .max(15, dispOff: 1)),
      .p([.send, .patch], 0, .max(1)),
    ])
  }

}
