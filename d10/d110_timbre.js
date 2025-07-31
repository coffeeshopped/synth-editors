
//    static func startAddress(_ path: SynthPath?) -> RolandAddress {
//      let endex = path?.endex ?? 0
//      return 0x030000 + (endex * RolandAddress(0x10))
//    }
      
const parms = [
  ['tone/group', { b: 0x00, opts: D10.Patch.toneGroupOptions }],
  ['tone/number', { b: 0x01, opts: D10.Patch.toneNumberOptions }],
  ['tune', { b: 0x02, max: 48, dispOff: -24 }],
  ['fine', { b: 0x03, max: 100, dispOff: -50 }],
  ['bend', { b: 0x04, max: 24 }],
  ['assign/mode', { b: 0x05, opts: D10.Patch.assignModeOptions }],
  ['out/assign', { b: 0x06, opts: ["Mix","Mix","Multi 1","Multi 2","Multi 3","Multi 4","Multi 5","Multi 6"] }],
  ['out/level', { b: 0x08, max: 100 }],
  ['pan', { b: 0x09, max: 14, dispOff: -7 }],
  ['key/lo', { b: 0x0a, iso: ['noteName', "C-1"] }],
  ['key/hi', { b: 0x0b, iso: ['noteName', "C-1"] }],
]

// size used to be 0x08. why? is that for D-10?
// ah, because in MEMORY they're only 08. But temporary area is 0x10 and includes extra params (level, pan)

const patchWerk = {
  single: "Timbre",
  parms: parms,
  size: 0x10,
}

module.exports = {
  patchWerk,
}