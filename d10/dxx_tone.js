

const structOptions = (13).map(i => `d10-struct_${i+1}`)

const commonParms = [
  ['structure/0', { b: 0x0a, opts: structOptions }],
  ['structure/1', { b: 0x0b, opts: structOptions }],
  ['tone/0/on', { b: 0x0c, bit: 0 }],
  ['tone/1/on', { b: 0x0c, bit: 1 }],
  ['tone/2/on', { b: 0x0c, bit: 2 }],
  ['tone/3/on', { b: 0x0c, bit: 3 }],
  ['env/sustain', { b: 0x0d, opts: ["Normal","No Sustain"] }],
]

const commonPatchWerk = {
  single: "Tone Common", 
  parms: commonParms,
  size: 0x0e,
  name: [0, 9],
}


// PARTIAL

const bankOptions = [
  0 : "Bank 1",
  2 : "Bank 2",
]

const pitchKeyTrkOptions = ["-1", "-1/2","-1/4","0","1/8","1/4","3/8","1/2","5/8", "3/4","7/8","1","5/4","3/2","2","s1","s2"]

const filterKeyTrkOptions = ["-1", "-1/2","-1/4","0","1/8","1/4","3/8","1/2", "5/8","3/4","7/8","1","5/4","3/2","2"]

const waveOptions = ["Square 1", "Saw 1", "Square 2", "Saw 2"]

const pcmOptions1 = ["Bass Drum 1", "Bass Drum 2", "Bass Drum 3", "Snare Drum 1", "Snare Drum 2", "Snare Drum 3", "Snare Drum 4", "Tom Tom 1", "Tom Tom 2", "High Hat", "High Hat LP", "Crash Cymbal 1", "Crash Cymbal 2 LP", "Ride Cymbal 1", "Ride Cymbal 2 LP", "Cup", "China Cymbal 1", "China Cymbal 2 LP", "Rim Shot", "Hand Clap", "Mute High Conga", "Conga", "Bongo", "Cowbell", "Tambourine", "Agogo", "Claves", "Timbale High", "Timbale Low", "Cabasa", "Timpani Attack", "Timpani", "Acoustic Piano High", "Acoustic Piano Low", "Piano Forte Thump", "Organ Percussion", "Trumpet", "Lips", "Trombone", "Clarinet", "Flute High", "Flute Low", "Steamer", "Indian Flute", "Breath", "Vibraphone High", "Vibraphone Low", "Marimba", "Xylophone High", "Xylophone Low", "Kalimba", "Wind Bell", "Chime Bar", "Hammer", "Guiro", "Chink", "Nails", "Fretless Bass", "Pull Bass", "Slap Bass", "Thump Bass", "Acoustic Bass", "Elec Bass", "Gut Guitar", "Steel Guitar", "Dirty Guitar", "Pizzicato", "Harp", "Contrabass", "Cello", "Violin 1", "Violin 2", "Koto", "Draw bars LP", "High Organ LP", "Low Organ LP", "Trumpet LP", "Trombone LP", "Sax 1 LP", "Sax 2 LP", "Reed LP", "Slap Bass LP", "Acoustic Bass LP", "Elec Bass 1 LP", "Elec Bass 2 LP", "Gut Guitar LP", "Steel Guitar LP", "Elec Guitar LP", "Clav LP", "Cello LP", "Violin LP", "Elec Piano 1 LP", "Elec Piano 2 LP", "Harpsichord 1 LP", "Harpsichord 2 LP", "Telephone Bell LP", "Female Voice 1 LP", "Female Voice 2 LP", "Male Voice 1 LP", "Male Voice 2 LP", "Spectrum 1 LP", "Spectrum 2 LP", "Spectrum 3 LP", "Spectrum 4 LP", "Spectrum 5 LP", "Spectrum 6 LP", "Spectrum 7 LP", "Spectrum 8 LP", "Spectrum 9 LP", "Spectrum 10 LP", "Noise LP", "Shot 1", "Shot 2", "Shot 3", "Shot 4", "Shot 5", "Shot 6", "Shot 7", "Shot 8", "Shot 9", "Shot 10", "Shot 11", "Shot 12", "Shot 13", "Shot 14", "Shot 15", "Shot 16", "Shot 17"]

const pcmOptions2 = ["Bass Drum 1*", "Bass Drum 2*", "Bass Drum 3*", "Snare Drum 1*", "Snare Drum 2*", "Snare Drum 3*", "Snare Drum 4*", "Tom Tom 1*", "Tom Tom 2*", "High Hat*", "High Hat* LP", "Crash Cymbal 1*", "Crash Cymbal 2* LP", "Ride Cymbal 1*", "Ride Cymbal 2* LP", "Cup*", "China Cymbal 1*", "China Cymbal 2* LP", "Rim Shot*", "Hand Clap*", "Mute High Conga*", "Conga*", "Bongo*", "Cowbell*", "Tambourine*", "Agogo*", "Claves*", "Timbale High*", "Timbale Low*", "Cabasa*", "Loop 1", "Loop 2", "Loop 3", "Loop 4", "Loop 5", "Loop 6", "Loop 7", "Loop 8", "Loop 9", "Loop 10", "Loop 11", "Loop 12", "Loop 13", "Loop 14", "Loop 15", "Loop 16", "Loop 17", "Loop 18", "Loop 19", "Loop 20", "Loop 21", "Loop 22", "Loop 23", "Loop 24", "Loop 25", "Loop 26", "Loop 27", "Loop 28", "Loop 29", "Loop 30", "Loop 31", "Loop 32", "Loop 33", "Loop 34", "Loop 35", "Loop 36", "Loop 37", "Loop 38", "Loop 39", "Loop 40", "Loop 41", "Loop 42", "Loop 43", "Loop 44", "Loop 45", "Loop 46", "Loop 47", "Loop 48", "Loop 49", "Loop 50", "Loop 51", "Loop 52", "Loop 53", "Loop 54", "Loop 55", "Loop 56", "Loop 57", "Loop 58", "Loop 59", "Loop 60", "Loop 61", "Loop 62", "Loop 63", "Loop 64", "Jam 1 LP", "Jam 2 LP", "Jam 3 LP", "Jam 4 LP", "Jam 5 LP", "Jam 6 LP", "Jam 7 LP", "Jam 8 LP", "Jam 9 LP", "Jam 10 LP", "Jam 11 LP", "Jam 12 LP", "Jam 13 LP", "Jam 14 LP", "Jam 15 LP", "Jam 16 LP", "Jam 17 LP", "Jam 18 LP", "Jam 19 LP", "Jam 20 LP", "Jam 21 LP", "Jam 22 LP", "Jam 23 LP", "Jam 24 LP", "Jam 25 LP", "Jam 26 LP", "Jam 27 LP", "Jam 28 LP", "Jam 29 LP", "Jam 30 LP", "Jam 31 LP", "Jam 32 LP", "Jam 33 LP", "Jam 34 LP"]


const biasPtOptions: [Int:String] = {
  let notes = ["A","A#","B","C","C#","D","D#","E","F","F#","G","G#"]
  var options: [String] = (0..<64).map {
    let note = notes[$0 % 12]
    let octave = ($0+9)/12 + 1
    return "<\(note)\(octave)"
  }
  options += (0..<64).map {
    let note = notes[$0 % 12]
    let octave = ($0+9)/12 + 1
    return ">\(note)\(octave)"
  }
  return options
}()


const partialParms = [
  ['coarse', { b: 0x00, max: 96 }],
  ['fine', { b: 0x01, max: 100, dispOff: -50 }],
  ['pitch/keyTrk', { b: 0x02, opts: pitchKeyTrkOptions }],
  ['bend', { b: 0x03, max: 1 }],
  ['wave', { b: 0x04, opts: waveOptions }],
  ['pcm/wave', { b: 0x05 }],
  ['pw', { b: 0x06, max: 100 }],
  ['pw/velo', { b: 0x07, max: 14, dispOff: -7 }],
  { prefix: 'pitch', block: [
    ['env/depth', { b: 0x08, max: 10 }],
    ['env/velo', { b: 0x09, max: 3 }],
    ['env/time/keyTrk', { b: 0x0a, max: 4 }],
    ['env/time/0', { b: 0x0b, max: 100 }],
    ['env/time/1', { b: 0x0c, max: 100 }],
    ['env/time/2', { b: 0x0d, max: 100 }],
    ['env/time/3', { b: 0x0e, max: 100 }],
    ['env/level/-1', { b: 0x0f, max: 100, dispOff: -50 }],
    ['env/level/0', { b: 0x10, max: 100, dispOff: -50 }],
    ['env/level/1', { b: 0x11, max: 100, dispOff: -50 }],
    ['env/level/2', { b: 0x12, max: 100, dispOff: -50 }], // always 0 other than MT-32!
    ['env/level/3', { b: 0x13, max: 100, dispOff: -50 }],
    
    ['lfo/rate', { b: 0x14, max: 100 }],
    ['lfo/depth', { b: 0x15, max: 100 }],
    ['lfo/mod/sens', { b: 0x16, max: 100 }],
  ] },
  ['cutoff', { b: 0x17, max: 100 }],
  ['reson', { b: 0x18, max: 30 }],
  { prefix: 'filter', block: [
    ['keyTrk', { b: 0x19, opts: filterKeyTrkOptions }],
    ['bias/pt', { b: 0x1a, opts: biasPtOptions }],
    ['bias/level', { b: 0x1b, max: 14, dispOff: -7 }],
    
    ['env/depth', { b: 0x1c, max: 100 }],
    ['env/velo', { b: 0x1d, max: 100 }],
    ['env/depth/keyTrk', { b: 0x1e, max: 4 }],
    ['env/time/keyTrk', { b: 0x1f, max: 4 }],
    { prefix: "env/time", count: 5, bx: 1, block: [
      ['', { b: 0x20, max: 100 }],
    ] },
    { prefix: "env/level", count: 4, bx: 1, block: [
      ['', { b: 0x25, max: 100 }],
    ] },
  ] },
  { prefix: 'amp', block: [
    ['level', { b: 0x29, max: 100 }],
    ['velo/sens', { b: 0x2a, max: 100, dispOff: -50 }],
    ['bias/pt/0', { b: 0x2b, opts: biasPtOptions }],
    ['bias/level/0', { b: 0x2c, max: 12, dispOff: -12 }],
    ['bias/pt/1', { b: 0x2d, opts: biasPtOptions }],
    ['bias/level/1', { b: 0x2e, max: 12, dispOff: -12 }],
    ['env/time/keyTrk', { b: 0x2f, max: 4 }],
    ['env/time/velo', { b: 0x30, max: 4 }],
    { prefix: "env/time", count: 5, bx: 1, block: [
      ['', { b: 0x31, max: 100 }],
    ] },
    { prefix: "env/level", count: 4, bx: 1, block: [
      ['', { b: 0x36, max: 100 }],
    ] },
  ] },
]

const partialPatchWerk = {
  single: Tone Partial",
  parms: partialParms,
  size: 0x3a,
}

// 296: older Patch Base format, stored as 5 separate msgs, (auto-calc'ed fileDataCount)
// 256: newer compact, 1 msg format. same as dump
const tonePatchWerk = {
  multi: "Tone",
  map: [
    ["common", 0x0000, commonPatchWerk],
    ["tone/0", 0x000e, partialPatchWerk],
    ["tone/1", 0x0048, partialPatchWerk],
    ["tone/2", 0x0102, partialPatchWerk],
    ["tone/3", 0x013c, partialPatchWerk],
  ],
  initFile: "D110-init",
  bundle:  MultiPatchTruss.fileDataCountBundle(trusses: map.map { $0.werk.truss }, validSizes: [256, 266], includeFileDataCount: true)
}

// returns whether given partial is PCM (vs. Wave) for given structure
function isPCM(structure, partial) {
  const upperPartialPCMStructures = [3,4,6,7,9,11,13]
  const lowerPartialPCMStructures = [5,6,7,9,12,13]
  switch partial {
  case 0, 2:
    return upperPartialPCMStructures.contains(structure + 1)
  case 1, 3:
    return lowerPartialPCMStructures.contains(structure + 1)
  default:
    return false
  }
}

// 14407 is fetch count when sending one big request
// 17014 is fetched count when fetching patch-by-patch (back and forth request/response)
const bankWerk = {
  compactMultiBank: tonePatchWerk,
  patchCount: 64,
  // TODO:
  // iso: .init(address: {
  //   0x0200 * Int($0)
  // }, location: {
  //   $0.sysexBytes(count: sysexWerk.addressCount)[1] / 2
  // }), validBundle: MultiBankTruss.fileDataCountBundle(patchTruss: patchWerk.truss, patchCount: 64, validSizes: [14407, 17014, 17067], includeFileDataCount: true))
}