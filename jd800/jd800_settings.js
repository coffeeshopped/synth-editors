
  //   if (values[0] ?? 0) < 16 {
  // // default deviceId to 16 (displayed as 17)
  // values[0] = 16
// }

const parms = [
  ["deviceId", { b: 0, rng: 0x[10, 0]x1f, dispOff: 1 }],
  ["pcm", { b: 1, opts: SOJD80Card.cardNameOptions }],
  ["channel", { b: 2, max: 15, dispOff: 1 }],
]

const patchTruss = {
  json: 'settings',
  parms: parms,
  initFile: "jd800-settings-init"
}