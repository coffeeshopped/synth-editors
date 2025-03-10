
struct ESQController {

  static func srcAmtCtrls(_ vc: FnPatchEditorController, prefix: SynthPath, src: String) -> (PBSelect, PBKnob) {
    let srcCtrl = PBSelect(src)
    let amtCtrl = PBKnob("←Amt")
    vc.addPatchChangeBlock(paths: [prefix + [.src], prefix + [.amt]]) { values in
      guard let src = values[prefix + [.src]],
            let amt = values[prefix + [.amt]] else { return }
      let alpha: CGFloat = src == 15 || amt == 0 ? 0.4 : 1
      [srcCtrl, amtCtrl].forEach { $0.alpha = alpha }
    }
    return (srcCtrl, amtCtrl)
  }

  static func controller(sq80: Bool) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.addChildren(count: 4, panelPrefix: "env", setup: {
        envController(index: $0, extra: sq80)
      })
      vc.addChildren(count: 3, panelPrefix: "osc", setup: oscController)
      vc.addChildren(count: 3, panelPrefix: "amp", setup: ampController)
      vc.addChildren(count: 3, panelPrefix: "lfo", setup: lfoController)
      
      vc.grid(panel: "mods", items: [[
        (PBKnob("Glide"), [.glide]),
        (PBCheckbox("AM"), [.am]),
        (PBCheckbox("Rotate"), [.rotate]),
        ],[
        (PBCheckbox("Wave Reset"), [.wave, .reset]),
        (PBCheckbox("Cycle"), [.cycle]),
        (PBCheckbox("Env Reset"), [.env, .reset]),
        ]])
      
      let (src1, amt1) = srcAmtCtrls(vc, prefix: [.filter, .mod, .i(0)], src: "Mod 1")
      let (src2, amt2) = srcAmtCtrls(vc, prefix: [.filter, .mod, .i(1)], src: "Mod 2")
      
      let fLabel = vc.createLabel()
      fLabel.textAlignment = .center
      fLabel.text = "Filter"
      vc.grid(panel: "filter", items: [[
        (PBKnob("Cutoff"), [.cutoff]),
        (PBKnob("Reson"), [.reson]),
        (src1, [.filter, .mod, .i(0), .src]),
        (amt1, [.filter, .mod, .i(0), .amt]),
        ],[
        (fLabel, nil),
        (PBKnob("Key Track"), [.filter, .mod, .i(2), .amt]),
        (src2, [.filter, .mod, .i(1), .src]),
        (amt2, [.filter, .mod, .i(1), .amt]),
        ]])

      let (panSrc, panAmt) = srcAmtCtrls(vc, prefix: [.pan, .mod], src: "Pan Mod")

      vc.grid(panel: "amp", items: [[
        (PBKnob("Env 4 > Amp 4"), [.amp, .i(3), .mod, .amt]),
        (PBKnob("Pan"), [.pan]),
        (PBCheckbox("Mono"), [.mono]),
        ],[
        (panSrc, [.pan, .mod, .src]),
        (panAmt, [.pan, .mod, .amt]),
        (PBCheckbox("Sync"), [.sync]),
        ]])

      let splitDirection = PBSwitch("Split")
      let splitLayerProgram = PBSelect("S/L Pgm")
      let layerProgram = PBSelect("Layer Pgm")
      let splitProgram = PBSelect("Split Pgm")
      vc.grid(panel: "splits", items: [
        [(PBCheckbox("Split/Layer"), [.split, .layer])],
        [(splitLayerProgram, [.split, .layer, .pgm])],
        [(PBCheckbox("Layer"), [.layer])],
        [(layerProgram, [.layer, .pgm])],
        [(splitDirection, [.split, .direction])],
        [(splitProgram, [.split, .pgm])],
        [(PBKnob("Split Key"), [.split, .pt])]
        ])
      
      vc.addParamChangeBlock { (params) in
        guard let param = params.params[[.patch, .name]] as? OptionsParam else { return }
        splitLayerProgram.options = param.options
        layerProgram.options = param.options
        splitProgram.options = param.options
      }

      vc.addLayoutConstraints { layout in
        layout.addRowConstraints([
          ("osc0",9),("amp0",7),("mods",8),("splits",3),("lfo0",8),
          ], options: [.alignAllTop], pinned: true, spacing: "-s1-")
        layout.addRowConstraints([
          ("osc1",9),("amp1",7),("filter",8),
          ], spacing: "-s1-")
        layout.addRowConstraints([
          ("osc2",9),("amp2",7),("amp",8),
          ], spacing: "-s1-")
        layout.addRowConstraints([
          ("env0",8),("env1",8),("env2",8),("env3",8),
          ], pinned: true, spacing: "-s1-")

        layout.addColumnConstraints([
          ("osc0",2),("osc1",2),("osc2",2),("env0",3),
          ], pinned: true, spacing: "-s1-")
        layout.addColumnConstraints([
          ("lfo0",2),("lfo1",2),("lfo2",2),("env3",3),
          ], options: [.alignAllTrailing], pinned: true, spacing: "-s1-")
        
        layout.addEqualConstraints(forItemKeys: ["osc0","amp0","mods"], attribute: .bottom)
        layout.addEqualConstraints(forItemKeys: ["mods","filter","amp"], attribute: .trailing)
        layout.addEqualConstraints(forItemKeys: ["lfo0","lfo1","lfo2"], attribute: .leading)
        layout.addEqualConstraints(forItemKeys: ["amp","splits","lfo2"], attribute: .bottom)
      }
      
      vc.addColorToAll(except: ["filter", "env0", "env1", "env2", "env3", "lfo0", "lfo1", "lfo2"])
      vc.addColor(panels: ["filter"], level: 0)
      vc.addColor(panels: ["env0", "env1", "env2", "env3"], level: 2)
      vc.addColor(panels: ["lfo0", "lfo1", "lfo2"], level: 2)
    }
  }
  
  static func oscController(index: Int) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      let waveDropdown = PBSelect("Osc \(index + 1)")
      waveDropdown.bold = true
      vc.prefixBlock = { _ in [.osc, .i(index)] }

      let (src1, amt1) = srcAmtCtrls(vc, prefix: [.mod, .i(0)], src: "Mod 1")
      let (src2, amt2) = srcAmtCtrls(vc, prefix: [.mod, .i(1)], src: "Mod 2")
      
      vc.grid(items: [[
        (waveDropdown, [.wave]),
        (PBKnob("Octave"), [.octave]),
        (PBKnob("Semi"), [.semitone]),
        (PBKnob("Fine"), [.fine]),
        ],[
        (src1, [.mod, .i(0), .src]),
        (amt1, [.mod, .i(0), .amt]),
        (src2, [.mod, .i(1), .src]),
        (amt2, [.mod, .i(1), .amt]),
        ]])
    }
  }
  
  static func ampController(index: Int) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      let enableCheckbox = PBCheckbox("Amp \(index + 1)")
      enableCheckbox.bold = true

      vc.prefixBlock = { _ in [.amp, .i(index)] }
      
      let (src1, amt1) = srcAmtCtrls(vc, prefix: [.mod, .i(0)], src: "Mod 1")
      let (src2, amt2) = srcAmtCtrls(vc, prefix: [.mod, .i(1)], src: "Mod 2")

      vc.grid(items: [[
        (enableCheckbox, [.on]),
        (src1, [.mod, .i(0), .src]),
        (amt1, [.mod, .i(0), .amt]),
        ],[
        (PBKnob("Level"), [.level]),
        (src2, [.mod, .i(1), .src]),
        (amt2, [.mod, .i(1), .amt]),
        ]])
      
      vc.dims(forPath: [.on])
    }
  }
  
  static func lfoController(index: Int) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      let waveDropdown = PBSwitch("LFO \(index + 1)")
      waveDropdown.bold = true

      vc.prefixBlock = { _ in [.lfo, .i(index)] }
      
      vc.grid(items: [[
        (waveDropdown, [.wave]),
        (PBKnob("Freq"), [.freq]),
        (PBCheckbox("Reset"), [.reset]),
        (PBCheckbox("Humanize"), [.analogFeel]),
        ],[
        (PBKnob("Level 1"), [.level, .i(0)]),
        (PBKnob("Delay"), [.delay]),
        (PBKnob("Level 2"), [.level, .i(1)]),
        (PBSelect("Mod Source"), [.mod, .src]),
        ]])
    }
  }
  
  static func envController(index: Int, extra: Bool) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      let envCtrl = PBRateLevelEnvelopeControl("Env \(index + 1)")
      envCtrl.pointCount = 4
      envCtrl.bipolar = true
      envCtrl.bold = true

      vc.prefixBlock = { _ in [.env, .i(index)] }
      
      vc.grid(items: [[
        (envCtrl, nil),
        (PBKnob("T1 Velo"), [.rate, .i(0), .velo]),
        (PBKnob("T Key"), [.rate, .key]),
        ],[
        (PBKnob("L1"), [.level, .i(0)]),
        (PBKnob("L2"), [.level, .i(1)]),
        (PBKnob("L3"), [.level, .i(2)]),
        (PBKnob("L Velo"), [.level, .velo]),
        ] + (extra ? [(PBSwitch("←LV"), [.velo, .extra])] : []), [
        (PBKnob("T1"), [.rate, .i(0)]),
        (PBKnob("T2"), [.rate, .i(1)]),
        (PBKnob("T3"), [.rate, .i(2)]),
        (PBKnob("T4"), [.rate, .i(3)]),
        ] + (extra ? [(PBCheckbox("2nd R"), [.release, .extra])] : [])])

      (0..<3).forEach { step in
        vc.addPatchChangeBlock(path: [.level, .i(step)]) { envCtrl.set(level: CGFloat($0) / 63, forIndex: step) }
      }
      (0..<4).forEach { step in
        vc.addPatchChangeBlock(path: [.rate, .i(step)]) { envCtrl.set(rate: CGFloat($0) / 63, forIndex: step) }
      }
      vc.registerForEditMenu(envCtrl, bundle: (
        paths: { 3.map { [.level, .i($0)] } + 4.map { [.rate, .i($0)] } },
        pasteboardType: "com.cfshpd.ESQEnvelope",
        initialize: { [63, 63, 63, 0, 63, 0 ,0] },
        randomize: { 3.map { _ in (-63...63).random()! } + 4.map { _ in (0...63).random()! } }
      ))    }
  }
}

