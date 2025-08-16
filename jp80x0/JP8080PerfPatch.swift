
//protocol JP80X0PerfPatch : JP8080MultiPatchTemplate, BankedPatchTemplate, PerfPatch {
//}
//
//extension JP80X0PerfPatch {
//  static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x01000000 }
//}
//
//struct JP8080PerfPatch : JP80X0PerfPatch {
//  typealias Bank = JP8080PerfBank
//  
//  static let initFileName: String = "jp8080-perf-init"
//
//  static var rolandMap: [RolandMapItem] = [
//    ([.common], 0x0000, CommonPatch.self),
//    ([.voice, .mod], 0x0800, VoiceModPatch.self),
//    ([.part, .i(0)], 0x1000, PartPatch.self),
//    ([.part, .i(1)], 0x1100, PartPatch.self),
//    ([.patch, .i(0)], 0x4000, JP8080VoicePatch.self),
//    ([.patch, .i(1)], 0x4200, JP8080VoicePatch.self),
//  ]
//  
//  static func isValid(fileSize: Int) -> Bool {
//    [fileDataCount, 686].contains(fileSize)
//  }
//  
//  // altered from RolandMultiPatchTemplate to acommodate voices broken into multiple sysex msgs
//  static func mapIndex(address: RolandAddress, sysex: Data) -> Int? {
//    rolandMap.enumerated().compactMap { i, item in
//      switch item.patch {
//      case is JP8080VoicePatch.Type:
//        // hacky hard-code approach.
//        guard address == item.address || address == item.address + 0x0172 else { return nil }
//        return i
//      case let template as RolandSinglePatchTemplate.Type:
//        guard address == item.address,
//              template.isValid(sysex: sysex) else { return nil }
//        return i
//      case let template as RolandMultiPatchTemplate.Type:
//        guard template.mapIndex(address: address - item.address, sysex: sysex) != nil else { return nil }
//        return i
//      default:
//        return nil
//      }
//    }.first
//  }
//
//  
//  struct CommonPatch : JP8080SinglePatchTemplate {
//    static let initFileName: String = "jp8080-perf-common-init"
//    static let size: RolandAddress = 0x25
//    static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x0000 }
//    static var nameByteRange: CountableRange<Int>? = 0..<0x10
//
//    // no randomize
//    static func randomize(patch: ByteBackedSysexPatch) { return }
//
//    static let params: SynthPathParam = paramsFromOpts(paramOptions())
//    static func paramOptions(isJP8080: Bool = true) -> [ParamOptions] {
//      inc(b: 0x10) {
//        [
//          o([.key, .mode], optArray: ["Single", "Dual", "Split"]),
//          o([.split, .pt], isoS: Miso.noteName(zeroNote: "C-1")),
//          o([.panel, .select], optArray: ["Upper", "Lower", "Upper&Lower"]),
//          o([.part, .detune], max: 100, dispOff: -50),
//          o([.out, .assign], optArray: ["Mix", "Parallel"]),
//          o([.arp, .dest], optArray: ["Lower&Upper", "Lower", "Upper"]),
//          o([.voice, .assign], optArray: (isJP8080
//              ? ["8-2", "7-3", "5-5", "3-7", "2-8", "6-4", "4-6"]
//              : ["6-2", "5-3", "4-4", "3-5", "2-6"]
//           )),
//        ]
//        <<< prefix([.arp]) {
//          [
//            o([.on], max: 1),
//            o([.mode], optArray: ["Up", "Down", "Up&Down", "Random", "RPS"]),
//            o([.pattern], optArray: ["1/4", "1/6", "1/8", "1/12", "1/16", "1/32", "PORTA-A1", "PORTA-A2", "PORTA-A3", "PORTA-A4", "PORTA-A5", "PORTA-A6", "PORTA-A7", "PORTA-A8", "PORTA-A9", "PORTA-A10", "PORTA-A11", "PORTA-B1", "PORTA-B2", "PORTA-B3", "PORTA-B4", "PORTA-B5", "PORTA-B6", "PORTA-B7", "PORTA-B8", "PORTA-B9", "PORTA-B10", "PORTA-B11", "PORTA-B12", "PORTA-B13", "PORTA-B14", "PORTA-B15", "SEQUENCE-A1", "SEQUENCE-A2", "SEQUENCE-A3", "SEQUENCE-A4", "SEQUENCE-A5", "SEQUENCE-A6", "SEQUENCE-A7", "SEQUENCE-B1", "SEQUENCE-B2", "SEQUENCE-B3", "SEQUENCE-B4", "SEQUENCE-B5", "SEQUENCE-C1", "SEQUENCE-C2", "SEQUENCE-D1", "SEQUENCE-D2", "SEQUENCE-D3", "SEQUENCE-D4", "SEQUENCE-D5", "SEQUENCE-D6", "SEQUENCE-D7", "SEQUENCE-D8", "ECHO1", "ECHO2", "ECHO3", "MUTE1", "MUTE2", "MUTE3", "MUTE4", "MUTE5", "MUTE6", "MUTE7", "MUTE8", "MUTE9", "MUTE10", "MUTE11", "MUTE12", "MUTE13", "MUTE14", "MUTE15", "MUTE16", "STRUMMING1", "STRUMMING2", "STRUMMING3", "STRUMMING4", "STRUMMING5", "STRUMMING6", "STRUMMING7", "STRUMMING8", "REFRAIN1", "REFRAIN2", "PERCUSSION1", "PERCUSSION2", "PERCUSSION3", "PERCUSSION4", "WALKING BASS", "HARP", "RANDOM"]),
//            o([.range], max: 3, dispOff: 1),
//            o([.hold], max: 1),
//          ]
//        }
//      }
//      <<< (isJP8080 ? [] : [o([.pedal], 0x1c, max: 0x2d)]) // TODO: Options.
//      <<< inc(b: 0x1d) {
//        prefix([.trigger]) {
//          [
//            o([.on], max: 1),
//            o([.dest], optArray: ["Filter Env", "Amp Env", "F&A Envs"]),
//            o([.src, .channel], max: 15, dispOff: 1),
//            o2([.src, .note], max: 128, isoS: Miso.switcher([
//              .int(128, "All"),
//            ], default: Miso.noteName(zeroNote: "C-1"))),
//          ]
//        }
//      }
//      <<< [
//        o2([.tempo], 0x22, range: 20...250),
//      ]
//      <<< (isJP8080 ? [o([.input], 0x24, optArray: ["Rear", "Front"])] : [])
//
//    }
//  }
//  
//  struct VoiceModPatch : JP8080SinglePatchTemplate {
//    static let initFileName: String = "jp8080-perf-voicemod-init"
//    static let size: RolandAddress = 0x29
//    static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x0800 }
//
//    static let params: SynthPathParam = paramsFromOpts(paramOptions)
//    static let paramOptions: [ParamOptions] = inc(b: 0x00) {
//      [
//        o([.on], max: 1),
//        o([.panel], max: 1),
//        o([.algo], optArray: ["Solid", "Smooth", "Wide", "F Bank Wide", "F Bank Narw"]),
//        o([.delay, .type], optArray: JP8080VoicePatch.delayTypes),
//        o([.chorus, .type], optArray: ["Ens Mild", "Ens Clean", "Ens Fast"] + JP8080VoicePatch.fxTypes.dropLast(1)), // ensemble
//        o([.ext, .instr], max: 1),
//        o([.ext, .voice], max: 1),
//        o([.morph, .ctrl], max: 1),
//        o([.morph, .threshold]),
//        o([.morph, .sens], dispOff: -64),
//        o([.ctrl, .i(0), .assign], optArray: ctrlOptions),
//        o([.ctrl, .i(1), .assign], optArray: ctrlOptions),
//      ]
//      <<< prefix([.character], count: 12, bx: 1) { _ in
//       [
//        o([])
//       ]
//      }
//      <<< [
//        o([.voice, .mix]),
//        o([.release]),
//        o([.reson]),
//        o([.pan], dispOff: -64),
//        o([.level]),
//        o([.noise, .cutoff]),
//        o([.noise, .level]),
//        o([.gate, .threshold]),
//        o([.robot, .pitch]),
//        o([.robot, .ctrl]),
//        o([.robot, .level]),
//        o([.chorus, .level]),
//        o([.delay, .time]),
//        o([.delay, .feedback]),
//        o([.delay, .level]),
//        o([.chorus, .sync]), // TODO
//        o([.delay, .sync]), // TODO
//      ]
//    }
//    
//    static let ctrlOptions = ["Ensmbl Lvl", "V Delay Time", "V Delay Feedbk", "V Delay Lvl", "Vocal Mix", "V Reson", "V Release", "V Pan", "V Level", "V Nz Cutoff", "V Nz Lvl", "Gate Thresh", "Robot Pitch", "Robot Ctrl", "Robot Lvl"] + 12.map { "Char \($0 + 1)"}
//  }
//  
//  struct PartPatch : JP8080SinglePatchTemplate {
//    static let initFileName: String = "jp8080-perf-part-init"
//    static let size: RolandAddress = 0x08
//    static func startAddress(_ path: SynthPath?) -> RolandAddress {
//      0x1000 + (path?.endex ?? 0) * 0x100
//    }
//
//    // no randomize
//    static func randomize(patch: ByteBackedSysexPatch) { return }
//
//    static let params: SynthPathParam = paramsFromOpts(paramOptions())
//    
//    static func paramOptions(isJP8080: Bool = true) -> [ParamOptions] {
//      inc(b: 0x00) {
//        [
//          o([.bank], optArray: ["In Perf", "User", "Preset"] + (isJP8080 ? ["Card"] : [] )),
//          o([.number]),
//          o([.channel], max: 16, isoS: Miso.switcher([.int(16, "Off")], default: Miso.a(1) >>> Miso.str())),
//          o([.transpose], max: 48, dispOff: -24),
//          o([.delay, .sync], optArray: delaySyncOptions),
//          o([.lfo, .sync], optArray: lfoSyncOptions),
//          o([.chorus, .sync], optArray: chorusSyncOptions),
//          
//        ] <<< (isJP8080 ? [o([.group], max: 63)] : [])
//      }
//    }
//    
//    static let chorusSyncOptions = ["Off", "1/16", "1/8t", "1/16.", "1/8", "1/4t", "1/8.", "1/4", "1/2t", "1/4.", "1/2", "1/1t", "1/2.", "1/1", "2/1t", "1/1.", "2/1", "3 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars", "LFO1"]
//
//    static let delaySyncOptions = ["Off", "1/16", "1/8t", "1/16.", "1/8", "1/4t", "1/8.", "1/4", "1/2t", "1/4.", "1/2"]
//    
//    static let lfoSyncOptions = ["Off", "1/16", "1/8t", "1/16.", "1/8", "1/4t", "1/8.", "1/4", "1/2t", "1/4.", "1/2", "1/1t", "1/2.", "1/1", "2/1t", "1/1.", "2/1", "3 bars", "4 bars", "5 bars", "6 bars", "7 bars", "8 bars"]
//
//
//  }
//}
