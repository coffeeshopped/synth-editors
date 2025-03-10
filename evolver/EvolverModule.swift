
public class EvolverModule : TypicalSectionedSynthModule, SectionedSynthModule {  
  
  public static let manufacturer = "Dave Smith Instruments"
  public class var model: String { return "Evolver" }
  public class var productId: String { return "d".s.i.dot.e.v.o.l.v.e.r }
  
  public static let colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#e8bd2e"),
    PBColor(hexString: "#4080ff"),
    PBColor(hexString: "#a3e51e"),
    PBColor(hexString: "#ff6347"),
    ])
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)

  required public override init(uuid: String) {
    super.init(uuid: uuid)

    initEditor()
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: globalBlock),
        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
        (title: "Wave", path: [.wave], controllerBlock: waveBlock),
        ]),
      SynthModuleSection(title: "Voice Banks", items: [
        (title: "Bank 1", path: [.bank, .i(0)], controllerBlock: defaultBankEditorBlock()),
        (title: "Bank 2", path: [.bank, .i(1)], controllerBlock: defaultBankEditorBlock()),
        (title: "Bank 3", path: [.bank, .i(2)], controllerBlock: defaultBankEditorBlock()),
        (title: "Bank 4", path: [.bank, .i(3)], controllerBlock: defaultBankEditorBlock()),
        ]),
      SynthModuleSection(title: "Wave Bank", items: [
        (title: "Wave Bank", path: [.bank, .wave], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }
  
  func initEditor() {
    synthEditor = EvolverEditor(baseURL: tempURL)
  }
  
  var globalBlock: SynthModuleControllerBlock {
    return { EvolverGlobalController() }
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = EvolverKeysController.defaultInstance()
      let mainController = EvolverVoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  var waveBlock: SynthModuleControllerBlock {
    return {
      let keysController = EvolverKeysController.defaultInstance()
      let mainController = EvolverWaveController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is EvolverGlobalPatch.Type, is EvolverKeyGlobalPatch.Type:
      return "Global"
    case is EvolverVoicePatch.Type, is EvolverKeyVoicePatch.Type:
      return "Patches"
    case is EvolverWavePatch.Type:
      return "Waves"
    case is EvolverVoiceBank.Type, is EvolverKeyVoiceBank.Type:
      return "Voice Banks"
    case is EvolverWaveBank.Type:
      return "Wave Banks"
    default:
      return nil
    }
  }
  
}
