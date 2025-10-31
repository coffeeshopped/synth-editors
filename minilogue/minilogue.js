const editor = {
  name: "",
  trussMap: [
    ["global", "channel"],
    ['patch', Voice.patchTruss],
    ['bank/patch', Voice.bankTruss],
  ],
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: [
  ],
}



class MinilogueEditor : SingleDocSynthEditor {
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .patch:
      return `request(Data([0xf0/${0x42}/${0x30 + UInt8(channel)}/${0x00}/${0x01}/${0x2c}/${0x10}/${0xf7}`))]
    case .bank:
      return (0..<200).map {
        let addressLower = UInt8($0 & 0x7f)
        let addressUpper = UInt8(($0 >> 7) & 0x1)
        return .request(Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x00, 0x01, 0x2c, 0x1c,
              addressLower, addressUpper, 0xf7]))
      }
    default:
      return nil
    }
  }

  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(voice(input: patchStateManager("patch")!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("bank")!.output, patchTransform: {
      guard let patch = $0 as? MiniloguePatch else { return nil }
      return [patch.sysexData(channel: self.channel, location: $1)]
    }))
    
    return midiOuts
  }
  
}

