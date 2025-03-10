
class JD990Editor : RolandNewAddressableEditor {
  
  override var deviceId: Int {
    return patch(forPath: [.deviceId])?[[.deviceId]] ?? 0
  }
  
  private static let _sysexMap: [SynthPath:Sysexible.Type] = {
    var map: [SynthPath:Sysexible.Type] = [
      [.deviceId]     : JD990SettingsPatch.self, // has device ID and PCM card setting
      [.global]       : JD990GlobalPatch.self,
      [.patch]        : JD990VoicePatch.self,
      [.rhythm]       : JD990RhythmPatch.self,
      [.perf]         : JD990PerfPatch.self,
      [.bank, .perf, .i(0)]  : JD990PerfBank.self, // internal
      [.bank, .perf, .i(1)]  : JD990PerfBank.self, // card
      [.bank, .patch, .i(0)] : JD990VoiceBank.self,
      [.bank, .patch, .i(1)] : JD990VoiceBank.self,
      [.bank, .rhythm, .i(0)] : JD990RhythmBank.self,
      [.bank, .rhythm, .i(1)] : JD990RhythmBank.self,
    ]
    (0..<7).forEach {
      map[[.part, .i($0)]] = JD990VoicePatch.self
    }
    return map
  }()
  class var sysexMap: [SynthPath:Sysexible.Type] { return _sysexMap }
  
  static let migrationMap: [SynthPath:String] = [:]

  required init(baseURL: URL) {
    super.init(baseURL: baseURL, sysexMap: type(of: self).sysexMap, migrationMap: type(of: self).migrationMap)
    
    load { [weak self] in
      self?.initPerfParamsOutput()
      self?.initPatchParamsOutput()
    }
  }
  
  // MARK: Interactions
  
  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
    // side effect: if saving from a part editor, update performance patch
    guard patchPath[0] == .part else { return }
    let params: [SynthPath:Int] = [
      patchPath + [.bank] : 0,
      patchPath + [.pgm, .number] : index
    ]
    changePatch(forPath: [.perf], MakeParamsChange(params), transmit: true)
  }
  
  
  // MARK: MIDI I/O
  
  override var requestHeader: Data {
    return Data([0xf0, 0x41, UInt8(deviceId), 0x57, 0x11])
  }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    if path == [.part, .i(0)] {
      guard let addressable = sysexibleType(path: path) as? RolandAddressable.Type else { return nil }
      let address = addressable.startAddress(path)
      return [.request(fetchRequestData(forAddress: address, size: JD990CommonPatch.size, addressCount: JD990CommonPatch.addressCount))]
    }
    
    guard let bankType = sysexibleType(path: path) as? RolandAddressableBank.Type,
      let bankPatchType = bankType.patchType as? RolandAddressable.Type else {
      return super.fetchCommands(forPath: path)
    }

    let address = bankType.startAddress(path)
    let cmds: [[RxMidi.FetchCommand]] = (0..<bankType.patchCount).map { [
      .request(fetchRequestData(forAddress: address + ($0 * 0x010000), size: bankPatchType.size, addressCount: bankType.addressCount)),
      .wait(1.2), // both voice and perf banks return multiple messages PER request message
        // RXMidiCommunicator is not handling that correctly at the moment; it sends the next
        // fetch request immediately after getting midi input that doesn't complete a fetch.
        // TODO: need to associate an expected byte count to be returned PER REQUEST MSG in midi commands
    ] }
    return [RxMidi.FetchCommand](cmds.joined())
  }
    
  override func midiChannel(forPath path: SynthPath) -> Int {
    guard let i = path.i(1) else { return 0 }
    return patch(forPath: [.perf])?[[.part, .i(i), .channel]] ?? 0
  }
    
  
  private var perfParamsOutput: Observable<SynthPathParam>?
  private var perfDisposeBag: DisposeBag?
    
  private func initPerfParamsOutput() {
    guard let params = super.paramsOutput(forPath: [.perf]),
      let patchBank0Out = bankChangesOutput(forPath: [.bank, .patch, .i(0)]),
      let patchBank1Out = bankChangesOutput(forPath: [.bank, .patch, .i(1)]),
      let rhythmBank0Out = bankChangesOutput(forPath: [.bank, .rhythm, .i(0)]),
      let rhythmBank1Out = bankChangesOutput(forPath: [.bank, .rhythm, .i(1)]) else { return }
    
    perfDisposeBag = DisposeBag()

    let patchBank0 = bankNameSubject(bankChanges: patchBank0Out, path: [.patch, .name, .i(0)], disposeBag: perfDisposeBag!)
    let patchBank1 = bankNameSubject(bankChanges: patchBank1Out, path: [.patch, .name, .i(1)], disposeBag: perfDisposeBag!)
    let rhythmBank0 = bankNameSubject(bankChanges: rhythmBank0Out, path: [.rhythm, .name, .i(0)], disposeBag: perfDisposeBag!)
    let rhythmBank1 = bankNameSubject(bankChanges: rhythmBank1Out, path: [.rhythm, .name, .i(1)], disposeBag: perfDisposeBag!)

    perfParamsOutput = Observable.merge(params, patchBank0, rhythmBank0, patchBank1, rhythmBank1)
  }
  
  private func bankNameSubject(bankChanges: Observable<(BankChange, SysexPatchBank?)>, path: SynthPath, disposeBag: DisposeBag) -> BehaviorSubject<SynthPathParam> {
    // we do it this way so that subscribing to this output doesn't require mapping the names every time
    let bankPrefix = path.endex == 0 ? "I" : "C"
    let isRhythm = path.first == .rhythm
    let optionsMap = EditorHelper.bankNameOptionsMap(output: bankChanges, path: path, nameBlock: {
      let number = isRhythm ? "" : "\(($0 / 8) + 1)\(($0 % 8) + 1)"
      return "\(bankPrefix)\(number): \($1)"
    })
    let subject = BehaviorSubject<SynthPathParam>(value: [:])
    optionsMap.subscribe(subject).disposed(by: disposeBag)
    return subject
  }
  
  private var patchParamsOutput: Observable<SynthPathParam>?
    
  // add the PCM/Exp params
  private func initPatchParamsOutput() {
    guard let params = super.paramsOutput(forPath: [.patch]),
      let deviceOut = patchChangesOutput(forPath: [.deviceId]) else { return }
    
    let deviceParams: Observable<SynthPathParam> = deviceOut.map {
      var p = SynthPathParam()
      guard let patch = $0.1 else { return p }
      
      if let pcm = patch[[.pcm]],
        let card = SOJD80Card.cards[pcm] {
        p[[.pcm]] = OptionsParam(options: card.waveOptions)
      }
      if let extra = patch[[.extra]],
        let board = SRJVBoard.boards[extra] {
        p[[.extra]] = OptionsParam(options: board.waveOptions)
      }

      return p
    }
    patchParamsOutput = Observable.merge(params, deviceParams)
  }
    
  override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
    if path == [.perf] {
      return perfParamsOutput
    }
    else if path.first == .patch || path.first == .part {
      return patchParamsOutput
    }
    return super.paramsOutput(forPath: path)
  }
  
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is VoicePatch.Type:
      return [[.bank, .patch, .i(0)], [.bank, .patch, .i(1)]]
    case is PerfPatch.Type:
      return [[.bank, .perf, .i(0)], [.bank, .perf, .i(1)]]
    case is RhythmPatch.Type:
      return [[.bank, .rhythm, .i(0)], [.bank, .rhythm, .i(1)]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is VoicePatch.Type:
      return ["Patch Bank", "C: Patch Bank"]
    case is PerfPatch.Type:
      return ["Perf Bank", "C: Perf Bank"]
    case is RhythmPatch.Type:
      return ["Rhythm Bank", "C: Rhythm Bank"]
    default:
      return []
    }
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    guard path.starts(with: [.bank, .patch]) else { return super.bankIndexLabelBlock(forPath: path) }
    return {
      let bank = ($0 / 8) + 1
      let patch = ($0 % 8) + 1
      return "\(bank)\(patch)"
    }
  }

  
}
