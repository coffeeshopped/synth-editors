const JVXP = require('./JVXP.js')

const commonPatchWerk = { 
  werk: JVXP.sysexWerk,
  single: "Rhythm Common",
  size: 0xc, 
  start: 0x0000, 
  name: [0, 0x0c],
}

const veloTSenses = ["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"]

const noteParms = [
  ['on', { b: 0x00, max: 1 }],
  ['wave/group', { b: 0x01, opts: ["Int","PCM","Exp"] }],
  ['wave/group/id', { b: 0x02 }],
  ['wave/number', { b: 0x03, packIso: JVXP.multiPack(0x03), max: 254 }],
  ['wave/gain', { b: 0x05, opts: ["-6","0","+6","+12"] }],
  ['bend/range', { b: 0x6, max: 12 }],
  ['mute/group', { b: 0x7, max: 31 }],
  ['env/sustain', { b: 0x8, max: 1 }],
  ['volume/ctrl', { b: 0x9, max: 1 }],
  ['hold/ctrl', { b: 0xa, max: 1 }],
  ['pan/ctrl', { b: 0xb, opts: ["Off","Continuous","Key-On"] }],
  ['src/key', { b: 0x0c }],
  ['fine', { b: 0x0d, max: 100, dispOff: -50 }],
  ['random/pitch', { b: 0x0e, opts: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"] }],
  { prefix: "pitch/env", block: [
    { inc: true, b: 0x0f, block: [
      ['depth', { max: 24, dispOff: -12 }],
      ['velo/sens', { max: 125 }],
      ['velo/time', { opts: veloTSenses }],
      ['time/0', { }],
      ['time/1', { }],
      ['time/2', { }],
      ['time/3', { }],
      ['level/0', { max: 126, dispOff: -63 }],
      ['level/1', { max: 126, dispOff: -63 }],
      ['level/2', { max: 126, dispOff: -63 }],
      ['level/3', { max: 126, dispOff: -63 }],
    ] },
  ] },
  ['filter/type', { b: 0x1a, opts: ["Off","LPF","BPF","HPF","PKG"] }],
  ['cutoff', { b: 0x1b }],
  ['reson', { b: 0x1c }],
  ['reson/velo/sens', { b: 0x1d, max: 125 }],
  { prefix: "filter/env", block: [
    { inc: true, b: 0x1e, block: [
      ['depth', { max: 126, dispOff: -63 }],
      ['velo/sens', { max: 125 }],
      ['velo/time', { opts: veloTSenses }],
      ['time/0', { }],
      ['time/1', { }],
      ['time/2', { }],
      ['time/3', { }],
      ['level/0', { }],
      ['level/1', { }],
      ['level/2', { }],
      ['level/3', { }],
    ] },
  ] },
  { inc: true, b: 0x29, block: [
    ['tone/level', { }],
    { prefix: "amp/env", block: [
      ['velo/sens', { max: 125 }],
      ['velo/time', { opts: veloTSenses }],
      ['time/0', { }],
      ['time/1', { }],
      ['time/2', { }],
      ['time/3', { }],
      ['level/0', { }],
      ['level/1', { }],
      ['level/2', { }],
    ] },
    ['pan', { dispOff: -64 }],
    ['random/pan', { max: 63 }],
    ['alt/pan', { rng: [1, 128], dispOff: -63 }],
    ['out/assign', { opts: ["Mix","FX","Output 1","Output 2"] }],
    ['out/level', { }],
    ['chorus', { }],
    ['reverb', { }],
  ] }
]

const notePatchWerk = {
  werk: JVXP.sysexWerk,
  single: "Rhythm Note", 
  parms: noteParms, 
  size: 0x3a, 
  start: 0x2300, 
  initFile: "jv1080-rhythm-note-init", 
  // randomize: { [
  // "on" : 1,
  // "wave/group" : 0,
  // "wave/group/id" : (1...2).rand(),
  // "tone/level" : 127,
  // "pan" : 64,
  // "out/assign" : 0,
  // "out/level" : 127,
  // "random/pitch" : 0,
  // ] }
}

const patchWerk = {
  werk: JVXP.sysexWerk,
  multi: "Rhythm",
  map: [
    ["common", 0x0000, commonPatchWerk],
  ].concat(
    (64).map(i => [`note/${i}`, [0x23 + i, 0x00], notePatchWerk])
  ),
  start: 0x02090000, 
  initFile: "jv1080-rhythm-init",
}

module.exports = {
  patchWerk: patchWerk,
  bankWerk: {
    werk: JVXP.sysexWerk,
    multi: patchWerk,
    patchCount: 2,
    start: 0x10400000, 
    initFile: "jv1080-rhythm-bank-init",
    iso: {
      address: i => [i, 0, 0],
      // array of address bytes (count determined by werk addy count?)
      location: arr => arr[1] - 0x40,
    },
  },
}

// 
// extension JV1080 {
//   
//   enum Rhythm {
//     
//     static let patchWerk = JVXP.sysexWerk.multiPatchWerk("Rhythm", [
//       ([.common], 0x0000, Common.patchWerk),
//     ] + 64.map {
//       ([.note, .i($0)], RolandAddress([0x23 + UInt8($0), 0x00]), Note.patchWerk)
//     }, start: 0x02090000, initFile: "jv1080-rhythm-init")
// 
//     static let bankWerk = JVXP.sysexWerk.multiBankWerk(patchWerk, 2, start: 0x10400000, initFile: "jv1080-rhythm-bank-init", iso: .init(address: {
//       RolandAddress([$0, 0, 0])
//     }, location: {
//       $0.sysexBytes(count: 4)[1] - 0x40
//     }))
// 
//         
//     enum Common {
//       static let patchWerk = try! JVXP.sysexWerk.singlePatchWerk("Rhythm Common", [:], size: 0xc, start: 0x0000, name: .basic(0..<0x0c))
//     }
// 
//     enum Note {
// 
//       static let patchWerk = try! JVXP.sysexWerk.singlePatchWerk("Rhythm Note", params, size: 0x3a, start: 0x2300, initFile: "jv1080-rhythm-note-init", randomize: { [
//         [.on] : 1,
//         [.wave, .group] : 0,
//         [.wave, .group, .id] : (1...2).rand(),
//         [.tone, .level] : 127,
//         [.pan] : 64,
//         [.out, .assign] : 0,
//         [.out, .level] : 127,
//         [.random, .pitch] : 0,
//       ] })
// 
//       static let parms: [Parm] = {
//         var p: [Parm] = [
//           .p([.on], 0x00, .max(1)),
//           .p([.wave, .group], 0x01, .opts(["Int","PCM","Exp"])),
//           .p([.wave, .group, .id], 0x02),
//           .p([.wave, .number], 0x03, packIso: JVXP.multiPack(0x03), .max(254)),
//           .p([.wave, .gain], 0x05, .opts(["-6","0","+6","+12"])),
//           .p([.bend, .range], 0x6, .max(12)),
//           .p([.mute, .group], 0x7, .max(31)),
//           .p([.env, .sustain], 0x8, .max(1)),
//           .p([.volume, .ctrl], 0x9, .max(1)),
//           .p([.hold, .ctrl], 0xa, .max(1)),
//           .p([.pan, .ctrl], 0xb, .opts(["Off","Continuous","Key-On"])),
//           .p([.src, .key], 0x0c),
//           .p([.fine], 0x0d, .max(100, dispOff: -50)),
//           .p([.random, .pitch], 0x0e, .options(randomPitchOptions)),
//         ] 
//         p += .prefix([.pitch, .env]) { .inc(b: 0x0f) { [
//           .p([.depth], .max(24, dispOff: -12)),
//           .p([.velo, .sens], .max(125)),
//           .p([.velo, .time], .options(veloTSensOptions)),
//           .p([.time, .i(0)]),
//           .p([.time, .i(1)]),
//           .p([.time, .i(2)]),
//           .p([.time, .i(3)]),
//           .p([.level, .i(0)], .max(126, dispOff: -63)),
//           .p([.level, .i(1)], .max(126, dispOff: -63)),
//           .p([.level, .i(2)], .max(126, dispOff: -63)),
//           .p([.level, .i(3)], .max(126, dispOff: -63)),
//         ] } } + [
//           .p([.filter, .type], 0x1a, .opts(["Off","LPF","BPF","HPF","PKG"])),
//           .p([.cutoff], 0x1b),
//           .p([.reson], 0x1c),
//           .p([.reson, .velo, .sens], 0x1d, .max(125)),
//         ] 
//         p += .prefix([.filter, .env]) { .inc(b: 0x1e) { [
//           .p([.depth], .max(126, dispOff: -63)),
//           .p([.velo, .sens], .max(125)),
//           .p([.velo, .time], .options(veloTSensOptions)),
//           .p([.time, .i(0)]),
//           .p([.time, .i(1)]),
//           .p([.time, .i(2)]),
//           .p([.time, .i(3)]),
//           .p([.level, .i(0)]),
//           .p([.level, .i(1)]),
//           .p([.level, .i(2)]),
//           .p([.level, .i(3)]),
//         ] } } + [
//           .p([.tone, .level], 0x29),
//         ] 
//         p += .prefix([.amp, .env]) { [
//           .p([.velo, .sens], 0x2a, .max(125)),
//           .p([.velo, .time], 0x2b, .options(veloTSensOptions)),
//           .p([.time, .i(0)], 0x2c),
//           .p([.time, .i(1)], 0x2d),
//           .p([.time, .i(2)], 0x2e),
//           .p([.time, .i(3)], 0x2f),
//           .p([.level, .i(0)], 0x30),
//           .p([.level, .i(1)], 0x31),
//           .p([.level, .i(2)], 0x32),
//         ] } + [
//           .p([.pan], 0x33, .rng(dispOff: -64)),
//           .p([.random, .pan], 0x34, .max(63)),
//           .p([.alt, .pan], 0x35, .rng(1...127, dispOff: -63)),
//           .p([.out, .assign], 0x36, .opts(["Mix","FX","Output 1","Output 2"])),
//           .p([.out, .level], 0x37),
//           .p([.chorus], 0x38),
//           .p([.reverb], 0x39),
//         ]
//         return p
//       }()
//       static let params = parms.params()
//       
//       static let randomPitchOptions: [Int:String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"]
//       
//       static let veloTSensOptions: [Int:String] = ["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"]
//       
//     }
// 
//   }
//   
// }
