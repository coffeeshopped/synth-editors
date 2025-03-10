
public class CircuitModule : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Novation" }
  public class var model: String { return "Circuit" }
  public class var productId: String { return "n".o.v.a.t.i.o.n.dot.c.i.r.c.u.i.t }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#8733ea"),
    PBColor(hexString: "#f59e33"),
    PBColor(hexString: "#30e5a3"),
    PBColor(hexString: "#4a74f0"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = CircuitEditor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { CircuitGlobalController() }),
        (title: "Synth 1", path: [.patch, .i(0)], controllerBlock: voiceBlock),
        (title: "Synth 2", path: [.patch, .i(1)], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Banks", items: [
        (title: "Synth Bank", path: [.bank, .patch], controllerBlock: defaultBankEditorBlock()),
        ])
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = CircuitVoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is CircuitGlobalPatch.Type:
      return "Global"
    case is CircuitSynthPatch.Type:
      return "Patches"
    case is CircuitSynthBank.Type:
      return "Voice Banks"
    default:
      return nil
    }
  }
  
}
