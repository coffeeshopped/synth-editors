
public class VirusTISnowModule : TypicalSectionedSynthModule, VirusTISeriesModule {
  
  public static let model = "Virus TI Snow"
  public static let productId = "a".c.c.e.s.s.dot.v.i.r.u.s.t.i.s.n.o.w
  
  required public override init(uuid: String) {
    super.init(uuid: uuid)
    
    synthEditor = VirusTISnowEditor(baseURL: tempURL)

    sections = [
      SynthModuleSection(title: nil, items: [
        (title: "Global", path: [.global], controllerBlock: { return VirusTISnowGlobalController()}),
        (title: "Single", path: [.patch], controllerBlock: voiceBlock),
        (title: "Multi", path: [.multi], controllerBlock: multiBlock),
        ]),
      SynthModuleSection(title: "Patch Banks", items: (0..<4).map {
        let title = "RAM \(($0 * 2) + 1) / \(($0 * 2) + 2)"
        return (title: title, path: [.bank, .i($0)], controllerBlock: defaultBankEditorBlock())
      }),
      SynthModuleSection(title: "Multi Bank", items: [
        (title: "RAM", path: [.multi, .bank], controllerBlock: defaultBankEditorBlock()),
        ]),
    ]
  }
  
  var multiBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysMIDIViewController.defaultInstance()
      let mainController = VirusTISnowMultiController()
      
      let sp = PopoverPatchBrowserController.defaultInstance()
      sp.setModule(self)
      sp.browsePath = [.patch]

      mainController.partController.voiceController.popover = sp

      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }
  
}
