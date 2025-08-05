
const fxTypeOptions: [Int:String] = 41.dict {
  [$0 : XV.FX.fxDisplayName($0)]
}

const outOptions = ["A"]

const parms = XV3080FX.parms.concat([
  ['type', { b: 0x00, opts: fxTypeOptions }],
  ['out', { b: 0x04, opts: outOptions }],
])

const chorusParms = XV5050FX.chorusParms.concat([
  ['type', { b: 0x00, opts: ["Off", "Chorus"] }],
  ['out/assign', { b: 0x02, opts: outOptions }],
])

const reverbParms = XV5050FX.reverbParms.concat([
  ['type', { b: 0x00, opts: ["Off", "Reverb"] }],
  ['out/assign', { b: 0x02, opts: outOptions }],
])

module.exports = {
  patchWerk: XVFX.patchWerk(parms),
  chorusPatchWerk: XVFX.chorusPatchWerk(chorusParms),
  reverbPatchWerk: XVFX.reverbPatchWerk(reverbParms),
}

