
extension JDXi {

  enum Drum {
      
    const patchWerk = multiPatchWerk("Drum", [
      ("common", 0x0, Common.patchWerk),
    ] + 37.map {
      ("partial/$0", RolandAddress([0x2e + UInt8(2 * $0), 0x00]), Partial.patchWerk)
    }, start: 0x19700000)

//    typealias PseudoPatch = PartialPatch
//    static var patchCount: Int { 37 }
//    static func patchPath(index: Int) -> SynthPath { "partial/index" }
        
    enum Bank {
      const iso = RolandOffsetAddressIso(address: {
        RolandAddress(0x00040000) * Int($0)
      }, location: {
        let bytes = $0.sysexBytes(count: 4)
        return UInt8((Int(bytes[0] % 4) * 32)) + (bytes[1] / 4)
      })
      
      const bankWerk = multiBankWerk(patchWerk, startOffset: 0x50, iso: iso)
      
    }

    
    enum Common {
      const patchWerk = singlePatchWerk("Drum Common", params, size: 0x12, start: 0x0000, name: .basic(0..<0x0c))
      
      const params: SynthPathParam = [
        "level" : RangeParam(byte: 0x000c)
      ]
    }

    struct Partial {
//      typealias PseudoBank = JDXiDrumPatch
      
      const patchWerk = singlePatchWerk("Drum Partial", parms.params(), size: 0x143, start: 0x2e00, name: .basic(0..<0x0c))

//      static func startAddress(_ path: SynthPath?) -> RolandAddress {
//        RolandAddress([0x2e + UInt8(2*(path?.endex ?? 0)), 0x00])
//      }
      
      const parms: [Parm] = {
        var p: [Parm] = [
          ['assign/type', { b: 0x000c, max: 1 }],
          ['mute/group', { b: 0x000d, max: 31 }],
          ['level', { b: 0x000e }],
          ['coarse', { b: 0x000f, dispOff: -64 }],
          ['fine', { b: 0x0010, rng: [14, 114], dispOff: -64 }],
          ['random/pitch', { b: 0x0011, opts: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"] }],
          ['pan', { b: 0x0012, dispOff: -64 }],
          ['random/pan', { b: 0x0013, max: 63 }],
          ['alt/pan', { b: 0x0014, rng: [1, 127], dispOff: -64 }],
          ['env/mode', { b: 0x0015, max: 1 }],
          ['out/level', { b: 0x0016 }],
          ['chorus', { b: 0x0019 }],
          ['reverb', { b: 0x001a }],
          ['out/assign', { b: 0x001b, opts: Program.outputAssignOptions }],
          ['bend', { b: 0x001c, max: 48 }],
          ['rcv/expression', { b: 0x001d, max: 1 }],
          ['rcv/hold', { b: 0x001e, max: 1 }],
          ['wave/velo', { b: 0x0020, opts: ["Off","On","Random"] }],
        ]
        
        p += .prefix("wave", count: 4, bx: (0x3e - 0x21), block: { i, off in [
            ['on', { b: 0x21, max: 1 }],
            ['number/0', { b: 0x27, packIso: JDXi.multiPack(0x27 + off), opts: waveOptions }],
            ['number/1', { b: 0x2b, packIso: JDXi.multiPack(0x2b + off), opts: waveOptions }],
            ['wave/gain', { b: 0x2f, opts: ["-6db", "0dB", "6dB", "12dB"] }],
            ['fxm/on', { b: 0x30, max: 1 }],
            ['fxm/color', { b: 0x31, max: 3, dispOff: 1 }],
            ['fxm/depth', { b: 0x32, max: 16 }],
            ['tempo/sync', { b: 0x33, max: 1 }],
            ['coarse', { b: 0x34, rng: [16, 112], dispOff: -64 }],
            ['fine', { b: 0x35, rng: [14, 114], dispOff: -64 }],
            ['pan', { b: 0x36, dispOff: -64 }],
            ['random/pan', { b: 0x37, max: 1 }],
            ['alt/pan', { b: 0x38, opts: ["Off", "On", "Reverse"] }],
            ['level', { b: 0x39 }],
            ['velo/range/lo', { b: 0x3a, rng: [1, 127] }],
            ['velo/range/hi', { b: 0x3b, rng: [1, 127] }],
            ['velo/fade/lo', { b: 0x3c }],
            ['velo/fade/hi', { b: 0x3d }],
        ] })

        p += [
          ['pitch/env/depth', { b: 0x0115, rng: [52, 76], dispOff: -64 }],
          ['pitch/env/velo', { b: 0x0116, rng: [1, 127], dispOff: -64 }],
          ['pitch/env/time/0/velo', { b: 0x0117, rng: [1, 127], dispOff: -64 }],
          ['pitch/env/time/3/velo', { b: 0x0118, rng: [1, 127], dispOff: -64 }],
          ['pitch/env/time/0', { b: 0x0119 }],
          ['pitch/env/time/1', { b: 0x011a }],
          ['pitch/env/time/2', { b: 0x011b }],
          ['pitch/env/time/3', { b: 0x011c }],
          ['pitch/env/level/-1', { b: 0x011d }],
          ['pitch/env/level/0', { b: 0x011e, rng: [1, 127], dispOff: -64 }],
          ['pitch/env/level/1', { b: 0x011f, rng: [1, 127], dispOff: -64 }],
          ['pitch/env/level/2', { b: 0x0120, rng: [1, 127], dispOff: -64 }],
          ['pitch/env/level/3', { b: 0x0121, rng: [1, 127], dispOff: -64 }],
          ['filter/type', { b: 0x0122, opts: ["Off", "Lo-Pass", "Bandpass", "Hi-Pass", "Peaking", "LPF2", "LPF3"] }],
          ['cutoff', { b: 0x0123 }],
          ['cutoff/velo/curve', { b: 0x0124 }],
          ['cutoff/velo', { b: 0x0125, rng: [1, 127], dispOff: -64 }],
          ['reson', { b: 0x0126 }],
          ['reson/velo', { b: 0x0127, rng: [1, 127], dispOff: -64 }],
          ['filter/env/depth', { b: 0x0128, rng: [1, 127], dispOff: -64 }],
          ['filter/env/velo/curve', { b: 0x0129 }],
          ['filter/env/velo', { b: 0x012a, rng: [1, 127], dispOff: -64 }],
          ['filter/env/time/0/velo', { b: 0x012b, rng: [1, 127], dispOff: -64 }],
          ['filter/env/time/3/velo', { b: 0x012c, rng: [1, 127], dispOff: -64 }],
          ['filter/env/time/0', { b: 0x012d }],
          ['filter/env/time/1', { b: 0x012e }],
          ['filter/env/time/2', { b: 0x012f }],
          ['filter/env/time/3', { b: 0x0130 }],
          ['filter/env/level/-1', { b: 0x0131 }],
          ['filter/env/level/0', { b: 0x0132 }],
          ['filter/env/level/1', { b: 0x0133 }],
          ['filter/env/level/2', { b: 0x0134 }],
          ['filter/env/level/3', { b: 0x0135 }],
          ['level/velo/curve', { b: 0x0136 }],
          ['level/velo', { b: 0x0137, rng: [1, 127], dispOff: -64 }],
          ['amp/env/time/0/velo', { b: 0x0138, rng: [1, 127], dispOff: -64 }],
          ['amp/env/time/3/velo', { b: 0x0139, rng: [1, 127], dispOff: -64 }],
          ['amp/env/time/0', { b: 0x013a }],
          ['amp/env/time/1', { b: 0x013b }],
          ['amp/env/time/2', { b: 0x013c }],
          ['amp/env/time/3', { b: 0x013d }],
          ['amp/env/level/0', { b: 0x013e }],
          ['amp/env/level/1', { b: 0x013f }],
          ['amp/env/level/2', { b: 0x0140 }],
          ['oneShot', { b: 0x0141, max: 1 }],
          ['level/adjust', { b: 0x0142, dispOff: -64 }],
        ]
        return p
      }()
      
      
    //  override func randomize() {
    //    super.randomize()
    //    set(value: 127, forParameterKey: "Level")
    //    set(value: 127, forParameterKey: "OutputLevel")
    //    set(value: 1, forParameterKey: "AssignType")
    //
    //    set(value: 64, forParameterKey: "CoarseTune")
    //    set(value: 64, forParameterKey: "FineTune")
    //
    //    //    p["CoarseTune"] = RangeParam(byte: 0x000f)
    //    for i in 1...4 {
    //      //      p["wave/i/On"] = RangeParam(byte: off+0x0021, maxVal: 1)
    //      //      p["wave/i/CoarseTune"] = RangeParam(byte: off+0x0034, range: 16...112, displayOffset: -64)
    //      //      p["wave/i/FineTune"] = RangeParam(byte: off+0x0035, range: 14...114, displayOffset: -64)
    //
    //      set(value: 127, forParameterKey: "wave, .i(i), .Level")
    //      set(value: 1, forParameterKey: "wave, .i(i), .VeloRangeLower")
    //      set(value: 127, forParameterKey: "wave, .i(i), .VeloRangeUpper")
    //    }
    //
    //    set(value: 127, forParameterKey: "Cutoff")
    //    //    p["pitch/env/Depth"] = RangeParam(byte: 0x0115, range: 52...76, displayOffset: -64)
    //    //    p["CutoffVeloSens"] = RangeParam(byte: 0x0125, range: 1...127, displayOffset: -64)
    //    //    p["Resonance"] = RangeParam(byte: 0x0126)
    //    //    p["ResonanceVeloSens"] = RangeParam(byte: 0x0127, range: 1...127, displayOffset: -64)
    //    //    p["filter/env/Depth"] = RangeParam(byte: 0x0128, range: 1...127, displayOffset: -64)
    //    //    p["filter/env/VeloCurve"] = RangeParam(byte: 0x0129)
    //    //    p["filter/env/VeloSens"] = RangeParam(byte: 0x012a, range: 1...127, displayOffset: -64)
    //    //    p["filter/env/rate/$)VeloSen"] = RangeParam(byte: 0x012b, range: 1...127, displayOffset: -64)
    //    //    p["filter/env/rate/$)VeloSen"] = RangeParam(byte: 0x012c, range: 1...127, displayOffset: -64)
    //    //    p["filter/env/rate/$"] = RangeParam(byte: 0x012d)
    //    //    p["filter/env/rate/$"] = RangeParam(byte: 0x012e)
    //    //    p["filter/env/rate/$"] = RangeParam(byte: 0x012f)
    //    //    p["filter/env/rate/$"] = RangeParam(byte: 0x0130)
    //    //    p["filter/env/level/$"] = RangeParam(byte: 0x0131)
    //    //    p["filter/env/level/$"] = RangeParam(byte: 0x0132)
    //    //    p["filter/env/level/$"] = RangeParam(byte: 0x0133)
    //    //    p["filter/env/level/$"] = RangeParam(byte: 0x0134)
    //    //    p["filter/env/level/$"] = RangeParam(byte: 0x0135)
    //    //    p["LevelVeloSens"] = RangeParam(byte: 0x0137, range: 1...127, displayOffset: -64)
    //
    //    set(value: 127, forParameterKey: "amp, .env, .level, .i($)")
    //    set(value: 127, forParameterKey: "amp, .env, .level, .i($)")
    //    set(value: 127, forParameterKey: "amp, .env, .level, .i($)")
    //    set(value: 64, forParameterKey: "RelativeLevel")
    //  }
      
        const waveOptions = ["Off", "78 Kick P", "606 Kick P", "808 Kick 1aP", "808 Kick 1bP", "808 Kick 1cP", "808 Kick 2aP", "808 Kick 2bP", "808 Kick 2cP", "808 Kick 3aP", "808 Kick 3bP", "808 Kick 3cP", "808 Kick 4aP", "808 Kick 4bP", "808 Kick 4cP", "808 Kick 1Lp", "808 Kick 2Lp", "909 Kick 1aP", "909 Kick 1bP", "909 Kick 1cP", "909 Kick 2bP", "909 Kick 2cP", "909 Kick 3P", "909 Kick 4", "909 Kick 5", "909 Kick 6", "909 DstKickP", "909 Kick Lp", "707 Kick 1 P", "707 Kick 2 P", "626 Kick 1 P", "626 Kick 2 P", "Analog Kick1", "Analog Kick2", "Analog Kick3", "Analog Kick4", "Analog Kick5", "PlasticKick1", "PlasticKick2", "Synth Kick 1", "Synth Kick 2", "Synth Kick 3", "Synth Kick 4", "Synth Kick 5", "Synth Kick 6", "Synth Kick 7", "Synth Kick 8", "Synth Kick 9", "Synth Kick10", "Synth Kick11", "Synth Kick12", "Synth Kick13", "Synth Kick14", "Synth Kick15", "Vint Kick P", "Jungle KickP", "HashKick 1 P", "HashKick 2 P", "Lite Kick P", "Dry Kick 1", "Dry Kick 2", "Tight Kick P", "Old Kick", "Warm Kick P", "Hush Kick P", "Power Kick", "Break Kick", "Turbo Kick", "TM-2 Kick 1", "TM-2 Kick 2", "PurePhatKckP", "Bright KickP", "LoBit Kick1P", "LoBit Kick2P", "Dance Kick P", "Hip Kick P", "HipHop Kick", "Mix Kick 1", "Mix Kick 2", "Wide Kick P", "LD Kick P", "SF Kick 1 P", "SF Kick 2 P", "TY Kick P", "WD Kick P", "Reg.Kick P", "Rock Kick P", "Jz Dry Kick", "Jazz Kick P", "78 Snr", "606 Snr 1 P", "606 Snr 2 P", "808 Snr 1a P", "808 Snr 1b P", "808 Snr 1c P", "808 Snr 2a P", "808 Snr 2b P", "808 Snr 2c P", "808 Snr 3a P", "808 Snr 3b P", "808 Snr 3c P", "909 Snr 1a P", "909 Snr 1b P", "909 Snr 1c P", "909 Snr 1d P", "909 Snr 2a P", "909 Snr 2b P", "909 Snr 2c P", "909 Snr 2d P", "909 Snr 3a P", "909 Snr 3b P", "909 Snr 3c P", "909 Snr 3d P", "909 DstSnr1P", "909 DstSnr2P", "909 DstSnr3P", "707 Snr 1a P", "707 Snr 2a P", "707 Snr 1b P", "707 Snr 2b P", "626 Snr 1", "626 Snr 2", "626 Snr 3", "626 Snr 1a P", "626 Snr 3a P", "626 Snr 1b P", "626 Snr 2 P", "626 Snr 3b P", "Analog Snr 1", "Analog Snr 2", "Analog Snr 3", "Synth Snr 1", "Synth Snr 2", "106 Snr", "Sim Snare", "Jungle Snr 1", "Jungle Snr 2", "Jungle Snr 3", "Lite Snare", "Lo-Bit Snr1P", "Lo-Bit Snr2P", "HphpJazzSnrP", "PurePhatSnrP", "DRDisco SnrP", "Ragga Snr", "Lo-Fi Snare", "DR Snare", "DanceHallSnr", "Break Snr", "Piccolo SnrP", "TM-2 Snr 1", "TM-2 Snr 2", "WoodSnr RS", "LD Snr", "SF Snr P", "TY Snr", "WD Snr P", "Tight Snr", "Reg.Snr1 P", "Reg.Snr2 P", "Ballad Snr P", "Rock Snr1 P", "Rock Snr2 P", "LD Rim", "SF Rim", "TY Rim", "WD Rim P", "Jazz Snr P", "Jazz Rim P", "Jz BrshSlapP", "Jz BrshSwshP", "Swish&Trn P", "78 Rimshot", "808 RimshotP", "909 RimshotP", "707 Rimshot", "626 Rimshot", "Vint Stick P", "Lo-Bit Stk P", "Hard Stick P", "Wild Stick P", "LD Cstick", "TY Cstick", "WD Cstick", "606 H.Tom P", "808 H.Tom P", "909 H.Tom P", "707 H.Tom P", "626 H.Tom 1", "626 H.Tom 2", "SimV Tom 1 P", "LD H.Tom P", "SF H.Tom P", "TY H.Tom P", "808 M.Tom P", "909 M.Tom P", "707 M.Tom P", "626 M.Tom 1", "626 M.Tom 2", "SimV Tom 2 P", "LD M.Tom P", "SF M.Tom P", "TY M.Tom P", "606 L.Tom P", "808 L.Tom P", "909 L.Tom P", "707 L.Tom P", "626 L.Tom 1", "626 L.Tom 2", "SimV Tom 3 P", "SimV Tom 4 P", "LD L.Tom P", "SF L.Tom P", "TY L.Tom P", "78 CHH", "606 CHH", "808 CHH", "909 CHH 1", "909 CHH 2", "909 CHH 3", "909 CHH 4", "707 CHH", "626 CHH", "HipHop CHH", "Lite CHH", "Reg.CHH", "Rock CHH", "S13 CHH Tip", "S14 CHH Tip", "606 C&OHH", "808 C&OHH S", "808 C&OHH L", "Hip PHH", "Reg.PHH", "Rock PHH", "S13 PHH", "S14 PHH", "606 OHH", "808 OHH S", "808 OHH L", "909 OHH 1", "909 OHH 2", "909 OHH 3", "707 OHH", "626 OHH", "HipHop OHH", "Lite OHH", "Reg.OHH", "Rock OHH", "S13 OHH Shft", "S14 OHH Shft", "78 Cymbal", "606 Cymbal", "808 Cymbal 1", "808 Cymbal 2", "808 Cymbal 3", "909 CrashCym", "909 Rev Cym", "MG Nz Cym", "707 CrashCym", "626 CrashCym", "Crash Cym 1", "Crash Cym 2", "Rock Crash 1", "Rock Crash 2", "P17 CrashTip", "S18 CrashTip", "Z18kCrashSft", "Jazz Crash", "909 RideCym", "707 RideCym", "626 RideCym", "Ride Cymbal", "626 ChinaCym", "China Cymbal", "Splash Cym", "626 Cup", "Rock Rd Cup", "808 ClapS1 P", "808 ClapS2 P", "808 ClapL1 P", "808 ClapL2 P", "909 Clap 1 P", "909 Clap 2 P", "909 Clap 3 P", "909 DstClapP", "707 Clap P", "626 Clap", "R8 Clap", "Cheap Clap", "Old Clap P", "Hip Clap", "Dist Clap", "Hand Clap", "Club Clap", "Real Clap", "Funk Clap", "Bright Clap", "TM-2 Clap", "Amb Clap", "Disc Clap", "Claptail", "Gospel Clap", "78 Tamb", "707 Tamb P", "626 Tamb", "TM-2 Tamb", "Tamborine 1", "Tamborine 2", "Tamborine 3", "808 CowbellP", "707 Cowbell", "626 Cowbell", "Cowbell Mute", "78 H.Bongo P", "727 H.Bongo", "Bongo Hi Mt", "Bongo Hi Slp", "Bongo Hi Op", "78 L.Bongo P", "727 L.Bongo", "Bongo Lo Op", "Bongo Lo Slp", "808 H.CongaP", "727 H.CngOpP", "727 H.CngMtP", "626 H.CngaOp", "626 H.CngaMt", "Conga Hi Mt", "Conga 2H Mt", "Conga Hi Slp", "Conga 2H Slp", "Conga Hi Op", "Conga 2H Op", "808 M.CongaP", "78 L.Conga P", "808 L.CongaP", "727 L.CongaP", "626 L.Conga", "Conga Lo Mt", "Conga Lo Slp", "Conga Lo Op", "Conga 2L Mt", "Conga 2L Op", "Conga Slp Op", "Conga Efx", "Conga Thumb", "727 H.Timbal", "626 H.Timbal", "727 L.Timbal", "626 L.Timbal", "Timbale 1", "Timbale 2", "Timbale 3", "Timbale 4", "Timbles LoOp", "Timbles LoMt", "TimbalesHand", "Timbales Rim", "TmbSideStick", "727 H.Agogo", "626 H.Agogo", "727 L.Agogo", "626 L.Agogo", "727 Cabasa P", "Cabasa Up", "Cabasa Down", "Cabasa Cut", "78 Maracas P", "808 MaracasP", "727 MaracasP", "Maracas", "727 WhistleS", "727 WhistleL", "Whistle", "78 Guiro S", "78 Guiro L", "Guiro", "Guiro Long", "78 Claves P", "808 Claves P", "626 Claves", "Claves", "Wood Block", "Triangle", "78 MetalBt P", "727 StrChime", "626 Shaker", "Shaker", "Finger Snap", "Club FinSnap", "Snap", "Group Snap", "Op Pandeiro", "Mt Pandeiro", "PandeiroOp", "PandeiroMt", "PandeiroHit", "PandeiroRim", "PandeiroCrsh", "PandeiroRoll", "727 Quijada", "TablaBayam 1", "TablaBayam 2", "TablaBayam 3", "TablaBayam 4", "TablaBayam 5", "TablaBayam 6", "TablaBayam 7", "Udo", "Udu Pot Hi", "Udu Pot Slp", "Scratch 1", "Scratch 2", "Scratch 3", "Scratch 4", "Scratch 5", "Dance M", "Ahh M", "Let's Go M", "Hah F", "Yeah F", "C'mon Baby F", "Wooh F", "White Noise", "Pink Noise", "Atmosphere", "PercOrgan 1", "PercOrgan 2", "TB Blip", "D.Mute Gtr", "Flute Fx", "Pop Brs Atk", "Strings Hit", "Smear Hit", "O'Skool Hit", "Orch. Hit", "Punch Hit", "Philly Hit", "ClassicHseHt", "Tao Hit", "MG S Zap 1", "MG S Zap 2", "MG S Zap 3", "SH2 S Zap 1", "SH2 S Zap 2", "SH2 S Zap 3", "SH2 S Zap 4", "SH2 S Zap 5", "SH2 U Zap 1", "SH2 U Zap 2", "SH2 U Zap 3", "SH2 U Zap 4", "SH2 U Zap 5"]
    }

  }

}
