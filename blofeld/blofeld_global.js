const Blofeld = require('./blofeld.js')

const dumpByte = 0x14

const channelIso = ['switch', [
  [0, "Omni"],
]]

const parms = [
  ["perf", {b: 1, max: 1}],
  ["autoEdit", {b: 35, max: 1}],
  ["channel", {b: 36, max: 16, iso: channelIso}],
  ["deviceId", {b: 37, rng: [0, 127]}],
  ["popup/time", {b: 38}],
  ["contrast", {b: 39}],
  ["tune", {b: 40, rng: [54,75], dispOff: 376}],
  ["transpose", {b: 41, rng: [52, 77], dispOff: -64}],
  ["ctrl/send", {b: 44, opts: ["off","Ctrl","SysEx","Ctrl+SysEx"]}],
  ["ctrl/rcv", {b: 45, rng: [0, 2]}],
  ["clock",{b:  48, opts: ["Auto","Internal"]}],
  ["velo/curve", {b: 50, opts: ["linear","square","cubic","exponential","root","fix32","fix64","fix100","fix127"]}],
  ["ctrl/0", {b: 51, max: 120}],
  ["ctrl/1", {b: 52, max: 120}],
  ["ctrl/2", {b: 53, max: 120}],
  ["ctrl/3", {b: 54, max: 120}],
  ["volume", {b: 55}],
  ["category", {b: 56, max: 13}],
]

module.exports = {
  dumpByte,
  patchTruss: Blofeld.createPatchTruss("Global", 73, "blofeld-global-init", null, parms, 5, dumpByte, false),
}