
public class MKS50Module : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Roland" }
  public class var model: String { return "MKS-50" }
  public class var productId: String { return "r".o.l.a.n.d.dot.m.k.s._5._0 }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#01b1cf"),
    PBColor(hexString: "#3a9fe3"),
    PBColor(hexString: "#dede21"),
    PBColor(hexString: "#e5592e"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = MKS50Editor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { ChannelSettingsController()} ),
        (title: "Tone", path: [.tone], controllerBlock: voiceBlock),
        (title: "Patch", path: [.patch], controllerBlock: patchBlock),
        (title: "Chord", path: [.chord], controllerBlock: chordBlock),
        ]),
      SynthModuleSection(title: "Bank", items: [
        (title: "Tone Bank a", path: [.bank, .tone, .i(0)], controllerBlock: defaultBankEditorBlock()),
        (title: "Tone Bank b", path: [.bank, .tone, .i(1)], controllerBlock: defaultBankEditorBlock()),
        (title: "Patch Bank A", path: [.bank, .patch, .i(0)], controllerBlock: defaultBankEditorBlock()),
        (title: "Patch Bank B", path: [.bank, .patch, .i(1)], controllerBlock: defaultBankEditorBlock()),
        (title: "Chord Bank", path: [.bank, .chord], controllerBlock: defaultBankEditorBlock()),
        ])
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = AlphaJunoVoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  var patchBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = MKS50PatchController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  var chordBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = MKS50ChordController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is ChannelSettingsPatch.Type:
      return "Global"
    case is VoicePatch.Type:
      return "Tones"
    case is VoiceBank.Type:
      return "Tone Banks"
    case is MKS50PatchPatch.Type:
      return "Patches"
    case is MKS50PatchBank.Type:
      return "Patch Banks"
    case is MKS50ChordPatch.Type:
      return "Chords"
    case is MKS50ChordBank.Type:
      return "Chord Banks"
    default:
      return nil
    }
  }
    
}

