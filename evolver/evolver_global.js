
const parms = [
  ["pgm", { b: 0, dispOff: 1 }],
  ["bank", { b: 1, max: 3, dispOff: 1 }],
  ["volume", { b: 2, max: 100 }],
  ["transpose", { b: 3, max: 72, dispOff: -36 }],
  ["tempo", { b: 4, rng: [30, 250] }],
  ["clock/divide", { b: 5, opts: EvolverVoicePatch.clockDivOptions }],
  ["pgm/tempo", { b: 6, max: 1 }],
  p["midi/clock"] = OptionsParam(byte: 7, options: [
    0: "Internal",
    1: "MIDI Out",
    2: "MIDI In",
    3: "MIDI In/Out",
    6: "MIDI In, no Start/Stop"])
  ["lock/seq", { b: 8, max: 1 }],
  ["poly/chain", { b: 9, opts: ["Normal", "Echo All", "Echo Notes"] }],
  ["input/gain", { b: 10, max: 8, formatter: { `+${3 * $0}` } }],
  ["fine", { b: 11, max: 100, dispOff: -50 }],
  ["midi/rcv", { b: 12, opts: ["Off", "All", "Pgm Ch Only", "Params Only"] }],
  ["midi/send", { b: 13, opts: ["Off", "All", "Pgm Ch Only", "Params Only"] }],
  p["channel"] = RangeParam(byte: 14, maxVal: 16, formatter: {
    $0 == 0 ? "Omni" : `${$0}`
  })
]

// TODO: the old code was parsing as nibbles, but outputting (createFile) as 7-bit LSB byte followed by 1-bit MSB. What's right?

const sysexData = [0xf0, 0x01, 0x20, 0x01, 0x0f, ['nibblizeLSB', 'b'], 0xf7]

const patchTruss = {
  single: 'global',
  parms: parms,
  initFile: "evolver-global-init",
  parseBody: ['>',
    ['bytes', { start: 5, count: 32 }],
    ['denibblizeLSB'],
  ],
  createFile: sysexData,
}

const patchTransform = {
  throttle: 300,
  param: (path, parm, value) => {
    let lNib = patch.bytes[param.byte] & 0x0f
    let mNib = (patch.bytes[param.byte] >> 4) & 0x0f
    return [Data([0xf0, 0x01, 0x20, 0x01, 0x09, UInt8(param.byte), lNib, mNib, 0xf7])]

  },
  singlePatch: [[sysexData, 10]], 
}

