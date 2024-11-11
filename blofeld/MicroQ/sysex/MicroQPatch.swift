//
//  MicroQPatch.swift
//  Blofeld
//
//  Created by Chadwick Wood on 10/18/21.
//  Copyright © 2021 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBCore

protocol MicroQPatch : SinglePatchTemplate {
  static func sysexData(_ bytes: [UInt8], deviceId: UInt8, bank: UInt8, location: UInt8) -> MidiMessage
}

extension MicroQPatch {

  static func sysexHeader(deviceId: UInt8) -> [UInt8] { [0xf0, 0x3e, 0x10, deviceId] }

  /// dumpByte: cmd byte for what kind of dump.
  static func sysexData(_ bytes: [UInt8], deviceId: UInt8, dumpByte: UInt8, bank: UInt8, location: UInt8) -> MidiMessage {
    var data = sysexHeader(deviceId: deviceId) + [dumpByte, bank, location]
    data.append(contentsOf: bytes)
    data.append(0x7f) // universal checksum
    data.append(0xf7)
    return .sysex(data)
  }
  
  static func fileData(_ bytes: [UInt8]) -> [UInt8] {
    // devID=127 is OMNI, but a PDF I read said 0 is default for sound designers
    sysexData(bytes, deviceId: 0, bank: 0x20, location: 0x00).bytes()
  }

  static func fxParams(_ b: Int) -> [ParamOptions] {
    prefix([.fx], count: 2, bx: 16) { i in
      inc(b: b) { [
        o([.type], optArray: i == 0 ? MicroQVoicePatch.fxTypes : MicroQVoicePatch.fx2Types),
        o([.mix]),
      ] }
      <<< prefix([.param], count: 14, bx: 1) { fx in
        [o([], b + 2)]
      }
    }
  }
  
  static func arpParams(_ b: Int) -> [ParamOptions] {
    prefix([.arp]) {
      inc(b: b) {[
        o([.mode], opts: Blofeld.Voice.arpModes),
        o([.pattern], max: 16, isoS: Miso.switcher([
          .int(0, "Off"),
          .int(1, "User"),
        ], default: Miso.a(-1) >>> Miso.str())),
        o([.note], max: 15, dispOff: 1),
        o([.clock], dispOff: 3),
        o([.length], isoS: Miso.switcher([
          .int(127, "Legato"),
        ], default: Miso.a(1) >>> Miso.str())),
        o([.octave], max: 9, dispOff: 1),
        o([.direction], opts: Blofeld.Voice.arpDirections),
        o([.sortOrder], opts: Blofeld.Voice.arpSortOptions),
        o([.velo], optArray: ["Each Note", "First Note", "Last Note"]),
        o([.timingFactor]),
        o([.legato], max: 1),
        o([.pattern, .reset], max: 1),
        o([.pattern, .length], max: 15, dispOff: 1),
      ]}
      <<< [
        o([.tempo], b + 15, isoF: MicroQVoicePatch.tempoIso),
      ]
      <<< prefix([], count: 16, bx: 1) { i in
        [
          o([.step], b + 16, bits: 4...6, dispOff: -4, opts: Blofeld.Voice.arpStepOptions),
          o([.glide], b + 16, bit: 3),
          o([.accent], b + 16, bits: 0...2, max: 7, dispOff: -4, isoS: MicroQVoicePatch.arpAccentIso),
          o([.length], b + 32, bits: 4...6, max: 7, dispOff: -4, isoS: MicroQVoicePatch.arpLenIso),
          o([.timing], b + 32, bits: 0...2, max: 7, dispOff: -4, isoS: MicroQVoicePatch.arpTimingIso),
        ]
      }
    }
  }

}

