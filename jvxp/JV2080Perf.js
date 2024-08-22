
extension JV2080 {
  
  enum Perf {
    
    static let patchWerk = JVXP.Perf.patchWerk(common: Common.patchWerk, part: Part.patchWerk, initFile: "")
    
    static let bankWerk = JVXP.Perf.bankWerk(patchWerk)

    enum Common {
      
      static let patchWerk = JVXP.Perf.Common.patchWerk(parms.params(), 0x44)
      
      static let parms = XP50.Perf.Common.parms + [
        .p([.clock, .src], 0x41, .opts(["Perform","System"])), // diff options
        .p([.fx, .i(1), .src], 0x42, .options(JV1080.Perf.Common.fxSrcOptions)),
        .p([.fx, .i(2), .src], 0x43, .options(JV1080.Perf.Common.fxSrcOptions)),
      ]
    }

    enum Part {
      
      static let patchWerk = JVXP.Perf.Part.patchWerk(parms.params(), 0x1a)
      
      static let parms = XP50.Perf.Part.parms + [
        .p([.out, .select], 0x19, .opts(["A","B","C"]))
      ]
      
      static let config: JV1080.Perf.CtrlConfig = .init(voicePresets: voicePresetOptionMap, rhythmPresets: rhythmPresetOptionMap, blank: JV1080.Perf.Part.blankPatchOptions, patchGroups: patchGroupOptions, hasOutSelect: true)

      static let patchGroupOptions = JV1080.Perf.Part.patchGroupOptions <<< [
        (7 - 100) : "Preset-E"
      ]
      
      static let voicePresetOptionMap = JV1080.Perf.Part.voicePresetOptionMap <<< [
        7 : presetEOptions
      ]

      static let rhythmPresetOptionMap = JV1080.Perf.Part.rhythmPresetOptionMap <<< [
        7 : rhythmPresetEOptions
      ]
      
      static let presetEOptions = OptionsParam.makeOptions(["001 Echo Piano", "002 Upright Pno", "003 RD-1000", "004 Player's EP", "005 D-50 Rhodes", "006 Innocent EP", "007 Echo Rhodes", "008 See-Thru EP", "009 FM Bel Piano", "010 Ring E.Piano", "011 Soap Opera", "012 Dirty Organ", "013 Surf's Up!", "014 Organesque", "015 pp Harmonium", "016 PieceOfCheez", "017 Harpsy Clav", "018 Exotic Velo", "019 HolidayCheer", "020 Morning Lite", "021 Prefab Chime", "022 Belfry Chime", "023 Stacc. Heaven", "024 2.2 Bell Pad", "025 Far East", "026 Wire Pad", "027 Phase Blipper", "028 Sweep Clav", "029 Glider", "030 Solo Steel", "031 DesertCrysti", "032 Clear Guitar", "033 Solo Strat", "034 Feed Me!", "035 Tube Smoke", "036 Creamy", "037 Blusey OD", "038 Grindstone", "039 OD 5ths", "040 East Europe", "041 Dulcitar", "042 Atmos Harp", "043 Pilgrimage", "044 202 Rude Bs", "045 2pole Bass", "046 4pole Bass", "047 Phaser MC", "048 Miniphaser", "049 Acid TB", "050 Full Orchest", "051 Str + Winds", "052 Flute 2080", "053 Scat Flute", "054 Sax Choir", "055 Ballad Trump", "056 Sm.Brass Grp", "057 Royale", "058 Brass Mutes", "059 Breathy Brs", "060 3 Osc Brass", "061 P5 Polymod", "062 Triumph Brs", "063 Techno Dream", "064 Organizer", "065 Civilization", "066 Mental Chord", "067 House Chord", "068 Sequalog", "069 Booster Bips", "070 VintagePlunk", "071 Plik-Plok", "072 RingSequence", "073 Cyber Swing", "074 Keep :-)", "075 Resojuice", "076 B'on d'moov!", "077 Dist TB-303", "078 Temple of JV", "079 Planet Asia", "080 Afterlife", "081 Trancing Pad", "082 Pulsatronic", "083 Cyber Dreams", "084 Warm Pipe", "085 Pure Pipe", "086 SH-2000", "087 X..? Whistle", "088 Jay Vee Solo", "089 Progresso Ld", "090 Adrenaline", "091 Enlighten", "092 Glass Blower", "093 Earth Blow", "094 JX SqrCarpet", "095 Dimensional", "096 Jupiterings", "097 Analog Drama", "098 Rich Dynapad", "099 Silky Way", "100 Gluey Pad", "101 BandPass Mod", "102 Soundtraque", "103 Translucence", "104 Darkshine", "105 D'light", "106 December Sky", "107 Octapad", "108 JUNO Power!", "109 Spectrum Mod", "110 Stringsheen", "111 GR500 TmpDly", "112 Mod Dirty Wav", "113 Silicon Str", "114 D50FantaPerc", "115 Rotodreams", "116 Blue Notes", "117 Rivers OfTime", "118 Phobos", "119 2 0 8 0", "120 Unearthly", "121 Glistening", "122 Sci-Fi Str", "123 Shadows", "124 Helium Queen", "125 Sci-Fi FX x4", "126 Perky Noize", "127 Droplet", "128 Rain Forest"])

      static let rhythmPresetEOptions = OptionsParam.makeOptions(["1 PowerDrmSet2", "2 PowerRaveSet"])
    }

  }
  
}
