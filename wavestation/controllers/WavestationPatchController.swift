
//class WavestationPatchController : NewPagedEditorController {
//    
//  private let mixController = MixController()
//  private let voiceController = VoiceController()
//  
//  override func loadView(_ view: PBView) {
//    createPanels(forKeys: ["switch", "levels"])
//    addPanelsToLayout(andView: view)
//    
//    layout.addRowConstraints([
//      ("switch", 6), ("levels", 10),
//      ], pinned: true, spacing: "-s1-")
//    layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
//    layout.addColumnConstraints([
//      ("switch",1),("page",8),
//      ], pinned: true, spacing: "-s1-")
//    
//    let switchCtrl = PBSegmentedControl(items: ["Mix", "A", "B", "C", "D"])
//    self.switchCtrl = switchCtrl
//    quickGrid(panel: "switch", pinMargin: "-1-", items: [[(switchCtrl, nil, "switchCtrl")]])
//    
//    addPatchChangeBlock { (changes) in
//      guard let value = Self.updatedValue(path: [.structure], state: changes) else { return }
//      switchCtrl.setEnabled(value == 2, forSegmentAt: 2) // B
//      switchCtrl.setEnabled(value > 0, forSegmentAt: 3) // C
//      switchCtrl.setEnabled(value == 2, forSegmentAt: 4) // D
//    }
//  }
//  
////  override func apply(colorGuide: ColorGuide) {
////    view.backgroundColor = backgroundColor(forColorGuide: colorGuide)
////    colorAllPanels(colorGuide: colorGuide)
////    panels["switch"]?.backgroundColor = .clear
////  }
//
//  override func viewController(forIndex index: Int) -> PBViewController? {
//    switch index {
//    case 0:
//      return mixController
//    default:
//      voiceController.index = index - 1
//      return voiceController
//    }
//  }
//    
//  
//  class MixController : NewPatchEditorController {
//  
//    private let a: [PBLabeledValue] = (0..<5).map { PBLabeledValue(label: "A\($0)") }
//    private let b: [PBLabeledValue] = (0..<5).map { PBLabeledValue(label: "B\($0)") }
//    private let c: [PBLabeledValue] = (0..<5).map { PBLabeledValue(label: "C\($0)") }
//    private let d: [PBLabeledValue] = (0..<5).map { PBLabeledValue(label: "D\($0)") }
//
//    override func loadView() {
//      let paddedView = PaddedContainer()
//      paddedView.horizontalPadding = 0.1
//      paddedView.verticalPadding = 0.06
//      let view = paddedView.mainView
//
//      createPanels(forKeys: ["struct", "env", "mod", "space1", "space2"])
//      addPanelsToLayout(andView: view)
//      
//      layout.addRowConstraints([
//        ("struct", 1), ("env", 5), ("mod", 5),
//        ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
//      layout.addColumnConstraints([
//        ("struct", 2), ("space1", 5),
//        ], options: [.alignAllLeading, .alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")
//      layout.addColumnConstraints([
//        ("mod", 3), ("space2", 4),
//        ], options: [.alignAllLeading, .alignAllTrailing], spacing: "-s1-")
//
//      layout.addEqualConstraints(forItemKeys: ["space1", "env", "space2"], attribute: .bottom)
//
//      quickGrid(panel: "struct", items: [[
//        (PBSwitch(label: "Structure"), [.structure], nil),
//        ],[
//        (PBCheckbox(label: "Hard Sync"), [.sync], nil),
//        ]])
//
//      var ctrls: [[(PBView, SynthPath?, String?)]] = [[
//        (LabelItem(text: nil, gridWidth: 2), nil, "rspace"),
//        (PBKnob(label: "R1"), [.mix, .rate, .i(0)], nil),
//        (PBKnob(label: "R2"), [.mix, .rate, .i(1)], nil),
//        (PBKnob(label: "R3"), [.mix, .rate, .i(2)], nil),
//        (PBKnob(label: "R4"), [.mix, .rate, .i(3)], nil),
//      ]]
//      
//      var bdCtrls = [PBView]()
//
//      ctrls.append((0..<5).map { (PBKnob(label: "AC\($0)"), [.mix, .ac, .i($0 - 1)], nil) })
//      ctrls.append((0..<5).map {
//        let knob = PBKnob(label: "BD\($0)")
//        bdCtrls.append(knob)
//        return (knob, [.mix, .bd, .i($0 - 1)], nil)
//      })
//      ctrls.append((0..<5).map { (a[$0], nil, "a\($0)") })
//      ctrls.append((0..<5).map { (b[$0], nil, "b\($0)") })
//      ctrls.append((0..<5).map { (c[$0], nil, "c\($0)") })
//      ctrls.append((0..<5).map { (d[$0], nil, "d\($0)") })
//      
//      bdCtrls.append(contentsOf: b)
//      bdCtrls.append(contentsOf: d)
//      
//      quickGrid(panel: "env", items: ctrls)
//
//      let bdMod1 = PBSelect(label: "BD Mod 1")
//      let bdModAmt1 = PBKnob(label: "Amt")
//      let bdMod2 = PBSelect(label: "BD Mod 2")
//      let bdModAmt2 = PBKnob(label: "Amt")
//      bdCtrls.append(contentsOf: [bdMod1, bdModAmt1, bdMod2, bdModAmt2])
//      quickGrid(panel: "mod", items: [[
//        (PBKnob(label: "Repeats"), [.mix, .rrepeat], nil),
//        (PBSelect(label: "Start Seg"), [.mix, .env, .loop], nil),
//        ],[
//        (PBSelect(label: "AC Mod 1"), [.mix, .ac, .mod, .i(0), .src], nil),
//        (PBKnob(label: "Amt"), [.mix, .ac, .mod, .i(0), .amt], nil),
//        (PBSelect(label: "AC Mod 2"), [.mix, .ac, .mod, .i(1), .src], nil),
//        (PBKnob(label: "Amt"), [.mix, .ac, .mod, .i(1), .amt], nil),
//        ],[
//        (bdMod1, [.mix, .bd, .mod, .i(0), .src], nil),
//        (bdModAmt1, [.mix, .bd, .mod, .i(0), .amt], nil),
//        (bdMod2, [.mix, .bd, .mod, .i(1), .src], nil),
//        (bdModAmt2, [.mix, .bd, .mod, .i(1), .amt], nil),
//        ]])
//
//      addPatchChangeBlock { [weak self] (changes) in
//        guard let value = Self.updatedValue(path: [.structure], state: changes) else { return }
//        let panelAlpha: CGFloat = value == 0 ? 0.3 : 1
//        self?.panels["env"]?.alpha = panelAlpha
//        self?.panels["mod"]?.alpha = panelAlpha
//
//        let bdHidden = value == 1
//        bdCtrls.forEach { $0.isHidden = bdHidden }
//      }
//      
//      addPatchChangeBlock { [weak self] (changes) in
//        (0..<5).forEach { step in
//          guard let values = self?.updatedValues(paths: [
//            [.structure], [.mix, .ac, .i(step - 1)], [.mix, .bd, .i(step - 1)]
//          ], changes: changes) else { return }
//          self?.updateABCD(step: step, values: values)
//        }
//      }
//      
//      layout.activateConstraints()
//      self.view = paddedView
//    }
//        
//    
//    private func updateABCD(step: Int, values: [SynthPath:Int]) {
//      let structMult = values[[.structure]] == 1 ? 2 : 1
//      let mixX = values[[.mix, .ac, .i(step - 1)]]!
//      let mixY = values[[.mix, .bd, .i(step - 1)]]!
//
//      // adapted from Wavestation Developer FAQ
//      var xp = mixX + mixY - 255
//      var yp = mixY - mixX
//   
//      xp = max(min(xp, 127), -128) /* Limit range to -128 - 127 */
//      yp = max(min(yp, 127), -128) /* Limit range to -128 - 127 */
//
//      xp += 128
//      yp += 128
//   
//      let dd = xp * yp / 645   /* Calculate individual wave % */
//      let cc = xp * (255 - yp) / 645 /* 645=(255^2/100)*127/128 */
//      let bb = (255 - xp) * (255 - yp) / 645
//      let aa = 100 - bb - cc - dd
//      
//      a[step].value = aa * structMult
//      b[step].value = bb * structMult
//      c[step].value = cc * structMult
//      d[step].value = dd * structMult
//    }
//    
////    override func apply(colorGuide: ColorGuide) {
////      colorAllPanels(colorGuide: colorGuide)
////      panels["space1"]?.backgroundColor = .clear
////      panels["space2"]?.backgroundColor = .clear
////    }
//  }
//  
//  class VoiceController : NewPatchEditorController {
//        
//    override var prefix: SynthPath? { return [.voice, .i(index)] }
//    
//    private let wave = PBSelect(label: "Wave/Seq")
//    private var seqNames = [[Int:String]]()
//        
//    override func loadView(_ view: PBView) {
//      addChild(PitchController(), withPanel: "pitch")
//      addChild(FilterController(), withPanel: "filter")
//      addChild(Env1Controller(), withPanel: "env1")
//      addChild(AmpController(), withPanel: "amp")
//      addChild(PanController(), withPanel: "pan")
//      (0..<2).forEach { lfo in
//        let vc = LFOController()
//        vc.index = lfo
//        addChild(vc, withPanel: "lfo\(lfo)")
//      }
//      createPanels(forKeys: ["wave"])
//      addPanelsToLayout(andView: view)
//      
//      layout.addRowConstraints([
//        ("wave",4), ("filter", 6), ("amp", 6),
//        ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
//      layout.addRowConstraints([
//        ("lfo0",5.5), ("lfo1",5.5), ("pan",2),
//        ], pinned: true, pinMargin: "", spacing: "-s1-")
//      layout.addColumnConstraints([
//        ("wave",1), ("pitch",4), ("lfo0", 2),
//        ], pinned: true, pinMargin: "", spacing: "-s1-")
//      layout.addColumnConstraints([
//        ("filter",2), ("env1",3),
//        ], options: [.alignAllLeading, .alignAllTrailing], spacing: "-s1-")
//      layout.addEqualConstraints(forItemKeys: ["pitch", "env1", "amp"], attribute: .bottom)
//      layout.addEqualConstraints(forItemKeys: ["wave", "pitch"], attribute: .trailing)
//      
//      let bank = PBKnob(label: "Bank")
//      quickGrid(panel: "wave", items: [[
//        (bank, [.bank], nil),
//        (wave, [.number], nil),
//        ]])
//      
//      seqNames.append([:])
//      seqNames.append([:])
//      seqNames.append([:])
//
//      addPatchChangeBlock(path: [.bank]) { [weak self] value in
//        self?.updateWaveOptions(value)
//      }
//      addParamChangeBlock { [weak self] (params) in
//        (0..<3).forEach { bank in
//          guard let param = params.params[[.seq, .name, .i(bank)]] as? OptionsParam else { return }
//          self?.seqNames[bank] = param.options
//        }
//        if let value = self?.latestValue(path: [.bank]) {
//          self?.updateWaveOptions(value)
//        }
//      }
//
//      addPatchChangeBlock(path: [.number]) { (value) in
//        bank.alpha = value > 31 ? 0.3 : 1
//      }
//    }
//    
//    private func updateWaveOptions(_ value: Int) {
//      var options = WavestationSRPatchPatch.waveOptions
//      let mergeOptions = value > 2 ? WavestationSRPatchPatch.waveSeqOptions[value - 3] : seqNames[value]
//      options.merge(mergeOptions) { (l, r) in return l }
//      wave.options = options
//    }
//    
////    override func apply(colorGuide: ColorGuide) {
////      colorAllPanels(colorGuide: colorGuide)
////    }
//
//    
//    
//    class PitchController : NewPatchEditorController {
//      override func loadView(_ view: PBView) {
//        quickGrid(view: view, items: [[
//          (PBKnob(label: "Semi"), [.semitone], nil),
//          (PBKnob(label: "Fine"), [.detune], nil),
//          (PBKnob(label: "Bend"), [.bend], nil),
//          ],[
//          (PBSelect(label: "Pitch Mod 1"), [.pitch, .mod, .i(0), .src], nil),
//          (PBKnob(label: "Amt"), [.pitch, .mod, .i(0), .amt], nil),
//          (LabelItem(text: nil, gridWidth: 3), nil, "mod1space"),
//          ],[
//          (PBSelect(label: "Pitch Mod 2"), [.pitch, .mod, .i(1), .src], nil),
//          (PBKnob(label: "Amt"), [.pitch, .mod, .i(1), .amt], nil),
//          (PBSelect(label: "Macro"), [.pitch, .macro], nil),
//          ],[
//          (PBKnob(label: "Ramp Amt"), [.pitch, .env, .amt], nil),
//          (PBKnob(label: "< Velo"), [.velo, .pitch, .env, .amt], nil),
//          (PBKnob(label: "Ramp Time"), [.pitch, .env, .rate], nil),
//          ]])
//      }
//    }
//    
//    class FilterController : NewPatchEditorController {
//      override func loadView(_ view: PBView) {
//        quickGrid(view: view, items: [[
//          (PBKnob(label: "Cutoff"), [.cutoff], nil),
//          (PBSelect(label: "Filter Mod 1"), [.filter, .mod, .i(0), .src], nil),
//          (PBKnob(label: "Amt"), [.filter, .mod, .i(0), .amt], nil),
//          (PBKnob(label: "Exciter"), [.excite], nil),
//          ],[
//          (PBKnob(label: "Key Trk"), [.filter, .key, .trk], nil),
//          (PBSelect(label: "Filter Mod 2"), [.filter, .mod, .i(1), .src], nil),
//          (PBKnob(label: "Amt"), [.filter, .mod, .i(1), .amt], nil),
//          (PBSelect(label: "Macro"), [.filter, .macro], nil),
//          ]])
//      }
//    }
//    
//    
//    class Env1Controller : NewPatchEditorController {
//      
//      override var prefix: SynthPath? { return [.env] }
//            
//      override func loadView(_ view: PBView) {
//        let envCtrl = PBRateLevelEnvelopeControl(label: "Env 1")
//        
//        quickGrid(view: view, items: [[
//          (envCtrl, nil, "env"),
//          (PBKnob(label: "R1"), [.rate, .i(0)], nil),
//          (PBKnob(label: "R2"), [.rate, .i(1)], nil),
//          (PBKnob(label: "R3"), [.rate, .i(2)], nil),
//          (PBKnob(label: "R4"), [.rate, .i(3)], nil),
//          ],[
//          (PBKnob(label: "Velo"), [.velo], nil),
//          (PBKnob(label: "L0"), [.level, .i(-1)], nil),
//          (PBKnob(label: "L1"), [.level, .i(0)], nil),
//          (PBKnob(label: "L2"), [.level, .i(1)], nil),
//          (PBKnob(label: "L3"), [.level, .i(2)], nil),
//          (PBKnob(label: "L4"), [.level, .i(3)], nil),
//          ],[
//          (PBSelect(label: "Macro"), [.macro], nil),
//          (PBKnob(label: "Velo > Rate"), [.velo, .rate], nil),
//          (PBKnob(label: "Key > Rate"), [.key, .rate], nil),
//          ]])
//        
//        (0...3).forEach { addRateChangeBlock(env: envCtrl, step: $0) }
//        (-1...3).forEach { addLevelChangeBlock(env: envCtrl, step: $0) }
//      }
//      
//      private func addRateChangeBlock(env: PBRateLevelEnvelopeControl, step: Int) {
//        addPatchChangeBlock(path: [.rate, .i(step)]) { (value) in
//          let v = CGFloat(value) / 99
//          env.set(rate: v, forIndex: step)
//        }
//      }
//      
//      private func addLevelChangeBlock(env: PBRateLevelEnvelopeControl, step: Int) {
//        addPatchChangeBlock(path: [.level, .i(step)]) { (value) in
//          let v = CGFloat(value) / 99
//          if step == -1 {
//            env.startLevel = v
//          }
//          else {
//            env.set(level: v, forIndex: step)
//          }
//        }
//      }
//    }
//    
//    class AmpController : NewPatchEditorController {
//      
//      override func loadView(_ view: PBView) {
//        let envCtrl = PBRateLevelEnvelopeControl(label: "Amp Env")
//        
//        quickGrid(view: view, items: [[
//          (PBKnob(label: "Level"), [.level], nil),
//          (PBSelect(label: "Amp Mod 1"), [.amp, .mod, .i(0), .src], nil),
//          (PBKnob(label: "Amt"), [.amp, .mod, .i(0), .amt], nil),
//          (PBCheckbox(label: "Out 1"), [.patch, .out, .i(0)], nil),
//          (PBCheckbox(label: "Out 2"), [.patch, .out, .i(1)], nil),
//          ],[
//          (LabelItem(text: nil, gridWidth: 2), nil, "modSpace"),
//          (PBSelect(label: "Amp Mod 2"), [.amp, .mod, .i(1), .src], nil),
//          (PBKnob(label: "Amt"), [.amp, .mod, .i(1), .amt], nil),
//          (PBCheckbox(label: "Out 3"), [.patch, .out, .i(2)], nil),
//          (PBCheckbox(label: "Out 4"), [.patch, .out, .i(3)], nil),
//          ],[
//          (envCtrl, [.env], nil),
//          (PBKnob(label: "R1"), [.amp, .env, .rate, .i(0)], nil),
//          (PBKnob(label: "R2"), [.amp, .env, .rate, .i(1)], nil),
//          (PBKnob(label: "R3"), [.amp, .env, .rate, .i(2)], nil),
//          (PBKnob(label: "R4"), [.amp, .env, .rate, .i(3)], nil),
//          ],[
//          (PBKnob(label: "Velo"), [.amp, .env, .velo], nil),
//          (PBKnob(label: "L0"), [.amp, .env, .level, .i(-1)], nil),
//          (PBKnob(label: "L1"), [.amp, .env, .level, .i(0)], nil),
//          (PBKnob(label: "L2"), [.amp, .env, .level, .i(1)], nil),
//          (PBKnob(label: "L3"), [.amp, .env, .level, .i(2)], nil),
//          (LabelItem(text: nil, gridWidth: 2), nil, "lspace"),
//          ],[
//          (PBSelect(label: "Macro"), [.amp, .env, .macro], nil),
//          (PBKnob(label: "Velo > Atk"), [.amp, .env, .velo, .attack], nil),
//          (PBKnob(label: "Key > Dec"), [.amp, .env, .key, .decay], nil),
//          ]])
//
//        (0...3).forEach { addRateChangeBlock(env: envCtrl, step: $0) }
//        (-1...2).forEach { addLevelChangeBlock(env: envCtrl, step: $0) }
//      }
//      
//      private func addRateChangeBlock(env: PBRateLevelEnvelopeControl, step: Int) {
//        addPatchChangeBlock(path: [.amp, .env, .rate, .i(step)]) { (value) in
//          let v = CGFloat(value) / 99
//          env.set(rate: v, forIndex: step)
//        }
//      }
//      
//      private func addLevelChangeBlock(env: PBRateLevelEnvelopeControl, step: Int) {
//        addPatchChangeBlock(path: [.amp, .env, .level, .i(step)]) { (value) in
//          let v = CGFloat(value) / 99
//          if step == -1 {
//            env.startLevel = v
//          }
//          else {
//            env.set(level: v, forIndex: step)
//          }
//        }
//      }
//      
//    }
//    
//    class LFOController : NewPatchEditorController {
//      
//      override var prefix: SynthPath? { return [.lfo, .i(index)] }
//      
//      private let wave = PBSelect(label: "LFO")
//      
//      override var index: Int {
//        didSet { wave.label = "LFO \(index + 1)" }
//      }
//      
//      override func loadView(_ view: PBView) {
//        quickGrid(view: view, items: [[
//          (wave, [.shape], nil),
//          (PBCheckbox(label: "Sync"), [.sync], nil),
//          (PBKnob(label: "Rate"), [.rate], nil),
//          (PBSelect(label: "Rate Mod"), [.rate, .mod, .src], nil),
//          (PBKnob(label: "Mod Amt"), [.rate, .mod, .amt], nil),
//          ],[
//          (PBKnob(label: "Delay"), [.delay], nil),
//          (PBKnob(label: "Fade"), [.fade], nil),
//          (PBKnob(label: "Depth"), [.amt], nil),
//          (PBSelect(label: "Depth Mod"), [.amt, .mod, .src], nil),
//          (PBKnob(label: "Mod Amt"), [.amt, .mod, .amt], nil),
//          ]])
//      }
//    }
//    
//    class PanController : NewPatchEditorController {
//
//      override func loadView(_ view: PBView) {
//        quickGrid(view: view, items: [[
//          (PBKnob(label: "Key > Pan"), [.key, .pan], nil),
//          (PBKnob(label: "Velo > Pan"), [.velo, .pan], nil),
//          ],[
//          (PBSelect(label: "Pan Macro"), [.pan, .macro], nil),
//          ]])
//      }
//    }
//    
//  }
//}
