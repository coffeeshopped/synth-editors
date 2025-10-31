
class JX8PEditor : SingleDocSynthEditor {

  private static let _sysexMap: [SynthPath:Sysexible.Type] = {
    var map: [SynthPath:Sysexible.Type] = [
      [.global]   : ChannelSettingsPatch.self,
      [.tone]     : JX8PVoicePatch.self,
      [.bank]     : JX8PVoiceBank.self,
    ]
    return map
  }()
  class var sysexMap: [SynthPath:Sysexible.Type] { _sysexMap }
  
  required init(baseURL: URL) {
    super.init(baseURL: baseURL, sysexMap: Self.sysexMap, migrationMap: Self.migrationMap)
  }

  var channel: Int { patch(forPath: [.global])?[[.channel]] ?? 0 }

  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case [.tone]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(67))]
    case [.bank]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(2464))]
    default:
      return nil
    }
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int { channel }
  
  // TODO: MIDI Out

  override func midiOuts() -> [Observable<[Data]?>]  {
    var midiOuts = [Observable<[Data]?>]()

    let voiceManager: PatchStateManager = patchStateManager([.tone])!
    midiOuts.append(voice(voiceManager.typedChangesOutput()))

    let voiceBankManager: BankStateManager = bankStateManager([.bank])!
    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: voiceBankManager.output, patchTransform: { [weak self] (patch, location) -> [Data]? in
      guard let self = self else { return nil }
      return (patch as? JX8PVoicePatch)?.writeData(channel: self.channel, location: location)
    }))

    return midiOuts
  }
  
}
