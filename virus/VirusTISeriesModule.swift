
protocol VirusTISeriesModule : SectionedSynthModule { }

extension VirusTISeriesModule {
  
  public static var manufacturer: String { return "Access" }

  public static var colorGuide: ColorGuide {
    return ColorGuide(colors: [
      PBColor(hexString: "#e8bc29"),
      PBColor(hexString: "#ff783a"),
      PBColor(hexString: "#4d2dff"),
      PBColor(hexString: "#9bff28"),
    ])
  }
  
  public var defaultIndexPath: IndexPath { return IndexPath(item: 1, section: 0) }

  var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = VirusTISnowVoiceController()
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
