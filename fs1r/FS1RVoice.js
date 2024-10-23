const FS1R = require('./FS1R.js')

const categoryOptions = [
  "None",
  "Pf - Piano",
  "Cp - Chromatic Percussion",
  "Or - Organ",
  "Gt - Guitar",
  "Ba - Bass",
  "St - Strings/Orchestral",
  "En - Ensemble",
  "Br - Brass",
  "Rd - Reed",
  "Pi - Pipe",
  "Ld - Synth Lead",
  "Pd - Synth Pad",
  "Fx - Synth Sound Effects",
  "Et - Ethnic",
  "Pc - Percussive",
  "Se - Sound Effects",
  "Dr - Drums",
  "Sc - Synth Comping",
  "Vo - Vocal",
  "Co - Combination",
  "Wv - Material Wave",
  "Sq - Sequence",
]
const lfoWaveOptions = ["Triangle", "Saw Down", "Saw Up", "Square", "Sine", "S&H"]
const knobDestOptions = ["Off","Out","Freq","Width"]
const levelAdjustOptions = (16).map(i => `-${i*1.5} dB`)
const lsCurves = ["-lin","-exp","+exp","+lin"]

const parms = [
  ["category", { b: 0x0e, opts: categoryOptions}],
  ["lfo/0/wave", { b: 0x10, opts: lfoWaveOptions}],
  ["lfo/0/rate", { b: 0x11, max: 99}],
  ["lfo/0/delay", { b: 0x12, max: 99}],
  ["lfo/0/key/sync", { b: 0x13, max: 1}],
  ["lfo/0/pitch", { b: 0x15, max: 99}],
  ["lfo/0/amp", { b: 0x16, max: 99}],
  ["lfo/0/freq", { b: 0x17, max: 99}],
  ["lfo/1/wave", { b: 0x18, opts: lfoWaveOptions}],
  ["lfo/1/rate", { b: 0x19}],
  ["lfo/1/phase", { b: 0x1c, opts: ["0","90","180","270"]}],
  ["lfo/1/key/sync", { b: 0x1d, max: 1}],
  ["note/shift", { b: 0x1e, max: 48, dispOff: -24}],
  { prefix: "pitch/env", block: [
    ["level/-1", { b: 0x1f, max: 100, dispOff: -50}],
    ["level/0", { b: 0x20, max: 100, dispOff: -50}],
    ["level/1", { b: 0x21, max: 100, dispOff: -50}],
    ["level/3", { b: 0x22, max: 100, dispOff: -50}],
    ["time/0", { b: 0x23, max: 99}],
    ["time/1", { b: 0x24, max: 99}],
    ["time/2", { b: 0x25, max: 99}],
    ["time/3", { b: 0x26, max: 99}],
    ["velo", { b: 0x27, max: 7}],
  ] },
  ["op/7/voiced/fseq", { b: 0x28, bit: 0}],
  ["op/7/unvoiced/fseq", { b: 0x2a, bit: 0}],
  (7).map(i => [
    [`op/${i}/voiced/fseq`, { b: 0x29, bit: i}],
    [`op/${i}/unvoiced/fseq`, { b: 0x2b, bit: i}],
  ]),
  ["algo", { b: 0x2c, max: 87, dispOff: 1}],
  { prefix: 'adjust/op', count: 8, bx: 1, block: [
    ["level", { b: 0x2d, opts: levelAdjustOptions}],
  ] },
  { prefix: "pitch/env", block: [
    ["range", { b: 0x3b, opts: ["8oct","2oct","1oct","1/2oct"]}],
    ["time/scale", { b: 0x3c, max: 7}],
  ] },
  ["feedback", { b: 0x3d, max: 7}],
  ["pitch/env/level/2", { b: 0x3e, max: 100, dispOff: -50}],
  { prefix: 'formant/ctrl', count: 5, bx: 1, block: [
    ["dest", { b: 0x40, bits: [4, 6], opts: knobDestOptions}],
    ["unvoiced", { b: 0x40, bit: 3, opts: ["Voiced","Unvoiced"]}],
    ["op", { b: 0x40, bits: [0, 3], max: 7, dispOff: 1}],
    ["depth", { b: 0x45, dispOff: -64}],
  ] },
  { prefix: 'fm/ctrl', count: 5, bx: 1, block: [
    ["dest", { b: 0x4a, bits: [4, 6], opts: knobDestOptions}],
    ["unvoiced", { b: 0x4a, bit: 3, opts: ["Voiced","Unvoiced"]}],
    ["op", { b: 0x4a, bits: [0, 3], max: 7, dispOff: 1}],
    ["depth", { b: 0x4f, dispOff: -64}],
  ] },
  ["filter/type", { b: 0x54, opts: ["LFP24","LPF18","LPF12","HPF","BPF","BEF"]}],
  ["reson", { b: 0x55}],
  ["reson/velo", { b: 0x56, max: 14, dispOff: -7}],
  ["cutoff", { b: 0x57}],
  ["filter/env/depth/velo", { b: 0x58, max: 14, dispOff: -7}],
  ["cutoff/lfo/0", { b: 0x59, max: 99}],
  ["cutoff/lfo/1", { b: 0x5a, max: 99}],
  ["cutoff/key/scale/depth", { b: 0x5b, dispOff: -64}],
  ["cutoff/key/scale/pt", { b: 0x5c}],
  ["filter/gain", { b: 0x5d, max: 24, dispOff: -12}],
  ["filter/env/depth", { b: 0x64, dispOff: -64}],
  { prefix: 'filter/env', count: 4, bx: 1, block: [
    ["level", { b: 0x66, max: 100, dispOff: -50}],
    ["time", { b: 0x69, max: 99}],
  ]},
  { prefix: 'filter/env', block: [
    ["attack/velo", { b: 0x6e, bits: [0, 3], max: 7}],
    ["time/scale", { b: 0x6e, bits: [3, 6], max: 7}],
  ]},
  { b: 0x70, offset: { prefix: 'op', count: 8, bx: 62, block: { b2p: [
    { prefix: 'voiced', block: [
      ["key/sync", { b: 0x00, bit: 6}],
      ["transpose", { b: 0x00, bits: [0, 6], max: 48, dispOff: -24}],
      ["coarse", { b: 0x01, max: 31}],
      ["fine", { b: 0x02, max: 99}],
      ["note/scale", { b: 0x03, max: 99}],
      ["bw/bias/sens", { b: 0x04, bits: [3, 7], max: 14, dispOff: -7}],
      ["spectral/form", { b: 0x04, bits: [0, 3], opts: ["Sine", "All 1", "All 2", "Odd 1", "Odd 2", "Res 1", "Res 2", "Formant"]}],
      ["osc/mode", { b: 0x05, bit: 6, opts: ["Ratio","Fixed"]}],
      ["spectral/skirt", { b: 0x05, bits: [3, 6], max: 7}],
      ["fseq/trk", { b: 0x05, bits: [0, 3], max: 7, dispOff: 1}],
      ["freq/ratio/spectral", { b: 0x06, max: 99}],
      ["detune", { b: 0x07, max: 30, dispOff: -15}],
      { prefix: "freq/env", block: [
        ["innit", { b: 0x08, max: 100, dispOff: -50}],
        ["attack/level", { b: 0x09, max: 100, dispOff: -50}],
        ["attack", { b: 0x0a, max: 99}],
        ["decay", { b: 0x0b, max: 99}],
      ] },
      { prefix: "amp/env", count: 4, bx: 1, block: [
        ["level", { b: 0x0c, max: 99}],
        ["time", { b: 0x10, max: 99}],
      ] },
      { prefix: "amp/env", block: [
        ["hold", { b: 0x14, max: 99}],
        ["time/scale", { b: 0x15, max: 7}],
        ["level", { b: 0x16, max: 99}], // TODO: should this be under level/scale?
      ] },
      { prefix: "level/scale", block: [
        ["brk/pt", { b: 0x17, max: 99}],
        ["left/depth", { b: 0x18, max: 99}],
        ["right/depth", { b: 0x19, max: 99}],
        ["left/curve", { b: 0x1a, opts: lsCurves}],
        ["right/curve", { b: 0x1b, opts: lsCurves}],
      ] },
      ["freq/bias/sens", { b: 0x1f, bits: [3, 7], max: 14, dispOff: -7}],
      ["pitch/mod/sens", { b: 0x1f, bits: [0, 3], max: 7}],
      ["freq/mod/sens", { b: 0x20, bits: [4, 7], max: 7}],
      ["freq/velo", { b: 0x20, bits: [0, 4], max: 14, dispOff: -7}],
      ["amp/env/mod/sens", { b: 0x21, bits: [4, 7], max: 7}],
      ["amp/env/velo", { b: 0x21, bits: [0, 4], max: 14, dispOff: -7 }],
      ["amp/env/bias/sens", { b: 0x22, max: 14, dispOff: -7}],
    ] },
    { prefix: 'unvoiced', block: [
      ["transpose", { b: 0x23, max: 48, dispOff: -24}],
      ["mode", { b: 0x24, bits: [5, 7], opts: ["Normal","Link FO", "Link FF"]}],
      ["coarse", { b: 0x24, bits: [0, 5], max: 31}],
      ["fine", { b: 0x25, max: 99}],
      ["note/scale", { b: 0x26, max: 99}],
      ["bw", { b: 0x27, max: 99}],
      ["bw/bias/sens", { b: 0x28, max: 14, dispOff: -7}],
      ["reson", { b: 0x29, bits: [3, 6], max: 7}],
      ["skirt", { b: 0x29, bits: [0, 3], max: 7}],
      { prefix: "freq/env", block: [
        ["innit", { b: 0x2a, max: 100, dispOff: -50}],
        ["attack/level", { b: 0x2b, max: 100, dispOff: -50}],
        ["attack", { b: 0x2c, max: 99}],
        ["decay", { b: 0x2d, max: 99}],
      ] },
      ["amp/env/level", { b: 0x2e, max: 99}],
      ["level/key/scale", { b: 0x2f, max: 14, dispOff: -7}],
      { prefix: "amp/env", count: 4, bx: 1, block: [
        ["level", { b: 0x30, max: 99}],
        ["time", { b: 0x34, max: 99}],
      ] },
      { prefix: "amp/env", block: [
        ["hold", { b: 0x38, max: 99}],
        ["time/scale", { b: 0x39, max: 7}],
      ] },
      ["freq/bias/sens", { b: 0x3a, max: 14, dispOff: -7}],
      ["freq/mod/sens", { b: 0x3b, bits: [4, 7], max: 7}],
      ["freq/velo", { b: 0x3b, bits: [0, 4], max: 14, dispOff: -7}],
      ["amp/env/mod/sens", { b: 0x3c, bits: [4, 7], max: 7}],
      ["amp/env/velo", { b: 0x3c, bits: [0, 4], max: 14, dispOff: -7}],
      ["amp/env/bias/sens", { b: 0x3d, max: 14, dispOff: -7}],
    ] },
  ] } } },
]

/// sysex bytes for patch as temp voice
const tempSysexData = (deviceId, part) => FS1R.sysexData(deviceId, [0x40 + part, 0x00, 0x00])

/// sysex bytes for patch as stored in memory location
const sysexData = (deviceId, location) => FS1R.sysexData(deviceId, [0x51, 0x00, location])

const patchTruss = {
  type: 'singlePatch',
  id: "voice", 
  bodyDataCount: 608, 
  namePack: [0, 10], 
  parms: parms, 
  initFile: "fs1r-init", 
  createFile: tempSysexData(0, 0), 
  parseBody: FS1R.parseOffset,
}

const bankValidBundle = { sizes: [79232, 39616] }

//  func randomize() {
//    randomizeAllParams()
//
//    // find the output ops and set level 4 to 0
//    let algos = Self.algorithms()
//    let algoIndex = self[[.algo]]!
//
//    let algo = algos[algoIndex]
//
//    self[[.lfo, .i(0), .pitch]] = (0...1).random()!
//
//    (0..<8).forEach { op in
//      self[[.op, .i(op), .voiced, .amp, .env, .hold]] = 0
//      self[[.op, .i(op), .unvoiced, .amp, .env, .hold]] = 0
//
//      self[[.adjust, .op, .i(op), .level]] = 0
//    }
//
//    algo.outputOps.forEach { op in
//
//      self[[.op, .i(op), .voiced, .pitch, .mod, .sens]] = (0...1).random()!
//
//      self[[.op, .i(op), .voiced, .freq, .env, .innit]] = 50
//      self[[.op, .i(op), .voiced, .freq, .env, .attack, .level]] = 50
//
//      self[[.op, .i(op), .voiced, .amp, .env, .level, .i(0)]] = 90 + (0...9).random()!
//      self[[.op, .i(op), .voiced, .amp, .env, .time, .i(0)]] = (0...19).random()!
//      self[[.op, .i(op), .voiced, .amp, .env, .level, .i(2)]] = 80+(0...19).random()!
//      self[[.op, .i(op), .voiced, .amp, .env, .level, .i(3)]] = 0
//      self[[.op, .i(op), .voiced, .amp, .env, .time, .i(3)]] = (0...69).random()!
//
//      self[[.op, .i(op), .voiced, .amp, .env, .level]] = 90+(0...9).random()!
//
//      self[[.op, .i(op), .unvoiced, .amp, .env, .level, .i(0)]] = 90 + (0...9).random()!
//      self[[.op, .i(op), .unvoiced, .amp, .env, .time, .i(0)]] = (0...19).random()!
//      self[[.op, .i(op), .unvoiced, .amp, .env, .level, .i(2)]] = 80+(0...19).random()!
//      self[[.op, .i(op), .unvoiced, .amp, .env, .level, .i(3)]] = 0
//      self[[.op, .i(op), .unvoiced, .amp, .env, .time, .i(3)]] = (0...69).random()!
//
//
//      self[[.op, .i(op), .voiced, .level, .scale, .left, .depth]] = (0...9).random()!
//      self[[.op, .i(op), .voiced, .level, .scale, .right, .depth]] = (0...9).random()!
//    }
//
//    // for one out, make it harmonic and louder
//    let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
//    self[[.op, .i(randomOut), .voiced, .osc, .mode]] = 0
//    self[[.op, .i(randomOut), .voiced, .coarse]] = 0
//    self[[.op, .i(randomOut), .voiced, .fine]] = 1
//
//    // flat pitch env
//    (-1...3).forEach { i in
//      self[[.pitch, .env, .level, .i(i)]] = 50
//    }
//  }
//
  
  // static func algorithms() -> [DXAlgorithm] { Algorithms.all }

// instead of sending <value>, we send the byte from the bytes array, because some params share bytes with others

const commonParamData = (part, paramAddress) =>
  FS1R.dataSetMsg(FS1R.deviceIdMap, [0x40 + part, 0x00, paramAddress], ['byte', paramAddress])

const opParamData = (part, parm, op) =>
  FS1R.dataSetMsg(FS1R.deviceIdMap, [0x60 + part, op, parm.p], ['byte', parm.b])

const fixedFreq = (coarse, fine) => {
  if (coarse <= 0) { return 0 }
  const c = Math.min(coarse, 21)
  return 14088 / Math.pow(2, 21 - (c + (fine / 128)))
}

const emptyBankOptions = (128).map(i => `${i+1}`)

const bankA = ["Ballad EP", "Clavmann", "Clavmann 2", "Digi Clav", "DX7Classic", "Mtrial Pno", "MtrialPno2", "MtrialPno3", "Real Rose", "Rose Att", "Rose Sft1", "Rose Sft2", "Suit Rose", "Velvt Rose", "4 Op Clav", "Da Comp", "Synth Bell", "Tabla", "B3JazzComp", "B3Perc3rd", "DrawOrgn", "DrawOrgn2", "DrawOrgn3", "Fs-Organ", "Full Drawb", "Ham Organ", "OR-Right", "Organ Fseq", "The Lounge", "Jazz Gtr", "Stratmann", "Acid King", "Ana Bass", "AttackBass", "B-Rave", "Bassline 1", "Bassline 2", "BlegBass", "DidgBass", "Dry Syn", "FM Bass", "FundaBass", "HyperFuzz", "JungleBass", "LoFiAcid", "Matze", "Moon Bass", "Phone Bass", "PlastBass", "PunchBass", "Syn Bass", "Technical", "FairyStrgs", "JMichel", "OB String", "ResoStrgs", "Saws", "SloDu Saws", "SS String", "SS String2", "HitMatrial", "ANSweep", "FS Brass", "Hook", "ObiehornL", "ObiehornR", "Quackz", "Stab", "Swell", "Kuchibue", "Dual Saws2", "DualSquare", "Earth Lead", "Fetish", "Glass Harp", "Glider", "Lead Saw", "Mitosis", "Retronic", "Score Pad", "Tech Lead", "Trance Csm", "Voc Lead", "Add Pad", "Beauty", "Brassetra", "CineSweep", "Fat Pad", "FormantPad", "FormSweep1", "FormSweep2", "FormSweep3", "FormSweep4", "FS Moby II", "Heimdal", "LFO Pad", "Moving", "Nebulous", "OBx Pad", "OBx Pad2", "Octavian", "Paddy", "Qwerty", "Saws&Hold", "Saws2", "SleepyPad", "Spacy Pad", "Starship", "SuperPad", "SweepersVx", "Tech Lead2", "The Seeker", "The Shadow", "Thermal", "VocPhaseA", "Win Pad", "Wind", "Caravan", "DippeDut", "Furry Bell", "Glacial", "Miracle", "MizuGuitar", "Morph", "Nightmare", "RhythmLoop", "Sho", "Spiral"]

const bankB = ["BagPipe", "BagPipe-dl", "Gamelan", "Gamelan2", "Mukkuri", "SuikinStr", "Thai Boxin", "ThumKalimb", "Big-Gamlan", "Eth-Drum1", "Eth-Drum2", "Beep VoX", "Dark", "ForceField", "Ghost", "Ghost2", "Magic", "Night", "Open Fseq", "RadioNoise", "Reso SE", "Saucer", "Scaling SE", "Slow Atk", "SpaceBomb", "WalkinRobo", "Warp1", "Warp2", "09 OpenHat", "09ClHatBel", "Beat BD", "Beat Cym", "Beat SD", "Beat Zap", "Boom", "Choos", "ClosedHat1", "ClosedHat2", "DanceKick", "FS-Kick1", "FS-Kick2", "FS-Kick3", "Hatty", "Hihat", "Nu Kick 1", "Nu Kick 2", "Nu Kick 3", "Nu Snare 1", "Nu Snare 2", "Nu Snare 3", "Open Hat 1", "Open Hat 2", "PowerKick", "Snare", "Tchak", "Tech BD", "Tech HH", "Tech Rim", "Tech SD", "TR Kick", "TR Snare", "DigiSQ1R", "DigiSQ3", "DogBytes", "Fast&Cheap", "Fmt-Pluck", "FunKey", "Funky Tech", "Fusion", "Metallic", "NoiseDecay", "Raymond", "SawSaw", "Snow Decay", "Snow Pixy", "Spellbound", "Syncorgano", "Thin Mini", "VeloSweep", "Vox Tron", "Zansyo", "Zapper", "Celebratn", "Eh Human", "FairyVoice", "FormSweep", "FS-Choir", "FS-Sweep", "Homy", "Human", "Ih Human", "Man_Eh", "NoisyVce", "Oh Human", "Shaman Woo", "Spacy Aaah", "Spacy FX", "SpacySweep", "SweepyVce", "VocoSweep", "VocPhaseB", "AN Arp 1", "AN Arp 2", "Compu Saw", "DigiSQ1", "DigiSQ2", "Drw-EuroDr", "Hard Pulse", "Harry", "New Key", "Power Key", "RythmLoop2", "Saw Pad", "TekBass", "FseqBase01", "FseqBase02", "FseqBase03", "FseqBase04", "FseqBase05", "FseqBase06", "FseqBase07", "FseqBase08", "FseqBase09", "FseqBase10", "FseqBase11", "FseqBase12", "FseqBase13", "FseqBase14"]

const bankC = ["FortePno 1", "FortePno 2", "MM-Piano 1", "MM-Piano 2", "Pianotone1", "Pianotone2", "Pianotone3", "5thPiano 1", "5thPiano 2", "PrprdPiano", "Claviano", "BrightPno1", "BrightPno2", "BrightPno3", "Dark Piano", "Digi Piano", "PianoDrops", "PowerPiano", "CP70 1", "CP70 2", "CP70 3", "El.Grand 1", "El.Grand 2", "El.Grand 3", "El.Grand 4", "MM-ElGnd 1", "MM-ElGnd 2", "E.Piano 1", "E.Piano 2", "E.Piano 3", "E.Piano 4", "E.Piano 5", "E.Piano 6", "E.Piano 7", "E.Piano 8", "E.Piano 9", "E.Piano 10", "E.Piano 11", "E.Piano 12", "E.Piano 13", "E.Piano 14", "E.Piano 15", "E.Piano 16", "E.Piano 17", "Aclectic", "DX-Road 1", "DX-Road 2", "DX-Road 3", "DX-Road 4", "DX-Road 5", "BrightEP 1", "BrightEP 2", "EP 1967", "EP 1970", "EP 1980", "EP 1985", "Soft EP 1", "Soft EP 2", "Soft EP 3", "Hard EP 1", "Hard EP 2", "Hard EP 3", "Hard EP 4", "Clicky EP", "Digitine", "Woody EP", "Metaltine", "Tinesquawk", "FullTine 1", "FullTine 2", "Wurli EP", "Wurli Road", "Dark Wurli", "Big Wurlt", "Andrian", "Blustig", "Woodmetal", "CastePiano", "Chorus EP", "BigJazzyEP", "ClearElPno", "NiteclubEP", "CosaRosa", "DX-Ragtime", "Digi Poly", "Duke EP", "DynoRoad", "Clavarpsi", "Wack EP", "HollowKeys", "HonkyTonk1", "HonkyTonk2", "PotlidKeyz", "Knock EP", "Knock Wack", "Mark III", "XtremeTine", "Mod ElPno", "3D Road", "PinchedEP", "No Tines", "Old Jazz", "Politti", "Pop Piano", "Prc ElPno", "Prds Piano", "Ratio Dob", "ThinnerEP", "Rezzo EP", "RubbaRoad", "SawBellEP", "QuikPlayEP", "Loud Piano", "Urban", "Vics EP", "DX Classic", "ToyPiano 1", "ToyPiano 2", "ToyPiano 3", "ToyPiano 4", "Plasticky", "Harpsi 1", "Harpsi 2", "Harpsi 3", "Harpsi 4", "Harpsi 5", "Harpsi 6", "Harpsi 7"]

const bankD = ["Harpsi 8", "Harpsi 9", "HarpsiWire", "AD 1600s 1", "AD 1600s 2", "AD 1900s", "Caffeine", "RazorWire", "Cembalim", "Cembalo", "ElecHarpsi", "Syn Harpsi", "DX-Clavi 1", "DX-Clavi 2", "DX-Clavi 3", "DX-Clavi 4", "DX-Clavi 5", "DX-Clavi 6", "DX-Clavi 7", "MM-Clavi 1", "MM-Clavi 2", "MM-Clavi 3", "BrightClv1", "BrightClv2", "BasoClavi", "ChorusClav", "Clavecin", "Clavi Comp", "ClaviExcel", "ClaviPluck", "ClaviStaff", "Mute Clavi", "Revinett", "SkeltonClv", "Celesta 1", "Celesta 2", "Celesta 3", "Celesta 4", "MM-Celesta", "Halloween", "Glocken 1", "Glocken 2", "Glocken 3", "Glocken 4", "Glocken 5", "Glocken 6", "HamerGlock", "Magiglokk", "AnvilGlock", "MetalGlock", "Perc Glock", "Glokenring", "SynGlock 1", "SynGlock 2", "MusicBox 1", "MusicBox 2", "MusicBox 3", "MusicBox 4", "MusicBox 5", "MusicBox 6", "MusicBox 7", "MusicBox 8", "MusicBox 9", "MusicBox10", "DX-Vibe 1", "DX-Vibe 2", "DX-Vibe 3", "DX-Vibe 4", "MM-Vibe 1", "MM-Vibe 2", "LFO Vibe", "Vocal Vibe", "Vibetron", "VibraPhone", "DX-Marimb1", "DX-Marimb2", "DX-Marimb3", "DX-Marimb4", "DX-Marimb5", "DX-Marimb6", "DX-Marimb7", "TineMallet", "Thumbpick", "EchoMalet1", "EchoMalet2", "EchoMalet3", "Congorimba", "Bamburimba", "BrightMrmb", "Guitarimba", "MellowMrmb", "Metal Mrmb", "DX-Xylo 1", "DX-Xylo 2", "DX-Xylo 3", "DX-Xylo 4", "DX-Xylo 5", "DX-Xylo 6", "Dual Xylo", "Xylo Log", "Syn Xylo", "Digi Xylo", "DX-Bell 1", "DX-Bell 2", "DX-Bell 3", "DX-Bell 4", "DX-Bell 5", "DX-Bell 6", "DX-Bell 7", "DX-Bell 8", "DX-Bell 9", "DX-Bell 10", "DX-Bell 11", "DX-Bell 12", "SparklBell", "Wire Bell", "DualSparkl", "BellGlassy", "MM-Bell", "Crystal 1", "Crystal 2", "SoftBell 1", "SoftBell 2", "Bell Pluck", "Blow Bell", "Carillon", "BellKeyzis", "Digi Log"]

const bankE = ["DumBells", "MellowBell", "Mini Bell", "Child Bell", "PPP Thing", "Stonemetal", "Syn Chime", "Air Bell", "WrapRound", "TempleBel1", "TempleBel2", "TempleBel3", "TempleBel4", "TempleBel5", "DX-Dlcm 1", "DX-Dlcm 2", "DX-Dlcm 3", "Frozentime", "MetalDlcmr", "Silk Road", "Full Organ", "DrawOrgan1", "DrawOrgan2", "DrawOrgan3", "DrawOrgan4", "DrawOrgan5", "DrawOrgan6", "DrawOrgan7", "DrawOrgan8", "DrawOrgan9", "DrawOrgn10", "DrawOrgn11", "DrawOrgn12", "DrawOrgn13", "DrawOrgn14", "DrawOrgn15", "DrawOrgn16", "Organsynth", "ChorusOrgn", "RotaryOrgn", "CirkusOrgn", "JazzDrwbr", "Keyclick", "VibraOrgan", "Farf Out", "Grinder", "JazzOrgan1", "JazzOrgan2", "PercOrgan1", "PercOrgan2", "PercOrgan3", "PercOrgan4", "PercOrgan5", "PercOrgan6", "PercOrgan7", "PercOrgan8", "PercOrgan9", "PercOrgn10", "PercOrgn11", "PercOrgn12", "PercOrgn13", "PercOrgn14", "PercOrgn15", "PercOrgn16", "PercOrgn17", "XtraPerc", "Road Organ", "Fluteorgan", "ClickNoise", "Novalis", "TouchOrgan", "RockOrgan1", "RockOrgan2", "RockOrgan3", "RockOrgan4", "RockOrgan5", "RockOrgan6", "RockOrgan7", "RockOrgan8", "RockOrgan9", "RockOrgn10", "RockOrgn11", "RockOrgn12", "RockOrgn13", "RockOrgn14", "RockOrgn15", "Vox Organ", "SynOrgan 1", "SynOrgan 2", "PlasticOrg", "PipeOrgan1", "PipeOrgan2", "PipeOrgan3", "PipeOrgan4", "PipeOrgan5", "PipeOrgan6", "PipeOrgan7", "PipeOrgan8", "TheatreOrg", "SmallPipes", "ChorusPipe", "Wedding", "DX-Chrch 1", "DX-Chrch 2", "BrightOrgn", "TamePipe", "PuffOrgan1", "PuffOrgan2", "Late Down", "SoftReedOr", "SteamOrgan", "StreetOrgn", "DX-Acrd 1", "DX-Acrd 2", "DX-Acrd 3", "DX-Acrd 4", "DX-Acrd 5", "DX-Acrd 6", "DX-TngAc", "DX-Hmnc 1", "DX-Hmnc 2", "DX-Hmnc 3", "DX-Hmnc 4", "Chromonica", "FM-Hmnc 1", "FM-Hmnc 2", "Bluesharp", "Buzzharp"]

const bankF = ["DX-AcstGt1", "DX-AcstGt2", "DX-AcstGt3", "DX-AcstGt4", "DX-AcstGt5", "GuitarBell", "LuteGuitar", "DX-PickGt1", "DX-PickGt2", "DX-PickGt3", "DX-PickGt4", "DX-PickGt5", "DX-PickGt6", "DX-PickGt7", "DX-PickGt8", "Synhalon", "Picksynth", "Compitar", "Stratish", "Banjitar", "Touch Mute", "Firenze", "Folknik", "FunkyPluck", "Guitar Box", "Long Nail", "Pianatar", "RhythmPluk", "SteelyPick", "TiteGuitar", "DX-JazzGt1", "DX-JazzGt2", "DX-JazzGt3", "DX-JazzGt4", "DX-JazzGt5", "Guitorgan", "DX-ClGt 1", "DX-ClGt 2", "DX-ClGt 3", "DX-ClGt 4", "DX-ClGt 5", "DX-ClGt 6", "DX-ClGt 7", "DX-ClGt 8", "DX-ClGt 9", "DX-ClGt 10", "DX-ClGt 11", "DX-ClGt 12", "Buzzstring", "DX-MuteGt1", "DX-MuteGt2", "DX-MuteGt3", "DX-MuteGt4", "Heavy Gage", "DX-OvDrGt", "DX-DistGt1", "DX-DistGt2", "DX-DistGt3", "DX-DistGt4", "DX-DistGt5", "Stortion1", "Pluckoww", "Stortion2", "FuzzGuitar", "DX-WoodBa1", "DX-WoodBa2", "DX-WoodBa3", "DX-WoodBa4", "DX-WoodBa5", "DX-WoodBa6", "DX-WoodBa7", "DarkWodBa1", "DarkWodBa2", "BoogieBass", "BassLegend", "DX-FngrBa1", "DX-FngrBa2", "DX-FngrBa3", "DX-FngrBa4", "Fusit Bass", "FingerPick", "HardFinger", "Harm Bass", "Inorganic", "Nasty Bass", "SkweekBass", "DX-PickBa1", "DX-PickBa2", "DX-PickBa3", "DX-PickBa4", "Bass Magic", "Chiff Bass", "Comped EB", "Metal Bass", "Owl Bass", "Pick Pluck", "Plektrumbs", "Wired Bass", "FretlesBa1", "FretlesBa2", "FretlesBa3", "FretlesBa4", "FretlesBa5", "SlapString", "Lite Slap", "RoundWound", "ImpactBass", "Afresh", "WireString", "Clakwire", "SuperBass1", "SuperBass2", "DigiBass 1", "DigiBass 2", "Digit Bass", "Draft Bass", "Brainacus", "DX-SynBa 1", "DX-SynBa 2", "DX-SynBa 3", "DX-SynBa 4", "DX-SynBa 5", "DX-SynBa 6", "DX-SynBa 7", "DX-SynBa 8", "DX-SynBa 9", "AnalogBass", "Nharmonik"]

const bankG = ["BassNovo", "BassResWp", "Cutmandu", "DX-Bass 1", "DX-Bass 2", "DX-Bass 3", "DX-Bass 4", "DX-Bass 5", "DX-Bass 6", "WireBass 1", "WireBass 2", "HardDXBass", "SmakaBass", "AnaBass 1", "AnaBass 2", "AnaBass 3", "81Z Bass", "DiscBass 1", "DiscBass 2", "Hop Bass 1", "Hop Bass 2", "After 88", "Cable Bass", "Wood Rez", "EazyAction", "ExciteBass", "PrkussBass", "Flapstick", "Jackson", "NipponBass", "Bass Knock", "Ana Stevie", "Munkhen", "Perc Bass", "Remark", "SmoothBass", "Ana Knock", "Jaco Syn", "Werksfunk", "ZedRubba", "DX-Violin1", "DX-Violin2", "DX-Violin3", "DX-Violin4", "Violinz", "DX-Viola 1", "DX-Viola 2", "DX-Viola 3", "DX-Cello 1", "DX-Cello 2", "DX-Cello 3", "DX-Cello 4", "Rosin", "DX-Str 1", "DX-Str 2", "DX-Str 3", "DX-Str 4", "DX-Str 5", "DX-Str 6", "DX-Str 7", "DX-Str 8", "DX-Str 9", "DX-Str 10", "DX-Str 11", "DX-Str 12", "DX-Str 13", "Quick Arco", "MidString1", "MidString2", "LowString1", "LowString2", "MM-String", "DX-AnaSt 1", "DX-AnaSt 2", "DX-AnaSt 3", "DX-SynSt 1", "DX-SynSt 2", "DX-SynSt 3", "DX-SynSt 4", "DX-SynSt 5", "DX-SynSt 6", "DX-SynSt 7", "WarmStr 1", "WarmStr 2", "WarmStr 3", "WarmStr 4", "Afternoon", "Agitate", "AnnaString", "Bright Str", "General", "GentleMind", "Gypsy", "MaxiString", "Michelle", "MoterDrive", "ReverbStrg", "StrMachine", "Silk Hall", "Small Sect", "Soft Bow", "Soline", "Violtron", "DX-PizzSt", "PizzString", "DX-Harp 1", "DX-Harp 2", "DX-Harp 3", "Baroquen", "Dbl Harp 1", "Dbl Harp 2", "Apollon", "CembaHarp", "ElectrHarp", "HarpStrum", "Lute Harp", "Metal Harp", "Orch Harp", "Syn Harp", "DX-Timpani", "Timpanic!", "Iron Timpa", "Ensemble", "HallOrch 1", "HallOrch 2", "Orch Brass", "DX-Trpt 1", "DX-Trpt 2"]

const bankH = ["DX-Trpt 3", "DX-Trpt 4", "DX-Trpt 5", "DX-Trpt 6", "SilverTrpt", "Solo Trpt", "SynTrumpet", "Trumponica", "DX-Trb 1", "DX-Trb 2", "DX-Trb 3", "Mute Trb", "DX-Tuba 1", "DX-Tuba 2", "DX-Tuba 3", "DX-Horn", "Hornz", "Alps Horn", "BlunchHorn", "Horn Ens", "MelowHorn1", "MelowHorn2", "SimpleHorn", "Syn Horns", "Vibra Horn", "DX-Brass 1", "DX-Brass 2", "Attack Brs", "Brasstring", "DX-BrsSec1", "DX-BrsSec2", "MM-Brass 1", "MM-Brass 2", "MM-Brass 3", "5th Brass", "Blow Brass", "Brass Sect", "Chorus Brs", "Fanfare", "Hard Brass", "Sample Brs", "Single Brs", "ThickBrass", "TightBrs 1", "TightBrs 2", "DX-SynBr 1", "DX-SynBr 2", "DX-SynBr 3", "DX-SynBr 4", "DX-SynBr 5", "DX-SynBr 6", "DX-SynBr 7", "FilterHorn", "SharpBrass", "Synthorns", "CS80-Brs 1", "CS80-Brs 2", "Ana Poly", "AnaFatBrs", "AnalogBrs", "Faze Brass", "Brassy", "Court", "DX-FatBrs", "RezAttack", "FunkyRhytm", "Chiffhorns", "Juice", "Kingdom", "PowerDrive", "Rahool Brs", "SyntiBrs", "UltraDrive", "Warm Brass", "SopranoSax", "DX-ASax 1", "DX-ASax 2", "Alto Sax", "DX-Tsax", "TenorSax", "Tenorsaxes", "Oboe 1", "Oboe 2", "Oboe 3", "Eng.Horn", "Bassoon", "DX-Clari 1", "DX-Clari 2", "Clari Solo", "Slow Clari", "VibratoCla", "Piccolo 1", "Piccolo 2", "DX-Flute 1", "DX-Flute 2", "DX-Flute 3", "DX-Flute 4", "DX-Flute 5", "DX-Flute 6", "DX-Flute 7", "Air Blower", "MetalFlute", "Song Flute", "Recorder 1", "Recorder 2", "Recorder 3", "DX-PnFlute", "Harvest", "Fuhppps!", "DX-Bottle", "Quena", "Whistle 1", "Whistle 2", "Whistle 3", "Sukiyaki", "SambaWhstl", "Cosmowhist", "DX-Ocrn 1", "DX-Ocrn 2", "DX-Ocrn 3", "DX-Sitar 1", "DX-Sitar 2", "Ethre Four", "India", "Juice Harp", "Syntholin", "Pilgrim", "Tenjiku"]

const bankI = ["Ukabanjo", "Xango", "Xanu", "Zimbalon", "DX-Banjo", "Shamisen 1", "Shamisen 2", "Shamisen 3", "DX-Koto", "DX-Klmb 1", "DX-Klmb 2", "DX-Klmb 3", "DX-Klmb 4", "DX-Klmb 5", "DX-Bagpipe", "DX-Fiddle", "African", "Bali", "Tibetan", "Charango", "Gamelan 1", "Gamelan 2", "Gamelan 3", "Kinzoku 1", "Kinzoku 2", "ScotchTone", "DX-Agogo 1", "DX-Agogo 2", "DX-Bongo", "Bongo", "DX-Clave", "DX-Perc", "Block", "Conga Drum", "Cowbell", "Flexatone", "Glaeser", "Log Drum", "SmlShaker", "Metal", "Percud", "RefrsWhstl", "Seq Pluck", "BigShaker", "Side Stick", "Perkabell", "Spoon", "DX-StelCan", "Steel Can", "DX-StelDr1", "DX-StelDr2", "SteelDrum1", "SteelDrum2", "Steel Band", "Jamaica", "Tambarin", "Triangle 1", "Triangle 2", "BellGliss1", "BellGliss2", "Twincle", "MetalBottl", "NipponDrm1", "NipponDrm2", "Janpany", "Nou", "Sumoh Drum", "HandBell 1", "HandBell 2", "JingleBell", "Light Year", "SlightBell", "TracerBell", "MM-SynDr 1", "MM-SynDr 2", "Click Kick", "Hexagon", "Whapit", "Hi-Hat", "Deep Snare", "DX-MtlSnr", "Snapie", "Snare", "Soft Head", "StreetSD", "Tom Herz", "DX-RevCym1", "DX-RevCym2", "DX-Chorus1", "DX-Chorus2", "DX-Chorus3", "DX-Chorus4", "DX-Chorus5", "DX-Chorus6", "DX-Chorus7", "DX-Chorus8", "DX-Chorus9", "DX-Voice 1", "DX-Voice 2", "MM-Voice 1", "MM-Voice 2", "MM-Voice 3", "MM-Voice 4", "DbVoxFem", "Fem Voice", "Lady Vox", "Space Vox", "Syn Vox", "Bell+Pno 1", "Bell+Pno 2", "Bell+Vibe1", "Bell+Str", "Bell+Vibe2", "Cho+Marimb", "Clavi+Bass", "DX-Ba+Lead", "DX-HpSt", "EP+Brass 1", "EP+Brass 2", "EP+Chime", "EP+Clavi", "Elec Combi", "Glock+Brs", "Glock+Pno", "Harp+Flute", "Koto+Flute", "MalletHorn", "Mrmb+Gtr"]

const bankJ = ["Orch Chime", "Pno+Flute", "StringTine", "Xylo+Brass", "DX-SynLd 1", "DX-SynLd 2", "DX-SynLd 3", "DX-SynLd 4", "DX-SynLd 5", "DX-SynLd 6", "DX-SynLd 7", "DX-SynLd 8", "DX-SynLd 9", "Pluck Lead", "Perka Lead", "GuitsynLd", "DXSynLd 1", "DXSynLd 2", "DXSynLd 3", "DXSynLd 4", "DXSynLd 5", "DXSynLd 6", "DXSynLd 7", "DXSynLd 8", "SqueezeLd", "Mooganic", "BrassLead1", "BrassLead2", "BrassLead3", "BrassLead4", "Saw Lead", "DX-SawLd 1", "DX-SawLd 2", "DX-Squar", "DX-VoiceLd", "DX-WahLead", "DXAttackLd", "CaliopLd 1", "CaliopLd 2", "CaliopLd 3", "Fifths 1", "Fifths 2", "LdSubHarm", "Buzzer", "Au Campo", "Bass Lead", "Comp Lead", "EadgbeLead", "Flap Synth", "FretlessLd", "Giovanni", "HarmoSynth", "Lead Line", "Lead Phone", "Lyle Lead", "PekingLead", "Puff Pipe", "Reed Lead", "SingleLine", "Super DX", "Sweep Lead", "Vibratoron", "DX-Vocoder", "Winwood", "DrkSweeper", "AnaBrsPad", "8bitStrPad", "DX-ChoPad1", "DX-ChoPad2", "Bow Pad 1", "Bow Pad 2", "Bow Pad 3", "Glassharp", "Wineglass", "Ice Galaxy", "Ice Heaven", "Hit Pad 1", "Hit Pad 2", "SynBrsPad1", "SynBrsPad2", "SynBrsPad3", "SynBrsPad4", "SynBrsPad5", "SynBrsPad6", "SynBrsPad7", "Vector Pad", "Pada Perka", "DX-MetalPd", "DX-SawPad", "Anna Pad", "Baroque", "BrassyWarm", "Bright Pad", "Clavi Pad", "Digi Pad", "Dispo Pad", "Ethereal", "Film Pad", "Fl.Cloud", "Floating", "Forest99", "Gior Pad", "GreenPeace", "Grunge Pad", "Hyper Sqr", "MM-Pretty", "MonsterPad", "Orwell", "PhaseSweep", "Phasers", "Glass Pad", "Sanctus", "StacHeaven", "Sweep Pad", "Water Log", "Spec-trail", "Whaser Pad", "Whisper", "WhistlePad", "DX-ScFi 1", "DX-ScFi 2", "DX-ScFi 3", "Image 1", "Image 2", "Laser 1", "Laser 2", "Laser 3", "Ri-zer"]

const bankK = ["MM-Shock 1", "MM-Shock 2", "Wallop 1", "Wallop 2", "Angel", "BackSuir", "Bird View", "ChorusElms", "DX-Stars", "Electric", "Evolution", "FM-Growth", "Paddawire", "Fantasynt", "Fluv Push", "Fmilters", "Glassy", "Glastine", "Glocker", "IceRevEcho", "InitEnsmbl", "MetalSweep", "SquareModd", "Mpndg Doom", "Mystrian", "RepertRise", "Space Trip", "Syn Rise", "Glider", "Anna DX", "Analog-X", "DX-Atms 1", "DX-Atms 2", "DX-Bright1", "DX-Bright2", "90 K", "200 K", "Arrow-X", "Attacker", "Harp Pad", "ChiLight", "Digi Calio", "Digitar", "Distracted", "FinerThing", "Fuji Stabs", "TouchyEdgy", "Metal Box", "MilkyWays", "New Elms", "Pipebells", "Synsitar", "OctiLate", "NoBoKuto", "Syn Bright", "Ting Voice", "Bottlead", "WhapSynth", "DX-Flght", "Take Off", "DX-Helicpt", "Helicopter", "DX-Ship", "DX-Train", "Mobile", "Motors", "MotorCycle", "U Boat", "Ambulance", "Whiz By", "Out-Da-Way", "Patrol Car", "Sirens", "DX-TelBusy", "DX-TelCall", "DX-TelTone", "DX-TlRing1", "DX-TlRing2", "Bugs&Birds", "DX-Insect1", "DX-Insect2", "DX-Piyo", "DX-Growl 1", "DX-Growl 2", "Animals", "DX-Wolf", "ManEater", "Alarm !", "Aura", "Chi-S&H", "Closing", "Computer", "Crasher", "DX-BigBen", "DX-Wave", "Descent", "Doppler", "Factory", "GhostLine", "Heart Beat", "Imaging", "IronEcho 1", "IronEcho 2", "MM-Fall", "MachineGun", "MobbyDick", "On the Run", "OuterLimit", "Perc Shot", "Repeater", "Jet Cars 1", "Scorchers", "Sci-Fi Too", "Jet Cars 2", "Speak-One", "Stopper", "Super Foot", "Talking DX", "Transport", "Turn Table", "UfoTakeOff", "Waterfall", "Whik Shot", "Bubblets", "Yes Talk", "Help me !", "Paranoir", "Screamy"]


module.exports = {
  patchTruss: patchTruss,
  bankTruss: {
    type: 'singleBank',
    patchTruss: patchTruss,
    patchCount: 128, 
    createFile: {
      locationMap: location => sysexData(0, location)
    },
    locationIndex: 8,
    validBundle: bankValidBundle,
  },
  bank64Truss: {
    type: 'singleBank',
    patchTruss: patchTruss,
    patchCount: 64, 
    createFile: {
      locationMap: location => sysexData(0, location)
    },
    locationIndex: 8,
    validBundle: bankValidBundle,
  },
  patchTransform: (part) => ({
    type: 'singlePatch',
    throttle: 30,
    param: (path, parm, value) => {
      // special check for fseq on/off for op, since that's a COMMON param...
      if (!(path.count == 4 && path[3] == 'fseq')) {
        let op = path[0] == 'op' ? path[1] : null
        return [[opParamData(part, parm, op), 30]]
      }
      else {
        // common params have param address stored in .b
        return [[commonParamData(part, parm.b), 30]]
      }
    }, 
    patch: [[tempSysexData(FS1R.deviceIdMap, part), 100]], 
    name: patchTruss.namePack.rangeMap(i => [
      commonParamData(part, i), 30
    ]),
  }),
  bankTransform: {
    type: 'singleBank',
    throttle: 0,
    bank: location => [sysexData(FS1R.deviceIdMap, location), 100]
  },
  fixedFreq: fixedFreq,
  voicedFreq: (oscMode, spectralForm, coarse, fine) => {
    if (oscMode == 0 && spectralForm < 7) {
      // ratio
      const c = coarse == 0 ? 0.5 : coarse
      return c + ((fine * c) / 100)
    }
    else {
      // fixed
      return fixedFreq(coarse, fine)
    }
  },
  ramBanks: [bankA, bankB, bankC, bankD, bankE, bankF, bankG, bankH, bankI, bankJ, bankK],
}