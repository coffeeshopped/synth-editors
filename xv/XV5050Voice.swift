
extension XV5050 {
  
  enum Voice {
    
    static let patchWerk = XV.Voice.patchWerk(common: Common.patchWerk, tone: Tone.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, initFile: "xv5050-voice-init")
    
    static let bankWerk = XV.Voice.bankWerk(patchWerk)
    
    enum Common {
      static let patchWerk = XV.Voice.Common.patchWerk(params)
      
      static let parms: [Parm] = {
        var p: [Parm] =  [
          .p([.category], 0x0c, .opts(categoryOptions)),
          .p([.tone, .type], 0x0d, .opts(["4Tones", "Multi-Partial"])),
          .p([.level], 0x0e),
          .p([.pan], 0x0f, .rng(dispOff: -64)),
          .p([.priority], 0x10, .opts(["Last", "Loudest"])),
          .p([.coarse], 0x11, .rng(16...112, dispOff: -64)),
          .p([.fine], 0x12, .rng(14...114, dispOff: -64)),
          .p([.octave, .shift], 0x13, .rng(61...67, dispOff: -64)),
          .p([.stretchTune], 0x14, .opts(["Off","1","2","3"])),
          .p([.analogFeel], 0x15, .max(1)),
          .p([.poly], 0x16, .opts(["Mono","Poly"])),
          .p([.legato], 0x17, .max(1)),
          .p([.legato, .retrigger], 0x18, .max(1)),
          .p([.porta], 0x19, .max(1)),
          .p([.porta, .mode], 0x1a, .opts(["Normal", "Legato"])),
          .p([.porta, .type], 0x1b, .opts(["Rate","Time"])),
          .p([.porta, .start], 0x1c, .opts(["Pitch","Note"])),
          .p([.porta, .time], 0x1d),
          .p([.clock, .src], 0x1e, .opts(["Patch","System"])),
          .p([.tempo], 0x1f, packIso: XV.multiPack2(0x1f), .rng(20...250)),
      //    .p([.oneShot], 0x21, .max(1)),
          .p([.cutoff], 0x22, .rng(1...127, dispOff: -64)),
          .p([.reson], 0x23, .rng(1...127, dispOff: -64)),
          .p([.attack], 0x24, .rng(1...127, dispOff: -64)),
          .p([.release], 0x25, .rng(1...127, dispOff: -64)),
          .p([.velo], 0x26, .rng(1...127, dispOff: -64)),
          .p([.out, .assign], 0x27, .options(outAssignOptions)),
          .p([.tone, .mix], 0x28, .max(1)),
          .p([.bend, .up], 0x29, .max(48)),
          .p([.bend, .down], 0x2a, .max(48)),
        ]
        
        p += .prefix([.mtrx, .ctrl], count: 4, bx: 9, block: { index, offset in
          [
            .p([.src], 0x2b, .options(mtrxSrcOptions)),
          ] + .prefix([.dest], count: 4, bx: 2, block: { index2, offset2 in
            [.p([], 0x2c, .options(mtrxDestOptions))]
          }) + .prefix([.amt], count: 4, bx: 2, block: { index2, offset2 in
            [.p([], 0x2d, .rng(1...127, dispOff: -64))]
          })
        })
        
        return p
      }()
      
      static let params = parms.params()
      
      static let categoryOptions = ["None",  "Acoust Piano (PNO)",  "Elec Piano (EP)",  "Keyboards (KEY)",  "Bell (BEL)",  "Mallet (MLT)",  "Organ (ORG)",  "Accordion (ACD)",  "Harmonica (HRM)",  "Acoust Guitar (AGT)",  "Elec Guitar (EGT)",  "Dist Guitar (DGT)",  "Bass (BS)",  "Synth Bass (SBS)",  "Strings (STR)",  "Orchestra (ORC)",  "Hit (HIT)",  "Winds (WND)",  "Flute (FLT)",  "Acoust Brass (BRS)",  "Synth Brass (SBR)",  "Sax (SAX)",  "Hard Synth Lead (HLD)",  "Soft Synth Lead (SLD)",  "Techno Synth (TEK)",  "Pulsating Synth (PLS)",  "Synth FX (FX)",  "Other Synth (SYN)",  "Bright Pad Synth (BPD)",  "Soft Pad Synth (SPD)",  "Vox (VOX)",  "Plucked (PLK)",  "Other Ethnic (ETH)",  "Fretted (FRT)",  "Percussion (PRC)",  "Sound FX (SFX)",  "Beat and Groove (BTS)",  "Drum Set (DRM)",  "Combination (CMB)"]
      
      static let outAssignOptions = [
        0 : "MFX",
        1 : "A",
        2 : "B",
        5 : "1",
        6 : "2",
        7 : "3",
        8 : "4",
        13 : "Tone",
      ]

      static let mtrxSrcOptions = [
          0 : "Off",
          96 : "Bend",
          97 : "Aftertouch",
          98 : "System 1",
          99 : "System 2",
          100 : "System 3",
          101 : "System 4",
          102 : "Velocity",
          103 : "Keyfollow",
          104 : "Tempo",
          105 : "LFO1",
          106 : "LFO2",
          107 : "Pitch Env",
          108 : "Filter Env",
          109 : "Amp Env",
        ]
        <<< (1...31).dict { [$0 : "CC \($0)"] }
        <<< (33...95).dict { [$0 : "CC \($0)"] }
      
      static let mtrxDestOptions: [Int:String] = ["Off", "Pitch", "Cutoff", "Reson", "Level", "Pan", "Dry", "Chorus", "Reverb", "Pitch LFO1", "Pitch LFO2", "Filter LFO1", "Filter LFO2", "Amp LFO1", "Amp LFO2", "Pan LFO1", "Pan LFO2", "LFO1 Rate", "LFO2 Rate", "Pitch Attack", "Pitch Decay", "Pitch Release", "Filter Attack", "Filter Decay", "Filter Release", "Amp Attack", "Amp Decay", "Amp Release", "TMT", "FXM", "MFX Ctrl 1", "MFX Ctrl 2", "MFX Ctrl 3", "MFX Ctrl 4"]
      
    }
    
    enum Tone {
      
      static let patchWerk = XV.Voice.Tone.patchWerk(params: params)
      
      static let parms: [Parm] = {
        var p: [Parm] = [
          .p([.level], 0x00),
          .p([.coarse], 0x01, .rng(16...112, dispOff: -64)),
          .p([.fine], 0x02, .rng(14...114, dispOff: -64)),
          .p([.random, .pitch], 0x03, .opts(randomPitchOptions)),
          .p([.pan], 0x04, .rng(dispOff: -64)),
          .p([.pan, .keyTrk], 0x05, .rng(54...74, dispOff: -64)),
          .p([.pan, .random], 0x06, .max(63)),
          .p([.pan, .alt], 0x07, .rng(1...127, dispOff: -64)),
          .p([.env, .mode], 0x08, .opts(["No-Sus","Sustain"])),
          .p([.delay, .mode], 0x09, .opts(["Normal", "Hold", "Key Off Normal", "Key Off Decay"])),
          .p([.delay, .time], 0x0a, packIso: XV.multiPack2(0x0a), .max(149)),
          .p([.dry], 0x0c),
          .p([.chorus, .fx], 0x0d),
          .p([.reverb, .fx], 0x0e),
          .p([.chorus], 0x0f),
          .p([.reverb], 0x10),
          .p([.out, .assign], 0x11, .options(outAssignOptions)),
          .p([.rcv, .bend], 0x12, .max(1)),
          .p([.rcv, .expression], 0x13, .max(1)),
          .p([.rcv, .hold], 0x14, .max(1)),
          .p([.rcv, .pan], 0x15, .max(1)),
          .p([.rcv, .redamper], 0x16, .max(1)),
        ]
        
        p += .prefix([.ctrl], count: 4, bx: 4, block: { index, offset in
          .prefix([.on], count: 4, bx: 1) { index, offset in
            [.p([], 0x17, .opts(["Off", "On", "Reverse"]))]
          }
        })

        p += [
          .p([.wave, .group], 0x27, .opts(["Int","SR-JV80","SRX"])),
          .p([.wave, .group, .id], 0x28, packIso: XV.multiPack4(0x28), .max(16384)),
          .p([.wave, .number, .i(0)], 0x2c, packIso: XV.multiPack4(0x2c), .options(XV.Voice.Tone.internalWaveOptions)),
          .p([.wave, .number, .i(1)], 0x30, packIso: XV.multiPack4(0x30), .options(XV.Voice.Tone.internalWaveOptions)),
          .p([.wave, .gain], 0x34, .opts(["-6","0","+6","+12"])),
          .p([.fxm, .on], 0x35, .max(1)),
          .p([.fxm, .color], 0x36, .max(3, dispOff: 1)),
          .p([.fxm, .depth], 0x37, .max(16)),
          .p([.tempo, .sync], 0x38, .max(1)),
          .p([.pitch, .keyTrk], 0x39, .iso(pitchKeyIso, 44...84)),
        ] + .prefix([.pitch, .env]) {
          [
            .p([.depth], 0x3a, .rng(52...76, dispOff: -64)),
            .p([.velo], 0x3b, .rng(1...127, dispOff: -64)),
            .p([.velo, .time, .i(0)], 0x3c, .rng(1...127, dispOff: -64)),
            .p([.velo, .time, .i(3)], 0x3d, .rng(1...127, dispOff: -64)),
            .p([.time, .keyTrk], 0x3e, .rng(54...74, dispOff: -64)),
            .p([.time, .i(0)], 0x3f),
            .p([.time, .i(1)], 0x40),
            .p([.time, .i(2)], 0x41),
            .p([.time, .i(3)], 0x42),
            .p([.level, .i(-1)], 0x43, .rng(1...127, dispOff: -64)),
            .p([.level, .i(0)], 0x44, .rng(1...127, dispOff: -64)),
            .p([.level, .i(1)], 0x45, .rng(1...127, dispOff: -64)),
            .p([.level, .i(2)], 0x46, .rng(1...127, dispOff: -64)),
            .p([.level, .i(3)], 0x47, .rng(1...127, dispOff: -64)),      
          ]
        } 
        p += [
          .p([.filter, .type], 0x48, .opts(["Off","LPF","BPF","HPF","PKG", "LFP2", "LPF3"])),
          .p([.cutoff], 0x49),
          .p([.cutoff, .keyTrk], 0x4a, .rng(44...84, dispOff: -64)),
          .p([.cutoff, .velo, .curve], 0x4b, .opts(veloCurveOptions)),
          .p([.cutoff, .velo], 0x4c, .rng(1...127, dispOff: -64)),
          .p([.reson], 0x4d),
          .p([.reson, .velo], 0x4e, .rng(1...127, dispOff: -64)),
        ] + .prefix([.filter, .env]) {
          [
            .p([.depth], 0x4f, .rng(1...127, dispOff: -64)),
            .p([.velo, .curve], 0x50, .opts(veloCurveOptions)),
            .p([.velo], 0x51, .rng(1...127, dispOff: -64)),
            .p([.velo, .time, .i(0)], 0x52, .rng(1...127, dispOff: -64)),
            .p([.velo, .time, .i(3)], 0x53, .rng(1...127, dispOff: -64)),
            .p([.time, .keyTrk], 0x54, .rng(54...74, dispOff: -64)),
            .p([.time, .i(0)], 0x55),
            .p([.time, .i(1)], 0x56),
            .p([.time, .i(2)], 0x57),
            .p([.time, .i(3)], 0x58),
            .p([.level, .i(-1)], 0x59),
            .p([.level, .i(0)], 0x5a),
            .p([.level, .i(1)], 0x5b),
            .p([.level, .i(2)], 0x5c),
            .p([.level, .i(3)], 0x5d),
          ]
        } 
        
        p += [
          .p([.bias, .level], 0x5e, .rng(54...74, dispOff: -64)),
          .p([.bias, .pt], 0x5f),
          .p([.bias, .direction], 0x60, .opts(["Lower","Upper","L&U","All"])),
        ] + .prefix([.amp, .env]) {
          [
            .p([.velo, .curve], 0x61, .opts(veloCurveOptions)),
            .p([.velo], 0x62, .rng(1...127, dispOff: -64)),
            .p([.velo, .time, .i(0)], 0x63, .rng(1...127, dispOff: -64)),
            .p([.velo, .time, .i(3)], 0x64, .rng(1...127, dispOff: -64)),
            .p([.time, .keyTrk], 0x65, .rng(54...74, dispOff: -64)),
            .p([.time, .i(0)], 0x66),
            .p([.time, .i(1)], 0x67),
            .p([.time, .i(2)], 0x68),
            .p([.time, .i(3)], 0x69),
            .p([.level, .i(0)], 0x6a),
            .p([.level, .i(1)], 0x6b),
            .p([.level, .i(2)], 0x6c),
          ]
        }
        
        p += .prefix([.lfo], count: 2, bx: 14, block: { index, offset in
          [
            .p([.wave], 0x6d, .opts(lfoWaveOptions)),
            .p([.rate], 0x6e, packIso: XV.multiPack2(0x6e + offset), .iso(lfoRateIso, 0...149)),
            .p([.offset], 0x70, .opts(lfoLevelOffsetOptions)),
            .p([.rate, .detune], 0x71),
            .p([.delay], 0x72),
            .p([.delay, .keyTrk], 0x73, .rng(54...74, dispOff: -64)),
            .p([.fade, .mode], 0x74, .opts(lfoFadeModeOptions)),
            .p([.fade, .time], 0x75),
            .p([.key, .trigger], 0x76, .max(1)),
            .p([.pitch], 0x77, .rng(1...127, dispOff: -64)),
            .p([.filter], 0x78, .rng(1...127, dispOff: -64)),
            .p([.amp], 0x79, .rng(1...127, dispOff: -64)),
            .p([.pan], 0x7a, .rng(1...127, dispOff: -64)),
          ]
        })

        return p
      }()

      static let params = parms.params()

      
      static let outAssignOptions = [
        0 : "MFX",
        1 : "A",
        2 : "B",
        5 : "1",
        6 : "2",
        7 : "3",
        8 : "4",
        ]
      
      static let pitchKeyIso = Miso.a(-64) >>> Miso.m(10)
      
      static let veloCurveOptions = (0...7).map { $0 == 0 ? "Fixed" : "\($0)" }
      
      static let lfoWaveOptions = ["Sine", "Tri", "Saw Up", "Saw Down", "Square", "Random", "Bend Up", "Bend Down", "TRP", "S&H", "CHS"]
      
      static let lfoLevelOffsetOptions = ["-100", "-50", "0", "+50", "+100"]
      
      static let lfoFadeModeOptions = ["On In", "On Out", "Off In", "Off Out"]
      
      static let lfoRateIso = Miso.switcher([
        .range(128...149, Miso.options(["1/64t", "1/64", "1/32t", "1/32", "1/16t", "1/32.", "1/16", "1/8t", "1/16.", "1/8", "1/4t", "1/8.", "1/4", "1/2t", "1/4.", "1/2", "1/1t", "1/2.", "1/1", "2/1t", "1/1.", "2/1"], startIndex: 128))
      ], default: Miso.str())
      
      static let randomPitchOptions = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"]
      
      static let srjvWaveGroupOptions =
        SRJVBoard.boards.dict { [$0.key + 100 : "SRJV: \($0.value.name)"] }

      static let srxWaveGroupOptions =
        SRXBoard.boards.dict { [$0.key + 200 : "SRX: \($0.value.name)"] }
      
      static let internalWaveGroupOptions = [
        0 : "Off",
        1 : "Internal"
      ]
      
      public static let waveGroupOptions = internalWaveGroupOptions <<<
        srxWaveGroupOptions
      
    }
    
    enum ToneMix {
      
      static let patchWerk = try! XV.sysexWerk.singlePatchWerk("Voice Tone Mix", params, size: 0x29, start: 0x1000, randomize: {
        [[.structure, .i(0)] : 0] <<< 4.dict { [
          [.tone, .i($0), .on] : 1,
          [.tone, .i($0), .key, .lo] : 0,
          [.tone, .i($0), .key, .hi] : 127,
          [.tone, .i($0), .velo, .lo] : 1,
          [.tone, .i($0), .velo, .hi] : 127,
          [.tone, .i($0), .key, .fade, .lo] : 0,
          [.tone, .i($0), .key, .fade, .hi] : 0,
          [.tone, .i($0), .velo, .fade, .lo] : 0,
          [.tone, .i($0), .velo, .fade, .hi] : 0,
        ] }
      })
            
      static let parms: [Parm] = [
        .p([.structure, .i(0)], 0x00, .opts(structureOptions)),
        .p([.booster, .i(0)], 0x01, .opts(boosterOptions)),
        .p([.structure, .i(1)], 0x02, .opts(structureOptions)),
        .p([.booster, .i(1)], 0x03, .opts(boosterOptions)),
        .p([.velo], 0x04, .opts(["Off", "On", "Random"])),
      ] + .prefix([.tone], count: 4, bx: 9, block: { i, off in [
        .p([.on], 0x05, .max(1)),
        .p([.key, .lo], 0x06, .iso(noteMiso)),
        .p([.key, .hi], 0x07, .iso(noteMiso)),
        .p([.key, .fade, .lo], 0x08),
        .p([.key, .fade, .hi], 0x09),
        .p([.velo, .lo], 0x0a, .rng(1...127)),
        .p([.velo, .hi], 0x0b, .rng(1...127)),
        .p([.velo, .fade, .lo], 0x0c),
        .p([.velo, .fade, .hi], 0x0d),
      ] })
      
      static let params = parms.params()
           
      static let noteMiso = Miso.noteName(zeroNote: "C-1")
      static let boosterOptions = ["0", "+6", "+12", "+18"]
      static let structureOptions = (1...10).map { "xv-struct-\($0)" }

    }
    
  }
  
}
