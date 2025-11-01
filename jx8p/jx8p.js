
const editor = {
  name: "JX8P",
  trussMap: [
    ["global", "channel"],
    ['tone', Voice.patchTruss],
    ['bank', Voice.bankTruss],
  ],
  fetchTransforms: [
    ['tone', ['manual', '>=', 67]],
    ['bank', ['manual', '>=', 2464]],
  ],

  midiOuts: [
    ['tone', Voice.patchTransform],
    ['bank', Voice.bankTransform],
  ],
  
  midiChannels: [
    ["tone", "basic"],
  ],
  slotTransforms: [
  ],
}
