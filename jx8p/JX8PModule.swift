
public class JX8PModule : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Roland" }
  public class var model: String { return "JX-8P" }
  public class var productId: String { return "r".o.l.a.n.d.dot.j.x._8.p }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#77d6ff"),
    PBColor(hexString: "#eea147"),
    PBColor(hexString: "#6d85e5"),
    PBColor(hexString: "#ed6e5f")
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = JX8PEditor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { ChannelSettingsController()} ),
        (title: "Tone", path: [.tone], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Bank", items: [
        (title: "Tone Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
        ])
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = JX8PVoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is ChannelSettingsPatch.Type:
      return "Global"
    case is VoicePatch.Type:
      return "Tones"
    case is VoiceBank.Type:
      return "Tone Banks"
    default:
      return nil
    }
  }
  
}

