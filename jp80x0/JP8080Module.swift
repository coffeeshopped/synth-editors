
//public struct JP8080Module : TypedSynthModuleTemplate {
//  
//  public typealias EditorTemplate = JP8080Editor
//  
//  public static var manu: Manufacturer = .roland
//  public static let model = "JP-8080"
//  public static let modelId: String = "j".p._8._0._8._0
//  
//  public static let colorGuide = ColorGuide([
//    "#00c76f",
//    "#f4a369",
//    "#95626e",
//    "#627095",
//    ])
//
//  public static let defaultIndexPath: IndexPath = IndexPath(item: 0, section: 1)
//
//  public static let sections: [SynthModuleTemplateSection] = [
//    (nil, items: [
//      ("Device ID", path: [.deviceId], controllerBlock: { _ in RolandDeviceIdSettingsController() }),
//      ("Global", path: [.global], controllerBlock: { _ in JP8080GlobalController.controller() }),
//      ("Performance", path: [.perf], controllerBlock: perfBlock),
//      ]),
//    ("Banks", items: [
//      ("Perf Bank", path: [.bank, .perf], controllerBlock: defaultBankEditorBlock()),
//      ("Patch Bank", path: [.bank, .patch], controllerBlock: defaultBankEditorBlock()),
//      ]),
//    ("Backup", items: [
//      ("Backup", path: [.backup], controllerBlock: defaultBackupEditorBlock()),
//      ]),
//  ]
//
//  static var perfBlock: SynthModuleTemplateControllerBlock {
//    return {
//      let keysController = BasicKeysMIDIViewController.defaultInstance()
//      
//      let popover = FnPopoverPatchBrowserController()
//      popover.set(module: $0, sysexType: JP8080VoicePatch.templatedPatchType)
//      let mainController = JP8080PerfController.controller(popover: popover)
//      
//      return PlayAdornedController(mainController: mainController, playController: keysController)
//    }
//  }
//
//  public static func directory(templateType: SysexTemplate.Type) -> String? { nil }
//}
