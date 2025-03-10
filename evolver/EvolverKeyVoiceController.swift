
class EvolverKeyVoiceController : EvolverVoiceController {

  override func initMainController() {
    mainController = MainController(keyModeControllerType: KeyModeController.self)
  }

  class KeyModeController : NewPatchEditorController {
        
    override func loadView(_ view: PBView) {
      let keyMode = PBSelect(label: "Key Mode")
      let voices = PBSwitch(label: "Voices")

      quickGrid(view: view, items: [[
        (PBKnob(label: "Transpose"), [.transpose], nil),
        (voices, [.key, .mode], "voices"),
        (keyMode, [.key, .mode], nil),
        ]])

      keyMode.options = EvolverVoicePatch.keyAssignOptions
      voices.options = [0 : "Poly", 1 : "Mono", 2 : "Unison 1", 3 : "Unison 2"]
      
      addPatchChangeBlock(path: [.key, .mode]) {
        keyMode.value = $0 % 6
        voices.value = $0 / 6
      }
      let ctrlBlock: (() -> Int) = { keyMode.value + (voices.value * 6) }
      addDefaultControlChangeBlock(control: keyMode, path: [.key, .mode], valueBlock: ctrlBlock)
      addDefaultControlChangeBlock(control: voices, path: [.key, .mode], valueBlock: ctrlBlock)
    }    
  }
  

}
