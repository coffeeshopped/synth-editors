
public class BassStationIIModule : TypicalSectionedSynthModule, SectionedSynthModule {
  
  public class var manufacturer: String { return "Novation" }
  public class var model: String { return "Bass Station II" }
  public class var productId: String { return "n".o.v.a.t.i.o.n.dot.b.a.s.s.s.t.a.t.i.o.n.i.i }
  
  private static let _colorGuide = ColorGuide(colors: [
    PBColor(hexString: "#5DE8E4"),
    PBColor(hexString: "#40d2ff"),
    PBColor(hexString: "#26ffba"),
    PBColor(hexString: "#809fff"),
    ])
  public class var colorGuide: ColorGuide { return _colorGuide }
  
  public let defaultIndexPath = IndexPath(item: 1, section: 0)
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = BassStationIIEditor(baseURL: tempURL)
    
    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { ChannelSettingsController() }),
        (title: "Voice", path: [.patch], controllerBlock: voiceBlock),
        (title: "Overlay", path: [.extra], controllerBlock: overlayBlock),
        ]),
      SynthModuleSection(title: "Banks", items: [
        (title: "Voice Bank", path: [.bank, .patch], controllerBlock: defaultBankEditorBlock()),
        (title: "Overlay Bank", path: [.bank, .extra], controllerBlock: defaultBankEditorBlock()),
        ])
    ]
  }
  
  var voiceBlock: SynthModuleControllerBlock {
    return defaultVoiceBlock(BassStationIIVoiceController.self)
  }
  
  var overlayBlock: SynthModuleControllerBlock {
    return {
//      let keysController = BasicKeysMIDIViewController  .defaultInstance()
      let mainController = BassStationIIOverlayController()
      
      let sp = PopoverPatchBrowserController.defaultInstance()
      sp.setModule(self)
      sp.browsePath = [.patch]
      // TODO: might not be necessary
      sp.set(colorManager: RxColorManager(module: self))

      mainController.keyController.popover = sp
      return mainController
//      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
    switch sysexType {
    case is ChannelSettingsPatch.Type:
      return "Global"
    case is BassStationIIVoicePatch.Type:
      return "Patches"
    case is BassStationIIOverlayPatch.Type:
      return "Overlays"
    case is BassStationIIVoiceBank.Type:
      return "Voice Banks"
    case is BassStationIIOverlayBank.Type:
      return "Overlay Banks"
    default:
      return nil
    }
  }
  
}
