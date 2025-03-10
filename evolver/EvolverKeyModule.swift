
public class EvolverKeyModule : EvolverModule {
  
  override public class var model: String { return "Evolver Keys" }
  override public class var productId: String { return "d".s.i.dot.e.v.o.l.v.e.r.k.e.y }
  
  override func initEditor() {
    synthEditor = EvolverKeyEditor(baseURL: tempURL)
  }

  override var globalBlock: SynthModuleControllerBlock {
    return { EvolverKeyGlobalController() }
  }
  
  override var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = EvolverKeysController.defaultInstance()
      let mainController = EvolverKeyVoiceController()
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

}
