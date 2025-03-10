
class ESQ1Editor : SingleDocSynthEditor {
  
  var channel: Int { patch(forPath: [.global])?[[.channel]] ?? 0 }

  private static let _patchMap: [SynthPath:Sysexible.Type] = [
    [.global] : ChannelSettingsPatch.self,
    [.patch] : ESQPatch.self,
    [.bank] : ESQBank.self,
  ]
  class var patchMap: [SynthPath:Sysexible.Type] { return _patchMap }
  
  required init(baseURL: URL) {
    let migrationMap: [SynthPath:String] = [
      [.global] : "Global.json",
      [.patch] : "Voice.syx",
      [.bank] : "Bank.syx",
    ]

    super.init(baseURL: baseURL, sysexMap: Self.patchMap, migrationMap: migrationMap)
  }
  
  // MARK: MIDI I/O
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .patch:
      return [.request(Data([0xf0, 0x0f, 0x02, UInt8(channel), 0x09, 0xf7]))]
    case .bank:
      return [.request(Data([0xf0, 0x0f, 0x02, UInt8(channel), 0x0a, 0xf7]))]
    default:
      return nil
    }
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    [
      voice(input: patchStateManager([.patch])!.typedChangesOutput()),
      bank(input: bankStateManager([.bank])!.typedChangesOutput()),
    ]
  }
  
  private var patchParamsOutput: Observable<SynthPathParam>?
  private var paramsDisposeBag: DisposeBag?
    
  private func initParamsOutput() {
    guard let origParams = super.paramsOutput(forPath: [.patch]),
      let bankOut = bankChangesOutput(forPath: [.bank]) else { return }
    
    paramsDisposeBag = DisposeBag()

    // we do it this way so that subscribing to this output doesn't require mapping the names every time
    let bankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: [.patch, .name])
    let bankSubject = BehaviorSubject<SynthPathParam>(value: [:])
    bankMap.subscribe(bankSubject).disposed(by: paramsDisposeBag!)

    patchParamsOutput = Observable.merge(origParams, bankSubject)
  }
  
  override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
    switch path.first {
    case .patch:
      if patchParamsOutput == nil { initParamsOutput() }
      return patchParamsOutput
    default:
      return super.paramsOutput(forPath: path)
    }
  }

  
  override func midiChannel(forPath path: SynthPath) -> Int { channel }
    
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] { [[.bank]] }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] { ["Voice Bank"] }
  
  func patchSendData(patch: ESQPatch) -> [Data] {
    // button press: Internal, Bank 1
    // patch data
    // then exit out of save mode: softkey5 down, up
    return [
      Self.keyPress(channel, [0x26, 0x59, 0x22, 0x55]),
      patch.sysexData(channel: channel),
      Self.keyPress(channel, [0x2f, 0x62]),
    ]
  }
  
  class func keyPress(_ channel: Int, _ keys: [UInt8]) -> Data {
    Data([0xf0, 0x0f, 0x02, UInt8(channel), 0x0e] + keys + [0xf7])
  }
  
  /// Transform <channel, patchChange, patch> into MIDI out data
  func voice(input: Observable<(PatchChange, ESQPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(300), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] as? ParamWithRange else { return nil }
      var data = [Data]()

      // trigger edit mode if needed
      // osc 1 button to trigger edit mode
      data.append(Self.keyPress(self.channel, [0x08, 0x3b]))

      let minValue = param.range.lowerBound
      let maxValue = param.range.upperBound

      let byte: Int
      
      if type(of: patch) is SQ80Patch.Type && [3, 13, 23, 33].contains(param.parm) {
        // .velo, .extra
        let patchByte = patch.bytes[param.byte]
        // LV value + lin/exp flag at top bit
        byte = patchByte.bits(2...7) + (patchByte.bit(0) * 64)
      }
      else if type(of: patch) is SQ80Patch.Type && [8, 18, 28, 38].contains(param.parm) {
        // .release, .extra
        let patchByte = patch.bytes[param.byte]
        // T4 value + 2nd release flag at top bit
        byte = patchByte.bits(0...5) + (patchByte.bit(7) * 64)
      }
      else if maxValue == 39 || maxValue == 74 {
        // split layer etc preset select is just straight value
        // so is wave select ONLY on SQ-80!
        byte = value
      }
      else if minValue == -63 {
        // the mapping in the final (below) case was making negative values off by 1.
        byte = value + 64
      }
      else {
        byte = max(0, Int((127 * (Float(value - minValue) / Float(maxValue - minValue))).rounded()))
      }

      data.append(Data(Midi.nrpn(param.parm, value: byte, channel: self.channel)))
      return data
      
    }, patchTransform: { (patch) -> [Data]? in
      self.patchSendData(patch: patch)
      
    }) { (patch, path, name) -> [Data]? in
      self.patchSendData(patch: patch)

    }
  }

}

extension ESQ1Editor {
  
  
  /// Transform <channel, patchChange, patch> into MIDI out data
  ///
  func bank(input: Observable<(BankChange, ChannelizedSysexible, Bool)>) -> Observable<[Data]?> {
    return GenericMidiOut.wholeBank(input: input) {
      let channel = self.channel
      // internal down, up
      // bank 1 down, up
      let saveMode = Self.keyPress(channel, [0x26, 0x59, 0x22, 0x55])
      
      let bank = $0.sysexData(channel: channel)
      
      // then exit out of save mode
      // softkey5 down, up
      let exitSaveMode = Self.keyPress(channel, [0x2f, 0x62])
      
      return [saveMode, bank, exitSaveMode]
    }
  }
}
