
const polarities = ["Standard", "Reverse"]

const pedalModes = ["Off","Int","MIDI","Int+MIDI"]

const pedalAssigns = (96).map { "CC\($0)" } + ["Aftertouch", "Bend Up", "Bend Down", "Pgm Up", "Pgm Down"]

const sendChannelOptions = (16).map(i => `${i + 1}`).concat(["Rx Ch", "Off"])

const parms = [
  // Switching to GM mode makes the synth stop responding to sysex!
  ['mode', { b: 0x00, opts: ["Performance","Patch"]), //,"GM"] }]
  ['tune', { b: 0x01, rng: [1, 128], dispOff: -64 }],
  ['key/transpose', { b: 0x02, rng: [28, 101], dispOff: -64 }],
  ['transpose', { b: 0x03, max: 1 }],
  ['reverb', { b: 0x04, max: 1 }],
  ['chorus', { b: 0x05, max: 1 }],
  ['hold/polarity', { b: 0x06, opts: polarities }],
  ['pedal/0/polarity', { b: 0x07, opts: polarities }],
  ['pedal/0/mode', { b: 0x08, opts: pedalModes }],
  ['pedal/0/assign', { b: 0x09, opts: pedalAssigns }],
  ['pedal/1/polarity', { b: 0x0a, opts: polarities }],
  ['pedal/1/mode', { b: 0x0b, opts: pedalModes }],
  ['pedal/1/assign', { b: 0x0c, opts: pedalAssigns }],
  ['ctrl/mode', { b: 0x0d, opts: pedalModes }],
  ['ctrl/assign', { b: 0x0e, opts: pedalAssigns }],
  ['aftertouch/threshold', { b: 0x0f }],

  ['rcv/volume', { b: 0x10, max: 1 }],
  ['rcv/ctrl/change', { b: 0x11, max: 1 }],
  ['rcv/aftertouch', { b: 0x12, max: 1 }],
  ['rcv/mod', { b: 0x13, max: 1 }],
  ['rcv/bend', { b: 0x14, max: 1 }],
  ['rcv/pgmChange', { b: 0x15, max: 1 }],
  ['rcv/bank/select', { b: 0x16, max: 1 }],

  ['send/volume', { b: 0x17, max: 1 }],
  ['send/ctrl/change', { b: 0x18, max: 1 }],
  ['send/aftertouch', { b: 0x19, max: 1 }],
  ['send/mod', { b: 0x1a, max: 1 }],
  ['send/bend', { b: 0x1b, max: 1 }],
  ['send/pgmChange', { b: 0x1c, max: 1 }],
  ['send/bank/select', { b: 0x1d, max: 1 }],

  ['patch/channel', { b: 0x1e, max: 15, dispOff: 1 }],
  ['patch/send/channel', { b: 0x1f, opts: sendChannelOptions }],
  ['ctrl/channel', { b: 0x20, opts: 17.map { $0 == 16 ? "Off" : "\($0+1)" } }],
]

const patchWerk = {
  single: "Global",
  parms: parms, 
  size: 0x21, 
  initFile: "jv880-global",
}