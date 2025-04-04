
extension XV {
  
  enum Voice {
    
    static func patchWerk(common: RolandSinglePatchTrussWerk, tone: RolandSinglePatchTrussWerk, fx: RolandSinglePatchTrussWerk, chorus: RolandSinglePatchTrussWerk, reverb: RolandSinglePatchTrussWerk, initFile: String) -> RolandMultiPatchTrussWerk {
      sysexWerk.multiPatchWerk("Voice", [
        ([.common], 0x0000, common),
        ([.fx], 0x0200, fx),
        ([.chorus], 0x0400, chorus),
        ([.reverb], 0x0600, reverb),
        ([.mix], 0x1000, XV5050.Voice.ToneMix.patchWerk),
        ([.tone, .i(0)], 0x2000, tone),
        ([.tone, .i(1)], 0x2200, tone),
        ([.tone, .i(2)], 0x2400, tone),
        ([.tone, .i(3)], 0x2600, tone),
      ], start: 0x1f000000, initFile: initFile)
    }
    
    static func bankWerk(_ patchWerk: RolandMultiPatchTrussWerk) -> RolandMultiBankTrussWerk {
      sysexWerk.multiBankWerk(patchWerk, 128, start: 0x30000000, initFile: "xv5050-voice-bank-init")
    }
    
    enum Common {
      
      static func patchWerk(_ params: SynthPathParam) -> RolandSinglePatchTrussWerk {
        try! sysexWerk.singlePatchWerk("Voice Common", params, size: 0x4f, start: 0x0000, name: .basic(0..<0x0c), randomize: {
          let vals: [SynthPath:Int] = [
            [.tone, .type] : 0,
            [.level] : 127,
            [.pan] : 64,
            [.out, .assign] : 13,
            [.coarse] : 64,
            [.fine] : 64,
            [.octave, .shift] : 64,
            [.cutoff] : 64,
            [.reson] : 64,
            [.attack] : 64,
            [.release] : 64,
            [.velo] : 64,
          ] <<< 4.dict { ctrl in
            [[.mtrx, .ctrl, .i(ctrl), .src] : 0] <<< 4.dict(transform: { dest in
              [
                [.mtrx, .ctrl, .i(ctrl), .dest, .i(dest)] : 0,
                [.mtrx, .ctrl, .i(ctrl), .amt, .i(dest)] : 64,
              ]
            })
          }
          return SynthPathInts(vals)
        })
        
      }
      
    }
    

    enum Tone {
      
      static func patchWerk(params: SynthPathParam) -> RolandSinglePatchTrussWerk {
        try! XV.sysexWerk.singlePatchWerk("Voice Tone", params, size: 0x0109, start: 0x2000, randomize: { [
          [.wave, .group] : 0,
          [.wave, .group, .id] : 1,
          [.wave, .number, .i(0)] : (1...651).rand(),
          [.wave, .number, .i(1)] : 0,
          [.delay, .mode] : 0,
          [.delay, .time] : 0,
          [.level] : 127,
          [.pan] : (54...74).rand(),
          [.out, .assign] : (0...1).rand(),
          [.dry] : 127,

          [.coarse] : (57...71).rand(),
          [.fine] : (57...71).rand(),
          [.random, .pitch] : 0,
          [.pitch, .keyTrk] : 74,

          [.pitch, .env, .depth] : 64,

          [.velo, .fade, .depth] : 0,
          [.velo, .range, .lo] : 1,
          [.velo, .range, .hi] : 127,
          [.key, .range, .lo] : 0,
          [.key, .range, .hi] : 127,

          [.filter, .env, .depth] : (64...80).rand(),
          [.amp, .env, .velo] : (54...127).rand(),
          [.amp, .env, .velo, .time, .i(0)] : 64,
          [.amp, .env, .velo, .time, .i(3)] : 64,
          [.amp, .env, .time, .i(0)] : (0...30).rand(),
          [.amp, .env, .time, .i(1)] : (30...40).rand(),
          [.amp, .env, .time, .i(2)] : (20...80).rand(),
          [.amp, .env, .time, .i(3)] : (0...80).rand(),
          [.amp, .env, .level, .i(0)] : 127,
          [.amp, .env, .level, .i(1)] : (30...127).rand(),
          [.amp, .env, .level, .i(2)] : (30...127).rand(),

          [.lfo, .i(0), .pitch] : (54...84).rand(),
          [.lfo, .i(1), .pitch] : (54...84).rand(),
          [.bias, .level] : 64,
        ] })
      }
            
      /// (Wave Group Type, Wave Group ID)
      static func waveGroup(forValue value: Int) -> (Int, Int) {
        (value / 100, value % 100)
      }
      
      static func value(forWaveGroup waveGroup: Int, id: Int) -> Int {
        (waveGroup * 100) + id
      }
      
      
      static let blankWaveOptions = OptionsParam.makeOptions((1...255).map { "\($0)" })
      
      static let internalWaveNames = ["Off", "StGrand pA L", "StGrand pA R", "StGrand pB L", "StGrand pB R", "StGrand pC L", "StGrand pC R", "StGrand fA L", "StGrand fA R", "StGrand fB L", "StGrand fB R", "StGrand fC L", "StGrand fC R", "Ac Piano2 pA", "Ac Piano2 pB", "Ac Piano2 pC", "Ac Piano2 fA", "Ac Piano2 fB", "Ac Piano2 fC", "Ac Piano1 A", "Ac Piano1 B", "Ac Piano1 C", "Piano Thump", "Piano Up TH", "Piano Atk", "MKS-20 P3 A", "MKS-20 P3 B", "MKS-20 P3 C", "SA Rhodes 1A", "SA Rhodes 1B", "SA Rhodes 1C", "SA Rhodes 2A", "SA Rhodes 2B", "SA Rhodes 2C", "Dyn Rhd mp A", "Dyn Rhd mp B", "Dyn Rhd mp C", "Dyn Rhd mf A", "Dyn Rhd mf B", "Dyn Rhd mf C", "Dyn Rhd ff A", "Dyn Rhd ff B", "Dyn Rhd ff C", "Wurly soft A", "Wurly soft B", "Wurly soft C", "Wurly hard A", "Wurly hard B", "Wurly hard C", "E.Piano 1A", "E.Piano 1B", "E.Piano 1C", "E.Piano 2A", "E.Piano 2B", "E.Piano 2C", "E.Piano 3A", "E.Piano 3B", "E.Piano 3C", "MK-80 EP A", "MK-80 EP B", "MK-80 EP C", "EP Hard", "EP Distone", "Clear Keys", "D-50 EP A", "D-50 EP B", "D-50 EP C", "Celesta", "Music Box", "Music Box 2", "Clav 1A", "Clav 1B", "Clav 1C", "Clav 2A", "Clav 2B", "Clav 2C", "Clav 3A", "Clav 3B", "Clav 3C", "Clav 4A", "Clav 4B", "Clav 4C", "Clav Wave", "MIDI Clav", "HarpsiWave A", "HarpsiWave B", "HarpsiWave C", "Jazz Organ 1", "Jazz Organ 2", "Organ 1", "Organ 2", "Organ 3", "Organ 4", "60's Organ1", "60's Organ2", "60's Organ3", "60's Organ4", "Full Organ", "Full Draw", "Rock Organ", "RockOrg1 A L", "RockOrg1 A R", "RockOrg1 B L", "RockOrg1 B R", "RockOrg1 C L", "RockOrg1 C R", "RockOrg2 A L", "RockOrg2 A R", "RockOrg2 B L", "RockOrg2 B R", "RockOrg2 C L", "RockOrg2 C R", "RockOrg3 A L", "RockOrg3 A R", "RockOrg3 B L", "RockOrg3 B R", "RockOrg3 C L", "RockOrg3 C R", "Dist. Organ", "Rot.Org Slw", "Rot.Org Fst", "Pipe Organ", "Soft Nylon A", "Soft Nylon B", "Soft Nylon C", "Nylon Gtr A", "Nylon Gtr B", "Nylon Gtr C", "Nylon Str", "6-Str Gtr A", "6-Str Gtr B", "6-Str Gtr C", "StlGtr mp A", "StlGtr mp B", "StlGtr mp C", "StlGtr mf A", "StlGtr mf B", "StlGtr mf C", "StlGtr ff A", "StlGtr ff B", "StlGtr ff C", "StlGtr sld A", "StlGtr sld B", "StlGtr sld C", "StlGtr Hrm A", "StlGtr Hrm B", "StlGtr Hrm C", "Gtr Harm A", "Gtr Harm B", "Gtr Harm C", "Jazz Gtr A", "Jazz Gtr B", "Jazz Gtr C", "LP Rear A", "LP Rear B", "LP Rear C", "Rock lead 1", "Rock lead 2", "Comp Gtr A", "Comp Gtr B", "Comp Gtr C", "Comp Gtr A+", "Mute Gtr 1", "Mute Gtr 2A", "Mute Gtr 2B", "Mute Gtr 2C", "Muters", "Pop Strat A", "Pop Strat B", "Pop Strat C", "JC Strat A", "JC Strat B", "JC Strat C", "JC Strat A+", "JC Strat B+", "JC Strat C+", "Clean Gtr A", "Clean Gtr B", "Clean Gtr C", "Stratus A", "Stratus B", "Stratus C", "Scrape Gut", "Strat Sust", "Strat Atk", "OD Gtr A", "OD Gtr B", "OD Gtr C", "OD Gtr A+", "Heavy Gtr A", "Heavy Gtr B", "Heavy Gtr C", "Heavy Gtr A+", "Heavy Gtr B+", "Heavy Gtr C+", "PowerChord A", "PowerChord B", "PowerChord C", "EG Harm", "Gt.FretNoise", "Syn Gtr A", "Syn Gtr B", "Syn Gtr C", "Harp 1A", "Harp 1B", "Harp 1C", "Harp Harm", "Pluck Harp", "Banjo A", "Banjo B", "Banjo C", "Sitar A", "Sitar B", "Sitar C", "E.Sitar A", "E.Sitar B", "E.Sitar C", "Santur A", "Santur B", "Santur C", "Dulcimer A", "Dulcimer B", "Dulcimer C", "Shamisen A", "Shamisen B", "Shamisen C", "Koto A", "Koto B", "Koto C", "Taishokoto A", "Taishokoto B", "Taishokoto C", "Pick Bass A", "Pick Bass B", "Pick Bass C", "Fingerd Bs A", "Fingerd Bs B", "Fingerd Bs C", "E.Bass", "P.Bass 1", "P.Bass 2", "Stick", "Fretless A", "Fretless B", "Fretless C", "Fretless 2A", "Fretless 2B", "Fretless 2C", "UprightBs 1", "UprightBs 2A", "UprightBs 2B", "UprightBs 2C", "Ac.Bass A", "Ac.Bass B", "Ac.Bass C", "Slap Bass 1", "Slap & Pop", "Slap Bass 2", "Slap Bass 3", "Jz.Bs Thumb", "Jz.Bs Slap 1", "Jz.Bs Slap 2", "Jz.Bs Slap 3", "Jz.Bs Pop", "Funk Bass1", "Funk Bass2", "Syn Bass A", "Syn Bass C", "Syn Bass", "Syn Bass 2 A", "Syn Bass 2 B", "Syn Bass 2 C", "Mini Bs 1A", "Mini Bs 1B", "Mini Bs 1C", "Mini Bs 2", "Mini Bs 2+", "MC-202 Bs A", "MC-202 Bs B", "MC-202 Bs C", "Hollow Bs", "Flute 1A", "Flute 1B", "Flute 1C", "Jazz Flute A", "Jazz Flute B", "Jazz Flute C", "Flute Tone", "Piccolo A", "Piccolo B", "Piccolo C", "Blow Pipe", "Pan Pipe", "BottleBlow", "Rad Hose", "Shakuhachi", "Shaku Atk", "Flute Push", "Clarinet A", "Clarinet B", "Clarinet C", "Oboe mf A", "Oboe mf B", "Oboe mf C", "Oboe f A", "Oboe f B", "Oboe f C", "E.Horn A", "E.Horn B", "E.Horn C", "Bassoon A", "Bassoon B", "Bassoon C", "T_Recorder A", "T_Recorder B", "T_Recorder C", "Sop.Sax A", "Sop.Sax B", "Sop.Sax C", "Sop.Sax mf A", "Sop.Sax mf B", "Sop.Sax mf C", "Alto mp A", "Alto mp B", "Alto mp C", "Alto Sax 1A", "Alto Sax 1B", "Alto Sax 1C", "T.Breathy A", "T.Breathy B", "T.Breathy C", "SoloSax A", "SoloSax B", "SoloSax C", "Tenor Sax A", "Tenor Sax B", "Tenor Sax C", "T.Sax mf A", "T.Sax mf B", "T.Sax mf C", "Bari.Sax f A", "Bari.Sax f B", "Bari.Sax f C", "Bari.Sax A", "Bari.Sax B", "Bari.Sax C", "Syn Sax", "Chanter", "Harmonica A", "Harmonica B", "Harmonica C", "OrcUnisonA L", "OrcUnisonA R", "OrcUnisonB L", "OrcUnisonB R", "OrcUnisonC L", "OrcUnisonC R", "BrassSectA L", "BrassSectA R", "BrassSectB L", "BrassSectB R", "BrassSectC L", "BrassSectC R", "Tpt Sect. A", "Tpt Sect. B", "Tpt Sect. C", "Tb Sect A", "Tb Sect B", "Tb Sect C", "T.Sax Sect A", "T.Sax Sect B", "T.Sax Sect C", "Flugel A", "Flugel B", "Flugel C", "FlugelWave", "Trumpet 1A", "Trumpet 1B", "Trumpet 1C", "Trumpet 2A", "Trumpet 2B", "Trumpet 2C", "HarmonMute1A", "HarmonMute1B", "HarmonMute1C", "Trombone 1", "Trombone 2 A", "Trombone 2 B", "Trombone 2 C", "Tuba A", "Tuba B", "Tuba C", "French 1A", "French 1C", "F.Horns A", "F.Horns B", "F.Horns C", "Violin A", "Violin B", "Violin C", "Violin 2 A", "Violin 2 B", "Violin 2 C", "Cello A", "Cello B", "Cello C", "Cello 2 A", "Cello 2 B", "Cello 2 C", "Cello Wave", "Pizz", "STR Attack A", "STR Attack B", "STR Attack C", "DolceStr.A L", "DolceStr.A R", "DolceStr.B L", "DolceStr.B R", "DolceStr.C L", "DolceStr.C R", "JV Strings L", "JV Strings R", "JV Strings A", "JV Strings C", "JP Strings1A", "JP Strings1B", "JP Strings1C", "JP Strings2A", "JP Strings2B", "JP Strings2C", "PWM", "Pulse Mod", "Soft Pad A", "Soft Pad B", "Soft Pad C", "Fantasynth A", "Fantasynth B", "Fantasynth C", "D-50 HeavenA", "D-50 HeavenB", "D-50 HeavenC", "Fine Wine", "D-50 Brass A", "D-50 Brass B", "D-50 Brass C", "D-50 BrassA+", "Doo", "Pop Voice", "Syn Vox 1", "Syn Vox 2", "Voice Aahs A", "Voice Aahs B", "Voice Aahs C", "Voice Oohs1A", "Voice Oohs1B", "Voice Oohs1C", "Voice Oohs2A", "Voice Oohs2B", "Voice Oohs2C", "Choir 1A", "Choir 1B", "Choir 1C", "Oohs Chord L", "Oohs Chord R", "Male Ooh A", "Male Ooh B", "Male Ooh C", "Org Vox A", "Org Vox B", "Org Vox C", "Org Vox", "ZZZ Vox", "Bell VOX", "Kalimba", "JD Kalimba", "Klmba Atk", "Wood Crak", "Block", "Gamelan 1", "Gamelan 2", "Gamelan 3", "Log Drum", "Hooky", "Tabla", "Marimba Wave", "Xylo", "Xylophone", "Vibes", "Bottle Hit", "Glockenspiel", "Tubular", "Steel Drums", "Pole lp", "Fanta Bell A", "Fanta Bell B", "Fanta Bell C", "FantaBell A+", "Org Bell", "AgogoBells", "FingerBell", "DIGI Bell 1", "DIGI Bell 1+", "JD Cowbell", "Bell Wave", "Chime", "Crystal", "2.2 Bellwave", "2.2 Vibwave", "Digiwave", "DIGI Chime", "JD DIGIChime", "BrightDigi", "Can Wave 1", "Can Wave 2", "Vocal Wave", "Wally Wave", "Brusky lp", "Wave Scan", "Wire String", "Nasty", "Wave Table", "Klack Wave", "Spark VOX", "JD Spark VOX", "Cutters", "EML 5th", "MMM VOX", "Lead Wave", "Synth Reed", "Synth Saw 1", "Synth Saw 2", "Syn Saw 2inv", "Synth Saw 3", "JD Syn Saw 2", "FAT Saw", "JP-8 Saw A", "JP-8 Saw B", "JP-8 Saw C", "P5 Saw A", "P5 Saw B", "P5 Saw C", "P5 Saw2 A", "P5 Saw2 B", "P5 Saw2 C", "D-50 Saw A", "D-50 Saw B", "D-50 Saw C", "Synth Square", "JP-8 SquareA", "JP-8 SquareB", "JP-8 SquareC", "DualSquare A", "DualSquare C", "DualSquareA+", "JD SynPulse1", "JD SynPulse2", "JD SynPulse3", "JD SynPulse4", "Synth Pulse1", "Synth Pulse2", "JD SynPulse5", "Sync Sweep", "Triangle", "JD Triangle", "Sine", "Metal Wind", "Wind Agogo", "Feedbackwave", "Spectrum", "CrunchWind", "ThroatWind", "Pitch Wind", "JD Vox Noise", "Vox Noise", "BreathNoise", "Voice Breath", "White Noise", "Pink Noise", "Rattles", "Ice Rain", "Tin Wave", "Anklungs", "Wind Chimes", "Orch. Hit", "Tekno Hit", "Back Hit", "Philly Hit", "Scratch 1", "Scratch 2", "Scratch 3", "Shami", "Org Atk 1", "Org Atk 2", "Sm Metal", "StrikePole", "Thrill", "Switch", "Tuba Slap", "Plink", "Plunk", "EP Atk", "TVF_Trig", "Org Click", "Cut Noiz", "Bass Body", "Flute Click", "Gt&BsNz MENU", "Ac.BassNz 1", "Ac.BassNz 2", "El.BassNz 1", "El.BassNz 2", "DistGtrNz 1", "DistGtrNz 2", "DistGtrNz 3", "DistGtrNz 4", "SteelGtrNz 1", "SteelGtrNz 2", "SteelGtrNz 3", "SteelGtrNz 4", "SteelGtrNz 5", "SteelGtrNz 6", "SteelGtrNz 7", "Sea", "Thunder", "Windy", "Stream", "Bubble", "Bird", "Dog Bark", "Horse", "Telephone 1", "Telephone 2", "Creak", "Door Slam", "Engine", "Car Stop", "Car Pass", "Crash", "Gun Shot", "Siren", "Train", "Jetplane", "Starship", "Breath", "Laugh", "Scream", "Punch", "Heart", "Steps", "Machine Gun", "Laser", "Thunder 2", "AmbientSN pL", "AmbientSN pR", "AmbientSN fL", "AmbientSN fR", "Wet SN p L", "Wet SN p R", "Wet SN f L", "Wet SN f R", "Dry SN p", "Dry SN f", "Sharp SN", "Piccolo SN", "Maple SN", "Old Fill SN", "70s SN", "SN Roll", "Natural SN1", "Natural SN2", "Ballad SN", "Rock SN p L", "Rock SN p R", "Rock SN mf L", "Rock SN mf R", "Rock SN f L", "Rock SN f R", "Rock Rim p L", "Rock Rim p R", "Rock Rim mfL", "Rock Rim mfR", "Rock Rim f L", "Rock Rim f R", "Rock Gst L", "Rock Gst R", "Snare Ghost", "Jazz SN p L", "Jazz SN p R", "Jazz SN mf L", "Jazz SN mf R", "Jazz SN f L", "Jazz SN f R", "Jazz SN ff L", "Jazz SN ff R", "Jazz Rim p L", "Jazz Rim p R", "Jazz Rim mfL", "Jazz Rim mfR", "Jazz Rim f L", "Jazz Rim f R", "Jazz Rim ffL", "Jazz Rim ffR", "Brush Slap", "Brush Swish", "Jazz Swish p", "Jazz Swish f", "909 SN 1", "909 SN 2", "808 SN", "Rock Roll L", "Rock Roll R", "Jazz Roll", "Brush Roll", "Dry Stick", "Dry Stick 2", "Side Stick", "Woody Stick", "RockStick pL", "RockStick pR", "RockStick fL", "RockStick fR", "Dry Kick", "Maple Kick", "Rock Kick p", "Rock Kick mf", "Rock Kick f", "Jazz Kick p", "Jazz Kick mf", "Jazz Kick f", "Jazz Kick", "Pillow Kick", "JazzDry Kick", "Lite Kick", "Old Kick", "Hybrid Kick", "Hybrid Kick2", "Verb Kick", "Round Kick", "MplLmtr Kick", "70s Kick 1", "70s Kick 2", "Dance Kick", "808 Kick", "909 Kick 1", "909 Kick 2", "Rock TomL1 p", "Rock TomL2 p", "Rock Tom M p", "Rock Tom H p", "Rock TomL1 f", "Rock TomL2 f", "Rock Tom M f", "Rock Tom H f", "Rock Flm L1", "Rock Flm L2", "Rock Flm M", "Rock Flm H", "Jazz Tom L p", "Jazz Tom M p", "Jazz Tom H p", "Jazz Tom L f", "Jazz Tom M f", "Jazz Tom H f", "Jazz Flm L", "Jazz Flm M", "Jazz Flm H", "Maple Tom 1", "Maple Tom 2", "Maple Tom 3", "Maple Tom 4", "808 Tom", "Verb Tom Hi", "Verb Tom Lo", "Dry Tom Hi", "Dry Tom Lo", "Rock ClHH1 p", "Rock ClHH1mf", "Rock ClHH1 f", "Rock ClHH2 p", "Rock ClHH2mf", "Rock ClHH2 f", "Jazz ClHH1 p", "Jazz ClHH1mf", "Jazz ClHH1 f", "Jazz ClHH2 p", "Jazz ClHH2mf", "Jazz ClHH2 f", "Cl HiHat 1", "Cl HiHat 2", "Cl HiHat 3", "Cl HiHat 4", "Cl HiHat 5", "Rock OpHH p", "Rock OpHH f", "Jazz OpHH p", "Jazz OpHH mf", "Jazz OpHH f", "Op HiHat", "Op HiHat 2", "Rock PdHH p", "Rock PdHH f", "Jazz PdHH p", "Jazz PdHH f", "Pedal HiHat", "Pedal HiHat2", "Dance Cl HH", "909 NZ HiHat", "70s Cl HiHat", "70s Op HiHat", "606 Cl HiHat", "606 Op HiHat", "909 Cl HiHat", "909 Op HiHat", "808 Claps", "HumanClapsEQ", "Tight Claps", "Hand Claps", "Finger Snaps", "Rock RdCym1p", "Rock RdCym1f", "Rock RdCym2p", "Rock RdCym2f", "Jazz RdCym p", "Jazz RdCymmf", "Jazz RdCym f", "Ride 1", "Ride 2", "Ride Bell", "Rock CrCym1p", "Rock CrCym1f", "Rock CrCym2p", "Rock CrCym2f", "Rock Splash", "Jazz CrCym p", "Jazz CrCym f", "Crash Cymbal", "Crash 1", "Rock China", "China Cym", "Cowbell", "Wood Block", "Claves", "Bongo Hi", "Bongo Lo", "Cga Open Hi", "Cga Open Lo", "Cga Mute Hi", "Cga Mute Lo", "Cga Slap", "Timbale", "Cabasa Up", "Cabasa Down", "Cabasa Cut", "Maracas", "Long Guiro", "Tambourine 1", "Tambourine 2", "Open Triangl", "Cuica", "Vibraslap", "Timpani", "Timp3 pp", "Timp3 mp", "Applause", "Syn FX Loop", "Loop 1", "Loop 2", "Loop 3", "Loop 4", "Loop 5", "Loop 6", "Loop 7", "R8 Click", "Metronome 1", "Metronome 2", "MC500 Beep 1", "MC500 Beep 2", "Low Saw", "Low Saw inv", "Low P5 Saw", "Low Pulse 1", "Low Pulse 2", "Low Square", "Low Sine", "Low Triangle", "Low White NZ", "Low Pink NZ", "DC", "REV Orch.Hit", "REV TeknoHit", "REV Back Hit", "REV PhillHit", "REV Steel DR", "REV Tin Wave", "REV AmbiSNpL", "REV AmbiSNpR", "REV AmbiSNfL", "REV AmbiSNfR", "REV Wet SNpL", "REV Wet SNpR", "REV Wet SNfL", "REV Wet SNfR", "REV Dry SN", "REV PiccloSN", "REV Maple SN", "REV OldFilSN", "REV 70s SN", "REV SN Roll", "REV NatrlSN1", "REV NatrlSN2", "REV BalladSN", "REV RkSNpL", "REV RkSNpR", "REV RkSNmfL", "REV RkSNmfR", "REV RkSNfL", "REV RkSNfR", "REV RkRimpL", "REV RkRimpR", "REV RkRimmfL", "REV RkRimmfR", "REV RkRimfL", "REV RkRimfR", "REV RkGstL", "REV RkGstR", "REV SnareGst", "REV JzSNpL", "REV JzSNpR", "REV JzSNmfL", "REV JzSNmfR", "REV JzSNfL", "REV JzSNfR", "REV JzSNffL", "REV JzSNffR", "REV JzRimpL", "REV JzRimpR", "REV JzRimmfL", "REV JzRimmfR", "REV JzRimfL", "REV JzRimfR", "REV JzRimffL", "REV JzRimffR", "REV Brush 1", "REV Brush 2", "REV Brush 3", "REV JzSwish1", "REV JzSwish2", "REV 909 SN 1", "REV 909 SN 2", "REV RkRoll L", "REV RkRoll R", "REV JzRoll", "REV Dry Stk", "REV DrySick", "REV Side Stk", "REV Wdy Stk", "REV RkStk1L", "REV RkStk1R", "REV RkStk2L", "REV RkStk2R", "REV Thrill", "REV Dry Kick", "REV Mpl Kick", "REV RkKik p", "REV RkKik mf", "REV RkKik f", "REV JzKik p", "REV JzKik mf", "REV JzKik f", "REV Jaz Kick", "REV Pillow K", "REV Jz Dry K", "REV LiteKick", "REV Old Kick", "REV Hybrid K", "REV HybridK2", "REV 70s K 1", "REV 70s K 2", "REV Dance K", "REV 909 K 2", "REV RkTomL1p", "REV RkTomL2p", "REV RkTomM p", "REV RkTomH p", "REV RkTomL1f", "REV RkTomL2f", "REV RkTomM f", "REV RkTomH f", "REV RkFlmL1", "REV RkFlmL2", "REV RkFlm M", "REV RkFlm H", "REV JzTomL p", "REV JzTomM p", "REV JzTomH p", "REV JzTomL f", "REV JzTomM f", "REV JzTomH f", "REV JzFlm L", "REV JzFlm M", "REV JzFlm H", "REV MplTom2", "REV MplTom4", "REV 808Tom", "REV VerbTomH", "REV VerbTomL", "REV DryTom H", "REV DryTom M", "REV RkClH1 p", "REV RkClH1mf", "REV RkClH1 f", "REV RkClH2 p", "REV RkClH2mf", "REV RkClH2 f", "REV JzClH1 p", "REV JzClH1mf", "REV JzClH1 f", "REV JzClH2 p", "REV JzClH2mf", "REV JzClH2 f", "REV Cl HH 1", "REV Cl HH 2", "REV Cl HH 3", "REV Cl HH 4", "REV Cl HH 5", "REV RkOpHH p", "REV RkOpHH f", "REV JzOpHH p", "REV JzOpHHmf", "REV JzOpHH f", "REV Op HiHat", "REV OpHiHat2", "REV RkPdHH p", "REV RkPdHH f", "REV JzPdHH p", "REV JzPdHH f", "REV PedalHH", "REV PedalHH2", "REV Dance HH", "REV 70s ClHH", "REV 70s OpHH", "REV 606 ClHH", "REV 606 OpHH", "REV 909 NZHH", "REV 909 OpHH", "REV HClapsEQ", "REV TghtClps", "REV FingSnap", "REV RealCLP", "REV RkRCym1p", "REV RkRCym1f", "REV RkRCym2p", "REV RkRCym2f", "REV JzRCym p", "REV JzRCymmf", "REV JzRCym f", "REV Ride 1", "REV Ride 2", "REV RideBell", "REV RkCCym1p", "REV RkCCym1f", "REV RkCCym2p", "REV RkCCym2f", "REV RkSplash", "REV JzCCym p", "REV JzCCym f", "REV CrashCym", "REV Crash 1", "REV RkChina", "REV China", "REV Cowbell", "REV WoodBlck", "REV Claves", "REV Conga", "REV Timbale", "REV Maracas", "REV Guiro", "REV Tamb 1", "REV Tamb 2", "REV Cuica", "REV Timpani", "REV Timp3 pp", "REV Timp3 mp", "REV Metro"]
      
      public static let internalWaveOptions = OptionsParam.makeOptions(internalWaveNames)
      
    }
    
  }
  
}
