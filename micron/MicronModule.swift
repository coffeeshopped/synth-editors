
public class MicronModule : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Alesis" }
  public class var model: String { return "Micron" }
  public class var productId: String { return "a".l.e.s.i.s.dot.m.i.c.r.o.n }
  
  public class var postAddMessage: String? {
    return "Note: Full Bank Editor and Table of Contents functionality requires an unofficial firmware update to your Micron. Please read the Micron Help page on the Patch Base website for full details before using."
  }

  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#167bb4"),
    PBColor(hexString: "#ff2c54"),
    PBColor(hexString: "#ebe72f"),
    PBColor(hexString: "#fa28f3"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = MicronEditor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { MicronGlobalController() }),
        (title: "Program", path: [.patch], controllerBlock: voiceBlock),
        (title: "Program TOC", path: [.memory, .patch], controllerBlock:  { MiniakVoiceIndexController() }),
        ]),
      SynthModuleSection(title: "Banks", items: (0..<8).map {
        (title: "Pgm Bank \($0)", path: [.bank, .patch, .i($0)], controllerBlock: defaultBankEditorBlock())
        }),
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = MicronVoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is MicronGlobalPatch.Type:
      return "Global"
    case is MicronVoicePatch.Type:
      return "Patches"
    case is MiniakVoiceIndexPatch.Type:
      return "Patch TOC"
    case is MicronVoiceBank.Type:
      return "Voice Banks"
    default:
      return nil
    }
  }
  
  func defaultFilteredToolbarIdentifiers(forIndexPath indexPath: IndexPath) -> [String] {
    guard let synthPath = synthPath(forIndexPath: indexPath),
      let sysexType = synthEditor.sysexibleType(path: synthPath) else { return [] }
    switch sysexType {
    case is JSONBackedSysexPatch.Type:
      return ["name", "init", "random", "fetch", "send", "keys", "browser"]
    case is GlobalPatch.Type:
      return ["name", "init", "random", "keys"]
    case is PerfPatch.Type:
      return ["keys"]
    default:
      return []
    }
  }
  
  public func filteredToolbarIdentifiers(forIndexPath indexPath: IndexPath) -> [String] {
    switch indexPath {
    case IndexPath(item: 2, section: 0):
      // TOC
      return ["name", "init", "random", "send", "keys", "browser"]
    default:
      return defaultFilteredToolbarIdentifiers(forIndexPath: indexPath)
    }
  }
}


public class MiniakModule : MicronModule {

  override public class var manufacturer: String { return "Akai" }
  override public class var model: String { return "Miniak" }
  override public class var productId: String { return "a".k.a.i.dot.m.i.n.i.a.k }

  override public class var postAddMessage: String? { return nil }

  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#1695b5"),
    PBColor(hexString: "#ff2b75"),
    PBColor(hexString: "#ebc82f"),
    PBColor(hexString: "#de28fa"),
    ])
  override public class var colorGuide: ColorGuide { return _colorGuide }
}
