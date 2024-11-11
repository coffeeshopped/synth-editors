//
//  MicroQGlobalPatch.swift
//  Blofeld
//
//  Created by Chadwick Wood on 10/19/21.
//  Copyright © 2021 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBCore

struct MicroQGlobalPatch : MicroQPatch, GlobalPatch {
    
  static var relatedBankType: SysexPatchBank.Type? = nil
  static let nameByteRange: CountableRange<Int>? = nil
  static let initFileName: String = "microq-global-init"
  static let fileDataCount: Int = 207
  
  static func bytes(data: Data) -> [UInt8] { data.safeBytes(5..<205) }
  
  static func sysexData(_ bytes: [UInt8], deviceId: UInt8, bank: UInt8, location: UInt8) -> MidiMessage {
    var data = sysexHeader(deviceId: deviceId) + [0x12] + bytes
    data.append(0x7f) // universal checksum
    data.append(0xf7)
    return .sysex(data)
  }
  
  
  static let paramOptions: [ParamOptions] =
    [
//      o([.part], 20, max: 15, dispOff: 1),
      o([.mode], 21, optArray: ["Single", "Multi"]),
//      o([.multi], 22, max: 99, dispOff: 1),
    ]
//    <<< prefix([.part], count: 4, bx: 1) { _ in
//      [
//        o([.sound], 1, max: 99, dispOff: 1),
//        o([.bank], 9, optArray: ["A", "B", "C"]),
//      ]
//    }
    <<< [
      o([.pedal, .offset], 70, dispOff: -64),
      o([.pedal, .gain], 71),
      o([.pedal, .curve], 72),
      o([.pedal, .ctrl], 73, optArray: ["Off", "Volume", "Ctrl W", "Ctrl X", "Ctrl Y", "Ctrl Z", "F1 Cutoff", "F2 Cutoff"]),
      o([.tune], 5, range: 54...74, dispOff: -64, isoF: Miso.lerp(in: 54...74, out: 430...450) >>> Miso.round()),
      o([.transpose], 6, range: 52...76, dispOff: -64),
      o([.ctrl, .send], 7, optArray: ["Off", "CC", "SysEx", "CC+SysEx"]),
      o([.ctrl, .rcv], 8, max: 1),
      o([.ctrl, .i(0)], 53, max: 120),
      o([.ctrl, .i(1)], 54, max: 120),
      o([.ctrl, .i(2)], 55, max: 120),
      o([.ctrl, .i(3)], 56, max: 120),
      o([.arp], 15, max: 1),
      o([.clock], 19, optArray: ["Internal", "Send", "Auto", "Auto-Thru"]),
      o([.channel], 24, max: 16, isoS: Miso.switcher([.int(0, "Omni")], default: Miso.str())),
      o([.deviceId], 25, max: 126),
      o([.local], 26, max: 1),
      o([.pgmChange, .send], 57, optArray: ["Off", "Num", "Num+Bank"]),
      o([.pgmChange, .rcv], 74, optArray: ["Off", "Num", "Num+Bank"]),
      o([.popup, .time], 27, isoS: timeIso),
      o([.extra, .time], 28, isoS: timeIso), // label time
      o([.contrast], 29),
      o([.on, .velo, .curve], 30, optArray: ["Exp2", "Exp1", "Linear", "Log1", "Log2", "Fix32", "Fix64", "Fix100", "Fix127"]),
      o([.release, .velo, .curve], 31, optArray: ["Off", "Exp2", "Exp1", "Linear", "Log1", "Log2", "Fix32", "Fix64", "Fix100", "Fix127"]),
      o([.pressure, .curve], 32, optArray: ["Exp2", "Exp1", "Linear", "Log1", "Log2"]),
      o([.input, .gain], 33, max: 3, dispOff: 1),
      o([.link, .fx], 35, optArray: ["None", "Inst 1", "Inst 2", "Inst 3", "Inst 4"]),
      o([.mix, .send], 58, optArray: ["Main", "Sub1", "Sub2", "Inst 1 FX", "Inst 2 FX", "Inst 3 FX", "Inst 4 FX", "FX2 Wet"]),
      o([.mix, .level], 59),
    ]
  
  static let params = paramsFromOpts(paramOptions)
  
  static let timeIso = Miso.lerp(in: 127, out: 0.05...15.5) >>> Miso.round(1) >>> Miso.unitFormat("s")
}
