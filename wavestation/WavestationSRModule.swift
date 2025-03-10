
//public class WavestationSRModule : TypicalSectionedSynthModule, SectionedSynthModule {
//  
//  public class var manufacturer: String { return "Korg" }
//  public class var model: String { return "Wavestation SR" }
//  public class var productId: String { return "k".o.r.g.dot.w.a.v.e.s.t.a.t.i.o.n.s.r }
//  
//  private static let _colorGuide = ColorGuide(colors: [
//    PBColor(hexString: "#e99995"),
//    PBColor(hexString: "#7bb1e5"),
//    PBColor(hexString: "#a9b24e"),
////    PBColor(hexString: "#4a74f0"),
//    ])
//  public class var colorGuide: ColorGuide { return _colorGuide }
//  
//  public let defaultIndexPath = IndexPath(item: 1, section: 0)
//  
//  required public override init(uuid: String) {
//    super.init(uuid: uuid)
//    
//    synthEditor = WavestationSREditor(baseURL: tempURL)
//    
//    sections = [
//      SynthModuleSection(title: nil, items: [
//        (title: "Global", path: [.global], controllerBlock: { WavestationSRGlobalController() }),
//        (title: "Perf", path: [.perf], controllerBlock: perfBlock),
//        ]),
//      SynthModuleSection(title: "Parts", items: (0..<8).map {
//        (title: "Part \($0+1)", path: [.patch, .i($0)], controllerBlock: voiceBlock)
//        }),
//      SynthModuleSection(title: "Patch Banks", items: (0..<3).map {
//        (title: "Patch Bank \($0+1)", path: [.bank, .patch, .i($0)], controllerBlock: defaultBankEditorBlock())
//        }),
//      SynthModuleSection(title: "Wave Seq Banks", items: (0..<3).map {
//        (title: "Seq Bank \($0+1)", path: [.bank, .seq, .i($0)], controllerBlock: waveSeqBlock)
//        }),
//      
//      SynthModuleSection(title: "Perf Banks", items: (0..<3).map {
//        (title: "Perf Bank \($0+1)", path: [.bank, .perf, .i($0)], controllerBlock: defaultBankEditorBlock())
//        }),
//    ]
//  }
//  
//  var voiceBlock: SynthModuleControllerBlock {
//    return {
//      let keysController = BasicKeysViewController.defaultInstance()
//      let mainController = WavestationPatchController()
//      return PlayAdornedController(mainController: mainController, playController: keysController)
//    }
//  }
//
////  var perfBlock: SynthModuleControllerBlock {
//    return {
//      let keysController = BasicKeysViewController.defaultInstance()
//      let mainController = WavestationSRPerfController()
//      return PlayAdornedController(mainController: mainController, playController: keysController)
//    }
//  }
//
//  var waveSeqBlock: SynthModuleControllerBlock {
//    return {
//      let keysController = BasicKeysViewController.defaultInstance()
//      let mainController = WavestationSRWaveSeqBankController()
//      return PlayAdornedController(mainController: mainController, playController: keysController)
//    }
//  }
//
//  
//  public func path(forSysexType sysexType: Sysexible.Type) -> String? {
//    switch sysexType {
//    case is ChannelSettingsPatch.Type:
//      return "Global"
//    case is VoicePatch.Type:
//      return "Patches"
//    case is PerfPatch.Type:
//      return "Performances"
//    case is VoiceBank.Type:
//      return "Voice Banks"
//    case is PerfBank.Type:
//      return "Performance Banks"
//    case is WavestationSRWaveSeqBank.Type:
//      return "Wave Seq Banks"
//    default:
//      return nil
//    }
//  }
//  
////  public func patchNameOptions(forBankIndex index: Int) -> [Int:String]? {
////    var opts: [Int:String]?
////    switch index {
////    case 0...2:
////      guard let bank = synthEditor.sysexible(forPath: [.bank, .patch, .i(index)]) as? WavestationSRPatchBank else { return nil }
////      opts = OptionsParam.makeOptions(bank.patchNames)
////    default:
////      opts = WavestationSRPerfPatch.patchOptions[index - 3]
////    }
////    opts?[255] = "---"
////    return opts
////  }
//
//}
//
