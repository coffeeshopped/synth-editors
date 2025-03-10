
public class D50Module : TypicalSectionedSynthModule, SectionedSynthModule, RolandSynthModule {

  public class var model: String { "D-50" }
  public class var productId: String  { "r".o.l.a.n.d.dot.d._5._0 }

  public static let colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#77d6ff"),
    PBColor(hexString: "#eea147"),
    PBColor(hexString: "#6d85e5"),
    PBColor(hexString: "#ed6e5f")
    ])

  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = D50Editor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { ChannelSettingsController() }),
        (title: "Patch", path: [.patch], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Bank", items: [
        (title: "Patch Bank", path: [.bank], controllerBlock: defaultBankEditorBlock())
        ])
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = D50MainController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is ChannelSettingsPatch.Type:
      return "Global"
    case is D50VoicePatch.Type:
      return "Patches"
    case is D50VoiceBank.Type:
      return "Patch Banks"
    default:
      return nil
    }
  }
  
}

public class D550Module : D50Module {

  override public class var model: String { return "D-550" }
  override public class var productId: String  { return "r".o.l.a.n.d.dot.d._5._5._0 }

}

public class D05Module : D50Module {
  
  override public class var model: String { return "D-05" }
  override public class var productId: String  { return "r".o.l.a.n.d.dot.d._0._5 }
  
}
