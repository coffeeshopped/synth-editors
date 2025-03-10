
public struct MophoModule : TypedSynthModuleTemplate {
  public typealias EditorTemplate = MophoEditor
  
  public static var manu: Manufacturer = .dsi
  public static var model: String = "Mopho"
  public static var modelId: String = "m".o.p.h.o
  
  public static let colorGuide = ColorGuide([
    "#FDC63F",
    "#4080ff",
    "#a3e51e",
    "#ff6347",
    ])
  
  public static var sections: [SynthModuleTemplateSection] = makeSections(global: { _ in MophoGlobalController() }, main: { _ in MophoMainController.controller() })
  
  fileprivate static func makeSections(global: @escaping SynthModuleTemplateControllerBlock, main: @escaping SynthModuleTemplateControllerBlock) -> [SynthModuleTemplateSection] {
    [
      (nil, [
        ("Global", [.global], global),
        ("Voice", [.patch], defaultVoiceBlock(main)),
        ]),
      ("Voice Bank", items: [
        ("Bank 1", [.bank, .i(0)], defaultBankEditorBlock()),
        ("Bank 2", [.bank, .i(1)], defaultBankEditorBlock()),
        ("Bank 3", [.bank, .i(2)], defaultBankEditorBlock()),
        ]),
    ]
  }

  public static func directory(templateType: SysexTemplate.Type) -> String? {
    switch templateType {
    case is MophoGlobalPatch.Type, is MophoKeyGlobalPatch.Type:
      return "Global"
    case is MophoVoicePatch.Type, is MophoKeyVoicePatch.Type:
      return "Patches"
    case is MophoVoiceBank.Type, is MophoKeyVoiceBank.Type:
      return "Banks"
    default:
      return nil
    }
  }
  
}


public struct MophoKeyModule : TypedSynthModuleTemplate {
  public typealias EditorTemplate = MophoKeyEditor

  public static var manu: Manufacturer = .dsi
  public static var model: String = "Mopho Keyboard"
  public static var modelId: String = "m".o.p.h.o.k.e.y
  
  public static let colorGuide = MophoModule.colorGuide
  
  public static var sections: [SynthModuleTemplateSection] = MophoModule.makeSections(global: { _ in MophoKeysGlobalController() }, main: { _ in MophoKeysMainController.controller() })

  public static func directory(templateType: SysexTemplate.Type) -> String? {
    MophoModule.directory(templateType: templateType)
  }
  
}
