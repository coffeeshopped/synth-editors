
extension JV1080 {
  
  enum Perf {
    
    static let patchWerk = JVXP.Perf.patchWerk(common: Common.patchWerk, part: Part.patchWerk, initFile: "jv1080-perf-init")
    
    static let bankWerk = JVXP.Perf.bankWerk(patchWerk)

    enum Common {
      
      static let patchWerk = JVXP.Perf.Common.patchWerk(params, 0x40)
      
//      static var fileDataAddress: RolandAddress {
//        return JV1080PerfPatch.fileDataAddress + startAddress()
//      }
            
      static let parms: [Parm] = {
        var p: [Parm] = [
          .p([.fx, .src], 0x0c, .options(fxSrcOptions)),
          .p([.fx, .type], 0x0d, .options(Voice.Common.fxTypeOptions)),
        ] + .prefix([.fx, .param], count: 12, bx: 1, block: { index, offset in
          [.p([], 0x0e)]
        })
        p += .inc(b: 0x1a) { [
          .p([.fx, .out, .assign], .opts(["Mix","Output 1","Output 2"])),
          .p([.fx, .out, .level]),
          .p([.fx, .chorus]),
          .p([.fx, .reverb]),
          .p([.fx, .ctrl, .src, .i(0)], .options(Voice.Common.fxControlSourceOptions)),
          .p([.fx, .ctrl, .depth, .i(0)], .max(126, dispOff: -63)),
          .p([.fx, .ctrl, .src, .i(1)], .options(Voice.Common.fxControlSourceOptions)),
          .p([.fx, .ctrl, .depth, .i(1)], .max(126, dispOff: -63)),
          .p([.chorus, .level]),
          .p([.chorus, .rate]),
          .p([.chorus, .depth]),
          .p([.chorus, .predelay]),
          .p([.chorus, .feedback]),
          .p([.chorus, .out, .assign], .options(Voice.Common.chorusOutOptions)),
          .p([.reverb, .type], .options(Voice.Common.reverbTypeOptions)),
          .p([.reverb, .level]),
          .p([.reverb, .time]),
          .p([.reverb, .hfdamp], .options(Voice.Common.reverbHFDampOptions)),
          .p([.reverb, .feedback]),
          .p([.tempo], packIso: JVXP.multiPack(0x2d), .rng(20...250)),
        ] }
        p += [
          .p([.key, .range], 0x2f, .max(1)),
        ] + .prefix([.part], count: 16, bx: 1, block: { index, offset in
          [.p([.voice, .reserve], 0x30, .max(64))]
        })
        return p
      }()
      static let params = parms.params()
      
      static let fxSrcOptions = OptionsParam.makeOptions(["Perform"] +
        (1...9).map {"Part \($0)"} +
        (10...15).map {"Part \($0+1)"})
      
    }
    
    
    enum Part {
      
      static let patchWerk = JVXP.Perf.Part.patchWerk(params, 0x13)
      
      static let parms: [Parm] = [
        .p([.midi, .rcv], 0x00, .max(1)),
        .p([.channel], 0x01, .max(15, dispOff: 1)),
        .p([.patch, .group], 0x02, .opts(["User","PCM","Exp"])),
        .p([.patch, .group, .id], 0x03),
        .p([.patch, .number], 0x04, packIso: JVXP.multiPack(0x04), .max(254, dispOff: 1)),
      ] + .inc(b: 0x06) { [
        .p([.level]),
        .p([.pan], .rng(dispOff: -64)),
        .p([.coarse], .max(96, dispOff: -48)),
        .p([.fine], .max(100, dispOff: -50)),
        .p([.out, .assign], .opts(["Mix","FX","Output 1","Output 2","Patch"])),
        .p([.out, .level]),
        .p([.chorus]),
        .p([.reverb]),
        .p([.rcv, .pgmChange], .max(1)),
        .p([.rcv, .volume], .max(1)),
        .p([.rcv, .hold], .max(1)),
        .p([.key, .range, .lo]),
        .p([.key, .range, .hi]),
      ] }
      static let params = parms.params()

      static let config: CtrlConfig = .init(voicePresets: voicePresetOptionMap, rhythmPresets: rhythmPresetOptionMap, blank: blankPatchOptions, patchGroups: patchGroupOptions, hasOutSelect: false)
      
      static let patchGroupOptions: [Int:String] = {
        var options = [
          1 : "User",
          3 : "Preset-A",
          4 : "Preset-B",
          5 : "Preset-C",
          6 : "GM",
        ]
        var pgo = [Int:String]()
        options.forEach { pgo[$0 - 100] = $1 }
        SRJVBoard.boardNameOptions.forEach { pgo[$0] = $1 }
        return pgo
      }()
      
      static let blankPatchOptions = OptionsParam.makeOptions((1...255).map { "\($0)" })

      static let voicePresetOptionMap = [
        3 : presetAOptions,
        4 : presetBOptions,
        5 : presetCOptions,
        6 : gmOptions,
      ]

      static let rhythmPresetOptionMap = [
        3 : rhythmPresetAOptions,
        4 : rhythmPresetBOptions,
        5 : rhythmPresetCOptions,
        6 : rhythmGMOptions,
      ]

      static let presetAOptions = OptionsParam.makeOptions(["1 64voicePiano", "2 Bright Piano", "3 Classique", "4 Nice Piano", "5 Piano Thang", "6 Power Grand", "7 House Piano", "8 E.Grand", "9 MIDIed Grand", "10 Piano Blend", "11 West Coast", "12 PianoStrings", "13 Bs/Pno+Brs", "14 Waterhodes", "15 S.A.E.P.", "16 SA Rhodes 1", "17 SA Rhodes 2", "18 Stiky Rhodes", "19 Dig Rhodes", "20 Nylon EPiano", "21 Nylon Rhodes", "22 Rhodes Mix", "23 PsychoRhodes", "24 Tremo Rhodes", "25 MK-80 Rhodes", "26 MK-80 Phaser", "27 Delicate EP", "28 Octa Rhodes1", "29 Octa Rhodes2", "30 JV Rhodes+", "31 EP+Mod Pad", "32 Mr.Mellow", "33 Comp Clav", "34 Klavinet", "35 Winger Clav", "36 Phaze Clav 1", "37 Phaze Clav 2", "38 Phuzz Clav", "39 Chorus Clav", "40 Claviduck", "41 Velo-Rez Clv", "42 Clavicembalo", "43 Analog Clav1", "44 Analog Clav2", "45 Metal Clav", "46 Full Stops", "47 Ballad B", "48 Mellow Bars", "49 AugerMentive", "50 Perky B", "51 The Big Spin", "52 Gospel Spin", "53 Roller Spin", "54 Rocker Spin", "55 Tone Wh.Solo", "56 Purple Spin", "57 60's LeadORG", "58 Assalt Organ", "59 D-50 Organ", "60 Cathedral", "61 Church Pipes", "62 Poly Key", "63 Poly Saws", "64 Poly Pulse", "65 Dual Profs 3", "66 Saw Mass 4", "67 Poly Split 4", "68 Poly Brass 3", "69 Stackoid 4", "70 Poly Rock 4", "71 D-50 Stack 4", "72 Fantasia JV 4", "73 Jimmee Dee 4", "74 Heavenals 4", "75 Mallet Pad 4", "76 Huff N Stuff 3", "77 Puff 1080 2", "78 BellVox 1080 4", "79 Fantasy Vox 4", "80 Square Keys 2", "81 Childlike 4", "82 Music Box 3", "83 Toy Box 2", "84 Wave Bells 4", "85 Tria Bells 4", "86 Beauty Bells 4", "87 Music Bells 2", "88 Pretty Bells 2", "89 Pulse Key 3", "90 Wide Tubular 4", "91 AmbienceVibe 4", "92 Warm Vibes 2", "93 Dyna Marimba 1", "94 Bass Marimba 4", "95 Nomad Perc 3", "96 Ethno Metals 4", "97 Islands Mlt 4", "98 Steelin Keys 3", "99 Steel Drums 1", "100 Voicey Pizz 3", "101 Sitar 2", "102 Drone Split 4", "103 Ethnopluck 4", "104 Jamisen 2", "105 Dulcimer 2", "106 East Melody 2", "107 MandolinTrem 4", "108 Nylon Gtr 1", "109 Gtr Strings 3", "110 Steel Away 3", "111 Heavenly Gtr 4", "112 12str Gtr 1 2", "113 12str Gtr 2 3", "114 Jz Gtr Hall 1", "115 LetterFrmPat 4", "116 Jazz Scat 3", "117 Lounge Gig 3", "118 JC Strat 1", "119 Twin Strats 3", "120 JV Strat 2", "121 Syn Strat 2", "122 Rotary Gtr 2", "123 Muted Gtr 1", "124 SwitchOnMute 2", "125 Power Trip 2", "126 Crunch Split 4", "127 Rezodrive 2", "128 RockYurSocks 4"])
      
      static let presetBOptions = OptionsParam.makeOptions(["1 DistGtr1 3", "2 DistGtr2 3", "3 R&R Chunk", "4 Phripphuzz", "5 Grungeroni", "6 Black Widow", "7 Velo-Wah Gtr", "8 Mod-Wah Gtr", "9 Pick Bass", "10 Hip Bass", "11 Perc.Bass", "12 Homey Bass", "13 Finger Bass", "14 Nylon Bass", "15 Ac.Upright", "16 Wet Fretls", "17 Fretls Dry", "18 Slap Bass 1", "19 Slap Bass 2", "20 Slap Bass 3", "21 Slap Bass 4", "22 4 Pole Bass", "23 Tick Bass", "24 House Bass", "25 Mondo Bass", "26 Clk AnalogBs", "27 Bass In Face", "28 101 Bass", "29 Noiz Bass", "30 Super Jup Bs", "31 Occitan Bass", "32 Hugo Bass", "33 Multi Bass", "34 Moist Bass", "35 BritelowBass", "36 Untamed Bass", "37 Rubber Bass", "38 Stereoww Bs", "39 Wonder Bass", "40 Deep Bass", "41 Super JX Bs", "42 W<RED>-Bass", "43 HI-Ring Bass", "44 Euro Bass", "45 SinusoidRave", "46 Alternative", "47 Acid Line", "48 Auto TB-303", "49 Hihat Tekno", "50 Velo Tekno 1", "51 Raggatronic", "52 Blade Racer", "53 S&H Pad", "54 Syncrosonix", "55 Fooled Again", "56 Alive", "57 Velo Tekno 2", "58 Rezoid", "59 Raverborg", "60 Blow Hit", "61 Hammer Bell", "62 Seq Mallet", "63 Intentions", "64 Pick It", "65 Analog Seq", "66 Impact Vox", "67 TeknoSoloVox 2", "68 X-Mod Man 2", "69 Paz <==> Zap 1", "70 4 Hits 4 You 4", "71 Impact 4", "72 Phase Hit 3", "73 Tekno Hit 1 2", "74 Tekno Hit 2 2", "75 Tekno Hit 3 4", "76 Reverse Hit 3", "77 SquareLead 1 3", "78 SquareLead 2 2", "79 You and Luck 2", "80 Belly Lead 4", "81 WhistlinAtom 2", "82 Edye Boost 2", "83 MG Solo 4", "84 FXM Saw Lead 4", "85 Sawteeth 3", "86 Smoothe 2", "87 MG Lead 2", "88 MG Interval 4", "89 Pulse Lead 1 3", "90 Pulse Lead 2 4", "91 Little Devil 4", "92 Loud SynLead 4", "93 Analog Lead 2", "94 5th Lead 2", "95 Flute 2", "96 Piccolo 1", "97 VOX Flute 4", "98 Air Lead 2", "99 Pan Pipes 2", "100 Airplaaane 4", "101 Taj Mahal 1", "102 Raya Shaku 3", "103 Oboe mf 1", "104 Oboe Express 2", "105 Clarinet mp 1", "106 ClariExpress 2", "107 Mitzva Split 4", "108 ChamberWinds 4", "109 ChamberWoods 3", "110 Film Orch 4", "111 Sop.Sax mf 2", "112 Alto Sax 3", "113 AltoLead Sax 3", "114 Tenor Sax 3", "115 Baritone Sax 3", "116 Take A Tenor 4", "117 Sax Section 4", "118 Bigband Sax 4", "119 Harmonica 2", "120 Harmo Blues 2", "121 BluesHarp 1", "122 Hillbillys 4", "123 French Bags 4", "124 Majestic Tpt 1", "125 Voluntare 2", "126 2Trumpets 2", "127 Tpt Sect 4", "128 Mute TP mod"])
      static let presetCOptions = OptionsParam.makeOptions(["1 Harmon Mute", "2 Tp&Sax Sect", "3 Sax+Tp+Tb", "4 Brass Sect", "5 Trombone", "6 Hybrid Bones", "7 Noble Horns", "8 Massed Horns", "9 Horn Swell", "10 Brass It!", "11 Brass Attack", "12 Archimede", "13 Rugby Horn", "14 MKS-80 Brass", "15 True ANALOG", "16 Dark Vox", "17 RandomVowels", "18 Angels Sing", "19 Pvox Oooze", "20 Longing...", "21 Arasian Morn", "22 Beauty Vox", "23 Mary-AnneVox", "24 Belltree Vox", "25 Vox Panner", "26 Spaced Voxx", "27 Glass Voices", "28 Tubular Vox", "29 Velo Voxx", "30 Wavox", "31 Doos", "32 Synvox Comps", "33 Vocal Oohz", "34 LFO Vox", "35 St.Strings", "36 Warm Strings", "37 Somber Str", "38 Marcato", "39 Bright Str", "40 String Ens", "41 TremoloStrng", "42 Chambers", "43 ViolinCello", "44 Symphonique", "45 Film Octaves", "46 Film Layers", "47 Bass Pizz", "48 Real Pizz", "49 Harp On It", "50 Harp", "51 JP-8 Str 1", "52 JP-8 Str 2", "53 E-Motion Pad", "54 JP-8 Str 3", "55 Vintage Orch", "56 JUNO Strings", "57 Gigantalog", "58 PWM Strings", "59 Warmth", "60 ORBit Pad", "61 Deep Strings", "62 Pulsify", "63 Pulse Pad", "64 Greek Power", "65 Harmonicum 2", "66 D-50 Heaven 2", "67 Afro Horns 3", "68 Pop Pad 4", "69 Dreamesque 4", "70 Square Pad 4", "71 JP-8 Hollow 4", "72 JP-8Haunting 4", "73 Heirborne 4", "74 Hush Pad 4", "75 Jet Pad 1 2", "76 Jet Pad 2 2", "77 Phaze Pad 3", "78 Phaze Str 4", "79 Jet Str Ens 2", "80 Pivotal Pad 4", "81 3D Flanged 1", "82 Fantawine 4", "83 Glassy Pad 3", "84 Moving Glass 1", "85 Glasswaves 3", "86 Shiny Pad 4", "87 ShiftedGlass 2", "88 Chime Pad 3", "89 Spin Pad 2", "90 Rotary Pad 4", "91 Dawn 2 Dusk 3", "92 Aurora 4", "93 Strobe Mode 4", "94 Albion 2", "95 Running Pad 4", "96 Stepped Pad 4", "97 Random Pad 4", "98 SoundtrkDANC 4", "99 Flying Waltz 4", "100 Vanishing 1", "101 5th Sweep 4", "102 Phazweep 4", "103 Big BPF 4", "104 MG Sweep 4", "105 CeremonyTimp 3", "106 Dyno Toms 4", "107 Sands ofTime 4", "108 Inertia 4", "109 Vektogram 4", "110 Crash Pad 4", "111 Feedback VOX 4", "112 Cascade 1", "113 Shattered 2", "114 NextFrontier 2", "115 Pure Tibet 1", "116 Chime Wash 4", "117 Night Shade 4", "118 Tortured 4", "119 Dissimilate 4", "120 Dunes 4", "121 Ocean Floor 1", "122 Cyber Space 3", "123 Biosphere 2", "124 Variable Run 4", "125 Ice Hall 2", "126 ComputerRoom 4", "127 Inverted 4", "128 Terminate 3"])
      static let gmOptions = OptionsParam.makeOptions(["1 Piano 1", "2 Piano 2", "3 Piano 3", "4 Honky-tonk", "5 E.Piano 1", "6 E.Piano 2", "7 Harpsichord", "8 Clav.", "9 Celesta", "10 Glockenspiel", "11 Music Box", "12 Vibraphone", "13 Marimba", "14 Xylophone", "15 Tubular-bell", "16 Santur", "17 Organ 1", "18 Organ 2", "19 Organ 3", "20 Church Org.1", "21 Reed Organ", "22 Accordion Fr", "23 Harmonica", "24 Bandneon", "25 Nylon-str.Gt", "26 Steel-str.Gt", "27 Jazz Gt.", "28 Clean Gt.", "29 Muted Gt.", "30 Overdrive Gt", "31 DistortionGt", "32 Gt.Harmonics", "33 Acoustic Bs.", "34 Fingered Bs.", "35 Picked Bs.", "36 Fretless Bs.", "37 Slap Bass 1", "38 Slap Bass 2", "39 Synth Bass 1", "40 Synth Bass 2", "41 Violin", "42 Viola", "43 Cello", "44 Contrabass", "45 Tremolo Str", "46 PizzicatoStr", "47 Harp", "48 Timpani", "49 Strings", "50 Slow Strings", "51 Syn.Strings1", "52 Syn.Strings2", "53 Choir Aahs", "54 Voice Oohs", "55 SynVox", "56 OrchestraHit", "57 Trumpet", "58 Trombone", "59 Tuba", "60 MutedTrumpet", "61 French Horn", "62 Brass 1", "63 Synth Brass1", "64 Synth Brass2", "65 Soprano Sax 1", "66 Alto Sax 1", "67 Tenor Sax 1", "68 Baritone Sax 2", "69 Oboe 2", "70 English Horn 2", "71 Bassoon 2", "72 Clarinet 1", "73 Piccolo 1", "74 Flute 1", "75 Recorder 2", "76 Pan Flute 2", "77 Bottle Blow 2", "78 Shakuhachi 1", "79 Whistle 1", "80 Ocarina 2", "81 Square Wave 2", "82 Saw Wave 2", "83 Syn.Calliope 2", "84 Chiffer Lead 2", "85 Charang 3", "86 Solo Vox 2", "87 5th Saw Wave 3", "88 Bass & Lead 2", "89 Fantasia 3", "90 Warm Pad 2", "91 Polysynth 2", "92 Space Voice 2", "93 Bowed Glass 3", "94 Metal Pad 2", "95 Halo Pad 3", "96 Sweep Pad 2", "97 Ice Rain 2", "98 Soundtrack 2", "99 Crystal 2", "100 Atmosphere 2", "101 Brightness 3", "102 Goblin 2", "103 Echo Drops 2", "104 Star Theme 2", "105 Sitar 1", "106 Banjo 1", "107 Shamisen 2", "108 Koto 1", "109 Kalimba 1", "110 Bag Pipe 3", "111 Fiddle 1", "112 Shanai 1", "113 Tinkle Bell 4", "114 Agogo 1", "115 Steel Drums 1", "116 Woodblock 1", "117 Taiko 4", "118 Melo. Tom 1 2", "119 Synth Drum 2", "120 Reverse Cym. 2", "121 Gt.FretNoise 1", "122 Breath Noise 2", "123 Seashore 3", "124 Bird 4", "125 Telephone 1 1", "126 Helicopter 2", "127 Applause 4", "128 Gun Shot"])
      
      
      static let rhythmPresetAOptions = OptionsParam.makeOptions(["1 PopDrumSet 1", "2 PopDrumSet 2"])
      static let rhythmPresetBOptions = OptionsParam.makeOptions(["1 PowerDrumSet", "2 RaveDrumSet"])
      static let rhythmPresetCOptions = OptionsParam.makeOptions(["1 JazzDrumSet2", "2 OrchDrumSet"])
      static let rhythmGMOptions = OptionsParam.makeOptions(["1 GM Drum Set", "2 BrushDrumSet"])
    }

    
  }
  
}
