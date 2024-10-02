//
//  FS1RMiniOpController.swift
//  Yamaha
//
//  Created by Chadwick Wood on 10/22/20.
//  Copyright © 2020 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBAPI

extension FS1R.Voice {

  enum MiniOp {
    
    static var controller: PatchController {
      
      let AllPaths: [SynthPath] = patchTruss.params.keys.compactMap {
        guard $0.starts(with: [.op, .i(0)]) else { return nil }
        return $0.subpath(from: 2)
      }

      
      return .index([.op], label: [.op], { "\($0 + 1)" }, [
        .items([
          (env(prefix: [.voiced]), "env"),
          (env(prefix: [.unvoiced]), "nenv"),
          (.label("?", align: .leading, size: 11, id: [.op]), "op"),
          (.label("x", align: .trailing, size: 11, bold: false, id: [.osc, .mode]), "freq"),
        ]),
      ], effects: [
        .patchChange(paths: [[.voiced, .osc, .mode], [.voiced, .spectral, .form], [.voiced, .coarse], [.voiced, .fine], [.voiced, .detune]], { values in
          guard let oscMode = values[[.voiced, .osc, .mode]],
            let specForm = values[[.voiced, .spectral, .form]],
            let coarse = values[[.voiced, .coarse]],
            let fine = values[[.voiced, .fine]],
            let detune = values[[.voiced, .detune]] else { return [] }
          let ratioMode = oscMode == 0 && specForm < 7
          let valText = String(String(format: "%5.3f", voicedFreq(oscMode: oscMode, spectralForm: specForm, coarse: coarse, fine: fine)).prefix(5))
          let detuneOff = detune - 15
          let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")
          return [
            .setCtrlLabel([.osc, .mode], ratioMode ? "x \(valText)\(detuneString)" : "\(valText) Hz")
          ]
        }),
        .setup([
          .colorItem([.voiced, .amp, .env], level: 2),
          .colorItem([.unvoiced, .amp, .env], level: 3, clearBG: true),
          .colorItem([.op], level: 1),
          .colorItem([.osc, .mode], level: 1),
        ]),
        // on-click for the VC's view, send an event up.
        .click(nil, { state, locals in
          [.event([.op], state, locals)]
        }),
        .editMenu(nil, paths: AllPaths, type: "Op", init: {
          let bd = try! patchTruss.createInitBodyData()
          return AllPaths.map { patchTruss.getValue(bd, path: [.op, .i(0)] + $0) ?? 0 }
        }(), rand: {
          let patch = patchTruss.randomize()
          return AllPaths.map { patch[[.op, .i(0)] + $0] ?? 0 }
        })
      ], layout: [
        .row([("op",1),("freq",4)]),//, spacing: 2),
        .row([("env", 1)]),//, spacing: 2),
        .colFixed(["op", "env"], fixed: "op", height: 11, spacing: 2),
        .row([("nenv", 1)]),//, spacing: 2),
        .colFixed(["op", "nenv"], fixed: "op", height: 11, spacing: 2),
      ])
    }
    
    static func env(prefix: SynthPath) -> PatchController.PanelItem {
      let prefix = prefix + [.amp, .env]
      let env: PatchController.Display = .timeLevelEnv(pointCount: 5, sustain: 3)
      let maps: [PatchController.DisplayMap] = [
        .src([.level], dest: [.gain], { $0 / 99 }),
        .src([.hold], dest: [.time, .i(0)], { $0 / 99 }),
      ] + 3.flatMap { [
        .src([.time, .i($0)], dest: [.time, .i($0 + 1)], { $0 / 99 }),
        .src([.level, .i($0)], dest: [.level, .i($0 + 1)], { $0 / 99 }),
      ] } + [
        .src([.time, .i(3)], dest: [.time, .i(4)], { $0 / 99 }),
        .src([.level, .i(3)], dest: [.level, .i(4)], { $0 / 99 }),
        .src([.level, .i(3)], dest: [.level, .i(0)], { $0 / 99 }),
      ]
      return .display(env, nil, maps.map { $0.srcPrefix(prefix) }, id: prefix)
    }

  }
}
