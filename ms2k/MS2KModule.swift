
public class MS2KModule : TypicalSectionedSynthModule, SectionedSynthModule, SynthModule {
  
  public class var manufacturer: String { return "Korg" }
  public class var model: String { return "MS2000" }
  public class var productId: String { return "k".o.r.g.dot.m.s._2.k }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#00ff31"),
    PBColor(hexString: "#f93048"),
    PBColor(hexString: "#3048f9"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  override required public init(uuid: String) {
    super.init(uuid: uuid)
    
    initEditor()
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { return ChannelSettingsController( )}),
        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Voice Bank", items: [
        (title: "Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }
  
  func initEditor() {
    synthEditor = MS2KEditor(baseURL: tempURL)
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = MS2KVoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is MS2KPatch.Type:
      return "Patches"
    case is MS2KBank.Type:
      return "Banks"
    default:
      return nil
    }
  }
}

public class MS2KRModule : MS2KModule {
  override public class var model: String { return "MS2000R" }
  override public class var productId: String { return "k".o.r.g.dot.m.s._2.k.r }
}

public class MS2KBModule : MS2KModule {
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#b6c9f0"),
    PBColor(hexString: "#f90028"),
    PBColor(hexString: "#3048f9"),
    ])
  override public class var colorGuide: ColorGuide { return _colorGuide }

  override public class var model: String { return "MS2000B" }
  override public class var productId: String { return "k".o.r.g.dot.m.s._2.k.b }
}

public class MS2KBRModule : MS2KModule {

  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#b6c9f0"),
    PBColor(hexString: "#f90028"),
    PBColor(hexString: "#3048f9"),
    ])
  override public class var colorGuide: ColorGuide { return _colorGuide }

  override public class var model: String { return "MS2000BR" }
  override public class var productId: String { return "k".o.r.g.dot.m.s._2.k.b.r }
}

