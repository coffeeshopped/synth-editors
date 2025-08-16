
//struct JP8080VoiceController {
//  
//  static func autoMap(vc: FnPatchEditorController, control: PBLabeledControl, path: SynthPath) {
//    guard let ctrl = control as? JP8080MorphKnob else {
//      return vc.addBlocks(control: control, path: path)
//    }
//
//    vc.addDefaultParamChangeBlock(control: control, path: path)
//    
//    vc.addPatchChangeBlock { state in
//      guard !control.isTracking else { return }
//      
//      if let value = FnPatchEditorController.updatedValue(path: path, state: state) {
//        control.value = value
//      }
//      
//      if let value = FnPatchEditorController.updatedValue(path: path + [.velo], state: state) {
//        ctrl.setValue(value - 127, mode: .velo)
//      }
//      
//      if let value = FnPatchEditorController.updatedValue(path: path + [.ctrl], state: state) {
//        ctrl.setValue(value - 127, mode: .ctrl)
//      }
//    }
//
//    vc.addControlChangeBlock(control: ctrl, block: {
//      switch ctrl.mode {
//      case .velo:
//        return .paramsChange([path + [.velo] : ctrl.value(forMode: .velo) + 127])
//      case .ctrl:
//        return .paramsChange([path + [.ctrl] : ctrl.value(forMode: .ctrl) + 127])
//      default:
//        return .paramsChange([path : ctrl.value])
//      }
//    }, controlledPaths: [path, path + [.velo], path + [.ctrl]])
//    
//    vc.addColorBlock {
//      ctrl.setColor(FnPatchEditorController.tintColor(forColorGuide: $0, level: 1), mode: .velo)
//      ctrl.setColor(FnPatchEditorController.tintColor(forColorGuide: $0, level: 2), mode: .ctrl)
//    }
//  }
//  
//  static func morph(_ label: String) -> JP8080MorphKnob { JP8080MorphKnob(label) }
//  
//  static func mainController() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.prefixBlock = { [.patch, .i($0.index)] }
//      vc.autoMapper = autoMap
//
//      vc.addChild(filterController(), withPanel: "filter")
//      
//      let labeledNameField = LabeledTextField(label: "...")
//      vc.addIndexChangeBlock {
//        labeledNameField.label.text = $0 == 0 ? "Upper" : "Lower"
//      }
//      vc.nameTextField = labeledNameField.textField
//      vc.namePathBlock = { _ in [] }
//      vc.grid(panel: "name", items: [[(labeledNameField, nil)]])
//      
//      addLFOPanels(vc)
//      
//      addOscPanels(vc)
//
//      vc.grid(panel: "pitch", items: [[
//        (morph("Pitch Env"), [.pitch, .env, .depth]),
//        (morph("A"), [.pitch, .env, .attack]),
//        (morph("D"), [.pitch, .env, .decay]),
//        ],[
//        (morph("LFO 2"), [.pitch, .lfo, .i(1), .depth]),
//        (PBKnob("Bend Up"), [.bend, .up]),
//        (PBKnob("Down"), [.bend, .down]),
//      ]])
//
//      addEqPanel(vc)
//      
//      vc.grid(panel: "fx", prefix: [.fx], items: [[
//        (PBSelect("FX"), [.type]),
//        (morph("Level"), [.level]),
//      ]])
//
//      vc.grid(panel: "delay", prefix: [.delay], items: [[
//        (PBSwitch("Delay"), [.type]),
//        (morph("Time"), [.time]),
//        (morph("Feedback"), [.feedback]),
//        (morph("Level"), [.level]),
//      ]])
//
//      vc.grid(panel: "porta", prefix: [.porta], items: [[
//        (PBCheckbox("Porta"), [.on]),
//        (morph("Time"), [.time]),
//      ]])
//
//      vc.grid(panel: "mono", items: [[
//        (PBCheckbox("Mono"), [.mono]),
//        (PBCheckbox("Legato"), [.legato]),
//      ]])
//            
//      vc.grid(panel: "morph", items: [[
//        (PBCheckbox("Bend→Morph"), [.morph, .bend]),
//        (PBCheckbox("Velo"), [.velo, .on]),
//      ]])
//     
//      vc.grid(panel: "solo", items: [[
//        (PBSwitch("Solo Env Type"), [.solo, .env, .type]),
//        (PBCheckbox("Ext→Osc 2"), [.osc, .i(1), .ext]),
//        (PBCheckbox("V Mod Send"), [.voice, .mod, .send]),
//        (PBCheckbox("Ext Trig"), [.ext, .trigger, .on]),
//        (PBSwitch("←Dest"), [.ext, .trigger, .dest]),
//      ]])
//      
//      vc.grid(panel: "unison", items: [[
//        (PBCheckbox("Unison"), [.unison, .on]),
//        (PBKnob("Uni Detune"), [.unison, .detune]),
//      ]])
//
//      vc.addLayoutConstraints { layout in
//        layout.addRowConstraints([("name", 3), ("fx", 2.5), ("delay", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addRowConstraints([("eq", 3), ("osc0", 2), ("osc1", 3), ("filter", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addRowConstraints([("lfo1", 2), ("osc", 3), ("pitch", 3)], options: [.alignAllTop], pinned: false, spacing: "-s1-")
//        layout.addRowConstraints([("mono", 2), ("unison", 2), ("morph", 2), ("solo", 5)], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addColumnConstraints([("name", 1), ("eq", 1), ("lfo0", 1), ("lfo1", 1), ("porta", 1), ("mono", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addEqualConstraints(forItemKeys: ["eq", "lfo0"], attribute: .trailing)
//        layout.addEqualConstraints(forItemKeys: ["lfo0", "osc0", "osc1"], attribute: .bottom)
//        layout.addEqualConstraints(forItemKeys: ["lfo1", "porta"], attribute: .trailing)
//        layout.addEqualConstraints(forItemKeys: ["porta", "osc", "pitch", "filter"], attribute: .bottom)
//        layout.addEqualConstraints(forItemKeys: ["osc1", "pitch"], attribute: .trailing)
//      }
//      
//      vc.addColorToAll(level: 3)
//    }
//  }
//  
//  static func addOscPanels(_ vc: FnPatchEditorController) {
//    let osc0Ctrls = [ morph("Ctrl 1"), morph("Ctrl 2") ]
//    vc.grid(panel: "osc0", prefix: [.osc, .i(0)], items: [[
//      (PBSelect("Osc 1"), [.wave]),
//      ],[
//      (osc0Ctrls[0], [.ctrl, .i(0)]),
//      (osc0Ctrls[1], [.ctrl, .i(1)]),
//    ]])
//    
//    let osc0CtrlLabels: [(String, String)] = [
//      ("Detune", "Mix"),
//      ("Offset", "LFO1 Dpth"),
//      ("Cutoff", "Reson"),
//      ("Harmon", "Feedbk"),
//      ("PW", "PWM Dpth"),
//      ("Shape", "LFO1 Dpth"),
//      ("Shape", "LFO1 Dpth"),
//    ]
//    vc.addPatchChangeBlock(path: [.osc, .i(0), .wave]) {
//      guard $0 < osc0CtrlLabels.count else { return }
//      osc0Ctrls[0].label = osc0CtrlLabels[$0].0
//      osc0Ctrls[1].label = osc0CtrlLabels[$0].1
//    }
//
//    let osc1Wave = PBSwitch("Osc 2")
//    let osc1Ctrls = [ morph("Ctrl 1"), morph("Ctrl 2") ]
//    let sync = PBCheckbox("Sync")
//    let range = morph("Range")
//    let fine = morph("Fine")
//    vc.grid(panel: "osc1", prefix: [.osc, .i(1)], items: [[
//      (osc1Wave, [.wave]),
//      (osc1Ctrls[0], [.ctrl, .i(0)]),
//      (osc1Ctrls[1], [.ctrl, .i(1)]),
//      ],[
//      (sync, [.sync]),
//      (range, [.range]),
//      (fine, [.fine]),
//    ]])
//    
//    vc.addPatchChangeBlock(paths: [[.osc, .i(1), .wave], [.osc, .i(1), .ext]]) {
//      guard let wave = $0[[.osc, .i(1), .wave]],
//            let ext = $0[[.osc, .i(1), .ext]] else { return }
//      if ext == 1 {
//        osc1Ctrls[0].isHidden = false
//        osc1Ctrls[0].label = "Gate Thresh"
//        osc1Ctrls[1].isHidden = true
//      }
//      else {
//        switch wave {
//        case 0:
//          osc1Ctrls[0].label = osc0CtrlLabels[4].0
//          osc1Ctrls[1].label = osc0CtrlLabels[4].1
//          osc1Ctrls.forEach { $0.isHidden = false }
//        case 3:
//          osc1Ctrls[0].label = osc0CtrlLabels[2].0
//          osc1Ctrls[1].label = osc0CtrlLabels[2].1
//          osc1Ctrls.forEach { $0.isHidden = false }
//        default:
//          osc1Ctrls.forEach { $0.isHidden = true }
//        }
//      }
//    }
//    
//    vc.addPatchChangeBlock(path: [.osc, .i(1), .ext]) {
//      let alpha = $0 == 1 ? 0.4 : 1
//      [osc1Wave, range, fine].forEach { $0.alpha = alpha }
//    }
//    
//    vc.dims(view: sync, forPaths: [[.osc, .i(1), .wave], [.osc, .i(1), .ext]]) {
//      guard let wave = $0[[.osc, .i(1), .wave]],
//            let ext = $0[[.osc, .i(1), .ext]] else { return false }
//      return ext == 1 || wave == 3
//    }
//
//    vc.grid(panel: "osc", items: [[
//      (PBKnob("Oct Shft"), [.transpose]),
//      (PBCheckbox("Ring"), [.ringMod]),
//      (PBSwitch("LFO1/Env Dest"), [.pitch, .lfo, .i(0), .env, .dest]),
//      ],[
//      (morph("Osc Bal"), [.osc, .balance]),
//      (morph("X-Mod"), [.cross]),
//      (morph("LFO1 Depth"), [.pitch, .lfo, .i(0), .depth]),
//    ]])
//  }
//  
//  static func addLFOPanels(_ vc: FnPatchEditorController) {
//    vc.grid(panel: "lfo0", prefix: [.lfo, .i(0)], items: [[
//      (PBSwitch("LFO 1"), [.wave]),
//      (morph("Rate"), [.rate]),
//      (morph("Fade"), [.fade]),
//    ]])
//
//    vc.grid(panel: "lfo1", items: [[
//      (morph("LFO 2 Rate"), [.lfo, .i(1), .rate]),
//    ]])
//  }
//  
//  static func filterController() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.prefixBlock = { _ in [.filter] }
//      vc.autoMapper = autoMap
//      
//      let env = RolandEnvController.adsr(vc: vc, prefix: [.env], label: "Filter")
//      vc.grid(items: [[
//        (PBSwitch("Filter"), [.type]),
//        (PBSwitch("Slope"), [.slop]),
//        (morph("Cutoff"), [.cutoff]),
//        (morph("Reson"), [.reson]),
//        ],[
//        (morph("Key Follow"), [.key, .trk]),
//        (morph("LFO 1"), [.lfo, .i(0), .depth]),
//        (morph("LFO 2"), [.lfo, .i(1), .depth]),
//        ],[
//        (env, nil),
//        (morph("Env Depth"), [.env, .depth]),
//        ],[
//        (morph("A"), [.env, .attack]),
//        (morph("D"), [.env, .decay]),
//        (morph("S"), [.env, .sustain]),
//        (morph("R"), [.env, .release]),
//      ]])
//    }
//  }
//
//  static func ampController() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.prefixBlock = { _ in [.amp] }
//      vc.autoMapper = autoMap
//      
//      let env = RolandEnvController.adsr(vc: vc, prefix: [.env], label: "Amp")
//      vc.grid(items: [[
//        (morph("Level"), [.level]),
//        (PBSwitch("Gain"), [.gain]),
//        (morph("LFO 1"), [.lfo, .i(0), .depth]),
//        (morph("LFO 2"), [.lfo, .i(1), .depth]),
//      ],[
//        (env, nil),
//        (PBSwitch("Pan"), [.pan, .select]),
//      ],[
//        (morph("A"), [.env, .attack]),
//        (morph("D"), [.env, .decay]),
//        (morph("S"), [.env, .sustain]),
//        (morph("R"), [.env, .release]),
//      ]])
//    }
//  }
//  
//  static func addEqPanel(_ vc: FnPatchEditorController) {
//    vc.grid(panel: "eq", prefix: [.eq], items: [[
//      (morph("Bass"), [.lo]),
//      (morph("Treble"), [.hi]),
//    ]])
//  }
//  
//  static func addPitchEnvPanel(_ vc: FnPatchEditorController) {
//    vc.grid(panel: "pitch", items: [[
//      (morph("Pitch Env"), [.pitch, .env, .depth]),
//      (morph("A"), [.pitch, .env, .attack]),
//      (morph("D"), [.pitch, .env, .decay]),
//      (morph("LFO 2"), [.pitch, .lfo, .i(1), .depth]),
//    ]])
//  }
//
//}
