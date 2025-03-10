
struct MophoVoiceController {
  
  static func controller() -> FnPatchEditorController {
    return controller { (vc) in
      let oscs = Self.oscsController {
        $0.grid(panel: "sync", items: [[
          (PBCheckbox(label: "Sync 2→1"), [.sync]),
          (PBKnob(label: "Slop"), [.slop]),
          (PBKnob(label: "Bend"), [.bend]),
          (PBSelect(label: "Key Assign Mode"), [.keyAssign]),
          ],[
          (PBKnob(label: "Mix"), [.mix]),
          (PBKnob(label: "Noise"), [.noise]),
          (PBKnob(label: "Ext. A"), [.extAudio]),
          (PBSwitch(label: "Glide Mode"), [.glide]),
          ]])
      }
      vc.addChild(oscs, withPanel: "oscs")

      vc.grid(panel: "knobs", items: [[
        (PBSelect(label: "Knob 1"), [.knob, .i(0)]),
        (PBSelect(label: "Knob 2"), [.knob, .i(1)]),
        ],[
        (PBSelect(label: "Knob 3"), [.knob, .i(2)]),
        (PBSelect(label: "Knob 4"), [.knob, .i(3)]),
        ]])


      vc.addLayoutConstraints {
        $0.addRowConstraints([
          ("oscs",12), ("mods",4)
          ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addRowConstraints([
          ("fEnv", 7), ("aEnv",5)
          ], pinned: false, spacing: "-s1-")
        $0.addRowConstraints([
          ("lfos",6), ("env3", 6.5), ("push", 3.5)
        ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addRowConstraints([
          ("knobs", 3), ("controls", 7)
        ], pinned: false, spacing: "-s1-")

        $0.addColumnConstraints([
          ("oscs",2),("fEnv",2),("lfos",4)
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addColumnConstraints([
          ("env3",2),("knobs",2),
          ], pinned: false, spacing: "-s1-")

        $0.addEqualConstraints(forItemKeys: ["aEnv","oscs"], attribute: .trailing)
        $0.addEqualConstraints(forItemKeys: ["aEnv","mods"], attribute: .bottom)
        $0.addEqualConstraints(forItemKeys: ["push","controls"], attribute: .trailing)
        $0.addEqualConstraints(forItemKeys: ["lfos","knobs"], attribute: .bottom)
        $0.addEqualConstraints(forItemKeys: ["env3","push"], attribute: .bottom)
      }
    }
  }
  
  static func controller(initPanels: (FnPatchEditorController) -> Void) -> FnPatchEditorController {
    return ActivatedFnEditorController { (vc) in
      vc.addChild(modsController(), withPanel: "mods")
      vc.addChild(controlsController(), withPanel: "controls")
      vc.addChild(lfosController(), withPanel: "lfos")

      let fEnv = envController(prefix: [.filter, .env], label: "Filter (Env 2)")
      vc.addChild(fEnv)
      vc.grid(panel: "fEnv", items: [[
        (fEnv.view, nil),
        (PBKnob(label: "Env Amt"), [.filter, .env, .amt]),
        (PBKnob(label: "Velo"), [.filter, .env, .velo]),
        (PBKnob(label: "Cutoff"), [.cutoff]),
        (PBKnob(label: "Reson"), [.reson]),
        (PBKnob(label: "Aud Mod"), [.filter, .extAudio]),
        ],[
        (PBKnob(label: "Delay"), [.filter, .env, .delay]),
        (PBKnob(label: "Attack"), [.filter, .env, .attack]),
        (PBKnob(label: "Decay"), [.filter, .env, .decay]),
        (PBKnob(label: "Sustain"), [.filter, .env, .sustain]),
        (PBKnob(label: "Release"), [.filter, .env, .release]),
        (PBCheckbox(label: "4-pole"), [.filter, .fourPole]),
        (PBKnob(label: "Key Trk"), [.filter, .keyTrk]),
        ]])
      
      let aEnv = envController(prefix: [.amp, .env], label: "Amp (Env 1)")
      vc.addChild(aEnv)
      vc.grid(panel: "aEnv", items: [[
          (aEnv.view, nil),
          (PBKnob(label: "Env Amt"), [.amp, .env, .amt]),
          (PBKnob(label: "Velo"), [.amp, .env, .velo]),
          (PBKnob(label: "Level"), [.amp, .level]),
          ],[
          (PBKnob(label: "Delay"), [.amp, .env, .delay]),
          (PBKnob(label: "Attack"), [.amp, .env, .attack]),
          (PBKnob(label: "Decay"), [.amp, .env, .decay]),
          (PBKnob(label: "Sustain"), [.amp, .env, .sustain]),
          (PBKnob(label: "Release"), [.amp, .env, .release]),
        ]])
      
      let env3 = envController(prefix: [.env, .i(2)], label: "Env 3")
      vc.addChild(env3)
      let env3Amt = PBKnob(label: "Amount")
      vc.grid(panel: "env3", items: [[
        (env3.view, nil),
        (PBKnob(label: "Velo"), [.env, .i(2), .velo]),
        (env3Amt, [.env, .i(2), .amt]),
        (PBSelect(label: "Destination"), [.env, .i(2), .dest]),
        ],[
        (PBKnob(label: "Delay"), [.env, .i(2), .delay]),
        (PBKnob(label: "Attack"), [.env, .i(2), .attack]),
        (PBKnob(label: "Decay"), [.env, .i(2), .decay]),
        (PBKnob(label: "Sustain"), [.env, .i(2), .sustain]),
        (PBKnob(label: "Release"), [.env, .i(2), .release]),
          (PBCheckbox(label: "Repeat"), [.env, .i(2), .rrepeat]),
        ]])
      vc.dims(view: env3Amt, forPath: [.env, .i(2), .dest])
      
      vc.grid(panel: "push", items: [[
        (PBKnob(label: "Push It Note"), [.pushIt, .note]),
        (PBKnob(label: "Velocity"), [.pushIt, .velo]),
        ],[
        (PBSwitch(label: "Switch Mode"), [.pushIt, .mode]),
        ]])
          
      initPanels(vc)
      
      vc.addColor(panels: ["fEnv", "aEnv", "uni"], level: 1)
      vc.addColor(panels: ["knobs", "env3", "push"], level: 2)    }
  }
    
  static func envController(prefix: SynthPath, label: String) -> FnPatchEditorController {
    return ActivatedFnEditorController { (vc) in
      let env = PBDadsrEnvelopeControl(label: label)
      vc.view = env
      vc.prefixBlock = { _ in prefix }
      
      vc.addPatchChangeBlock(path: [.delay]) { env.delay = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.attack]) { env.attack = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.decay]) { env.decay = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.sustain]) { env.sustain = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.release]) { env.rrelease = CGFloat($0) / 127 }
      
      vc.registerForEditMenu(env, bundle: (
        paths: { [[.delay], [.attack], [.decay], [.sustain], [.release]] },
        pasteboardType: "com.cfshpd.MophoEnvelope",
        initialize: { [0, 0, 0, 127, 0] },
        randomize: { 5.map { 128.rand() } }
      ))
    }
  }
    
  static func oscsController(syncPanel: (FnPatchEditorController) -> Void, waveReset: Bool = false) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.addChild(oscController(index: 0, waveReset: waveReset), withPanel: "osc0")
      vc.addChild(oscController(index: 1, waveReset: waveReset), withPanel: "osc1")
      syncPanel(vc)

      vc.addLayoutConstraints {
        $0.addRowConstraints([
          ("osc0",7.5), ("sync", 4.5)
          ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addColumnConstraints([("osc0", 1), ("osc1", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addEqualConstraints(forItemKeys: ["osc1","sync"], attribute: .bottom)
      }
      
      vc.addColorToAll()
      vc.addBorder()
    }
  }
  
  static func oscController(index: Int, waveReset: Bool = false) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.prefixBlock = { _ in return [.osc, .i(index)] }
      let wave = PBSwitch(label: "Oscillator \(index + 1)")
      let pw = PBKnob(label: "PW")

      var items: [(PBView, SynthPath?)] = [
        (wave, nil),
        (pw, nil),
        (PBKnob(label: "Freq"), [.semitone]),
        (PBKnob(label: "Fine"), [.detune]),
        (PBKnob(label: "Glide"), [.glide]),
        (PBCheckbox(label: "Key"), [.keyTrk]),
        (PBKnob(label: "Sub"), [.sub]),
      ]
      if waveReset {
        items.append((PBCheckbox(label: "Reset"), [.reset]))
      }
      vc.grid(items: [items])

      vc.addBlocks(control: wave, path: [.shape], paramAfterBlock: {
        wave.options = MophoVoicePatch.waveOptions
      }, patchChangeAssignBlock: {
        wave.value = min($0, 4)
      })

      vc.addBlocks(control: pw, path: [.shape], paramAfterBlock: {
        pw.displayOffset = -4
        pw.minimumValue = 4
      }, patchChangeAssignBlock: {
        pw.value = $0
        pw.isHidden = $0 < 4
      })

      vc.dims(forPath: [.shape])
    }
  }

  static func lfosController() -> FnPatchEditorController {
    ActivatedFnEditorController { (vc) in
      vc.addChildren(count: 4, panelPrefix: "lfo", setup: lfoController(index:))
      vc.addLayoutConstraints {
        $0.addGridConstraints([
          [("lfo0", 1), ("lfo1", 1)],
          [("lfo2", 1), ("lfo3", 1)],
        ], pinMargin: "", spacing: "-s1-")
      }
      vc.addColorToAll(level: 3)
      vc.addBorder(level: 3)
    }
  }
  
  static func lfoController(index: Int) -> FnPatchEditorController {
    ActivatedFnEditorController { (vc) in
      vc.prefixBlock = { _ in [.lfo, .i(index)] }
      let freqDropdown = PBSelect(label: "Freq")
      let freqKnob = PBKnob(label: "Freq")

      let amt = PBKnob(label: "Amount")
      vc.grid(items: [[
        (PBSwitch(label: "LFO \(index + 1)"), [.shape]),
        (freqKnob, nil),
        (amt, [.amt]),
        ],[
        (PBCheckbox(label: "Sync"), [.key, .sync]),
        (freqDropdown, nil),
        (PBSelect(label: "Destination"), [.dest]),
        ]])
      
      vc.addBlocks(control: freqDropdown, path: [.freq], paramAfterBlock: {
        freqDropdown.options = MophoVoicePatch.lfoFreqOptions
      }, patchChangeAssignBlock: {
        freqDropdown.value = $0 < 151 ? 0 : $0 - 150
      }, controlChangeValueBlock:  {
        return freqDropdown.value == 0 ? 75 : freqDropdown.value + 150
      })

      vc.addBlocks(control: freqKnob, path: [.freq], paramAfterBlock: {
        freqKnob.maximumValue = 150
      }, patchChangeAssignBlock: {
        freqKnob.isHidden = $0 > 150
        freqKnob.value = $0
      })
      
      vc.dims(view: amt, forPath: [.dest])

    }
  }
  
  static func modsController() -> FnPatchEditorController {
    ActivatedFnEditorController { (vc) in
      vc.addChildren(count: 4, panelPrefix: "mod", setup: modController(index:))
      vc.addLayoutConstraints {
        $0.addGridConstraints((0..<4).map { [("mod\($0)", 1)] }, pinMargin: "", spacing: "-s1-")
      }

      vc.addColorToAll(level: 2)
      vc.addBorder(level: 2)
    }
  }
  
  static func modController(index: Int) -> FnPatchEditorController {
    ActivatedFnEditorController { (vc) in
      let src = PBSelect(label: "Mod \(index + 1) Src")
      vc.prefixBlock = { _ in [.mod, .i(index)] }
      vc.grid(items: [[
        (src, [.src]),
        (PBKnob(label: "Amt"), [.amt]),
        (PBSelect(label: "Destination"), [.dest]),
      ]])
      
      vc.addPatchChangeBlock(paths: [[.src], [.dest]]) { values in
        let on = values.values.reduce(true, { $0 && $1 > 0 })
        vc.view.alpha = on ? 1 : 0.4
      }
    }
  }

  static func controlsController() -> FnPatchEditorController {
    ActivatedFnEditorController { (vc) in
      vc.addChild(controlController(prefix: [.modWheel], label: "Mod Wheel"), withPanel: "mod")
      vc.addChild(controlController(prefix: [.pressure], label: "Pressure"), withPanel: "press")
      vc.addChild(controlController(prefix: [.breath], label: "Breath"), withPanel: "breath")
      vc.addChild(controlController(prefix: [.velo], label: "Velocity"), withPanel: "velo")
      vc.addChild(controlController(prefix: [.foot], label: "Foot"), withPanel: "foot")
      
      vc.addLayoutConstraints {
        $0.addGridConstraints([[
          ("mod", 1),("press", 1),("breath", 1),("velo", 1),("foot", 1),
        ]], pinMargin: "", spacing: "-s1-")
      }
      
      vc.addColorToAll(level: 2)
      vc.addBorder(level: 2)
    }
  }
  
  
  static func controlController(prefix: SynthPath, label: String) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.prefixBlock = { _ in return prefix }
      let amt = PBKnob(label: label)
      vc.grid(items: [
        [(amt, [.amt])],
        [(PBSelect(label: "Dest"), [.dest])],
      ])
      
      vc.addPatchChangeBlock(paths: [[.amt], [.dest]]) { values in
        let on = values[[.amt]] != 127 && values[[.dest]] != 0
        vc.view.alpha = on ? 1 : 0.4
      }
    }
  }
  
}
