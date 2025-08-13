
const parms = [
  ["channel/0", { b: 0, max: 14, dispOff: 1 }],
  ["channel/1", { b: 1, max: 14, dispOff: 1 }],
]

const patchTruss = {
  json: 'circuit.global',
  parms: parms,
  initFile: "circuit-global-init",
}

module.exports = {
  patchTruss,
}