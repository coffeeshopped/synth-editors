
protocol JP80X0VoicePatch : JP8080SinglePatchTemplate, BankedPatchTemplate, VoicePatch { }

extension JP80X0VoicePatch {

 static var nameByteRange: CountableRange<Int>? { 0..<0x10 }

 static func startAddress(_ path: SynthPath?) -> RolandAddress {
   0x4000 + (path?.endex ?? 0) * 0x200
 }
 
 static func bytes(data: Data) -> [UInt8] {
   let rolandData = RolandTemplatedData<Self>(data: data)
   let parsedBytes = rolandData.data(forAddress: rolandData.startAddress, size: size)
   return parsedBytes.count == realSize ? parsedBytes : [UInt8](repeating: 0, count: realSize)
 }

}

struct JP8080VoicePatch : JP80X0VoicePatch {
 typealias Bank = JP8080VoiceBank
 
 static let size: RolandAddress = 0x0178
 static let initFileName: String = "jp8080-voice-init"
 
 static func isValid(fileSize: Int) -> Bool {
   [fileDataCount, 272].contains(fileSize)
 }
 
 
 static let params: SynthPathParam = paramsFromOpts(paramOptions())

 static func paramOptions(isJP8080: Bool = true) -> [ParamOptions] {
   let opts = prefix([.lfo, .i(0)]) {
     inc(b: 0x10) {
       [
         o([.wave], optArray: ["Tri", "Saw", "Sqr", "S/H"]),
         o([.rate]),
         o([.fade])
       ]
     }
   }
   <<< prefix([.lfo, .i(1)]) {
     inc(b: 0x13) {
       [
         o([.rate]),
         o([.depth, .select], optArray: ["Pitch", "Filter", "Amp"])
       ]
     }
   }
   <<< inc(b: 0x15) {
     [
       o([.ringMod], max: 1),
       o([.cross]),
       o([.osc, .balance], isoS: Miso.switcher([
         .range(0...63, Miso.m(-1) >>> Miso.a(64) >>> Miso.unitFormat(" O1")),
         .int(64, "Bal"),
         .range(65...127, Miso.a(-64) >>> Miso.unitFormat(" O2")),
       ])),
       o([.pitch, .lfo, .i(0), .env, .dest], optArray: ["Osc 1+2", "Osc 2", "X-Mod"]),
       o([.pitch, .lfo, .i(0), .depth], dispOff: -64),
       o([.pitch, .lfo, .i(1), .depth], dispOff: -64),
     ]
     <<< prefix([.pitch, .env]) {
       [
         o([.depth], dispOff: -64),
         o([.attack]),
         o([.decay]),
       ]
     }
     <<< prefix([.osc, .i(0)]) {
       [
         o([.wave], optArray: ["Super Saw", "Tri Mod", "Noise", "Feedbk Osc", "Pulse", "Saw", "Tri"]),
         o([.ctrl, .i(0)]),
         o([.ctrl, .i(1)]),
       ]
     }
     <<< prefix([.osc, .i(1)]) {
       [
         o([.wave], optArray: ["Pulse", "Saw", "Tri"] + (isJP8080 ? ["Noise"] : [])),
         o([.sync], max: 1),
         o([.range], max: 50, isoS: Miso.switcher([
           .int(0, "-Wide"),
           .range(1...49, Miso.a(-25) >>> Miso.str()),
           .int(50, "+Wide"),
         ])),
         o([.fine], max: 100, dispOff: -50),
         o([.ctrl, .i(0)]),
         o([.ctrl, .i(1)]),
       ]
     }
     <<< prefix([.filter]) {
       [
         o([.type], optArray: ["HPF", "BPF", "LPF"]),
         o([.slop], optArray: ["-12", "-24"]),
         o([.cutoff]),
         o([.reson]),
         o([.key, .trk], dispOff: -64),
         o([.lfo, .i(0), .depth], dispOff: -64),
         o([.lfo, .i(1), .depth], dispOff: -64),
       ]
       <<< prefix([.env]) {
         [
           o([.depth], dispOff: -64),
           o([.attack]),
           o([.decay]),
           o([.sustain]),
           o([.release]),
         ]
       }
     }
     <<< prefix([.amp]) {
       [
         o([.level]),
         o([.lfo, .i(0), .depth], dispOff: -64),
         o([.lfo, .i(1), .depth], dispOff: -64),
       ]
       <<< prefix([.env]) {
         [
           o([.attack]),
           o([.decay]),
           o([.sustain]),
           o([.release]),
         ]
       }
     }
     <<< [
       o([.amp, .pan, .select], optArray: ["Off", "Auto Pan", "Man Pan"]),
       o([.eq, .lo], dispOff: -64),
       o([.eq, .hi], dispOff: -64),
       o([.fx, .type], optArray: (isJP8080 ? fxTypes : fxTypes.dropLast(1))), // no dist on 8000
       o([.fx, .level]),
       o([.delay, .type], optArray: delayTypes),
       o([.delay, .time]),
       o([.delay, .feedback]),
       o([.delay, .level]),
       o([.bend, .up], max: 24),
       o([.bend, .down], max: 24),
       o([.porta, .on], max: 1),
       o([.porta, .time]),
       o([.mono], max: 1),
       o([.legato], max: 1),
       o([.transpose], max: 4, dispOff: -2),
     ]
   }
   <<< inc(b: 0x4a, inc: 2) {
     suffix([.ctrl]) {
       [
         octrl([.lfo, .i(0), .rate]),
         octrl([.lfo, .i(0), .fade]),
         octrl([.lfo, .i(1), .rate]),
         octrl([.cross]),
         octrl([.osc, .balance]),
         octrl([.pitch, .lfo, .i(0), .depth]),
         octrl([.pitch, .lfo, .i(1), .depth]),
       ]
       <<< prefix([.pitch, .env]) {
         [
           octrl([.depth]),
           octrl([.attack]),
           octrl([.decay]),
         ]
       }
       <<< prefix([.osc, .i(0)]) {
         [
           octrl([.ctrl, .i(0)]),
           octrl([.ctrl, .i(1)]),
         ]
       }
       <<< prefix([.osc, .i(1)]) {
         [
           o2([.range], range: -50...50),
           o2([.fine], range: -100...100),
           octrl([.ctrl, .i(0)]),
           octrl([.ctrl, .i(1)]),
         ]
       }
       <<< prefix([.filter]) {
         [
           octrl([.cutoff]),
           octrl([.reson]),
           octrl([.key, .trk]),
           octrl([.lfo, .i(0), .depth]),
           octrl([.lfo, .i(1), .depth]),
         ]
         <<< prefix([.env]) {
           [
             octrl([.depth]),
             octrl([.attack]),
             octrl([.decay]),
             octrl([.sustain]),
             octrl([.release]),
           ]
         }
       }
       <<< prefix([.amp]) {
         [
           octrl([.level]),
           octrl([.lfo, .i(0), .depth]),
           octrl([.lfo, .i(1), .depth]),
         ]
         <<< prefix([.env]) {
           [
             octrl([.attack]),
             octrl([.decay]),
             octrl([.sustain]),
             octrl([.release]),
           ]
         }
       }
       <<< [
         octrl([.eq, .lo]),
         octrl([.eq, .hi]),
         octrl([.fx, .level]),
         octrl([.delay, .time]),
         octrl([.delay, .feedback]),
         octrl([.delay, .level]),
       ]
     }
   }
   <<< [
     o([.morph, .bend], 0x0118, max: 1),
     octrl([.ctrl, .porta, .time], 0x0119),
     o([.velo, .on], 0x011b, max: 1),
   ]
   <<< inc(b: 0x011c, inc: 2) {
     suffix([.velo]) {
       [
         o2([.lfo, .i(0), .rate]),
         octrl([.lfo, .i(0), .fade]),
         octrl([.lfo, .i(1), .rate]),
         octrl([.cross]),
         octrl([.osc, .balance]),
         octrl([.pitch, .lfo, .i(0), .depth]),
         octrl([.pitch, .lfo, .i(1), .depth]),
       ]
       <<< prefix([.pitch, .env]) {
         [
           octrl([.depth]),
           octrl([.attack]),
           octrl([.decay]),
         ]
       }
       <<< prefix([.osc, .i(0)]) {
         [
           octrl([.ctrl, .i(0)]),
           octrl([.ctrl, .i(1)]),
         ]
       }
       <<< prefix([.osc, .i(1)]) {
         [
           o2([.range], range: -50...50),
           o2([.fine], range: -100...100),
           octrl([.ctrl, .i(0)]),
           octrl([.ctrl, .i(1)]),
         ]
       }
       <<< prefix([.filter]) {
         [
           octrl([.cutoff]),
           octrl([.reson]),
           octrl([.key, .trk]),
           octrl([.lfo, .i(0), .depth]),
           octrl([.lfo, .i(1), .depth]),
         ]
         <<< prefix([.env]) {
           [
             octrl([.depth]),
             octrl([.attack]),
             octrl([.decay]),
             octrl([.sustain]),
             octrl([.release]),
           ]
         }
       }
       <<< prefix([.amp]) {
         [
           octrl([.level]),
           octrl([.lfo, .i(0), .depth]),
           octrl([.lfo, .i(1), .depth]),
         ]
         <<< prefix([.env]) {
           [
             octrl([.attack]),
             octrl([.decay]),
             octrl([.sustain]),
             octrl([.release]),
           ]
         }
       }
       <<< [
         octrl([.eq, .lo]),
         octrl([.eq, .hi]),
         octrl([.fx, .level]),
         octrl([.delay, .time]),
         octrl([.delay, .feedback]),
         octrl([.delay, .level]),
         octrl([.porta, .time]),
       ]
     }
   }
   
   guard isJP8080 else { return opts }

   return opts <<< [
     o([.solo, .env, .type], 0x016f, optArray: ["Std", "Analog"]),
   ]
   <<< inc(b: 0x0171) {
     [
       o([.osc, .i(1), .ext], max: 1),
       o([.voice, .mod, .send], max: 1),
       o([.unison, .on], max: 1),
       o([.unison, .detune], max: 50),
       o([.amp, .gain], optArray: ["0", "6", "12"]),
       o([.ext, .trigger, .on], max: 1),
       o([.ext, .trigger, .dest], optArray: ["Filter", "Amp", "Filter+Amp"]),
     ]
   }

 }
 
 // -127..127 ctrl/velo param
 static func octrl(_ path: SynthPath, _ b: Int? = nil) -> ParamOptions {
   o2(path, b, max: 254, dispOff: -127)
 }

 static let delayTypes = ["Pan L→R", "Pan R→L", "Pan Short", "Mono Short", "Mono Long"]
 
 static let fxTypes = ["Chorus Slw", "Chorus Mid", "Chorus Fst", "Chorus Clr", "Flanger Slow", "Flanger Deep", "Flanger Fast", "Deep Phasing Slw", "Jet Phasing", "Twisting", "Freeze Phase 1", "Freeze Phase 2", "Distortion"]
 
 static let presetNames = [
   ["Spit'n Slide Bs", "Velo Decay Bass", "Wall Bob", "Juno Sub Bass", "Subsonic Bass", "Big & Dark", "Bass Flow", "Juno Bass Vel", "Dubb Bass", "Juice Bass", "Dreams Are Made", "Reso Bass Line", "Bass Pedals", "Hard Core Bass", "MC-202 Bass", "Rubber SH-2", "Raging Bass", "Blipper Bass", "JP-303", "Rave Time", "Fretless Bass", "Digi Strat", "Fire Wire", "Proflike Clavit", "Withmod Comp", "Juno Clav", "Gritty Power", "Separate ways", "For RPS", "Bread'n Butter", "Silk 5ths", "Ancient Asia", "Intervalic", "Squared Away", "Velo Syncoid", "Resonance Chord", "Resorelease", "Waspy Synth", "Euro SAW", "Dance Sweep", "Trance Food", "One Shot Reso", "The Fat Guy", "Spit Brass", "Poly Sync", "Rave 5th", "UK Shorty", "Old Rhodes", "Wurly Piano 1", "Wurly Piano 2", "Moody Organ", "Org/Rotary>Ribon", "VK09 PercEchoes", "Sine Lead", "Wichita Lead", "Creamy", "Smoothy", "Soaring Mini", "Ribn F/B Lead", "Sup-Jup Lead", "Modular Lead", "Syncrosolo", "Ripper", "Phantom Lead", "Whammy Mammy", "Wicked Lead", "Drefull Dr", "Wiggle Mod", "Feedback Lead", "Crunch", "Chaos Lead", "Out of Control", "String Machine", "Tron Vlns", "Luxury Symph", "Debussy", "BPF Velo Strings", "Detuned Str", "Juno B81 Pad", "Richland", "MOD Strings", "Jupiter Pad", "Soft Strings", "Shan-gri-la", "Fine Wine", "Glue Pad", "True Pad", "Foreboding", "Skreachea", "BPM Pulse 1", "BPM Pulse 2", "Hi-Pass Puls", "Sample&Hold Me", "MKS80 Space", "Arctic Sweep", "Replicant CS", "Stargate", "Lost in Time", "Circular", "Space Choir", "Hypass Sweep", "BPF Tides", "Matrix Sweep", "MKS80 Bells", "Tiny bells", "Chimey", "Juno Arp", "Sonar Ping", "Air Harp", "Velo FX Percs", "Quizzled", "Intermittent", "Brain Static", "Computone", "Pin Matrix", "Space Cheese", "Rough Day", "The Etruscan", "Varese", "Pipe Dream", "Meteor", "Snowman", "Space Ghost", "Ozone", "Cool-a little", "Electro Gulls", "Template 1", "Template 2"],
   ["MG Bass", "Trance Bass 4", "Trance Bass 5", "Trance Bass 6", "Bone Sa Mo", "Bone Yall", "PHM 1", "PHM 2", "PHM 3", "Static Bass 1", "Static Bass 2", "M Bass", "PHM 4", "PHM 5", "Mini Bass", "Wonderland Bass", "Hard Bass", "Fretless Synth", "Lead Bass", "JP Fat Synbrass", "Gate me", "Kling Klang 2", "Rising Key", "Flat Out 1", "Flat LFO", "Flat Out 2", "Flat Out 3", "MiniSynth 1", "AW/DM Resonance1", "AW/DM Resonance2", "AW/DM Resonance3", "AW/DM Resonance4", "WONDERLAND 1", "WONDERLAND 2", "Jupiter8Arpeggio", "Fuel", "Shake", "Model", "Vanishing Key", "Fade Away", "Hard Key 1", "Hard Key 2", "Hard Key 3", "Cheesy Key 1", "Cheesy Key 2", "DM 1", "DM 2", "Hard Key 4", "Hard Key 5", "Hard Key 6", "DM 3", "Arpy 3", "Arpy 4", "J Echo", "Mini Seq. 1", "Mini Seq. 2", "Pulsar 88", "Kling Klang 3", "Straight Jacket", "DM 4", "CHEM 1", "CHEM 2", "Dusseldorf 1", "Dusseldorf 2", "Virtual Voltage", "DAD or alive", "Freeze Frame", "Rave2theRhythm", "Cheesy Lead 1", "Cheesy Lead 2", "Cheesy Lead 3", "Cheesy Lead 4", "Cheesy Lead 5", "Coreline Nine", "Wonderland Pad 1", "Wonderland Pad 2", "Wonderland Pad 3", "seqaT nortoleM", "Venusian Strings", "Wonderland Pad 4", "GRAMMAPHONE 1", "GRAMMAPHONE 2", "GRAMMAPHONE 3", "Oil Canvas 1", "Oil Canvas 2", "Oil Canvas 3", "Oil Canvas 4", "Oil Canvas 5", "Blossoms 1", "Blossoms 2", "Broom", "J Pad", "Dream Kate", "Temple 1", "Temple 2", "Thick", "Open 54", "Kling Klang 4", "Epic", "Multiples 1", "Lodelity", "Lode in Stereo", "Wonderland Brs", "Hard Pad", "Gate in Stereo 1", "Gate in Stereo 2", "Gate in Stereo 3", "S/H in Stereo", "Bub", "Simple E.Drums", "Boom your Woofer", "Multiples 2", "Midnight 1-900", "100% After", "Time and Space", "LFO 1", "LFO 2", "HLAH", "Blade", "Cyborg", "Fall", "Rise", "Radioactive 1", "Radioactive 2", "DroneOn", "Duss", "Hydro Noise", "From Space..."],
   ["Culture Bass", "Techno Brie", "Wired Funk", "Deep Thought", "Trance Bass", "Baroque Bass", "Pulse 303", "101 Sub Bass", "Serious Low Ant1", "Serious Low Ant2", "Bone", "JX Dyna Bass", "Xa Bass", "Offbeat Bass", "Drone Bass", "Clean Wow Bass", "FM Solid", "FM Tube Bass", "FM Rave Bass", "Velo Organ", "Club Organ", "Old Organ", "PercussivToyPno", "Noise Toys", "Apostle Piano", "Clavi-Club", "Perc Clavsynth", "Cyber Cellopluck", "Pulse Key", "Nova Catch", "Eurodance Perc 1", "Tribal Party", "Viking", "Nova Pad", "HPF Saws", "5th Saws Key", "Eros Synth", "Mov'Mov Synth", "Formula Stack 1", "Formula Stack 2", "Raveline", "Ravers Delite", "Super Saw Soup", "Chainsawmassacre", "Daft Five", "Coming up", "Power of 80's", "Jericho Horns", "Milling Lead", "Dark Loonie", "X-Mod May-Day", "Dirty Mania", "Vinyl Story", "Zipper Hymn", "Nova Attack", "Super Attack", "Beep 8000", "Optic Perc", "8008-Cow Signal", "X-FM Metallic", "Pluck & Pray", "Bermuda Triangle", "Home of the Rave", "Paris spirit", "Eurodance Perc 2", "Lo-Fi Chops", "Tranceients", "Voicetransformer", "AW/DM", "Braindead", "I get a Kick", "Upside down", "Hoppy Lead", "Magic Ribbon", "Nice Lead", "Solo Sine&Square", "Vintage Voltage", "Trusty Lead", "Dream P5", "Eastern Lead 1", "Eastern Lead 2", "Tri&Saw Lead", "Crystal Noise", "Happy Euro Lead", "Alphabet Lead", "Feedbacky", "Trance Lead", "CheeseOscillator", "Prod Lead", "Dirty Electrons", "Kitch Vinylead", "Killerbeez", "*¥ Ethnomad", "P5 Sync", "Ergot Rye Seed", "FB 5th", "70's Mono", "Mega HPF Lead", "Siren's Song", "Retro Strings", "Ambient Pad", "Mystery Room", "ElectronicHarmon", "Jungle Pad", "Filtersweep 1", "Filtersweep 2", "Sizzler", "Hi-Pass Saws", "Piping Pad", "Odyssee Astral", "Agitation", "Safari LFO", "Tricky LFO", "Extra Hi-Fi", "Rhythmic Synth", "Asteroid Mode", "Disaster 1", "Fuzzy Logic", "QZ Sub Naut", "Searing", "Disaster 2", "Scrapers", "Trip in Stereo", "CHEM", "Xform", "Amuck", "Cat Conversation", "Pulsing Sweep"],
 ]
 
 
}
