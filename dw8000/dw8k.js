const editor = {
  name: "",
  trussMap: [
    ["global", "channel"],
    ['voice', Voice.patchTruss],
    ['bank/voice', Voice.bankTruss],
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



class DW8KEditor : SingleDocSynthEditor {
    
  private func patchFetchCommand() -> RxMidi.FetchCommand {
    return .request(Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x03, 0x10, 0xf7]))
  }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path.first! {
    case .patch:
      return [patchFetchCommand()]
    case .bank:
      return Array((0..<64).map { (location) -> [RxMidi.FetchCommand] in
        [
          .send(Data(Midi.pgmChange(location, channel: channel))),
          .wait(0.03),
          patchFetchCommand(),
          .wait(0.03),
        ] }.joined())
    default:
      return nil
    }
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(voiceOut(input: patchStateManager("patch")!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("bank")!.output) {
      guard let patch = $0 as? DW8KVoicePatch else { return nil }
      return patch.sysexData(channel: self.channel, location: $1)
    })
    
    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    return {
      let bank = ($0 / 8) + 1
      let patch = ($0 % 8) + 1
      return "\(bank)\(patch)"
    }
  }
}
