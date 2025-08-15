
const categoryOptions = Array.sparse([
  [0, "None"],
  [26, "Brass"],
  [40, "Seq"],
  [39, "FX/Other"],
  [9, "Key"],
  [21, "Bass"],
  [34, "Lead"],
  [36, "Str/Pad"],
])

const commonParms = [
  ["tone/level", { b: 0x000c }],
  ["porta", { b: 0x0012, max: 1 }],
  ["porta/time", { b: 0x0013 }],
  ["mono", { b: 0x0014, max: 1 }],
  ["octave/shift", { b: 0x0015, rng: [61, 67], dispOff: -64 }],
  ["bend/up", { b: 0x0016, max: 24 }],
  ["bend/down", { b: 0x0017, max: 24 }],
  ["partial/0/on", { b: 0x0019, max: 1 }],
  ["partial/0/select", { b: 0x001a, max: 1 }],
  ["partial/1/on", { b: 0x001b, max: 1 }],
  ["partial/1/select", { b: 0x001c, max: 1 }],
  ["partial/2/on", { b: 0x001d, max: 1 }],
  ["partial/2/select", { b: 0x001e, max: 1 }],
  ["ringMod", { b: 0x001f, opts: Array.sparse([[0, "Off"], [2, "On"]]) }],
  ["unison", { b: 0x002e, max: 1 }],
  ["porta/legato", { b: 0x0031, max: 1 }],
  ["legato", { b: 0x0032, max: 1 }],
  ["analogFeel", { b: 0x0034 }],
  ["wave/shape", { b: 0x0035 }],
  ["category", { b: 0x0036, opts: categoryOptions }],
  ["unison/number", { b: 0x003c, opts: ["2", "4", "6", "8"] }],
]

const commonWerk = {
  single: "Digital Common", 
  parms: commonParms, 
  size: 0x40, 
  namePack: [0, 0x0b],
}


const modifyParms = [
  ["attack/interval/sens", { b: 0x0001 }],
  ["release/interval/sens", { b: 0x0002 }],
  ["porta/interval/sens", { b: 0x0003 }],
  ["env/loop/mode", { b: 0x0004, opts: ["Off", "Free Run", "Tempo Sync"])
  ["env/loop/sync/note", { b: 0x0005, opts: ["16", "12", "8", "4", "2", "1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"] }],
  ["chromatic/porta", { b: 0x0006, max: 1 }],
]

const modifyWerk = {
  single: "Digital Modify", 
  parms: modifyParms,
  size: 0x25,
}

const lfoShapes = ["Triangle", "Sine", "Saw", "Square", "S&H", "Random"]
const lfoSyncNotes = ["16", "12", "8", "4", "2", "1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"]

const partialParms = [
  ['osc/wave', { b: 0x0000, opts: ["Saw", "Square", "PW Square", "Triangle", "Sine", "Noise", "Super Saw", "PCM Wave"] }],
  ['osc/wave/mod', { b: 0x0001, opts: ["A", "B", "C"] }],
  { inc: 1, b: 0x0003, block: [
    ['coarse', { rng: [40, 88], dispOff: -64 }],
    ['fine', { rng: [14, 114], dispOff: -64 }],
    ['pw/mod/depth', { }],
    ['pw', { }],
    ['pitch/env/attack', { }],
    ['pitch/env/decay', { }],
    ['pitch/env/depth', { rng: [1, 127], dispOff: -64 }],
    ['filter/mode', { opts: ["Bypass", "Lo-Pass", "Hi-Pass", "Bandpass", "Peaking", "LPF2", "LPF3", "LPF4"] }],
    ['filter/curve', { opts: ["-12dB", "-24dB"] }],
    ['cutoff', { }],
    ['filter/key/trk', { rng: [54, 74], dispOff: -64 }],
    ['filter/env/velo', { rng: [1, 127], dispOff: -64 }],
    ['reson', { }],
    ['filter/env/attack', { }],
    ['filter/env/decay', { }],
    ['filter/env/sustain', { }],
    ['filter/env/release', { }],
    ['filter/env/depth', { rng: [1, 127], dispOff: -64 }],
    ['amp/level', { }],
    ['amp/velo', { rng: [1, 127], dispOff: -64 }],
    ['amp/env/attack', { }],
    ['amp/env/decay', { }],
    ['amp/env/sustain', { }],
    ['amp/env/release', { }],
    ['pan', { dispOff: -64 }],
    
    ['lfo/shape', { opts: lfoShapes }],
    ['lfo/rate', { }],
    ['lfo/tempo/sync', { max: 1 }],
    ['lfo/sync/note', { opts: lfoSyncNotes }],
    
    ['lfo/fade', { }],
    ['lfo/key/sync', { max: 1 }],
    ['lfo/pitch/depth', { rng: [1, 127], dispOff: -64 }],
    ['lfo/filter/depth', { rng: [1, 127], dispOff: -64 }],
    ['lfo/amp/depth', { rng: [1, 127], dispOff: -64 }],
    ['lfo/pan/depth', { rng: [1, 127], dispOff: -64 }],
    ['mod/lfo/shape', { opts: lfoShapes }],
    ['mod/lfo/rate', { }],
    ['mod/lfo/tempo/sync', { max: 1 }],
    ['mod/lfo/sync/note', { opts: lfoSyncNotes }],
    ['pw/shift', { }],
  ] },
  ['mod/lfo/pitch/depth', { b: 0x002c, rng: [1, 127], dispOff: -64 }],
  ['mod/lfo/filter/depth', { b: 0x002d, rng: [1, 127], dispOff: -64 }],
  ['mod/lfo/amp/depth', { b: 0x002e, rng: [1, 127], dispOff: -64 }],
  ['mod/lfo/pan/depth', { b: 0x002f, rng: [1, 127], dispOff: -64 }],
  ['cutoff/aftertouch/sens', { b: 0x0030, rng: [1, 127], dispOff: -64 }],
  ['level/aftertouch/sens', { b: 0x0031, rng: [1, 127], dispOff: -64 }],
  ['wave/gain', { b: 0x0034, opts: ["-6dB", "0dB", "6dB", "12dB"] }],
  ['wave/number', { b: 0x0035, packIso: JDXi.multiPack(0x0035), opts: ["OFF", "Calc.Saw", "DistSaw Wave", "GR-300 Saw", "Lead Wave 1", "Lead Wave 2", "Unison Saw", "Saw+Sub Wave", "SqrLeadWave", "SqrLeadWave+", "FeedbackWave", "Bad Axe", "Cutting Lead", "DistTB Sqr", "Sync Sweep", "Saw Sync", "Unison Sync+", "Sync Wave", "Cutters", "Nasty", "Bagpipe Wave", "Wave Scan", "Wire String", "Lead Wave 3", "PWM Wave 1", "PWM Wave 2", "MIDI Clav", "Huge MIDI", "Wobble Bs 1", "Wobble Bs 2", "Hollow Bass", "SynBs Wave", "Solid Bass", "House Bass", "4OP FM Bass", "Fine Wine", "Bell Wave 1", "Bell Wave 1+", "Bell Wave 2", "Digi Wave 1", "Digi Wave 2", "Org Bell", "Gamelan", "Crystal", "Finger Bell", "DipthongWave", "DipthongWv +", "Hollo Wave1", "Hollo Wave2", "Hollo Wave2+", "Heaven Wave", "Doo", "MMM Vox", "Eeh Formant", "Iih Formant", "Syn Vox 1", "Syn Vox 2", "Org Vox", "Male Ooh", "LargeChrF 1", "LargeChrF 2", "Female Oohs", "Female Aahs", "Atmospheric", "Air Pad 1", "Air Pad 2", "Air Pad 3", "VP-330 Choir", "SynStrings 1", "SynStrings 2", "SynStrings 3", "SynStrings 4", "SynStrings 5", "SynStrings 6", "Revalation", "Alan's Pad", "lfo, . Poly", "Boreal Pad L", "Boreal Pad R", "HPF Pad L", "HPF Pad R", "Sweep Pad", "Chubby Ld", "Fantasy Pad", "Legend Pad", "D-50 Stack", "ChrdOfCnadaL", "ChrdOfCnadaR", "Fireflies", "JazzyBubbles", "SynthFx 1", "SynthFx 2", "X-mod, . Wave 1", "X-mod, . Wave 2", "SynVox Noise", "Dentist Nz", "Atmosphere", "Anklungs", "Xylo Seq", "O'Skool Hit", "Orch. Hit", "Punch Hit", "Philly Hit", "ClassicHseHt", "Tao Hit", "Smear Hit", "808 Kick 1Lp", "808 Kick 2Lp", "909 Kick Lp", "JD Piano", "E.Grand", "Stage EP", "Wurly", "EP Hard", "FM EP 1", "FM EP 2", "FM EP 3", "Harpsi Wave", "Clav Wave 1", "Clav Wave 2", "Vibe Wave", "Organ Wave 1", "Organ Wave 2", "PercOrgan 1", "PercOrgan 2", "Vint.Organ", "Harmonica", "Ac. Guitar", "Nylon Gtr", "Brt Strat", "Funk Guitar", "Jazz Guitar", "Dist Guitar", "D.Mute Gtr", "FatAc. Bass", "Fingerd Bass", "Picked Bass", "Fretless Bs", "Slap Bass", "Strings 1", "Strings 2", "Strings 3 L", "Strings 3 R", "Pizzagogo", "Harp Harm", "Harp Wave", "PopBrsAtk", "PopBrass", "Tp Section", "Studio Tp", "Tp Vib Mari", "Tp Hrmn Mt", "FM Brass", "Trombone", "Wide Sax", "Flute Wave", "Flute Push", "E.Sitar", "Sitar Drone", "Agogo", "Steel Drums"] }],
  ['hi/pass/cutoff', { b: 0x0039 }],
  ['saw/detune', { b: 0x003a }],
  ['mod/lfo/rate/ctrl', { b: 0x003b, rng: [1, 127], dispOff: -64 }],
  ['amp/key/trk', { b: 0x003c, rng: [54, 74], dispOff: -64 }],
]

const partialWerk = {
  singel: "Digital Partial", 
  parms: partialParms,
  size: 0x3d,
}

const extraWerk = {
  single: "Digital Extra", 
  parms: [], 
  size: 0x111,
}

const patchWerk = {
  multi: "Digital", 
  map: [
    ["common", 0x0000, commonWerk],
    ["extra", 0x0200, extraWerk],
    ["partial/0", 0x2000, partialWerk],
    ["partial/1", 0x2100, partialWerk],
    ["partial/2", 0x2200, partialWerk],
    ["mod", 0x5000, modifyWerk],
  ],
}

  //  const fileDataCount = 513
//
//  // 354: what it *should* be based on the size of the subpatches
//  // 513: what is *is* bc the JD-Xi sends an extra sysex msg. undocumented
//  static func isValid(fileSize: Int) -> Bool {
//    return fileSize == fileDataCount || fileSize == 354
//  }
  
const bankWerk = multiBankWerk(patchWerk, startOffset: 0x60, initFile: "jdxi-digital-bank-init")
