const JVXP = require('./jvxp.js')

const structures = (10).map(i => `xv-struct-${i+1}`)

const chorusOuts = ["Mix", "Reverb", "Mix+Reverb"]
const reverbTypes = ["Room 1","Room 2","Stage 1","Stage 2","Hall 1","Hall 2","Delay","Pan Delay"]
const reverbHFDamps = ["200", "250", "315", "400", "500", "630", "800", "1000", "1250", "1600", "2000", "2500", "3150", "4000", "5000", "6300", "8000", "Bypass"]

const fxTypes = ["Stereo-eq", "Overdrive", "Distortion", "Phaser", "Spectrum", "Enhancer", "Auto-wah", "Rotary", "Compressor", "Limiter", "Hexa-chorus", "Tremolo-chorus", "Space-d", "Stereo-chorus", "Stereo-flanger", "Step-flanger", "Stereo-delay", "Modulation-delay", "Triple-tap-delay", "Quadruple-tap-delay", "Time-control-delay", "2Voice-pitch-shifter", "Fbk-pitch-shifter", "Reverb", "Gate-reverb", "Overdrive->Chorus", "Overdrive->Flanger", "Overdrive->Delay", "Distortion->Chorus", "Distortion->Flanger", "Distortion->Delay", "Enhancer->Chorus", "Enhancer->Flanger", "Enhancer->Delay", "Chorus->Delay", "Flanger->Delay", "Chorus->Flanger", "Chorus/Delay", "Flanger/Delay", "Chorus/Flanger"]

const fxControlSources = ["Off", "Sys Ctrl1", "Sys Ctrl2", "Modulation", "Breath", "Foot", "Volume", "Pan", "Expression", "Bender", "Aftertouch"]

const patchControlSources = ["Off", "Sys Ctrl1", "Sys Ctrl2", "Modulation", "Breath", "Foot", "Volume", "Pan", "Expression", "Bender", "Aftertouch", "LFO 1", "LFO 2", "Velocity", "Keyfollow", "Playmate"]

const holdPeaks = ["Off", "Hold", "Peak"]
const boosters = ["0", "+6", "+12", "+18"]


const commonParms = [
  ["fx/type", { b: 0x0c, opts: fxTypes }],
  { prefix: "fx/param", count: 12, bx: 1, block: ["", { b: 0x0d }] },
  { inc: 1, b: 0x19, block: [
    ["fx/out/assign", { opts: ["Mix","Output 1","Output 2"] }],
    ["fx/out/level", { }],
    ["fx/chorus", { }],
    ["fx/reverb", { }],
    ["fx/ctrl/src/0", { opts: fxControlSources }],
    ["fx/ctrl/depth/0", { max: 126, dispOff: -63 }],
    ["fx/ctrl/src/1", { opts: fxControlSources }],
    ["fx/ctrl/depth/1", { max: 126, dispOff: -63 }],
    ["chorus/level", { }],
    ["chorus/rate", { }],
    ["chorus/depth", { }],
    ["chorus/predelay", { }],
    ["chorus/feedback", { }],
    ["chorus/out/assign", { opts: chorusOuts }],
    ["reverb/type", { opts: reverbTypes }],
    ["reverb/level", { }],
    ["reverb/time", { }],
    ["reverb/hfdamp", { opts: reverbHFDamps }],
    ["reverb/feedback", { }],
    ["tempo", { packIso: JVXP.multiPack(0x2c), rng: [20, 251] }],
  ]},
  { inc: 1, b: 0x2e, block: [
    ["level", { }],
    ["pan", { dispOff: -64 }],
    ["analogFeel", { }],
    ["bend/up", { max: 12 }],
    ["bend/down", { max: 48 }],
    ["mono", { max: 1 }],
    ["legato", { max: 1 }],
    ["porta", { max: 1 }],
    ["porta/legato", { max: 1 }],
    ["porta/type", { opts: ["Rate","Time"] }],
    ["porta/start", { opts: ["Pitch","Note"] }],
    ["porta/time", { }],
    ["patch/ctrl/src/1", { opts: patchControlSources }],
    ["patch/ctrl/src/2", { opts: patchControlSources }],
    ["fx/ctrl/holdPeak", { opts: holdPeaks }],
    ["ctrl/0/holdPeak", { opts: holdPeaks }],
    ["ctrl/1/holdPeak", { opts: holdPeaks }],
    ["ctrl/2/holdPeak", { opts: holdPeaks }],
    ["velo/range/on", { max: 1 }],
    ["octave/shift", { max: 6, dispOff: -3 }],
    ["stretchTune", { max: 3 }],
    ["voice/priority", { opts: ["Last","Loudest"] }],
    ["structure/0", { opts: structures }],
    ["booster/0", { opts: boosters }],
    ["structure/1", { opts: structures }],
    ["booster/1", { opts: boosters }],
  ]},
]

const commonPatchWerk = JVXP.perfCommonPatchWerk(commonParms, 0x48)

  
//    static func startAddress(_ path: SynthPath?) -> RolandAddress {
//      return RolandAddress([0x10 + UInt8(0x02 * (path?.endex ?? 0)), 0x00])
//    }

const controlDestinations = ["Off", "Pitch", "Cutoff", "Resonance", "Level", "Pan", "Mix", "Chorus", "Reverb", "Pitch L1", "Pitch L2", "Filter L1", "Filter L2", "Amp L1", "Amp L2", "Pan L1", "Pan L2", "L1R", "L2R"]

const lfoWaves = ["Tri", "Sine", "Saw", "Square", "TRP", "S&H", "Random", "CHS"]

const lfoLevelOffsets = ["-100", "-50", "0", "+50", "+100"]

const lfoFadeModes = ["On In", "On Out", "Off In", "Off Out"]

const lfoExtSyncs = ["Off","Clock","Tap"]

const randomPitchs = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"]

const pitchKeyfollows = ["-100", "-70", "-50", "-30", "-10", "0", "10", "20", "30", "40", "50", "70", "100", "120", "150", "200"]

const veloTSenss = ["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"]

const toneParms = [
  ["on", { b: 0x00, max: 1 }],
  ["wave/group", { b: 0x01, opts: ["Int","PCM","Exp"] }],
  ["wave/group/id", { b: 0x02 }],
  ["wave/number", { b: 0x03, packIso: JVXP.multiPack(0x03), max: 254 }],
  { inc: 1, b: 0x05, block: [
    ["wave/gain", { opts: ["-6","0","+6","+12"] }],
    ["fxm/on", { max: 1 }],
    ["fxm/color", { max: 3, dispOff: 1 }],
    ["fxm/depth", { max: 15, dispOff: 1 }],
    ["delay/mode", { opts: ["Normal","Hold","Key Interval","Clock Sync","Tap Sync","Key Off Normal","Key Off Decay"] }],
    ["delay/time", { }],
    ["velo/fade/depth", { }],
    ["velo/range/lo", { rng: [1, 128] }],
    ["velo/range/hi", { rng: [1, 128] }],
    ["key/range/lo", { }],
    ["key/range/hi", { }],
    ["redamper/ctrl", { max: 1 }],
    ["volume/ctrl", { max: 1 }],
    ["hold/ctrl", { max: 1 }],
    ["bend/ctrl", { max: 1 }],
    ["pan/ctrl", { max: 1 }],
  ] },
  { prefix: "ctrl", count: 3, bx: 8, block: [
    { prefix: "dest", count: 4, bx: 2, block: 
      ["", { b: 0x15, opts: controlDestinations }]
    },
    { prefix: "depth", count: 4, bx: 2, block: 
      ["", { b: 0x16, max: 126, dispOff: -63 }]
    },
  ] },
  { prefix: "lfo", count: 2, bx: 8, block: [
    { inc: 1, b: 0x2d, block: [
      ["wave", { opts: lfoWaves }],
      ["key/trigger", { max: 1 }],
      ["rate", { }],
      ["level/offset", { opts: lfoLevelOffsets }],
      ["delay", { }],
      ["fade/mode", { opts: lfoLevelOffsets }],
      ["fade/time", { }],
      ["ext/sync", { opts: lfoExtSyncs }],
    ] },
  ] },
  ["coarse", { b: 0x3d, max: 96, dispOff: -48 }],
  ["fine", { b: 0x3e, max: 100, dispOff: -50 }],
  ["random/pitch", { b: 0x3f, opts: randomPitchs }],
  ["pitch/keyTrk", { b: 0x40, opts: pitchKeyfollows }],  
  { prefix: "pitch/env", block: [
    { inc: 1, b: 0x41, block: [
      ["depth", { max: 24, dispOff: -12 }],
      ["velo/sens", { max: 125 }],
      ["velo/time/0", { opts: veloTSenss }],
      ["velo/time/3", { opts: veloTSenss }],
      ["time/keyTrk", { opts: veloTSenss }],
      ["time/0", { }],
      ["time/1", { }],
      ["time/2", { }],
      ["time/3", { }],
      ["level/0", { max: 126, dispOff: -63 }],
      ["level/1", { max: 126, dispOff: -63 }],
      ["level/2", { max: 126, dispOff: -63 }],
      ["level/3", { max: 126, dispOff: -63 }],
    ] },
  ] },
  ["lfo/0/pitch", { b: 0x4e, max: 126, dispOff: -63 }],
  ["lfo/1/pitch", { b: 0x4f, max: 126, dispOff: -63 }],
  ["filter/type", { b: 0x50, opts: ["Off","LPF","BPF","HPF","PKG"] }],
  ["cutoff", { b: 0x51 }],
  ["cutoff/keyTrk", { b: 0x52, opts: pitchKeyfollows }],
  ["reson", { b: 0x53 }],
  ["reson/velo/sens", { b: 0x54, max: 125 }],
  { prefix: "filter/env", block: [
    { inc: 1, b: 0x55, block: [
      ["depth", { max: 126, dispOff: -63 }],
      ["velo/curve", { max: 6, dispOff: 1 }],
      ["velo/sens", { max: 125 }],
      ["velo/time/0", { opts: veloTSenss }],
      ["velo/time/3", { opts: veloTSenss }],
      ["time/keyTrk", { opts: veloTSenss }],
      ["time/0", { }],
      ["time/1", { }],
      ["time/2", { }],
      ["time/3", { }],
      ["level/0", { }],
      ["level/1", { }],
      ["level/2", { }],
      ["level/3", { }],
    ] },
  ] },
  ["lfo/0/filter", { b: 0x63, max: 126, dispOff: -63 }],
  ["lfo/1/filter", { b: 0x64, max: 126, dispOff: -63 }],
  ["tone/level", { b: 0x65 }],
  ["bias/direction", { b: 0x66, opts: ["Lower","Upper","L&U","All"] }],
  ["bias/pt", { b: 0x67 }],
  ["bias/level", { b: 0x68, opts: veloTSenss }],
  { prefix: "amp/env", block: [
    { inc: 1, b: 0x69, block: [
      ["velo/curve", { max: 6, dispOff: 1 }],
      ["velo/sens", { max: 125 }],
      ["velo/time/0", { opts: veloTSenss }],
      ["velo/time/3", { opts: veloTSenss }],
      ["time/keyTrk", { opts: veloTSenss }],
      ["time/0", { }],
      ["time/1", { }],
      ["time/2", { }],
      ["time/3", { }],
      ["level/0", { }],
      ["level/1", { }],
      ["level/2", { }],
    ] },
  ] },
  { inc: 1, b: 0x75, block: [
    ["lfo/0/amp", { max: 126, dispOff: -63 }],
    ["lfo/1/amp", { max: 126, dispOff: -63 }],
    ["pan", { dispOff: -64 }],
    ["pan/keyTrk", { opts: veloTSenss }],
    ["random/pan", { max: 63 }],
    ["alt/pan", { rng: [1, 128], dispOff: -64 }],
    ["lfo/0/pan", { max: 126, dispOff: -63 }],
    ["lfo/1/pan", { max: 126, dispOff: -63 }],
    ["out/assign", { opts: ["Mix","FX","Output 1","Output 2"] }],
    ["out/level", { }],
    ["chorus", { }],
  ] },
  // TODO: make sure inc respects 7-bit address "bytes"
  ["reverb", { b: 0x100 }],
]


const tonePatchWerk = {
  single: "Voice Tone", 
  parms: toneParms, 
  size: 0x0101, 
  initFile: "jv1080-tone-init", 
  randomize: () => [
    ["wave/group", 0],
    ["wave/group/id", Math.random(2) + 1],
    ["delay/mode", 0],
    ["delay/time", 0],
    ["tone/level", 127],
    ["pan", 63],
    ["out/assign", 0],
    ["out/level", 127],
    ["random/pitch", 0],
    ["pitch/keyTrk", 12],
    ["velo/fade/depth", 0],
    ["velo/range/lo", 1],
    ["velo/range/hi", 127],
    ["key/range/lo", 0],
    ["key/range/hi", 127],
  ],
} 

const intAWaves = ["1 Ac Piano1 A", "2 Ac Piano1 B", "3 Ac Piano1 C", "4 Ac Piano2 pA", "5 Ac Piano2 pB", "6 Ac Piano2 pC", "7 Ac Piano2 fA", "8 Ac Piano2 fB", "9 Ac Piano2 fC", "10 Piano Thump", "11 Piano Up TH", "12 MKS-20 P3 A", "13 MKS-20 P3 B", "14 MKS-20 P3 C", "15 SA Rhodes 1A", "16 SA Rhodes 1B", "17 SA Rhodes 1C", "18 SA Rhodes 2A", "19 SA Rhodes 2B", "20 SA Rhodes 2C", "21 E.Piano 1A", "22 E.Piano 1B", "23 E.Piano 1C", "24 E.Piano 2A", "25 E.Piano 2B", "26 E.Piano 2C", "27 E.Piano 3A", "28 E.Piano 3B", "29 E.Piano 3C", "30 MK-80 EP A", "31 MK-80 EP B", "32 MK-80 EP C", "33 D-50 EP A", "34 D-50 EP B", "35 D-50 EP C", "36 Celesta", "37 Music Box", "38 Clav 1A", "39 Clav 1B", "40 Clav 1C", "41 Organ 1", "42 Jazz Organ 1", "43 Jazz Organ 2", "44 Organ 2", "45 Organ 3", "46 Organ 4", "47 Rock Organ", "48 Dist. Organ", "49 Rot.Org Slw", "50 Rot.Org Fst", "51 Pipe Organ", "52 Nylon Gtr A", "53 Nylon Gtr B", "54 Nylon Gtr C", "55 6-Str Gtr A", "56 6-Str Gtr B", "57 6-Str Gtr C", "58 Gtr Harm A", "59 Gtr Harm B", "60 Gtr Harm C", "61 Comp Gtr A", "62 Comp Gtr B", "63 Comp Gtr C", "64 Comp Gtr A+", "65 Mute Gtr 1", "66 Mute Gtr 2A", "67 Mute Gtr 2B", "68 Mute Gtr 2C", "69 Pop Strat A", "70 Pop Strat B", "71 Pop Strat C", "72 Jazz Gtr A", "73 Jazz Gtr B", "74 Jazz Gtr C", "75 JC Strat A", "76 JC Strat B", "77 JC Strat C", "78 JC Strat A+", "79 JC Strat B+", "80 JC Strat C+", "81 Clean Gtr A", "82 Clean Gtr B", "83 Clean Gtr C", "84 Stratus A", "85 Stratus B", "86 Stratus C", "87 ODGtrA", "88 ODGtrB", "89 ODGtrC", "90 ODGtrA+", "91 Heavy Gtr A", "92 Heavy Gtr B", "93 Heavy Gtr C", "94 Heavy Gtr A+", "95 Heavy Gtr B+", "96 Heavy Gtr C+", "97 PowerChord A", "98 PowerChord B", "99 PowerChord C", "100 EG Harm", "101 Gt.FretNoise", "102 SynGtrA", "103 Syn Gtr B", "104 Syn Gtr C", "105 Harp 1A", "106 Harp 1B", "107 Harp 1C", "108 Banjo A", "109 Banjo B", "110 Banjo C", "111 Sitar A", "112 Sitar B", "113 Sitar C", "114 Dulcimer A", "115 Dulcimer B", "116 Dulcimer C", "117 Shamisen A", "118 Shamisen B", "119 Shamisen C", "120 Koto A", "121 Koto B", "122 Koto C", "123 Pick Bass A", "124 Pick Bass B", "125 Pick Bass C", "126 Fingerd Bs A", "127 Fingerd Bs B", "128 Fingerd Bs C", "129 E.Bass", "130 Fretless A", "131 Fretless B", "132 Fretless C", "133 UprightBs 1", "134 UprightBs 2A", "135 UprightBs 2B", "136 UprightBs 2C", "137 Slap Bass 1", "138 Slap & Pop", "139 Slap Bass 2", "140 Slap Bass 3", "141 Jz.Bs Thumb", "142 Jz.Bs Slap 1", "143 Jz.Bs Slap 2", "144 Jz.Bs Slap 3", "145 Jz.Bs Pop", "146 Syn Bass A", "147 Syn Bass C", "148 Mini Bs 1A", "149 Mini Bs 1B", "150 Mini Bs 1C", "151 Mini Bs 2", "152 Mini Bs 2+", "153 MC-202BsA", "154 MC-202 Bs B", "155 MC-202 Bs C", "156 Flute 1A", "157 Flute 1B", "158 Flute 1C", "159 Blow Pipe", "160 Bottle", "161 Shakuhachi", "162 Clarinet A", "163 Clarinet B", "164 Clarinet C", "165 Oboe mf A", "166 Oboe mf B", "167 Oboe mf C", "168 Sop.Sax mf A", "169 Sop.Sax mf B", "170 Sop.Sax mf C", "171 Alto Sax 1A", "172 Alto Sax 1B", "173 Alto Sax 1C", "174 Tenor Sax A", "175 Tenor Sax B", "176 Tenor Sax C", "177 Bari.Sax f A", "178 Bari.Sax f B", "179 Bari.Sax f C", "180 Harmonica A", "181 Harmonica B", "182 Harmonica C", "183 Chanter", "184 Tpt Sect. A", "185 Tpt Sect. B", "186 Tpt Sect. C", "187 Trumpet 1A", "188 Trumpet 1B", "189 Trumpet 1C", "190 Trumpet 2A", "191 Trumpet 2B", "192 Trumpet 2C", "193 HarmonMute1A", "194 HarmonMute1B", "195 HarmonMute1C", "196 Trombone 1", "197 French 1A", "198 French 1C", "199 F.Horns", "200 F.Horns", "201 F.Horns", "202 Violin A", "203 Violin B", "204 Violin C", "205 Cello A", "206 Cello B", "207 Cello C", "208 ST.Strings-R", "209 ST.Strings-L", "210 MonoStringsA", "211 MonoStringsC", "212 Pizz", "213 JP Strings1A", "214 JP Strings1B", "215 JP Strings1C", "216 JP Strings2A", "217 JP Strings2B", "218 JP Strings2C", "219 Soft Pad A", "220 Soft Pad B", "221 Soft Pad C", "222 Fantasynth A", "223 Fantasynth B", "224 Fantasynth C", "225 D-50 HeavenA", "226 D-50 HeavenB", "227 D-50 HeavenC", "228 Fine Wine", "229 D-50 Brass A", "230 D-50 Brass B", "231 D-50 Brass C", "232 D-50 BrassA+", "233 DualSquare A", "234 DualSquare C", "235 DualSquareA+", "236 Pop Voice", "237 Syn Vox 1", "238 Syn Vox 2", "239 Voice Aahs A", "240 Voice Aahs B", "241 Voice Aahs C", "242 Voice Oohs1A", "243 Voice Oohs1B", "244 Voice Oohs1C", "245 Voice Oohs2A", "246 Voice Oohs2B", "247 Voice Oohs2C", "248 Voice Breath", "249 Male Ooh A", "250 Male Ooh B", "251 Male Ooh C", "252 Org Vox A", "253 Org Vox B", "254 Org Vox C", "255 Vox Noise"]

const intBWaves = ["1 Kalimba", "2 Marimba Wave", "3 Log Drum", "4 Vibes", "5 Bottle Hit", "6 Glockenspiel", "7 Tubular", "8 Steel Drums", "9 Fanta Bell A", "10 Fanta Bell B", "11 Fanta Bell C", "12 FantaBell A+", "13 Org Bell", "14 Agogo", "15 DIGI Bell 1", "16 DIGI Bell 1+", "17 DIGI Chime", "18 Wave Scan", "19 Wire String", "20 2.2 Bellwave", "21 2.2 Vibwave", "22 Spark VOX", "23 MMM VOX", "24 Lead Wave", "25 Synth Reed", "26 Synth Saw 1", "27 Synth Saw 2", "28 Syn Saw 2inv", "29 Synth Saw 3", "30 JP-8 Saw A", "31 JP-8 Saw B", "32 JP-8 Saw C", "33 P5 Saw A", "34 P5 Saw B", "35 P5 Saw C", "36 D-50 Saw A", "37 D-50 Saw B", "38 D-50 Saw C", "39 Synth Square", "40 JP-8 SquareA", "41 JP-8 SquareB", "42 JP-8 SquareC", "43 Synth Pulse1", "44 Synth Pulse2", "45 Triangle", "46 Sine", "47 OrgClick", "48 White Noise", "49 Pink Noise", "50 Metal Wind", "51 Wind Agogo", "52 Feedbackwave", "53 Spectrum", "54 BreathNoise", "55 Rattles", "56 Ice Rain", "57 Tin Wave", "58 Anklungs", "59 Wind Chimes", "60 Orch. Hit", "61 Tekno Hit", "62 Back Hit", "63 Philly Hit", "64 Scratch 1", "65 Scratch 2", "66 Scratch 3", "67 Natural SN1", "68 Natural SN2", "69 Piccolo SN", "70 Ballad SN", "71 SN Roll", "72 808 SN", "73 Brush Slap", "74 Brush Swish", "75 Brush Roll", "76 Dry Stick", "77 Side Stick", "78 Lite Kick", "79 Hybrid Kick1", "80 Hybrid Kick2", "81 Old Kick", "82 Verb Kick", "83 Round Kick", "84 808 Kick", "85 Verb Tom Hi", "86 Verb Tom Lo", "87 Dry Tom Hi", "88 Dry Tom Lo", "89 Cl HiHat 1", "90 Cl HiHat 2", "91 Op HiHat", "92 Pedal HiHat", "93 606 HiHat Cl", "94 606 HiHat Op", "95 808 Claps", "96 Hand Claps", "97 Finger Snaps", "98 Ride1", "99 Ride 2", "100 Ride Bell 1", "101 Crash 1", "102 China Cym", "103 Cowbell 1", "104 Wood Block", "105 Claves", "106 Bongo Hi", "107 Bongo Lo", "108 Cga Open Hi", "109 Cga Open Lo", "110 Cga Mute Hi", "111 Cga Mute Lo", "112 Cga Slap", "113 Timbale", "114 Cabasa Up", "115 Cabasa Down", "116 Cabasa Cut", "117 Maracas", "118 Long Guiro", "119 Tambourine", "120 Open Triangl", "121 Cuica", "122 Vibraslap", "123 Timpani", "124 Applause", "125 REV Orch.Hit", "126 REV TeknoHit", "127 REV Back Hit", "128 REV PhillHit", "129 REV Steel DR", "130 REV Tin Wave", "131 REV NatrlSN1", "132 REV NatrlSN2", "133 REV PiccloSN", "134 REV BalladSN", "135 REV Side Stk", "136 REV SN Roll", "137 REV Brush 1", "138 REV Brush 2", "139 REV Brush 3", "140 REV LiteKick", "141 REV HybridK1", "142 REV HybridK2", "143 REV Old Kick", "144 REV Timpani", "145 REV VerbTomH", "146 REV VerbTomL", "147 REV DryTom H", "148 REV DryTom M", "149 REV ClHiHat1", "150 REV ClHiHat2", "151 REV Op HiHat", "152 REV Pedal HH", "153 REV 606HH Cl", "154 REV 606HH Op", "155 REV Ride", "156 REV Cup", "157 REV Crash 1", "158 REV China", "159 REV DrySick", "160 REV RealCLP", "161 REV FingSnap", "162 REV Cowbell", "163 REV WoodBlck", "164 REV Clve", "165 REV Conga", "166 REV Tamb", "167 REV Maracas", "168 REV Guiro", "169 REV Cuica", "170 REV Metro", "171 Loop 1", "172 Loop 2", "173 Loop 3", "174 Loop 4", "175 Loop 5", "176 Loop 6", "177 Loop 7", "178 R8 Click", "179 Metronome 1", "180 Metronome 2", "181 MC500 Beep 1", "182 MC500 Beep 2", "183 Low Saw", "184 Low Saw inv", "185 Low P5 Saw", "186 Low Pulse 1", "187 Low Pulse 2", "188 Low Square", "189 Low Sine", "190 Low Triangle", "191 Low White NZ", "192 Low Pink NZ", "193 DC L"]

const patchWerk = JVXP.voicePatchWerk(commonPatchWerk, tonePatchWerk, "jv1080-init")

module.exports = {
  patchWerk: patchWerk,
  bankWerk: JVXP.voiceBankWerk(patchWerk),
  fxTypes: fxTypes,
  fxControlSources: fxControlSources,
  chorusOuts: chorusOuts,
  reverbTypes: reverbTypes,
  reverbHFDamps: reverbHFDamps,
  toneParms: toneParms,
  intAWaves: intAWaves,
  intBWaves: intBWaves,
  blankWaves: (255).map(i => `${i+1}`),
}