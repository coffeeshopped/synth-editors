
public enum CZ1000 {
  
  static let editorTruss = CZ101.createEditorTruss("CZ-1000", patchCount: 16, letteredBanks: false, cz1: false)
  public static let moduleTruss = CZ101.createModuleTruss(editorTruss, subid: "cz1000", cz1: false)

}
