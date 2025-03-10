
public class TG33Module : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Yamaha" }
  public class var model: String { return "TG33" }
  public class var productId: String { return "y".a.m.a.h.a.dot.t.g._3._3 }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#a2cd50"),
    PBColor(hexString: "#f93d31"),
    PBColor(hexString: "#0050d3")
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = TG33Editor(baseURL: tempURL)

    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { return ChannelSettingsController() }),
        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
        (title: "Multi", path: [.multi], controllerBlock: { return TG33MultiController() }),
        ]),
      SynthModuleSection(title: "Banks", items: [
        (title: "Voice Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
        (title: "Multi Bank", path: [.multi, .bank], controllerBlock: defaultBankEditorBlock()),
        ])
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = TG33VoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is TG33VoicePatch.Type:
      return "Patches"
    case is TG33VoiceBank.Type:
      return "Voice Banks"
    case is TG33MultiPatch.Type:
      return "Multi"
    case is TG33MultiBank.Type:
      return "Multi Banks"
    default:
      return nil
    }
  }
  
}
