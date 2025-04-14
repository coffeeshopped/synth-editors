const Voice = require('./jv8x_voice.js')

const commonParms = [
  ['key/mode', { b: 0x0c }],
  ['reverb/type', { b: 0x0d, opts: Voice.reverbTypes }],
  ['reverb/level', { b: 0x0e }],
  ['reverb/time', { b: 0x0f }],
  ['reverb/feedback', { b: 0x10 }],
  ['chorus/type', { b: 0x11, opts: Voice.chorusTypes }],
  ['chorus/level', { b: 0x12 }],
  ['chorus/depth', { b: 0x13 }],
  ['chorus/rate', { b: 0x14 }],
  ['chorus/feedback', { b: 0x15 }],
  ['chorus/out/assign', { b: 0x16, opts: Voice.chorusOuts }],
  { prefix: "part", count: 8, bx: 1, block: [
    ["voice/reserve", 0x17, { max: 28 }],
  ] },
]

const commonPatchWerk = {
  single: "Perf Common",
  parms: commonParms, 
  size: 0x1f, 
  name: [0, 0x0b],
}

const partParms = [
  ['send/on', { b: 0x00, max: 1 }],
  ['send/channel', { b: 0x01, max: 15, dispOff: 1 }],
  ['send/pgmChange', { b: 0x02, packIso: Voice.multiPack(0x02), max: 128 }],
  ['send/volume', { b: 0x04, packIso: Voice.multiPack(0x04), max: 128 }],
  ['send/pan', { b: 0x06, packIso: Voice.multiPack(0x06), max: 128 }],
  ['send/key/range/lo', { b: 0x08 }],
  ['send/key/range/hi', { b: 0x09 }],
  ['send/key/transpose', { b: 0x0a, rng: [28, 101], dispOff: -64 }],
  ['send/velo/sens', { b: 0x0b, rng: [1, 128] }],
  ['send/velo/hi', { b: 0x0c }],
  ['send/velo/curve', { b: 0x0d, max: 6, dispOff: 1 }],

  ['int/on', { b: 0x0e, max: 1 }],
  ['int/key/range/lo', { b: 0x0f }],
  ['int/key/range/hi', { b: 0x10 }],
  ['int/key/transpose', { b: 0x11, rng: [28, 101], dispOff: -64 }],
  ['int/velo/sens', { b: 0x12, rng: [1, 128] }],
  ['int/velo/hi', { b: 0x13 }],
  ['int/velo/curve', { b: 0x14, max: 6, dispOff: 1 }],

  ['on', { b: 0x15, max: 1 }],
  ['channel', { b: 0x16, max: 15, dispOff: 1 }],
  ['patch/number', { b: 0x17, packIso: Voice.multiPack(0x17), max: 255 }],
  ['level', { b: 0x19 }],
  ['pan', { b: 0x1a, dispOff: -64 }],
  ['coarse', { b: 0x1b, rng: [16, 113], dispOff: -64 }],
  ['fine', { b: 0x1c, rng: [14, 115], dispOff: -64 }],
  ['reverb', { b: 0x1d, max: 1 }],
  ['chorus', { b: 0x1e, max: 1 }],
  ['rcv/pgmChange', { b: 0x1f, max: 1 }],
  ['rcv/volume', { b: 0x20, max: 1 }],
  ['rcv/hold', { b: 0x21, max: 1 }],
]

const presetAOptions = ["1: A.Piano 1", "2: A.Piano 2", "3: Mellow Piano", "4: Pop Piano 1", "5: Pop Piano 2", "6: Pop Piano 3", "7: MIDled Grand", "8: Country Bar", "9: Glist EPiano", "10: MIDI EPiano", "11: SA Rhodes", "12: Dig Rhodes 1", "13: Dig Rhodes 2", "14: Stiky Rhodes", "15: Guitr Rhodes", "16: Nylon Rhodes", "17: Clav 1", "18: Clav 2", "19: Marimba", "20: Marimba SW", "21: Warm Vibe", "22: Vibe", "23: Wave Bells", "24: Vibrobell", "25: Pipe Organ 1", "26: Pipe Organ 2", "27: Pipe Organ 3", "28: E.Organ 1", "29: E.Organ 2", "30: Jazz Organ 1", "31: Jazz Organ 2", "32: Metal Organ", "33: Nylon Gtr 1", "34: Flanged Nyln", "35: Steel Guitar", "36: PickedGuitar", "37: 12 strings", "38: Velo Harmnix", "39: Nylon+Steel", "40: SwitchOnMute", "41: JC Strat", "42: Stratus", "43: Syn Strat", "44: Pop Strat", "45: Clean Strat", "46: Funk Gtr", "47: Syn Guitar", "48: Overdrive", "49: Fretless", "50: St Fretless", "51: Woody Bass 1", "52: Woody Bass 2", "53: Analog Bs 1", "54: House Bass", "55: Hip Bass", "56: RockOut Bass", "57: Slap Bass", "58: Thumpin Bass", "59: Pick Bass", "60: Wonder Bass", "61: Yowza Bass", "62: Rubber Bs 1", "63: Rubber Bs 2", "64: Stereoww Bs"]

const presetBOptions = ["1: Pizzicato", "2: Real Pizz", "3: Harp", "4: SoarinString", "5: Warm Strings", "6: Marcato", "7: St Strings", "8: Orch Strings", "9: Slow Strings", "10: Velo Strings", "11: BrightStrngs", "12: TremoloStrng", "13: Orch Stab 1", "14: Brite Stab", "15: JP-  8 Strings", "16: String Synth", "17: Wire Strings", "18: New Age Vox", "19: Arasian Morn", "20: Beauty Vox", "21: Vento Voxx", "22: Pvox Oooze", "23: GlassVoices", "24: Space Ahh", "25: Trumpet", "26: Trombone", "27: Harmon Mute1", "28: Harmon Mute2", "29: TeaJay Brass", "30: Brass Sect 1", "31: Brass Sect 2", "32: Brass Swell·", "33: Brass Combo", "34: Stab Brass", "35: Soft Brass", "36: Horn Brass", "37: French Horn", "38: AltoLead Sax", "39: Alto Sax", "40: Tenor Sax 1", "41: Tenor Sax 2", "42: Sax Section", "43: Sax Tp Tb", "44: FlutePiccolo", "45: Flute mod", "46: Ocarina", "47: OverblownPan", "48: Air Lead", "49: Steel Drum", "50: Log Drum", "51: Box Lead", "52: Soft Lead", "53: Whistle", "54: Square Lead", "55: Touch Lead", "56: NightShade", "57: Pizza Hutt", "58: EP+Exp Pad", "59: JP-8 Pad", "60: Puff", "61: SpaciosSweep", "62: Big n Beefy", "63: RevCymBend", "64: Analog Seq"]

const werks = (config) => {
  const part = {
    single: "Perf Part", 
    parms: partParms.concat(config.extraParms), 
    size: config.size,
  }
  
  const patch = {
    multi: "Perf", 
    map: [
      ['common', 0x0000, commonPatchWerk],
    ].concat(
      (8).map(i => [['part', i], [0x08 + i, 0x00], part])
    ),
    initFile: "jv880-perf",
  }
  
  return {
    patch: patch,
    bank: {
      multiBank: patch, 
      patchCount: 16,
      initFile: "jv880-perf-bank",
      // iso: ['lsbyte', 2],
    },
  }
}

//      static func isValid(fileSize: Int) -> Bool {
//        return fileSize == fileDataCount || fileSize == fileDataCount + 1 // allow for JV-880 patches
//      }


module.exports = {
  patchGroupOptions: ["Internal", "Card", "Preset-A", "Preset-B"],
  blankPatchOptions: (64).map(i => `${i+1}`),
  presetAOptions,
  presetBOptions,
  werks,
}