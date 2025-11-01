

const fetchCmd = ['truss', [0xf0, 0x42, ['+', 0x30, 'channel'], 0x03, 0x10, 0xf7]]

const editor = {
  name: "",
  trussMap: [
    ["global", "channel"],
    ['voice', Voice.patchTruss],
    ['bank/voice', Voice.bankTruss],
  ],
  fetchTransforms: [
    ['voice', fetchCmd],
    ['bank/voice', ['sequence', 64.flatMap(loc => [
      ['send', ['pgmChange', loc, 'channel']],
      ['wait', 30],
      fetchCmd,
      ['wait', 30],
    ])]],
  ],
  midiOuts: [
    ["voice", Voice.patchTransform],
    ["bank/voice", Voice.bankTransform],
  ],
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
    ['bank/voice', ['user', i => {
      const bank = (i / 8) + 1
      const patch = (i % 8) + 1
      return `${bank}${patch}`
    }]]
  ],
}
