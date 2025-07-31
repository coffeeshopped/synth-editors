
const reverbTypeOptions = ["Room 1", "Room 2", "Hall 1", "Hall 2", "Plate", "Tap Delay 1","Tap Delay 2", "Tap Delay 3"]

const channelOptions = (17).map(i => i == 16 ? "Off" : `${i+1}`)

const tuneIso = ['>', ['switch', [
  [[0, 7], ['lerp', [0, 7], [427.4, 428.8]]],
  [[8, 34], ['lerp', [8, 34], [429, 434]]],
  [[35, 127], ['lerp', [35, 127], [434.2, 452.6]]],
]], ['round', 1]]

const parms = [
  ["tune", { b: 0x00, iso: tuneIso }], 
  //, .iso(Miso.lerp(in: 0...127, out: 427.4...452.6))),
  ['reverb/type', { b: 0x01, opts: reverbTypeOptions }],
  ['reverb/time', { b: 0x02, max: 7, dispOff: 1 }],
  ['reverb/level', { b: 0x03, max: 7 }],
  { prefix: "part", count: 8, bx: 1, block: [
    ['reserve', { b: 0x04, max: 32 }],
    ['channel', { b: 0x0d, opts: channelOptions }],
  ] },
  ['part/rhythm/reserve', { b: 0x0c, max: 32 }],
  ['part/rhythm/channel', { b: 0x15, opts: channelOptions }],
]

const patchWerk = {
  single: "System", 
  parms: [parms[0]],
  size: 0x1,
}

module.exports = {
  parms,
  patchWerk,
  reverbTypeOptions,
}