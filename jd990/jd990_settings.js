
  //   if (values[0] ?? 0) < 16 {
  // // default deviceId to 16 (displayed as 17)
  // values[0] = 16
// }

const parms = [
  ["deviceId", { b: 0, rng: 0x[10, 0]x1f, dispOff: 1 }],
  ["pcm", { b: 1, opts: SOJD80Card.cardNameOptions }],
  ["extra", { b: 2, opts: SRJVBoard.boardNameOptions }],
]

const patchWerk = {
  json: 'settings',
  initFile: "jd990-settings-init",
  parms: parms,
}
