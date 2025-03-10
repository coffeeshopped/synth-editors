
//class WavestationSREditor : SingleDocSynthEditor {
//    
//  required init(baseURL: URL) {
//    var map: [SynthPath:Sysexible.Type] = [
//      [.global] : WavestationSRGlobalPatch.self,
//      [.perf] : WavestationSRPerfPatch.self,
//    ]
//    (0..<8).forEach {
//      map[[.patch, .i($0)]] = WavestationSRPatchPatch.self
//    }
//    (0..<3).forEach {
//      map[[.bank, .patch, .i($0)]] = WavestationSRPatchBank.self
//      map[[.bank, .perf, .i($0)]] = WavestationSRPerfBank.self
//      map[[.bank, .seq, .i($0)]] = WavestationSRWaveSeqBank.self
//    }
//
//    super.init(baseURL: baseURL, sysexMap: map, migrationMap: [:])
//    
//    load { [weak self] in
//      // do this as a subscription. If we do the old globalDoc.patch?[..] method for grabbing
//      // fetchBank/Location on demand, it gives a stale result if there's no subscription to globalDoc.output yet.
//      self?.globalSubscription = self?.globalManager?.output.subscribe(onNext: { [weak self] in
//        self?.handleGlobalPatchChange($0.1)
//      })
//
//      self?.initPerfParamsOutput()
//      self?.initPatchParamsOutput()
//    }
//  }
//  
//  deinit {
//    globalSubscription?.dispose()
//    midiInDisposable?.dispose()
//  }
//
//  private var globalPatch: SysexPatch? { return patch(forPath: [.global]) }
//  private var perfPatch: SysexPatch? { return patch(forPath: [.perf]) }
//  var channel: Int { return globalPatch?[[.channel]] ?? 0 }
//  var tempBank: UInt8 { return UInt8(globalPatch?[[.bank]] ?? 7) }
//  var tempLocation: UInt8 { return UInt8(globalPatch?[[.location]] ?? 127) }
//  
//  private var globalManager: PatchStateManager? {
//    return patchStateManager([.global])
//  }
//  
//  // these should be read where needed, but only set by subscription to globalDoc
//  private var _fetchBank = 0
//  private var _fetchLocation = 0
//  private let fetchBankPath: SynthPath = [.dump, .bank]
//  private let fetchLocationPath: SynthPath = [.dump, .location]
//
//  private var globalSubscription: Disposable?
//
//  private func handleGlobalPatchChange(_ patch: SysexPatch) {
//    _fetchBank = patch[fetchBankPath] ?? _fetchBank
//    _fetchLocation = patch[fetchLocationPath] ?? _fetchLocation
//  }
//  
//  
//  // TODO: for the seq bank OUTPUTs, they should be mapped.
//  // when there is an insert, or a delete, then paramChanges should also be output for
//  // step number ... and maybe ALL steps after the one inserted or deleted!
//  
//
//  // MARK: MIDI I/O
//  
//  private var midiInDisposable: Disposable?
//  
//  override func setMidiIn(_ input: Observable<MidiMessage>?) {
//    super.setMidiIn(input)
//
//    midiInDisposable?.dispose()
//    midiInDisposable = input?.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] msg in
//      self?.handleMidiIn(msg)
//    })
//  }
//
//  private func handleMidiIn(_ msg: MidiMessage) {
//    switch msg {
//    case .cc(let channel, let number, let value):
//      guard channel == self.channel, number == 0x20 else { return }
//      globalManager?.patchChangesInput.value = (.paramsChange([fetchBankPath : Int(value)]), false)
//    case .pgmChange(let channel, let value):
//      guard channel == self.channel else { return }
//      globalManager?.patchChangesInput.value = (.paramsChange([fetchLocationPath : Int(value)]), false)
//    default:
//      break
//    }
//  }
//  
//  private func fetchHeader() -> [UInt8] {
//    return [0xf0, 0x42, 0x30 + UInt8(channel), 0x28]
//  }
//    
//  // bank fetching
//  // 0, 1 : RAM 1, 2
//  // 2 : ROM 11
//  // 3 : --- prob card?
//  // 4 : RAM 3
//  // 5, 6, 7, 8, 9, 10, 11 : ROM 4, 5, 6, 7, 8, 9, 10
//  
//  // map displayed bank to fetch msg
//  static let bankMap = [0,1,4,5,6,7,8,9,10,11,2]
//  
//  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
//    switch path.first! {
//    case .patch:
//      guard let part = path.i(1),
//        let bank = perfPatch?[[.part, .i(part), .bank]],
//        let patch = perfPatch?[[.part, .i(part), .patch]] else { return nil }
//      // look at current performance to see where we should be fetching from
//      return [.request(Data(fetchHeader() + [0x10, UInt8(type(of: self).bankMap[bank]), UInt8(patch), 0xf7]))]
//    case .perf:
//      return [.request(Data(fetchHeader() + [0x19, UInt8(type(of: self).bankMap[_fetchBank]), UInt8(_fetchLocation), 0xf7]))]
//    case .bank:
//      guard let bank = path.i(2) else { return nil }
//      let mappedBank = UInt8(type(of: self).bankMap[bank])
//      switch path[1] {
//      case .patch:
//        return [.request(Data(fetchHeader() + [0x1c, mappedBank, 0xf7]))]
//      case .perf:
//        return [.request(Data(fetchHeader() + [0x1d, mappedBank, 0xf7]))]
//      case .seq:
//        return [.request(Data(fetchHeader() + [0x0c, mappedBank, 0xf7]))]
//      default:
//        return nil
//      }
//    default:
//      return nil
//    }
//  }
//  
//  
//  // re-mapping performance param output to include patch names
//  private var perfParamsOutput: Observable<SynthPathParam>?
//  private var perfDisposeBag: DisposeBag?
//    
//  private func initPerfParamsOutput() {
//    guard let params = super.paramsOutput(forPath: [.perf]) else { return }
//    
//    var outs = [Observable<SynthPathParam>]()
//    outs.append(params)
//    
//    perfDisposeBag = DisposeBag()
//
//    (0..<3).forEach { bank in
//      guard let patchBankOut = bankChangesOutput(forPath: [.bank, .patch, .i(bank)]) else { return }
//      // we do it this way so that subscribing to this output doesn't require mapping the names every time
//      let patchBankMap = EditorHelper.bankNameOptionsMap(output: patchBankOut, path: [.patch, .name, .i(bank)], nameBlock: { "\($0): \($1)" })
//      let patchBankSubject = BehaviorSubject<SynthPathParam>(value: [:])
//      patchBankMap.subscribe(patchBankSubject).disposed(by: perfDisposeBag!)
//      outs.append(patchBankSubject)
//    }
//
//    perfParamsOutput = Observable.merge(outs)
//  }
//  
//  // re-mapping to include wave sequence names
//  private var patchParamsOutput: Observable<SynthPathParam>?
//  private var patchDisposeBag: DisposeBag?
//
//  private func initPatchParamsOutput() {
//    guard let params = super.paramsOutput(forPath: [.patch, .i(0)]) else { return }
//    
//    var outs = [Observable<SynthPathParam>]()
//    outs.append(params)
//    
//    patchDisposeBag = DisposeBag()
//
//    (0..<3).forEach { bank in
//      guard let seqBankOut = patchChangesOutput(forPath: [.bank, .seq, .i(bank)]) else { return }
//      // we do it this way so that subscribing to this output doesn't require mapping the names every time
//
//      let seqMap: Observable<[Int:String]> = seqBankOut.map {
//        guard let seqBank = $0.1 as? WavestationSRWaveSeqBank else { return [:] }
//        var opts = [Int:String]()
//        (0..<32).forEach { seq in
//          guard let name = seqBank.name(seq) else { return }
//          opts[seq] = "\(seq): \(name)"
//        }
//        return opts
//      }
//      let seqBankMap: Observable<SynthPathParam> = seqMap.map {
//        return [[.seq, .name, .i(bank)] : OptionsParam(options: $0)]
//      }
//      
//      let seqBankSubject = BehaviorSubject<SynthPathParam>(value: [:])
//      seqBankMap.subscribe(seqBankSubject).disposed(by: patchDisposeBag!)
//      outs.append(seqBankSubject)
//    }
//
//    patchParamsOutput = Observable.merge(outs)
//  }
//  
//  override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
//    switch path.first {
//    case .perf:
//      return perfParamsOutput
//    case .patch:
//      return patchParamsOutput
//    default:
//      return super.paramsOutput(forPath: path)
//    }
//  }
//  
//  
//  func waveOptions(forBank bank: Int) -> [Int:String] {
//    return WavestationSRPatchPatch.waveOptions
//  }
//  
//  override func midiOuts() -> [Observable<[Data]?>] {
//    var midiOuts = [Observable<[Data]?>]()
//
//    // TODO: Global?
//    
//    (0..<8).forEach { part in
//      let voiceManager: PatchStateManager = patchStateManager([.patch, .i(part)])!
//      midiOuts.append(voiceOut(part: part, input: voiceManager.typedChangesOutput()))
//    }
//
//    let perfManager: PatchStateManager = patchStateManager([.perf])!
//    midiOuts.append(perfOut(input: perfManager.typedChangesOutput()))
//
//    (0..<3).forEach { bank in
//      let voiceBankManager: BankStateManager = bankStateManager([.bank, .patch, .i(bank)])!
//      let voiceBankOut: Observable<(BankChange, WavestationSRPatchBank, Bool)> = voiceBankManager.typedChangesOutput()
//      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: voiceBankOut) {
//        [$0.sysexData(channel: self.channel, bank: bank, location: $1)]
//      })
//
//      let perfBankManager: BankStateManager = bankStateManager([.bank, .perf, .i(bank)])!
//      let perfBankOut: Observable<(BankChange, WavestationSRPerfBank, Bool)> = perfBankManager.typedChangesOutput()
//      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: perfBankOut) {
//        [$0.sysexData(channel: self.channel, bank: bank, location: $1)]
//      })
//
//      let seqBankManager: PatchStateManager = patchStateManager([.bank, .seq, .i(bank)])!
//      midiOuts.append(seqBankOut(bank: bank, input: seqBankManager.typedChangesOutput()))
//    }
//
//    return midiOuts
//  }
//  
//  override func midiChannel(forPath path: SynthPath) -> Int {
//    return channel
//  }
//  
//  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
//    switch patchType {
//    case is WavestationSRPatchPatch.Type:
//      return [[.bank, .patch, .i(0)], [.bank, .patch, .i(1)], [.bank, .patch, .i(2)]]
//    case is WavestationSRPerfPatch.Type:
//      return [[.bank, .perf, .i(0)], [.bank, .perf, .i(1)], [.bank, .perf, .i(2)]]
//    default:
//      return []
//    }
//  }
//
//  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
//    switch patchType {
//    case is WavestationSRPatchPatch.Type:
//      return ["Patch Bank 1", "Patch Bank 2", "Patch Bank 3"]
//    case is WavestationSRPerfPatch.Type:
//      return ["Perf Bank 1", "Perf Bank 2", "Perf Bank 3"]
//    default:
//      return []
//    }
//  }
//
//  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
//    return { "\($0)" }
//  }
//}
//
//// MARK: Midi Out
//
//extension WavestationSREditor {
//  
//  enum ParamType : UInt8 {
//    case norm = 0x41, exp = 0x42, sr = 0x43
//  }
//  
//  private func paramChange(parm: Int, value: Int) -> Data {
//    let type: ParamType
//    if (1...379) ~= parm {
//      type = .norm
//    }
//    else if (380...406) ~= parm {
//      type = .exp
//    }
//    else if (407...484) ~= parm {
//      type = .sr
//    }
//    else {
//      return Data()
//    }
//
//    let lsb = UInt8(parm & 0x7f)
//    let msb = UInt8((parm >> 7) & 0x7f)
//    var data = Data([0xf0, 0x42, 0x30 + UInt8(self.channel), 0x28, type.rawValue, lsb, msb])
//    data.append(contentsOf: "\(value)".utf8.map { $0 })
//    data.append(contentsOf: [0x00, 0xf7])
//    return data
//  }
//  
//  func partSelectMsg(part: Int) -> Data {
//    // set current part (1-based, not 0)
//    return paramChange(parm: 56, value: part + 1)
//  }
//  
//  func voiceOut(part: Int, input: Observable<(PatchChange,WavestationSRPatchPatch, Bool)>) -> Observable<[Data]?> {
//    
//    return GenericMidiOut.patchChange(throttle: .milliseconds(300), input: input, paramTransform: { (patch, path, value) -> [Data]? in
//      guard let param = type(of: patch).params[path] else { return nil }
//      let parm = param.parm
//      var cmds = [Data]()
//      
//      // set current part (1-based, not 0)
//      cmds.append(self.partSelectMsg(part: part))
//
//      // some params need pre-commands sent...
//      if (80...146) ~= parm || (347...348) ~= parm { // voice params
//        // set current voice (wave)
//        cmds.append(self.paramChange(parm: 79, value: path.i(1)!))
//      }
//      else if (194...196) ~= parm { // mix env pts
//        // set env pt
//        cmds.append(self.paramChange(parm: 193, value: path.i(2)! + 1))
//      }
//      
//      let v: Int
//      if path.last == .bank {
//        v = WavestationSRPerfPatch.patchBankMap[value]
//      }
//      else {
//        v = value
//      }
//      // send the param
//      cmds.append(self.paramChange(parm: parm, value: v))
//      
//      return cmds
//
//    }, patchTransform: { [weak self] (patch) -> [Data]? in
//      guard let self = self else { return nil }
//      return [
//        self.partSelectMsg(part: part),
//        patch.sysexData(channel: self.channel, bank: 0, location: 0)
//      ]
//
//    })
//  }
//  
//  func perfOut(input: Observable<(PatchChange,WavestationSRPerfPatch, Bool)>) -> Observable<[Data]?> {
//    
//    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
//      guard let param = type(of: patch).params[path] else { return nil }
//      let parm = param.parm
//      var cmds = [Data]()
//      
//      // some params need pre-commands sent...
//      if (57...76) ~= parm { // part params
//        // set current part (1-based, not 0)
//        cmds.append(self.partSelectMsg(part: path.i(1)!))
//      }
//      
//      // if sending bank #, needs mapping
//      let v: Int
//      if path.last == .bank {
//        v = WavestationSRPerfPatch.patchBankMap[value]
//      }
//      else if path.last == .patch {
//        v = value == 255 ? -1 : value
//      }
//      else {
//        v = value
//      }
//      
//      // send the param
//      cmds.append(self.paramChange(parm: parm, value: v))
//
//      return cmds
//
//    }, patchTransform: { (patch) -> [Data]? in
//      return [patch.sysexData(channel: self.channel, bank: 0, location: 0)]
//
//    })
//  }
//  
//  func seqBankOut(bank: Int, input: Observable<(PatchChange, WavestationSRWaveSeqBank, Bool)>) -> Observable<[Data]?> {
//    
//    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
//      guard path[0] == .seq,
//        let seq = path.i(1) else {
//          return nil
//      }
//
//      var cmds = [Data]()
//      
//      // TODO: send seq name
//      
//      // select wave seq bank
//      cmds.append(self.paramChange(parm: 176, value: bank))
//      // select wave seq number
//      cmds.append(self.paramChange(parm: 175, value: seq))
//
//      let paramPath = SynthPath(path.suffix(from: 2))
//
//      if paramPath.count > 2 && paramPath[0] == .step,
//        let step = paramPath.i(1) {
//        // select wave seq step
//        // NOTE: it's 1-based, not 0-based like internally
//        cmds.append(self.paramChange(parm: 178, value: step + 1))
//        
//        guard let param = type(of: patch).params[paramPath],
//          param.parm > 0 else { return nil }
//        cmds.append(self.paramChange(parm: param.parm, value: value))
//      }
//      else if paramPath == [.step, .insert] {
//        // select the step
//        cmds.append(self.paramChange(parm: 178, value: value))
//        // send the insert cmd
//        cmds.append(self.paramChange(parm: 459, value: 1)) // TODO: what is the right value here?
//      }
//      else if paramPath == [.step, .dump] {
//        // select the step
//       cmds.append(self.paramChange(parm: 178, value: value))
//       // send the insert cmd
//       cmds.append(self.paramChange(parm: 460, value: 1)) // TODO: what is the right value here?
//     }
//      else {
//        // for seq-level params
//        guard let param = type(of: patch).params[path],
//          param.parm > 0 else { return nil }
//        cmds.append(self.paramChange(parm: param.parm, value: value))
//      }
//
//      return cmds
//
//    }, patchTransform: { (patch) -> [Data]? in
//      return [patch.sysexData(channel: self.channel, bank: bank)]
//
//    })
//  }
//
//}
//
