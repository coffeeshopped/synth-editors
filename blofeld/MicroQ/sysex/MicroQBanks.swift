//
//  MicroQVoiceBank.swift
//  Blofeld
//
//  Created by Chadwick Wood on 10/14/21.
//  Copyright © 2021 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBCore


extension SingleBankTemplate where Template: MicroQPatch {
  static func patchArray(fromData data: Data) -> [Patch] {
    patchArray(fromData: data) { location($0, fromByte: 6) }
  }
  
  static func fileData(_ patches  : [Patch]) -> [UInt8] {
    sysexData(patches: patches) {
      Template.sysexData($0.bytes, deviceId: 0, bank: 0x40, location: UInt8($1)).bytes()
    }
  }
}

struct MicroQVoiceBank : SingleBankTemplate, VoiceBank {
  typealias Template = MicroQVoicePatch
  static let patchCount: Int = 100
  static let initFileName: String = "microq-voice-bank-init"
}

struct MicroQMultiBank : SingleBankTemplate, PerfBank {
  typealias Template = MicroQMultiPatch
  static let patchCount: Int = 100
  static let initFileName: String = "microq-multi-bank-init"
}

struct MicroQDrumBank : SingleBankTemplate, RhythmBank {
  typealias Template = MicroQDrumPatch
  static let patchCount: Int = 20
  static let initFileName: String = "microq-drum-bank-init"
}
