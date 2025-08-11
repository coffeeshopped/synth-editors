
const banks = Array.sparse([
  [0, "A"],
  [1, "B"],
  [2, "C"],
  [4, "D"],
])

const ctrlIso = Miso.switcher(`int(121/${"Global")}`, default: Miso.str())

const channelIso = Miso.switcher([
  .int(0, "Global"),
  .int(1, "Omni"),
], default: Miso.a(-1) >>> Miso.str())

const patternIso = Miso.switcher(`int(0/${"Off")}`, default: Miso.str())
const noteIso = ['noteName', "C-2"]

const parms = [
  ["volume", {b: 0, rng: [1, 127] }],
  { prefix: "ctrl", count: 4, bx: 1, block: [
    ['', {b: 1, max: 121, iso: ctrlIso}],
  ] },
  { prefix: "part", count: 16, bx: 22, block: [
    { inc: 1, b: 32, block: [
      ["bank", { p: -1, opts: banks}],
      ["number", { p: -1, max: 99, dispOff: 1}],
      ["channel", { max: 17, iso: channelIso}],
      ["volume", { }],
      ["transpose", { rng: [16, 112], dispOff: -64}],
      ["detune", { dispOff: -64}],
      ["out", { opts: ["Main", "Sub1", "Sub2", "FX1", "FX2", "FX3", "FX4", "Aux"] }],
      ["on", { opts: ["Off", "Midi"] }],
      ["pan", { dispOff: -64 }],
    ] },
    { inc: 1, b: 44, block: [
      ["velo/lo", {rng: [1, 127]}],
      ["velo/hi", {rng: [1, 127]}],
      ["key/lo", {iso: noteIso}],
      ["key/hi", {iso: noteIso}],
    ] },
  }
]

function sysexData(bank, location) {
  return sysexData(0x11, bank, location)
}

const patchTruss = {
  single: 'microq.multi',
  parms: parms,
  initFile: "microq-multi-init",
  namePack: [16, 31],
  bodyDataCount: 384,
  parseBody: 7,
}

struct MicroQMultiBank : SingleBankTemplate, PerfBank {
  typealias Template = MicroQMultiPatch
  static let patchCount: Int = 100
  static let initFileName: String = "microq-multi-bank-init"
}
