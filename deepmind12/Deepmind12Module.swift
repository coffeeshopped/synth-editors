
public class Deepmind12Module : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Behringer" }
  public class var model: String { return "Deepmind 12" }
  public class var productId: String { return "b".e.h.r.i.n.g.e.r.dot.d.e.e.p.m.i.n.d._1._2 }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#5f33ed"),
    PBColor(hexString: "#e57717"),
    PBColor(hexString: "#4a18ed"),
    PBColor(hexString: "#BAEA01"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 2, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = Deepmind12Editor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Connection", path: [.mode], controllerBlock: { Deepmind12ModeController() }),
        (title: "Global", path: [.global], controllerBlock: { Deepmind12GlobalController() }),
        (title: "Voice", path: [.patch], controllerBlock: defaultVoiceBlock(Deepmind12VoiceController.self)),
        (title: "Arp", path: [.arp], controllerBlock: defaultVoiceBlock(Deepmind12ArpController.self)),
        ]),
      SynthModuleSection(title: "Banks", items:
                          (0..<8).map {
                            (title: "Voice Bank \(Deepmind12VoiceBank.bankLetter($0))", path: [.bank, .patch, .i($0)], controllerBlock: defaultBankEditorBlock())
                          } + [
                            (title: "Arp Bank", path: [.bank, .arp], controllerBlock: defaultBankEditorBlock())
                          ]
        )
    ]
  }

  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is GlobalPatch.Type:
      return "Global"
    case is VoicePatch.Type:
      return "Patches"
    case is Deepmind12ArpPatch.Type:
      return "Arps"
    case is Deepmind12VoiceBank.Type:
      return "Voice Banks"
    case is Deepmind12ArpBank.Type:
      return "Arp Banks"
    default:
      return nil
    }
  }
  
}
