
const tuneIso = Miso.a(-1024) >>> Miso.m(0.001 * (1/12)) >>> Miso.pow(base: 2) >>> Miso.m(440) >>> Miso.round(1)

const commonParms = [
  ['tune', { b: 0x00, packIso: JDXi.multiPack(0x00), .iso(tuneIso, 24...2024) }],
  ['key/shift', { b: 0x04, rng: [40, 88], dispOff: -64 }],
  ['level', { b: 0x05 }],
  ['pgmChange/channel', { b: 0x11, opts: 17.map { $0 == 16 ? "Off" : "\($0+1))" } }],
  ['rcv/pgmChange', { b: 0x29, max: 1 }],
  ['rcv/bank/select', { b: 0x2a, max: 1 }],
]

const commonWerk = {
  single: "Global Common", 
  parms: commonParms, 
  size: 0x2b,
}

const ctrlrParms = [
  ["send/pgmChange", { b: 0x00, max: 1 }],
  ["send/bank/select", { b: 0x01, max: 1 }],
  ["velo", { b: 0x02, opts: (128).map(i => i == 0 ? "Real" : `${i}`) }],
  ["velo/curve", { b: 0x03, opts: Array.sparse([
    [1, "Light"],
    [2, "Medium"],
    [3, "Heavy"],
  ]) }],
  ["velo/curve/offset", { b: 0x04, rng: [54, 73], dispOff: -64 }],
]

// Fetch for the ControllerPatch doesn't work as of the latest firmware (1.52)
// It just returns nothing.

const ctrlrWerk = {
  single: "Global Controller", 
  parms: parms, 
  size: 0x11,
}

const patchWerk = {
  multi: "Global", 
  map: [
    ["common", 0x0000, commonWerk],
//    ("ctrl", 0x0300, CtrlrPatch.self),
  ],
}
