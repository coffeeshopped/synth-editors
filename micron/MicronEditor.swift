
class MicronEditor : SingleDocSynthEditor {
  
  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }
  var tempBank: UInt8 { return UInt8(patch(forPath: [.global])?[[.bank]] ?? 7) }
  var tempLocation: UInt8 { return UInt8(patch(forPath: [.global])?[[.location]] ?? 127) }
    
  // these should be read where needed, but only set by subscription to globalDoc
  private let fetchBankPath: SynthPath = [.dump, .bank]
  private let fetchLocationPath: SynthPath = [.dump, .location]
  var fetchBank: UInt8 { return UInt8(patch(forPath: [.global])?[fetchBankPath] ?? 7) }
  var fetchLocation: UInt8 { return UInt8(patch(forPath: [.global])?[fetchLocationPath] ?? 127) }

  private var globalSubscription: Disposable?
  
  required init(baseURL: URL) {
    var map: [SynthPath:Sysexible.Type] = [
      [.global] : MicronGlobalPatch.self,
      [.patch] : MicronVoicePatch.self,
      [.memory, .patch] : MiniakVoiceIndexPatch.self,
    ]
    (0..<8).forEach { map[[.bank, .patch, .i($0)]] = MicronVoiceBank.self }

    addMidiInHandler(throttle: .milliseconds(0)) { [weak self] (msg) in
      self?.handleMidiIn(msg)
    }
  }
    
  // MARK: MIDI I/O
    
  private func handleMidiIn(_ msg: MidiMessage) {
    switch msg {
    case .cc(let channel, let number, let value):
      guard channel == self.channel,
        number == 0x20 else { return }
      changePatch(forPath: [.global], .paramsChange([fetchBankPath : Int(value)]), transmit: false)
    case .pgmChange(let channel, let value):
      guard channel == self.channel else { return }
      changePatch(forPath: [.global], .paramsChange([fetchLocationPath : Int(value)]), transmit: false)
    default:
      break
    }
  }
  
  private func fetchCommand(_ bytes: [UInt8]) -> RxMidi.FetchCommand {
    return .request(Data([0xf0, 0x00, 0x00, 0x0e, 0x22] + bytes + [0xf7]))
  }
  
  private func patchFetchCommand(bank: UInt8, location: UInt8) -> RxMidi.FetchCommand {
    return fetchCommand([0x41, bank, 0x00, location])
  }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path.first! {
    case .patch:
      return [patchFetchCommand(bank: fetchBank, location: fetchLocation),
              .wait(0.03),
              .send(Data([0xb0 + UInt8(channel), 0x20, fetchBank])), // bank select (fine) on chan 1
              .send(Data([0xc0 + UInt8(channel), fetchLocation])), // pgmChange on chan 1
      ]
    case .memory:
      return [fetchCommand([0x41, 0x00, 0x04, 0x00])]
    case .bank:
      guard let bank = path.i(2) else { return nil }
      let voiceIndexPatch = patch(forPath: [.memory, .patch]) as? MiniakVoiceIndexPatch
      var fallbackLocation: Int?
      for i in 0..<128 {
        if voiceIndexPatch?.voices[bank][i] != nil {
          fallbackLocation = i
          break
        }
      }
      guard let fallback = fallbackLocation else { return nil }
      return Array((0..<128).map { (location) -> [RxMidi.FetchCommand] in
        // check if patch exists
        let fetchLocation = voiceIndexPatch?.voices[bank][location] == nil ? fallback : location
        return [
          patchFetchCommand(bank: UInt8(bank), location: UInt8(fetchLocation)),
          .wait(0.03),
        ] }.joined())
    default:
      return nil
    }
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(voiceOut(input: patchStateManager([.patch])!.typedChangesOutput()))

    (0..<8).forEach { bank in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .patch, .i(bank)])!.output) {
        guard let patch = $0 as? MicronVoicePatch else { return nil }
        return [patch.sysexData(bank: UInt8(bank), location: UInt8($1))]
      })
    }
    
    return midiOuts
  }
  
  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
    // update fetch bank, location to match to where we just saved
    guard patchPath == [.patch],
      let bank = bankPath.i(2) else { return }
    changePatch(forPath: [.global], .paramsChange([
      fetchBankPath : bank,
      fetchLocationPath : index,
    ]), transmit: false)
  }
  
  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    super.changePatch(forPath: path, change, transmit: transmit)
    guard case .replace = change else { return }
    makeFetchMatchWrite()
  }

  fileprivate func makeFetchMatchWrite() {
    changePatch(forPath: [.global], .paramsChange([
      fetchBankPath : Int(tempBank),
      fetchLocationPath : Int(tempLocation)
    ]), transmit: false)
  }

  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    switch path[0] {
    default:
      return { "\($0)" }
    }
  }
}
