
public class DX200Module : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Yamaha" }
  public class var model: String { return "DX200" }
  public class var productId: String { return "y".a.m.a.h.a.dot.d.x._2._0._0 }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#dfdfcf"),
    PBColor(hexString: "#0084e4"),
    PBColor(hexString: "#e53a37"),
    PBColor(hexString: "#c23d9e"),
    ])
  public class var colorGuide: ColorGuide { _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 2, section: 0)
  
  required override public init(uuid uid: String) {
    super.init(uuid: uid)
    
    synthEditor = DX200Editor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Device #", path: [.global], controllerBlock: { TX802GlobalController() }),
        (title: "System", path: [.system], controllerBlock: { DX200SystemController() }),
        (title: "Pattern", path: [.patch], controllerBlock: voiceBlock),
        ]),
      SynthModuleSection(title: "Banks", items: [
        (title: "Pattern Bank", path: [.bank], controllerBlock: defaultBankEditorBlock()),
        ])
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return { [unowned self] in
      let keysController = StartStopKeysController.defaultInstance()
      let mainController = DX200PatternController()

      let sp = FnPopoverPatchBrowserController()
      sp.set(module: self, browsePath: [.voice])
      sp.sysexibleSelectedHandler = { [unowned self] (patch) in
        let pc: PatchChange = .replace(patch)
        self.synthEditor.changePatch(forPath: [.patch], pc.prefixed([.voice, .voice]), transmit: true)
      }
      sp.sysexibleSaveHandler = { [unowned self] in
        let pattern = self.synthEditor.sysexible(forPath: [.patch]) as! DX200PatternPatch
        return pattern.subpatches[[.voice, .voice]]!
      }

      mainController.synthPopover = sp
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is ChannelSettingsPatch.Type:
      return "Device Id"
    case is DX200PatternPatch.Type:
      return "Patterns"
    case is DX200PatternBank.Type:
      return "Pattern Banks"
    case is DX200SystemPatch.Type:
      return "System"
    case is TX802VoicePatch.Type, is DX200VoicePatch.Type:
      return "DX7 Patches"
    case is TX802VoiceBank.Type, is DX200VoiceBank.Type:
      return "DX7 Banks"
    default:
      return nil
    }
  }
  
}
