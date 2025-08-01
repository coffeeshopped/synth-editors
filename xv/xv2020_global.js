const XV5050Global = require('./xv5050_global.js')

const patchWerk = {
  multi: 'Global',
  map: [
    ["common", 0x0000, XV5050Global.commonPatchWerk),
  ],
  initFile: "xv2020-global-init",
}

module.exports = {
  patchWerk,
}
