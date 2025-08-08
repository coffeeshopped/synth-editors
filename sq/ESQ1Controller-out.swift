
struct ESQController {

  const srcAmtCtrls = (_ vc: FnPatchEditorController, prefix: SynthPath, src: String) => {
    let srcCtrl = {select: src}
    let amtCtrl = PBKnob("←Amt")
    ['patchChange', { paths: [prefix + "src", prefix + "amt"], fn: values => {
      guard let src = values[prefix + "src"],
            let amt = values[prefix + "amt"] else { return }
      let alpha: CGFloat = src == 15 || amt == 0 ? 0.4 : 1
      [srcCtrl, amtCtrl].forEach { $0.alpha = alpha }
    }
    return (srcCtrl, amtCtrl)
  }

  const controller = (sq80: Bool) => {
    ActivatedFnEditorController { vc in
      ['children', 4, "env", {
        envController(index: $0, extra: sq80)
      })
      ['children', 3, "osc", oscController]
      ['children', 3, "amp", ampController]
      ['children', 3, "lfo", lfoController]
      
      ['panel', 'mods', { }, [[
        ["Glide", "glide"],
        [{checkbox: "AM"}, "am"],
        [{checkbox: "Rotate"}, "rotate"],
        ],[
        [{checkbox: "Wave Reset"}, "wave/reset"],
        [{checkbox: "Cycle"}, "cycle"],
        [{checkbox: "Env Reset"}, "env/reset"],
        ]]]
      
      let (src1, amt1) = srcAmtCtrls(vc, prefix: "filter/mod/0", src: "Mod 1")
      let (src2, amt2) = srcAmtCtrls(vc, prefix: "filter/mod/1", src: "Mod 2")
      
      let fLabel = vc.createLabel()
      fLabel.textAlignment = .center
      fLabel.text = "Filter"
      ['panel', 'filter', { }, [[
        ["Cutoff", "cutoff"],
        ["Reson", "reson"],
        (src1, "filter/mod/0/src"),
        (amt1, "filter/mod/0/amt"),
        ],[
        (fLabel, nil),
        ["Key Track", "filter/mod/2/amt"],
        (src2, "filter/mod/1/src"),
        (amt2, "filter/mod/1/amt"),
        ]]]

      let (panSrc, panAmt) = srcAmtCtrls(vc, prefix: "pan/mod", src: "Pan Mod")

      ['panel', 'amp', { }, [[
        ["Env 4 > Amp 4", "amp/3/mod/amt"],
        ["Pan", "pan"],
        [{checkbox: "Mono"}, "mono"],
        ],[
        (panSrc, "pan/mod/src"),
        (panAmt, "pan/mod/amt"),
        [{checkbox: "Sync"}, "sync"],
        ]]]

      let splitDirection = {switch: "Split"}
      let splitLayerProgram = {select: "S/L Pgm"}
      let layerProgram = {select: "Layer Pgm"}
      let splitProgram = {select: "Split Pgm"}
      ['panel', 'splits', { }, [
        [[{checkbox: "Split/Layer"}, "split/layer"]],
        [(splitLayerProgram, "split/layer/pgm")],
        [[{checkbox: "Layer"}, "layer"]],
        [(layerProgram, "layer/pgm")],
        [(splitDirection, "split/direction")],
        [(splitProgram, "split/pgm")],
        [["Split Key", "split/pt"]]
        ])
      
      vc.addParamChangeBlock { (params) in
        guard let param = params.params["patch/name"] as? OptionsParam else { return }
        splitLayerProgram.options = param.options
        layerProgram.options = param.options
        splitProgram.options = param.options
      }

      vc.addLayoutConstraints { layout in
        ['row', [
          ("osc0",9),("amp0",7),("mods",8),("splits",3),("lfo0",8),
          ], options: "alignAllTop", pinned: true, spacing: "-s1-")
        ['row', [
          ("osc1",9),("amp1",7),("filter",8),
          ], spacing: "-s1-")
        ['row', [
          ("osc2",9),("amp2",7),("amp",8),
          ], spacing: "-s1-")
        ['row', [
          ("env0",8),("env1",8),("env2",8),("env3",8),
          ], pinned: true, spacing: "-s1-")

        ['col', [
          ("osc0",2),("osc1",2),("osc2",2),("env0",3),
          ], pinned: true, spacing: "-s1-")
        ['col', [
          ("lfo0",2),("lfo1",2),("lfo2",2),("env3",3),
          ], options: "alignAllTrailing", pinned: true, spacing: "-s1-")
        
        ['eq', ["osc0","amp0","mods"], 'bottom']
        ['eq', ["mods","filter","amp"], 'trailing']
        ['eq', ["lfo0","lfo1","lfo2"], 'leading']
        ['eq', ["amp","splits","lfo2"], 'bottom']
      }
      
      vc.addColorToAll(except: ["filter", "env0", "env1", "env2", "env3", "lfo0", "lfo1", "lfo2"])
      vc.addColor(panels: ["filter"], level: 0)
      vc.addColor(panels: ["env0", "env1", "env2", "env3"], level: 2)
      vc.addColor(panels: ["lfo0", "lfo1", "lfo2"], level: 2)
    }
  }
  
  const oscController = (index: Int) => {
    ActivatedFnEditorController { vc in
      let waveDropdown = {select: "Osc \(index + 1}")
      waveDropdown.bold = true
      vc.prefixBlock = { _ in "osc/index" }

      let (src1, amt1) = srcAmtCtrls(vc, prefix: "mod/0", src: "Mod 1")
      let (src2, amt2) = srcAmtCtrls(vc, prefix: "mod/1", src: "Mod 2")
      
      ['grid', [[
        (waveDropdown, "wave"),
        ["Octave", "octave"],
        ["Semi", "semitone"],
        ["Fine", "fine"],
        ],[
        (src1, "mod/0/src"),
        (amt1, "mod/0/amt"),
        (src2, "mod/1/src"),
        (amt2, "mod/1/amt"),
        ]]]
    }
  }
  
  const ampController = (index: Int) => {
    ActivatedFnEditorController { vc in
      let enableCheckbox = {checkbox: "Amp \(index + 1}")
      enableCheckbox.bold = true

      vc.prefixBlock = { _ in "amp/index" }
      
      let (src1, amt1) = srcAmtCtrls(vc, prefix: "mod/0", src: "Mod 1")
      let (src2, amt2) = srcAmtCtrls(vc, prefix: "mod/1", src: "Mod 2")

      ['grid', [[
        (enableCheckbox, "on"),
        (src1, "mod/0/src"),
        (amt1, "mod/0/amt"),
        ],[
        ["Level", "level"],
        (src2, "mod/1/src"),
        (amt2, "mod/1/amt"),
        ]]]
      
      vc.dims(forPath: "on")
    }
  }
  
  const lfoController = (index: Int) => {
    ActivatedFnEditorController { vc in
      let waveDropdown = {switch: "LFO \(index + 1}")
      waveDropdown.bold = true

      vc.prefixBlock = { _ in "lfo/index" }
      
      ['grid', [[
        (waveDropdown, "wave"),
        ["Freq", "freq"],
        [{checkbox: "Reset"}, "reset"],
        [{checkbox: "Humanize"}, "analogFeel"],
        ],[
        ["Level 1", "level/0"],
        ["Delay", "delay"],
        ["Level 2", "level/1"],
        [{select: "Mod Source"}, "mod/src"],
        ]]]
    }
  }
  
  const envController = (index: Int, extra: Bool) => {
    ActivatedFnEditorController { vc in
      let envCtrl = PBRateLevelEnvelopeControl("Env \(index + 1)")
      envCtrl.pointCount = 4
      envCtrl.bipolar = true
      envCtrl.bold = true

      vc.prefixBlock = { _ in "env/index" }
      
      ['grid', [[
        (envCtrl, nil),
        ["T1 Velo", "rate/0/velo"],
        ["T Key", "rate/key"],
        ],[
        ["L1", "level/0"],
        ["L2", "level/1"],
        ["L3", "level/2"],
        ["L Velo", "level/velo"],
        ] + (extra ? [[{switch: "←LV"}, "velo/extra"]] : []), [
        ["T1", "rate/0"],
        ["T2", "rate/1"],
        ["T3", "rate/2"],
        ["T4", "rate/3"],
        ] + (extra ? [[{checkbox: "2nd R"}, "release/extra"]] : [])])

      (0..<3).forEach { step in
        vc.addPatchChangeBlock(path: "level/step") { envCtrl.set(level: CGFloat($0) / 63, forIndex: step) }
      }
      (0..<4).forEach { step in
        vc.addPatchChangeBlock(path: "rate/step") { envCtrl.set(rate: CGFloat($0) / 63, forIndex: step) }
      }
      vc.registerForEditMenu(envCtrl, bundle: (
        paths: { 3.map { "level/$0" } + 4.map { "rate/$0" } },
        pasteboardType: "com.cfshpd.ESQEnvelope",
        initialize: { [63, 63, 63, 0, 63, 0 ,0] },
        randomize: { 3.map { _ in (-63...63).random()! } + 4.map { _ in (0...63).random()! } }
      ))    }
  }
}

