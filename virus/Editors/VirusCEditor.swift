
class VirusCEditor : SingleDocSynthEditor, VirusEditor {
  
  required init(baseURL: URL) {
    var map: [SynthPath:Sysexible.Type] = [
      [.global] : VirusCGlobalPatch.self,
      [.patch] : VirusCVoicePatch.self,
      [.multi] : VirusCMultiPatch.self,
      [.multi, .bank] : VirusCMultiBank.self,
    ]
    (0..<16).forEach { map[[.part, .i($0)]] = VirusCVoicePatch.self }
    (0..<2).forEach { map[[.bank, .i($0)]] = VirusCVoiceBank.self }

    super.init(baseURL: baseURL, sysexMap: map)
    load { [weak self] in
      self?.initPerfParamsOutput()
    }

  }

    
  // MARK: MIDI I/O
      
//  override var sendInterval: TimeInterval { return 0.2 }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path.first {
    case .global:
      return [fetchRequest([0x35])]
    case .patch:
      return [fetchRequest([0x30, 0x00, 0x40])]
    case .multi:
      return [fetchRequest(path.last == .bank ? [0x33, 0x01] : [0x31, 0x00, 0x00])]
    case .bank:
      guard let bankIndex = path.i(1) else { return nil }
      return [fetchRequest([0x32, UInt8(bankIndex + 1)])]
    case .part:
      guard let part = path.i(1) else { return nil }
      return [fetchRequest([0x30, 0x00, UInt8(part)])]
    default:
      return nil
    }
  }
    
  
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(global(input: patchStateManager([.global])!.typedChangesOutput()))
    midiOuts.append(voice(input: patchStateManager([.patch])!.typedChangesOutput(), part: 0x40))
    midiOuts.append(multi(input: patchStateManager([.multi])!.typedChangesOutput()))

    midiOuts.append(contentsOf: (0..<16).map {
      voice(input: patchStateManager([.part, .i($0)])!.typedChangesOutput(), part: UInt8($0))
    })
    
    (0..<2).forEach { i in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .i(i)])!.output, patchTransform: {
        guard let patch = $0 as? VirusCVoicePatch else { return nil }
        return [patch.sysexData(deviceId: self.deviceId, bank: UInt8(i + 1), part: UInt8($1))]
      }))
    }

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.multi, .bank])!.output, patchTransform: {
      guard let patch = $0 as? VirusMultiPatch else { return nil }
      return [patch.sysexData(deviceId: self.deviceId, bank: 1, part: UInt8($1))]
    }))

    return midiOuts
  }
  
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }

  private var perfParamsOutput: Observable<SynthPathParam>?
  private var perfDisposeBag: DisposeBag?
    
  private func initPerfParamsOutput() {
    guard let params = super.paramsOutput(forPath: [.multi]) else { return }
    
    perfDisposeBag = DisposeBag()

    // we do it this way so that subscribing to this output doesn't require mapping the names every time
    var bankSubjects = [Observable<SynthPathParam>]()
    (0..<2).forEach {
      let bankOut = bankChangesOutput(forPath: [.bank, .i($0)])!
      let patchBankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: [.patch, .name, .i($0)]) {
        "\($0): \($1)"
      }
      let patchBankSubject = BehaviorSubject<SynthPathParam>(value: [:])
      patchBankMap.subscribe(patchBankSubject).disposed(by: perfDisposeBag!)
      bankSubjects.append(patchBankSubject)
    }
    bankSubjects.append(params)
    perfParamsOutput = Observable.merge(bankSubjects)
  }
  
  override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
    guard path == [.multi] else { return super.paramsOutput(forPath: path) }
    return perfParamsOutput
  }

  
  // MARK: Bank Support

  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is VoicePatch.Type:
      return (0..<2).map { [.bank, .i($0)] }
    case is PerfPatch.Type:
      return [[.multi, .bank]]
    default:
      return []
    }
  }

  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is VoicePatch.Type:
      return ["Bank A", "Bank B"]
    case is PerfPatch.Type:
      return ["Multi"]
    default:
      return []
    }
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    if let bankIndex = path.i(1) {
      return {
        let b = ["A", "B"][bankIndex]
        return "\(b)\($0)"
      }
    }
    else {
      return { "\($0)" }
    }
  }


}

extension VirusCEditor {

  /// Transform <patchChange, patch> into MIDI out data
  func global(input: PatchTransmitObservable<VirusCGlobalPatch>) -> Observable<[Data]?> {
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      let noSendParms: [SynthPath] = [[.deviceId]]
      guard !noSendParms.contains(path) else { return nil }

      let pushParms: [SynthPath] = [[.knob, .vib]]
      if pushParms.contains(path) {
        return [patch.sysexData(deviceId: self.deviceId)]
      }
      else {
        guard let param = type(of: patch).params[path] else { return nil }
        return [Data(self.sysexCommand([0x72, 0x00, UInt8(param.byte), UInt8(value)]))]
      }

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(deviceId: self.deviceId)]
    })
  }

  /// Transform <patchChange, patch> into MIDI out data
  func voice(input: PatchTransmitObservable<VirusCVoicePatch>, part: UInt8) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      
      let section = param.byte / 128 // should be 0...3
      let cmdByte: UInt8 = [0x70, 0x71, 0x6e, 0x6f][section]
      let cmdBytes = self.sysexCommand([cmdByte, part, UInt8(param.byte % 128), UInt8(value)])
      return [Data(cmdBytes)]

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(deviceId: self.deviceId, bank: 0, part: part)]

    }) { (patch, path, name) -> [Data]? in
      // batch as a single data so that it doesn't get .wait()s interleaved
      return [Data(patch.nameBytes.enumerated().map {
        Data(self.sysexCommand([0x71, part, UInt8(0x70 + $0.offset), $0.element]))
      }.joined())]
    }
  }
    
  func multi(input: PatchTransmitObservable<VirusCMultiPatch>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      let loPage: [SynthPathItem] = [.fx, .pan]
      guard let param = type(of: patch).params[path] else { return nil }
      let part = path.i(1) ?? 0
      let cmdByte: UInt8 = loPage.contains(path.last!) ? 0x70 : 0x72
      return [Data(self.sysexCommand([cmdByte, UInt8(part), UInt8(param.parm), UInt8(value)]))]

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(deviceId: self.deviceId, bank: 0, part: 0)]

    }) { (patch, path, name) -> [Data]? in
      return [Data(name.bytes(forCount: 10).enumerated().map {
        Data(self.sysexCommand([0x72, 0, UInt8(0x04 + $0.offset), $0.element]))
      }.joined())]
    }
  }
    
}


