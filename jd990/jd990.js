
protocol JD990Patch : RolandSingleAddressable { }
extension JD990Patch {
  
  // Different multi-byte param pack/unpack
  
  /// Compose Int value from bytes (MSB first)
  static func multiByteParamInt(from: [UInt8]) -> Int {
    guard from.count > 1 else { return Int(from[0]) }
    return (1...from.count).reduce(0) {
      let shift = (from.count - $1) * 7
      return $0 + (Int(from[$1 - 1]) << shift)
    }
  }

  /// Decompose Int to bytes (7! bits at a time)
  static func multiByteParamBytes(from: Int, count: Int) -> [UInt8] {
    guard count > 0 else { return [UInt8(from)] }
    return (1...count).map {
      let shift = (count - $0) * 7
      return UInt8((from >> shift) & 0x7f)
    }
  }

}


class JD990VoiceBank: JD990Bank<JD990VoicePatch>, VoiceBank {

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    // internal, or card
    return path?.endex == 0 ? 0x06000000 : 0x0a000000
  }
  
  override class var patchCount: Int { return 64 }
  override class var initFileName: String { return "jd990-voice-bank-init" }

  
  override class func isValid(fileSize: Int) -> Bool {
    return fileSize == 33216 || fileSize == fileDataCount
  }

}


const editor = {
  rolandModelId: [0x57], 
  addressCount: 4,
  name: "",
  map: ([
    ["deviceId", ?, Settings.patchWerk], // has device ID and PCM card setting
    ["global", Global.patchWerk],
    ["patch" , Voice.patchWerk],
    ["rhythm", Rhythm.patchWerk],
    ["perf"  , Perf.patchWerk],
    ["bank/perf/0" , Perf.bankWerk, // internal
    ["bank/perf/1" , Perf.bankWerk, // card
    ["bank/patch/0", Voice.bankWerk,
    ["bank/patch/1", Voice.bankWerk,
    ["bank/rhythm/0", Rhythm.bankWerk,
    ["bank/rhythm/1", Rhythm.bankWerk,
  ]).concat(
    (7).map(i => [['part', i], , Voice.patchWerk])
  ),
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
    ['bank/patch', ['user', i => {
      const bank = (i / 8) + 1
      const patch = (i % 8) + 1
      return `${bank}${patch}`
    }]]
  ],
}



class JD990Editor : RolandNewAddressableEditor {
  
  override var deviceId: Int {
    return patch(forPath: "deviceId")?["deviceId"] ?? 0
  }
  
  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
    // side effect: if saving from a part editor, update performance patch
    guard patchPath[0] == .part else { return }
    let params: [SynthPath:Int] = [
      patchPath + "bank" : 0,
      patchPath + "pgm/number" : index
    ]
    changePatch(forPath: "perf", MakeParamsChange(params), transmit: true)
  }
    
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    if path == "part/0" {
      guard let addressable = sysexibleType(path: path) as? RolandAddressable.Type else { return nil }
      let address = addressable.startAddress(path)
      return `request(fetchRequestData(forAddress: address/${size: JD990CommonPatch.size}/${addressCount: JD990CommonPatch.addressCount))}`
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
    return patch(forPath: "perf")?["part/i/channel"] ?? 0
  }
        
  private func initPerfParamsOutput() {
    guard let params = super.paramsOutput(forPath: "perf"),
      let patchBank0Out = bankChangesOutput(forPath: "bank/patch/0"),
      let patchBank1Out = bankChangesOutput(forPath: "bank/patch/1"),
      let rhythmBank0Out = bankChangesOutput(forPath: "bank/rhythm/0"),
      let rhythmBank1Out = bankChangesOutput(forPath: "bank/rhythm/1") else { return }
    
    perfDisposeBag = DisposeBag()

    let patchBank0 = bankNameSubject(bankChanges: patchBank0Out, path: "patch/name/0", disposeBag: perfDisposeBag!)
    let patchBank1 = bankNameSubject(bankChanges: patchBank1Out, path: "patch/name/1", disposeBag: perfDisposeBag!)
    let rhythmBank0 = bankNameSubject(bankChanges: rhythmBank0Out, path: "rhythm/name/0", disposeBag: perfDisposeBag!)
    let rhythmBank1 = bankNameSubject(bankChanges: rhythmBank1Out, path: "rhythm/name/1", disposeBag: perfDisposeBag!)

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
    guard let params = super.paramsOutput(forPath: "patch"),
      let deviceOut = patchChangesOutput(forPath: "deviceId") else { return }
    
    let deviceParams: Observable<SynthPathParam> = deviceOut.map {
      var p = SynthPathParam()
      guard let patch = $0.1 else { return p }
      
      if let pcm = patch["pcm"],
        let card = SOJD80Card.cards[pcm] {
        p["pcm"] = OptionsParam(options: card.waveOptions)
      }
      if let extra = patch["extra"],
        let board = SRJVBoard.boards[extra] {
        p["extra"] = OptionsParam(options: board.waveOptions)
      }

      return p
    }
    patchParamsOutput = Observable.merge(params, deviceParams)
  }
    
  override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
    if path == "perf" {
      return perfParamsOutput
    }
    else if path.first == .patch || path.first == .part {
      return patchParamsOutput
    }
    return super.paramsOutput(forPath: path)
  }
  
}
