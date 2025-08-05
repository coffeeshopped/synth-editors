const XVFX = require('./xv_fx.js')
const XV5050FX = require('./xv5050_fx.js')

const fxTypeOptions = XV5050FX.fxTypeOptions

const outOptions = ["A","B","C","D"]

const parms = XV5050FX.parms.concat([
  ['out', { b: 0x04, opts: outOptions }],
])

const chorusParms = XV5050FX.chorusParms.concat([
  ['out/assign', { b: 0x02, opts: outOptions }],
])

const reverbParms = XV5050FX.reverbParms.concat([
  ['out/assign', { b: 0x02, opts: outOptions }],
])

module.exports = {
  patchWerk: XVFX.patchWerk(parms),
  chorusPatchWerk: XVFX.chorusPatchWerk(chorusParms),
  reverbPatchWerk: XVFX.reverbPatchWerk(reverbParms),
}


