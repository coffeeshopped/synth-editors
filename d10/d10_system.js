const D110System = require('./d110_system.js')

const parms = D110System.parms.concat([
  { prefix: "part", count: 8, bx: 1, block: [
    ['level', { b: 0x21, max: 100 }],
    ['pan', { b: 0x2a, max: 14, dispOff: -7 }],
  ] },
  ['part/rhythm/level', { b: 0x29, max: 100 }],
])

const patchWerk = {
  single: "System",
  parms: parms,
  size: 0x32,
  initFile: "d10-system-init",
}

module.exports = {
  patchWerk,
}