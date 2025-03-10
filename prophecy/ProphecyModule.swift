
public class ProphecyModule : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Korg" }
  public class var model: String { return "Prophecy" }
  public class var productId: String { return "k".o.r.g.dot.p.r.o.p.h.e.c.y }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#abc123"),
    PBColor(hexString: "#81ff6c"),
    PBColor(hexString: "#ff97ad"),
    PBColor(hexString: "#00fff9"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = ProphecyEditor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { ProphecyGlobalController() }),
        (title: "Voice", path: [.patch], controllerBlock: defaultVoiceBlock(ProphecyVoiceController.self)),
        (title: "Arp", path: [.arp], controllerBlock: defaultVoiceBlock(ProphecyArpController.self)),
        ]),
      SynthModuleSection(title: "Banks", items:
                          (0..<2).map {
                            (title: "Voice Bank \(ProphecyVoiceBank.bankLetter($0))", path: [.bank, .patch, .i($0)], controllerBlock: defaultBankEditorBlock())
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
    case is ProphecyArpPatch.Type:
      return "Arps"
    case is VoiceBank.Type:
      return "Voice Banks"
    case is ProphecyArpBank.Type:
      return "Arp Banks"
    default:
      return nil
    }
  }
  
}
