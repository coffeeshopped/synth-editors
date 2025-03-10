
//public class TX802Module : TypicalSectionedSynthModule, SectionedSynthModule {
//  
//  public class var manufacturer: String { return "Yamaha" }
//  public class var model: String { return "TX802" }
//  public class var productId: String { return "y".a.m.a.h.a.dot.t.x._8._0._2 }
//
//  private static let _colorGuide = ColorGuide(colors: [
//    PBColor(hexString: "#4acd7d"),
//    PBColor(hexString: "#22bdff"),
//    PBColor(hexString: "#fd4f45")
//    ])
//  public class var colorGuide: ColorGuide { return _colorGuide }
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
//        (title: "Global", path: [.global], controllerBlock: { return TX802GlobalController() }),
//        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
//        (title: "Performance", path: [.perf], controllerBlock: { return TX802PerfController() }),
//        ]),
//      SynthModuleSection(title: "Bank", items: [
//        (title: "Voices (1-32)", path: [.bank, .i(0)], controllerBlock: defaultBankEditorBlock()),
//        (title: "Voices (33-64)", path: [.bank, .i(1)], controllerBlock: defaultBankEditorBlock()),
//        (title: "Perf Bank", path: [.perf, .bank], controllerBlock: defaultBankEditorBlock()),
//        ]),
//    ]
//  }
//  
//  func initEditor() {
//    synthEditor = TX802Editor(baseURL: tempURL)
//  }
//  
//  var voiceBlock: SynthModuleControllerBlock {
//    return {
//      let keysController = BasicKeysMIDIViewController.defaultInstance()
//      let mainController = TX802Controller<TX802ExtraController>()
//      return PlayAdornedController(mainController: mainController, playController: keysController)
//    }
//  }
//  
//  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
//    switch sysexType {
//    case is DX7Patch.Type, is TX802VoicePatch.Type, is VoicePatch.Type:
//      return "Patches"
//    case is DX7VoiceBank.Type, is VoiceBank.Type:
//      return "Voice Banks"
//    case is TX802PerfPatch.Type:
//      return "Performances"
//    case is TX802PerfBank.Type:
//      return "Perf Banks"
//    default:
//      return nil
//    }
//  }
//  
//}
//
//public class DX7IIModule : TX802Module {
//  
//  override public class var model: String { return "DX7II" }
//  override public class var productId: String { return "y".a.m.a.h.a.dot.d.x._7.i.i }
//  
//  public required init(uuid: String) {
//    super.init(uuid: uuid)
//    
//    sections = [
//      SynthModuleSection(title: nil, items: [
//        (title: "Global", path: [.global], controllerBlock: { return TX802GlobalController() }),
//        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
//        ]),
//      SynthModuleSection(title: "Bank", items: [
//        (title: "Voices (1-32)", path: [.bank, .i(0)], controllerBlock: defaultBankEditorBlock()),
//        (title: "Voices (33-64)", path: [.bank, .i(1)], controllerBlock: defaultBankEditorBlock()),
//        ]),
//    ]
//  }
//  
//  override func initEditor() {
//    synthEditor = DX7IIEditor(baseURL: tempURL)
//  }
//
//  override var voiceBlock: SynthModuleControllerBlock {
//    return {
//      let keysController = BasicKeysMIDIViewController.defaultInstance()
//      let mainController = DX7iiVoiceController()
//      return PlayAdornedController(mainController: mainController, playController: keysController)
//    }
//  }
//
//
//}
