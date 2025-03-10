
public enum CZ5000 {
  
  static let editorTruss = CZ101.createEditorTruss("CZ-5000", patchCount: 32, letteredBanks: true, cz1: false)
  public static let moduleTruss = CZ101.createModuleTruss(editorTruss, subid: "cz5000", cz1: false)

}
