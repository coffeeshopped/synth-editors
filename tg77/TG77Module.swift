
public class TG77Module : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Yamaha" }
  public class var model: String { return "TG77" }
  public class var productId: String { return "y".a.m.a.h.a.dot.t.g._7._7 }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#4158be"),
    PBColor(hexString: "#df7757"),
    PBColor(hexString: "#425bcd"),
    PBColor(hexString: "#a7e46f"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    initEditor()
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { return TG77SystemController() }),
        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
        (title: "Multi", path: [.multi], controllerBlock: multiBlock),
        (title: "Pan", path: [.pan], controllerBlock: { return TG77PanController() }),
        ]),
      SynthModuleSection(title: "Banks", items: [
        (title: "Voice Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
        (title: "Multi Bank", path: [.multi, .bank], controllerBlock: defaultBankEditorBlock()),
        (title: "Pan Bank", path: [.pan, .bank], controllerBlock: defaultBankEditorBlock()),
        ])
    ]
  }
  
  func initEditor() {
    synthEditor = TG77Editor(baseURL: tempURL)
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = TG77VoiceController(hideIndivOut: false)
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  var multiBlock: SynthModuleControllerBlock {
    return { return TG77MultiController(hideIndivOut: false) }
  }

  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is TG77SystemPatch.Type:
      return "System"
    case is TG77VoicePatch.Type:
      return "Patches"
    case is TG77VoiceBank.Type:
      return "Voice Banks"
    case is TG77MultiPatch.Type, is TG77MultiCommonPatch.Type:
      return "Multi"
    case is TG77MultiBank.Type, is TG77MultiCommonBank.Type:
      return "Multi Banks"
    case is TG77PanPatch.Type:
      return "Pan"
    case is TG77PanBank.Type:
      return "Pan Banks"
    default:
      return nil
    }
  }
    
  public func panNameOptions() -> [Int:String]? {
    guard let bank = synthEditor.sysexible(forPath: [.pan, .bank]) as? SysexPatchBank else { return nil }
    return OptionsParam.makeOptions(bank.patchNames.enumerated().map { "I\($0.offset + 1). \($0.element)" })
  }
  
}
