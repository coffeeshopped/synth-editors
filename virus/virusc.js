const editor = {
  name: "",
  trussMap: ([
    ["global", Global.patchTruss],
    ["patch", Voice.patchTruss],
    ["multi", Multi.patchTruss],
    ["multi/bank", Multi.bankTruss],
  ]).concat(
    (16).map(i => [["part", i] = Voice.patchTruss }
    (2).map(i => [["bank", i] = Voice.bankTruss }
  ),
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: [
  ],
}



class VirusCEditor : SingleDocSynthEditor, VirusEditor {
  
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

    midiOuts.append(global(input: patchStateManager("global")!.typedChangesOutput()))
    midiOuts.append(voice(input: patchStateManager("patch")!.typedChangesOutput(), part: 0x40))
    midiOuts.append(multi(input: patchStateManager("multi")!.typedChangesOutput()))

    midiOuts.append(contentsOf: (0..<16).map {
      voice(input: patchStateManager("part/$0")!.typedChangesOutput(), part: UInt8($0))
    })
    
    (0..<2).forEach { i in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("bank/i")!.output, patchTransform: {
        guard let patch = $0 as? VirusCVoicePatch else { return nil }
        return [patch.sysexData(deviceId: self.deviceId, bank: UInt8(i + 1), part: UInt8($1))]
      }))
    }

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("multi/bank")!.output, patchTransform: {
      guard let patch = $0 as? VirusMultiPatch else { return nil }
      return [patch.sysexData(deviceId: self.deviceId, bank: 1, part: UInt8($1))]
    }))

    return midiOuts
  }
  
 
  private func initPerfParamsOutput() {
    guard let params = super.paramsOutput(forPath: "multi") else { return }
    
    perfDisposeBag = DisposeBag()

    // we do it this way so that subscribing to this output doesn't require mapping the names every time
    var bankSubjects = [Observable<SynthPathParam>]()
    (0..<2).forEach {
      let bankOut = bankChangesOutput(forPath: "bank/$0")!
      let patchBankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: "patch/name/$0") {
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
    guard path == "multi" else { return super.paramsOutput(forPath: path) }
    return perfParamsOutput
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
