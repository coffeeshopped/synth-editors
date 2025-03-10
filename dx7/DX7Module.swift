DX7Module : TypicalSectionedSynthModule, SectionedSynthModule {
//  
//  open class var manufacturer: String { return "Yamaha" }
//  open class var model: String { return "DX7" }
//  open class var productId: String { return "y".a.m.a.h.a.dot.d.x._7 }
//  
//  private static let _colorGuide = ColorGuide(colors: [
//    PBColor(hexString: "#4acd7d"),
//    PBColor(hexString: "#22bdff"),
//    PBColor(hexString: "#fd4f45")
//    ])
//  open class var colorGuide: ColorGuide { return _colorGuide }
//  
//  public let defaultIndexPath = IndexPath(item: 1, section: 0)
//  
//  required public override init(uuid: String) {
//    super.init(uuid: uuid)
//    
//    initEditor()
//    
//    sections = [
//      SynthModuleSection(title: nil, items: [
//        (title: "Global", path: [.global], controllerBlock: { return ChannelSettingsController() }),
//        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
//        ]),
//      SynthModuleSection(title: "Bank", items: [
//        (title: "Voice Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
//        ]),
//    ]
//  }
//  
//  open func initEditor() {
//    synthEditor = DX7Editor(baseURL: tempURL)
//  }
//  
//  var voiceBlock: SynthModuleControllerBlock {
//    return {
//      let keysController = BasicKeysViewController.defaultInstance()
//      let mainController = DX7Controller()
//      return PlayAdornedController(mainController: mainController, playController: keysController)
//    }
//  }
//
//  open func path(forSysexType sysexType: Sysexible.Type) -> String? {
//    switch sysexType {
//    case is DX7Patch.Type, is TX802VoicePatch.Type:
//      return "Patches"
//    case is DX7VoiceBank.Type, is TX802VoiceBank.Type:
//      return "Voice Banks"
//    default:
//      return nil
//    }
//  }
//  
//  // implemented so that child (Volca FM) gets its impl called
//  open func filteredToolbarIdentifiers(forIndexPath indexPath: IndexPath) -> [String] {
//    defaultFilteredToolbarIdentifiers(forIndexPath: indexPath)
//  }
//
//}
//
//public class TX7Module : DX7Module {
//  override public class var model: String { return "TX7" }
//  override public class var productId: String { return "y".a.m.a.h.a.dot.t.x._7 }
//}
//
//public class TX816Module : DX7Module {
//  override public class var model: String { return "TX816" }
//  override public class var productId: String { return "y".a.m.a.h.a.dot.t.x._8._1._6 }
//}
//
