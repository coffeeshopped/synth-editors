
//class TX802OpController : DX7OpController {
//  
//  override open var prefix: SynthPath? { return [.voice, .op, .i(index)] }
//
//  override func initAmpMod() {
//    let ampModKnob = self.ampModKnob
//    addPatchChangeBlock { [weak self] (changes) in
//      guard let index = self?.index else { return }
//      guard let value = Self.updatedValueForFullPath([.extra, .op, .i(index), .amp, .mod], state: changes) else { return }
//      ampModKnob.value = value
//    }
//    addParamChangeBlock { [weak self] (params) in
//      guard let index = self?.index,
//            let param = params.params[[.extra, .op, .i(index), .amp, .mod]] else { return }
//      self?.defaultConfigure(control: ampModKnob, forParam: param)
//    }
//    // TODO: this is not working right
//    addDefaultControlChangeBlock(control: ampModKnob, path: [.amp, .mod])
//  }
//
//
//}
