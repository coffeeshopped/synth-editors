const editor = {
  name: "",
  trussMap: [
    ["global", "channel"],
    ['tone', Voice.patchTruss],
    ['bank', Voice.bankTruss],
  ],
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["tone", "basic"],
  ],
  slotTransforms: [
  ],
}



class JX8PEditor : SingleDocSynthEditor {
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case "tone":
      return `requestMsg(.sysex([0xf0/${0xf7}`), .gtEq(67))]
    case "bank":
      return `requestMsg(.sysex([0xf0/${0xf7}`), .gtEq(2464))]
    default:
      return nil
    }
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int { channel }
  
  // TODO: MIDI Out

  override func midiOuts() -> [Observable<[Data]?>]  {
    var midiOuts = [Observable<[Data]?>]()

    let voiceManager: PatchStateManager = patchStateManager("tone")!
    midiOuts.append(voice(voiceManager.typedChangesOutput()))

    let voiceBankManager: BankStateManager = bankStateManager("bank")!
    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: voiceBankManager.output, patchTransform: { [weak self] (patch, location) -> [Data]? in
      guard let self = self else { return nil }
      return (patch as? JX8PVoicePatch)?.writeData(channel: self.channel, location: location)
    }))

    return midiOuts
  }
  
}
