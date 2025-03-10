
public class MinilogueModule : TypicalSectionedSynthModule, SectionedSynthModule, SynthModule {
  
  public class var manufacturer: String { return "Korg" }
  public class var model: String { return "Minilogue" }
  public class var productId: String { return "k".o.r.g.dot.m.i.n.i.l.o.g.u.e }
  
  public static let colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#eb2526"),
    PBColor(hexString: "#b4c5d9"),
    PBColor(hexString: "#94805d")
    ])
  
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = MinilogueEditor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { return ChannelSettingsController() }),
        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Voice Bank", items: [
        (title: "Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = MinilogueMainController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is MiniloguePatch.Type:
      return "Patches"
    case is MinilogueBank.Type:
      return "Banks"
    default:
      return nil
    }
  }
  
}
