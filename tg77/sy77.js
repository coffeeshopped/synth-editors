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
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
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

  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(system(input: patchStateManager("global")!.typedChangesOutput()))
    midiOuts.append(voice(input: patchStateManager("patch")!.typedChangesOutput()))
    midiOuts.append(multiCommon(input: patchStateManager("multi")!.typedChangesOutput()))
    midiOuts.append(pan(input: patchStateManager("pan")!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("bank")!.output) {
      guard let patch = $0 as? TG77VoicePatch else { return nil }
      return [patch.sysexData(channel: self.deviceId, location: $1)]
    })

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("multi/bank")!.output) {
      guard let patch = $0 as? TG77MultiCommonPatch else { return nil }
      return [patch.sysexData(channel: self.deviceId, location: $1)]
    })

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("pan/bank")!.output) {
      guard let patch = $0 as? TG77PanPatch else { return nil }
      return [patch.sysexData(channel: self.deviceId, location: $1)]
    })

    return midiOuts
  }

  
}
