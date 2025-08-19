
const deviceIdIso = Miso.switcher([
  .int(16, "Omni")
], default: Miso.a(1) >>> Miso.str())

const parms = [
  ["channel", { b: 0, max: 15, dispOff: 1 }],
  ["deviceId", { b: 1, rng: [0, 16], iso: deviceIdIso }],
]

const patchTruss = {
  json: 'global',
  parms: parms,
  initFile: "virusti-snow-global-init",
}