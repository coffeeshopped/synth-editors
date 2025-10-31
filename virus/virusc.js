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
    ([
      ["global", Global.patchTransform],
      ["patch", Voice.patchTransform(0x40)],
      ["multi", Multi.patchTransform],
      ["multi/bank", Multi.bankTransform],
    ]).concat(
      (16).map(i => [["part", i] = Voice.patchTransform(i) }
      (2).map(i => [["bank", i] = Voice.bankTransform(i) }
    ),
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
