const XVPerf = require('./xv_perf.js')

const fxCtrlChannelIso = ['switch', [
  [16, 'Off'],
], ['+', 1]]

const voiceReserveIso = ['switch', [
  [64, 'Full'],
]]

const commonParms = [
  ['solo', { b: 0x0c, iso: XVPerf.soloIso, max: 16 }],
  ['fx/ctrl/channel', { b: 0x0d, iso: fxCtrlChannelIso, max: 16 }],
  ['fx/ctrl/midi/0', { b: 0x0e, max: 1 }],
  ['fx/ctrl/midi/1', { b: 0x0f, max: 1 }],
  { prefix: "voice/reserve", count: 32, bx: 1, block: [
    ['', { b: 0x10, iso: voiceReserveIso, max: 64 }],
  ] }
  ['fx/0/src', { b: 0x30, iso: XVPerf.srcIso, max: 16 }],
  ['fx/1/src', { b: 0x31, iso: XVPerf.srcIso, max: 16 }],
  ['fx/2/src', { b: 0x32, iso: XVPerf.srcIso, max: 16 }],
  ['chorus/src', { b: 0x33, iso: XVPerf.srcIso, max: 16 }],
  ['reverb/src', { b: 0x34, iso: XVPerf.srcIso, max: 16 }],
]

const partParms = XV3080Perf.partParms.concat([
  ['out/assign', { b: 0x1f, opts: outAssignOptions }],
  ['decay', { b: 0x21, dispOff: -64 }],
  ['vib/rate', { b: 0x22, dispOff: -64 }],
  ['vib/depth', { b: 0x23, dispOff: -64 }],
  ['vib/delay', { b: 0x24, dispOff: -64 }],
  { prefix: "scale/tune", count: 12, bx: 1, block: [
    ['', { b: 0x25, dispOff: -64 }],
  ] },
])
  
static var outAssignOptions = XV5050.Voice.Tone.outAssignOptions
  <<< [13 : "Patch"]

const internalPartGroupOptions: [Int:String] = {
  let ids: [SynthPath] = [
    '',
    "int/user",
    "int/preset/0",
    "int/preset/1",
    "int/preset/2",
    "int/preset/3",
    "int/preset/4",
    "int/preset/5",
    "int/preset/6",
    "int/preset/7",
    "int/gm2",
  ]
  return ids.dict {
    [XV.Perf.Part.value(forSynthPath: $0) : XV.Perf.Part.internalGroupsMap[$0] ?? ""]
  }
}()

const config = XV3080Perf.Part.config
config.voicePartGroups = internalPartGroupOptions <<< XV.Perf.Part.srxPartGroupOptions
config.rhythmPartGroups = internalPartGroupOptions <<< XV.Perf.Part.srxPartGroupOptions

const commonPatchWerk = XVPerf.commonPatchWerk(commonParms)
const partPatchWerk = XVPerf.partPatchWerk(partParms, 0x31)


const patchWerk = XVPerf.patchWerk(16, {
  common: commonPatchWerk, 
  part: partPatchWerk, 
  fx: FX.patchWerk, 
  chorus: FX.chorusPatchWerk, 
  reverb: FX.reverbPatchWerk,
}, [
  ("fx/1", 0x0800, FX.patchWerk),
  ("fx/2", 0x0a00, FX.patchWerk),
], "xv5050-perf-init")

const bankWerk = XVPerf.bankWerk(patchWerk, "xv5050-perf-bank-init")

const fullRefTruss = XVPerf.fullRefTruss(16, perf: patchWerk, voice: Voice.patchWerk, rhythm: rhythmPatchWerk)

module.exports = {
}