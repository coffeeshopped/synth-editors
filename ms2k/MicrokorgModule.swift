
public class MicrokorgModule : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public static let colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#85c8fa"),
    PBColor(hexString: "#efbb6d"),
    PBColor(hexString: "#6dbbef"),
    ])
  
  public static let manufacturer = "Korg"
  public static let model = "Microkorg"
  public static let productId = "k".o.r.g.dot.m.i.c.r.o.k.o.r.g

  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  override required public init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = MicrokorgEditor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { return MicrokorgGlobalController() }),
        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Voice Bank", items: [
        (title: "Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }
  
  private var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = MicrokorgVoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is MicrokorgGlobalPatch.Type:
      return "Global"
    case is MicrokorgPatch.Type:
      return "Patches"
    case is MicrokorgBank.Type:
      return "Banks"
    default:
      return nil
    }
  }
}
