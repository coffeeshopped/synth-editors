const JVXP = require('./jvxp.js')

const tapSources = ["Off","Hold-1","Sustain","Soft","Hold-2"]
const systemControls = (96).map(i => `CC ${i}`).concat(["Bender","Aftertouch"])

const parms = [
  // Switching to GM mode makes the synth stop responding to sysex! omit that option
  { inc: 1, b: 0x00, block: [
    ["mode", { opts: ["Performance","Patch"] }],
    ["perf", { }],
    ["patch/group", { opts: ["User","PCM","Exp"] }],
    ["patch/group/id", { }],
    ["patch/number", { max: 254 }],
  ] },
  { inc: 1, b: 0x06, block: [
    ["tune", { max: 126 }],
    ["scale/tune", { max: 1 }],
    ["fx", { max: 1 }],
    ["chorus", { max: 1 }],
    ["reverb", { max: 1 }],
    ["patch/remain", { max: 1 }],
    ["clock", { opts: ["Internal","Ext MIDI"] }],
    ["tap", { opts: tapSources }],
    ["hold", { opts: tapSources }],
    ["peak", { opts: tapSources }],
    ["volume", { opts: ["Volume","Vol & Exp"] }],
    ["aftertouch", { opts: ["Channel After", "Poly After", "Ch & Poly"] }],
    ["ctrl/0", { opts: systemControls }],
    ["ctrl/1", { opts: systemControls }],
    ["rcv/pgmChange", { max: 1 }],
    ["rcv/bank/select", { max: 1 }],
    ["rcv/ctrl/change", { max: 1 }],
    ["rcv/mod", { max: 1 }],
    ["rcv/volume", { max: 1 }],
    ["rcv/hold", { max: 1 }],
    ["rcv/bend", { max: 1 }],
    ["rcv/aftertouch", { max: 1 }],
    ["ctrl/channel", { opts: (17).map(i => i == 16 ? "Off" : `${i + 1}` ) }],
    ["patch/channel", { max: 15, dispOff: 1 }],
    ["rhythm/edit", { opts: ["Panel","Panel & MIDI"] }],
    ["preview/mode", { opts: ["Single","Chord"] }],
    ["preview/key/0", { }],
    ["preview/velo/0", { }],
    ["preview/key/1", { }],
    ["preview/velo/1", { }],
    ["preview/key/2", { }],
    ["preview/velo/2", { }],
    ["preview/key/3", { }],
    ["preview/velo/3", { }],
  ] }
]

module.exports = {
  patchWerk: JVXP.globalPatchWerk(parms, 0x28, "jv1080-global-init"),
  parms,
}
