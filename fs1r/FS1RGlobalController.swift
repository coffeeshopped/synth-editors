//
//  FS1RGlobalController.swift
//  Patch Base
//
//  Created by Chadwick Wood on 6/13/18.
//  Copyright © 2018 Coffeeshopped LLC. All rights reserved.
//

import PBAPI

extension FS1R.Global {
  
  enum Controller {
    
    static var controller: PatchController {
      return .patch([
        .panel("dev", color: 1, [[
          .knob("Device ID", [.deviceId]),
          .knob("Note Shift", [.note, .shift]),
          .knob("Detune", [.detune]),
          .switsch("Dump Int", [.dump, .interval]),
          .switsch("Pgm Ch Mode", [.pgmChange, .mode]),
          .select("Perf Channel", [.perf, .channel]),
          .switsch("Knob Mode", [.knob, .mode]),
        ]]),
        .panel("curve", color: 1, [[
          .switsch("Breath Crv", [.breath, .curve]),
          .switsch("Velo Crv", [.velo, .curve]),
          .switsch("Note Rcv", [.rcv, .note]),
          .checkbox("Bank Rcv", [.rcv, .bank, .select]),
          .checkbox("Pgm Ch Rcv", [.rcv, .pgmChange]),
          .checkbox("Knob Rcv", [.rcv, .knob]),
          .checkbox("Knob Send", [.send, .knob]),
        ]]),
        .panel("knob", color: 1, [[
          .knob("Knob 1", [.knob, .ctrl, .i(0), .number]),
          .knob("2", [.knob, .ctrl, .i(1), .number]),
          .knob("3", [.knob, .ctrl, .i(2), .number]),
          .knob("4", [.knob, .ctrl, .i(3), .number]),
        ]]),
        .panel("mc", color: 1, [[
          .knob("MC 1", [.midi, .ctrl, .i(0), .number]),
          .knob("2", [.midi, .ctrl, .i(1), .number]),
          .knob("3", [.midi, .ctrl, .i(2), .number]),
          .knob("4", [.midi, .ctrl, .i(3), .number]),
        ]]),
        .panel("foot", color: 1, [[
          .knob("Formant Ctrl", [.formant, .ctrl, .number]),
          .knob("FM Ctrl", [.fm, .ctrl, .number]),
        ],[
          .knob("Foot Ctrl", [.foot, .ctrl, .number]),
          .knob("Breath Ctrl", [.breath, .ctrl, .number]),
        ]]),
        .panel("play", color: 1, [[
          .knob("Play Note 1", [.preview, .note, .i(0)]),
          .knob("2", [.preview, .note, .i(1)]),
          .knob("3", [.preview, .note, .i(2)]),
          .knob("4", [.preview, .note, .i(3)]),
        ],[
          .knob("Play Velo 1", [.preview, .velo, .i(0)]),
          .knob("2", [.preview, .velo, .i(1)]),
          .knob("3", [.preview, .velo, .i(2)]),
          .knob("4", [.preview, .velo, .i(3)]),
        ]]),
      ], layout: [
        .row([("dev", 1)]),
        .row([("curve", 1)]),
        .row([("knob", 1),("mc", 1)]),
        .row([("foot", 1),("play",2)]),
        .col([("dev",1), ("curve", 1), ("knob", 1), ("foot", 2)]),
      ])
    }
    
  }
  
}
