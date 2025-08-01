const XVPerf = require('./xv_perf.js')
const XV5050Perf = require('./xv5050_perf.js')



const outAssignOptions: [Int:String] = XV2020.Voice.Tone.outAssignOptions <<<
  [13 : "Patch"]

const internalPartGroupOptions: [Int:String] = {
  let ids: [SynthPath] = [
    [],
    "int/user",
    "int/preset/0",
    "int/preset/1",
    "int/preset/2",
    "int/preset/3",
    "int/gm2",
  ]

  return ids.dict {
    [XVPerf.Part.value(forSynthPath: $0) : XVPerf.Part.internalGroupsMap[$0] ?? ""]
  }
}()

const config = XVPerf.Part.Config(voicePartGroups: voicePartGroups, rhythmPartGroups: rhythmPartGroups, voicePresets: voicePresets, rhythmPresets: rhythmPresets)

const voicePartGroups: [Int:String] = internalPartGroupOptions <<< XVPerf.Part.srxPartGroupOptions

const rhythmPartGroups: [Int:String] = {
  let ids: [SynthPath] = [
    [],
    "int/user",
    "int/preset/0",
    "int/preset/1",
    "int/gm2",
  ]
  return ids.dict {
    [XVPerf.Part.value(forSynthPath: $0) : XVPerf.Part.internalGroupsMap[$0] ?? ""]
  } <<< XVPerf.Part.srxPartGroupOptions
}()


const presetAOptions = ["Grand XV", "RockPiano Ch", "Contemplate", "Hall Grand", "64voicePiano", "Power Grand", "E.Grand", "RD-1000", "MIDIed Grand", "SparklePiano", "Warm pF Mix", "PianoStrings", "Y2K Concerto", "Piano+SftPad", "R&Ballad Mix", "West Coast", "Hit Rhodes", "Full Rhodes", "Player’s EP", "Retro Rhodes", "Fat Rhodes", "PingE Piano", "Rholitzer", "Dig Rhodes", "Delicate EP", "Rhodes Mix", "D-50 Rhodes", "FM BellPiano", "FM Delight", "Ring E.Piano", "XV Crystal", "Rhodes Trem", "Waterhodes", "PsychoRhodes", "MK-80 Phaser", "SmoothRhodes", "EP+Mod Pad", "Mr.Mellow", "Wurlie", "PureSineKey", "Dreams Sine", "Cutter Clav", "Funky D6", "Phaze Clav", "Nasty Clav", "Velo-Rez Clv", "Analog Clav", "St.Harpsichd", "Square Keys", "D-50 Stack", "Stacc.Heaven", "Heavenals", "Morning Lite", "HolidayCheer", "Prefab Chime", "2020 Bell", "2.2 Bell Pad", "Tria Bells", "Music Bells", "Childlike", "Celestabox", "Chime Bells", "Belfry Chime", "True Vibe", "Warm Vibes", "Dyna Marimba", "Ambient Wood", "Nomad Perc", "Exotic Velo", "Islands Mlt", "Steel Drums", "Soft Perky", "Soft B", "Gospel Spin", "Rocker Org", "Velvet Organ", "Rocker Spin", "Full Stops", "Ballad B", "Mellow Bars", "Soap Opera", "AugerMentive", "Perky B", "Klubb Organ", "Drew’s Bee", "Purple Spin", "Surf’s Up!", "96 Years", "Glory Us Rok", "D-50 Organ", "Cathedral", "Church Harmn", "Wedding Mass", "XV Accordion", "Harmo Blues", "Nylon Gtr", "Soft Nylon", "Steel Away", "SteelRelease", "Thick Steel", "XV Steel Gtr", "Comp’Steel", "12str Guitar", "Nylozzicato", "SpanishNight", "Hybrid Nylon", "DesertCrystl", "Two+Ensemble", "Clear Guitar", "Jz Gtr Hall", "LetterFrmPat", "JC Strat", "Twin Strats", "Plug n’ Play", "Swell Strat", "Fab 4 Guitar", "Muted Gtr", "Velo-Wah Gtr", "Tube Smoke", "Creamy", "Blusey OD", "Crying Solo", "Feed Me!", "RockYurSocks", "Searing Lead", "Loud Lead", "OD 5ths", "Crunch Split"]

const presetBOptions = ["Rezodrive", "Hurtin’Tubes", "R&R Chunk", "Power Trip", "Pick Bass", "Hip Bass", "Homey Bass", "Tap Bass", "Pop Bass", "TremCho Bs", "Nylon Bass", "XV Upright", "XV Ac.Bass", "XV Fretless", "Basic F’less", "8-str F’less", "LookMaNoFret", "Slap Bass 1", "Slap Bass 2", "Slap Bass 3", "Sub Zero", "SinusoidRave", "808 SynBass", "Acid TB", "MC-TB Bass", "TB Tra Bass", "Cyber SynBs", "2020 Reso Bs", "Now Bass", "D9 Trcker", "West End Bs", "TB Squelch", "Detune Bass", "FatPolyBass", "GarageBass", "2020 OrgBs", "2020 JunoBs", "Comp Bass", "2020 Bass 1", "2020 Bass 2", "StabSawBass", "2020 SquBs", "Square Bass", "SQR+Sub Bs", "2020 Pls Bs", "Grounded Bs", "2pole Bass", "4pole Bass", "House Bass", "Bass Trap", "Bass In Face", "Ticker Bass", "Klack Bass", "Hugo Bass", "Mg Bass", "New Acid Grv", "8VCO MonoSyn", "Wonder Bass", "S-Tone+SYNBS", "Booty Bass", "XV Strings", "St.Strings", "Dolce p/m/f", "Sad Strings", "Marcato", "String Ens", "Marcato Str", "Fat Strings", "UltraSmooth", "HybStringsXV", "ViolinCello", "Lead 4x Vlns", "ChmbrQuartet", "FullChmbrStr", "Film Octaves", "Bass Pizz", "JP-8 Str 1", "JP-8 Str 2", "Deep Strings", "Hold A Chord", "Tape Strings", "Symphonique", "Full Orchest", "My Orchestra", "Soft Symphny", "Henry VIII", "Wood Symphny", "Prelude", "TudorFanfare", "Brassy Symph", "4 Hits 4 You", "Impact", "Phase Hit", "Tekno Hit", "Reel Slam", "OffTheRecord", "3rdTeenChrd", "Auto Chord", "MOVE!", "Oboe mf", "Clarinet mp", "SwellEnsembl", "ChamberWoods", "Flute/Clari", "Wind Wood", "Flute", "Jazzer Flute", "VOX Flute", "Pan Pipes", "LegatoBamboo", "The Andes", "Deja Vlute", "Majestic Tpt", "Ballad Trump", "Mute TP mod", "Harmon Mute", "Tpt Sect", "NewR&RBrass", "Simply Brass", "Valve Job", "Tower Trumps", "BigBrassBand", "Biggie Brass", "Lil’BigHornz", "Sm.Brass Grp", "Trombone", "Trombone Atm", "Massed Horns"]

const presetCOptions = ["Voyager Brs", "3 Osc Brass", "Poly Brass", "Brass It!", "Archimede", "Breathy Brs", "Triumph Brs", "P5 Polymod", "FatSynBrass", "True ANALOG", "Afro Horns", "Sop.Sax mf", "Solo SoprSax", "Alto Sax", "Solo AltoSax", "XV DynoTenor", "Honker Bari", "Sax Choir", "Full Saxz", "Swingin’Bari", "P5_TB", "Soaring Saws", "FXM Saw Lead", "BOG", "Square Roots", "Old School", "Retro Lead", "Loud SynLead", "PortaSynLd", "OSC Sync2020", "Talking Box", "Blistering", "MG Interval", "Analog Lead", "5th Lead", "Classy Pulse", "TubbyTriangl", "Square Lead", "2020SquLead", "Creamer", "Belly Lead", "Flyin’ High", "SH-2000", "Soft Tooth", "Sine Lead", "Smoothe", "Basic Mg", "LegatoJupitr", "Soaring Sqr", "Soaring Sync", "Nasal Spray", "Soft Lead", "House Piano", "Techno Dream", "Organizer", "Auto TB-303", "Dist TB-303", "Resojuice", "B’on d’moov", "Con Sequence", "Technoheadz", "Phunky DC", "Shortrave", "Cross Fire", "Velo Tekno", "Rezoid", "Booster Bips", "Mental Chord", "House Chord", "GenderBender", "MinorIncidnt", "Winky", "Dance Zipper", "5ths in 4ths", "Ambi Voices", "Intentions", "Pick It", "Analog Seq", "Sequalog", "Plik-Plok", "Big BPF", "Agent X", "Keep :-)", "Saw n’ 202", "RageInYouth", "Happy Brass", "LFO Trance", "Syncrosonix", "GermanBounce", "Trance Fair", "Cyber Pad", "S&H Pad", "PressureDome", "Pulsatronic", "Cyber Dreams", "Alive", "Trancing Pad", "Acid JaZZ", "Alternative", "Acid Line", "Raggatronic", "Temple of JV", "Blades", "Fooled Again", "Planet Asia", "Afterlife", "Cultivate", "Paz <==> Zap", "Strobe Mode", "Albion", "Running Pad", "Rippling", "Random Pad", "SoundtrkDANC", "Flying Waltz", "Phazweep", "Mad Bender", "X-mod Reso", "Shapeshifter", "Glistening", "Atmospherics", "Vektogram", "Feedback VOX", "Helium Queen", "Halographix", "Shattered", "Pure Tibet", "X-Tension"]

const presetDOptions = ["Dark Side", "Dunes", "The Beast", "Ocean Floor", "Cyber Space", "Nexus", "ForestMoon", "Planet Meta", "Predator 2", "Flashback", "JUNO Keys", "Poly Key", "Poly Saws", "Dual Profs", "Saw Mass", "Streamer", "Soft Puff", "Dreams East", "Sugar Key", "D50FantaPerc", "Galactic", "Pulse Key", "Wire Pad", "Waspy Pulse", "Glider", "80s Retrosyn", "Powerwiggle", "Trance Saws1", "Trance Saws2", "Don’t Jump", "AirSoThin", "Silicon Str", "PWM Strings", "Vintage Orch", "106 Strings", "Modular Life", "2020 Digital", "Oscillations", "Greek Power", "Soaring Hrns", "Rolling 5ths", "Spectre", "Glass Orbit", "Hush Pad", "Pivotal Pad", "Spectre Vox", "Digital Vox", "Stringsheen", "Combing", "5th Sweep", "MG Sweep", "Hydrogen", "BPFsweep Mod", "Mod DirtyWav", "X-mod Sweep", "Silky Way", "Gluey Pad", "Dreamesque", "Analogue Str", "JX SqrCarpet", "Pulsify", "JP-8Haunting", "Earth Blow", "Jet Pad", "Dimensional", "Jupiterings", "3D Flanged", "Glassy Pad", "2.2 Strings", "Moving Glass", "ShiftedGlass", "Heirborne", "Translucence", "Darkshine", "Shiny Pad", "Analog Drama", "BandPass Mod", "Air Pad", "Soundtraque", "Octapad", "Fat Pad", "GR700 Pad", "Rotary Pad", "Dawn 2 Dusk", "Aurora", "Morph Pad", "Sun Dive", "Sabbath Day", "OvertoneScan", "December Sky", "NothrnLights", "Vocals: Boys", "St. Choir", "Vocals: Ooh", "Pvox Oooze", "RandomVowels", "Brite Vox", "Beauty Vox", "Longing...", "Enlighten", "Arasian Morn", "Dark Vox", "Belltree Vox", "Spaced Voxx", "Glass Voices", "Doos", "Wavox", "Sitar", "Dulcimer", "Dulcitar", "Drone Split", "MountainFolk", "EastrnEurope", "Harp", "VelHarp)Harm", "Celtic Harp", "AmbiPizza", "CheesyPluk 1", "CheesyPluk 2", "Taj Mahal", "Cairo lead", "Lochscapes", "Celtic Song", "Far East", "Slap Timps", "Tape Q", "Gruvacious", "Blue Notes"]

const rhythmPresetAOptions = ["R&B Kit", "House Kit", "Techno Kit", "XV Pop Kit"]
const rhythmPresetBOptions = ["XV Rock Kit", "Jazz Kit", "XV Rust Kit", "OrchestraKit"]

const voicePresets: [SynthPath:[Int:String]] = [
  "preset/0" : presetAOptions,
  "preset/1" : presetBOptions,
  "preset/2" : presetCOptions,
  "preset/3" : presetDOptions,
  "preset/4" : XV3080.Perf.Part.presetEOptions,
  "preset/5" : XV3080.Perf.Part.presetFOptions,
  "preset/6" : XV3080.Perf.Part.presetGOptions,
  "preset/7" : XV3080.Perf.Part.presetHOptions,
  "gm2" : XV3080.Perf.Part.gm2Options
]

const rhythmPresets: [SynthPath:[Int:String]] = [
  "preset/0" : rhythmPresetAOptions,
  "preset/1" : rhythmPresetBOptions,
  "preset/2" : XV3080.Perf.Part.rhythmPresetCOptions,
  "preset/3" : XV3080.Perf.Part.rhythmPresetDOptions,
  "preset/4" : XV3080.Perf.Part.rhythmPresetEOptions,
  "preset/5" : XV3080.Perf.Part.rhythmPresetFOptions,
  "preset/6" : XV3080.Perf.Part.rhythmPresetGOptions,
  "preset/7" : XV3080.Perf.Part.rhythmPresetHOptions,
  "gm2" : XV3080.Perf.Part.rhythmGm2Options
]


const partParms = XV5050Perf.partParms.concat([
  ['out/assign', { b: 0x1f, opts: outAssignOptions }],
  ['out/fx', { b: 0x20, opts: ["A"] }],
])

const partPatchWerk = XVPerf.Part.patchWerk(params: parms.params(), size: 0x31)

const patchWerk = XVPerf.patchWerk(16, common: XV5050.Perf.Common.patchWerk, part: Part.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, other: [], initFile: "xv2020-perf-init")

const bankWerk = XVPerf.bankWerk(patchWerk, initFile: "xv2020-perf-bank-init")

const fullRefTruss = XVPerf.Full.refTruss(16, perf: patchWerk, voice: Voice.patchWerk, rhythm: rhythmPatchWerk)
