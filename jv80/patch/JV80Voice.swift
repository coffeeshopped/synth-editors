
extension JV80 {
  
  enum Voice {

    static let patchWerk = JV8X.Voice.patchWerk(tone: Tone.patchWerk)

    static let bankWerk = JV8X.Voice.bankWerk(patchWerk)
    
//      override class func startAddress(_ path: SynthPath?) -> RolandAddress {
//        return (path?.endex ?? 0) == 0 ? 0x01402000 : 0x02402000
//      }

//    static func location(forData data: Data) -> Int {
//      return Int(addressBytes(forSysex: data)[1]) - 0x40
//    }
    
    enum Common {
      
      static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Voice Common", parms.params(), size: 0x22, start: 0x0000, name: .basic(0..<0x0c), randomize: { [
        [.level] : 127,
        [.pan] : 64,
      ] })

      static let parms: [Parm] = [
        .p([.velo], 0x0c, .max(1)),
        .p([.reverb, .type], 0x0d, .opts(reverbTypeOptions)),
        .p([.reverb, .level], 0x0e),
        .p([.reverb, .time], 0x0f),
        .p([.reverb, .feedback], 0x10),
        .p([.chorus, .type], 0x11, .opts(chorusTypeOptions)),
        .p([.chorus, .level], 0x12),
        .p([.chorus, .depth], 0x13),
        .p([.chorus, .rate], 0x14),
        .p([.chorus, .feedback], 0x15),
        .p([.chorus, .out, .assign], 0x16, .opts(chorusOutOptions)),
        .p([.analogFeel], 0x17),
        .p([.level], 0x18),
        .p([.pan], 0x19, .rng(dispOff: -64)),
        .p([.bend, .down], 0x1a, .rng(16...64, dispOff: -64)),
        .p([.bend, .up], 0x1b, .max(12)),
        .p([.mono], 0x1c, .max(1)),
        .p([.legato], 0x1d, .max(1)),
        .p([.porta], 0x1e, .max(1)),
        .p([.porta, .legato], 0x1f, .opts(["Legato","Normal"])),
        .p([.porta, .type], 0x20, .opts(["Time","Rate"])),
        .p([.porta, .time], 0x21),
      ]
                  
      static let chorusTypeOptions = ["Chorus 1", "Chorus 2", "Chorus 3"]
      static let chorusOutOptions = ["Mix", "Reverb"]
      static let reverbTypeOptions = ["Room 1","Room 2","Stage 1","Stage 2","Hall 1","Hall 2","Delay","Pan Delay"]
    }

    enum Tone {
      
      static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Voice Tone", parms.params(), size: 0x73, start: 0x0800, randomize: { [
        [.on] : 1,
        [.wave, .group] : 0,
        [.delay, .mode] : 0,
        [.delay, .time] : 0,
        [.tone, .level] : 127,
        [.pan] : 64,
        [.random, .pitch] : 0,
        [.pitch, .keyTrk] : 12,
        [.pitch, .env, .depth] : 64,
        [.velo, .range, .lo] : 1,
        [.velo, .range, .hi] : 127,
      ] })
      
//      static func isValid(fileSize: Int) -> Bool {
//        return fileSize == fileDataCount || fileSize == fileDataCount + 1 // allow for JV-880 patches
//      }

      static let parms: [Parm] = {
        var p: [Parm] = [
          .p([.wave, .group], 0x00, .opts(["Int","Exp","PCM"])),
          .p([.wave, .number], 0x01, packIso: JV8X.multiPack(0x01), .options(waveOptions)),
          .p([.on], 0x03, .max(1)),
          .p([.fxm, .on], 0x04, .max(1)),
          .p([.fxm, .depth], 0x05, .max(15, dispOff: 1)),
          .p([.velo, .range, .lo], 0x06),
          .p([.velo, .range, .hi], 0x07),
          .p([.volume, .ctrl], 0x08, .max(1)),
          .p([.hold, .ctrl], 0x09, .max(1)),
        ] 
        p += .prefixes([[.mod], [.aftertouch], [.expression]], bx: 8, block: { path in
            .prefix([.dest], count: 4, bx: 2, block: { index, offset in
              [.p([], 0x0a, .options(controlDestinationOptions))]
            })
            + .prefix([.depth], count: 4, bx: 2, block: { index, offset in
              [.p([], 0x0b, .rng(1...127, dispOff: -64))]
            })
        })
        p += .prefix([.lfo], count: 2, bx: 11, block: { index, offset in
          [
            .p([.wave], 0x22, .options(lfoWaveOptions)),
            .p([.level, .offset], 0x23, .options(lfoLevelOffsetOptions)),
            .p([.key, .trigger], 0x24, .max(1)),
            .p([.rate], 0x25),
            .p([.delay], 0x26, packIso: JV8X.multiPack(0x26 + offset), .max(128)),
            .p([.fade, .mode], 0x28, .opts(["In","Out"])),
            .p([.fade, .time], 0x29),
            .p([.pitch], 0x2a, .rng(4...124, dispOff: -64)),
            .p([.filter], 0x2b, .rng(1...127, dispOff: -64)),
            .p([.amp], 0x2c, .rng(1...127, dispOff: -64)),
          ]
        }) 
        p += [
          .p([.coarse], 0x38, .rng(16...112, dispOff: -64)),
          .p([.fine], 0x39, .rng(14...114, dispOff: -64)),
          .p([.random, .pitch], 0x3a, .options(randomPitchOptions)),
          .p([.pitch, .keyTrk], 0x3b, .options(pitchKeyfollowOptions)),
          .p([.pitch, .env, .velo, .sens], 0x3c, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .velo, .time, .i(0)], 0x3d, .options(veloTSensOptions)),
          .p([.pitch, .env, .velo, .time, .i(3)], 0x3e, .options(veloTSensOptions)),
          .p([.pitch, .env, .time, .keyTrk], 0x3f, .options(veloTSensOptions)),
          .p([.pitch, .env, .depth], 0x40, .rng(52...76, dispOff: -64)),
          .p([.pitch, .env, .time, .i(0)], 0x41),
          .p([.pitch, .env, .level, .i(0)], 0x42, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .time, .i(1)], 0x43),
          .p([.pitch, .env, .level, .i(1)], 0x44, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .time, .i(2)], 0x45),
          .p([.pitch, .env, .level, .i(2)], 0x46, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .time, .i(3)], 0x47),
          .p([.pitch, .env, .level, .i(3)], 0x48, .rng(1...127, dispOff: -64)),

          .p([.filter, .type], 0x49, .opts(["Off","LPF","HPF"])),
          .p([.cutoff], 0x4a),
          .p([.reson], 0x4b),
          .p([.reson, .mode], 0x4c, .opts(["Soft", "Hard"])),
          .p([.cutoff, .keyTrk], 0x4d, .options(pitchKeyfollowOptions)),
          .p([.filter, .env, .velo, .curve], 0x4e, .max(6, dispOff: 1)),
          .p([.filter, .env, .velo, .sens], 0x4f, .rng(1...127, dispOff: -64)),
          .p([.filter, .env, .velo, .time, .i(0)], 0x50, .options(veloTSensOptions)),
          .p([.filter, .env, .velo, .time, .i(3)], 0x51, .options(veloTSensOptions)),
          .p([.filter, .env, .time, .keyTrk], 0x52, .options(veloTSensOptions)),
          .p([.filter, .env, .depth], 0x53, .rng(1...127, dispOff: -64)),
          .p([.filter, .env, .time, .i(0)], 0x54),
          .p([.filter, .env, .level, .i(0)], 0x55),
          .p([.filter, .env, .time, .i(1)], 0x56),
          .p([.filter, .env, .level, .i(1)], 0x57),
          .p([.filter, .env, .time, .i(2)], 0x58),
          .p([.filter, .env, .level, .i(2)], 0x59),
          .p([.filter, .env, .time, .i(3)], 0x5a),
          .p([.filter, .env, .level, .i(3)], 0x5b),

          .p([.tone, .level], 0x5c),
          .p([.bias, .level], 0x5d, .options(veloTSensOptions)),
          .p([.pan], 0x5e, packIso: JV8X.multiPack(0x5e), .max(128, dispOff: -64)),
          .p([.pan, .keyTrk], 0x60, .options(veloTSensOptions)),
          .p([.delay, .mode], 0x61, .opts(["Normal","Hold","Play-mate"])),
          .p([.delay, .time], 0x62, packIso: JV8X.multiPack(0x62), .max(128)),
          .p([.amp, .env, .velo, .curve], 0x64, .max(6, dispOff: 1)),
          .p([.amp, .env, .velo, .sens], 0x65, .rng(1...127, dispOff: -64)),
          .p([.amp, .env, .velo, .time, .i(0)], 0x66, .options(veloTSensOptions)),
          .p([.amp, .env, .velo, .time, .i(3)], 0x67, .options(veloTSensOptions)),
          .p([.amp, .env, .time, .keyTrk], 0x68, .options(veloTSensOptions)),
          .p([.amp, .env, .time, .i(0)], 0x69),
          .p([.amp, .env, .level, .i(0)], 0x6a),
          .p([.amp, .env, .time, .i(1)], 0x6b),
          .p([.amp, .env, .level, .i(1)], 0x6c),
          .p([.amp, .env, .time, .i(2)], 0x6d),
          .p([.amp, .env, .level, .i(2)], 0x6e),
          .p([.amp, .env, .time, .i(3)], 0x6f),

          .p([.out, .level], 0x70),
          .p([.reverb], 0x71),
          .p([.chorus], 0x72),
        ]
        return p
      }()
      
      static let controlDestinationOptions = OptionsParam.makeOptions(["Off", "Pitch", "Cutoff", "Resonance", "Level", "Pitch L1", "Pitch L2", "Filter L1", "Filter L2", "Amp L1", "Amp L2", "LFO1 Rate", "LFO2 Rate"])
      
      static let lfoWaveOptions = OptionsParam.makeOptions(["Tri", "Sine", "Saw", "Square", "RND1", "RND2"])
      
      static let lfoLevelOffsetOptions = OptionsParam.makeOptions(["-100", "-50", "0", "+50", "+100"])
      
      static let randomPitchOptions = OptionsParam.makeOptions(["0", "5", "10", "20", "30", "40", "50", "70", "100", "200", "300", "400", "500", "600", "800", "1200"])
      
      static let pitchKeyfollowOptions = OptionsParam.makeOptions(["-100", "-70", "-50", "-30", "-10", "0", "10", "20", "30", "40", "50", "70", "100", "120", "150", "200"])
      
      static let veloTSensOptions = OptionsParam.makeOptions(["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"])
      
      static let blankWaveOptions = OptionsParam.makeOptions((1...255).map { "\($0)" })
      
      static let waveOptions = OptionsParam.makeOptions(["1: Ac Piano 1", "2: SA Rhodes 1", "3: SA Rhodes 2", "4: E.Piano 1", "5: E.Piano 2", "6: Clav 1", "7: Organ 1", "8: Jazz Organ", "9: Pipe Organ", "10: Nylon GTR", "11: 6STR GTR", "12: GTR HARM", "13: Mute GTR 1", "14: Pop Strat", "15: Stratus", "16: SYN GTR", "17: Harp 1", "18: SYN Bass", "19: Pick Bass", "20: E.Bass", "21: Fretless 1", "22: Upright BS", "23: Slap Bass 1", "24: Slap & Pop", "25: Slap Bass 2", "26: Slap Bass 3", "27: Flute 1", "28: Trumpet 1", "29: Trombone 1", "30: Harmon Mute1", "31: Alto Sax 1", "32: Tenor Sax 1", "33: French 1", "34: Blow Pipe", "35: Bottle", "36: Trumpet SECT", "37: ST.Strings-A", "38: ST.Strings-L", "39: Mono Strings", "40: Pizz", "41: SYN VOX 1", "42: SYN VOX 2", "43: Male Ooh", "44: ORG VOX", "45: VOX Noise", "46: Soft Pad", "47: JP Strings", "48: Pop Voice", "49: Fine Wine", "50: Fantasynth", "51: Fanta Bell", "52: ORG Bell", "53: Agogo", "54: Bottle Hit", "55: Vibes", "56: Marimba wave", "57: Log Drum", "58: DIGI Bell 1", "59: DIGI Chime", "60: Steel Drums", "61: MMM VOX", "62: Spark VOX", "63: Wave Scan", "64: Wire String", "65: Lead Wave", "66: Synth Saw 1", "67: Synth Saw 2", "68: Synth Saw 3", "69: Synth Square", "70: Synth Pulse1", "71: Synth Pulse2", "72: Triangle", "73: Sine", "74: ORG Click", "75: White Noise", "76: Wind Agogo", "77: Metal Wind", "78: Feedbackwave", "79: Anklungs", "80: Wind Chimes", "81: Rattles", "82: Tin Wave", "83: Spectrum 1", "84: 808 SNR 1", "85: 90's Snare", "86: Piccolo SN", "87: LA Snare", "88: Whack Snare", "89: Rim Shot", "90: Bright Kick", "91: Verb Kick", "92: Round Kick", "93: 808 Kick", "94: Closed HAT 1", "95: Closed HAT 2", "96: Open HAT 1", "97: Crash 1", "98: Ride 1", "99: Ride Bell 1", "100: Power Tom Hi", "101: Power Tom Lo", "102: Cross Stick1", "103: 808 Claps", "104: Cowbell 1", "105: Tambourine", "106: Timbale", "107: CGA Mute Hi", "108: CGA Mute Lo", "109: CGA Slap", "110: Conga Hi", "111: Conga Lo", "112: Maracas", "113: Cabasa Cut", "114: Cabasa Up", "115: Cabasa Down", "116: REV Steel DR", "117: REV Tin Wave", "118: REV SN i", "119: REV SN 2", "120: REV SN 3", "121: REV SN 4", "122: REV Kick 1", "123: REV Cup", "124: REV Tom", "125: REV Cow Bell", "126: REV TAMS", "127: REV Conga", "128: REV Maracas", "129: REV Crash 1"])
      
    }
  }
  
}
