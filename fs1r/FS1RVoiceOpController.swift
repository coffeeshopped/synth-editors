//
//  FS1RVoiceOpController.swift
//  Patch Base
//
//  Created by Chadwick Wood on 1/22/18.
//  Copyright © 2018 Coffeeshopped LLC. All rights reserved.
//

import PBAPI
import DX7

extension FS1R.Voice {
  
  enum Op {
    
    static var controller: PatchController {
      return .patch(prefix: .index([.op]), [
        .child(voicedOp, "v"),
        .child(unvoicedOp, "n"),
      ], effects: [
        .indexChange({ [
          .setIndex("v", $0),
          .setIndex("n", $0),
        ]}),
      ], layout: [
        .simpleGrid([[("v", 8.5),("n", 7.5)]]),
      ])
    }

        
    static var opControllerEffects: [PatchController.Effect] {
      return [
        .patchChange([.amp, .env, .level], { [.dimPanel($0 == 0, nil)] }),
        .paramChange([.fseq, .on], { param in
          [
            .dimItem(param.parm == 0, [.fseq]),
            .dimItem(param.parm == 0, [.fseq, .trk]),
          ]
        }),

      ]
    }

    static var voicedOp: PatchController {
      let AllPaths: [SynthPath] = patchTruss.params.keys.compactMap {
        guard $0.starts(with: [.op, .i(0), .voiced]) else { return nil }
        return $0.subpath(from: 3)
      }

      return .patch(prefix: .fixed([.voiced]), border: 2, [
        .child(ampController, "amp", color: 2),
        .child(freqController, "freq", color: 2),
        .child(levelScale, "levelScale", color: 2),
        .button("Op", color: 2),
        .panel("osc", color: 2, [[
          .switsch("Mode", [.osc, .mode]),
          .switsch("Ratio", nil, id: [.ratio]),
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Detune", [.detune]),
          .knob("Transpose", [.transpose]),
          .knob("P Mod", [.pitch, .mod, .sens]),
        ], [
          .select("Spectral Form", [.spectral, .form]),
          .knob("Skirt", [.spectral, .skirt]),
          .knob("BW", [.freq, .ratio, .spectral]),
          .knob("BW Bias", [.bw, .bias, .sens]),
          .checkbox("Key Sync", [.key, .sync]),
          .knob("Freq Scaling", [.note, .scale]),
          .checkbox("Fseq", [.fseq]),
          .knob("Fseq Trk", [.fseq, .trk]),
        ]]),
        .panel("freq2", color: 2, [[
          .knob("Fr Velo", [.freq, .velo]),
          .knob("Fr Mod", [.freq, .mod, .sens]),
          .knob("Fr Bias", [.freq, .bias, .sens]),
        ]]),
      ], effects: [
        Controller.spectralFormEffect,
        Controller.oscModeEffect,
        .indexChange({ [.setCtrlLabel([.button], "Op \($0 + 1) - Voiced")] }),
        .editMenu([.button], paths: AllPaths, type: "FS1RVoicedOp", init: {
          let bd = try! patchTruss.createInitBodyData()
          return AllPaths.map { patchTruss.getValue(bd, path: [.op, .i(0), .voiced] + $0) ?? 0 }
        }(), rand: {
          let patch = patchTruss.randomize()
          return AllPaths.map { patch[[.op, .i(0), .voiced] + $0] ?? 0 }
        })
      ] + opControllerEffects, layout: [
        .row([("freq", 6), ("freq2", 3)]),
        .row([("button", 3), ("levelScale", 7.5)]),
        .col([("osc", 2), ("freq", 1), ("amp", 2), ("button", 1)]),
        .eq(["osc","freq2","amp","levelScale"], .trailing),
      ])
    }

    static var levelScale: PatchController {
      
      let levelMaps: [PatchController.DisplayMap] = [
        .ident([.left, .curve]),
        .ident([.right, .curve]),
        .src([.left, .depth], { $0 / 99 }),
        .src([.right, .depth], { $0 / 99 }),
        .src([.brk, .pt], { $0 / 99 })
      ]
      let levelScale: PatchController.PanelItem = .display(.levelScaling(), nil, levelMaps, id: [.level, .scale], width: 4)

      return .patch(prefix: .fixed([.level, .scale]), [
        .grid([[
          levelScale,
          .knob("L Depth", [.left, .depth]),
          .switsch("L Curve", [.left, .curve]),
          .knob("Break Pt", [.brk, .pt]),
          .knob("R Depth", [.right, .depth]),
          .switsch("R Curve", [.right, .curve]),
        ]])
      ], effects: [
        .editMenu([.level, .scale], paths: [
          [.left, .depth],
          [.left, .curve],
          [.right, .depth],
          [.right, .curve],
          [.brk, .pt],
        ], type: "FS1RRateLevel", init: [0, 3, 0, 0, 39], rand: {
          5.map { $0 % 2 == 1 ? (0..<4).random()! : (0..<100).random()! }
        })
      ])
    }

    static var unvoicedOp: PatchController {
      let AllPaths: [SynthPath] = patchTruss.params.keys.compactMap {
        guard $0.starts(with: [.op, .i(0), .unvoiced]) else { return nil }
        return $0.subpath(from: 3)
      }

      return .patch(prefix: .fixed([.unvoiced]), border: 3, [
        .child(ampController, "amp", color: 3),
        .child(freqController, "freq", color: 3),
        .button("Op", color: 3),
        .panel("osc", color: 3, [[
          .switsch("Mode", [.mode]),
          .switsch("Ratio", [.ratio]),
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Transpose", [.transpose]),
          .knob("Freq Scale", [.note, .scale]),
        ],[
          .knob("Skirt", [.skirt]),
          .knob("BW", [.bw]),
          .knob("BW Bias", [.bw, .bias, .sens]),
          .knob("Reson", [.reson]),
          .knob("Fr Velo", [.freq, .velo]),
          .knob("Fr Mod", [.freq, .mod, .sens]),
          .knob("Fr Bias", [.freq, .bias, .sens]),
        ]]),
        .panel("freq2", color: 3, [[
          .checkbox("Fseq", [.fseq]),
        ]]),
        .panel("amp2", color: 3, [[
          .knob("Level Scale", [.level, .key, .scale]),
        ]])
      ], effects: [
        .indexChange({ [.setCtrlLabel([.button], "Op \($0 + 1) - Unvoiced")] }),
        .editMenu([.button], paths: AllPaths, type: "FS1RUnvoicedOp", init: {
          let bd = try! patchTruss.createInitBodyData()
          return AllPaths.map { patchTruss.getValue(bd, path: [.op, .i(0), .unvoiced] + $0) ?? 0 }
        }(), rand: {
          let patch = patchTruss.randomize()
          return AllPaths.map { patch[[.op, .i(0), .unvoiced] + $0] ?? 0 }
        }),
        Controller.unvoicedRatioEffect,
        Controller.unvoicedModeEffect,
      ] + opControllerEffects, layout: [
        .row([("freq", 6), ("freq2", 1)]),
        .row([("button", 3), ("amp2", 4)]),
        .col([("osc", 2), ("freq", 1), ("amp", 2), ("button", 1)]),
        .eq(["osc","freq2","amp","amp2"], .trailing),
      ])
    }
    
    
    static var ampController: PatchController {

      let env: PatchController.Display = .timeLevelEnv(pointCount: 5, sustain: 3)
      let envItem: PatchController.PanelItem = .display(env, "Amp EG", [
        .src([.hold], dest: [.time, .i(0)], { $0 / 99 }),
      ] + 4.flatMap { [
        .src([.time, .i($0)], dest: [.time, .i($0 + 1)], { $0 / 99 }),
        .src([.level, .i($0)], dest: [.level, .i($0 + 1)], { $0 / 99 }),
      ] } + [
        .src([.level, .i(3)], dest: [.start, .level], { $0 / 99 }),
        .src([.level, .i(3)], dest: [.level, .i(0)], { $0 / 99 }),
      ], id: [.env])
      
      return .patch(prefix: .fixed([.amp, .env]), [
        .grid([[
          envItem,
          .knob("T1", [.time, .i(0)]),
          .knob("T2", [.time, .i(1)]),
          .knob("T3", [.time, .i(2)]),
          .knob("T4", [.time, .i(3)]),
          .knob("Velo", [.velo]),
          .knob("Amp Mod", [.mod, .sens]),
          ],[
          .knob("T Scale", [.time, .scale]),
          .knob("Hold", [.hold]),
          .knob("L1", [.level, .i(0)]),
          .knob("L2", [.level, .i(1)]),
          .knob("L3", [.level, .i(2)]),
          .knob("L4", [.level, .i(3)]),
          .knob("EG Bias", [.bias, .sens]),
          .knob("Level", [.level]),
          .checkbox("Mute", nil, id: [.mute]),
        ]])
      ], effects: [
        .patchChange([.level], { [.setValue([.mute], $0 == 0 ? 1 : 0)] }),
        .controlChange([.mute], fn: { state, locals in
          let value = locals[[.mute]] ?? 0
          let level: Int
          var changes = [PatchController.AttrChange]()
          if value > 0 {
            let newLastLevel = state.prefixedValue([.level]) ?? 90
            changes.append(.setValue([.extra, .level], newLastLevel == 0 ? 90 : newLastLevel))
            level = 0
          }
          else {
            level = locals[[.extra, .level]] ?? 90
          }
          return changes + [.paramsChange([[.level] : level])]
        }),
        .editMenu([.env], paths: 4.map { [.time, .i($0)] } + 4.map { [.level, .i($0)] } + [[.hold]], type: "FS1RAmpEnvelope", init: [0, 20, 20, 0, 99, 99, 99, 0, 0], rand: { 9.map { $0 > 6 ? 0 : (0..<100).random()! } }),
      ])
    }
    
    
    static var freqController: PatchController {
      return .patch([
        .grid([[
          Controller.freqEnv,
          .knob("Initial", [.freq, .env, .innit]),
          .knob("A Level", [.freq, .env, .attack, .level]),
          .knob("Attack", [.freq, .env, .attack]),
          .knob("Decay", [.freq, .env, .decay]),
        ]])
      ], effects: [
        Controller.freqEnvMenu,
      ])
    }
  }
  
}
