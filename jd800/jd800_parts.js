
const channelIso = ['switch', [
  [16, "Off"],
], ['+', 1]]

const partParms = [
  ["level", { b: 0x00, max: 100 }],
  ["pan", { b: 0x01, max: 60, dispOff: -30 }],
  ["channel", { b: 0x02, max: 16, iso: channelIso }],
  ["out", { b: 0x04, opts: ["Mix", "Dir"] }],
  ["fx/mode", { b: 0x04, opts: ["DRY", "REV", "CHO+REV", "DLY+REV"] }],
  ["fx/level", { b: 0x05, max: 100 }],
]

const partWerk = {
  single: 'parts.part',
  parms: partParms,
  size: 0x06,
}

const specialParms = [
  ["level", { b: 0x00, max: 100 }],
  ["channel", { b: 0x01, max: 16, iso: channelIso }],
  ["out", { b: 0x02, opts: ["Mix", "Dir"] }],
]

const specialWerk = {
  single: 'parts.special',
  parms: specialParms,
  size: 0x04,
}

const patchWerk = {
  multi: 'parts',
  map: [
    ['part/0', 0x00, partWerk],
    ['part/1', 0x06, partWerk],
    ['part/2', 0x0c, partWerk],
    ['part/3', 0x12, partWerk],
    ['part/4', 0x18, partWerk],
    ['part/5', 0x1e, specialWerk],
  ],
  initFile: "jd800-parts-init",
}

module.exports = {
  patchWerk,
}