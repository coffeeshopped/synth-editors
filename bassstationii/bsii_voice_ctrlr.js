
class BassStationIIVoiceController : NewPatchEditorController {
  
  override func loadView(_ view: PBView) {
    ['child', OscController(prefix: "osc/0", label: "Osc 1"), "osc0"]
    ['child', OscController(prefix: "osc/1", label: "Osc 2"), "osc1"]
    ['child', OscController(prefix: "sub", label: "Osc 3"), "osc2"]
    ['child', SubController(), "sub"]
    
    let _: [LFOController] = addChildren(count: 2, panelPrefix: "lfo")
    ['child', EnvController(prefix: "mod/env", label: "Mod"), "mod"]
    ['child', EnvController(prefix: "amp/env", label: "Amp"), "amp"]

    ['panel', 'mix', { }, [[
      ["Osc 1", "osc/0/level"],
      ["Noise", "noise/level"],
      ],[
      ["Osc 2", "osc/1/level"],
      ["Ring", "ringMod/level"],
      ],[
      ["Sub", "sub/level"],
      ["Ext", "ext/level"],
    ]]]
    
    ['panel', 'afx', { }, [[
      [{switch: "Sub Mode"}, "sub/mode"],
      ["Overlay", "extra"],
    ]]]

    ['panel', 'para', { }, [[
      [{checkbox: "Paraphonic"}, "paraphonic"],
      ["Glide", "porta"],
      ["Divergence", "glide/split"],
      ["Bend", "bend"],
      ["Osc Error", "osc/slop"],
      [{checkbox: "Osc Sync"}, "sync"],
    ]]]

    let shape = {switch: "Shape"}
    let slope = {switch: "Slope"}
    ['panel', 'filter', { }, [[
      [{switch: "Filter Type"}, "filter/type"],
      (shape, "filter/shape"),
      (slope, "filter/slop"),
      ["Cutoff", "filter/cutoff"],
      ["Reson", "filter/reson"],
      ["Overdrive", "filter/drive"],
      [{select: "Track"}, "filter/trk"],
      ["Env Amt", "filter/mod/env/cutoff/amt"],
      ["LFO2 Amt", "filter/lfo/1/cutoff/amt"],
    ]]]
    
    ['patchChange', "filter/type",  {
      let alpha: CGFloat = $0 == 0 ? 1 : 0.2
      shape.alpha = alpha
      slope.alpha = alpha
    }
    
    ['panel', 'fx', { }, [[
      ["Distortion", "dist"],
      ["Osc Filter Mod", "osc/filter/mod"],
      ],[
      ["Limiter", "limiter"],
      ["MicroTune", "micro/tune"],
    ]]]
        
    let wheelLabel = LabelItem(text: "Mod Wheel", gridWidth: 1)
    wheelLabel.textAlignment = .center
    ['panel', 'wheel', { }, [[
      ["LFO1>Pitch", "mod/lfo/0/pitch"],
      ["LFO2>Cutoff", "mod/lfo/1/filter/cutoff"],
      ["Cutoff", "mod/filter/cutoff"],
      ["Osc2 Pitch", "mod/osc/1/pitch"],
      ],[
      (wheelLabel, nil),
      ]]]

    let afterLabel = LabelItem(text: "Aftertouch", gridWidth: 1)
    afterLabel.textAlignment = .center
    ['panel', 'after', { }, [[
      ["LFO1>Pitch", "aftertouch/lfo/0/pitch"],
      ["LFO2 Speed", "aftertouch/lfo/1/speed"],
      ["Cutoff", "aftertouch/filter/cutoff"],
      ],[
      (afterLabel, nil),
      ]]]

    let rhythm = PBKnob(label: "Rhythm")
    let arpOct = {switch: "Octave"}
    let arpSwing = PBKnob(label: "Swing")
    let arpMode = {select: "Note Mode"}
    let latch = {checkbox: "Latch"}
    let retrig = {checkbox: "Retrig"}
    ['panel', 'arp', { }, [[
      [{checkbox: "Arp"}, "arp/on"],
      (rhythm, "arp/rhythm"),
      ],[
      (arpOct, "arp/octave"),
      (arpSwing, "arp/swing"),
      ],[
      (arpMode, "arp/note/mode"),
      ],[
      (latch, "arp/latch"),
      (retrig, "arp/seq/retrigger"),
    ]]]
    
    ['patchChange', "arp/on",  {
      let alpha: CGFloat = $0 == 1 ? 1 : 0.2
      [rhythm, arpOct, arpSwing, arpMode, latch, retrig].forEach { $0.alpha = alpha }
    }
    ['patchChange', "sub/mode",  { [weak self] in
      self?.panels["osc2"]?.alpha = $0 == 1 ? 1 : 0.2
    }
    
    ['patchChange', "sub/mode",  { [weak self] in
      self?.panels["osc2"]?.alpha = $0 == 1 ? 1 : 0.2
      self?.panels["sub"]?.alpha = $0 == 0 ? 1 : 0.2
    }

    
    addPanelsToLayout(andView: view)
    
    ['row', [["mix", 2], ["osc0", 9], ["sub", 2]], opts: "alignAllTop")
    ['row', [["filter", 9], ["para", 6]]]
    ['row', [["mod", 6], ["amp", 6], ["fx", 2], ["arp", 2]], opts: "alignAllTop")
    ['row', [["lfo0", 3], ["lfo1", 3], ["wheel", 4], ["after", 3]], pinned: false)
    
    ['col', [["mix", 3], ["filter", 1], ["mod", 2], ["lfo0", 2]]]
    ['col', [["osc0", 1], ["osc1", 1], ["osc2", 1]], opts: "alignAllLeading/alignAllTrailing", pinned: false)
    ['col', [["sub", 2], ["afx", 1]], opts: "alignAllLeading/alignAllTrailing", pinned: false)
    
    ['eq', ["fx", "after"], 'trailing']
    ['eq', ["mix", "osc2", "afx"], 'bottom']
    ['eq', ["mod", "amp", "fx"], 'bottom']
    ['eq', ["after", "arp"], 'bottom']
    
    addColor(panels: ["osc0", "osc1", "osc2", "mix", "sub", "afx", "para"])
    addColor(panels: ["filter", "fx"], level: 2)
    addColor(panels: ["mod", "amp", "lfo0", "lfo1", "wheel", "after", "arp"], level: 3)
  }
    
  
  class OscController : NewPatchEditorController {
    override var prefix: SynthPath? { return _prefix }
    private var _prefix: SynthPath?
        
    convenience init(prefix: SynthPath, label: String) {
      self.init()
      _prefix = prefix
      osc.label = label
    }

    private let osc = {switch: "Osc"}

    override func loadView(_ view: PBView) {
      let pwEnv = PBKnob(label: "Mod Env→")
      let pw = PBKnob(label: "PW")
      let pwLFO = PBKnob(label: "←LFO 2")

      ['grid', [[
        (osc, "wave"),
        [{switch: "Range"}, "octave"],
        ["Coarse", "coarse"],
        ["Fine", "fine"],
        ["Env Amt", "mod/env/pitch/amt"],
        ["LFO 1 Amt", "lfo/0/pitch/amt"],
        (pwEnv, "mod/env/pw/amt"),
        (pw, [ .pw]),
        (pwLFO, "lfo/1/pw/amt"),
      ]]]
      
      ['patchChange', "wave",  {
        let alpha: CGFloat = $0 == 3 ? 1 : 0.2
        [pwEnv, pw, pwLFO].forEach { $0.alpha = alpha }
      }
    }
  }
  
  class SubController : NewPatchEditorController {
    override var prefix: SynthPath? { return "sub" }
    
    override func loadView(_ view: PBView) {
      ['grid', [[
        [{switch: "Sub Shape"}, "sub/wave"],
        [{switch: "Octave"}, "sub/octave"],
        ],[
        ["Coarse", "coarse"],
        ["Fine", "fine"],
      ]]]
    }
  }
  
  class EnvController : NewPatchEditorController {
    let env = PBAdsrEnvelopeControl()
    
    override var prefix: SynthPath? { return _prefix }
    private var _prefix: SynthPath?
        
    convenience init(prefix: SynthPath, label: String) {
      self.init()
      _prefix = prefix
      env.label = label
    }
    
    override func loadView(_ view: PBView) {
      let retrig = {checkbox: "Retrigger"}
      let rCount = PBKnob(label: "Retrig #")
      let decay = PBKnob(label: "Decay")
      ['grid', [[
        (env, nil),
        [{switch: "Mode"}, "trigger"],
        (retrig, "retrigger"),
        (rCount, "retrigger/number"),
        ],[
        ["Attack", "attack"],
        (decay, "decay"),
        ["Sustain", "sustain"],
        ["Release", "release"],
        [{checkbox: "Fixed Dur"}, "fixed"],
        ["Velo", "velo"],
      ]]]
      
      ['patchChange', "fixed",  {
        retrig.alpha = $0 == 0 ? 1 : 0.2
        decay.label = $0 == 0 ? "Decay" : "Duration"
      }
      addPatchChangeBlock(paths: ["fixed", "retrigger"]) {
        guard let fixed = $0["fixed"],
              let r = $0["retrigger"] else { return }
        rCount.alpha = fixed == 0 && r == 1 ? 1 : 0.2
      }
      
      ['editMenu', env, (
        paths: { ["attack", "decay", "sustain", "release"] },
        pasteboardType: "com.cfshpd.BSIIEnv",
        initialize: { [0, 0, 127, 0] },
        randomize: { (0..<4).map { _ in (0...127).random()! } }
      ))
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      let env = self.env
      ['patchChange', "attack",  { env.attack = CGFloat($0) / 127 }
      ['patchChange', "decay",  { env.decay = CGFloat($0) / 127 }
      ['patchChange', "sustain",  { env.sustain = CGFloat($0) / 127 }
      ['patchChange', "release",  { env.rrelease = CGFloat($0) / 127 }
    }
  }
  
  class LFOController : NewPatchEditorController {
    
    override func loadView(_ view: PBView) {
      let rate = PBKnob(label: "Speed")
      
      addPatchChangeBlock(paths: ["speed", "sync"]) { [weak self] in
        let mode = self?.latestValue(path: "time/sync") ?? 0
        rate.value = $0[mode == 0 ? "speed" : "sync"] ?? 0
      }
      addControlChangeBlock(control: rate) { [weak self] in
        let mode = self?.latestValue(path: "time/sync") ?? 0
        let path: SynthPath = mode == 0 ? "speed" : "sync"
        return .paramsChange([path : rate.value])
      }
    }
  }
  
}

const lfo = {
  index: 'lfo',
  labelItem: 'wave',
  text: i => `LFO ${i+1}`,
  gridBuilder: [[
    [{switch: "LFO \(index + 1)"}, "wave"],
    ["Delay", "delay"],
    (rate, nil),
    ],[
    [{checkbox: "Key Sync"}, "key/sync"],
    ["Slew", "slew"],
    [{switch: "Mode"}, "time/sync"],
  ]],
  effects: [
    ["patchChange", ['time/sync'], (values, state, locals) => {
      const sync = values['time/sync']
      let label: String
      let path: SynthPath
      switch $0 {
      if (sync == 0) {
        label = "Speed"
        path = "speed"
      }
      else {
        label = "Sync"
        path = "sync"
      }
      rate.label = label
      rate.value = self?.latestValue(path: path) ?? 0
      if let param = self?.latestParam(path: path) {
        self?.defaultConfigure(control: rate, forParam: param)
      }

    }]
  ],
}
