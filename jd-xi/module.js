const { bankCtrlr, backupCtrlr } = require('/core/Controller.js')

module.exports = {
  EditorTemplate: require('editor.js'),
  
  colorGuide: [
    "#00c76f",
    "#f23518",
    "#1868f2",
    "#abe817",
    ],
      
  sections: [
    [null, [
      ["Global", ["global"], global],
      ["Voice", ["patch"], () => KeyController.controller(main(), {})],
    ]],
    ["Voice Bank", [
      ["Bank 1", ["bank", 0], bankCtrlr],
      ["Bank 2", ["bank", 1], bankCtrlr],
      ["Bank 3", ["bank", 2], bankCtrlr],
    ]],
    ["Backup", [
      ["Backup", ["backup"], backupCtrlr], 
    ]]
  ]
  // makeSections(require('./controller/global.js'), require('./controller/main.js')),
}


// public struct JDXiModule : TypedSynthModuleTemplate {
//   public static let defaultIndexPath: IndexPath = IndexPath(item: 0, section: 1)
// 
//   public static let sections: [SynthModuleTemplateSection] = [
//     (nil, items: [
//       ("Global", path: [.global], controllerBlock: { _ in JDXiGlobalController.controller() }),
//       ("Program", path: [.perf], controllerBlock: programBlock),
//       ("Full Program", path: [.extra, .perf], controllerBlock: { _ in FullRefEditorController.defaultInstance() }),
//       ]),
//     ("Parts", items: [
//       ("Digital 1", path: [.digital, .i(0)], controllerBlock: digitalBlock),
//       ("Digital 2", path: [.digital, .i(1)], controllerBlock: digitalBlock),
//       ("Analog", path: [.analog], controllerBlock: analogBlock),
//       ("Drums", path: [.rhythm], controllerBlock: rhythmBlock),
//       ]),
//     ("Banks", items: [
//       ("Prgm Bank 1", path: [.bank, .perf, .i(0)], controllerBlock: defaultBankEditorBlock()),
//       ("Prgm Bank 2", path: [.bank, .perf, .i(1)], controllerBlock: defaultBankEditorBlock()),
//       ("Digital Bank 1", path: [.bank, .digital, .i(0)], controllerBlock: defaultBankEditorBlock()),
//       ("Digital Bank 2", path: [.bank, .digital, .i(1)], controllerBlock: defaultBankEditorBlock()),
//       ("Digital Bank 3", path: [.bank, .digital, .i(2)], controllerBlock: defaultBankEditorBlock()),
//       ("Digital Bank 4", path: [.bank, .digital, .i(3)], controllerBlock: defaultBankEditorBlock()),
//     ] + 2.map { ("Analog Bank \($0 + 1)", path: [.bank, .analog, .i($0)], controllerBlock: defaultBankEditorBlock()) }
//      + 2.map { ("Drum Bank \($0 + 1)", path: [.bank, .rhythm, .i($0)], controllerBlock: defaultBankEditorBlock()) }
//     ),
//     ("Backup", items: [
//       ("Backup", path: [.backup], controllerBlock: defaultBackupEditorBlock()),
//       ]),
//   ]
//   
//   static var programBlock: SynthModuleTemplateControllerBlock {
//     return { _ in
//       let keysController = BasicKeysMIDIViewController.defaultInstance()
//       let mainController = JDXiProgramController.controller()
//       return PlayAdornedController(mainController: mainController, playController: keysController)
//     }
//   }
// 
//   static var digitalBlock: SynthModuleTemplateControllerBlock {
//     return { _ in
//       let keysController = BasicKeysViewController.defaultInstance()
//       let mainController = JDXiDigitalController.controller()
//       return PlayAdornedController(mainController: mainController, playController: keysController)
//     }
//   }
// 
//   static var analogBlock: SynthModuleTemplateControllerBlock {
//     return { _ in
//       let keysController = BasicKeysViewController.defaultInstance()
//       let mainController = JDXiAnalogController.controller()
//       return PlayAdornedController(mainController: mainController, playController: keysController)
//     }
//   }
// 
//   public static var rhythmBlock: SynthModuleTemplateControllerBlock {
//     {
//       let popover = FnPopoverPatchBrowserController()
//       popover.set(module: $0, browsePath: [.rhythm, .partial])
//       return JDXiDrumsController.controller(popover: popover)
//     }
//   }
// 
// 
//   public static func directory(templateType: SysexTemplate.Type) -> String? {
//     switch templateType {
//     case is JDXiGlobalPatch.Type:
//       return "Global"
//     case is JDXiProgramPatch.Type:
//       return "Programs"
//     case is JDXiDigitalPatch.Type:
//       return "Digital"
//     case is JDXiAnalogPatch.Type:
//       return "Analog"
//     case is JDXiDrumPatch.Type:
//       return "Drums"
//     case is JDXiProgramBank.Type:
//       return "Program Banks"
//     case is JDXiDigitalBank.Type:
//       return "Digital Banks"
//     case is JDXiAnalogBank.Type:
//       return "Analog Banks"
//     case is JDXiDrumBank.Type:
//       return "Drum Banks"
//     case is FullPerf.Type:
//       return "Full Programs"
//     case is JDXiDrumPatch.PartialPatch.Type:
//       return "Drum Partials"
//     default:
//       return nil
//     }
//   }
//   
// }
