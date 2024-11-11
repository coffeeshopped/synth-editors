//
//  MicroQVoiceController.swift
//  Blofeld
//
//  Created by Chadwick Wood on 10/14/21.
//  Copyright © 2021 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBCore


extension FnPatchEditorController {
  func modCombo(_ label: String, _ pre: SynthPath) -> (src: PBSelect, amt: PBKnob) {
    let srcCtrl = PBSelect(label: "←\(label) Src")
    let amtCtrl = PBKnob(label: label)
    addPatchChangeBlock(paths: [pre + [.src], pre + [.amt]]) { values in
      guard let src = values[pre + [.src]],
            let amt = values[pre + [.amt]] else { return }
      let off = src == 0 || amt == 64
      [srcCtrl, amtCtrl].forEach { $0.alpha = off ? 0.4 : 1 }
    }
    return (src: srcCtrl, amt: amtCtrl)
  }
  
  func fmCombo() -> (src: PBSelect, amt: PBKnob) {
    let srcCtrl = PBSelect(label: "←FM Src")
    let amtCtrl = PBKnob(label: "FM")
    addPatchChangeBlock(path: [.fm, .src]) {
      let off = $0 == 0
      [srcCtrl, amtCtrl].forEach { $0.alpha = off ? 0.4 : 1 }
    }
    return (src: srcCtrl, amt: amtCtrl)
  }

}

struct MicroQVoiceController {
  
  static func controller() -> FnPagedEditorController {
    ActivatedFnEditorController { vc in
      vc.switchCtrl = PBSegmentedControl(items: ["Main", "Mods", "FX/Arp"])
      vc.grid(panel: "switch", items: [[(vc.switchCtrl, nil)]])

      vc.grid(panel: "glide", items: [[
        (PBCheckbox(label: "Glide"), [.glide, .on]),
        (PBSwitch(label: "Mode"), [.glide, .mode]),
        (PBKnob(label: "Rate"), [.glide, .rate]),
      ]])

      vc.grid(panel: "mono", items: [[
        (PBCheckbox(label: "Mono"), [.mono]),
        (PBKnob(label: "Unison"), [.unison]),
        (PBKnob(label: "Detune"), [.unison, .detune]),
        ]])

      let amps = vc.modCombo("Amp Mod", [.amp, .mod])
      vc.grid(panel: "amp", items: [[
          (PBKnob(label: "Volume"), [.volume]),
          (PBKnob(label: "Velo"), [.amp, .velo]),
          (amps.amt, [.amp, .mod, .amt]),
          (amps.src, [.amp, .mod, .src]),
      ]])

      vc.grid(panel: "tempo", items: [[
        (PBKnob(label: "Tempo"), [.arp, .tempo]),
        ]])

      vc.addLayoutConstraints { layout in
        layout.addGridConstraints([
          (row: [("switch", 4.5), ("glide", 3), ("mono", 3), ("amp", 4.5), ("tempo", 1)], height: 1),
          (row: [("page", 1)], height: 8),
        ], spacing: "-s1-")
      }
      
      vc.setControllerBlocks([
        voiceController, modsController, arpController,
      ])

      vc.addColor(panels: ["glide", "mono", "amp"])
      vc.addColor(panels: ["tempo"], level: 2)
      vc.addColor(panels: ["switch"], clearBackground: true)
    }
  }

  static func voiceController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.addChildren(count: 3, panelPrefix: "osc") { oscController($0) }
      vc.addChildren(count: 2, panelPrefix: "filter") { filterController($0) }
      vc.addChild(envController(), withPanel: "env")
      vc.addChild(lfoController(), withPanel: "lfo")
            
      vc.grid(panel: "mix", items: [[
        (PBKnob(label: "O1 Level"), [.osc, .i(0), .level]),
        (PBKnob(label: "O1 Bal"), [.osc, .i(0), .balance]),
      ],[
        (PBKnob(label: "O2 Level"), [.osc, .i(1), .level]),
        (PBKnob(label: "O2 Bal"), [.osc, .i(1), .balance]),
      ],[
        (PBKnob(label: "O3 Level"), [.osc, .i(2), .level]),
        (PBKnob(label: "O3 Bal"), [.osc, .i(2), .balance]),
      ],[
        (PBKnob(label: "Noise"), [.noise, .level]),
        (PBKnob(label: "Balance"), [.noise, .balance]),
      ],[
        (PBKnob(label: "Ring Mod"), [.ringMod, .level]),
        (PBKnob(label: "Balance"), [.ringMod, .balance]),
      ]])
      
      vc.grid(panel: "noise", items: [[
        (PBSwitch(label: "Sel 1"), [.noise, .select, .i(0)]),
        (PBSwitch(label: "Sel 2"), [.noise, .select, .i(1)]),
        ]])

      let pitch = vc.modCombo("Pitch Mod", [.pitch])
      vc.grid(panel: "pitch", items: [[
        (pitch.amt, [.pitch, .amt]),
        (pitch.src, [.pitch, .src]),
      ]])
            
      vc.grid(panel: "route", items: [[
        (PBSwitch(label: "Routing"), [.filter, .routing]),
      ]])
      
      
      let env = Blofeld.EnvelopeControl(label: "Filter")
      let knobs = envControllerSetup(vc, prefix: [.env, .i(0)])
      let envSub = envSubController(env)
      envSub.prefixBlock = { _ in [.env, .i(0)] }
      vc.addChild(envSub)

      // add before fEnv panels so it's in the back.
      vc.createPanels(forKeys: ["fEnvCon"])

      vc.grid(panel: "fEnv", prefix: [.env, .i(0)], items: [[
        (knobs[1], [.attack]),
        (knobs[2], [.decay]),
        (knobs[3], [.sustain]),
      ],[
        (knobs[0], [.attack, .level]),
        (PBSwitch(label: "Trigger"), [.trigger]),
        (knobs[6], [.release]),
      ],[
        (PBSelect(label: "Mode"), [.mode]),
        (env, nil),
      ]])

      vc.grid(panel: "fEnvX", prefix: [.env, .i(0)], items: [[
        (knobs[4], [.decay2]),
        (knobs[5], [.sustain2]),
      ]])
      
//      vc.grid(panel: "cat", items: [[(PBSelect(label: "Category"), [.category])]])

      vc.addLayoutConstraints { layout in
        layout.addRowConstraints([("mix", 2), ("osc0", 14)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addRowConstraints([("noise", 2), ("route", 1), ("filter0", 5.5), ("filter1", 5.5)], options: [.alignAllTop], pinned: false, spacing: "-s1-")
        layout.addRowConstraints([("fEnv", 3), ("fEnvX", 2)], options: [.alignAllTop], pinned: false, spacing: "-s1-")
        layout.addRowConstraints([("env", 7), ("lfo", 6)], pinned: false, spacing: "-s1-")
        layout.addColumnConstraints([("mix", 5), ("fEnv", 3)], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([("osc0", 1), ("osc1", 1), ("osc2", 1), ("filter1", 3), ("lfo", 2)], options: [.alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([("noise", 1), ("pitch", 1)], pinned: false, spacing: "-s1-")
        layout.addEqualConstraints(forItemKeys: ["osc0", "osc1", "osc2", "noise", "pitch"], attribute: .leading)
        layout.addEqualConstraints(forItemKeys: ["route", "pitch", "fEnvX"], attribute: .trailing)
        layout.addEqualConstraints(forItemKeys: ["mix", "pitch"], attribute: .bottom)
        layout.addEqualConstraints(forItemKeys: ["noise", "route"], attribute: .bottom)
        layout.addEqualConstraints(forItemKeys: ["fEnvX", "filter0", "filter1"], attribute: .bottom)
        layout.addEqualConstraints(forItemKeys: ["fEnvX", "env"], attribute: .leading)
        
        layout.addEqualConstraints(forItemKeys: ["fEnvCon", "fEnv"], attribute: .top)
        layout.addEqualConstraints(forItemKeys: ["fEnvCon", "fEnv"], attribute: .leading)
        layout.addEqualConstraints(forItemKeys: ["fEnvCon", "fEnvX"], attribute: .bottom)
        layout.addEqualConstraints(forItemKeys: ["fEnvCon", "fEnvX"], attribute: .trailing)
      }
      
      vc.addColor(panels: ["mix", "osc0", "osc1", "osc2", "noise", "pitch"], level: 1)
      vc.addColor(panels: ["filter0", "filter1", "fEnv", "fEnvX", "route", "fEnvCon"], level: 2)
      vc.addColor(panels: ["env", "lfo"], level: 3)
    }
  }
  
  static func oscController(_ index: Int) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.prefixBlock = { _ in [.osc, .i(index)] }

      let pwm = vc.modCombo("PWM", [.pw])
      let fm = vc.fmCombo()
      vc.grid(items: [[
        (PBSelect(label: "Osc \(index + 1) Wave"), [.shape]),
        (PBSelect(label: "Octave"), [.octave]),
        (PBKnob(label: "Semi"), [.coarse]),
        (PBKnob(label: "Detune"), [.fine]),
        (PBKnob(label: "PW"), [.pw]),
        (pwm.amt, [.pw, .amt]),
        (pwm.src, [.pw, .src]),
        (fm.amt, [.fm, .amt]),
        (fm.src, [.fm, .src]),
        (PBKnob(label: "Key Track"), [.keyTrk]),
        (PBKnob(label: "Bend"), [.bend]),
      ] + (index < 2 ? [
        (PBKnob(label: "Sub Freq Div"), [.sub, .freq, .divide]),
        (PBKnob(label: "Sub Vol"), [.sub, .volume]),
      ]: [
        (PBCheckbox(label: "Sync→O3"), [.sync]),
        (SpacerItem(text: nil, gridWidth: 2), nil),
      ])])
      
      vc.dims(forPath: [.shape])
    }
  }
  
  static func filterController(_ index: Int) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.prefixBlock = { _ in [.filter, .i(index)] }

      let cutoff = vc.modCombo("Cutoff Mod", [.cutoff])
      let fm = vc.fmCombo()
      let pan = vc.modCombo("Pan Mod", [.pan])
      vc.grid(items: [[
        (PBSelect(label: "Filter \(index + 1)"), [.type]),
        (PBKnob(label: "Cutoff"), [.cutoff]),
        (PBKnob(label: "Reson"), [.reson]),
        (PBKnob(label: "Env Amt"), [.env, .amt]),
        (PBKnob(label: "Velocity"), [.velo]),
      ],[
        (cutoff.amt, [.cutoff, .amt]),
        (cutoff.src, [.cutoff, .src]),
        (fm.amt, [.fm, .amt]),
        (fm.src, [.fm, .src]),
      ],[
        (PBKnob(label: "Pan"), [.pan]),
        (pan.amt, [.pan, .amt]),
        (pan.src, [.pan, .src]),
        (PBKnob(label: "Drive"), [.drive]),
        (PBKnob(label: "Key Track"), [.keyTrk]),
      ]])
      
      vc.dims(forPath: [.type])
    }
  }
  
  static func envSubController(_ env: Blofeld.EnvelopeControl) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.view = env
      
      vc.addPatchChangeBlock(path: [.mode]) { env.mode = .init(rawValue: $0) ?? .ADS1DS2R }
      vc.addPatchChangeBlock(path: [.attack, .level]) { env.attackLevel = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.attack]) { env.attack = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.decay]) { env.decay = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.sustain]) { env.sustain = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.decay2]) { env.decay2 = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.sustain2]) { env.sustain2 = CGFloat($0) / 127 }
      vc.addPatchChangeBlock(path: [.release]) { env.rrelease = CGFloat($0) / 127 }
      
      vc.registerForEditMenu(env, bundle: (
        paths: { [[.mode], [.attack], [.attack, .level], [.decay],
                  [.sustain], [.decay2], [.sustain2], [.release]] },
        pasteboardType: "com.cfshpd.MicroQEnvelope",
        initialize: { [0, 0, 64, 0, 127, 64, 64, 0] },
        randomize: { [5.rand()] + 7.map { 128.rand() } }
      ))
    }
  }
  
  static func envController(withFilter: Bool = false) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.prefixBlock = { [.env, .i($0.index + (withFilter ? 0 : 1))] }
      let items = (withFilter ? ["Filter"] : []) + ["Amp","3","4"]
      let lsc = LabeledSegmentedControl(label: "Envelope", items: items)
      vc.switchCtrl = lsc.segmentedControl
      lsc.wantsGridWidth = withFilter ? 7 : 5

      let env = Blofeld.EnvelopeControl()
      if withFilter {
        vc.addIndexChangeBlock { env.label = ["Filter", "Amp", "Env 3", "Env 4"][$0 % 4] }
      }
      else {
        vc.addIndexChangeBlock { env.label = ["Amp", "Env 3", "Env 4"][$0 % 3] }
      }

      let knobs = envControllerSetup(vc)
      vc.addChild(envSubController(env))
      vc.grid(items: [[
        (knobs[0], [.attack, .level]),
        (knobs[1], [.attack]),
        (knobs[2], [.decay]),
        (knobs[3], [.sustain]),
        (knobs[4], [.decay2]),
        (knobs[5], [.sustain2]),
        (knobs[6], [.release]),
      ],[
        (lsc, nil),
        (PBSelect(label: "Mode"), [.mode]),
        (env, nil),
        (PBSwitch(label: "Trigger"), [.trigger]),
      ]])
    }
  }
  
  static func envControllerSetup(_ vc: FnPatchEditorController, prefix: SynthPath? = nil) -> [PBKnob] {
    let knobs = [
      PBKnob(label: "AL"), // 0
      PBKnob(label: "A"), // 1
      PBKnob(label: "D1"), // 2
      PBKnob(label: "S1"), // 3
      PBKnob(label: "D2"), // 4
      PBKnob(label: "S2"), // 5
      PBKnob(label: "R"), // 6
    ]
        
    vc.addPatchChangeBlock(path: (prefix ?? []) + [.mode]) {
      let active: [Int]
      switch $0 {
      case 0, 2: // adsr
        active = [1, 2, 3, 6]
        knobs[2].label = "D"
        knobs[3].label = "S"
      default: // loop all
        active = [0, 1, 2, 3, 4, 5, 6]
        knobs[2].label = "D1"
        knobs[3].label = "S1"
      }
      knobs.enumerated().forEach { $0.element.isHidden = !active.contains($0.offset) }
    }

    return knobs
  }
  
  static func lfoController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.prefixBlock = { [.lfo, .i($0.index)] }
      let lsc = LabeledSegmentedControl(label: "LFO", items: ["1","2","3"])
      vc.switchCtrl = lsc.segmentedControl
      let wave = PBSelect(label: "Wave")
      vc.addIndexChangeBlock { wave.label = "LFO \($0 + 1)" }
      
      let phase = PBKnob(label: "Phase")
      let speed = PBKnob(label: "Speed")
      vc.grid(items: [[
        (speed, [.speed]),
        (PBCheckbox(label: "Clocked"), [.clock]),
        (PBKnob(label: "Key Track"), [.keyTrk]),
        (phase, [.phase]),
        (PBKnob(label: "Delay"), [.delay]),
        (PBKnob(label: "Fade"), [.fade]),
      ],[
        (lsc, nil),
        (wave, [.shape]),
        (PBCheckbox(label: "Sync"), [.sync]),
      ]])
      
      vc.addPatchChangeBlock(path: [.clock]) { [weak vc] in
        let param = $0 == 0 ? RangeParam() : MisoParam.make(iso: MicroQVoicePatch.lfoRateIso)
        vc?.defaultConfigure(control: speed, forParam: param)
      }
      
      vc.dims(view: phase, forPath: [.sync])
    }
  }
  
  static func modsController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.addChildren(count: 16, panelPrefix: "mod") { index in
        ActivatedFnEditorController { modVC in
          modVC.prefixBlock = { _ in [index < 8 ? .hi : .lo, .mod, .i(index % 8)] }
          let src = PBSelect(label: "M\((index % 8) + 1)\(index < 8 ? "F" : "S") Src")
          modVC.grid(items: [[
            (src, [.src]),
            (PBKnob(label: "Amt"), [.amt]),
            (PBSelect(label: "Dest"), [.dest]),
          ]])
          if index % 8 < 2 {
            // M1/2F/S Amount can be modulated, so an Amt of 0 shouldn't dim
            modVC.dims(forPath: [.src])
          }
          else {
            modVC.dims(forPaths: [[.src], [.amt]]) {
              $0[[.src]] == 0 || $0[[.amt]] == 64
            }
          }
        }
      }
      
      vc.addChildren(count: 4, panelPrefix: "modif") { index in
        ActivatedFnEditorController { modVC in
          modVC.prefixBlock = { _ in [.modif, .i(index)] }
          let const = PBKnob(label: "Const")
          modVC.grid(items: [[
            (PBSelect(label: "Modif \(index + 1) Src A"), [.src, .i(0)]),
            (PBSelect(label: "Op"), [.op]),
            (PBSelect(label: "Src B"), [.src, .i(1)]),
            (const, [.const]),
            ]])
          modVC.addPatchChangeBlock(path: [.src, .i(1)]) { const.isHidden = $0 > 0 }
        }
      }
      vc.addChild(lfoController(), withPanel: "lfo")
      vc.addChild(envController(withFilter: true), withPanel: "env")

      vc.addLayoutConstraints { layout in
        layout.addGridConstraints([
          (row: [("mod0", 4), ("mod1", 4), ("mod2", 4), ("mod3", 4)], height: 1),
          (row: [("mod4", 4), ("mod5", 4), ("mod6", 4), ("mod7", 4)], height: 1),
          (row: [("mod8", 4), ("mod9", 4), ("mod10", 4), ("mod11", 4)], height: 1),
          (row: [("mod12", 4), ("mod13", 4), ("mod14", 4), ("mod15", 4)], height: 1),
          (row: [("modif0", 5.5), ("modif1", 5.5)], height: 1),
          (row: [("modif2", 5.5), ("modif3", 5.5)], height: 1),
          (row: [("env", 7), ("lfo", 6)], height: 2),
        ], pinMargin: "", spacing: "-s1-")
      }
      
      vc.addColor(panels: (0..<16).map { "mod\($0)" })
      vc.addColor(panels: (0..<4).map { "modif\($0)" }, level: 2)
      vc.addColor(panels: ["lfo", "env"], level: 3)
    }
  }


  static func fxController(index: Int) -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      let knobCount = 14
      let knobs = (0..<knobCount).map { PBKnob(label: "\($0)") }
      vc.prefixBlock = { _ in [.fx, .i(index)] }
      vc.grid(items: [[
        (PBSelect(label: "FX \(index + 1)"), [.type]),
        (PBKnob(label: "Mix"), [.mix])
      ] + knobs.map { ($0, nil)}])
      
      vc.addPatchChangeBlock(paths: [[.type]] + (0..<14).map { [.param, .i($0)] }) { values in
        guard let fxType = values[[.type]] else { return }
        (0..<knobCount).forEach {
          guard let pindex = paramIndex(forType: fxType, knob: $0) else { return }
          knobs[$0].value = values[[.param, .i(pindex)]] ?? 0
        }
      }
      // configure knobs when fxType changes
      vc.addPatchChangeBlock(path: [.type]) { [weak vc] value in
        guard let fxMap = fxParams(forType: value) else { return }
        (0..<knobCount).forEach {
          let knob = knobs[$0]
          knob.isHidden = $0 >= fxMap.count
          
          guard $0 < fxMap.count else { return }
          knob.label = fxMap[$0].label
          vc?.defaultConfigure(control: knob, forParamOptions: fxMap[$0])
        }
      }
      (0..<knobCount).forEach { knobIndex in
        let knob = knobs[knobIndex]
        vc.addControlChangeBlock(control: knob) { [weak vc] in
          guard let fxType = vc?.latestValue(path: [.type]),
                let pindex = paramIndex(forType: fxType, knob: knobIndex) else { return nil }
          return .paramsChange([[.param, .i(pindex)] : knob.value])
        }
      }
    }
  }
  
  static func fxParams(forType type: Int) -> [ParamOptions]? {
    guard type < MicroQVoicePatch.fxMap.count else { return nil }
    return MicroQVoicePatch.fxMap[type]
  }
  
  static func paramIndex(forType type: Int, knob: Int) -> Int? {
    guard let fxMap = fxParams(forType: type),
          knob < fxMap.count else { return nil }
    return (fxMap[knob].path.i(0) ?? 146) - 146
  }
  
  static func arpController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.addChildren(count: 2, panelPrefix: "fx") { fxController(index: $0) }

      vc.grid(panel: "cat", items: [[(PBSelect(label: "Category"), [.category])]])
      
      arpControllerSetup(vc)

      vc.addLayoutConstraints { layout in
        layout.addGridConstraints([
          [("fx0", 1)],
          [("fx1", 1)],
          [("mode", 14.5), ("cat", 1.5)],
          [("step", 1)],
          [("length", 1)],
          [("time", 1)],
          [("accent", 1)],
          [("glide", 1)],
        ], pinMargin: "", spacing: "-s1-")
      }
      
      vc.addColor(panels: ["fx0", "fx1", "cat"])
      vc.addColor(panels: ["mode", "step", "length", "time", "accent", "glide"], level: 2)
    }
  }
  
  static func arpControllerSetup(_ vc: FnPatchEditorController) {
    vc.grid(panel: "mode", prefix: [.arp], items: [[
      (PBSwitch(label: "Arp Mode"), [.mode]),
      (PBKnob(label: "Pattern"), [.pattern]),
      (PBKnob(label: "Max Notes"), [.note]),
      (PBKnob(label: "Clock"), [.clock]),
      (PBKnob(label: "Length"), [.length]),
      (PBKnob(label: "Octave"), [.octave]),
      (PBSwitch(label: "Direction"), [.direction]),
      (PBSelect(label: "Sort Order"), [.sortOrder]),
      (PBSwitch(label: "Velocity"), [.velo]),
      (PBKnob(label: "Timing Factor"), [.timingFactor]),
      (PBCheckbox(label: "Same Note Over"), [.legato]),
      (PBCheckbox(label: "Pattern Reset"), [.pattern, .reset]),
      (PBKnob(label: "Pattern Length"), [.pattern, .length]),
      (PBKnob(label: "Tempo"), [.tempo]),
    ]])
    
    let stepRange = 0..<16
    let steps: [PBView] = stepRange.map { PBSelect(label: $0 == 0 ? "Step 1" : "\($0 + 1)") }
    vc.grid(panel: "step", items: [stepRange.map { (steps[$0], [.arp, .i($0), .step]) }])

    let lens: [PBView] = stepRange.map { PBKnob(label: $0 == 0 ? "Length 1" : "\($0 + 1)") }
    vc.grid(panel: "length", items: [stepRange.map { (lens[$0], [.arp, .i($0), .length]) }])

    let times: [PBView] = stepRange.map { PBKnob(label: $0 == 0 ? "Timing 1" : "\($0 + 1)") }
    vc.grid(panel: "time", items: [stepRange.map { (times[$0], [.arp, .i($0), .timing]) }])

    let accents: [PBView] = stepRange.map { PBKnob(label: $0 == 0 ? "Accent 1" : "\($0 + 1)") }
    vc.grid(panel: "accent", items: [stepRange.map { (accents[$0], [.arp, .i($0), .accent]) }])

    let glides: [PBView] = stepRange.map { PBCheckbox(label: $0 == 0 ? "Glide 1" : "\($0 + 1)") }
    vc.grid(panel: "glide", items: [stepRange.map { (glides[$0], [.arp, .i($0), .glide]) }])
    
    vc.addPatchChangeBlock(path: [.arp, .pattern, .length]) { value in
      (0..<16).forEach { step in
        let alpha = step <= value ? 1 : 0.25
        [steps, lens, times, accents, glides].forEach { $0[step].alpha = alpha }
      }
    }
    
    vc.addPatchChangeBlock(path: [.arp, .pattern]) { [weak vc] value in
      let notUser = value != 1
      ["step", "length", "time", "accent", "glide"].forEach { vc?.panels[$0]?.isHidden = notUser }
    }
  }
}
