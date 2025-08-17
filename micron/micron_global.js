
const parms = [
  ["channel", { b: 0, max: 15, dispOff: 1 }],
  ["bank", { b: 1, max: 7 }],
  ["location", { b: 2 }],
  // where we fetch from
  ["dump/bank", { b: 3, max: 7 }],
  ["dump/location", { b: 4 }],
]

const patchTruss = {
  json: 'global',
  parms: parms,
  initFile: "micron-global-init",
}