
const commonParms = [
  ['level', { b: 0x0c }],
  ['clock/src', { b: 0x0d, opts: ["Rhythm", "System"] }],
  ['tempo', { b: 0x0e, packIso: XV.multiPack2(0x0e), rng: [20, 250] }],
  ['oneShot', { b: 0x10, max: 1 }],
]

function commonPatchWerk(outAssignOptions) {
  return {
    single: "Rhythm Common",
    parms: commonParms.concat([
      ['out/assign', { b: 0x11, opts: outAssignOptions }],
    ]),
    size: 0x12,
    name: [0, 0x0b],
    // randomize: { [
    // "level" : 127,
    // "out/assign" : 13,
    // ] 
  }
}

// TONE

const toneParms = [
  ['assign/type', { b: 0x000c, max: 1 }],
  ['mute/group', { b: 0x000d, max: 31 }],
  ['level', { b: 0x000e }],
  ['coarse', { b: 0x000f, dispOff: -64 }],
  ['fine', { b: 0x0010, rng: [14, 114], dispOff: -64 }],
  ['random/pitch', { b: 0x0011, opts: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"] }],
  ['pan', { b: 0x0012, dispOff: -64 }],
  ['random/pan', { b: 0x0013, max: 63 }],
  ['alt/pan', { b: 0x0014, rng: [1, 127], dispOff: -64 }],
  ['env/mode', { b: 0x0015, max: 1 }],
  ['dry', { b: 0x0016 }],
  ['chorus/fx', { b: 0x0017 }],
  ['reverb/fx', { b: 0x0018 }],
  ['chorus', { b: 0x0019 }],
  ['reverb', { b: 0x001a }],
//        ['out/assign', { b: 0x001b, opts: XV5050TonePatch.outAssignOptions }],
  ['bend', { b: 0x001c, max: 48 }],
  ['rcv/expression', { b: 0x001d, max: 1 }],
  ['rcv/hold', { b: 0x001e, max: 1 }],
  ['rcv/pan', { b: 0x001f, opts: ["Continuous", "Key On"] }],
  ['wave/velo', { b: 0x0020, opts: ["Off","On","Random"] }],
  { prefix: "pitch/env", block: [
    ['depth', { b: 0x0115, rng: [52, 76], dispOff: -64 }],
    ['velo', { b: 0x0116, rng: [1, 127], dispOff: -64 }],
    ['time/0/velo', { b: 0x0117, rng: [1, 127], dispOff: -64 }],
    ['time/3/velo', { b: 0x0118, rng: [1, 127], dispOff: -64 }],
    ['time/0', { b: 0x0119 }],
    ['time/1', { b: 0x011a }],
    ['time/2', { b: 0x011b }],
    ['time/3', { b: 0x011c }],
    ['level/-1', { b: 0x011d }],
    ['level/0', { b: 0x011e, rng: [1, 127], dispOff: -64 }],
    ['level/1', { b: 0x011f, rng: [1, 127], dispOff: -64 }],
    ['level/2', { b: 0x0120, rng: [1, 127], dispOff: -64 }],
    ['level/3', { b: 0x0121, rng: [1, 127], dispOff: -64 }],
  ] },
  ['filter/type', { b: 0x0122, opts: ["Off", "Lo-Pass", "Bandpass", "Hi-Pass", "Peaking", "LPF2", "LPF3"] }],
  ['cutoff', { b: 0x0123 }],
  ['cutoff/velo/curve', { b: 0x0124 }],
  ['cutoff/velo', { b: 0x0125, rng: [1, 127], dispOff: -64 }],
  ['reson', { b: 0x0126 }],
  ['reson/velo', { b: 0x0127, rng: [1, 127], dispOff: -64 }],
  { prefix: "filter/env", block: [
    ['depth', { b: 0x0128, rng: [1, 127], dispOff: -64 }],
    ['velo/curve', { b: 0x0129 }],
    ['velo', { b: 0x012a, rng: [1, 127], dispOff: -64 }],
    ['time/0/velo', { b: 0x012b, rng: [1, 127], dispOff: -64 }],
    ['time/3/velo', { b: 0x012c, rng: [1, 127], dispOff: -64 }],
    ['time/0', { b: 0x012d }],
    ['time/1', { b: 0x012e }],
    ['time/2', { b: 0x012f }],
    ['time/3', { b: 0x0130 }],
    ['level/-1', { b: 0x0131 }],
    ['level/0', { b: 0x0132 }],
    ['level/1', { b: 0x0133 }],
    ['level/2', { b: 0x0134 }],
    ['level/3', { b: 0x0135 }],
  ] },
  ['level/velo/curve', { b: 0x0136 }],
  { prefix: "amp/env", block: [
    ['velo', { b: 0x0137, rng: [1, 127], dispOff: -64 }],
    ['time/0/velo', { b: 0x0138, rng: [1, 127], dispOff: -64 }],
    ['time/3/velo', { b: 0x0139, rng: [1, 127], dispOff: -64 }],
    ['time/0', { b: 0x013a }],
    ['time/1', { b: 0x013b }],
    ['time/2', { b: 0x013c }],
    ['time/3', { b: 0x013d }],
    ['level/0', { b: 0x013e }],
    ['level/1', { b: 0x013f }],
    ['level/2', { b: 0x0140 }],
  ] },
  { prefix: "wave", count: 4, bx: (0x3e - 0x21), block: { (i, off) => [
    ['on', { b: 0x21, max: 1 }],
    ['wave/group', { b: 0x22, opts: ["Int","SR-JV80","SRX"] }],
    ['wave/group/id', { b: 0x23, packIso: XV.multiPack4(0x23 + off), max: 16384 }],
    ['wave/number/0', { b: 0x27, packIso: XV.multiPack4(0x27 + off), opts: XV.Voice.Tone.internalWaveOptions }],
    ['wave/number/1', { b: 0x2b, packIso: XV.multiPack4(0x2b + off), opts: XV.Voice.Tone.internalWaveOptions }],
    ['wave/gain', { b: 0x2f, opts: ["-6db", "0dB", "6dB", "12dB"] }],
    ['fxm/on', { b: 0x30, max: 1 }],
    ['fxm/color', { b: 0x31, max: 3, dispOff: 1 }],
    ['fxm/depth', { b: 0x32, max: 16 }],
    ['tempo/sync', { b: 0x33, max: 1 }],
    ['coarse', { b: 0x34, rng: [16, 112], dispOff: -64 }],
    ['fine', { b: 0x35, rng: [14, 114], dispOff: -64 }],
    ['pan', { b: 0x36, dispOff: -64 }],
    ['random/pan', { b: 0x37, max: 1 }],
    ['alt/pan', { b: 0x38, opts: ["Off", "On", "Reverse"] }],
    ['level', { b: 0x39 }],
    ['velo/range/lo', { b: 0x3a, rng: [1, 127] }],
    ['velo/range/hi', { b: 0x3b, rng: [1, 127] }],
    ['velo/fade/lo', { b: 0x3c }],
    ['velo/fade/hi', { b: 0x3d }],
  ] })
]
  
function tonePatchWerk(outAssignOptions) {
  return {
    single: "Rhythm Tone", 
    parms: (toneParms.concat([
      ['out/assign', { b: 0x001b, opts: outAssignOptions }],
    ]), 
    size: 0x141,
    name: [0, 0x0b],
    // randomize: {
    // [
    //   "level" : 127,
    //   "out/assign" : (0...1).rand(),
    //   "dry" : 127,
    //   "coarse" : (57...71).rand(),
    //   "fine" : (57...71).rand(),
    //   "random/pitch" : 0,
    //   "pitch/env/depth" : 64,
    //   "filter/env/depth" : (64...80).rand(),
    //   "cutoff" : (40...127).rand(),
    //   "cutoff/velo" : (64...127).rand(),
    //   "random/pan" : (54...74).rand(),
    //   "alt/pan" : (54...74).rand(),
    //   "amp/env/velo" : (54...127).rand(),
    //   "amp/env/velo/time/0" : 64,
    //   "amp/env/velo/time/3" : 64,
    //   "amp/env/time/0" : 0,
    //   "amp/env/time/1" : (30...40).rand(),
    //   "amp/env/time/2" : (20...80).rand(),
    //   "amp/env/time/3" : (0...80).rand(),
    //   "amp/env/level/0" : 127,
    //   "amp/env/level/1" : 127,
    // ] <<< 4.dict { i in
    //   ([
    //     "on" : i == 0 ? 1 : i == 1 ? (0...1).rand() : 0,
    //     "wave/group" : 0,
    //     "wave/group/id" : 1,
    //     "wave/number/0" : (632...1083).rand(),
    //     "wave/number/1" : 0,
    //     "coarse" : (57...71).rand(),
    //     "fine" : (57...71).rand(),
    //     "pan" : (54...74).rand(),
    //     "level" : 127,
    //     "velo/range/lo" : 1,
    //     "velo/range/hi" : 127,
    //     "velo/fade/lo" : 0,
    //     "velo/fade/hi" : 0,
    //   ]).prefixed("wave/i")
  }
}

// TODO: address math
function patchWerk(commonOuts, toneOuts, fx, chorus, reverb) {
  return {
    multi: "Rhythm", 
    map: ([
      ["common", 0x0000, commonPatchWerk(commonOuts)],
      ["fx", 0x0200, fx],
      ["chorus", 0x0400, chorus],
      ["reverb", 0x0600, reverb],
    ]).concat((88).map(i => 
      [["tone", i], 0x1000 + (i * 0x200), tonePatchWerk(toneOuts)]
    )),
    initFile: "xv5050-rhythm-init",
  }
}

function bankWerk(patchWerk) {
  return {
    multiBank: patchWerk,
    patchCount: 4,
    initFile: "xv5050-rhythm-bank-init",
    iso: .init(address: {
    RolandAddress([$0 << 4, 0, 0])
    }, location: {
      $0.sysexBytes(count: 4)[1] >> 4
    }),
  }
}

module.exports = {
  patchWerk,
  bankWerk,
}