
public enum CZ3000 {
  
  static let editorTruss = CZ101.createEditorTruss("CZ-3000", patchCount: 32, letteredBanks: true, cz1: false)
  public static let moduleTruss = CZ101.createModuleTruss(editorTruss, subid: "cz3000", cz1: false)

}
