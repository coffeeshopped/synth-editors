

const editor = {
  rolandModelId: [0x14],
  addressCount: 3,
  name: "D-50",
  map: [
    ['channel'],
    ['patch', 0x000000, Voice.patchWerk],
    ['bank', 0x020000, Voice.bankWerk],
  ],
  midiChannels: [
    ['patch', 'basic'],
  ],
  slotTransforms: [
    ['bank', ['user', i => `${(i / 8) + 1}${(i % 8) + 1}`]],
  ]
}
class D50Editor : RolandNewAddressableEditor {
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    guard path == [.bank] else { return super.fetchCommands(forPath: path) }
    return [.request(Data())] // don't send a request, but DO wait for a response.
  }

  override func midiOuts() -> [Observable<[Data]?>] {
    midiOuts.append(midiDataObservable(forPath: [.patch])!)

    // only .replace/.push will send the bank, since you need to be in data transfer mode anyway.
    midiOuts.append(GenericMidiOut.pushOnlyBank(input: bankStateManager([.bank])!.output) {
      guard let bank = $0 as? D50VoiceBank else { return nil }
      return bank.sysexData(deviceId: self.deviceId, address: D50VoiceBank.startAddress())
    })
    
    return midiOuts
  }
  
}
