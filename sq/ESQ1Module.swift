
public class ESQ1Module : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Ensoniq" }
  public class var model: String { return "ESQ-1" }
  public class var productId: String { return "e".n.s.o.n.i.q.dot.e.s.q._1 }
  
  public static let colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#b1bfd6"),
    PBColor(hexString: "#d9bf47"),
    PBColor(hexString: "#47bfd9"),
    ])
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)

  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    initEditor()
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { return ChannelSettingsController() }),
        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Bank", items: [
        (title: "Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }
  
  func initEditor() {
    synthEditor = ESQ1Editor(baseURL: tempURL)
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = ESQController.controller(sq80: false)
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is ESQPatch.Type:
      return "Patches"
    case is ESQBank.Type, is SQ80Bank.Type:
      return "Bank"
    default:
      return nil
    }
  }

}

public class SQ80Module : ESQ1Module {

  override public class var model: String { "SQ-80" }
  override public class var productId: String { "e".n.s.o.n.i.q.dot.s.q._8._0 }

  override func initEditor() {
    synthEditor = SQ80Editor(baseURL: tempURL)
  }
  
  override var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = ESQController.controller(sq80: true)
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

}

public class ESQMModule : ESQ1Module {

  override public class var model: String { "ESQ-M" }
  override public class var productId: String { "e".n.s.o.n.i.q.dot.e.s.q.m }
  
  override func initEditor() {
    synthEditor = ESQMEditor(baseURL: tempURL)
  }

}
