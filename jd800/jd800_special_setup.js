

const commonParms = [
  ["lo/freq", { b: 0x0, opts: ["200", "400"] }],
  ["lo/gain", { b: 0x1, max: 30, dispOff: -15 }],
  ["mid/freq", { b: 0x2, opts: ["200", "250", "315", "400", "500", "630", "800", "1k", "1.25k", "1.6k", "2k", "2.5k", "3.15k", "4k", "5k", "6.3k", "8kHz"] }],
  ["mid/q", { b: 0x3, opts: ["0.5", "1.0", "2.0", "4.0", "9.0"] }],
  ["mid/gain", { b: 0x4, max: 30, dispOff: -15 }],
  ["hi/freq", { b: 0x5, opts: ["4k", "8k"] }],
  ["hi/gain", { b: 0x6, max: 30, dispOff: -15 }],
  ["bend/down", { b: 0x7, max: 48 }],
  ["bend/up", { b: 0x8, max: 12 }],
  ["aftertouch/bend", { b: 0x9, max: 26, iso: ['switch', [
    [0, -36],
    [1, -24],
  ], ['-', 14]] }],
]

const commonWerk = {
  single: 'special.common',
  parms: commonParms,
  size: 0x0a,
}

const keyParms = [
  ["mute/group", { b: 0x0A, opts: ["OFF", "A", "B", "C", "D", "E", "F", "G", "H"] }],
  ["env/mode", { b: 0x0B, opts: ["SUSTAIN", "NO SUSTAIN"] }],
  ["pan", { b: 0x0C, max: 60, dispOff: -30 }],
  ["fx/mode", { b: 0x0D, opts: ["DRY", "REV", "CHO+REV", "DLY+REV"] }],
  ["fx/level", { b: 0x0E, max: 100 }],
  { b: 0x10, offset: Voice.toneWerk.parms },
]

const keyWerk = {
  single: 'special.key',
  namePack: [0, 9],
  size: 0x58,
  parms: keyParms,
}

const patchWerk = {
  multi: 'special',
  map: ([
    ['common', 0x0000, commonWerk],
  ]).concat(
    // TODO: address math
    (61).map(i => [['note', i], 0x0a + i * 0x58, keyWerk])
  ),
  initFile: "jd800-special-setup-init"
  defaultName: "Special Setup",
}

  // static func location(forData data: Data) -> Int {
  // return 0 // just 1 per bank
// }

const bankWerk = {
  multiBank: patchWerk,
  patchCount: 1,
  initFile: "jd800-special-setup-bank-init",
}
  
  // override class func offsetAddress(location: Int) -> RolandAddress {
  //   return RolandAddress(0)
  // }

