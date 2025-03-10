
public class DW8KModule : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Korg" }
  public class var model: String { return "DW-8000" }
  public class var productId: String { return "k".o.r.g.dot.d.w._8.k }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#e99995"),
    PBColor(hexString: "#7bb1e5"),
    PBColor(hexString: "#a9b24e"),
//    PBColor(hexString: "#4a74f0"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = DW8KEditor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { ChannelSettingsController() }),
        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Bank", items: [
        (title: "Voice Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
        ])
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = DW8KVoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is ChannelSettingsPatch.Type:
      return "Global"
    case is VoicePatch.Type:
      return "Patches"
    case is VoiceBank.Type:
      return "Voice Banks"
    default:
      return nil
    }
  }
}

public class EX8KModule : DW8KModule {

  override public class var model: String { return "EX-8000" }
  override public class var productId: String { return "k".o.r.g.dot.e.x._8.k }

}
