
public struct MicroQModule : TypedSynthModuleTemplate {
  public typealias EditorTemplate = MicroQEditor
  
  public static let manu: Manufacturer = .waldorf
  public static let model: String = "Micro Q"
  public static let modelId: String = "m".i.c.r.o.q
  
  public static let colorGuide = ColorGuide([
    "#8F761E",
    "#dbb943",
    "#013c6e",
    "#5ADBC7",
    ])
  
  public static var sections: [SynthModuleTemplateSection] = [
    (nil, [
      ("Global", [.global], { _ in MicroQGlobalController.controller() }),
      ("Voice", [.patch], defaultVoiceBlock({ _ in MicroQVoiceController.controller() })),
      ]),
    ("Banks", items: [
      ("Bank A", [.bank, .i(0)], defaultBankEditorBlock()),
      ("Bank B", [.bank, .i(1)], defaultBankEditorBlock()),
      ("Bank C", [.bank, .i(2)], defaultBankEditorBlock()),
      ("Multi Bank", [.bank, .multi], defaultBankEditorBlock()),
      ("Drum Bank", [.bank, .rhythm], defaultBankEditorBlock()),
      ]),
    ("Multi Mode", [
      ("Multi", [.multi], defaultPerfBlock({ _ in MicroQMultiController.controller() })),
    ] + (0..<16).map {
      ("Part \($0 + 1)", [.multi, .i($0)], defaultVoiceBlock({ _ in MicroQVoiceController.controller() }))
    }),
    ("Drum Map", [
      ("Drum Map", [.rhythm], defaultVoiceBlock({ _ in MicroQDrumController.controller() })),
    ] + (0..<32).map {
      ("Drum \($0 + 1)", [.rhythm, .i($0)], defaultVoiceBlock({ _ in MicroQVoiceController.controller() }))
    }),
  ]

  public static func directory(templateType: SysexTemplate.Type) -> String? {
    switch templateType {
    case is GlobalPatch.Type:
      return "Global"
    case is VoicePatch.Type:
      return "Patches"
    case is PerfPatch.Type:
      return "Multis"
    case is RhythmPatch.Type:
      return "Drum Maps"
    case is VoiceBank.Type:
      return "Banks"
    case is PerfBank.Type:
      return "Multi Banks"
    case is RhythmBank.Type:
      return "Drum Banks"
    default:
      return nil
    }
  }

}
