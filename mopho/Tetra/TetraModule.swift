
public struct TetraModule : TypedSynthModuleTemplate {
  public typealias EditorTemplate = TetraEditor

  public static let manu: Manufacturer = .dsi
  public static let model = "Tetra"
  public static let modelId = "t".e.t.r.a
  
  public static let colorGuide = ColorGuide([
    "#FDC63F",
    "#4080ff",
    "#a3e51e",
    "#ff6347",
  ])
  
  public static let sections: [SynthModuleTemplateSection] = [
    (nil, [
      ("Global", [.global], { _ in TetraGlobalController() }),
      ("Voice", [.patch], defaultVoiceBlock({ _ in TetraVoiceController.controller() })),
      ("Combo", [.perf], { _ in PBViewController() }), // dummy block
      ]),
    ("Banks", [
      ("Bank 1", [.bank, .i(0)], defaultBankEditorBlock()),
      ("Bank 2", [.bank, .i(1)], defaultBankEditorBlock()),
      ("Bank 3", [.bank, .i(2)], defaultBankEditorBlock()),
      ("Bank 4", [.bank, .i(3)], defaultBankEditorBlock()),
      ("Combo Bank", [.bank, .perf], defaultBankEditorBlock()),
      ]),
  ]
    
  public static func viewController(_ module: TemplatedModule, forIndexPath indexPath: IndexPath) -> PBViewController {
    guard indexPath.section == 0 && indexPath.row == 2 else { return defaultViewController(module, forIndexPath: indexPath) }
    
    if module.controllers[indexPath] == nil {
      let popover = FnPopoverPatchBrowserController()
      popover.set(module: module, browsePath: [.patch])
      let voiceBlock = defaultVoiceBlock({ _ in
        TetraComboController.controller(popover: popover)
      })
      module.controllers[indexPath] = voiceBlock(module)
    }
    return module.controllers[indexPath]!
  }
  
  public static func directory(templateType: SysexTemplate.Type) -> String? {
    switch templateType {
    case is TetraGlobalPatch.Type:
      return "Global"
    case is TetraVoicePatch.Type:
      return defaultPatchDirectory
    case is TetraComboPatch.Type:
      return "Combos"
    case is TetraVoiceBank.Type:
      return "Voice Banks"
    case is TetraComboBank.Type:
      return "Combo Banks"
    default:
      return nil
    }
  }
    
}
