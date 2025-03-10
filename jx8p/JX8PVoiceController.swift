
class JX8PVoiceController : NewPatchEditorController {

  private let patchPanels = ["assign", "bend", "porta", "after"]

  override func loadView(_ view: PBView) {
    let _: [EnvController] = addChildren(count: 2, panelPrefix: "env")
    createPanels(forKeys: ["osc0", "osc1", "pitch", "mix0", "mix1", "osc1mix", "filter", "amp", "lfo", "chorus"])
    createPanels(forKeys: patchPanels)
    addPanelsToLayout(andView: view)

    layout.addRowConstraints([("assign", 2.5), ("bend", 2), ("porta", 2), ("after", 1)], pinned: true, spacing: "-s1-")

    layout.addRowConstraints([("osc0", 6), ("pitch", 1), ("mix0", 1), ("osc1mix", 2)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("filter", 8)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("lfo", 3), ("chorus", 1), ("amp", 3)], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("env0", 4), ("env1", 4)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("assign", 1), ("osc0", 1), ("osc1", 1), ("filter", 1), ("lfo", 1), ("env0", 2)], pinned: true, spacing: "-s1-")
    
    layout.addColumnConstraints([("mix0", 1), ("mix1", 1)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["osc0", "osc1"], attribute: .trailing)
    layout.addEqualConstraints(forItemKeys: ["osc1", "pitch", "mix1", "osc1mix"], attribute: .bottom)
    
    
    quickGrid(panel: "osc0", items: [[
      (PBSwitch(label: "DCO 1"), [.osc, .i(0), .wave], nil),
      (PBSwitch(label: "Range"), [.osc, .i(0), .range], nil),
      (PBKnob(label: "Tune"), [.osc, .i(0), .tune], nil),
      (PBSwitch(label: "Cross Mod"), [.osc, .mod], nil),
      (PBKnob(label: "LFO"), [.osc, .i(0), .lfo, .depth], nil),
      (PBKnob(label: "Env"), [.osc, .i(0), .env, .depth], nil),
      ]])

    quickGrid(panel: "osc1", items: [[
      (PBSwitch(label: "DCO 2"), [.osc, .i(1), .wave], nil),
      (PBSwitch(label: "Range"), [.osc, .i(1), .range], nil),
      (PBKnob(label: "Tune"), [.osc, .i(1), .tune], nil),
      (PBKnob(label: "Fine"), [.osc, .i(1), .fine], nil),
      (PBKnob(label: "LFO"), [.osc, .i(1), .lfo, .depth], nil),
      (PBKnob(label: "Env"), [.osc, .i(1), .env, .depth], nil),
      ]])

    quickGrid(panel: "pitch", items: [[
      (PBSwitch(label: "Pitch Env"), [.pitch, .env, .mode], nil),
      ],[
      (PBSwitch(label: "Pitch Dyna"), [.pitch, .velo], nil),
      ]])

    quickGrid(panel: "mix0", items: [[
      (PBKnob(label: "DCO 1 Level"), [.osc, .i(0), .level], nil),
      ]])

    quickGrid(panel: "mix1", items: [[
      (PBKnob(label: "DCO 2 Level"), [.osc, .i(1), .level], nil),
      ]])

    quickGrid(panel: "osc1mix", items: [[
      (PBSwitch(label: "DCO 2 Env"), [.osc, .i(1), .amp, .env, .mode], nil),
      (PBKnob(label: "Env Depth"), [.osc, .i(1), .amp, .env, .depth], nil),
      ],[
      (PBSwitch(label: "DCO 2 Dyna"), [.osc, .i(1), .amp, .velo], nil),
      ]])

    quickGrid(panel: "filter", items: [[
      (PBSwitch(label: "HPF"), [.hi, .cutoff], nil),
      (PBKnob(label: "VCF Cutoff"), [.cutoff], nil),
      (PBKnob(label: "Reson"), [.reson], nil),
      (PBKnob(label: "LFO"), [.filter, .lfo, .depth], nil),
      (PBKnob(label: "Env"), [.filter, .env, .depth], nil),
      (PBSwitch(label: "Env Mode"), [.filter, .env, .mode], nil),
      (PBSwitch(label: "Dyna"), [.filter, .velo], nil),
      (PBKnob(label: "Key Trk"), [.filter, .keyTrk], nil),
      ]])

    quickGrid(panel: "lfo", items: [[
      (PBSwitch(label: "LFO"), [.lfo, .wave], nil),
      (PBKnob(label: "Delay"), [.lfo, .delay], nil),
      (PBKnob(label: "Rate"), [.lfo, .rate], nil),
      ]])

    quickGrid(panel: "chorus", items: [[
      (PBSwitch(label: "Chorus"), [.chorus], nil),
      ]])

    quickGrid(panel: "amp", items: [[
      (PBKnob(label: "Amp Level"), [.amp, .level], nil),
      (PBSwitch(label: "Env Mode"), [.amp, .env, .mode], nil),
      (PBSwitch(label: "Dyna"), [.amp, .velo], nil),
      ]])

    // PATCH
    
    quickGrid(panel: "assign", items: [[
      (PBSelect(label: "Assign Mode"), [.patch, .assign, .mode], nil),
      (PBKnob(label: "Unison Detune"), [.patch, .unison, .detune], nil),
      ]])

    quickGrid(panel: "bend", items: [[
      (PBSwitch(label: "Bend"), [.patch, .bend], nil),
      (PBKnob(label: "LFO"), [.patch, .bend, .lfo], nil),
      ]])

    quickGrid(panel: "porta", items: [[
      (PBSwitch(label: "Porta"), [.patch, .porta], nil),
      (PBKnob(label: "Time"), [.patch, .porta, .time], nil),
      ]])

    quickGrid(panel: "after", items: [[
      (PBSwitch(label: "Aftertouch"), [.patch, .aftertouch], nil),
      ]])
    
    addColorToAll(except: patchPanels + ["filter", "amp"], level: 2)
    addColor(panels: patchPanels)
    addColor(panels: ["filter", "amp"], level: 3)
  }
  
  
  class EnvController : NewPatchEditorController {
    
    override var prefix: SynthPath? { return [.env, .i(index)] }
    
    override var index: Int {
      didSet { env.label = "Env \(index + 1)"}
    }
    
    private let env = PBAdsrEnvelopeControl()
    
    override func loadView(_ view: PBView) {
      quickGrid(view: view, items: [[
        (PBKnob(label: "Attack"), [.attack], nil),
        (PBKnob(label: "Decay"), [.decay], nil),
        (PBKnob(label: "Sustain"), [.sustain], nil),
        (PBKnob(label: "Release"), [.release], nil),
        ],[
        (env, nil, "env"),
        (PBSwitch(label: "Key Follow"), [.keyTrk], nil),
        ]])
      
      let env = self.env
      addPatchChangeBlock(path: [.attack]) { env.attack = CGFloat($0) / 127 }
      addPatchChangeBlock(path: [.decay]) { env.decay = CGFloat($0) / 127 }
      addPatchChangeBlock(path: [.sustain]) { env.sustain = CGFloat($0) / 127 }
      addPatchChangeBlock(path: [.release]) { env.rrelease = CGFloat($0) / 127 }
      
      registerForEditMenu(env, bundle: (
        paths: {[[.attack],
                [.decay],
                [.sustain],
                [.release],
        ]},
        pasteboardType: "com.cfshpd.JX8PEnvelope",
        initialize: nil,
        randomize: nil
      ))
    }
  }
}
