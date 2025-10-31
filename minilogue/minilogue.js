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
    ["patch", Voice.patchTransform],
    ["bank/patch", Voice.bankTransform],
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

}

