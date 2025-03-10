
extension JDXi {

  enum Drum {
      
    static let patchWerk = multiPatchWerk("Drum", [
      ([.common], 0x0, Common.patchWerk),
    ] + 37.map {
      ([.partial, .i($0)], RolandAddress([0x2e + UInt8(2 * $0), 0x00]), Partial.patchWerk)
    }, start: 0x19700000)

//    typealias PseudoPatch = PartialPatch
//    static var patchCount: Int { 37 }
//    static func patchPath(index: Int) -> SynthPath { [.partial, .i(index)] }
        
    enum Bank {
      static let iso = RolandOffsetAddressIso(address: {
        RolandAddress(0x00040000) * Int($0)
      }, location: {
        let bytes = $0.sysexBytes(count: 4)
        return UInt8((Int(bytes[0] % 4) * 32)) + (bytes[1] / 4)
      })
      
      static let bankWerk = multiBankWerk(patchWerk, startOffset: 0x50, iso: iso)
      
    }

    
    enum Common {
      static let patchWerk = singlePatchWerk("Drum Common", params, size: 0x12, start: 0x0000, name: .basic(0..<0x0c))
      
      static let params: SynthPathParam = [
        [.level] : RangeParam(byte: 0x000c)
      ]
    }

    struct Partial {
//      typealias PseudoBank = JDXiDrumPatch
      
      static let patchWerk = singlePatchWerk("Drum Partial", parms.params(), size: 0x143, start: 0x2e00, name: .basic(0..<0x0c))

//      static func startAddress(_ path: SynthPath?) -> RolandAddress {
//        RolandAddress([0x2e + UInt8(2*(path?.endex ?? 0)), 0x00])
//      }
      
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
          .p([.out, .level], 0x0016),
          .p([.chorus], 0x0019),
          .p([.reverb], 0x001a),
          .p([.out, .assign], 0x001b, .options(Program.outputAssignOptions)),
          .p([.bend], 0x001c, .max(48)),
          .p([.rcv, .expression], 0x001d, .max(1)),
          .p([.rcv, .hold], 0x001e, .max(1)),
          .p([.wave, .velo], 0x0020, .opts(["Off","On","Random"])),
        ]
        
        p += .prefix([.wave], count: 4, bx: (0x3e - 0x21), block: { i, off in [
            .p([.on], 0x21, .max(1)),
            .p([.number, .i(0)], 0x27, packIso: JDXi.multiPack(0x27 + off), .options(waveOptions)),
            .p([.number, .i(1)], 0x2b, packIso: JDXi.multiPack(0x2b + off), .options(waveOptions)),
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

        p += [
          .p([.pitch, .env, .depth], 0x0115, .rng(52...76, dispOff: -64)),
          .p([.pitch, .env, .velo], 0x0116, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .time, .i(0), .velo], 0x0117, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .time, .i(3), .velo], 0x0118, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .time, .i(0)], 0x0119),
          .p([.pitch, .env, .time, .i(1)], 0x011a),
          .p([.pitch, .env, .time, .i(2)], 0x011b),
          .p([.pitch, .env, .time, .i(3)], 0x011c),
          .p([.pitch, .env, .level, .i(-1)], 0x011d),
          .p([.pitch, .env, .level, .i(0)], 0x011e, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .level, .i(1)], 0x011f, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .level, .i(2)], 0x0120, .rng(1...127, dispOff: -64)),
          .p([.pitch, .env, .level, .i(3)], 0x0121, .rng(1...127, dispOff: -64)),
          .p([.filter, .type], 0x0122, .opts(["Off", "Lo-Pass", "Bandpass", "Hi-Pass", "Peaking", "LPF2", "LPF3"])),
          .p([.cutoff], 0x0123),
          .p([.cutoff, .velo, .curve], 0x0124),
          .p([.cutoff, .velo], 0x0125, .rng(1...127, dispOff: -64)),
          .p([.reson], 0x0126),
          .p([.reson, .velo], 0x0127, .rng(1...127, dispOff: -64)),
          .p([.filter, .env, .depth], 0x0128, .rng(1...127, dispOff: -64)),
          .p([.filter, .env, .velo, .curve], 0x0129),
          .p([.filter, .env, .velo], 0x012a, .rng(1...127, dispOff: -64)),
          .p([.filter, .env, .time, .i(0), .velo], 0x012b, .rng(1...127, dispOff: -64)),
          .p([.filter, .env, .time, .i(3), .velo], 0x012c, .rng(1...127, dispOff: -64)),
          .p([.filter, .env, .time, .i(0)], 0x012d),
          .p([.filter, .env, .time, .i(1)], 0x012e),
          .p([.filter, .env, .time, .i(2)], 0x012f),
          .p([.filter, .env, .time, .i(3)], 0x0130),
          .p([.filter, .env, .level, .i(-1)], 0x0131),
          .p([.filter, .env, .level, .i(0)], 0x0132),
          .p([.filter, .env, .level, .i(1)], 0x0133),
          .p([.filter, .env, .level, .i(2)], 0x0134),
          .p([.filter, .env, .level, .i(3)], 0x0135),
          .p([.level, .velo, .curve], 0x0136),
          .p([.level, .velo], 0x0137, .rng(1...127, dispOff: -64)),
          .p([.amp, .env, .time, .i(0), .velo], 0x0138, .rng(1...127, dispOff: -64)),
          .p([.amp, .env, .time, .i(3), .velo], 0x0139, .rng(1...127, dispOff: -64)),
          .p([.amp, .env, .time, .i(0)], 0x013a),
          .p([.amp, .env, .time, .i(1)], 0x013b),
          .p([.amp, .env, .time, .i(2)], 0x013c),
          .p([.amp, .env, .time, .i(3)], 0x013d),
          .p([.amp, .env, .level, .i(0)], 0x013e),
          .p([.amp, .env, .level, .i(1)], 0x013f),
          .p([.amp, .env, .level, .i(2)], 0x0140),
          .p([.oneShot], 0x0141, .max(1)),
          .p([.level, .adjust], 0x0142, .rng(dispOff: -64)),
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
    //    //    p[[.CoarseTune]] = RangeParam(byte: 0x000f)
    //    for i in 1...4 {
    //      //      p[[.wave, .i(i), .On]] = RangeParam(byte: off+0x0021, maxVal: 1)
    //      //      p[[.wave, .i(i), .CoarseTune]] = RangeParam(byte: off+0x0034, range: 16...112, displayOffset: -64)
    //      //      p[[.wave, .i(i), .FineTune]] = RangeParam(byte: off+0x0035, range: 14...114, displayOffset: -64)
    //
    //      set(value: 127, forParameterKey: "wave, .i(i), .Level")
    //      set(value: 1, forParameterKey: "wave, .i(i), .VeloRangeLower")
    //      set(value: 127, forParameterKey: "wave, .i(i), .VeloRangeUpper")
    //    }
    //
    //    set(value: 127, forParameterKey: "Cutoff")
    //    //    p[[.pitch, .env, .Depth]] = RangeParam(byte: 0x0115, range: 52...76, displayOffset: -64)
    //    //    p[[.CutoffVeloSens]] = RangeParam(byte: 0x0125, range: 1...127, displayOffset: -64)
    //    //    p[[.Resonance]] = RangeParam(byte: 0x0126)
    //    //    p[[.ResonanceVeloSens]] = RangeParam(byte: 0x0127, range: 1...127, displayOffset: -64)
    //    //    p[[.filter, .env, .Depth]] = RangeParam(byte: 0x0128, range: 1...127, displayOffset: -64)
    //    //    p[[.filter, .env, .VeloCurve]] = RangeParam(byte: 0x0129)
    //    //    p[[.filter, .env, .VeloSens]] = RangeParam(byte: 0x012a, range: 1...127, displayOffset: -64)
    //    //    p[[.filter, .env, .rate, .i($)VeloSens]] = RangeParam(byte: 0x012b, range: 1...127, displayOffset: -64)
    //    //    p[[.filter, .env, .rate, .i($)VeloSens]] = RangeParam(byte: 0x012c, range: 1...127, displayOffset: -64)
    //    //    p[[.filter, .env, .rate, .i($)]] = RangeParam(byte: 0x012d)
    //    //    p[[.filter, .env, .rate, .i($)]] = RangeParam(byte: 0x012e)
    //    //    p[[.filter, .env, .rate, .i($)]] = RangeParam(byte: 0x012f)
    //    //    p[[.filter, .env, .rate, .i($)]] = RangeParam(byte: 0x0130)
    //    //    p[[.filter, .env, .level, .i($)]] = RangeParam(byte: 0x0131)
    //    //    p[[.filter, .env, .level, .i($)]] = RangeParam(byte: 0x0132)
    //    //    p[[.filter, .env, .level, .i($)]] = RangeParam(byte: 0x0133)
    //    //    p[[.filter, .env, .level, .i($)]] = RangeParam(byte: 0x0134)
    //    //    p[[.filter, .env, .level, .i($)]] = RangeParam(byte: 0x0135)
    //    //    p[[.LevelVeloSens]] = RangeParam(byte: 0x0137, range: 1...127, displayOffset: -64)
    //
    //    set(value: 127, forParameterKey: "amp, .env, .level, .i($)")
    //    set(value: 127, forParameterKey: "amp, .env, .level, .i($)")
    //    set(value: 127, forParameterKey: "amp, .env, .level, .i($)")
    //    set(value: 64, forParameterKey: "RelativeLevel")
    //  }
      
        static let waveOptions = OptionsParam.makeOptions(["Off", "78 Kick P", "606 Kick P", "808 Kick 1aP", "808 Kick 1bP", "808 Kick 1cP", "808 Kick 2aP", "808 Kick 2bP", "808 Kick 2cP", "808 Kick 3aP", "808 Kick 3bP", "808 Kick 3cP", "808 Kick 4aP", "808 Kick 4bP", "808 Kick 4cP", "808 Kick 1Lp", "808 Kick 2Lp", "909 Kick 1aP", "909 Kick 1bP", "909 Kick 1cP", "909 Kick 2bP", "909 Kick 2cP", "909 Kick 3P", "909 Kick 4", "909 Kick 5", "909 Kick 6", "909 DstKickP", "909 Kick Lp", "707 Kick 1 P", "707 Kick 2 P", "626 Kick 1 P", "626 Kick 2 P", "Analog Kick1", "Analog Kick2", "Analog Kick3", "Analog Kick4", "Analog Kick5", "PlasticKick1", "PlasticKick2", "Synth Kick 1", "Synth Kick 2", "Synth Kick 3", "Synth Kick 4", "Synth Kick 5", "Synth Kick 6", "Synth Kick 7", "Synth Kick 8", "Synth Kick 9", "Synth Kick10", "Synth Kick11", "Synth Kick12", "Synth Kick13", "Synth Kick14", "Synth Kick15", "Vint Kick P", "Jungle KickP", "HashKick 1 P", "HashKick 2 P", "Lite Kick P", "Dry Kick 1", "Dry Kick 2", "Tight Kick P", "Old Kick", "Warm Kick P", "Hush Kick P", "Power Kick", "Break Kick", "Turbo Kick", "TM-2 Kick 1", "TM-2 Kick 2", "PurePhatKckP", "Bright KickP", "LoBit Kick1P", "LoBit Kick2P", "Dance Kick P", "Hip Kick P", "HipHop Kick", "Mix Kick 1", "Mix Kick 2", "Wide Kick P", "LD Kick P", "SF Kick 1 P", "SF Kick 2 P", "TY Kick P", "WD Kick P", "Reg.Kick P", "Rock Kick P", "Jz Dry Kick", "Jazz Kick P", "78 Snr", "606 Snr 1 P", "606 Snr 2 P", "808 Snr 1a P", "808 Snr 1b P", "808 Snr 1c P", "808 Snr 2a P", "808 Snr 2b P", "808 Snr 2c P", "808 Snr 3a P", "808 Snr 3b P", "808 Snr 3c P", "909 Snr 1a P", "909 Snr 1b P", "909 Snr 1c P", "909 Snr 1d P", "909 Snr 2a P", "909 Snr 2b P", "909 Snr 2c P", "909 Snr 2d P", "909 Snr 3a P", "909 Snr 3b P", "909 Snr 3c P", "909 Snr 3d P", "909 DstSnr1P", "909 DstSnr2P", "909 DstSnr3P", "707 Snr 1a P", "707 Snr 2a P", "707 Snr 1b P", "707 Snr 2b P", "626 Snr 1", "626 Snr 2", "626 Snr 3", "626 Snr 1a P", "626 Snr 3a P", "626 Snr 1b P", "626 Snr 2 P", "626 Snr 3b P", "Analog Snr 1", "Analog Snr 2", "Analog Snr 3", "Synth Snr 1", "Synth Snr 2", "106 Snr", "Sim Snare", "Jungle Snr 1", "Jungle Snr 2", "Jungle Snr 3", "Lite Snare", "Lo-Bit Snr1P", "Lo-Bit Snr2P", "HphpJazzSnrP", "PurePhatSnrP", "DRDisco SnrP", "Ragga Snr", "Lo-Fi Snare", "DR Snare", "DanceHallSnr", "Break Snr", "Piccolo SnrP", "TM-2 Snr 1", "TM-2 Snr 2", "WoodSnr RS", "LD Snr", "SF Snr P", "TY Snr", "WD Snr P", "Tight Snr", "Reg.Snr1 P", "Reg.Snr2 P", "Ballad Snr P", "Rock Snr1 P", "Rock Snr2 P", "LD Rim", "SF Rim", "TY Rim", "WD Rim P", "Jazz Snr P", "Jazz Rim P", "Jz BrshSlapP", "Jz BrshSwshP", "Swish&Trn P", "78 Rimshot", "808 RimshotP", "909 RimshotP", "707 Rimshot", "626 Rimshot", "Vint Stick P", "Lo-Bit Stk P", "Hard Stick P", "Wild Stick P", "LD Cstick", "TY Cstick", "WD Cstick", "606 H.Tom P", "808 H.Tom P", "909 H.Tom P", "707 H.Tom P", "626 H.Tom 1", "626 H.Tom 2", "SimV Tom 1 P", "LD H.Tom P", "SF H.Tom P", "TY H.Tom P", "808 M.Tom P", "909 M.Tom P", "707 M.Tom P", "626 M.Tom 1", "626 M.Tom 2", "SimV Tom 2 P", "LD M.Tom P", "SF M.Tom P", "TY M.Tom P", "606 L.Tom P", "808 L.Tom P", "909 L.Tom P", "707 L.Tom P", "626 L.Tom 1", "626 L.Tom 2", "SimV Tom 3 P", "SimV Tom 4 P", "LD L.Tom P", "SF L.Tom P", "TY L.Tom P", "78 CHH", "606 CHH", "808 CHH", "909 CHH 1", "909 CHH 2", "909 CHH 3", "909 CHH 4", "707 CHH", "626 CHH", "HipHop CHH", "Lite CHH", "Reg.CHH", "Rock CHH", "S13 CHH Tip", "S14 CHH Tip", "606 C&OHH", "808 C&OHH S", "808 C&OHH L", "Hip PHH", "Reg.PHH", "Rock PHH", "S13 PHH", "S14 PHH", "606 OHH", "808 OHH S", "808 OHH L", "909 OHH 1", "909 OHH 2", "909 OHH 3", "707 OHH", "626 OHH", "HipHop OHH", "Lite OHH", "Reg.OHH", "Rock OHH", "S13 OHH Shft", "S14 OHH Shft", "78 Cymbal", "606 Cymbal", "808 Cymbal 1", "808 Cymbal 2", "808 Cymbal 3", "909 CrashCym", "909 Rev Cym", "MG Nz Cym", "707 CrashCym", "626 CrashCym", "Crash Cym 1", "Crash Cym 2", "Rock Crash 1", "Rock Crash 2", "P17 CrashTip", "S18 CrashTip", "Z18kCrashSft", "Jazz Crash", "909 RideCym", "707 RideCym", "626 RideCym", "Ride Cymbal", "626 ChinaCym", "China Cymbal", "Splash Cym", "626 Cup", "Rock Rd Cup", "808 ClapS1 P", "808 ClapS2 P", "808 ClapL1 P", "808 ClapL2 P", "909 Clap 1 P", "909 Clap 2 P", "909 Clap 3 P", "909 DstClapP", "707 Clap P", "626 Clap", "R8 Clap", "Cheap Clap", "Old Clap P", "Hip Clap", "Dist Clap", "Hand Clap", "Club Clap", "Real Clap", "Funk Clap", "Bright Clap", "TM-2 Clap", "Amb Clap", "Disc Clap", "Claptail", "Gospel Clap", "78 Tamb", "707 Tamb P", "626 Tamb", "TM-2 Tamb", "Tamborine 1", "Tamborine 2", "Tamborine 3", "808 CowbellP", "707 Cowbell", "626 Cowbell", "Cowbell Mute", "78 H.Bongo P", "727 H.Bongo", "Bongo Hi Mt", "Bongo Hi Slp", "Bongo Hi Op", "78 L.Bongo P", "727 L.Bongo", "Bongo Lo Op", "Bongo Lo Slp", "808 H.CongaP", "727 H.CngOpP", "727 H.CngMtP", "626 H.CngaOp", "626 H.CngaMt", "Conga Hi Mt", "Conga 2H Mt", "Conga Hi Slp", "Conga 2H Slp", "Conga Hi Op", "Conga 2H Op", "808 M.CongaP", "78 L.Conga P", "808 L.CongaP", "727 L.CongaP", "626 L.Conga", "Conga Lo Mt", "Conga Lo Slp", "Conga Lo Op", "Conga 2L Mt", "Conga 2L Op", "Conga Slp Op", "Conga Efx", "Conga Thumb", "727 H.Timbal", "626 H.Timbal", "727 L.Timbal", "626 L.Timbal", "Timbale 1", "Timbale 2", "Timbale 3", "Timbale 4", "Timbles LoOp", "Timbles LoMt", "TimbalesHand", "Timbales Rim", "TmbSideStick", "727 H.Agogo", "626 H.Agogo", "727 L.Agogo", "626 L.Agogo", "727 Cabasa P", "Cabasa Up", "Cabasa Down", "Cabasa Cut", "78 Maracas P", "808 MaracasP", "727 MaracasP", "Maracas", "727 WhistleS", "727 WhistleL", "Whistle", "78 Guiro S", "78 Guiro L", "Guiro", "Guiro Long", "78 Claves P", "808 Claves P", "626 Claves", "Claves", "Wood Block", "Triangle", "78 MetalBt P", "727 StrChime", "626 Shaker", "Shaker", "Finger Snap", "Club FinSnap", "Snap", "Group Snap", "Op Pandeiro", "Mt Pandeiro", "PandeiroOp", "PandeiroMt", "PandeiroHit", "PandeiroRim", "PandeiroCrsh", "PandeiroRoll", "727 Quijada", "TablaBayam 1", "TablaBayam 2", "TablaBayam 3", "TablaBayam 4", "TablaBayam 5", "TablaBayam 6", "TablaBayam 7", "Udo", "Udu Pot Hi", "Udu Pot Slp", "Scratch 1", "Scratch 2", "Scratch 3", "Scratch 4", "Scratch 5", "Dance M", "Ahh M", "Let's Go M", "Hah F", "Yeah F", "C'mon Baby F", "Wooh F", "White Noise", "Pink Noise", "Atmosphere", "PercOrgan 1", "PercOrgan 2", "TB Blip", "D.Mute Gtr", "Flute Fx", "Pop Brs Atk", "Strings Hit", "Smear Hit", "O'Skool Hit", "Orch. Hit", "Punch Hit", "Philly Hit", "ClassicHseHt", "Tao Hit", "MG S Zap 1", "MG S Zap 2", "MG S Zap 3", "SH2 S Zap 1", "SH2 S Zap 2", "SH2 S Zap 3", "SH2 S Zap 4", "SH2 S Zap 5", "SH2 U Zap 1", "SH2 U Zap 2", "SH2 U Zap 3", "SH2 U Zap 4", "SH2 U Zap 5"])
    }

  }

}
