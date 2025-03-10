
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
  
  static let migrationMap: [SynthPath:String] = [:]
  
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
  
  private func voice(_ input: Observable<(PatchChange, JX8PVoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(10), input: input, paramTransform: { [weak self] (patch, path, value) -> [Data]? in
      guard let self = self,
        let param = type(of: patch).params[path] else { return nil }
      return [self.paramData(byte: param.byte, value: value)]

    }, patchTransform: { [weak self] (patch) -> [Data]? in
      guard let self = self else { return nil }
      return [patch.sysexData(channel: self.channel)]

    }) { [weak self] (patch, path, name) -> [Data]? in
      guard let self = self else { return nil }
      var data = Data([0xf0, 0x41, 0x36, UInt8(self.channel), 0x21, 0x20, 0x01])
      (0..<10).forEach {
        data.append(UInt8($0))
        data.append(UInt8(patch.bytes[$0]))
      }
      data.append(0xf7)
      return [data]
      
    }
  }
  
  private func paramData(byte: Int, value: Int) -> Data {
    let isPatch = byte > 58
    var data = Data([0xf0, 0x41, 0x36, UInt8(channel), 0x21, isPatch ? 0x30 : 0x20, 0x01])
    data.append(UInt8(byte % 59))
    data.append(UInt8(value))
    data.append(0xf7)
    return data
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is VoicePatch.Type:
      return [[.bank]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is VoicePatch.Type:
      return ["Tone Bank"]
    default:
      return []
    }
  }
  
}
