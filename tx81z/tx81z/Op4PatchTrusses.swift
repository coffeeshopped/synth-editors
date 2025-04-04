
extension Op4 {
  
  enum VCED {
    
    static let patchWerk = PatchWerk(synth, "vced", 93, namePack: .basic(77..<87), params: parms.params(), initFile: "dx100-init", cmdByte: 0x12, sysexData: {
      Yamaha.sysexData(channel: $1, cmdBytes: [0x03, 0x00, 0x5d], bodyBytes: $0)
    }, parseOffset: 6, compact: (body: 128, namePack: .basic(57..<67), parms: compactParms))

        
    static func algorithms() -> [DXAlgorithm] {
      DXAlgorithm.algorithmsFromPlist("TX81Z Algorithms")
    }

//    static let bankTruss = Op4.createVoiceBankTruss(patchCount: 32, patchWerk: patchWerk)

//    open func randomize() {
//      randomizeAllParams()
//
//      let algos = Self.algorithms()
//      let algoIndex = self[[.algo]] ?? 0
//
//      let algo = algos[algoIndex]
//
//      // make output ops audible
//      for outputId in algo.outputOps {
//        let op: SynthPath = [.op, .i(outputId)]
//        self[op + [.level]] = 90+(0...9).random()!
//        self[op + [.level, .scale]] = 0
//      }
//
//      self[[.transpose]] = 24
//      self[[.porta, .time]] = 0
//      self[[.modWheel, .pitch]] = 0
//      self[[.modWheel, .amp]] = 0
//      self[[.breath, .pitch]] = 0
//      self[[.breath, .amp]] = 0
//      self[[.breath, .pitch, .bias]] = 50
//      self[[.breath, .env, .bias]] = 0
//
//
//      // flat pitch env
//      for i in 0..<3 {
//        self[[.pitch, .env, .level, .i(i)]] = 50
//      }
//
//      // all ops on
//      for op in 0..<4 { self[[.op, .i(op), .on]] = 1 }
//    }
    
    static let parms: [Parm] = [
    ] <<< [3,1,2,0].enumerated().map { i, op in
        // note the order: 4, 2, 3, 1. wacky
        .prefix([.op, .i(op)]) {
          .offset(b: i * 13) { [
            .p([.attack], 0, .max(31)),
            .p([.decay, .i(0)], 1, .max(31)),
            .p([.decay, .i(1)], 2, .max(31)),
            .p([.release], 3, .rng(1...15)),
            .p([.decay, .level], 4, .max(15)),
            .p([.level, .scale], 5, .max(99)),
            .p([.rate, .scale], 6, .max(3)),
            .p([.env, .bias, .sens], 7, .max(7)),
            .p([.amp, .mod], 8, .max(1)),
            .p([.velo], 9, .max(7)),
            .p([.level], 10, .max(99)),
            .p([.coarse], 11, .max(63)),
            .p([.detune], 12, .max(6, dispOff: -3)),
          ] }
        }
    }.reduce([], +) <<< .inc(b: 52) { [
      .p([.algo], .max(7, dispOff: 1)),
      .p([.feedback], .max(7)),
      .p([.lfo, .speed], .max(99)),
      .p([.lfo, .delay], .max(99)),
      .p([.pitch, .mod, .depth], .max(99)),
      .p([.amp, .mod, .depth], .max(99)),
      .p([.lfo, .sync], .max(1)),
      .p([.lfo, .wave], .opts(["Saw Up","Square","Triangle","S/Hold"])),
      .p([.pitch, .mod, .sens], .max(7)),
      .p([.amp, .mod, .sens], .max(3)),
      .p([.transpose], .max(48, dispOff: -24)),
      .p([.poly], .max(1)),
      .p([.bend], .max(12)),
      .p([.porta, .mode], .max(1)),
      .p([.porta, .time], .max(99)),
      .p([.foot, .volume], .max(99)),
      .p([.sustain], .max(1)),
      .p([.porta], .max(1)),
      .p([.chorus], .max(1)),
      .p([.modWheel, .pitch], .max(99)),
      .p([.modWheel, .amp], .max(99)),
      .p([.breath, .pitch], .max(99)),
      .p([.breath, .amp], .max(99)),
      .p([.breath, .pitch, .bias], .max(99, dispOff: -50)),
      .p([.breath, .env, .bias], .max(99)),
    ] } <<< .inc(b: 87) {
      .prefix([.pitch, .env]) { [
        // Pitch env is on DX21
        .p([.rate, .i(0)], .max(99)),
        .p([.rate, .i(1)], .max(99)),
        .p([.rate, .i(2)], .max(99)),
        .p([.level, .i(0)], .max(99)),
        .p([.level, .i(1)], .max(99)),
        .p([.level, .i(2)], .max(99)),
      ] }
    }

    static let compactParms: [Parm] = [
    ] <<< [3,1,2,0].enumerated().map { i, op in
      // note the order: 4, 2, 3, 1. wacky
        .prefix([.op, .i(op)]) {
          .offset(b: i * 10) { [
            .p([.attack], 0),
            .p([.decay, .i(0)], 1),
            .p([.decay, .i(1)], 2),
            .p([.release], 3),
            .p([.decay, .level], 4),
            .p([.level, .scale], 5),
            .p([.rate, .scale], 9, bits: 3...4),
            .p([.env, .bias, .sens], 6, bits: 3...5),
            .p([.amp, .mod], 6, bit: 6),
            .p([.velo], 6, bits: 0...2),
            .p([.level], 7),
            .p([.coarse], 8),
            .p([.detune], 9, bits: 0...2),
          ] }
        }
    }.reduce([], +) <<< [
      .p([.algo], 40, bits: 0...2),
      .p([.feedback], 40, bits: 3...5),
      .p([.lfo, .speed], 41),
      .p([.lfo, .delay], 42),
      .p([.pitch, .mod, .depth], 43),
      .p([.amp, .mod, .depth], 44),
      .p([.lfo, .sync], 40, bit: 6),
      .p([.lfo, .wave], 45, bits: 0...1),
      .p([.pitch, .mod, .sens], 45, bits: 4...6),
      .p([.amp, .mod, .sens], 45, bits: 2...3),
      .p([.transpose], 46),
      .p([.poly], 48, bit: 3),
      .p([.bend], 47),
      .p([.porta, .mode], 48, bit: 0),
      .p([.porta, .time], 49),
      .p([.foot, .volume], 50),
      .p([.sustain], 48, bit: 2),
      .p([.porta], 48, bit: 1),
      .p([.chorus], 48, bit: 4),
      .p([.modWheel, .pitch], 51),
      .p([.modWheel, .amp], 52),
      .p([.breath, .pitch], 53),
      .p([.breath, .amp], 54),
      .p([.breath, .pitch, .bias], 55),
      .p([.breath, .env, .bias], 56),

      // Pitch env is on DX21
      .p([.pitch, .env, .rate, .i(0)], 67),
      .p([.pitch, .env, .rate, .i(1)], 68),
      .p([.pitch, .env, .rate, .i(2)], 69),
      .p([.pitch, .env, .level, .i(0)], 70),
      .p([.pitch, .env, .level, .i(1)], 71),
      .p([.pitch, .env, .level, .i(2)], 72),
    ]
    
  }

  enum ACED {
    
    static let patchWerk = PatchWerk(synth, "aced", 23, params: parms.params(), cmdByte: 0x13, sysexData: {
      Yamaha.sysexData(channel: $1, cmdBytes: [0x7e, 0x00, 0x21], bodyBytes: "LM  8976AE".sysexBytes() + $0)
    }, parseOffset: 16, compact: (body: 128, namePack: nil, parms: compactParms))
    
  //  open func randomize() {
  //    randomizeAllParams()
  //    (0..<4).forEach {
  //      self[[.op, .i($0), .shift]] = 0
  //    }
  //  }
    
    static let parms: [Parm] = [
    ] <<< [3,1,2,0].enumerated().map { i, op in
        // note the order: 4, 2, 3, 1. wacky
        .prefix([.op, .i(op)]) {
          .offset(b: i * 5) { [
            .p([.osc, .mode], 0, .max(1)),
            .p([.fixed, .range], 1, .max(7)),
            .p([.fine], 2, .max(15)),
            .p([.wave], 3, .opts(8.map { "tx81z-wave-\($0 + 1)" })),
            .p([.shift], 4, .max(3)),
          ] }
        }
    }.reduce([], +) <<< .inc(b: 20) { [
      .p([.reverb], .max(7)),
      .p([.foot, .pitch], .max(99)),
      .p([.foot, .amp], .max(99)),
    ] }
            
    static let compactParms: [Parm] = [
    ] <<< [3,1,2,0].enumerated().map { i, op in
        .prefix([.op, .i(op)]) {
          .offset(b: 73 + (i * 2)) { [
            .p([.osc, .mode], 0, bit: 3),
            .p([.fixed, .range], 0, bits: 0...2),
            .p([.fine], 1, bits: 0...3),
            .p([.wave], 1, bits: 4...6),
            .p([.shift], 0, bits: 4...5),
          ] }
        }
    }.reduce([], +) <<< .inc(b: 81) { [
      .p([.reverb]),
      .p([.foot, .pitch]),
      .p([.foot, .amp]),
    ] }

  }
}
