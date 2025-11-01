
const fetchBytes = (bytes) => [0xf0, 0x42, ['+', 0x30 'channel'], 0x00, 0x01, 0x2c, bytes, 0xf7]

const editor = {
  name: "",
  trussMap: [
    ["global", "channel"],
    ['patch', Voice.patchTruss],
    ['bank/patch', Voice.bankTruss],
  ],
  fetchTransforms: [
    ['patch', ['truss', fetchBytes([0x10])]],
    ['bank/patch', ['bankTruss', fetchBytes([0x1c, ['bits', [0, 6]], ['bit', 7]])]],
  ],
  midiOuts: [
    ["patch", Voice.patchTransform],
    ["bank/patch", Voice.bankTransform],
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: [
  ],
}

