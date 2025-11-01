

const fetchCmd = (bytes) => ['truss', [0xf0, 0x42, ['+', 0x30, 'channel'], 0x00, 0x01, 0x2f, bytes, 0xf7]]

const editor = {
  name: "Volca FM2",
  trussMap: [
    ["global", Global.patchTruss],
    ["patch", Voice.patchTruss],
    ["perf", Sequence.patchTruss],
    ["bank", Voice.bankTruss],
    ["perf/bank", Sequence.bankTruss],
    ["backup", backupTruss],
    ["extra/perf", Sequence.refTruss],
  ],
  fetchTransforms: [
    ["patch", fetchCmd([0x12])],
    ["perf", fetchCmd([0x10])],
    ["bank", ['bankTruss', fetchCmd([0x1e, 'b'])]],
    ["perf/bank", ['bankTruss', fetchCmd([0x1c, 'b'])]],
  ],
  midiOuts: [
    ["patch", Voice.patchTransform],
    ["perf", Sequence.patchTransform],
    ["bank", Voice.patchWerk.bankTransform],
    ["perf/bank", Sequence.patchWerk.bankTransform],
  ],
  
  midiChannels: [
    ["patch", "basic"],
    ["perf", "basic"],
  ],
  slotTransforms: [
    ["bank", ['user', i => `Int-${i}`]],
  ],
  extraParamOuts: [
    ["perf", ['bankNames', "bank", "patch/name"]],
  ],
}

