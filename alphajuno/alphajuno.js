
// AJ1: 64 presets / 64 memory
// AJ2: 64 presets / 64 memory / 64 cartridge
// MKS-50: 128 tones / 128 patches (tone + perf ctrl) all writeable

const Shared = require('./shared.js')
const Voice = require('./alphajuno_voice.js')

const editor = {
  name: "Alpha Juno",
  trussMap: [
    ["global", "channel"],
    ['tone', Voice.patchTruss],
    ['bank/tone', Voice.bankTruss],
  ],
  fetchTransforms: [
    ["tone", ['manual', '>=', 54]],
    ["bank/tone", ['manual', '>=', 4256]],
  ],

  midiOuts: [
    ["tone", Voice.patchTransform],
    ["bank/tone", 'manual'], // a push-only transform that uses the createFile fn
  ],
  
  midiChannels: [
    ["tone", "basic"],
  ],
  slotTransforms: [
    ["bank/tone", Shared.toneSlotTransform],
  ],

}
