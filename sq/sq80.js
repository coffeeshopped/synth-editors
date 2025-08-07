public class SQ80Module : ESQ1Module {

  override public class var model: String { "SQ-80" }
  override public class var productId: String { "e".n.s.o.n.i.q.dot.s.q._8._0 }

  override func initEditor() {
    synthEditor = SQ80Editor(baseURL: tempURL)
  }
  
  override var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = ESQController.controller(sq80: true)
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

}
