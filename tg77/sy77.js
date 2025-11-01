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



class SY77Editor : TG77Editor {
  

  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .multi:
      if path.count == 1 {
        return [.request(fetchData(forHeader: "LM  8101MU", location: -1))]
      }
      else {
        let arrs: [[RxMidi.FetchCommand]] = (0..<16).map {
          [.request(fetchData(forHeader: "LM  8101MU", location: $0))]
        }
        return [RxMidi.FetchCommand](arrs.joined())
      }
    default:
      return super.fetchCommands(forPath: path)
    }
  }
  
}
