
public class VirusCModule : TypicalSectionedSynthModule, SectionedSynthModule {  
  
  public static let manufacturer = "Access"
  public static let model = "Virus C"
  public static let productId = "a".c.c.e.s.s.dot.v.i.r.u.s.c
  
  public static let colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#e8bc29"),
    PBColor(hexString: "#ff783a"),
    PBColor(hexString: "#4d2dff"),
    PBColor(hexString: "#9bff28"),
  ])
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = VirusCEditor(baseURL: tempURL)

    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { return VirusCGlobalController()}),
        (title: "Single", path: [.patch], controllerBlock: voiceBlock()),
        ]),
      SynthModuleSection(title: "Multi", items: [
        (title: "Multi", path: [.multi], controllerBlock: multiBlock),
      ] + (0..<16).map { (
        title: "Part \($0 + 1)", path: [.part, .i($0)], controllerBlock: voiceBlock(multipart: true))
      }),
      SynthModuleSection(title: "Patch Banks", items: (0..<2).map {
        let title = "Bank " + ["A", "B"][$0]
        return (title: title, path: [.bank, .i($0)], controllerBlock: defaultBankEditorBlock())
      }),
      SynthModuleSection(title: "Multi Bank", items: [
        (title: "Multi Bank", path: [.multi, .bank], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }
  
  func voiceBlock(multipart: Bool = false) -> SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = VirusCVoiceController(multipart: multipart)
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  var multiBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysMIDIViewController.defaultInstance()
      let mainController = VirusCMultiController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is GlobalPatch.Type:
      return "Global"
    case is VoicePatch.Type:
      return "Patches"
    case is PerfPatch.Type:
      return "Multi"
    case is VoiceBank.Type:
      return "Voice Banks"
    case is PerfBank.Type:
      return "Multi Banks"
    default:
      return nil
    }
  }
    
}
