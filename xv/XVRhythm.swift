
extension XV {
  
  enum Rhythm {
    
    static func patchWerk(commonOuts: [Int:String], toneOuts: [Int:String], fx: RolandSinglePatchTrussWerk, chorus: RolandSinglePatchTrussWerk, reverb: RolandSinglePatchTrussWerk) -> RolandMultiPatchTrussWerk {
      
      return sysexWerk.multiPatchWerk("Rhythm", [
        ([.common], 0x0000, Common.patchWerk(outAssignOptions: commonOuts)),
        ([.fx], 0x0200, fx),
        ([.chorus], 0x0400, chorus),
        ([.reverb], 0x0600, reverb),
      ] + 88.map {
        ([.tone, .i($0)], 0x1000 + ($0 * 0x200), Tone.patchWerk(outAssignOptions: toneOuts))
      }, start: 0x1f100000, initFile: "xv5050-rhythm-init")
    }

    static func bankWerk(_ patchWerk: RolandMultiPatchTrussWerk) -> RolandMultiBankTrussWerk {
      XV.sysexWerk.multiBankWerk(patchWerk, 4, start: 0x40000000, initFile: "xv5050-rhythm-bank-init", iso: .init(address: {
        RolandAddress([$0 << 4, 0, 0])
      }, location: {
        $0.sysexBytes(count: 4)[1] >> 4
      }))
    }

    
    enum Common {
      static func patchWerk(outAssignOptions: [Int:String]) -> RolandSinglePatchTrussWerk {
        let p = parms + [
          .p([.out, .assign], 0x11, .options(outAssignOptions)),
        ]
        return try! XV.sysexWerk.singlePatchWerk("Rhythm Common", p.params(), size: 0x12, start: 0x0000, name: .basic(0..<0x0c), randomize: { [
          [.level] : 127,
          [.out, .assign] : 13,
        ] })
      }

      static let parms: [Parm] = [
        .p([.level], 0x0c),
        .p([.clock, .src], 0x0d, .opts(["Rhythm", "System"])),
        .p([.tempo], 0x0e, packIso: XV.multiPack2(0x0e), .rng(20...250)),
        .p([.oneShot], 0x10, .max(1)),
      ]
    }
    
    enum Tone {
      
      static func patchWerk(outAssignOptions: [Int:String]) -> RolandSinglePatchTrussWerk {
        try! XV.sysexWerk.singlePatchWerk("Rhythm Tone", (parms + [
          .p([.out, .assign], 0x001b, .options(outAssignOptions)),
        ]).params(), size: 0x141, start: 0x1000, name: .basic(0..<0x0c), randomize: {
          [
            [.level] : 127,
            [.out, .assign] : (0...1).rand(),
            [.dry] : 127,
            [.coarse] : (57...71).rand(),
            [.fine] : (57...71).rand(),
            [.random, .pitch] : 0,
            [.pitch, .env, .depth] : 64,
            [.filter, .env, .depth] : (64...80).rand(),
            [.cutoff] : (40...127).rand(),
            [.cutoff, .velo] : (64...127).rand(),
            [.random, .pan] : (54...74).rand(),
            [.alt, .pan] : (54...74).rand(),
            [.amp, .env, .velo] : (54...127).rand(),
            [.amp, .env, .velo, .time, .i(0)] : 64,
            [.amp, .env, .velo, .time, .i(3)] : 64,
            [.amp, .env, .time, .i(0)] : 0,
            [.amp, .env, .time, .i(1)] : (30...40).rand(),
            [.amp, .env, .time, .i(2)] : (20...80).rand(),
            [.amp, .env, .time, .i(3)] : (0...80).rand(),
            [.amp, .env, .level, .i(0)] : 127,
            [.amp, .env, .level, .i(1)] : 127,
          ] <<< 4.dict { i in
            ([
              [.on] : i == 0 ? 1 : i == 1 ? (0...1).rand() : 0,
              [.wave, .group] : 0,
              [.wave, .group, .id] : 1,
              [.wave, .number, .i(0)] : (632...1083).rand(),
              [.wave, .number, .i(1)] : 0,
              [.coarse] : (57...71).rand(),
              [.fine] : (57...71).rand(),
              [.pan] : (54...74).rand(),
              [.level] : 127,
              [.velo, .range, .lo] : 1,
              [.velo, .range, .hi] : 127,
              [.velo, .fade, .lo] : 0,
              [.velo, .fade, .hi] : 0,
            ]).prefixed([.wave, .i(i)]) as [SynthPath:Int]
          }
        })
      }
      
      static let parms: [Parm] = {
        var p: [Parm] = [
          .p([.assign, .type], 0x000c, .max(1)),
          .p([.mute, .group], 0x000d, .max(31)),
          .p([.level], 0x000e),
          .p([.coarse], 0x000f, .rng(dispOff: -64)),
          .p([.fine], 0x0010, .rng(14...114, dispOff: -64)),
          .p([.random, .pitch], 0x0011, .opts(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"])),
          .p([.pan], 0x0012, .rng(dispOff: -64)),
          .p([.random, .pan], 0x0013, .max(63)),
          .p([.alt, .pan], 0x0014, .rng(1...127, dispOff: -64)),
          .p([.env, .mode], 0x0015, .max(1)),
          .p([.dry], 0x0016),
          .p([.chorus, .fx], 0x0017),
          .p([.reverb, .fx], 0x0018),
          .p([.chorus], 0x0019),
          .p([.reverb], 0x001a),
  //        .p([.out, .assign], 0x001b, .options(XV5050TonePatch.outAssignOptions)),
          .p([.bend], 0x001c, .max(48)),
          .p([.rcv, .expression], 0x001d, .max(1)),
          .p([.rcv, .hold], 0x001e, .max(1)),
          .p([.rcv, .pan], 0x001f, .opts(["Continuous", "Key On"])),
          .p([.wave, .velo], 0x0020, .opts(["Off","On","Random"])),
        ]
        
        p += .prefix([.pitch, .env], block: { [
          .p([.depth], 0x0115, .rng(52...76, dispOff: -64)),
          .p([.velo], 0x0116, .rng(1...127, dispOff: -64)),
          .p([.time, .i(0), .velo], 0x0117, .rng(1...127, dispOff: -64)),
          .p([.time, .i(3), .velo], 0x0118, .rng(1...127, dispOff: -64)),
          .p([.time, .i(0)], 0x0119),
          .p([.time, .i(1)], 0x011a),
          .p([.time, .i(2)], 0x011b),
          .p([.time, .i(3)], 0x011c),
          .p([.level, .i(-1)], 0x011d),
          .p([.level, .i(0)], 0x011e, .rng(1...127, dispOff: -64)),
          .p([.level, .i(1)], 0x011f, .rng(1...127, dispOff: -64)),
          .p([.level, .i(2)], 0x0120, .rng(1...127, dispOff: -64)),
          .p([.level, .i(3)], 0x0121, .rng(1...127, dispOff: -64)),
        ] })
        
        p += [
          .p([.filter, .type], 0x0122, .opts(["Off", "Lo-Pass", "Bandpass", "Hi-Pass", "Peaking", "LPF2", "LPF3"])),
          .p([.cutoff], 0x0123),
          .p([.cutoff, .velo, .curve], 0x0124),
          .p([.cutoff, .velo], 0x0125, .rng(1...127, dispOff: -64)),
          .p([.reson], 0x0126),
          .p([.reson, .velo], 0x0127, .rng(1...127, dispOff: -64)),
        ] + .prefix([.filter, .env], block: { [
          .p([.depth], 0x0128, .rng(1...127, dispOff: -64)),
          .p([.velo, .curve], 0x0129),
          .p([.velo], 0x012a, .rng(1...127, dispOff: -64)),
          .p([.time, .i(0), .velo], 0x012b, .rng(1...127, dispOff: -64)),
          .p([.time, .i(3), .velo], 0x012c, .rng(1...127, dispOff: -64)),
          .p([.time, .i(0)], 0x012d),
          .p([.time, .i(1)], 0x012e),
          .p([.time, .i(2)], 0x012f),
          .p([.time, .i(3)], 0x0130),
          .p([.level, .i(-1)], 0x0131),
          .p([.level, .i(0)], 0x0132),
          .p([.level, .i(1)], 0x0133),
          .p([.level, .i(2)], 0x0134),
          .p([.level, .i(3)], 0x0135),
        ] })
        
        p += [
          .p([.level, .velo, .curve], 0x0136),
        ] + .prefix([.amp, .env], block: { [
          .p([.velo], 0x0137, .rng(1...127, dispOff: -64)),
          .p([.time, .i(0), .velo], 0x0138, .rng(1...127, dispOff: -64)),
          .p([.time, .i(3), .velo], 0x0139, .rng(1...127, dispOff: -64)),
          .p([.time, .i(0)], 0x013a),
          .p([.time, .i(1)], 0x013b),
          .p([.time, .i(2)], 0x013c),
          .p([.time, .i(3)], 0x013d),
          .p([.level, .i(0)], 0x013e),
          .p([.level, .i(1)], 0x013f),
          .p([.level, .i(2)], 0x0140),
        ] })
        
        p += .prefix([.wave], count: 4, bx: (0x3e - 0x21), block: { i, off in [
          .p([.on], 0x21, .max(1)),
          .p([.wave, .group], 0x22, .opts(["Int","SR-JV80","SRX"])),
          .p([.wave, .group, .id], 0x23, packIso: XV.multiPack4(0x23 + off), .max(16384)),
          .p([.wave, .number, .i(0)], 0x27, packIso: XV.multiPack4(0x27 + off), .options(XV.Voice.Tone.internalWaveOptions)),
          .p([.wave, .number, .i(1)], 0x2b, packIso: XV.multiPack4(0x2b + off), .options(XV.Voice.Tone.internalWaveOptions)),
          .p([.wave, .gain], 0x2f, .opts(["-6db", "0dB", "6dB", "12dB"])),
          .p([.fxm, .on], 0x30, .max(1)),
          .p([.fxm, .color], 0x31, .max(3, dispOff: 1)),
          .p([.fxm, .depth], 0x32, .max(16)),
          .p([.tempo, .sync], 0x33, .max(1)),
          .p([.coarse], 0x34, .rng(16...112, dispOff: -64)),
          .p([.fine], 0x35, .rng(14...114, dispOff: -64)),
          .p([.pan], 0x36, .rng(dispOff: -64)),
          .p([.random, .pan], 0x37, .max(1)),
          .p([.alt, .pan], 0x38, .opts(["Off", "On", "Reverse"])),
          .p([.level], 0x39),
          .p([.velo, .range, .lo], 0x3a, .rng(1...127)),
          .p([.velo, .range, .hi], 0x3b, .rng(1...127)),
          .p([.velo, .fade, .lo], 0x3c),
          .p([.velo, .fade, .hi], 0x3d),
        ] })
        
        return p

      }()
      
      static let params = parms.params()
    
    }
  }
  
}
