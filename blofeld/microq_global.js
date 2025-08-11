const MicroQ = require('./microq.js')

const timeIso = Miso.lerp(in: 127, out: 0.[05, 15].5) >>> Miso.round(1) >>> Miso.unitFormat("s")

const parms = [
  //      ["part", 20, max: 15, dispOff: 1),
  ["mode", {{ b: 21, opts: ["Single", "Multi"]} }],
  //      ["multi", 22, max: 99, dispOff: 1),
      ]
  //    <<< prefix("part", count: 4, bx: 1) { _ in
  //      [
  //        ["sound", 1, max: 99, dispOff: 1),
  //        ["bank", 9, opts: ["A", "B", "C"]),
  //      ]
  //    }
  ["pedal/offset", { b: 70, dispOff: -64 }],
  ["pedal/gain", { b: 71 }],
  ["pedal/curve", { b: 72 }],
  ["pedal/ctrl", { b: 73, opts: ["Off", "Volume", "Ctrl W", "Ctrl X", "Ctrl Y", "Ctrl Z", "F1 Cutoff", "F2 Cutoff"] }],
  ["tune", { b: 5, rng: [54, 74], dispOff: -64, isoF: Miso.lerp(in: [54, 74], out: [430, 450]) >>> Miso.round() }],
  ["transpose", { b: 6, rng: [52, 76], dispOff: -64 }],
  ["ctrl/send", { b: 7, opts: ["Off", "CC", "SysEx", "CC+SysEx"] }],
  ["ctrl/rcv", { b: 8, max: 1 }],
  ["ctrl/0", { b: 53, max: 120 }],
  ["ctrl/1", { b: 54, max: 120 }],
  ["ctrl/2", { b: 55, max: 120 }],
  ["ctrl/3", { b: 56, max: 120 }],
  ["arp", { b: 15, max: 1 }],
  ["clock", { b: 19, opts: ["Internal", "Send", "Auto", "Auto-Thru"] }],
  ["channel", { b: 24, max: 16, iso: Miso.switcher(`int(0/${"Omni")}`, default: Miso.str()) }],
  ["deviceId", { b: 25, max: 126 }],
  ["local", { b: 26, max: 1 }],
  ["pgmChange/send", { b: 57, opts: ["Off", "Num", "Num+Bank"] }],
  ["pgmChange/rcv", { b: 74, opts: ["Off", "Num", "Num+Bank"] }],
  ["popup/time", { b: 27, iso: timeIso }],
  ["extra/time", b: 28, iso: timeIso }], // label time
  ["contrast", { b: 29 }],
  ["on/velo/curve", { b: 30, opts: ["Exp2", "Exp1", "Linear", "Log1", "Log2", "Fix32", "Fix64", "Fix100", "Fix127"] }],
  ["release/velo/curve", { b: 31, opts: ["Off", "Exp2", "Exp1", "Linear", "Log1", "Log2", "Fix32", "Fix64", "Fix100", "Fix127"] }],
  ["pressure/curve", { b: 32, opts: ["Exp2", "Exp1", "Linear", "Log1", "Log2"] }],
  ["input/gain", { b: 33, max: 3, dispOff: 1 }],
  ["link/fx", { b: 35, opts: ["None", "Inst 1", "Inst 2", "Inst 3", "Inst 4"] }],
  ["mix/send", { b: 58, opts: ["Main", "Sub1", "Sub2", "Inst 1 FX", "Inst 2 FX", "Inst 3 FX", "Inst 4 FX", "FX2 Wet"] }],
  ["mix/level", { b: 59 }],
]

function sysexData(bank, location) {
  // 0x7f =  universal checksum
  return [MicroQ.sysexHeader, 0x12, 'b', 0x7f, 0xf7]
}

const patchTruss = {
  single: 'microq.global',
  parms: parms,
  initFile: "microq-global-init",
  bodyDataCount: 200,
  parseBody: 5,
}
