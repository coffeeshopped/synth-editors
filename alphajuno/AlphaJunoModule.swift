
public class AlphaJunoModule : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Roland" }
  public class var model: String { return "Alpha Juno-1" }
  public class var productId: String { return "r".o.l.a.n.d.dot.a.l.p.h.a.j.u.n.o._1 }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#f73a34"),
    PBColor(hexString: "#3a9fe3"),
    PBColor(hexString: "#dede21"),
    PBColor(hexString: "#e5592e"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = AlphaJunoEditor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { ChannelSettingsController()} ),
        (title: "Tone", path: [.tone], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Bank", items: [
        (title: "Tone Bank", path: [.bank, .tone], controllerBlock: defaultBankEditorBlock()),
        ])
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = AlphaJunoVoiceController()
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

public class AlphaJuno2Module : AlphaJunoModule {

  override public class var model: String { return "Alpha Juno-2" }
  override public class var productId: String { return "r".o.l.a.n.d.dot.a.l.p.h.a.j.u.n.o._2 }

}
