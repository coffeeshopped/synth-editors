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
  
}
