
class AlphaJunoVoiceController : NewPatchEditorController {
  
  override func loadView() {
    let paddedView = PaddedContainer()
    paddedView.horizontalPadding = 0.1
    paddedView.verticalPadding = 0.1
    let view = paddedView.mainView
    
    addChild(EnvController(), withPanel: "env")
    
    let pwm = PBKnob(label: "PW(M)")
    let pwmRate = PBKnob(label: "PWM Rate")
    grid(panel: "osc", items: [[
      (PBImageSelect(label: "Pulse Wave"), [.osc, .wave, .pulse]),
      (pwm, [.osc, .pw, .depth]),
      (PBSwitch(label: "Range"), [.osc, .range]),
      ],[
      (PBImageSelect(label: "Saw Wave"), [.osc, .wave, .saw]),
      (pwmRate, [.osc, .pw, .rate]),
      (PBKnob(label: "Bend"), [.bend]),
      ],[
      (PBImageSelect(label: "Sub Wave"), [.osc, .wave, .sub]),
      (PBKnob(label: "Sub Lvl"), [.osc, .sub, .level]),
      (PBKnob(label: "Noise"), [.osc, .noise, .level]),
      ],[
      (PBKnob(label: "LFO Amt"), [.pitch, .lfo]),
      (PBKnob(label: "Env Amt"), [.pitch, .env]),
      (PBSwitch(label: "Env Mode"), [.pitch, .env, .mode]),
      (PBKnob(label: "Aftertouch"), [.pitch, .aftertouch]),
      ]])
    
    grid(panel: "filter", items: [[
      (PBSwitch(label: "HPF"), [.hi, .cutoff]),
      (PBKnob(label: "Key Trk"), [.filter, .keyTrk]),
      ],[
      (PBKnob(label: "Filter Cutoff"), [.cutoff]),
      (PBKnob(label: "Reson"), [.reson]),
      ],[
      (PBSwitch(label: "Env Mode"), [.filter, .env, .mode]),
      (PBKnob(label: "Env Amt"), [.filter, .env]),
      ],[
      (PBKnob(label: "LFO Amt"), [.filter, .lfo]),
      (PBKnob(label: "Aftertouch"), [.filter, .aftertouch]),
      ]])
    
    grid(panel: "amp", items: [[
      (PBKnob(label: "Amp Level"), [.amp, .level]),
      ],[
      (PBSwitch(label: "Env Mode"), [.amp, .env, .mode]),
      ],[
      (PBKnob(label: "Aftertouch"), [.amp, .aftertouch]),
      ]])
    
    grid(panel: "lfo", items: [[
      (PBKnob(label: "LFO Rate"), [.lfo, .rate]),
      ],[
      (PBKnob(label: "Delay"), [.lfo, .delay]),
      ]])

    grid(panel: "chorus", items: [[
      (PBCheckbox(label: "Chorus"), [.chorus]),
      ],[
      (PBKnob(label: "Rate"), [.chorus, .rate]),
      ]])
    
    addPanelsToLayout(andView: view)

    layout.addRowConstraints([("osc",4), ("filter",2), ("amp",1), ("lfo",1)], options: [.alignAllTop], pinned: true, spacing: "-s1-")
    layout.addRowConstraints([("env",1)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("osc",4), ("env",2)], pinned: true, spacing: "-s1-")
    layout.addColumnConstraints([("lfo",2), ("chorus",2)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
    layout.addEqualConstraints(forItemKeys: ["osc","filter","amp","chorus"], attribute: .bottom)

    layout.activateConstraints()
    self.view = paddedView
    
    addPatchChangeBlock(paths: [[.osc, .wave, .pulse], [.osc, .wave, .saw]]) { values in
      guard let saw = values[[.osc, .wave, .saw]],
            let pulse = values [[.osc, .wave, .pulse]] else { return }
      let isHidden = saw != 3 && pulse != 3
      pwm.isHidden = isHidden
      pwmRate.isHidden = isHidden
    }
    
    addColorToAll(except: ["filter"])
    addColor(panels: ["filter"], level: 3)
  }

  
  
  class EnvController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.env] }
        
    override func loadView(_ view: PBView) {
      let env = AlphaJunoEnvelopeControl(label: "Envelope")
      grid(panel: "env", items: [[(env, [.env])]])
      
      grid(panel: "knobs", items: [[
        (PBKnob(label: "T1"), [.time, .i(0)]),
        (PBKnob(label: "T2"), [.time, .i(1)]),
        (PBKnob(label: "T3"), [.time, .i(2)]),
        (PBKnob(label: "T4"), [.time, .i(3)]),
        ],[
        (PBKnob(label: "L1"), [.level, .i(0)]),
        (PBKnob(label: "L2"), [.level, .i(1)]),
        (PBKnob(label: "L3"), [.level, .i(2)]),
        (PBKnob(label: "Key Trk"), [.keyTrk]),
        ]])
      
      addPanelsToLayout(andView: view)
      layout.addGridConstraints([[("env",4), ("knobs",4)]], pinMargin: "", spacing: "-s1-")

      (0..<4).forEach { step in
        addPatchChangeBlock(path: [.time, .i(step)]) { env.set(rate: CGFloat($0) / 127, forIndex: step) }
        addPatchChangeBlock(path: [.level, .i(step)]) { env.set(level: CGFloat($0) / 127, forIndex: step) }
      }
      
      addColorToAll(level: 2)
    }
    
  }
}
