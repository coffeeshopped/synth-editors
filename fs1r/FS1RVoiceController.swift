//
//  FS1RVoiceController.swift
//  Patch Base
//
//  Created by Chadwick Wood on 1/19/18.
//  Copyright © 2018 Coffeeshopped LLC. All rights reserved.
//

import PBAPI

extension FS1R.Voice {
  
  enum Controller {
    
    static let algo: PatchController = .fm(algorithms(), MiniOp.controller, algoPath: [.algo], reverse: true, selectable: true)

    static let algoOptions = 88.map { "fs1r-algo-\($0 + 1)" }

    static var controller: PatchController {
      return .paged([
        .switcher(8.map { "Op \($0 + 1)" } + ["Common", "V Osc", "V Amp", "V Freq", "Mods", "N Osc", "N Amp", "N Freq"], cols: 4, color: 1),
        .child(algo, "algo", color: 1, clearBG: true),
        .panel("feed", color: 1, [[
          .imgSelect("Algorithm", [.algo], w: 120, h: 120, images: algoOptions),
        ],[
          .knob("Feedback", [.feedback]),
        ]]),

      ], effects: [
        .indexChange({ [.setIndex("algo", $0)] }),
        // listen for events from the algo controller to select index.
        .listen([.op], { state, locals in
          [.setIndex(nil, state.index)]
        })
      ], layout: [
        .row([("algo", 8), ("feed",2), ("switch", 6)]),
        .row([("page", 1)]),
        .col([("algo", 3), ("page", 5)]),
      ], pages: .map(8.map { [.op, .i($0)] } + [
        [.common], [.voiced, .osc], [.voiced, .amp], [.voiced, .freq],
        [.mod], [.unvoiced, .osc], [.unvoiced, .amp], [.unvoiced, .freq],
      ], [
        [.common] : commonController,
        [.mod] : modsController,
        [.op] : Op.controller,
        [.voiced, .amp] : palette(voicedAmpController),
        [.voiced, .osc] : palette(voicedOscController),
        [.voiced, .freq] : palette(voicedFreqController),
        [.unvoiced, .amp] : palette(unvoicedAmpController),
        [.unvoiced, .osc] : palette(unvoicedOscController),
        [.unvoiced, .freq] : palette(unvoicedFreqController),
      ]))
      
    }

    static var modsController: PatchController {
      return .patch([
        .child(knobController("Formant Control", "Formant Dest", .formant), "formant"),
        .child(knobController("FM Control", "FM Dest", .fm), "fm"),
      ], layout: [
        .simpleGrid([[("formant", 1), ("fm", 1)]]),
      ])
    }
      
    static func knobController(_ topLabel: String, _ destLabel: String, _ prefixItem: SynthPathItem) -> PatchController {
      return .patch(border: 1, [
        .children(5, "mod", color: 1, formantController(destLabel: destLabel, prefixItem: prefixItem)),
        .panel("label", color: 1, clearBG: true, [[.label(topLabel)]])
      ], layout: [
        .row([("label", 1), ("mod0", 1)]),
        .row([("mod1", 1), ("mod2", 1)]),
        .row([("mod3", 1), ("mod4", 1)]),
        .col([("label", 1), ("mod1", 1), ("mod3", 1)]),
      ])
    }
    
    static func formantController(destLabel: String, prefixItem: SynthPathItem) -> PatchController {
      return .patch(prefix: .index([prefixItem, .ctrl]), [
        .grid( [[
          .knob("Op", [.op]),
          .switsch("V/N", [.unvoiced]),
          .switsch(destLabel, [.dest]),
          .knob("Depth", [.depth])
        ]]),
      ], effects: [
        .patchChange(paths: [[.dest], [.depth]], { values in
          [.dimPanel(values[[.dest]] == 0 || values[[.depth]] == 64, nil)]
        })
      ])
    }
    
    
    static var commonController: PatchController {
      return .patch([
        .child(pitchController(), "pitch", color: 1),
        .child(filterController(), "filter", color: 1),
        .panel("filter2", color: 1, [[
          .select("Filter", [.filter, .type]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .knob("Reson Velo", [.reson, .velo]),
        ],[
          .knob("LFO1 Cutoff", [.cutoff, .lfo, .i(0)]),
          .knob("LFO2 Cutoff", [.cutoff, .lfo, .i(1)]),
          .knob("Input Gain", [.filter, .gain]),
          .knob("Key Sc Cutoff", [.cutoff, .key, .scale, .depth]),
          .knob("Key Sc Brk Pt", [.cutoff, .key, .scale, .pt])
        ]]),
        .panel("lfo1", color: 1, [[
          .select("LFO 1", [.lfo, .i(0), .wave]),
          .knob("Speed", [.lfo, .i(0), .rate]),
          .knob("Delay", [.lfo, .i(0), .delay]),
          .checkbox("Key Sync", [.lfo, .i(0), .key, .sync]),
          .knob("Pitch", [.lfo, .i(0), .pitch]),
          .knob("Amp", [.lfo, .i(0), .amp]),
          .knob("Freq", [.lfo, .i(0), .freq]),
        ]]),
        .panel("lfo2", color: 1, [[
          .select("LFO 2", [.lfo, .i(1), .wave]),
          .knob("Speed", [.lfo, .i(1), .rate]),
          .switsch("Phase", [.lfo, .i(1), .phase]),
          .checkbox("Key Sync", [.lfo, .i(1), .key, .sync]),
        ]]),
        .panel("cat", color: 1, [[
          .select("Category", [.category]),
          .knob("Note Shift", [.note, .shift]),
        ]]),
        .panel("level", color: 1, [[
          .knob("Level Adj 1", [.adjust, .op, .i(0), .level]),
          .knob("2", [.adjust, .op, .i(1), .level]),
          .knob("3", [.adjust, .op, .i(2), .level]),
          .knob("4", [.adjust, .op, .i(3), .level]),
        ],[
          .knob("5", [.adjust, .op, .i(4), .level]),
          .knob("6", [.adjust, .op, .i(5), .level]),
          .knob("7", [.adjust, .op, .i(6), .level]),
          .knob("8", [.adjust, .op, .i(7), .level]),
      ]])
      ], effects: [
        .paramChange([.filter, .on], { param in
          let dim = param.parm == 0
          return ["filter", "filter2", "lfo2"].map { .dimPanel(dim, $0) }
        })
      ], layout: [
        .row([("pitch", 7), ("lfo1", 7.5)], opts: [.alignAllTop]),
        .rowPart([("lfo2", 4.5), ("cat", 2.5)]),
        .row([("filter", 7), ("filter2", 5), ("level", 4)]),
        .col([("pitch", 2), ("filter", 2)]),
        .colPart([("lfo1", 1), ("lfo2", 1)]),
        .eq(["lfo1", "cat"], .trailing),
        .eq(["pitch", "lfo2"], .bottom),
      ])
    }
    
    static func env(label: String) -> (PatchController.PanelItem, PatchController.Effect) {
      let env: PatchController.Display = .timeLevelEnv(pointCount: 4, sustain: 2, bipolar: true)
      let item: PatchController.PanelItem = .display(env, label, [
        .src([.level, .i(-1)], dest: [.start, .level], { ($0 - 50) / 50 }),
      ] + 4.flatMap { [
        .src([.time, .i($0)], { $0 / 99 }),
        .src([.level, .i($0)], { ($0 - 50) / 50 })
      ] }, id: [.env])
      let effect: PatchController.Effect = .editMenu([.env], paths: 4.flatMap { [[.time, .i($0)], [.level, .i($0)]] }, type: "FS1REnvelope", init: nil, rand: nil)
      return (item, effect)
    }
    
    static func pitchController() -> PatchController {
      let env = env(label: "Pitch EG")
      return .patch(prefix: .fixed([.pitch, .env]), [
        .grid([[
          env.0,
          .knob("T1", [.time, .i(0)]),
          .knob("T2", [.time, .i(1)]),
          .knob("T3", [.time, .i(2)]),
          .knob("T4", [.time, .i(3)]),
          .switsch("EG Range", [.range]),
        ],[
          .knob("Velocity", [.velo]),
          .knob("L0", [.level, .i(-1)]),
          .knob("L1", [.level, .i(0)]),
          .knob("L2", [.level, .i(1)]),
          .knob("L3", [.level, .i(2)]),
          .knob("L4", [.level, .i(3)]),
          .knob("T Scale", [.time, .scale]),
        ]]),
      ], effects: [env.1])
    }
    
    static func filterController() -> PatchController {
      let env = env(label: "Filter EG")
      return .patch(prefix: .fixed([.filter, .env]), [
        .grid( [[
          env.0,
          .knob("T1", [.time, .i(0)]),
          .knob("T2", [.time, .i(1)]),
          .knob("T3", [.time, .i(2)]),
          .knob("T4", [.time, .i(3)]),
          .knob("EG Depth", [.depth]),
        ],[
          .knob("Velocity", [.depth, .velo]),
          .knob("Attack Velo", [.attack, .velo]),
          .knob("L1", [.level, .i(0)]),
          .knob("L2", [.level, .i(1)]),
          .knob("L3", [.level, .i(2)]),
          .knob("L4", [.level, .i(3)]),
          .knob("T Scale", [.time, .scale]),
        ]]),
      ], effects: [env.1])
    }

    
    // MARK: Palette
    
    static func palette(_ subVC: PatchController) -> PatchController {
      return .patch([
        .children(8, "vc", subVC),
      ] + 8.map {
        .panel("label\($0)", color: 1, clearBG: true, [[.label("\($0 + 1)")]])
      } , layout: [
        .row(8.map { ("label\($0)", 1) }),
        .row(8.map { ("vc\($0)", 1) }),
        .col([("vc0", 15), ("label0", 1)])
      ])
    }
    

    static var paletteEffect: PatchController.Effect {
      .dimsOn([.amp, .env, .level], id: nil)
    }
    static let voicedPrefix: PatchController.Prefix = .indexFn({ [.op, .i($0), .voiced] })
    static let unvoicedPrefix: PatchController.Prefix = .indexFn({ [.op, .i($0), .unvoiced] })
        
    static func ampController() -> (PatchController.Builder, [PatchController.Effect]) {
      let builder: PatchController.Builder = .grid([[
        .knob("T1", [.amp, .env, .time, .i(0)]),
        .knob("T2", [.amp, .env, .time, .i(1)]),
      ],[
        .knob("T3", [.amp, .env, .time, .i(2)]),
        .knob("T4", [.amp, .env, .time, .i(3)]),
      ],[
        .knob("Velo", [.amp, .env, .velo]),
        .knob("Amp Mod", [.amp, .env, .mod, .sens]),
      ],[
        .knob("L1", [.amp, .env, .level, .i(0)]),
        .knob("L2", [.amp, .env, .level, .i(1)]),
      ],[
        .knob("L3", [.amp, .env, .level, .i(2)]),
        .knob("L4", [.amp, .env, .level, .i(3)]),
      ],[
        .knob("Level", [.amp, .env, .level]),
        .checkbox("Mute", nil, id: [.mute]),
      ]])
      
      let effects: [PatchController.Effect] = [
        .patchChange([.amp, .env, .level], { [.setValue([.mute], $0 == 0 ? 1 : 0)] }),
        .controlChange([.mute], fn: { state, locals in
          let value = locals[[.mute]] ?? 0
          let level: Int
          var changes = [PatchController.AttrChange]()
          if value > 0 {
            let newLastLevel = state.prefixedValue([.amp, .env, .level]) ?? 90
            changes.append(.setValue([.extra, .level], newLastLevel == 0 ? 90 : newLastLevel))
            level = 0
          }
          else {
            level = locals[[.extra, .level]] ?? 90
          }
          return changes + [.paramsChange([[.amp, .env, .level] : level])]
        })
      ]
      return (builder, effects)
    }
    
    static var voicedAmpController: PatchController {
      let amp = ampController()
      return .patch(prefix: voicedPrefix, color: 2, border: 2, [amp.0], effects: amp.1 + [paletteEffect])
    }
    
    static let spectralFormEffect: PatchController.Effect = .patchChange([.spectral, .form], { value in
      let isSine = value == 0
      let isFormant = value == 7
      return [
        .dimItem(isFormant, [.osc, .mode], dimAlpha: 0),
        .dimItem(value < 5, [.freq, .ratio, .spectral], dimAlpha: 0),
        .setCtrlLabel([.freq, .ratio, .spectral], isFormant ? "BW" : "Reson"),
        .dimItem(isFormant, [.key, .sync], dimAlpha: 0),
        .dimItem(isSine, [.spectral, .skirt], dimAlpha: 0),
        // these next are only present in the bigger op controller
        .dimItem(!isFormant, [.bw, .bias, .sens], dimAlpha: 0),
        .dimItem(!isFormant, [.note, .scale], dimAlpha: 0),
        .dimItem(!isFormant, [.freq, .velo], dimAlpha: 0),
        .dimItem(!isFormant, [.freq, .mod, .sens], dimAlpha: 0),
        .dimItem(!isFormant, [.freq, .bias, .sens], dimAlpha: 0),
      ]
    })
    
    static let oscModeEffect: PatchController.Effect = .patchChange(paths: [[.osc, .mode], [.spectral, .form], [.coarse], [.fine]], { values in
      guard let oscMode = values[[.osc, .mode]],
        let specForm = values[[.spectral, .form]],
        let coarse = values[[.coarse]],
        let fine = values[[.fine]] else { return [] }
      return [
        .setCtrlLabel([.ratio], (oscMode == 0 && specForm < 7) ? "Ratio" : "Fixed"),
        .configCtrl([.ratio], .opts(ParamOptions(optArray: [
          String(String(format: "%5.3f", voicedFreq(oscMode: oscMode, spectralForm: specForm, coarse: coarse, fine: fine)).prefix(5))
        ]))),
      ]
    })


    
    static var voicedOscController: PatchController {
      return .patch(prefix: voicedPrefix, color: 2, border: 2, [
        .grid([[
          .switsch("Mode", [.osc, .mode]),
          .switsch("Ratio", nil, id: [.ratio]),
        ], [
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
        ], [
          .knob("Detune", [.detune]),
          .knob("Transpose", [.transpose]),
        ], [
          .knob("P Mod", [.pitch, .mod, .sens]),
          .knob("Skirt", [.spectral, .skirt]),
        ], [
          .select("Spectral Form", [.spectral, .form]),
        ], [
          .knob("BW", [.freq, .ratio, .spectral]),
          .checkbox("Key Sync", [.key, .sync]),
        ]]),
      ], effects: [
        paletteEffect,
        spectralFormEffect,
        oscModeEffect,
      ])
    }
    
    static let freqEnv: PatchController.PanelItem = {
      let env: PatchController.Display = .timeLevelEnv(pointCount: 2, sustain: 999, bipolar: true)
      return .display(env, "Freq EG", [
        .src([.freq, .env, .innit], dest: [.start, .level], { ($0 - 50) / 50 }),
        .src([.freq, .env, .attack, .level], dest: [.level, .i(0)], { ($0 - 50) / 50 }),
        .src([.freq, .env, .attack], dest: [.time, .i(0)], { $0 / 99 }),
        .src([.freq, .env, .decay], dest: [.time, .i(1)], { $0 / 99 }),
      ], id: [.env])
    }()
    
    static let freqEnvMenu: PatchController.Effect = .editMenu([.env], paths: [[.freq, .env, .innit], [.freq, .env, .attack, .level], [.freq, .env, .attack], [.freq, .env, .decay]], type: "FS1RFreqEnvelope", init: [0, 0, 20, 20], rand: { 4.map { _ in (0..<100).random()! } })

    
    static func freqController(fseqTrk: Bool) -> (PatchController.Builder, [PatchController.Effect]) {
      
      let builder: PatchController.Builder = .grid([[
        freqEnv,
      ],[
        .knob("Initial", [.freq, .env, .innit]),
        .knob("A Level", [.freq, .env, .attack, .level]),
      ],[
        .knob("Attack", [.freq, .env, .attack]),
        .knob("Decay", [.freq, .env, .decay]),
      ],[
        .knob("Freq Scaling", [.note, .scale]),
        .knob("Fr Bias", [.freq, .bias, .sens]),
      ],[
        .knob("Fr Velo", [.freq, .velo]),
        .knob("Fr Mod", [.freq, .mod, .sens]),
      ],[
        .checkbox("Fseq", [.fseq]),
      ] + (fseqTrk ? [.knob("Fseq Trk", [.fseq, .trk])] : [])])
      
      let effects: [PatchController.Effect] = [
        .patchChange([.spectral, .form], { value in
          let isFormant = value == 7
          let freqPaths: [SynthPath] = [
            [.freq, .velo],
            [.freq, .mod, .sens],
            [.freq, .bias, .sens],
            [.note, .scale],
          ]
          return freqPaths.map { .dimItem(isFormant, $0, dimAlpha: 0) }
        }),
        .paramChange([.fseq, .on], { param in
          [
            .dimItem(param.parm == 0, [.fseq]),
            .dimItem(param.parm == 0, [.fseq, .trk]),
          ]
        }),
        freqEnvMenu,
      ]
      
      return (builder, effects)
    }
    
    static var voicedFreqController: PatchController {
      let c = freqController(fseqTrk: true)
      return .patch(prefix: voicedPrefix, color: 2, border: 2, [c.0], effects: c.1 + [paletteEffect])
    }
    
    static var unvoicedAmpController: PatchController {
      let c = ampController()
      return .patch(prefix: unvoicedPrefix, color: 3, border: 3, [c.0], effects: c.1 + [paletteEffect])
    }
    
    static let unvoicedRatioEffect: PatchController.Effect = .patchChange(paths: [[.coarse], [.fine], [.mode]], { values in
      guard let mode = values[[.mode]],
        let coarse = values[[.coarse]],
        let fine = values[[.fine]] else { return [] }
      return [
        .dimItem(mode > 0, [.ratio], dimAlpha: 0),
        .configCtrl([.ratio], .opts(ParamOptions(optArray: [
          String(String(format: "%5.3f", fixedFreq(coarse: coarse, fine: fine)).prefix(5)),
        ])))
      ]
    })
    
    static let unvoicedModeEffect: PatchController.Effect = .patchChange([.mode], { value in
      let isNormal = value == 0
      return [
        .dimItem(!isNormal, [.coarse], dimAlpha: 0),
        .dimItem(!isNormal, [.fine], dimAlpha: 0),
        // only in bigger controller
        .dimItem(!isNormal, [.freq, .velo], dimAlpha: 0),
        .dimItem(!isNormal, [.freq, .mod, .sens], dimAlpha: 0),
        .dimItem(!isNormal, [.freq, .bias, .sens], dimAlpha: 0),
        .dimItem(!isNormal, [.note, .scale], dimAlpha: 0),
      ]
    })
    
    static var unvoicedOscController: PatchController {
      return .patch(prefix: unvoicedPrefix, color: 3, border: 3, [
        .grid( [[
          .switsch("Mode", [.mode]),
          .switsch("Ratio", [.ratio]),
        ], [
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
        ], [
          .knob("Transpose", [.transpose]),
        ], [
          .knob("BW", [.bw]),
          .knob("BW Bias", [.bw, .bias, .sens]),
        ], [
          .knob("Skirt", [.skirt]),
          .knob("Reson", [.reson]),
        ]])
      ], effects: [
        paletteEffect,
        unvoicedRatioEffect,
        unvoicedModeEffect,
      ])
    }
    
    static var unvoicedFreqController: PatchController {
      let c = freqController(fseqTrk: false)
      return .patch(prefix: unvoicedPrefix, color: 3, border: 3, [c.0], effects: c.1 + [paletteEffect])
    }
    
  }
  
}
