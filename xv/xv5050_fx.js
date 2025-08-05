

const fxTypeOptions: [Int:String] = XV.FX.allFx.enumerated().dict {
  [$0.offset : XV.FX.fxDisplayName($0.offset)]
}

const aTypeOptions = fxTypeOptions.dict {
  [$0.key : $0.value + (isBCFX(index: $0.key) ? " ♢" : "")]
}

const bcTypeOptions = fxTypeOptions.filter { isBCFX(index: $0.key) }

function isBCFX(index) {
  return (0...23).contains(index) || (26...41).contains(index) || (44...45).contains(index) || (52...58).contains(index) || (62...63).contains(index)
}

const ctrlSrcOptions: [Int:String] = {
  var opts = [
    0 : "Off",
    96 : "Bend",
    97 : "Aftertouch",
    98 : "System 1",
    99 : "System 2",
    100 : "System 3",
    101 : "System 4",
    ]
  (1...31).forEach { opts[$0] = "CC \($0)" }
  (33...95).forEach { opts[$0] = "CC \($0)" }
  return opts
}()

const ctrlAssigns = 17.map { $0 == 0 ? "Off" : "\($0)" }

const parms = [
  ['type', { b: 0x00, opts: fxTypeOptions }],
  ['dry', { b: 0x01 }],
  ['chorus', { b: 0x02 }],
  ['reverb', { b: 0x03 }],
  ['out', { b: 0x04, opts: ["A","B"] }],
  { prefix: "ctrl", count: 4, bx: 2, block: [
    ['src', { b: 0x05, opts: ctrlSrcOptions }],
    ['amt', { b: 0x06, rng: [1, 127], dispOff: -64 }],
  ] },
  { prefix: "ctrl", count: 4, bx: 1, block: [
    ['assign', { b: 0x0d, opts: ctrlAssigns }],
  ] },
  { prefix: "param", count: 32, bx: 4, block: (index, offset) => [
    ['', { b: 0x11, packIso: XV.multiPack4(0x11 + offset), rng: [12768, 52768], dispOff: -32768 }],
  ] },
]

const chorusParms = [
  ['type', { b: 0x00, opts: ["Off", "Chorus", "Delay", "GM2 Chorus"] }],
  ['level', { b: 0x01 }],
  ['out/assign', { b: 0x02, opts: ["A","B"] }],
  ['out/select', { b: 0x03, opts: ["Main", "Reverb", "Main+Rev"] }],
  { prefix: "ctrl", count: 4, bx: 1, block: [
    ['assign', { b: 0x0d, opts: ctrlAssigns }],
  ] },
]

const reverbParms = [
  ['type', { b: 0x00, opts: ["Off", "Reverb", "SRV Room", "SRV Hall", "SRV Plate", "GM2 Reverb"] }],
  ['level', { b: 0x01 }],
  ['out/assign', { b: 0x02, opts: ["A","B"] }],
  { prefix: "param", count: 20, bx: 4, block: (index, offset) => [
    ['', { b: 0x03, packIso: XV.multiPack4(0x03 + offset), rng: [12768, 52768], dispOff: -32768 }],
  ] },
]

module.exports = {
  patchWerk: XVFX.patchWerk(parms),
  chorusPatchWerk: XVFX.chorusPatchWerk(chorusParms),
  reverbPatchWerk: XVFX.reverbPatchWerk(reverbParms),
}


