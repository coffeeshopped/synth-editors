
  func unpack(param: Param) -> Int? {
  guard let p = param as? ParamWithRange,
        p.range.lowerBound < 0 else { return defaultUnpack(param: param) }
  
  // handle negative values
  guard let bits = p.bits else { return Int(Int8(bitPattern: bytes[p.byte])) }
  return bytes[p.byte].signedBits(bits)
}


const rcvOptions = ["Dis", "Ena", "Intp"]

const translationIso = Miso.switcher([
  .int(0, "PBend"),
  .int(1, "ATouch")
], default: Miso.a(-2) >>> Miso.str("CC%g"))

const ec5Options = ["Off", "Sustain", "Pgm Up", "Pgm Down", "Octave Up", "Octave Down", "Porta SW", "Dist SW", "Wah SW", "Delay SW", "Chorus SW", "Reverb SW", "Arp Off/On", "Wheel3 Hold"]

const arpCtrlOptions = OptionsParam.makeOptions({
  var opts = ["Off", "PBend", "After Touch", ]
  opts += ([0, 95]).map { `CC${$0}` }
  return opts
}())

const parms = [
  ["tune", { p: 1, b: 0, rng: [-100, 100], iso: ['>', ['*', 0.1], ['+', 440], ['round', 1]] }],
  ["transpose", { p: 2, b: 1, rng: [-12, 12] }],
  ["velo/curve", { p: 3, b: 2, max: 7, dispOff: 1 }],
  ["aftertouch/curve", { p: 4, b: 3, max: 7, dispOff: 1 }],
  ["aftertouch/sens", { p: 5, b: 4, max: 99 }],
  ["z/sens", { p: 6, b: 5, max: 99 }],
  ["foot/pedal/polarity", { p: 7, b: 6, bit: 0, opts: ["+", "-"] }],
  ["foot/mode/polarity", { p: 8, b: 6, bit: 1, opts: ["+", "-"] }],
  ["transpose/mode", { p: 9, b: 6, bit: 2, opts: ["Post Kbd", "Pre TG"] }],
  ["octave/mode", { p: 10, b: 6, bit: 3, opts: ["Latch", "Unlatch"] }],
  ["scene/memory", { p: 11, b: 6, bit: 4 }], // page memory
  ["hold", { p: 12, b: 6, bit: 5 }], // 10's hold
  ["delay/on", { p: 13, b: 6, bit: 6, opts: ["On", "Bypass"] }],
  { prefix: 'scale/octave', count: 12, bx: 1, px: 1, block: [
    ["", { p: 14, b: 7, rng: [-100, 100] }],
  ] },
  { prefix: 'scale/key', count: 128, bx: 1, px: 1, block: [
    ["", { p: 26, b: 19, rng: [-100, 100] }],
  ] },
  ["memory/protect", { p: 170, b: 163, bit: 0 }],
  ["arp/memory/protect", { p: 171, b: 163, bit: 1 }],
  { prefix: 'knob', count: 5, bx: 1, px: 1, block: [
    ["ctrl", { p: 172, b: 164, opts: Voice.ctrlOptions }],
  ]},
  ["velo/ctrl", { p: 177, b: 169, opts: arpCtrlOptions }],
  ["gate/ctrl", { p: 178, b: 170, opts: arpCtrlOptions }],
  { prefix: 'extra', count: 5, bx: 1, px: 1, block: [
    ["", { p: 179, b: 171, opts: ec5Options }],
  ] },
  ["channel", { p: 184, b: 176, max: 15, dispOff: 1 }],
  ["local", { p: 185, b: 177, bit: 0 }],
  ["omni", { p: 186, b: 177, bit: 1 }],
  ["clock/src", { p: 187, b: 177, bit: 2, opts: ["Int", "Ext"] }],
  ["sysex/send", { p: 188, b: 178, bit: 0 }],
  ["sysex/rcv", { p: 189, b: 178, bit: 1 }],
  ["pgm/send", { p: 190, b: 179, bit: 0 }],
  ["pgm/rcv", { p: 191, b: 179, bit: 1 }],
  { prefix: 'bank', count: 3, bx: 2, px: 2, block: [
    ["bank/i/hi", { p: 192, b: 181 }],
    ["bank/i/lo", { p: 193, b: 180 }],
  ] },
  { prefix: 'bank', count: 3, bx: 64, px: 64, block: [
    { prefix: 'pgm', count: 64, bx: 1, px: 1, block: [
      ["loc", { p: 198, b: 186 }],
    ] },
  ] },
  ["bend/send", { p: 390, b: 378, bit: 0 }],
  ["bend/rcv", { p: 391, b: 378, bits: [1, 2], opts: rcvOptions }],
  ["bend/thru", { p: 392, b: 378, bit: 3 }],
  ["bend/transpose", { p: 393, b: 379, max: 97, iso: translationIso }],
  ["aftertouch/send", { p: 394, b: 380, bit: 0 }],
  ["aftertouch/rcv", { p: 395, b: 380, bits: [1, 2], opts: rcvOptions }],
  ["aftertouch/thru", { p: 396, b: 380, bit: 3 }],
  ["aftertouch/transpose", { p: 397, b: 381, max: 97, iso: translationIso }],
  { prefix: 'ctrl', count: 96, bx: 2, px: 4, block: [
    ["send", { p: 398, b: 382, bit: 0 }],
    ["rcv", { p: 399, b: 382, bits: [1, 2], opts: rcvOptions }],
    ["thru", { p: 400, b: 382, bit: 3 }],
    ["transpose", { p: 401, b: 383, max: 97, iso: translationIso }],
  ] },
]

const sysexData = [Prophecy.sysexHeader, 0x51, 0x00, ['pack78'], 0xf7]

const patchTruss = {
  single: 'global',
  parms: parms,
  initFile: "prophecy-global-init",
  parseBody: ['>',
    ['bytes', { start: 6, count: 656 }],
    'unpack87',
  ],
  createFile: sysexData,
}
