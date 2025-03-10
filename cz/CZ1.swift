
public enum CZ1 {
  
  static let editorTruss = CZ101.createEditorTruss("CZ-1", patchCount: 64, letteredBanks: true, cz1: true)
  public static let moduleTruss = CZ101.createModuleTruss(editorTruss, subid: "cz1", cz1: true)

}
