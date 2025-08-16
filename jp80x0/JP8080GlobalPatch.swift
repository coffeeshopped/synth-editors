
//struct JP8080GlobalPatch : JP8080MultiPatchTemplate, GlobalPatch {
//
//  static let initFileName: String = "jp8080-global-init"
//  static var rolandMap: [RolandMapItem] = [
//    ([.param], 0x0000, ParameterPatch.self),
//    ([.motion], 0x2000, MotionPatch.self),
//    ([.rcv], 0x3000, TxRxPatch.self),
//  ]
//  
//  static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x00000000 }
//
//  
//  struct ParameterPatch : JP8080SinglePatchTemplate {
//    
//    static let initFileName: String = "jp8080-global-parameter-init"
//    static let size: RolandAddress = 0x19
//    static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x0000 }
//    
//    static let params: SynthPathParam = paramsFromOpts(paramOptions)
//    
//    static let paramOptions: [ParamOptions] = inc(b: 0x00) {
//      [
//        o([.perf, .bank], range: 1...3, isoS: Miso.options(["User", "Preset", "Card"], startIndex: 1)),
//        o([.perf, .number], max: 63),
//        o([.perf, .ctrl, .channel], max: 16, isoS: Miso.switcher([
//          .range(0...15, Miso.a(1) >>> Miso.str()),
//          .int(16, "Off"),
//        ])),
//        o([.on, .mode], optArray: ["Perf U-11", "Last-Set"]),
//        o([.midi, .sync], optArray: ["Off", "MIDI In", "Remote KBD In"]),
//        o([.local], max: 1),
//        o([.send, .rcv, .edit, .mode], optArray: ["Mode 1", "Mode 2"]),
//        o([.send, .rcv, .edit, .on], max: 1),
//        o([.send, .rcv, .pgmChange, .mode], optArray: ["Off", "PC", "Bank Sel+PC"]),
//      ]
//    }
//    <<< inc(b: 0x0a) {
//      [
//        o([.tune], max: 100, dispOff: -50),
//        o([.pattern, .trigger, .quantize], optArray: ["Off", "Beat", "Measure"]),
//        o([.motion, .reset], max: 1),
//        o([.motion, .preset], optArray: ["A", "B"]),
//        o([.gate, .time, .ratio], optArray: ["Real", "Staccato", "33%", "50%", "66%", "100%"]),
//        o([.input, .quantize], optArray: ["Off", "1/16(3)", "1/16", "1/8(3)", "1/8", "1/4(3)", "1/4"]),
//        o([.pattern, .metro], max: 8, dispOff: -4, isoS: metroIso),
//        o([.motion, .metro], max: 8, dispOff: -4, isoS: metroIso),
//      ]
//    }
//    <<< [
//      o([.perf, .group], 0x17, max: 63, dispOff: 1),
//      o([.ext, .key, .channel], 0x18, max: 16, isoS: Miso.switcher([
//        .range(0...15, Miso.a(1) >>> Miso.str()),
//        .int(16, "All"),
//      ])),
//    ]
//    
//    static let metroIso = Miso.switcher([
//      .range(0...3, Miso.m(-1) >>> Miso.a(4) >>> Miso.str("Beep %g")),
//      .int(4, "Off"),
//      .range(5...8, Miso.a(-4) >>> Miso.str("Click %g")),
//    ])
//  }
//  
//  struct MotionPatch : JP8080SinglePatchTemplate {
//    
//    static let initFileName: String = "jp8080-global-motion-init"
//    static let size: RolandAddress = 0x04
//    static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x2000 }
//    
//    static let params: SynthPathParam = paramsFromOpts(paramOptions)
//    
//    static let paramOptions: [ParamOptions] = inc(b: 0x00) {
//      [
//        o([.i(0), .i(0), .length], max: 8, isoS: lenIso),
//        o([.i(0), .i(1), .length], max: 8, isoS: lenIso),
//        o([.i(1), .i(0), .length], max: 8, isoS: lenIso),
//        o([.i(1), .i(1), .length], max: 8, isoS: lenIso),
//      ]
//    }
//    
//    static let lenIso = Miso.switcher([
//      .int(0, "Play Once"),
//      .range(1...8, Miso.unitFormat("-bar"))
//    ])
//  }
//
//  struct TxRxPatch : JP8080SinglePatchTemplate {
//    
//    static let initFileName: String = "jp8080-global-txrx-init"
//    static let size: RolandAddress = 0x2a
//    static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x3000 }
//    
//    static let params: SynthPathParam = paramsFromOpts(paramOptions)
//    
//    static let paramOptions: [ParamOptions] = inc(b: 0x0) {
//      [
//        octrl([.lfo, .i(0), .rate]),
//        octrl([.lfo, .i(0), .fade]),
//        octrl([.lfo, .i(1), .rate]),
//        octrl([.cross]),
//        octrl([.osc, .balance]),
//        octrl([.pitch, .lfo, .i(0), .depth]),
//        octrl([.pitch, .lfo, .i(1), .depth]),
//      ]
//      <<< prefix([.pitch, .env]) {
//        [
//          octrl([.depth]),
//          octrl([.attack]),
//          octrl([.decay]),
//        ]
//      }
//      <<< prefix([.osc, .i(0)]) {
//        [
//          octrl([.ctrl, .i(0)]),
//          octrl([.ctrl, .i(1)]),
//        ]
//      }
//      <<< prefix([.osc, .i(1)]) {
//        [
//          octrl([.range]),
//          octrl([.fine]),
//          octrl([.ctrl, .i(0)]),
//          octrl([.ctrl, .i(1)]),
//        ]
//      }
//      <<< prefix([.filter]) {
//        [
//          octrl([.cutoff]),
//          octrl([.reson]),
//          octrl([.key, .trk]),
//          octrl([.lfo, .i(0), .depth]),
//          octrl([.lfo, .i(1), .depth]),
//        ]
//        <<< prefix([.env]) {
//          [
//            octrl([.depth]),
//            octrl([.attack]),
//            octrl([.decay]),
//            octrl([.sustain]),
//            octrl([.release]),
//          ]
//        }
//      }
//      <<< prefix([.amp]) {
//        [
//          octrl([.level]),
//          octrl([.lfo, .i(0), .depth]),
//          octrl([.lfo, .i(1), .depth]),
//        ]
//        <<< prefix([.env]) {
//          [
//            octrl([.attack]),
//            octrl([.decay]),
//            octrl([.sustain]),
//            octrl([.release]),
//          ]
//        }
//      }
//      <<< [
//        octrl([.eq, .lo]),
//        octrl([.eq, .hi]),
//        octrl([.fx, .level]),
//        octrl([.delay, .time]),
//        octrl([.delay, .feedback]),
//        octrl([.delay, .level]),
//        octrl([.porta, .time]),
//      ]
//    }
//    <<< [
//      o([.morph, .ctrl, .up], 0x28, max: 95, isoS: ctrlIso),
//      o([.morph, .ctrl, .down], 0x29, max: 95, isoS: ctrlIso),
//    ]
//    
//    static func octrl(_ path: SynthPath, _ b: Int? = nil) -> ParamOptions {
//      o(path, b, max: 96, isoS: ctrlIso)
//    }
//    
//    static let ctrlIso = Miso.switcher([
//      .int(0, "Off"),
//      .range(1...31, Miso.str()),
//      .int(32, "After"),
//      .range(33...95, Miso.str()),
//      .int(96, "Sysex"),
//    ])
//
//  }
//
//}
