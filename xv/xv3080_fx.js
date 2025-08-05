
const fxTypeOptions: [Int:String] = 64.dict {
  [$0 : XV.FX.fxDisplayName($0)]
}

const outOptions = ["A","B","C"]

const parms = XV5050FX.parms.concat([
  ['type', { b: 0x00, opts: fxTypeOptions }],
  ['out', { b: 0x04, opts: outOptions }],
])

const chorusParms = XV5050FX.chorusParms.concat([
  ['type', { b: 0x00, opts: ["Off", "Chorus", "Delay"] }],
  ['out/assign', { b: 0x02, opts: FX.outOptions }],
])

const reverbParms = XV5050FX.reverbParms.concat([
  ['type', { b: 0x00, opts: ["Off", "Reverb", "Bright Room", "Bright Hall", "Bright Plate"] }],
  ['out/assign', { b: 0x02, opts: FX.outOptions }],
])

module.exports = {
  patchWerk: XVFX.patchWerk(parms),
  chorusPatchWerk: XVFX.chorusPatchWerk(chorusParms),
  reverbPatchWerk: XVFX.reverbPatchWerk(reverbParms),
}

