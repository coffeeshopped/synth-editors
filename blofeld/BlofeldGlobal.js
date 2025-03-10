const Blofeld = require('./Blofeld.js')

const dumpByte = 0x14

const channelIso = ['switch', [
  [0, "Omni"],
]]

const parms = [
  ["perf", 1, {max: 1}],
  ["autoEdit", 35, {max: 1}],
  ["channel", 36, {max: 16, iso: channelIso}],
  ["deviceId", 37, {rng: [0, 127]}],
  ["popup/time", 38],
  ["contrast", 39],
  ["tune", 40, {rng: [54,75], dispOff: 376}],
  ["transpose", 41, {rng: [52, 77], dispOff: -64}],
  ["ctrl/send", 44, {opts: ["off","Ctrl","SysEx","Ctrl+SysEx"]}],
  ["ctrl/rcv", 45, {rng: [0, 2]}],
  ["clock", 48, {opts: ["Auto","Internal"]}],
  ["velo/curve", 50, {opts: ["linear","square","cubic","exponential","root","fix32","fix64","fix100","fix127"]}],
  ["ctrl/0", 51, {max: 120}],
  ["ctrl/1", 52, {max: 120}],
  ["ctrl/2", 53, {max: 120}],
  ["ctrl/3", 54, {max: 120}],
  ["volume", 55],
  ["category", 56, {max: 13}],
]

module.exports = {
  dumpByte,
  patchTruss: Blofeld.createPatchTruss("Global", 73, "blofeld-global-init", parms, 5, dumpByte, false),
}