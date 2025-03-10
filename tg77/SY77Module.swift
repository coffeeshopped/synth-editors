
public class SY77Module : TG77Module {

  override public class var model: String { return "SY77" }
  override public class var productId: String { return "y".a.m.a.h.a.dot.s.y._7._7 }

  override func initEditor() {
    synthEditor = SY77Editor(baseURL: tempURL)
  }
  
  override var voiceBlock: SynthModuleControllerBlock {
    return {
      let keysController = BasicKeysViewController.defaultInstance()
      let mainController = TG77VoiceController(hideIndivOut: true)
      return PlayAdornedController(mainController: mainController, playController: keysController)
    }
  }

  override var multiBlock: SynthModuleControllerBlock {
    return { return SY77MultiController(hideIndivOut: true) }
  }


}
