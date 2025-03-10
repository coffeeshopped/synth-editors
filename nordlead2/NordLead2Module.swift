
public class NordLead2Module : TypicalSectionedSynthModule, SectionedSynthModule, SynthModule {
  
  public static let manufacturer = "Clavia"
  public class var model: String { return "Nord Lead 2" }
  public class var productId: String  {
    return "c".l.a.v.i.a.dot.n.o.r.d.l.e.a.d._2
  }
  
  public static let colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#ed132e"),
    PBColor(hexString: "#ffcf58"),
    PBColor(hexString: "#3a84f5")
    ])
  
  public let defaultIndexPath = IndexPath(item: 0, section: 1)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)

    initEditor()
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Performance", path: [.perf], controllerBlock: { return NordLead2PerfController() }),
        ]),
      SynthModuleSection(title: "Slots", items: [
        (title: "Slot A", path: [.part, .i(0)], controllerBlock: voiceBlock),
        (title: "Slot B", path: [.part, .i(1)], controllerBlock: voiceBlock),
        (title: "Slot C", path: [.part, .i(2)], controllerBlock: voiceBlock),
        (title: "Slot D", path: [.part, .i(3)], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Banks", items: [
        (title: "Int Bank", path: [.bank, .voice, .i(0)], controllerBlock: defaultBankEditorBlock()),
        (title: "Card Bank 1", path: [.bank, .voice, .i(1)], controllerBlock: defaultBankEditorBlock()),
        (title: "Card Bank 2", path: [.bank, .voice, .i(2)], controllerBlock: defaultBankEditorBlock()),
        (title: "Card Bank 3", path: [.bank, .voice, .i(3)], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }
  
  func initEditor() {
    synthEditor = NordLead2Editor(baseURL: tempURL)
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return defaultVoiceBlock(NordLead2PaddedMainController.self)
  }

  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is NordLead2PerfPatch.Type:
      return "Performance"
    case is NordLead2VoicePatch.Type:
      return "Patches"
    case is NordLead2VoiceBank.Type:
      return "Voice Banks"
    default:
      return nil
    }
  }
  
}

public class NordLead2XModule : NordLead2Module {
  
  override public class var model: String {
    return "Nord Lead 2X"
  }
  override public class var productId: String  {
    return "c".l.a.v.i.a.dot.n.o.r.d.l.e.a.d._2.x
  }
  
  override func initEditor() {
    synthEditor = NordLead2XEditor(baseURL: tempURL)
  }
  
}

public class NordLead2NoPadModule : NordLead2Module {
  override var voiceBlock: SynthModuleControllerBlock {
    return defaultVoiceBlock(NordLead2MainController.self)
  }
}

public class NordLead2XNoPadModule : NordLead2XModule {
  override var voiceBlock: SynthModuleControllerBlock {
    return defaultVoiceBlock(NordLead2MainController.self)
  }
}
