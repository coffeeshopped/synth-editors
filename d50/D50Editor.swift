
class D50Editor : RolandNewAddressableEditor {
  
  override var deviceId: Int {
    return patch(forPath: [.global])?[[.channel]] ?? 0
  }

  static let sysexMap: [SynthPath:Sysexible.Type] = [
    [.global] : ChannelSettingsPatch.self,
    [.patch] : D50VoicePatch.self,
    [.bank] : D50VoiceBank.self,
  ]

  static let migrationMap: [SynthPath:String] = [
    [.global] : "Global.syx",
    [.patch] : "Patch.syx",
    [.bank] : "Patch Bank.syx",
  ]
    
  required init(baseURL: URL) {
    super.init(baseURL: baseURL, sysexMap: type(of: self).sysexMap, migrationMap: type(of: self).migrationMap)
  }

  // MARK: MIDI I/O
  
  override var requestHeader: Data {
    return Data([0xf0, 0x41, UInt8(deviceId), 0x14, 0x11])
  }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    guard path == [.bank] else { return super.fetchCommands(forPath: path) }
    return [.request(Data())] // don't send a request, but DO wait for a response.
  }

  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(midiDataObservable(forPath: [.patch])!)

    // only .replace/.push will send the bank, since you need to be in data transfer mode anyway.
    midiOuts.append(GenericMidiOut.pushOnlyBank(input: bankStateManager([.bank])!.output) {
      guard let bank = $0 as? D50VoiceBank else { return nil }
      return bank.sysexData(deviceId: self.deviceId, address: D50VoiceBank.startAddress())
    })
    
    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return deviceId
  }

  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    return [[.bank]]
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    return ["Patch Bank"]
  }

  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    return {
      let bank = ($0 / 8) + 1
      let patch = ($0 % 8) + 1
      return "\(bank)\(patch)"
    }
  }

}
