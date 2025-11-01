const editor = {
  name: "",
  trussMap: [
    ["global", System.patchTruss],
    ["patch", Voice.patchTruss],
    ["bank", Voice.bankTruss],
    ["multi", Multi.commonPatchTruss], // SY77 doesn't have "extra" multi info
    ["multi/bank", Multi.commonBankTruss], // SY77 doesn't have "extra" multi info
    ["pan", Pan.patchTruss],
    ["pan/bank", Pan.bankTruss],
  ],
  fetchTransforms: [
    ["global", fetchLocation("8101SY", 0)],
    ["patch", fetchTemp("8101VC")],
    ["bank", fetchBank("8101VC")],
    // just sending the request for the "common" patch triggers dump of common + extra on TG77
    ["multi", fetchTemp("8101MU")],
    ["multi/bank", fetchBank("8101MU")],
    ["pan", fetchLocation("8101PN", tempPan)],
    ["pan/bank", ['bankTruss', fetchBank("8101PN")],
  ],

  midiOuts: [
    ["global", System.patchTransform],
    ["patch", Voice.patchTransform],
    ["bank", Voice.bankTransform],
    ["multi", Multi.commonPatchTransform],
    ["multi/bank", Multi.commonBankTransform],
    ["pan", Pan.patchTransform],
    ["pan/bank", Pan.bankTransform],
  ],  

  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
    ['bank', ['user', i => {
      const banks = ["A","B","C","D"]
      return `${banks[i / 16]}${(i % 16) + 1}`
    }]],
    ['multi/bank', 'userZeroToOne'],
    ['multi/pan', 'userZeroToOne'],
  ],
}
