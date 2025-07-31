
// rep's Timbre memory.

const parms = [
  ['tone/group', { b: 0x00, opts: Patch.toneGroupOptions }],
  ['tone/number', { b: 0x01, opts: Patch.toneNumberOptions }],
  ['tune', { b: 0x02, max: 48, dispOff: -24 }],
  ['fine', { b: 0x03, max: 100, dispOff: -50 }],
  ['bend', { b: 0x04, max: 24 }],
  ['assign/mode', { b: 0x05, opts: Patch.assignModeOptions }],
  ['out/assign', { b: 0x06, max: 1 }], // reverb on/off
]

const patchWerk = { 
  single: "Timbre",
  parms: parms,
  size: 0x08,
  defaultName: "Timbre",
}

const bankWerk = {
  compactSingleBank: patchWerk,
  patchCount: 128,
  validSizes: [1064],
}

module.exports = {
  patchWerk,
  bankWerk,
}