const MophoGlobal = require('global.js')
const PO = require('/core/ParamOptions.js')

const channelIso = [
  ["int", 0, "Omni"],
  ["range", 1, 16, [Jiso.str()]],
]

const paramOptions = PO.reduce(function*() {
  yield PO.inc({b: 0}, function*() {
    yield [
      [["semitone"], {p: 384, max: 24, dispOff: -12}],
      [["detune"], {p: 385, max: 100, dispOff: -50}],
      [["channel"], {p: 386, max: 16, isoS: channelIso}],
      [["clock"], {p: 388, opts: ["Internal","MIDI Out", "MIDI In", "MIDI In/Out"]}],
      [["param", "send"], {p: 390, opts: ["NRPN","CC","Off"]}],
      [["param", "rcv"], {p: 391, opts: ["All","NRPN only","CC only", "Off"]}],
      [["ctrl"], {p: 394, max: 1}],
      [["sysex"], {p: 395, max: 1}],
      [["out"], {p: 405, opts: ["Stereo","Mono"]}],
      [["midi", "out"], {p: 406, opts: ["MIDI Out","MIDI Thru"]}],
    ]
  })
})


const MophoGlobalPatch = {
  trussType: "SinglePatch",
  localType: "Global",
  fileDataCount: 31, // manual says 25 bytes but it looks like newer firmware added some.
  initFileName: "mopho-global-init",

  bytes: function(fileData) {
    return MophoGlobal.bytes(fileData, [4, 30])
  },
  
  fileData: function(bytes) {
    return MophoGlobal.fileData(bytes, 0x25)
  },
  
  paramOptions: paramOptions,

  params: (function() {
    let p = {}
    for (let i=0; i<paramOptions.length; ++i) {
      let path = paramOptions[i][0].join('/')
      let obj = paramOptions[i][1]
      p[path] = obj
    }
    return p
  }()),
  
}

module.exports = MophoGlobalPatch
