
//struct JP8080PerfController : FnPopoverHostController {
//  
//  static func controller(popover: ModulePopoverPatchBrowserController) -> FnPagedEditorController {
//    ActivatedFnEditorController { vc in
//      vc.grid(panel: "key", prefix: [.common], items: [[
//        (PBSwitch("Key Mode"), [.key, .mode]),
//        (PBKnob("Split Pt"), [.split, .pt]),
//        (PBSwitch("Panel Select"), [.panel, .select]),
//        (PBKnob("Part Detune"), [.part, .detune]),
//        (PBSwitch("Out Assign"), [.out, .assign]),
//        (PBSelect("Voice Assign"), [.voice, .assign]),
//        (PBKnob("Tempo"), [.tempo]),
//        (PBSwitch("Input"), [.input])
//      ]])
//      
//      vc.grid(panel: "arp", prefix: [.common, .arp], items: [[
//        (PBCheckbox("Arp"), [.on]),
//        (PBSwitch("Dest"), [.dest]),
//        (PBSwitch("Mode"), [.mode]),
//        (PBSelect("Pattern"), [.pattern]),
//        (PBKnob("Oct Range"), [.range]),
//        (PBCheckbox("Hold"), [.hold]),
//      ]])
//      
//      vc.grid(panel: "trig", prefix: [.common, .trigger], items: [[
//        (PBCheckbox("Indiv Trig"), [.on]),
//        (PBSwitch("Dest"), [.dest]),
//        (PBKnob("Src Chan"), [.src, .channel]),
//        (PBKnob("Src Note"), [.src, .note]),
//      ]])
//      
//      vc.switchCtrl = PBSegmentedControl(items: ["Upper", "Lower", "Voice Mod", "2-Up"])
//      vc.grid(panel: "switch", items: [[(vc.switchCtrl, nil)]])
//
//      vc.addLayoutConstraints { layout in
//        layout.addGridConstraints([
//          (row: [("key", 8.5), ("arp", 6.5)], height: 1),
//          (row: [("switch", 6.5), ("trig", 4)], height: 1),
//          (row: [("page", 16)], height: 7),
//        ], spacing: "-s1-")
//      }
//      
//      vc.addColor(panels: ["key", "arp", "trig"], level: 1)
//      vc.addColor(panels: ["switch"], level: 1, clearBackground: true)
//      
//      vc.setControllerLogic([
//        [.part] : { partController(popover: popover) },
//        [.voice, .mod] : voiceModController,
//        [.up, .voice] : twoUpVoiceController,
//      ], indexMap: 2.map { [.part, .i($0)] } + [[.voice, .mod], [.up, .voice]])
//    }
//  }
//  
//  static func partController(popover: ModulePopoverPatchBrowserController) -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//
//      let ampContainer = ActivatedFnEditorController { vc in
//        vc.prefixBlock = { [.patch, .i($0.index)] }
//        vc.addChild(JP8080VoiceController.ampController(), withPanel: "amp")
//        vc.addColorToAll(level: 3)
//        vc.addLayoutConstraints { layout in
//          layout.addGridConstraints([[("amp", 1)]], pinMargin: "", spacing: "-s1-")
//        }
//      }
//
//      let indexSubs: [String:FnPatchEditorController] = [
//        "subpart" : subpartController(),
//        "voice" : JP8080VoiceController.mainController(),
//        "amp" : ampContainer,
//        "button" : patchButtonController(),
//        "load" : loadSaveController(popover: popover),
//      ]
//            
//      indexSubs.forEach { vc.addChild($0.value, withPanel: $0.key) }
//
//      vc.addIndexChangeBlock { index in
//        indexSubs.values.forEach { $0.index = index }
//      }
//
//      vc.grid(panel: "mode", items: [[(addMorphEdit(vc), nil)]])
//            
//      vc.addLayoutConstraints { layout in
//        layout.addRowConstraints([("voice", 12), ("subpart", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addRowConstraints([("mode", 1), ("button", 1.25), ("load", 1.75)], pinned: false, spacing: "-s1-")
//        layout.addColumnConstraints([("subpart", 2), ("amp", 3), ("mode", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addEqualConstraints(forItemKeys: ["voice", "button"], attribute: .bottom)
//        layout.addEqualConstraints(forItemKeys: ["subpart", "amp", "load"], attribute: .trailing)
//      }
//      
//      vc.addColor(panels: ["mode"], level: 3, clearBackground: true)
//    }
//  }
//  
//  static func addMorphEdit(_ vc: FnPatchEditorController) -> PBSwitch {
//    let morphCtrl = PBSwitch("Morph Edit")
//    morphCtrl.options = OptionsParam.makeOptions(["Off", "Velo", "Ctrl"])
//    vc.addCommandBlock(control: morphCtrl) { vc in
//      let morphs: [JP8080MorphKnob] = getSubviewsOf(view: vc.view)
//      let modes: [JP8080MorphKnob.Mode?] = [nil, .velo, .ctrl]
//      let nextMode = modes[morphCtrl.value]
//      morphs.forEach { $0.mode = nextMode }
//    }
//    return morphCtrl
//  }
//  
//  private static func getSubviewsOf<T: PBView>(view: PBView) -> [T] {
//    view.subviews.map {
//      var subviews = getSubviewsOf(view: $0) as [T]
//      if let subview = $0 as? T {
//        subviews.append(subview)
//      }
//      return subviews
//    }.reduce([], +)
//  }
//
//  static func patchButtonController() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.prefixBlock = { [.patch, .i($0.index)] }
//      let button = vc.createMenuButton(titled: "Edit")
//      vc.grid(pinMargin: "", items: [[(button, nil)]])
//      
//      vc.addColor(level: 3, clearBackground: true)
//      
//      let paths = JP8080VoicePatch.paramKeys()
//      vc.registerForEditMenu(button, bundle: (
//        paths: { paths },
//        pasteboardType: "com.cfshpd.JP8080VoicePatch",
//        initialize: nil,
//        randomize: {
//          let patch = JP8080VoicePatch.templatedPatchType.random()
//          return paths.map { patch[$0] ?? 0 }
//        }
//      ))
//    }
//  }
//  
//  static func loadSaveController(popover: ModulePopoverPatchBrowserController) -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.prefixBlock = { [.patch, .i($0.index)] }
//      let button = vc.createMenuButton(titled: "Load/Save")
//      vc.grid(pinMargin: "", items: [[(button, nil)]])
//      
//      vc.addColor(level: 3, clearBackground: true)
//      
//      let paths = JP8080VoicePatch.paramKeys()
//      setupPopoverHandlers(vc, popover: popover, paths: paths, patchTemplate: JP8080VoicePatch.self)
//      
//      vc.addCommandBlock(control: button, onClick: true) { vc in
//        vc.showBrowserPopover(popover, forView: button)
//      }
//    }
//  }
//  
//  static func subpartController() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.prefixBlock = { [.part, .i($0.index)] }
//      
//      let bankCtrl = PBSelect("Bank")
//      let pgmCtrl = PBSelect("Program")
//      
//      vc.grid(items: [[
//        (bankCtrl, nil),
//        (pgmCtrl, [.number]),
//        (PBKnob("Channel"), [.channel]),
//      ],[
//        (PBKnob("Transpose"), [.transpose]),
//        (PBKnob("Delay Sync"), [.delay, .sync]),
//        (PBKnob("LFO Sync"), [.lfo, .sync]),
//        (PBKnob("Chorus Sync"), [.chorus, .sync]),
//      ]])
//      
//      bankCtrl.options = OptionsParam.makeOptions(["In Perf", "User"] + 3.map { "Preset \($0 + 1)" } + 64.map { "Card \($0 + 1)"})
//      
//      let bankIso = FuzzyMiso.test()
//      vc.addPatchChangeBlock(paths: [[.bank], [.group]]) {
//        guard let bank = $0[[.bank]],
//              let group = $0[[.group]] else { return }
//        bankCtrl.value = bankIso.backward(bank, group).first?.lowerBound ?? 0
////        bankCtrl.value = bankValue(bank: bank, group: group)
//      }
//      vc.addControlChangeBlock(control: bankCtrl, block: {
//        let (bank, group) = bankIso.forward(bankCtrl.value)
////        let (bank, group) = bankParse(bankCtrl.value)
//        return .paramsChange([
//          [.bank] : bank ?? 0,
//          [.group] : group ?? 0,
//        ])
//      }, controlledPaths: [[.bank], [.group]])
//      
//      let presetOptions = 3.map { abOptions(JP8080VoicePatch.presetNames[$0]) }
//      let cardOptions = abOptions(128.map { "\($0 + 1)" })
//      vc.bankSelectOptions(control: pgmCtrl, paths: [[.bank], [.group]]) { values in
//        guard let bank = values[[.bank]],
//              let group = values[[.group]] else { return nil }
//        switch bank {
//        case 0:
//          return nil
//        case 1:
//          return [.patch, .name] as SynthPath
//        case 2:
//          guard group < 3 else { return nil }
//          return presetOptions[group]
//        default:
//          return cardOptions
//        }
//      }
//      
//      vc.addPatchChangeBlock(path: [.bank]) { pgmCtrl.isHidden = $0 == 0 }
//      
//      vc.addColor(level: 2)
//    }
//  }
//  
//  private static func abOptions(_ names: [String]) -> [Int:String] {
//    names.enumerated().dictionary { i, name in
//      [i : "\(JP8080VoiceBank.bankIndexToPrefix(i)): \(name)"]
//    }
//  }
//  
//  private static func bankParse(_ value: Int) -> (bank: Int, group: Int) {
//    switch value {
//    case 0:
//      return (0, 0)
//    case 1:
//      return (1, 0)
//    case 2...4:
//      return (2, value - 2)
//    default:
//      return (3, value - 5)
//    }
//  }
//  
//  private static func bankValue(bank: Int, group: Int) -> Int {
//    switch bank {
//    case 0:
//      return 0
//    case 1:
//      return 1
//    case 2:
//      return 2 + group
//    default:
//      return 5 + group
//    }
//  }
//  
//  static func voiceModController() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.prefixBlock = { _ in [.voice, .mod] }
//      
//      vc.grid(panel: "on", items: [[
//        (PBCheckbox("Voice Mod"), [.on]),
//        (PBCheckbox("Panel"), [.panel]),
//      ]])
//      
//      vc.grid(panel: "ens", prefix: [.chorus], items: [[
//        (PBSelect("Ensemble"), [.type]),
//        (PBKnob("Level"), [.level]),
//        (PBKnob("Sync"), [.sync]),
//      ]])
//
//      vc.grid(panel: "delay", prefix: [.delay], items: [[
//        (PBSwitch("Delay"), [.type]),
//        (PBKnob("Time"), [.time]),
//        (PBKnob("Feedbk"), [.feedback]),
//        (PBKnob("Level"), [.level]),
//        (PBKnob("Sync"), [.sync]),
//      ]])
//
//      vc.grid(panel: "algo", items: [[
//        (PBSwitch("Algo"), [.algo]),
//        (PBCheckbox("Ext>Inst"), [.ext, .instr]),
//        (PBCheckbox("Ext>Voc"), [.ext, .voice]),
//      ]])
//
//      vc.grid(panel: "mix", items: [[
//        (PBKnob("Voice Mix"), [.voice, .mix]),
//        (PBKnob("Reson"), [.reson]),
//        (PBKnob("Release"), [.release]),
//      ]])
//
//      vc.grid(panel: "pan", items: [[
//        (PBKnob("Pan"), [.pan]),
//        (PBKnob("Level"), [.level]),
//      ]])
//
//      vc.grid(panel: "ctrl", items: [[
//        (PBSelect("Ctrl 1"), [.ctrl, .i(0), .assign]),
//        (PBSelect("Ctrl 2"), [.ctrl, .i(1), .assign]),
//      ]])
//      
//      vc.grid(panel: "noise", prefix: [.noise], items: [[
//        (PBKnob("Nz Cutoff"), [.cutoff]),
//        (PBKnob("Level"), [.level]),
//      ]])
//
//      vc.grid(panel: "gate", items: [[
//        (PBKnob("Gate Thresh"), [.gate, .threshold]),
//      ]])
//
//      vc.grid(panel: "robot", prefix: [.robot], items: [[
//        (PBKnob("Robot Pitch"), [.pitch]),
//        (PBKnob("Ctrl"), [.ctrl]),
//        (PBKnob("Level"), [.level]),
//      ]])
//
//      vc.grid(panel: "morph", prefix: [.morph], items: [[
//        (PBCheckbox("Vocal Morph"), [.ctrl]),
//        (PBKnob("Thresh"), [.threshold]),
//        (PBKnob("Sens"), [.sens]),
//      ]])
//
//      vc.grid(panel: "char", prefix: [.character], items: [
//        12.map { (PBKnob($0 == 0 ? "Char 1" : "\($0 + 1)"), [.i($0)]) }
//      ])
//      
//      vc.createPanels(forKeys: ["top", "bottom"])
//
//      vc.addLayoutConstraints { layout in
//        layout.addGridConstraints([
//          [("top", 1)],
//          [("on", 2), ("ens", 3.5), ("delay", 5)],
//          [("algo", 3), ("mix", 3), ("pan", 2), ("ctrl", 3)],
//          [("noise", 2), ("gate", 1), ("robot", 3), ("morph", 3)],
//          [("char", 1)],
//          [("bottom", 1)],
//        ], pinMargin: "", spacing: "-s1-")
//      }
//      
//      vc.addColorToAll(except: ["top", "bottom"])
//
//    }
//  }
//  
//  static func twoUpVoiceController() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.addChildren(count: 2, panelPrefix: "pal") { index in
//        let palette = PaletteController.wrap(upVoiceController(), pasteType: "JP8080VoiceUp", vcHeight: 14) {
//          [.patch, .i($0.index)]
//        } buttonLabelBlock: {
//          $0 == 0 ? "Upper" : "Lower"
//        }
//        palette.index = index
//        return palette
//      }
//      vc.addLayoutConstraints { layout in
//        layout.addGridConstraints([2.map { ("pal\($0)", 1) }], pinMargin: "", spacing: "-s1-")
//      }
//    }
//  }
//  
//  static func upVoiceController() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.autoMapper = JP8080VoiceController.autoMap
//
//      JP8080VoiceController.addOscPanels(vc)
//      JP8080VoiceController.addLFOPanels(vc)
//      JP8080VoiceController.addPitchEnvPanel(vc)
//      JP8080VoiceController.addEqPanel(vc)
//      vc.addChild(JP8080VoiceController.filterController(), withPanel: "filter")
//      vc.addChild(JP8080VoiceController.ampController(), withPanel: "amp")
//
//      vc.grid(panel: "velo", items: [[
//        (PBCheckbox("Velo"), [.velo, .on]),
//      ]])
//      
//      
//      vc.grid(panel: "mode", items: [[(addMorphEdit(vc), nil)]])
//      
//      vc.addLayoutConstraints { layout in
//        layout.addRowConstraints([("osc0", 2), ("osc1", 3), ("osc", 3)], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addRowConstraints([("filter", 4), ("pitch", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addRowConstraints([("mode", 1), ("velo", 1), ("lfo0", 3), ("lfo1", 1), ("eq", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addColumnConstraints([("osc0", 2), ("filter", 4), ("mode", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addColumnConstraints([("pitch", 1), ("amp", 3)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
//        layout.addEqualConstraints(forItemKeys: ["filter", "amp"], attribute: .bottom)
//      }
//      
//      vc.addColorToAll(except: ["mode"], level: 3)
//      vc.addColor(panels: ["mode"], level: 3, clearBackground: true)
//      vc.addBorder(level: 3)
//    }
//  }
//  
//
//}
