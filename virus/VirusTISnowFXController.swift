
extension VirusTISnowVoiceController {
  
  class FXController : NewPatchEditorController {
    
    override func loadView() {
      let paddedView = PaddedContainer()
      paddedView.horizontalPadding = 0.1
      paddedView.verticalPadding = 0
      let view = paddedView.mainView
      
      addChild(ChorusController(), withPanel: "chorus")
      addChild(PhasorController(), withPanel: "phasor")
      addChild(DistortionController(), withPanel: "distort")
      addChild(VocoderController(), withPanel: "vocoder")
      addChild(CharacterController(), withPanel: "char")
      addChild(DelayController(), withPanel: "delay")
      addChild(ReverbController(), withPanel: "reverb")
      addChild(FilterBankController(), withPanel: "fBank")
      createPanels(forKeys: ["input", "eq"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("chorus", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("phasor", 7), ("distort", 7.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("vocoder", 10.5), ("char", 3.5)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("eq", 4), ("delay", 8)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("reverb", 9), ("input", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("fBank", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("chorus", 1), ("phasor", 1), ("vocoder", 1), ("eq", 2), ("reverb", 1), ("fBank", 1)], pinned: true, pinMargin: "", spacing: "-s1-")

      grid(panel: "eq", items: [[
        (PBKnob(label: "Lo Freq"), [.eq, .lo, .freq]),
        (PBKnob(label: "Mid Freq"), [.eq, .mid, .freq]),
        (PBKnob(label: "Mid Q"), [.eq, .mid, .q]),
        (PBKnob(label: "Hi Freq"), [.eq, .hi, .freq]),
        ],[
        (PBKnob(label: "Lo Gain"), [.eq, .lo, .gain]),
        (PBKnob(label: "Mid Gain"), [.eq, .mid, .gain]),
        (PBKnob(label: "Hi Gain"), [.eq, .hi, .gain]),
      ]])

      grid(panel: "input", items: [[
        (PBSwitch(label: "In Fol"), [.input, .follow]),
        (PBKnob(label: "Attack"), [.filter, .env, .attack]),
        (PBKnob(label: "Release"), [.filter, .env, .release]),
        (PBKnob(label: "Sens"), [.filter, .env, .sustain]),
      ]])

      layout.activateConstraints()
      self.view = paddedView
      addColorToAll()
    }
    
  }

  
  class ChorusController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.chorus] }
    
    override func loadView(_ view: PBView) {
      
      let type = PBSelect(label: "Chorus")
      let rate = PBKnob(label: "Rate")
      let depth = PBKnob(label: "Depth")
      let feedbk = PBKnob(label: "Feedback")
      let delay = PBKnob(label: "Delay")
      let mix = PBKnob(label: "Mix")
      let lfo = PBSelect(label: "LFO Wave")
      let xover = PBKnob(label: "X-Over")
      let amt = PBKnob(label: "Mix")
      
      grid(view: view, items: [[
        (type, [.type]),
        (rate, [.rate]),
        (depth, [.depth]),
        (feedbk, [.feedback]),
        (delay, [.delay]),
        (mix, [.mix]),
        (lfo, [.shape]),
        (amt, [.amt]),
        (xover, [.cross]),
      ]])
      
      addPatchChangeBlock(path: [.type]) { [weak self] in
        var parms: [PBLabeledControl:Param?] = [:]
        switch $0 {
        case 0:
          [rate, depth, feedbk, delay, mix, lfo, xover, amt].forEach { $0.isHidden = true }
        case 1:
          [rate, depth, feedbk, delay, mix, lfo].forEach { $0.isHidden = false }
          [xover, amt].forEach { $0.isHidden = true }
          delay.label = "Delay"
          parms[delay] = RangeParam()
        case 2:
          [rate, depth, xover, amt].forEach { $0.isHidden = false }
          [feedbk, delay, mix, lfo].forEach { $0.isHidden = true }
        case 3:
          [depth, delay, xover, amt].forEach { $0.isHidden = false }
          [rate, feedbk, mix, lfo].forEach { $0.isHidden = true }
          delay.label = "Amount"
          parms[delay] = VirusTIVoicePatch.hyperChorusAmtParam
        case 4:
          [depth, xover].forEach { $0.isHidden = false }
          [rate, delay, feedbk, mix, lfo, amt].forEach { $0.isHidden = true }
        case 5:
          [rate, depth, xover].forEach { $0.isHidden = false }
          [delay, feedbk, mix, lfo, amt].forEach { $0.isHidden = true }
        case 6:
          [rate, depth, delay, feedbk, amt].forEach { $0.isHidden = false }
          [mix, lfo, xover].forEach { $0.isHidden = true }
          delay.label = "Mic Angle"
          parms[delay] = VirusTIVoicePatch.chorusMicAngleParam
        default:
          [rate, depth, feedbk, delay, mix, lfo, xover, amt].forEach { $0.isHidden = false }
        }
        
        parms.forEach {
          guard let parm = $0.value else { return }
          self?.defaultConfigure(control: $0.key, forParam: parm)
        }

        
        feedbk.label = $0 == 6 ? "LowHigh Bal" : "Feedback"
        
        rate.label = $0 == 6 ? "Speed" : "Rate"
        let rateParam = $0 == 6 ? VirusTIVoicePatch.chorusSpeedParam : VirusTIVoicePatch.params[[.chorus, .rate]]!
        self?.defaultConfigure(control: rate, forParam: rateParam)
        
        depth.label = $0 == 6 ? "Distance" : "Depth"
        let depthParam = $0 == 6 ? VirusTIVoicePatch.chorusDistanceParam : VirusTIVoicePatch.params[[.chorus, .depth]]!
        self?.defaultConfigure(control: depth, forParam: depthParam)
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
      
      let distort = PBSelect(label: "Distortion")
      let mix = PBKnob(label: "Mix")
      let intens = PBKnob(label: "Intens")
      let treb = PBKnob(label: "Treb Bst")
      let hi = PBKnob(label: "Hi Cut")
      let qual = PBKnob(label: "Quality")
      let tone = PBKnob(label: "Tone")
      
      grid(view: view, items: [[
        (distort, [.type]),
        (mix, [.mix]),
        (intens, [.amt]),
        (treb, [.booster]),
        (hi, [.hi, .cutoff]),
        (qual, [.q]),
        (tone, [.tone]),
      ]])
      
      addPatchChangeBlock(path: [.type]) {
        switch $0 {
        case 0:
          [mix, intens, treb, hi, qual, tone].forEach { $0.isHidden = true }
        case 1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15, 16, 17:
          [mix, intens, treb, hi].forEach { $0.isHidden = false }
          [qual, tone].forEach { $0.isHidden = true }
        case 8, 9, 10, 11:
          [mix, intens].forEach { $0.isHidden = false }
          [treb, hi, qual, tone].forEach { $0.isHidden = true }
        case 18, 19:
          [mix, intens, qual].forEach { $0.isHidden = false }
          [treb, hi, tone].forEach { $0.isHidden = true }
        case 20, 24: // mint, pepper
          [mix, tone, intens, hi].forEach { $0.isHidden = false }
          [treb, qual].forEach { $0.isHidden = true }
          tone.maximumValue = 64 // TODO: maybe going above 64 does something cooL?
        case 21, 25: // curry, chili
          [mix, intens, hi].forEach { $0.isHidden = false }
          [treb, qual, tone].forEach { $0.isHidden = true }
        case 22, 23: // saffron, onion
          [mix, tone, intens, hi].forEach { $0.isHidden = false }
          [treb, qual].forEach { $0.isHidden = true }
          tone.maximumValue = 127
        default:
          [mix, intens, treb, hi, qual, tone].forEach { $0.isHidden = false }
        }
        
        intens.label = [20,21,22,23,24,25].contains($0) ? "Drive" : "Intens"
      }
    }
  }
  
  class VocoderController : NewPatchEditorController {
    // WHEN VOCODER IS ACTIVE, FILTERS AND SATURATION ARE DISABLED
    // FILTER ENVELOPE IS ALSO HIDDEN!
    // FILTER BANK ALSO TURNS OFF / goes away
    
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
        (bal, nil),
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
      addBlocks(control: bal, path: [.filter, .balance], paramAfterBlock: {
        bal.displayOffset = 0
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
      let mode = PBSelect(label: "Character")
      
      grid(view: view, items: [[
        (mode, [.type]),
        (PBKnob(label: "Intens"), [.amt]),
        (PBKnob(label: "Freq"), [.tune]),
      ]])

      addPatchChangeBlock(path: [.type]) {
        let hidden = (1...6).contains($0)
        view.subviews.filter { $0 != mode }.forEach { $0.isHidden = hidden }
      }
    }
  }
  
  
  class DelayController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.delay] }
    
    override func loadView(_ view: PBView) {
      
      let send = PBKnob(label: "Send")
      let feedbk = PBKnob(label: "Feedbk")
      let mode = PBSelect(label: "Mode")
      let clock = PBKnob(label: "Clock")
      let color = PBKnob(label: "Color")
      let wave = PBSelect(label: "LFO Wave")
      let rate = PBKnob(label: "Rate")
      let depth = PBKnob(label: "Depth")
      let lClock = PBSwitch(label: "L Clock")
      let rClock = PBSwitch(label: "R Clock")
      let bw = PBKnob(label: "BW")
      let time = PBKnob(label: "Time")
      let ratio = PBKnob(label: "Ratio")
      
      grid(view: view, items: [[
        (PBSwitch(label: "Delay Type"), [.type]),
        (send, [.send]),
        (mode, [.mode]),
        (clock, [.clock]),
        (time, [.time]),
        (wave, [.shape]),
        (rate, [.rate]),
        ],[
        (feedbk, [.feedback]),
        (lClock, [.clock, .left]),
        (rClock, [.clock, .right]),
        (ratio, [.ratio]),
        (color, [.color]),
        (bw, [.bw]),
        (depth, [.depth]),
      ]])
      
      addPatchChangeBlock(paths: [[.type], [.mode], [.clock]]) {
        guard let dType = $0[[.type]],
              let dMode = $0[[.mode]],
              let dClock = $0[[.clock]]
              else { return }
        switch dType {
        case 0:
          [mode, rate, wave].forEach { $0.isHidden = false }
          clock.isHidden = dMode > 5
          time.isHidden = dMode > 5 || dClock > 0
          [lClock, rClock, bw, ratio].forEach { $0.isHidden = true }
        case 1: // clocked
          [lClock, rClock, bw].forEach { $0.isHidden = false }
          [mode, clock, time, ratio, rate, wave].forEach { $0.isHidden = true }
        case 2, 3: // free, doppler
          [time, ratio, bw].forEach { $0.isHidden = false }
          [lClock, rClock, mode, clock, rate, wave].forEach { $0.isHidden = true }
        default:
          [mode, clock, time, rate, wave, lClock, rClock, bw, ratio].forEach { $0.isHidden = false }
        }

        let isTape = dType != 0
        color.label = isTape ? "Freq" : "Color"
        color.displayOffset = isTape ? 0 : -64
        depth.label = isTape ? "Modulation" : "Depth"
      }

    }
  }
  
  
  class ReverbController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.reverb] }
    
    override func loadView(_ view: PBView) {
      
      let predelay = PBKnob(label: "Predelay")
      let feedback = PBKnob(label: "Feedbk")
      
      grid(view: view, items: [[
        (PBSwitch(label: "Reverb"), [.mode]),
        (PBSwitch(label: "Type"), [.type]),
        (PBKnob(label: "Send"), [.send]),
        (PBKnob(label: "Clock"), [.clock]),
        (PBKnob(label: "Time"), [.time]),
        (PBKnob(label: "Damping"), [.redamper]),
        (PBKnob(label: "Color"), [.color]),
        (predelay, [.delay]),
        (feedback, [.feedback]),
      ]])

      addPatchChangeBlock(path: [.mode]) {
        feedback.isHidden = $0 == 1
      }
      addPatchChangeBlock(path: [.clock]) {
        predelay.isHidden = $0 > 0
      }
    }
  }
  
  class FilterBankController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.freq, .shift] }
    
    override func loadView(_ view: PBView) {
      let mix = PBKnob(label: "Mix")
      let freq = PBKnob(label: "Frequency")
      let phase = PBKnob(label: "St Phase")
      let left = PBKnob(label: "Shape L")
      let right = PBKnob(label: "Shape R")
      let reson = PBKnob(label: "Reson")
      
      grid(view: view, items: [[
        (PBSelect(label: "Filter Bank"), [.type]),
        (mix, [.mix]),
        (freq, [.freq]),
        (phase, [.phase]),
        (left, [.left]),
        (right, [.right]),
        (reson, [.reson]),
      ]])

      addPatchChangeBlock { (changes) in
        guard let vocoderMode = Self.updatedValueForFullPath([.vocoder, .mode], state: changes) else { return }
        view.alpha = vocoderMode == 0 ? 1 : 0.4
      }
      
      addPatchChangeBlock(path: [.type]) { [weak self] in
        var parms: [PBLabeledControl:Param?] = [:]
        switch $0 {
        case 0:
          [mix, freq, phase, left, right, reson].forEach { $0.isHidden = true }
        case 1: // ring mod
          [mix, freq, phase].forEach { $0.isHidden = false }
          [left, right, reson].forEach { $0.isHidden = true }
          parms[freq] = VirusTIVoicePatch.params[[.freq, .shift, .freq]]
        case 2: // freq shift
          [mix, freq, phase, left, right].forEach { $0.isHidden = false }
          [reson].forEach { $0.isHidden = true }
          parms[freq] = VirusTIVoicePatch.params[[.freq, .shift, .freq]]
          left.label = "Shape L"
          parms[left] = VirusTIVoicePatch.params[[.freq, .shift, .left]]
          right.label = "Shape R"
          parms[right] = VirusTIVoicePatch.params[[.freq, .shift, .right]]
        case 3: // vowel filter
          [mix, freq, phase, reson].forEach { $0.isHidden = false }
          [left, right].forEach { $0.isHidden = true }
          parms[freq] = MisoParam.make(iso: VirusTIVoicePatch.fullPercIso)
          parms[reson] = VirusTIVoicePatch.params[[.freq, .shift, .reson]]
        case 4: // comb filter
          [mix, freq, phase, reson].forEach { $0.isHidden = false }
          [left, right].forEach { $0.isHidden = true }
          parms[freq] = MisoParam.make(maxVal: 96, iso: Miso.noteName(zeroNote: "C0"))
          parms[reson] = VirusTIVoicePatch.params[[.freq, .shift, .reson]]
        case 5, 6, 7, 8: // 1, 2, 4, 6 pole xfade
          [freq, reson, left].forEach { $0.isHidden = false }
          [mix, phase, right].forEach { $0.isHidden = true }
          parms[freq] = RangeParam()
          left.label = "Filter Type"
          parms[left] = MisoParam.make(iso: VirusTIVoicePatch.freqShiftFTypeIso)
          parms[reson] = MisoParam.make(iso: VirusTIVoicePatch.fullPercIso)
        case 9, 10, 11: // VariSlopes
          [freq, reson, left, right].forEach { $0.isHidden = false }
          [mix, phase].forEach { $0.isHidden = true }
          
          parms[freq] = RangeParam()
          left.label = "Poles"
          parms[left] = MisoParam.make(iso: VirusTIVoicePatch.freqShiftPolesIso)
          right.label = "Slope"
          parms[right] = RangeParam()
          parms[reson] = MisoParam.make(iso: VirusTIVoicePatch.fullPercIso)
        default:
          [mix, freq, phase, left, right, reson].forEach { $0.isHidden = false }
        }
        
        parms.forEach {
          guard let parm = $0.value else { return }
          self?.defaultConfigure(control: $0.key, forParam: parm)
        }
      }
    }
  }
  
}
