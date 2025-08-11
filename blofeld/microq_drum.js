
const parms = [
  { prefix: "part", count: 32, bx: 9, block: [
    { inc: 1, b: 0, block: [
      ["bank", {opts: ["A", "B", "C"]}],
      ["number", {max: 99, dispOff: 1}],
      ["out", {opts: ["Main", "Sub1", "Sub2"]}],
      ["pan", {dispOff: -64}],
      ["key", {iso: ['noteName',  "C-2"]}],
      ["transpose", {range: [4, 124], dispOff: -64}],
      ["volume", { }],
    ] }
  ] },
  fxParams(288),
  arpParams(320),
]

function sysexData(bank, location) {
  return MicroQ.sysexData(0x12, bank, location)
}

const patchTruss = {
  single: 'microq.drum',
  parms: parms,
  bodyDataCount: 384,
  namePack: [368, 383],
  initFile: "microq-drum-init",
  parseBody: 7,
}

struct MicroQDrumBank : SingleBankTemplate, RhythmBank {
  typealias Template = MicroQDrumPatch
  static let patchCount: Int = 20
  static let initFileName: String = "microq-drum-bank-init"
}

