const Voice = require('./ms2k_voice.js')


const fetchCommand = (byte) =>
  ['truss', [0xf0, 0x42, ['+', 0x30, 'channel'], 0x58, byte, 0xf7]]

// sysex for entering edit mode
const editModeSysex = [0xf0, 0x42, ['+', 0x30, 'channel'], 0x58, 0x4e, 0x01, 0x00, 0xf7]

const editor = {
  name: "",
  trussMap: [
    ["global", "channel"],
    ['patch', Voice.patchTruss],
    ['bank', Voice.bankTruss],
  ],
  fetchTransforms: [
    ['patch', ['sequence', [
      fetchCommand(0x10),
      ['send', editModeSysex],
    ]]],
    ['bank', fetchCommand(0x1c)],
  ],

  midiOuts: [
    ['patch', Voice.patchTransform],
    ['bank', Voice.bankTransform],
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: [
  ],
}
