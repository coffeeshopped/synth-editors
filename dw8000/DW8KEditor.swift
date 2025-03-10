
class DW8KEditor : SingleDocSynthEditor {
    
  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : ChannelSettingsPatch.self,
      [.patch] : DW8KVoicePatch.self,
      [.bank] : DW8KVoiceBank.self,
    ]

    let migrationMap: [SynthPath:String] = [
      [.global] : "Global.json",
      [.patch] : "Voice.syx",
      [.bank] : "Voice Bank.syx",
    ]

    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
  }

  // MARK: MIDI I/O
  
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
    
    midiOuts.append(voiceOut(input: patchStateManager([.patch])!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank])!.output) {
      guard let patch = $0 as? DW8KVoicePatch else { return nil }
      return patch.sysexData(channel: self.channel, location: $1)
    })
    
    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    return [[.bank]]
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    return ["Voice Bank"]
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    return {
      let bank = ($0 / 8) + 1
      let patch = ($0 % 8) + 1
      return "\(bank)\(patch)"
    }
  }
}

// MARK: Midi Out

extension DW8KEditor {
  
  func voiceOut(input: Observable<(PatchChange, DW8KVoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      return [Data([0xf0, 0x42, 0x30 + UInt8(self.channel), 0x03, 0x41, UInt8(param.byte), UInt8(value), 0xf7])]

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    })
    
  }
  
}

