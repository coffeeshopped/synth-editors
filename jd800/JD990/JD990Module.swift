
public class JD990Module : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Roland" }
  public class var model: String { return "JD-990" }
  public class var productId: String { return "r".o.l.a.n.d.dot.j.d._9._9._0 }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#8733ea"),
    PBColor(hexString: "#f5b63a"),
    PBColor(hexString: "#b222f5"),
    PBColor(hexString: "#00f57e"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 2, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = JD990Editor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Config", path: [.deviceId], controllerBlock: { JD990SettingsController() } ),
        (title: "System", path: [.global], controllerBlock: { JD990GlobalController() } ),
        (title: "Patch", path: [.patch], controllerBlock: defaultVoiceBlock(JD990VoiceController.self) ),
        (title: "Rhythm", path: [.rhythm], controllerBlock: { JD990RhythmController() } ),
        ]),
      SynthModuleSection(title: "Performance", items: [
        (title: "Performance", path: [.perf], controllerBlock: defaultPerfBlock(JD990PerfController.self) ),
        (title: "Part 1", path: [.part, .i(0)], controllerBlock: defaultVoiceBlock(JD990VoiceController.self) ),
        (title: "Part 2", path: [.part, .i(1)], controllerBlock: defaultVoiceBlock(JD990VoiceController.self) ),
        (title: "Part 3", path: [.part, .i(2)], controllerBlock: defaultVoiceBlock(JD990VoiceController.self) ),
        (title: "Part 4", path: [.part, .i(3)], controllerBlock: defaultVoiceBlock(JD990VoiceController.self) ),
        (title: "Part 5", path: [.part, .i(4)], controllerBlock: defaultVoiceBlock(JD990VoiceController.self) ),
        (title: "Part 6", path: [.part, .i(5)], controllerBlock: defaultVoiceBlock(JD990VoiceController.self) ),
        (title: "Part 7", path: [.part, .i(6)], controllerBlock: defaultVoiceBlock(JD990VoiceController.self) ),
        ]),
      SynthModuleSection(title: "Internal Banks", items: [
        (title: "Voice Bank", path: [.bank, .patch, .i(0)], controllerBlock: defaultBankEditorBlock()),
        (title: "Rhythm Bank", path: [.bank, .rhythm, .i(0)], controllerBlock: defaultBankEditorBlock()),
        (title: "Perf Bank", path: [.bank, .perf, .i(0)], controllerBlock: defaultBankEditorBlock()),
        ]),
      SynthModuleSection(title: "Card Banks", items: [
        (title: "C: Voice Bank", path: [.bank, .patch, .i(1)], controllerBlock: defaultBankEditorBlock()),
        (title: "C: Rhythm Bank", path: [.bank, .rhythm, .i(1)], controllerBlock: defaultBankEditorBlock()),
        (title: "C: Perf Bank", path: [.bank, .perf, .i(1)], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }

  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is JD990SettingsPatch.Type:
      return "Config"
    case is GlobalPatch.Type:
      return "Global"
    case is VoicePatch.Type:
      return "Patches"
    case is PerfPatch.Type:
      return "Performances"
    case is RhythmPatch.Type:
      return "Rhythm"
    case is VoiceBank.Type:
      return "Voice Banks"
    case is PerfBank.Type:
      return "Performance Banks"
    case is RhythmBank.Type:
      return "Rhythm Banks"
    default:
      return nil
    }
  }

}
