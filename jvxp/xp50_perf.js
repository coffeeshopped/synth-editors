const JVXP = require('./jvxp.js')
const JV1080Perf = require('./jv1080_perf.js')

const commonParms = JV1080Perf.commonParms.concat([
  ['key/mode', { b: 0x40, opts: ["Layer","Single"] }],
  ['clock/src', { b: 0x41, opts: ["Perform","Seq"] }],
])

const commonPatchWerk = JVXP.perfCommonPatchWerk(commonParms, 0x42)

const partParms = JV1080Perf.partParms.concat([
  ['octave/shift', { b: 0x13, max: 6, dispOff: -3 }],
  ['local', { b: 0x014, max: 1 }],
  ['send', { b: 0x015, max: 1 }],
  ["send/bank/select/group", { b: 0x16, opts: (8).map(i =>
    i == 0 ? "Patch" : `Group ${i}`
  )}],
  ['send/volume', { b: 0x17, packIso: JVXP.multiPack(0x17), opts: (129).map(i =>
    i == 128 ? "Off" : `${i}`
  )}],
])

const partPatchWerk = JVXP.perfPartPatchWerk(partParms, 0x19)

const patchWerk = JVXP.perfPatchWerk(commonPatchWerk, partPatchWerk, "")

module.exports = {
  patchWerk,
  bankWerk: JVXP.perfBankWerk(patchWerk),
  commonParms,
  partParms,
}
