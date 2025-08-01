
extension JDXi {
  
  enum Digital {
        
    static let patchWerk = multiPatchWerk("Digital", [
      ([.common], 0x0000, Common.patchWerk),
      ([.extra], 0x0200, Extra.patchWerk),
      ([.partial, .i(0)], 0x2000, Partial.patchWerk),
      ([.partial, .i(1)], 0x2100, Partial.patchWerk),
      ([.partial, .i(2)], 0x2200, Partial.patchWerk),
      ([.mod], 0x5000, Modify.patchWerk),
    ], start: 0x19010000)

    //  static let fileDataCount = 513
  //
  //  // 354: what it *should* be based on the size of the subpatches
  //  // 513: what is *is* bc the JD-Xi sends an extra sysex msg. undocumented
  //  static func isValid(fileSize: Int) -> Bool {
  //    return fileSize == fileDataCount || fileSize == 354
  //  }
    
    enum Bank {
      static let bankWerk = multiBankWerk(patchWerk, startOffset: 0x60, initFile: "jdxi-digital-bank-init")
    }
    
    enum Common {
      static let patchWerk = singlePatchWerk("Digital Common", params, size: 0x40, start: 0x0000, name: .basic(0..<0x0c))

      static let params: SynthPathParam = [
        [.tone, .level] : RangeParam(byte: 0x000c),
        [.porta] : RangeParam(byte: 0x0012, maxVal: 1),
        [.porta, .time] : RangeParam(byte: 0x0013),
        [.mono] : RangeParam(byte: 0x0014, maxVal: 1),
        [.octave, .shift] : RangeParam(byte: 0x0015, range: 61...67, displayOffset: -64),
        [.bend, .up] : RangeParam(byte: 0x0016, maxVal: 24),
        [.bend, .down] : RangeParam(byte: 0x0017, maxVal: 24),
        [.partial, .i(0), .on] : RangeParam(byte: 0x0019, maxVal: 1),
        [.partial, .i(0), .select] : RangeParam(byte: 0x001a, maxVal: 1),
        [.partial, .i(1), .on] : RangeParam(byte: 0x001b, maxVal: 1),
        [.partial, .i(1), .select] : RangeParam(byte: 0x001c, maxVal: 1),
        [.partial, .i(2), .on] : RangeParam(byte: 0x001d, maxVal: 1),
        [.partial, .i(2), .select] : RangeParam(byte: 0x001e, maxVal: 1),
        [.ringMod] : OptionsParam(byte: 0x001f, options: [0:"Off",2:"On"]),
        [.unison] : RangeParam(byte: 0x002e, maxVal: 1),
        [.porta, .legato] : RangeParam(byte: 0x0031, maxVal: 1),
        [.legato] : RangeParam(byte: 0x0032, maxVal: 1),
        [.analogFeel] : RangeParam(byte: 0x0034),
        [.wave, .shape] : RangeParam(byte: 0x0035),
        [.category] : OptionsParam(byte: 0x0036, options: categoryOptions),
        [.unison, .number] : OptionsParam(byte: 0x003c, options: ["2", "4", "6", "8"]),
      ]
      
      static let categoryOptions : [Int:String] = [
        0 : "None",
        26 : "Brass",
        40 : "Seq",
        39 : "FX/Other",
        9 : "Key",
        21 : "Bass",
        34 : "Lead",
        36 : "Str/Pad",
      ]
    }
    
    enum Modify {
      
      static let patchWerk = singlePatchWerk("Digital Modify", params, size: 0x25, start: 0x5000)
          
      static let params: SynthPathParam = {
        var p = SynthPathParam()
        
        p[[.attack, .interval, .sens]] = RangeParam(byte: 0x0001)
        p[[.release, .interval, .sens]] = RangeParam(byte: 0x0002)
        p[[.porta, .interval, .sens]] = RangeParam(byte: 0x0003)
        p[[.env, .loop, .mode]] = OptionsParam(byte: 0x0004, options: ["Off", "Free Run", "Tempo Sync"])
        p[[.env, .loop, .sync, .note]] = OptionsParam(byte: 0x0005, options: ["16", "12", "8", "4", "2", "1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"])
        p[[.chromatic, .porta]] = RangeParam(byte: 0x0006, maxVal: 1)
        
        return p
      }()
      
    }

    enum Partial {
      
      static let patchWerk = singlePatchWerk("Digital Partial", parms.params(), size: 0x3d, start: 0x2000)
      
      static let parms: [Parm] = {
        var p: [Parm] = [
          .p([.osc, .wave], 0x0000, .opts(["Saw", "Square", "PW Square", "Triangle", "Sine", "Noise", "Super Saw", "PCM Wave"])),
          .p([.osc, .wave, .mod], 0x0001, .opts(["A", "B", "C"])),
          .p([.coarse], 0x0003, .rng(40...88, dispOff: -64)),
          .p([.fine], 0x0004, .rng(14...114, dispOff: -64)),
          .p([.pw, .mod, .depth], 0x0005),
          .p([.pw], 0x0006),
          .p([.pitch, .env, .attack], 0x0007),
          .p([.pitch, .env, .decay], 0x0008),
          .p([.pitch, .env, .depth], 0x0009, .rng(1...127, dispOff: -64)),
          .p([.filter, .mode], 0x000a, .opts(["Bypass", "Lo-Pass", "Hi-Pass", "Bandpass", "Peaking", "LPF2", "LPF3", "LPF4"])),
          .p([.filter, .curve], 0x000b, .opts(["-12dB", "-24dB"])),
          .p([.cutoff], 0x000c),
          .p([.filter, .key, .trk], 0x000d, .rng(54...74, dispOff: -64)),
          .p([.filter, .env, .velo], 0x000e, .rng(1...127, dispOff: -64)),
          .p([.reson], 0x000f),
          .p([.filter, .env, .attack], 0x0010),
          .p([.filter, .env, .decay], 0x0011),
          .p([.filter, .env, .sustain], 0x0012),
          .p([.filter, .env, .release], 0x0013),
          .p([.filter, .env, .depth], 0x0014, .rng(1...127, dispOff: -64)),
          .p([.amp, .level], 0x0015),
          .p([.amp, .velo], 0x0016, .rng(1...127, dispOff: -64)),
          .p([.amp, .env, .attack], 0x0017),
          .p([.amp, .env, .decay], 0x0018),
          .p([.amp, .env, .sustain], 0x0019),
          .p([.amp, .env, .release], 0x001a),
          .p([.pan], 0x001b, .rng(dispOff: -64)),

          .p([.lfo, .shape], 0x001c, .options(lfoShapes)),
          .p([.lfo, .rate], 0x001d),
          .p([.lfo, .tempo, .sync], 0x001e, .max(1)),
          .p([.lfo, .sync, .note], 0x001f, .options(lfoSyncNotes)),

          .p([.lfo, .fade], 0x0020),
          .p([.lfo, .key, .sync], 0x0021, .max(1)),
          .p([.lfo, .pitch, .depth], 0x0022, .rng(1...127, dispOff: -64)),
          .p([.lfo, .filter, .depth], 0x0023, .rng(1...127, dispOff: -64)),
          .p([.lfo, .amp, .depth], 0x0024, .rng(1...127, dispOff: -64)),
          .p([.lfo, .pan, .depth], 0x0025, .rng(1...127, dispOff: -64)),
          .p([.mod, .lfo, .shape], 0x0026, .options(lfoShapes)),
          .p([.mod, .lfo, .rate], 0x0027),
          .p([.mod, .lfo, .tempo, .sync], 0x0028, .max(1)),
          .p([.mod, .lfo, .sync, .note], 0x0029, .options(lfoSyncNotes)),
          .p([.pw, .shift], 0x002a),
          .p([.mod, .lfo, .pitch, .depth], 0x002c, .rng(1...127, dispOff: -64)),
          .p([.mod, .lfo, .filter, .depth], 0x002d, .rng(1...127, dispOff: -64)),
          .p([.mod, .lfo, .amp, .depth], 0x002e, .rng(1...127, dispOff: -64)),
          .p([.mod, .lfo, .pan, .depth], 0x002f, .rng(1...127, dispOff: -64)),
          .p([.cutoff, .aftertouch, .sens], 0x0030, .rng(1...127, dispOff: -64)),
          .p([.level, .aftertouch, .sens], 0x0031, .rng(1...127, dispOff: -64)),
          .p([.wave, .gain], 0x0034, .opts(["-6dB", "0dB", "6dB", "12dB"])),
          .p([.wave, .number], 0x0035, packIso: JDXi.multiPack(0x0035), .opts(["OFF", "Calc.Saw", "DistSaw Wave", "GR-300 Saw", "Lead Wave 1", "Lead Wave 2", "Unison Saw", "Saw+Sub Wave", "SqrLeadWave", "SqrLeadWave+", "FeedbackWave", "Bad Axe", "Cutting Lead", "DistTB Sqr", "Sync Sweep", "Saw Sync", "Unison Sync+", "Sync Wave", "Cutters", "Nasty", "Bagpipe Wave", "Wave Scan", "Wire String", "Lead Wave 3", "PWM Wave 1", "PWM Wave 2", "MIDI Clav", "Huge MIDI", "Wobble Bs 1", "Wobble Bs 2", "Hollow Bass", "SynBs Wave", "Solid Bass", "House Bass", "4OP FM Bass", "Fine Wine", "Bell Wave 1", "Bell Wave 1+", "Bell Wave 2", "Digi Wave 1", "Digi Wave 2", "Org Bell", "Gamelan", "Crystal", "Finger Bell", "DipthongWave", "DipthongWv +", "Hollo Wave1", "Hollo Wave2", "Hollo Wave2+", "Heaven Wave", "Doo", "MMM Vox", "Eeh Formant", "Iih Formant", "Syn Vox 1", "Syn Vox 2", "Org Vox", "Male Ooh", "LargeChrF 1", "LargeChrF 2", "Female Oohs", "Female Aahs", "Atmospheric", "Air Pad 1", "Air Pad 2", "Air Pad 3", "VP-330 Choir", "SynStrings 1", "SynStrings 2", "SynStrings 3", "SynStrings 4", "SynStrings 5", "SynStrings 6", "Revalation", "Alan's Pad", "lfo, . Poly", "Boreal Pad L", "Boreal Pad R", "HPF Pad L", "HPF Pad R", "Sweep Pad", "Chubby Ld", "Fantasy Pad", "Legend Pad", "D-50 Stack", "ChrdOfCnadaL", "ChrdOfCnadaR", "Fireflies", "JazzyBubbles", "SynthFx 1", "SynthFx 2", "X-mod, . Wave 1", "X-mod, . Wave 2", "SynVox Noise", "Dentist Nz", "Atmosphere", "Anklungs", "Xylo Seq", "O'Skool Hit", "Orch. Hit", "Punch Hit", "Philly Hit", "ClassicHseHt", "Tao Hit", "Smear Hit", "808 Kick 1Lp", "808 Kick 2Lp", "909 Kick Lp", "JD Piano", "E.Grand", "Stage EP", "Wurly", "EP Hard", "FM EP 1", "FM EP 2", "FM EP 3", "Harpsi Wave", "Clav Wave 1", "Clav Wave 2", "Vibe Wave", "Organ Wave 1", "Organ Wave 2", "PercOrgan 1", "PercOrgan 2", "Vint.Organ", "Harmonica", "Ac. Guitar", "Nylon Gtr", "Brt Strat", "Funk Guitar", "Jazz Guitar", "Dist Guitar", "D.Mute Gtr", "FatAc. Bass", "Fingerd Bass", "Picked Bass", "Fretless Bs", "Slap Bass", "Strings 1", "Strings 2", "Strings 3 L", "Strings 3 R", "Pizzagogo", "Harp Harm", "Harp Wave", "PopBrsAtk", "PopBrass", "Tp Section", "Studio Tp", "Tp Vib Mari", "Tp Hrmn Mt", "FM Brass", "Trombone", "Wide Sax", "Flute Wave", "Flute Push", "E.Sitar", "Sitar Drone", "Agogo", "Steel Drums"])),
          .p([.hi, .pass, .cutoff], 0x0039),
          .p([.saw, .detune], 0x003a),
          .p([.mod, .lfo, .rate, .ctrl], 0x003b, .rng(1...127, dispOff: -64)),
          .p([.amp, .key, .trk], 0x003c, .rng(54...74, dispOff: -64)),
        ]
        return p
      }()
      
      static let lfoShapes = OptionsParam.makeOptions(["Triangle", "Sine", "Saw", "Square", "S&H", "Random"])
      static let lfoSyncNotes = OptionsParam.makeOptions(["16", "12", "8", "4", "2", "1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"])
    }

    enum Extra {
      static let patchWerk = singlePatchWerk("Digital Extra", [:], size: 0x111, start: 0x0200)
    }
  }
}
