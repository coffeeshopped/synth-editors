
extension VirusCVoiceController {
  
  class EQController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBKnob(label: "Lo Freq"), [.eq, .lo, .freq]),
        (PBKnob(label: "Mid Freq"), [.eq, .mid, .freq]),
        (PBKnob(label: "Mid Q"), [.eq, .mid, .q]),
        (PBKnob(label: "Hi Freq"), [.eq, .hi, .freq]),
        ],[
        (PBKnob(label: "Lo Gain"), [.eq, .lo, .gain]),
        (PBKnob(label: "Mid Gain"), [.eq, .mid, .gain]),
        (PBKnob(label: "Hi Gain"), [.eq, .hi, .gain]),
      ]])
    }
  }
  
  class ChorusController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.chorus] }
    
    override func loadView(_ view: PBView) {
      let rate = PBKnob(label: "Rate")
      let depth = PBKnob(label: "Depth")
      let feedbk = PBKnob(label: "Feedback")
      let delay = PBKnob(label: "Delay")
      let mix = PBKnob(label: "Chorus Mix")
      let lfo = PBSelect(label: "LFO Wave")
      
      grid(view: view, items: [[
        (mix, [.mix]),
        (rate, [.rate]),
        (depth, [.depth]),
        (feedbk, [.feedback]),
        (delay, [.delay]),
        (lfo, [.shape]),
      ]])
      
      addPatchChangeBlock(path: [.mix]) {
        let hidden = $0 == 0
        [feedbk, rate, depth, delay, lfo].forEach { $0.isHidden = hidden }
      }

    }
  }
  
  
  class PhasorController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.phase] }
    
    override func loadView(_ view: PBView) {
      
      let mix = PBKnob(label: "Phasor Mix")
      let freq = PBKnob(label: "Freq")
      let feedbk = PBKnob(label: "Feedback")
      let rate = PBKnob(label: "Mod Rate")
      let depth = PBKnob(label: "Mod Depth")
      let stages = PBKnob(label: "Stages")
      let spread = PBKnob(label: "Spread")
      
      grid(view: view, items: [[
        (mix, [.mix]),
        (freq, [.freq]),
        (feedbk, [.feedback]),
        (rate, [.rate]),
        (depth, [.depth]),
        (stages, [.mode]),
        (spread, [.pan]),
      ]])
      
      addPatchChangeBlock(path: [.mix]) {
        let hidden = $0 == 0
        [freq, feedbk, rate, depth, stages, spread].forEach { $0.isHidden = hidden }
      }
    }
  }
  
  class DistortionController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.dist] }
    
    override func loadView(_ view: PBView) {      
      grid(view: view, items: [[
        (PBSelect(label: "Distortion"), [.type]),
        (PBKnob(label: "Intens"), [.amt]),
      ]])
    }
  }
  
  class VocoderController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      
      let mode = PBSelect(label: "Vocoder")
      let center = PBKnob(label: "Center Freq")
      let bal = PBKnob(label: "Bal")
      let modOff = PBKnob(label: "Mod Offst")
      let specBal = PBKnob(label: "Spec Bal")
      let bands = PBKnob(label: "Bands")
      
      grid(view: view, items: [[
        (mode, [.vocoder, .mode]),
        (PBKnob(label: "Carr Sprd"), [.filter, .keyTrk]),
        (PBKnob(label: "Carr Q"), [.filter, .reson]),
        (center, nil),
        (bal,  [.filter, .balance]),
        (modOff, nil),
        (PBKnob(label: "Carr Atk"), [.filter, .env, .attack]),
        (PBKnob(label: "Carr Rel"), [.filter, .env, .decay]),
        (specBal, nil),
        (bands, nil),
      ]])
      
      // some of the display differs from how these params are used for the filters.
      addBlocks(control: center, path: [.filter, .i(0), .cutoff], paramAfterBlock: {
        center.displayOffset = -64
      })
      addBlocks(control: modOff, path: [.filter, .i(1), .cutoff], paramAfterBlock: {
        modOff.displayOffset = -64
      })
      addBlocks(control: specBal, path: [.filter, .env, .sustain, .slop], paramAfterBlock: {
        specBal.displayOffset = 0
      })
      addBlocks(control: bands, path: [.filter, .env, .release], paramAfterBlock: {
        bands.maximumValue = 31
        bands.displayOffset = 1
      })
      
      addPatchChangeBlock(path: [.vocoder, .mode]) {
        let hidden = $0 == 0
        view.subviews.filter { $0 != mode }.forEach { $0.isHidden = hidden }
      }
    }
  }
  
  class CharacterController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.character] }
    
    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBKnob(label: "Ana Boost Intens"), [.amt]),
        (PBKnob(label: "Tune"), [.tune]),
      ]])
    }
  }
  
  
  class DelayController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.delay] }
    
    let send = PBKnob(label: "Send")
    let feedbk = PBKnob(label: "Feedbk")
    let clock = PBKnob(label: "Clock")
    let color = PBKnob(label: "Color")
    let wave = PBKnob(label: "LFO Wave")
    let rate = PBKnob(label: "Rate")
    let depth = PBKnob(label: "Depth")
    let time = PBKnob(label: "Time")

    override func loadView(_ view: PBView) {
      grid(view: view, items: [[
        (PBSelect(label: "Delay"), [.mode]),
        (send, [.send]),
        (clock, [.clock]),
        (time, [.time]),
        (feedbk, [.feedback]),
        ],[
        (color, [.color]),
        (wave, [.shape]),
        (rate, [.rate]),
        (depth, [.depth]),
      ]])
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()

      let send = self.send
      let feedbk = self.feedbk
      let clock = self.clock
      let color = self.color
      let wave = self.wave
      let rate = self.rate
      let depth = self.depth
      let time = self.time

      addPatchChangeBlock(paths: [[.mode], [.clock]]) { [weak self] in
        guard let dMode = $0[[.mode]],
              let dClock = $0[[.clock]]
              else { return }
        
        let revTypeParm = MisoParam.make(options: ["Ambi", "Sml Rm", "Lrg Rm", "Hall"])
        
        var parms: [PBLabeledControl:Param?] = [:]
        switch dMode {
        case 0: // off
          [send, feedbk, clock, color, time, rate, wave, depth].forEach { $0.isHidden = true }
        default:
          [send, color, rate, wave, depth].forEach { $0.isHidden = false }
          time.isHidden = dClock > 0 || dMode > 8 || dMode == 0
          clock.isHidden = dMode > 8 || dMode == 0
          feedbk.isHidden = dMode == 2
        }
        
        let isVerb = [2,3,4].contains(dMode)
        depth.label = isVerb ? "Type" : "Depth"
        parms[depth] = isVerb ? revTypeParm : RangeParam()
        wave.label = isVerb ? "Damping" : "LFO Wave"
        parms[wave] = isVerb ? RangeParam() : VirusCVoicePatch.params[[.delay, .shape]]
        rate.label = isVerb ? "Time" : "Rate"
        time.label = isVerb ? "Predelay" : "Time"

        parms.forEach {
          guard let parm = $0.value else { return }
          self?.defaultConfigure(control: $0.key, forParam: parm)
        }
      }
    }
    
  }
  
  
}
