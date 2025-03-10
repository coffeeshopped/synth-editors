
class DW8KVoiceController : NewPatchEditorController {
  
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0.02
    paddedView.verticalPadding = 0.15
    let view = paddedView.mainView
    
    addChild(FilterController(), withPanel: "filter")
    addChild(AmpController(), withPanel: "amp")
    createPanels(forKeys: ["osc0","osc1","autoBend", "noise", "mg", "porta", "assign", "after", "bend", "delay"])
    addPanelsToLayout(andView: view)
    
    layout.addRowConstraints([("osc0", 3.5), ("autoBend", 4), ("mg", 3), ("porta", 1)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("osc1", 6), ("noise", 1.5)], pinned: false, spacing: "-s1-")
    layout.addRowConstraints([("filter", 5), ("amp", 3), ("bend", 3)], options: [.alignAllTop], pinned: false, spacing: "-s1-")
    layout.addColumnConstraints([("osc0", 1), ("osc1", 1), ("filter", 3)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("bend", 1), ("delay", 2)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
    layout.addColumnConstraints([("porta", 1), ("assign", 1), ("after", 3)], options: [.alignAllLeading, .alignAllTrailing], pinned: true, spacing: "-s1-")
    
    layout.addEqualConstraints(forItemKeys: ["autoBend", "noise"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["mg", "bend"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["osc0", "autoBend"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["noise", "mg"], attribute: .bottom)
    layout.addEqualConstraints(forItemKeys: ["filter", "amp", "delay"], attribute: .bottom)
    
    quickGrid(panel: "osc0", items: [[
      (PBSelect(label: "Osc 1"), [.osc, .i(0), .wave], nil),
      (PBSwitch(label: "Octave"), [.osc, .i(0), .octave], nil),
      (PBKnob(label: "Level"), [.osc, .i(0), .level], nil),
      ]])
    
    quickGrid(panel: "autoBend", items: [[
      (PBSwitch(label: "Auto Bend"), [.auto, .bend, .select], nil),
      (PBSwitch(label: "Mode"), [.auto, .bend, .mode], nil),
      (PBKnob(label: "Time"), [.auto, .bend, .time], nil),
      (PBKnob(label: "Int"), [.auto, .bend, .amt], nil),
      ]])
    
    quickGrid(panel: "mg", items: [[
      (PBSwitch(label: "MG Wave"), [.lfo, .wave], nil),
      (PBKnob(label: "Freq"), [.lfo, .freq], nil),
      (PBKnob(label: "Delay"), [.lfo, .delay], nil),
      ],[
      (PBKnob(label: "Pitch"), [.lfo, .pitch], nil),
      (PBKnob(label: "Filter"), [.lfo, .filter], nil),
      ]])
    
    quickGrid(panel: "porta", items: [[
      (PBKnob(label: "Porta"), [.porta], nil),
      ]])
    
    quickGrid(panel: "osc1", items: [[
      (PBSelect(label: "Osc 2"), [.osc, .i(1), .wave], nil),
      (PBSwitch(label: "Octave"), [.osc, .i(1), .octave], nil),
      (PBKnob(label: "Level"), [.osc, .i(1), .level], nil),
      (PBSelect(label: "Interval"), [.interval], nil),
      (PBKnob(label: "Detune"), [.detune], nil),
      ]])
    
    quickGrid(panel: "noise", items: [[
      (PBKnob(label: "Noise"), [.noise], nil),
      ]])
    
    quickGrid(panel: "assign", items: [[
      (PBSelect(label: "Assign Mode"), [.assign, .mode], nil),
      ]])
    
    quickGrid(panel: "bend", items: [[
      (PBKnob(label: "Pitch Bend"), [.bend, .pitch], nil),
      (PBCheckbox(label: "Filter Bend"), [.bend, .filter], nil),
      ]])
    
    quickGrid(panel: "delay", items: [[
      (PBKnob(label: "Delay Time"), [.delay, .time], nil),
      (PBKnob(label: "Factor"), [.delay, .scale], nil),
      (PBKnob(label: "Feedback"), [.delay, .feedback], nil),
      ],[
      (PBKnob(label: "Mod Freq"), [.delay, .mod, .freq], nil),
      (PBKnob(label: "Mod Int"), [.delay, .mod, .amt], nil),
      (PBKnob(label: "Level"), [.delay, .level], nil),
      ]])

    quickGrid(panel: "after", items: [[
      (PBKnob(label: "After>Vib"), [.aftertouch, .vib], nil),
      ],[
      (PBKnob(label: "After>Filter"), [.aftertouch, .filter], nil),
      ],[
      (PBKnob(label: "After>Amp"), [.aftertouch, .amp], nil),
      ]])

    layout.activateConstraints()
    self.view = paddedView
    
    addColor(panels: ["osc0","osc1","autoBend", "noise", "mg", "porta", "assign", "after", "bend", "delay", "amp"])
    addColor(panels: ["filter"], level: 2)

  }
  
  
  class EnvController : NewPatchEditorController {
    fileprivate let env = DW8KEnvelopeControl(label: "")
    
    func setupEnv(pre: SynthPath) {
      let env = self.env
      addPatchChangeBlock(path: pre + [.attack]) { env.set(rate: CGFloat($0) / 31, forIndex: 0) }
      addPatchChangeBlock(path: pre + [.decay]) { env.set(rate: CGFloat($0) / 31, forIndex: 1) }
      addPatchChangeBlock(path: pre + [.brk]) { env.set(level: CGFloat($0) / 31, forIndex: 1) }
      addPatchChangeBlock(path: pre + [.slop]) { env.set(rate: CGFloat($0) / 31, forIndex: 2) }
      addPatchChangeBlock(path: pre + [.sustain]) { env.set(level: CGFloat($0) / 31, forIndex: 2) }
      addPatchChangeBlock(path: pre + [.release]) { env.set(rate: CGFloat($0) / 31, forIndex: 3) }
      
      registerForEditMenu(env, bundle: (
        paths: {[
          pre + [.attack],
          pre + [.decay],
          pre + [.brk],
          pre + [.slop],
          pre + [.sustain],
          pre + [.release],
        ]},
        pasteboardType: "com.cfshpd.DW8KEnvelope",
        initialize: nil,
        randomize: nil
      ))
    }
  }
  
  class FilterController : EnvController {
    override func loadView(_ view: PBView) {
      env.label = "Filter"
      
      quickGrid(view: view, items: [[
        (env, nil, "env"),
        (PBKnob(label: "Env Int"), [.filter, .env, .amt], nil),
        (PBKnob(label: "Cutoff"), [.cutoff], nil),
        (PBKnob(label: "Velo"), [.filter, .velo], nil),
        ],[
        (PBKnob(label: "Attack"), [.filter, .env, .attack], nil),
        (PBKnob(label: "Brk Pt"), [.filter, .env, .brk], nil),
        (PBKnob(label: "Sustain"), [.filter, .env, .sustain], nil),
        (PBKnob(label: "Reson"), [.reson], nil),
        (PBView(), nil, "fspace"),
        ],[
        (PBKnob(label: "Decay"), [.filter, .env, .decay], nil),
        (PBKnob(label: "Slope"), [.filter, .env, .slop], nil),
        (PBKnob(label: "Release"), [.filter, .env, .release], nil),
        (PBSwitch(label: "Polarity"), [.filter, .env, .polarity], nil),
        (PBSwitch(label: "Key Trk"), [.filter, .keyTrk], nil),
        ]])
      
      setupEnv(pre: [.filter, .env])
    }
    
  }
  
  class AmpController : EnvController {
    override func loadView(_ view: PBView) {
      env.label = "Amp"
      
      quickGrid(view: view, items: [[
        (env, nil, "env"),
        (PBKnob(label: "Velo"), [.amp, .velo], nil),
        ],[
        (PBKnob(label: "Attack"), [.amp, .env, .attack], nil),
        (PBKnob(label: "Brk Pt"), [.amp, .env, .brk], nil),
        (PBKnob(label: "Sustain"), [.amp, .env, .sustain], nil),
        ],[
        (PBKnob(label: "Decay"), [.amp, .env, .decay], nil),
        (PBKnob(label: "Slope"), [.amp, .env, .slop], nil),
        (PBKnob(label: "Release"), [.amp, .env, .release], nil),
        ]])
      
      setupEnv(pre: [.amp, .env])
    }
  }
}
