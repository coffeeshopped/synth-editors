
extension XV5050 {
  
  enum Voice {
    
    const patchWerk = XV.Voice.patchWerk(common: Common.patchWerk, tone: Tone.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, initFile: "xv5050-voice-init")
    
    const bankWerk = XV.Voice.bankWerk(patchWerk)
    
    enum Common {
      const patchWerk = XV.Voice.Common.patchWerk(params)
      
      const parms: [Parm] = {
        var p: [Parm] =  [
          ['category', { b: 0x0c, opts: categoryOptions }],
          ['tone/type', { b: 0x0d, opts: ["4Tones", "Multi-Partial"] }],
          ['level', { b: 0x0e }],
          ['pan', { b: 0x0f, dispOff: -64 }],
          ['priority', { b: 0x10, opts: ["Last", "Loudest"] }],
          ['coarse', { b: 0x11, rng: [16, 112], dispOff: -64 }],
          ['fine', { b: 0x12, rng: [14, 114], dispOff: -64 }],
          ['octave/shift', { b: 0x13, rng: [61, 67], dispOff: -64 }],
          ['stretchTune', { b: 0x14, opts: ["Off","1","2","3"] }],
          ['analogFeel', { b: 0x15, max: 1 }],
          ['poly', { b: 0x16, opts: ["Mono","Poly"] }],
          ['legato', { b: 0x17, max: 1 }],
          ['legato/retrigger', { b: 0x18, max: 1 }],
          ['porta', { b: 0x19, max: 1 }],
          ['porta/mode', { b: 0x1a, opts: ["Normal", "Legato"] }],
          ['porta/type', { b: 0x1b, opts: ["Rate","Time"] }],
          ['porta/start', { b: 0x1c, opts: ["Pitch","Note"] }],
          ['porta/time', { b: 0x1d }],
          ['clock/src', { b: 0x1e, opts: ["Patch","System"] }],
          ['tempo', { b: 0x1f, packIso: XV.multiPack2(0x1f), rng: [20, 250] }],
      //    ['oneShot', { b: 0x21, max: 1 }],
          ['cutoff', { b: 0x22, rng: [1, 127], dispOff: -64 }],
          ['reson', { b: 0x23, rng: [1, 127], dispOff: -64 }],
          ['attack', { b: 0x24, rng: [1, 127], dispOff: -64 }],
          ['release', { b: 0x25, rng: [1, 127], dispOff: -64 }],
          ['velo', { b: 0x26, rng: [1, 127], dispOff: -64 }],
          ['out/assign', { b: 0x27, opts: outAssignOptions }],
          ['tone/mix', { b: 0x28, max: 1 }],
          ['bend/up', { b: 0x29, max: 48 }],
          ['bend/down', { b: 0x2a, max: 48 }],
        ]
        
        p += .prefix("mtrx/ctrl", count: 4, bx: 9, block: { index, offset in
          [
            ['src', { b: 0x2b, opts: mtrxSrcOptions }],
          ] + .prefix("dest", count: 4, bx: 2, block: { index2, offset2 in
            "p([", 0x2c, .options(mtrxDestOptions))]
          }) + .prefix("amt", count: 4, bx: 2, block: { index2, offset2 in
            "p([", 0x2d, .rng(1...127, dispOff: -64))]
          })
        })
        
        return p
      }()
      
      const params = parms.params()
      
      const categoryOptions = ["None",  "Acoust Piano (PNO)",  "Elec Piano (EP)",  "Keyboards (KEY)",  "Bell (BEL)",  "Mallet (MLT)",  "Organ (ORG)",  "Accordion (ACD)",  "Harmonica (HRM)",  "Acoust Guitar (AGT)",  "Elec Guitar (EGT)",  "Dist Guitar (DGT)",  "Bass (BS)",  "Synth Bass (SBS)",  "Strings (STR)",  "Orchestra (ORC)",  "Hit (HIT)",  "Winds (WND)",  "Flute (FLT)",  "Acoust Brass (BRS)",  "Synth Brass (SBR)",  "Sax (SAX)",  "Hard Synth Lead (HLD)",  "Soft Synth Lead (SLD)",  "Techno Synth (TEK)",  "Pulsating Synth (PLS)",  "Synth FX (FX)",  "Other Synth (SYN)",  "Bright Pad Synth (BPD)",  "Soft Pad Synth (SPD)",  "Vox (VOX)",  "Plucked (PLK)",  "Other Ethnic (ETH)",  "Fretted (FRT)",  "Percussion (PRC)",  "Sound FX (SFX)",  "Beat and Groove (BTS)",  "Drum Set (DRM)",  "Combination (CMB)"]
      
      const outAssignOptions = [
        0 : "MFX",
        1 : "A",
        2 : "B",
        5 : "1",
        6 : "2",
        7 : "3",
        8 : "4",
        13 : "Tone",
      ]

      const mtrxSrcOptions = [
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
      
      const mtrxDestOptions: [Int:String] = ["Off", "Pitch", "Cutoff", "Reson", "Level", "Pan", "Dry", "Chorus", "Reverb", "Pitch LFO1", "Pitch LFO2", "Filter LFO1", "Filter LFO2", "Amp LFO1", "Amp LFO2", "Pan LFO1", "Pan LFO2", "LFO1 Rate", "LFO2 Rate", "Pitch Attack", "Pitch Decay", "Pitch Release", "Filter Attack", "Filter Decay", "Filter Release", "Amp Attack", "Amp Decay", "Amp Release", "TMT", "FXM", "MFX Ctrl 1", "MFX Ctrl 2", "MFX Ctrl 3", "MFX Ctrl 4"]
      
    }
    
    enum Tone {
      
      const patchWerk = XV.Voice.Tone.patchWerk(params: params)
      
      const parms: [Parm] = {
        var p: [Parm] = [
          ['level', { b: 0x00 }],
          ['coarse', { b: 0x01, rng: [16, 112], dispOff: -64 }],
          ['fine', { b: 0x02, rng: [14, 114], dispOff: -64 }],
          ['random/pitch', { b: 0x03, opts: randomPitchOptions }],
          ['pan', { b: 0x04, dispOff: -64 }],
          ['pan/keyTrk', { b: 0x05, rng: [54, 74], dispOff: -64 }],
          ['pan/random', { b: 0x06, max: 63 }],
          ['pan/alt', { b: 0x07, rng: [1, 127], dispOff: -64 }],
          ['env/mode', { b: 0x08, opts: ["No-Sus","Sustain"] }],
          ['delay/mode', { b: 0x09, opts: ["Normal", "Hold", "Key Off Normal", "Key Off Decay"] }],
          ['delay/time', { b: 0x0a, packIso: XV.multiPack2(0x0a), max: 149 }],
          ['dry', { b: 0x0c }],
          ['chorus/fx', { b: 0x0d }],
          ['reverb/fx', { b: 0x0e }],
          ['chorus', { b: 0x0f }],
          ['reverb', { b: 0x10 }],
          ['out/assign', { b: 0x11, opts: outAssignOptions }],
          ['rcv/bend', { b: 0x12, max: 1 }],
          ['rcv/expression', { b: 0x13, max: 1 }],
          ['rcv/hold', { b: 0x14, max: 1 }],
          ['rcv/pan', { b: 0x15, max: 1 }],
          ['rcv/redamper', { b: 0x16, max: 1 }],
        ]
        
        p += .prefix("ctrl", count: 4, bx: 4, block: { index, offset in
          .prefix("on", count: 4, bx: 1) { index, offset in
            "p([", 0x17, .opts(["Off", "On", "Reverse"]))]
          }
        })

        p += [
          ['wave/group', { b: 0x27, opts: ["Int","SR-JV80","SRX"] }],
          ['wave/group/id', { b: 0x28, packIso: XV.multiPack4(0x28), max: 16384 }],
          ['wave/number/0', { b: 0x2c, packIso: XV.multiPack4(0x2c), opts: XV.Voice.Tone.internalWaveOptions }],
          ['wave/number/1', { b: 0x30, packIso: XV.multiPack4(0x30), opts: XV.Voice.Tone.internalWaveOptions }],
          ['wave/gain', { b: 0x34, opts: ["-6","0","+6","+12"] }],
          ['fxm/on', { b: 0x35, max: 1 }],
          ['fxm/color', { b: 0x36, max: 3, dispOff: 1 }],
          ['fxm/depth', { b: 0x37, max: 16 }],
          ['tempo/sync', { b: 0x38, max: 1 }],
          ['pitch/keyTrk', { b: 0x39, .iso(pitchKeyIso, 44...84) }],
        ] + .prefix("pitch/env") {
          [
            ['depth', { b: 0x3a, rng: [52, 76], dispOff: -64 }],
            ['velo', { b: 0x3b, rng: [1, 127], dispOff: -64 }],
            ['velo/time/0', { b: 0x3c, rng: [1, 127], dispOff: -64 }],
            ['velo/time/3', { b: 0x3d, rng: [1, 127], dispOff: -64 }],
            ['time/keyTrk', { b: 0x3e, rng: [54, 74], dispOff: -64 }],
            ['time/0', { b: 0x3f }],
            ['time/1', { b: 0x40 }],
            ['time/2', { b: 0x41 }],
            ['time/3', { b: 0x42 }],
            ['level/-1', { b: 0x43, rng: [1, 127], dispOff: -64 }],
            ['level/0', { b: 0x44, rng: [1, 127], dispOff: -64 }],
            ['level/1', { b: 0x45, rng: [1, 127], dispOff: -64 }],
            ['level/2', { b: 0x46, rng: [1, 127], dispOff: -64 }],
            ['level/3', { b: 0x47, rng: [1, 127], dispOff: -64 }],      
          ]
        } 
        p += [
          ['filter/type', { b: 0x48, opts: ["Off","LPF","BPF","HPF","PKG", "LFP2", "LPF3"] }],
          ['cutoff', { b: 0x49 }],
          ['cutoff/keyTrk', { b: 0x4a, rng: [44, 84], dispOff: -64 }],
          ['cutoff/velo/curve', { b: 0x4b, opts: veloCurveOptions }],
          ['cutoff/velo', { b: 0x4c, rng: [1, 127], dispOff: -64 }],
          ['reson', { b: 0x4d }],
          ['reson/velo', { b: 0x4e, rng: [1, 127], dispOff: -64 }],
        ] + .prefix("filter/env") {
          [
            ['depth', { b: 0x4f, rng: [1, 127], dispOff: -64 }],
            ['velo/curve', { b: 0x50, opts: veloCurveOptions }],
            ['velo', { b: 0x51, rng: [1, 127], dispOff: -64 }],
            ['velo/time/0', { b: 0x52, rng: [1, 127], dispOff: -64 }],
            ['velo/time/3', { b: 0x53, rng: [1, 127], dispOff: -64 }],
            ['time/keyTrk', { b: 0x54, rng: [54, 74], dispOff: -64 }],
            ['time/0', { b: 0x55 }],
            ['time/1', { b: 0x56 }],
            ['time/2', { b: 0x57 }],
            ['time/3', { b: 0x58 }],
            ['level/-1', { b: 0x59 }],
            ['level/0', { b: 0x5a }],
            ['level/1', { b: 0x5b }],
            ['level/2', { b: 0x5c }],
            ['level/3', { b: 0x5d }],
          ]
        } 
        
        p += [
          ['bias/level', { b: 0x5e, rng: [54, 74], dispOff: -64 }],
          ['bias/pt', { b: 0x5f }],
          ['bias/direction', { b: 0x60, opts: ["Lower","Upper","L&U","All"] }],
        ] + .prefix("amp/env") {
          [
            ['velo/curve', { b: 0x61, opts: veloCurveOptions }],
            ['velo', { b: 0x62, rng: [1, 127], dispOff: -64 }],
            ['velo/time/0', { b: 0x63, rng: [1, 127], dispOff: -64 }],
            ['velo/time/3', { b: 0x64, rng: [1, 127], dispOff: -64 }],
            ['time/keyTrk', { b: 0x65, rng: [54, 74], dispOff: -64 }],
            ['time/0', { b: 0x66 }],
            ['time/1', { b: 0x67 }],
            ['time/2', { b: 0x68 }],
            ['time/3', { b: 0x69 }],
            ['level/0', { b: 0x6a }],
            ['level/1', { b: 0x6b }],
            ['level/2', { b: 0x6c }],
          ]
        }
        
        p += .prefix("lfo", count: 2, bx: 14, block: { index, offset in
          [
            ['wave', { b: 0x6d, opts: lfoWaveOptions }],
            ['rate', { b: 0x6e, packIso: XV.multiPack2(0x6e + offset), .iso(lfoRateIso, 0...149) }],
            ['offset', { b: 0x70, opts: lfoLevelOffsetOptions }],
            ['rate/detune', { b: 0x71 }],
            ['delay', { b: 0x72 }],
            ['delay/keyTrk', { b: 0x73, rng: [54, 74], dispOff: -64 }],
            ['fade/mode', { b: 0x74, opts: lfoFadeModeOptions }],
            ['fade/time', { b: 0x75 }],
            ['key/trigger', { b: 0x76, max: 1 }],
            ['pitch', { b: 0x77, rng: [1, 127], dispOff: -64 }],
            ['filter', { b: 0x78, rng: [1, 127], dispOff: -64 }],
            ['amp', { b: 0x79, rng: [1, 127], dispOff: -64 }],
            ['pan', { b: 0x7a, rng: [1, 127], dispOff: -64 }],
          ]
        })

        return p
      }()

      const params = parms.params()

      
      const outAssignOptions = [
        0 : "MFX",
        1 : "A",
        2 : "B",
        5 : "1",
        6 : "2",
        7 : "3",
        8 : "4",
        ]
      
      const pitchKeyIso = Miso.a(-64) >>> Miso.m(10)
      
      const veloCurveOptions = (0...7).map { $0 == 0 ? "Fixed" : "\($0)" }
      
      const lfoWaveOptions = ["Sine", "Tri", "Saw Up", "Saw Down", "Square", "Random", "Bend Up", "Bend Down", "TRP", "S&H", "CHS"]
      
      const lfoLevelOffsetOptions = ["-100", "-50", "0", "+50", "+100"]
      
      const lfoFadeModeOptions = ["On In", "On Out", "Off In", "Off Out"]
      
      const lfoRateIso = Miso.switcher([
        .range(128...149, Miso.options(["1/64t", "1/64", "1/32t", "1/32", "1/16t", "1/32.", "1/16", "1/8t", "1/16.", "1/8", "1/4t", "1/8.", "1/4", "1/2t", "1/4.", "1/2", "1/1t", "1/2.", "1/1", "2/1t", "1/1.", "2/1"], startIndex: 128))
      ], default: Miso.str())
      
      const randomPitchOptions = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"]
      
      const srjvWaveGroupOptions =
        SRJVBoard.boards.dict { [$0.key + 100 : "SRJV: \($0.value.name)"] }

      const srxWaveGroupOptions =
        SRXBoard.boards.dict { [$0.key + 200 : "SRX: \($0.value.name)"] }
      
      const internalWaveGroupOptions = [
        0 : "Off",
        1 : "Internal"
      ]
      
      public const waveGroupOptions = internalWaveGroupOptions <<<
        srxWaveGroupOptions
      
    }
    
    enum ToneMix {
      
      const patchWerk = try! XV.sysexWerk.singlePatchWerk("Voice Tone Mix", params, size: 0x29, start: 0x1000, randomize: {
        ["structure/0" : 0] <<< 4.dict { [
          "tone/$0/on" : 1,
          "tone/$0/key/lo" : 0,
          "tone/$0/key/hi" : 127,
          "tone/$0/velo/lo" : 1,
          "tone/$0/velo/hi" : 127,
          "tone/$0/key/fade/lo" : 0,
          "tone/$0/key/fade/hi" : 0,
          "tone/$0/velo/fade/lo" : 0,
          "tone/$0/velo/fade/hi" : 0,
        ] }
      })
            
      const parms: [Parm] = [
        ['structure/0', { b: 0x00, opts: structureOptions }],
        ['booster/0', { b: 0x01, opts: boosterOptions }],
        ['structure/1', { b: 0x02, opts: structureOptions }],
        ['booster/1', { b: 0x03, opts: boosterOptions }],
        ['velo', { b: 0x04, opts: ["Off", "On", "Random"] }],
      ] + .prefix("tone", count: 4, bx: 9, block: { i, off in [
        ['on', { b: 0x05, max: 1 }],
        ['key/lo', { b: 0x06, .iso(noteMiso) }],
        ['key/hi', { b: 0x07, .iso(noteMiso) }],
        ['key/fade/lo', { b: 0x08 }],
        ['key/fade/hi', { b: 0x09 }],
        ['velo/lo', { b: 0x0a, rng: [1, 127] }],
        ['velo/hi', { b: 0x0b, rng: [1, 127] }],
        ['velo/fade/lo', { b: 0x0c }],
        ['velo/fade/hi', { b: 0x0d }],
      ] })
      
      const params = parms.params()
           
      const noteMiso = Miso.noteName(zeroNote: "C-1")
      const boosterOptions = ["0", "+6", "+12", "+18"]
      const structureOptions = (1...10).map { "xv-struct-\($0)" }

    }
    
  }
  
}
