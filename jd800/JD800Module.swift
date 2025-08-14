
public class JD800Module : TypicalSectionedSynthModule, SectionedSynthModule, RolandSynthModule {
  
  public class var model: String { return "JD-800" }
  public class var productId: String  { return "r".o.l.a.n.d.dot.j.d._8._0._0 }
  
  public static let colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#8adb2d"),
    PBColor(hexString: "#a915e8"),
    PBColor(hexString: "#9aec2c"),
    PBColor(hexString: "#a60bff"),
    ])
  
  // Patch
  public let defaultIndexPath = IndexPath(item: 2, section: 0)
  
  override required public init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = JD800Editor(baseURL: tempURL)

    var partItems: [SynthModuleSectionItem] = (0..<5).map {
      (title: "Part \($0 + 1)", path: [.part, .i($0)], controllerBlock: voicePartBlock)
    }
    partItems.append((title: "Special Setup", path: [.rhythm], controllerBlock: { JD800SpecialSetupController() }))

    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Config", path: [.deviceId], controllerBlock: { JD800SettingsController() }),
        (title: "System", path: [.global], controllerBlock: { JD800SystemController() }),
        (title: "Patch", path: [.patch], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Multi", items: [
        (title: "Parts", path: [.perf], controllerBlock: { JD800PartsController() }),
        ] + partItems),
      SynthModuleSection(title: "Banks", items: [
        (title: "Patch Bank", path: [.bank, .patch], controllerBlock: defaultBankEditorBlock()),
        (title: "Special Setup Bank", path: [.bank, .rhythm], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = JD800VoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  var voicePartBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = JD800VoiceController()
      mainController.hideFX()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is RolandDeviceIdSettingsPatch.Type:
      return "Device Id"
    case is GlobalPatch.Type:
      return "Global"
    case is VoicePatch.Type:
      return "Patches"
    case is PerfPatch.Type:
      return "Parts"
    case is RhythmPatch.Type:
      return "Rhythm"
    case is VoiceBank.Type:
      return "Voice Banks"
    case is RhythmBank.Type:
      return "Special Setup Banks"
    default:
      return nil
    }
  }
  
}


