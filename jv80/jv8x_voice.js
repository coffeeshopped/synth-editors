
//      override class func startAddress(_ path: SynthPath?) -> RolandAddress {
//        return (path?.endex ?? 0) == 0 ? 0x01402000 : 0x02402000
//      }

//    static func location(forData data: Data) -> Int {
//      return Int(addressBytes(forSysex: data)[1]) - 0x40
//    }

/// MSB first. lower 4 bits of each byte used
// 2 bytes per value
const multiPack = (byte) => ['splitter', (2).map(i => {
  let loValBit = (2 - (i + 1)) * 4
  let hiValBit = loValBit + 3
  return {
    byte: (byte + i), // RolandAddress(intValue: i)).intValue(), 
    byteBits: [0, 4], 
    valueBits: [loValBit, hiValBit + 1],
  }
})]

const chorusTypes = ["Chorus 1", "Chorus 2", "Chorus 3"]
const chorusOuts = ["Mix", "Reverb"]
const reverbTypes = ["Room 1","Room 2","Stage 1","Stage 2","Hall 1","Hall 2","Delay","Pan Delay"]

const commonParms = [
  ['velo', { b: 0x0c, max: 1 }],
  ['reverb/type', { b: 0x0d, opts: reverbTypes }],
  ['reverb/level', { b: 0x0e }],
  ['reverb/time', { b: 0x0f }],
  ['reverb/feedback', { b: 0x10 }],
  ['chorus/type', { b: 0x11, opts: chorusTypes }],
  ['chorus/level', { b: 0x12 }],
  ['chorus/depth', { b: 0x13 }],
  ['chorus/rate', { b: 0x14 }],
  ['chorus/feedback', { b: 0x15 }],
  ['chorus/out/assign', { b: 0x16, opts: chorusOuts }],
  ['analogFeel', { b: 0x17 }],
  ['level', { b: 0x18 }],
  ['pan', { b: 0x19, dispOff: -64 }],
  ['bend/down', { b: 0x1a, rng: [16, 65], dispOff: -64 }],
  ['bend/up', { b: 0x1b, max: 12 }],
  ['mono', { b: 0x1c, max: 1 }],
  ['legato', { b: 0x1d, max: 1 }],
  ['porta', { b: 0x1e, max: 1 }],
  ['porta/legato', { b: 0x1f, opts: ["Legato","Normal"] }],
  ['porta/type', { b: 0x20, opts: ["Time","Rate"] }],
  ['porta/time', { b: 0x21 }],
]

const commonPatchWerk = {
  single: "Voice Common", 
  parms: commonParms, 
  size: 0x22, 
  name: [0, 0x0b], 
  randomize: () => [
    ["level", 127],
    ["pan", 64],
  ],
}

const controlDestinationOptions = ["Off", "Pitch", "Cutoff", "Resonance", "Level", "Pitch L1", "Pitch L2", "Filter L1", "Filter L2", "Amp L1", "Amp L2", "LFO1 Rate", "LFO2 Rate"]

const lfoWaveOptions = ["Tri", "Sine", "Saw", "Square", "RND1", "RND2"]

const lfoLevelOffsetOptions = ["-100", "-50", "0", "+50", "+100"]

const randomPitchOptions = ["0", "5", "10", "20", "30", "40", "50", "70", "100", "200", "300", "400", "500", "600", "800", "1200"]

const pitchKeyfollowOptions = ["-100", "-70", "-50", "-30", "-10", "0", "10", "20", "30", "40", "50", "70", "100", "120", "150", "200"]

const veloTSens = ["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"]

const blankWaveOptions = (255).map(i => `${i+1}`)

const waveOptions = ["1: Ac Piano 1", "2: SA Rhodes 1", "3: SA Rhodes 2", "4: E.Piano 1", "5: E.Piano 2", "6: Clav 1", "7: Organ 1", "8: Jazz Organ", "9: Pipe Organ", "10: Nylon GTR", "11: 6STR GTR", "12: GTR HARM", "13: Mute GTR 1", "14: Pop Strat", "15: Stratus", "16: SYN GTR", "17: Harp 1", "18: SYN Bass", "19: Pick Bass", "20: E.Bass", "21: Fretless 1", "22: Upright BS", "23: Slap Bass 1", "24: Slap & Pop", "25: Slap Bass 2", "26: Slap Bass 3", "27: Flute 1", "28: Trumpet 1", "29: Trombone 1", "30: Harmon Mute1", "31: Alto Sax 1", "32: Tenor Sax 1", "33: French 1", "34: Blow Pipe", "35: Bottle", "36: Trumpet SECT", "37: ST.Strings-A", "38: ST.Strings-L", "39: Mono Strings", "40: Pizz", "41: SYN VOX 1", "42: SYN VOX 2", "43: Male Ooh", "44: ORG VOX", "45: VOX Noise", "46: Soft Pad", "47: JP Strings", "48: Pop Voice", "49: Fine Wine", "50: Fantasynth", "51: Fanta Bell", "52: ORG Bell", "53: Agogo", "54: Bottle Hit", "55: Vibes", "56: Marimba wave", "57: Log Drum", "58: DIGI Bell 1", "59: DIGI Chime", "60: Steel Drums", "61: MMM VOX", "62: Spark VOX", "63: Wave Scan", "64: Wire String", "65: Lead Wave", "66: Synth Saw 1", "67: Synth Saw 2", "68: Synth Saw 3", "69: Synth Square", "70: Synth Pulse1", "71: Synth Pulse2", "72: Triangle", "73: Sine", "74: ORG Click", "75: White Noise", "76: Wind Agogo", "77: Metal Wind", "78: Feedbackwave", "79: Anklungs", "80: Wind Chimes", "81: Rattles", "82: Tin Wave", "83: Spectrum 1", "84: 808 SNR 1", "85: 90's Snare", "86: Piccolo SN", "87: LA Snare", "88: Whack Snare", "89: Rim Shot", "90: Bright Kick", "91: Verb Kick", "92: Round Kick", "93: 808 Kick", "94: Closed HAT 1", "95: Closed HAT 2", "96: Open HAT 1", "97: Crash 1", "98: Ride 1", "99: Ride Bell 1", "100: Power Tom Hi", "101: Power Tom Lo", "102: Cross Stick1", "103: 808 Claps", "104: Cowbell 1", "105: Tambourine", "106: Timbale", "107: CGA Mute Hi", "108: CGA Mute Lo", "109: CGA Slap", "110: Conga Hi", "111: Conga Lo", "112: Maracas", "113: Cabasa Cut", "114: Cabasa Up", "115: Cabasa Down", "116: REV Steel DR", "117: REV Tin Wave", "118: REV SN i", "119: REV SN 2", "120: REV SN 3", "121: REV SN 4", "122: REV Kick 1", "123: REV Cup", "124: REV Tom", "125: REV Cow Bell", "126: REV TAMS", "127: REV Conga", "128: REV Maracas", "129: REV Crash 1"]

const toneParms = [
  ['wave/group', { b: 0x00, opts: ["Int","Exp","PCM"] }],
  ['wave/number', { b: 0x01, packIso: multiPack(0x01), opts: waveOptions }],
  ['on', { b: 0x03, max: 1 }],
  ['fxm/on', { b: 0x04, max: 1 }],
  ['fxm/depth', { b: 0x05, max: 15, dispOff: 1 }],
  ['velo/range/lo', { b: 0x06 }],
  ['velo/range/hi', { b: 0x07 }],
  ['volume/ctrl', { b: 0x08, max: 1 }],
  ['hold/ctrl', { b: 0x09, max: 1 }],
  { prefixes: ["mod", "aftertouch", "expression"], bx: 8, block: [
    { prefix: "dest", count: 4, bx: 2, block: [
      ['', 0x0a, { opts: controlDestinationOptions }],
    ] },
    { prefix: "depth", count: 4, bx: 2, block: [
      ['', 0x0b, { rng: [1, 127], dispOff: -64 }],
    ] },
  ] },
  { prefix: "lfo", count: 2, bx: 11, block: (index, offset) => [
    ['wave', { b: 0x22, opts: lfoWaveOptions }],
    ['level/offset', { b: 0x23, opts: lfoLevelOffsetOptions }],
    ['key/trigger', { b: 0x24, max: 1 }],
    ['rate', { b: 0x25 }],
    ['delay', { b: 0x26, packIso: multiPack(0x26 + offset), max: 128 }],
    ['fade/mode', { b: 0x28, opts: ["In","Out"] }],
    ['fade/time', { b: 0x29 }],
    ['pitch', { b: 0x2a, rng: [4, 125], dispOff: -64 }],
    ['filter', { b: 0x2b, rng: [1, 128], dispOff: -64 }],
    ['amp', { b: 0x2c, rng: [1, 128], dispOff: -64 }],
  ] },
  ['coarse', { b: 0x38, rng: [16, 113], dispOff: -64 }],
  ['fine', { b: 0x39, rng: [14, 115], dispOff: -64 }],
  ['random/pitch', { b: 0x3a, opts: randomPitchOptions }],
  ['pitch/keyTrk', { b: 0x3b, opts: pitchKeyfollowOptions }],
  ['pitch/env/velo/sens', { b: 0x3c, rng: [1, 128], dispOff: -64 }],
  ['pitch/env/velo/time/0', { b: 0x3d, opts: veloTSens }],
  ['pitch/env/velo/time/3', { b: 0x3e, opts: veloTSens }],
  ['pitch/env/time/keyTrk', { b: 0x3f, opts: veloTSens }],
  ['pitch/env/depth', { b: 0x40, rng: [52, 77], dispOff: -64 }],
  ['pitch/env/time/0', { b: 0x41 }],
  ['pitch/env/level/0', { b: 0x42, rng: [1, 128], dispOff: -64 }],
  ['pitch/env/time/1', { b: 0x43 }],
  ['pitch/env/level/1', { b: 0x44, rng: [1, 128], dispOff: -64 }],
  ['pitch/env/time/2', { b: 0x45 }],
  ['pitch/env/level/2', { b: 0x46, rng: [1, 128], dispOff: -64 }],
  ['pitch/env/time/3', { b: 0x47 }],
  ['pitch/env/level/3', { b: 0x48, rng: [1, 128], dispOff: -64 }],
  
  ['filter/type', { b: 0x49, opts: ["Off","LPF","HPF"] }],
  ['cutoff', { b: 0x4a }],
  ['reson', { b: 0x4b }],
  ['reson/mode', { b: 0x4c, opts: ["Soft", "Hard"] }],
  ['cutoff/keyTrk', { b: 0x4d, opts: pitchKeyfollowOptions }],
  ['filter/env/velo/curve', { b: 0x4e, max: 6, dispOff: 1 }],
  ['filter/env/velo/sens', { b: 0x4f, rng: [1, 128], dispOff: -64 }],
  ['filter/env/velo/time/0', { b: 0x50, opts: veloTSens }],
  ['filter/env/velo/time/3', { b: 0x51, opts: veloTSens }],
  ['filter/env/time/keyTrk', { b: 0x52, opts: veloTSens }],
  ['filter/env/depth', { b: 0x53, rng: [1, 128], dispOff: -64 }],
  ['filter/env/time/0', { b: 0x54 }],
  ['filter/env/level/0', { b: 0x55 }],
  ['filter/env/time/1', { b: 0x56 }],
  ['filter/env/level/1', { b: 0x57 }],
  ['filter/env/time/2', { b: 0x58 }],
  ['filter/env/level/2', { b: 0x59 }],
  ['filter/env/time/3', { b: 0x5a }],
  ['filter/env/level/3', { b: 0x5b }],
  
  ['tone/level', { b: 0x5c }],
  ['bias/level', { b: 0x5d, opts: veloTSens }],
  ['pan', { b: 0x5e, packIso: multiPack(0x5e), max: 128, dispOff: -64 }],
  ['pan/keyTrk', { b: 0x60, opts: veloTSens }],
  ['delay/mode', { b: 0x61, opts: ["Normal","Hold","Play-mate"] }],
  ['delay/time', { b: 0x62, packIso: multiPack(0x62), max: 128 }],
  ['amp/env/velo/curve', { b: 0x64, max: 6, dispOff: 1 }],
  ['amp/env/velo/sens', { b: 0x65, rng: [1, 128], dispOff: -64 }],
  ['amp/env/velo/time/0', { b: 0x66, opts: veloTSens }],
  ['amp/env/velo/time/3', { b: 0x67, opts: veloTSens }],
  ['amp/env/time/keyTrk', { b: 0x68, opts: veloTSens }],
  ['amp/env/time/0', { b: 0x69 }],
  ['amp/env/level/0', { b: 0x6a }],
  ['amp/env/time/1', { b: 0x6b }],
  ['amp/env/level/1', { b: 0x6c }],
  ['amp/env/time/2', { b: 0x6d }],
  ['amp/env/level/2', { b: 0x6e }],
  ['amp/env/time/3', { b: 0x6f }],
  
  ['out/level', { b: 0x70 }],
  ['reverb', { b: 0x71 }],
  ['chorus', { b: 0x72 }],
]  


const werks = (config) => {
  const tone = {
    single: "Voice Tone", 
    parms: toneParms.concat(config.extraParms), 
    size: config.size,
    randomize: () => [
      ["on", 1],
      ["wave/group", 0],
      ["delay/mode", 0],
      ["delay/time", 0],
      ["tone/level", 127],
      ["pan", 64],
      ["random/pitch", 0],
      ["pitch/keyTrk", 12],
      ["pitch/env/depth", 64],
      ["velo/range/lo", 1],
      ["velo/range/hi", 127],
      ["out/assign", 0],
    ]
  }
  
  const patch = {
    multi: "Voice",
    map: [
      ['common', 0x0000, commonPatchWerk],
      ['tone/0', 0x0800, tone],
      ['tone/1', 0x0900, tone],
      ['tone/2', 0x0a00, tone],
      ['tone/3', 0x0b00, tone],
    ],
    initFile: "jv880-voice",
  }
  
  return {
    patch: patch,
    bank: {
      multiBank: patch,
      patchCount: 64,
      initFile: "jv880-voice-bank", 
      // TODO:
      // iso: {
      //   address: {
      //     RolandAddress([$0, 0, 0])
      //   }, 
      //   location: {
      //   // have to do this because the address passed here is an absolute address, not an offset
      //   // whereas above in "address:", we are creating an offset address
      //   $0.sysexBytes(count: 4)[1] - 0x40
      // }),
    },
  }
}


  //      static func isValid(fileSize: Int) -> Bool {
  //        return fileSize == fileDataCount || fileSize == fileDataCount + 1 // allow for JV-880 patches
  //      }
  
  module.exports = {
    werks,
    multiPack,
    chorusTypes,
    chorusOuts,
    reverbTypes,
  }