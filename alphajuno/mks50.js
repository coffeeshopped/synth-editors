
// MKS-50: 128 tones / 128 patches (tone + perf ctrl) all writeable

const editor = {
  name: "MKS-50",
  trussMap: [
    ["global", "channel"],
    ['tone', Voice.patchTruss],
    ['bank/tone/0', Voice.bankTruss],
    ['bank/tone/1', Voice.bankTruss],
    ['patch', Patch.patchTruss],
    ['bank/patch/0', Patch.bankTruss],
    ['bank/patch/1', Patch.bankTruss],
    ['chord', Chord.patchTruss],
    ['bank/chord', Chord.bankTruss],
  ],
  fetchTransforms: [
    ["tone", ['manual', '>=', 54]],
    ["bank/tone/0", ['manual', '>=', 4256]],
    ['bank/tone/1', ['manual', '>=', 4256]],
    ['patch', ['manual', '>=', 31]],
    ['bank/patch/0', ['manual', '>=', 4256]],
    ['bank/patch/1', ['manual', '>=', 4256]],
    ['chord', ['manual', '>=', 14]],
    ['bank/chord', ['manual', '>=', 202]],
  ],
  
  midiOuts: [
    ["tone", Voice.patchTransform],
    ["bank/tone/0", 'manual'],
    ['bank/tone/1', 'manual'],
    ['patch', Patch.patchTransform],
    ['bank/patch/0', 'manual'],
    ['bank/patch/1', 'manual'],
    ['chord', {
      singlePatch: 'createFile',
      throttle: 30,
    }],
    ['bank/chord', 'manual'],
  ],

  slotTransforms: [
    ["bank/tone/0", Shared.toneSlotTransform],
    ["bank/tone/1", Shared.toneSlotTransform],
    ["bank/chord", ['user', loc => `${loc + 1}`]],
  ],
  extraParamOuts: [
    ['patch', ['bankNames', 'bank/tone/0', 'tone/name/0', (i, name) => `a${1 + i / 8}${1 + i % 8}: ${name}`]],
    ['patch', ['bankNames', 'bank/tone/1', 'tone/name/1', (i, name) => `b${1 + i / 8}${1 + i % 8}: ${name}`]],
  ],
}
