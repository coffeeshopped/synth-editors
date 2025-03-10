
class ProphecyOscController : NewPatchEditorController {
  override func loadView(_ view: PBView) {
    addChild(OscSwitchController(), withPanel: "osc")
    addChild(MixerController(), withPanel: "mix")
    
    grid(panel: "noise", prefix: [.noise], items: [[
      (PBKnob(label: "Noise Freq"), [.cutoff]),
      (PBKnob(label: "←KeyTrk"), [.cutoff, .key]),
    ]])

    grid(panel: "sub", prefix: [.sub], items: [[
      (PBKnob(label: "Coarse"), [.coarse]),
      (PBKnob(label: "Fine"), [.fine]),
      ],[
      (PBSwitch(label: "Sub Wave"), [.wave]),
      (PBSwitch(label: "Pitch"), [.pitch, .src]),
    ]])
    
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("osc", 11)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addRowConstraints([("mix", 9), ("noise", 2)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("osc", 5), ("mix", 3)], pinned: true, pinMargin: "", spacing: "-s1-")
    layout.addColumnConstraints([("noise", 1), ("sub", 2)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["mix", "sub"], attribute: .bottom)
    
    addColor(panels: ["noise", "sub"], level: 1)

  }
    
  
  class MixerController : NewPatchEditorController {
    override var prefix: SynthPath? { [.mix, .i(index)] }
                
    override func loadView(_ view: PBView) {
      let labeledGrid = LabeledGridSelectControl(label: "Mixer")
      labeledGrid.label.textAlignment = .center
      let gridSelect = labeledGrid.gridControl
      gridSelect.columnCount = 1
      gridSelect.options = OptionsParam.makeOptions((1...2).map { "\($0)" })
      gridSelect.value = 0
      gridSelect.addValueChangeTarget(self, action: #selector(selectIndex(_:)))

      grid(panel: "switch", items: [[(labeledGrid, nil)]])
      
      grid(panel: "osc0", prefix: [.osc, .i(0)], items: [[
        (PBKnob(label: "Osc 1 Lvl"), [.level]),
        ],[
        (PBKnob(label: "Mod Amt"), [.mod, .amt]),
        ],[
        (PBSelect(label: "Osc 1 Mod"), [.mod, .src]),
      ]])

      grid(panel: "osc1", prefix: [.osc, .i(1)], items: [[
        (PBKnob(label: "Osc 2 Lvl"), [.level]),
        ],[
        (PBKnob(label: "Mod Amt"), [.mod, .amt]),
        ],[
        (PBSelect(label: "Osc 2 Mod"), [.mod, .src]),
      ]])

      grid(panel: "sub", prefix: [.sub], items: [[
        (PBKnob(label: "Sub Lvl"), [.level]),
        ],[
        (PBKnob(label: "Mod Amt"), [.mod, .amt]),
        ],[
        (PBSelect(label: "Sub Mod"), [.mod, .src]),
      ]])

      grid(panel: "noise", prefix: [.noise], items: [[
        (PBKnob(label: "Noise Lvl"), [.level]),
        ],[
        (PBKnob(label: "Mod Amt"), [.mod, .amt]),
        ],[
        (PBSelect(label: "Noise Mod"), [.mod, .src]),
      ]])

      grid(panel: "feedback", prefix: [.feedback], items: [[
        (PBKnob(label: "Feedbk Lvl"), [.level]),
        ],[
        (PBKnob(label: "Mod Amt"), [.mod, .amt]),
        ],[
        (PBSelect(label: "Feedbk Mod"), [.mod, .src]),
      ]])

      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([[
        ("switch", 1), ("osc0", 1.5), ("osc1", 1.5), ("sub", 1.5), ("noise", 1.5), ("feedback", 1.5),
      ]], pinMargin: "", spacing: "-s1-")
      
      addColor(panels: ["osc0", "osc1", "sub", "noise", "feedback"], level: 1)
      addColor(panels: ["switch"], level: 1, clearBackground: true)
      addBorder(view: view)
    }
    
  }
  
  
  class OscSwitchController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.osc, .i(index)] }
    
    private let pageController = OscPageController()
    
    override func loadView(_ view: PBView) {
      addChild(pageController, withPanel: "page")
      
      let oscSet = PBSelect(label: "Osc Set")
      grid(panel: "set", items: [[(oscSet, nil)]])
      
      let labeledSwitch = LabeledSegmentedControl(label: "Oscillator", items: ["1", "2"])
      switchCtrl = labeledSwitch.segmentedControl
      grid(panel: "switch", items: [[(labeledSwitch, nil)]])
      
      grid(panel: "tune", items: [[
        (PBKnob(label: "Coarse"), [.coarse]),
        (PBKnob(label: "Fine"), [.fine]),
        (PBKnob(label: "Offset"), [.offset]),
        (PBSelect(label: "Pitch Mod"), [.pitch, .mod, .src]),
        (PBKnob(label: "←Int"), [.pitch, .mod, .amt]),
      ]])
      
      grid(panel: "octave", items: [[
        (PBSwitch(label: "Octave"), [.octave]),
        (PBKnob(label: "Key Lo"), [.key, .lo]),
        (PBKnob(label: "Slope Lo"), [.slop, .lo]),
        (PBKnob(label: "Key Hi"), [.key, .hi]),
        (PBKnob(label: "Slope Hi"), [.slop, .hi]),
        (PBSwitch(label: "LFO"), [.pitch, .lfo]),
        (PBKnob(label: "←Int"), [.pitch, .lfo, .amt]),
        (PBKnob(label: "←After"), [.pitch, .lfo, .aftertouch]),
        (PBKnob(label: "←CC1"), [.pitch, .lfo, .ctrl]),
      ]])

      grid(panel: "shape", items: [[
        (PBKnob(label: "Input Gain"), [.input, .gain]),
        (PBKnob(label: "Input Offset"), [.input, .offset]),
      ],[
        (PBSelect(label: "In Gain Mod"), [.input, .mod, .src]),
        (PBKnob(label: "←Int"), [.input, .mod, .amt]),
      ],[
        (PBKnob(label: "Feedbk"), [.feedback]),
        (PBKnob(label: "Cross Lvl"), [.cross]),
      ],[
        (PBSwitch(label: "Table"), [.shape, .select]),
        (PBKnob(label: "Shape"), [.shape, .amt]),
      ],[
        (PBSelect(label: "Shape Mod"), [.shape, .mod, .src]),
        (PBKnob(label: "←Int"), [.shape, .mod, .amt]),
      ],[
        (PBKnob(label: "Out Gain"), [.out, .gain]),
        (PBKnob(label: "Thru Gain"), [.thru, .gain]),
      ]])
      
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("set", 1.5), ("switch", 2), ("tune", 5.5), ("shape", 2)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("set", 1), ("octave", 1), ("page", 3)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addEqualConstraints(forItemKeys: ["tune", "octave", "page"], attribute: .trailing)
      layout.addEqualConstraints(forItemKeys: ["page", "shape"], attribute: .bottom)
      layout.addEqualConstraints(forItemKeys: ["set", "switch", "tune"], attribute: .bottom)
      
      defaultConfigure(control: oscSet, forParam: ProphecyVoicePatch.params[[.osc, .select]]!)
      addPatchChangeBlock { [weak self] changes in
        guard let value = Self.updatedValueForFullPath([.osc, .select], state: changes) else { return }
        oscSet.value = value
        self?.updatePageController(value)
      }
      
      #if os(iOS)
      oscSet.delegate = self
      #endif
      oscSet.addValueChangeTarget(self, action: #selector(oscSetChanged(_:)))
      
      addColor(panels: ["tune", "octave", "shape"], level: 1)
      addColor(panels: ["set"], level: 2)
      addColor(panels: ["switch"], level: 1, clearBackground: true)
      addBorder(view: view)
    }
    
    @IBAction func oscSetChanged(_ sender: PBLabeledControl) {
      pushPatchChangeUnprefixed(.paramsChange([
        [.osc, .select] : sender.value
      ]))
    }
    
    func updatePageController(_ value: Int) {
      var hidden = false
      var pageIndex = 0
      switch index {
      case 0:
        switch value {
        case 0, 1, 2, 3:
          pageIndex = 0
        case 4, 5, 6:
          pageIndex = 1
        case 7, 8:
          pageIndex = 2
        default:
          pageIndex = value - 5
        }
      default:
        switch value {
        case 0, 1, 2, 3:
          pageIndex = value
        case 4, 5, 6:
          pageIndex = value - 3
        case 7, 8:
          pageIndex = value - 5
        default:
          hidden = true
        }
      }
      pageController.view.isHidden = hidden
      pageController.index = pageIndex
      
    }
    
  }

  class OscPageController : NewPagedEditorController {
    
    private let std = StdController()
    private let comb = CombController()
    private let vpm = VPMController()
    private let mod = ModController()
    private let brass = BrassController()
    private let reed = ReedController()
    private let pluck = PluckController()
    
    override func loadView(_ view: PBView) {
      addPanelsToLayout(andView: view)
      layout.addGridConstraints([[("page", 1)]], pinMargin: "", spacing: "-s1-")
    }
    
    override func viewController(forIndex index: Int) -> PBViewController? {
      guard index < 7 else { return nil }
      return [std, comb, vpm, mod, brass, reed, pluck][index]
    }
  }
  
  class StdController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.normal] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSwitch(label: "Wave"), [.wave]),
        (PBKnob(label: "Edge"), [.edge]),
        (PBKnob(label: "Wave Level"), [.wave, .level]),
        (PBKnob(label: "Ramp Level"), [.ramp, .level]),
      ],[
        (PBKnob(label: "Form"), [.form]),
        (PBSwitch(label: "LFO"), [.lfo]),
        (PBKnob(label: "←Int"), [.lfo, .amt]),
        (PBSelect(label: "Mod Src"), [.mod, .src]),
        (PBKnob(label: "←Int"), [.mod, .amt]),
      ]])
      
      addColor(view: view)
    }
    
  }
  
  class CombController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.filter] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBKnob(label: "Noise"), [.noise]),
        (PBSwitch(label: "Wave"), [.wave]),
        (PBKnob(label: "Wave Level"), [.wave, .level]),
        (PBKnob(label: "In Gain"), [.gain]),
        (PBKnob(label: "Cutoff"), [.cutoff]),
      ],[
        (PBKnob(label: "Feedback"), [.feedback]),
        (PBSelect(label: "Env"), [.env]),
        (PBKnob(label: "←Int"), [.env, .amt]),
        (PBSelect(label: "Mod Src"), [.mod, .src]),
        (PBKnob(label: "←Int"), [.mod, .amt]),
      ]])
      
      addColor(view: view)

    }
    
  }

  class VPMController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.fm] }
    
    override func loadView(_ view: PBView) {
      grid(panel: "carrier", prefix: [.carrier], items: [[
        (PBSwitch(label: "Carrier Wave"), [.wave]),
        (PBKnob(label: "Level"), [.level]),
        (PBKnob(label: "Feedback"), [.feedback]),
      ],[
        (PBSelect(label: "Env"), [.env]),
        (PBKnob(label: "←Int"), [.env, .amt]),
      ],[
        (PBSelect(label: "Mod Src"), [.mod, .src]),
        (PBKnob(label: "←Int"), [.mod, .amt]),
      ]])

      grid(panel: "table", prefix: [.table], items: [[
        (PBKnob(label: "Carrier Shape"), []),
        ],[
        (PBSwitch(label: "LFO"), [.lfo]),
        (PBKnob(label: "←Int"), [.lfo, .amt]),
        ],[
        (PBSelect(label: "Mod Src"), [.mod, .src]),
        (PBKnob(label: "←Int"), [.mod, .amt]),
      ]])
      
      grid(panel: "mod", prefix: [.mod], items: [[
        (PBSwitch(label: "Mod Wave"), [.wave]),
        (PBKnob(label: "Level"), [.level]),
        (PBKnob(label: "Semi"), [.coarse]),
        (PBKnob(label: "Fine"), [.fine]),
      ],[
        (PBKnob(label: "↓Key→Lvl"), [.env, .key]),
        (PBKnob(label: "Key→Pitch"), [.pitch, .key]),
        (PBSelect(label: "Pitch Mod Src"), [.pitch, .mod, .src]),
        (PBKnob(label: "←Int"), [.pitch, .mod, .amt]),
      ],[
        (PBSelect(label: "Level Env"), [.env]),
        (PBKnob(label: "←Int"), [.env, .amt]),
        (PBSelect(label: "Level Mod"), [.mod, .src]),
        (PBKnob(label: "←Int"), [.mod, .amt]),
      ]])

      addPanelsToLayout(andView: view)
      layout.addGridConstraints([[("carrier", 3), ("table", 2.5), ("mod", 5)]], pinMargin: "", spacing: "-s1-")
      
      addColorToAll()
    }
  }
  
  class ModController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.mod] }
    
    override func loadView(_ view: PBView) {
    
      grid(panel: "type", items: [[
        (PBSwitch(label: "Type"), [.type]),
        (PBSwitch(label: "Input"), [.input]),
      ]])

      grid(panel: "ring", items: [[
        (PBSwitch(label: "Carrier"), [.ringMod]),
      ]])

      grid(panel: "sync", items: [[
        (PBSwitch(label: "Sync Wave"), [.sync, .wave]),
        (PBKnob(label: "Edge"), [.sync, .edge]),
      ]])

      grid(panel: "cross", items: [[
        (PBSwitch(label: "Carrier"), [.cross, .carrier]),
        (PBKnob(label: "Depth"), [.cross, .depth]),
        (PBSwitch(label: "Env"), [.cross, .env]),
        (PBKnob(label: "←Int"), [.cross, .env, .amt]),
        (PBSelect(label: "Mod Src"), [.cross, .mod, .src]),
        (PBKnob(label: "←Int"), [.cross, .mod, .amt]),
      ]])
      
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        [("type", 2), ("ring", 1), ("sync", 2)],
        [("cross", 6.5)]
      ], pinMargin: "", spacing: "-s1-")
      
      addPatchChangeBlock(path: [.type]) { [weak self] value in
        ["ring", "cross", "sync"].enumerated().forEach {
          self?.panels[$0.element]?.isHidden = value != $0.offset
        }
      }
      addColorToAll()
    }
  }
  
  class BrassController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.brass] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSwitch(label: "Type"), [.type]),
        (PBSelect(label: "Bend Ctrl"), [.bend, .ctrl]),
        (PBKnob(label: "Bend Amt"), [.bend, .amt]),
        (PBSwitch(label: "Bend Dir"), [.bend, .direction]),
        (PBSelect(label: "Pressure EG"), [.pressure, .env]),
        (PBKnob(label: "←Int"), [.pressure, .env, .amt]),
      ],[
        (PBSelect(label: "Press EG Mod"), [.pressure, .env, .mod, .src]),
        (PBKnob(label: "←Int"), [.pressure, .env, .mod, .amt]),
        (PBSwitch(label: "Press LFO"), [.pressure, .lfo]),
        (PBKnob(label: "←Int"), [.pressure, .lfo, .amt]),
        (PBSelect(label: "Press Mod Src"), [.pressure, .mod, .src]),
        (PBKnob (label: "←Int"), [.pressure, .mod, .amt]),
        (PBKnob(label: "Noise"), [.noise]),
      ],[
        (PBKnob(label: "Lip Char"), [.lip, .character]),
        (PBSelect(label: "Lip Mod"), [.lip, .mod, .src]),
        (PBKnob(label: "←Int"), [.lip, .mod, .amt]),
        (PBSwitch(label: "Bell Type"), [.bell, .type]),
        (PBKnob(label: "Bell Tone"), [.bell, .tone]),
        (PBKnob(label: "Bell Reson"), [.bell, .reson]),
      ]])
      
      addColor(view: view)
    }
    
  }
  
  class ReedController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.reed] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSelect(label: "Type"), [.type]),
        (PBSelect(label: "Bend Ctrl"), [.bend, .ctrl]),
        (PBKnob(label: "Bend Amt"), [.bend, .amt]),
        (PBSwitch(label: "Bend Dir"), [.bend, .direction]),
        (PBSelect(label: "Pressure EG"), [.pressure, .env]),
        (PBKnob(label: "←Int"), [.pressure, .env, .amt]),
      ],[
        (PBSelect(label: "Press EG Mod"), [.pressure, .env, .mod, .src]),
        (PBKnob(label: "←Int"), [.pressure, .env, .mod, .amt]),
        (PBSwitch(label: "Press LFO"), [.pressure, .lfo]),
        (PBKnob(label: "←Int"), [.pressure, .lfo, .amt]),
        (PBSelect(label: "Press Mod Src"), [.pressure, .mod, .src]),
        (PBKnob (label: "←Int"), [.pressure, .mod, .amt]),
      ],[
        (PBSelect(label: "Reed Mod"), [.mod, .src]),
        (PBKnob(label: "←Int"), [.mod, .amt]),
        (PBKnob(label: "Noise"), [.noise]),

//        (PBKnob(label: "X1"), [.extra, .i(0)]),
//        (PBKnob(label: "X2"), [.extra, .i(1)]),
//        (PBKnob(label: "X3"), [.extra, .i(2)]),
      ]])
      
      addColor(view: view)

    }

  }
  
  class PluckController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.pluck] }
    
    override func loadView(_ view: PBView) {
      grid(panel: "attack", items: [[
        (PBKnob(label: "Attack Level"), [.attack, .level]),
        (PBKnob(label: "←Velo"), [.attack, .level, .velo]),
        (PBKnob(label: "Noise Bal"), [.noise, .level]),
        (PBKnob(label: "←Velo"), [.noise, .level, .velo]),
      ]])

      grid(panel: "filter", items: [[
        (PBSwitch(label: "Filter"), [.noise, .filter, .type]),
        (PBKnob(label: "Cutoff"), [.noise, .filter, .cutoff]),
        (PBKnob(label: "←Velo"), [.noise, .filter, .velo]),
        (PBKnob(label: "Reson"), [.noise, .filter, .reson]),
      ]])

      grid(panel: "curve", items: [[
        (PBKnob(label: "Curve Up"), [.curve, .up]),
        (PBKnob(label: "←Velo"), [.curve, .up, .velo]),
        (PBKnob(label: "Curve Down"), [.curve, .down]),
        (PBKnob(label: "←Velo"), [.curve, .down, .velo]),
        (PBKnob(label: "Attack Edge"), [.attack, .edge]),
      ]])

      grid(panel: "pos", items: [[
        (PBKnob(label: "String Pos"), [.string, .position]),
        (PBKnob(label: "←Velo"), [.string, .position, .velo]),
        (PBSelect(label: "Mod Src"), [.string, .position, .mod, .src]),
        (PBKnob(label: "← Int"), [.string, .position, .mod, .amt]),
      ]])

      grid(panel: "loss", items: [[
        (PBKnob(label: "String Loss"), [.string, .damp]),
        (PBKnob(label: "←Key"), [.string, .damp, .key]),
        (PBSelect(label: "Mod Src"), [.string, .damp, .mod, .src]),
        (PBKnob(label: "←Int"), [.string, .damp, .mod, .amt]),
      ]])

      grid(panel: "inharm", items: [[
        (PBKnob(label: "Inharm"), [.off, .harmonic, .amt]),
        (PBKnob(label: "←Key"), [.off, .harmonic, .key]),
      ]])
      
      grid(panel: "decay", items: [[
        (PBKnob(label: "Decay"), [.decay]),
        (PBKnob(label: "←Key"), [.decay, .key]),
        (PBKnob(label: "Release"), [.release]),
        (PBKnob(label: "←Key"), [.release, .key]),
      ]])
      
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        [("attack", 4), ("filter", 4)],
        [("curve", 5), ("pos", 4.5)],
        [("loss", 4.5), ("inharm", 2), ("decay", 4)]
      ], pinMargin: "", spacing: "-s1-")
      
      addColorToAll()
    }
  }

}

