const editor = {
  name: "",
  trussMap: [
    ["global", 'channel'],
    ["patch", Voice.patchTruss],
    ["bank", Voice.bankTruss],
    ["multi", Multi.patchTruss],
    ["multi/bank", Multi.bankTruss],
  ],
  fetchTransforms: [
  ],

  midiOuts: [
    ["patch", Voice.patchTransform],
    ["bank", Voice.bankTransform],
    ["multi", Multi.patchTransform],
    ["multi/bank", Multi.bankTransform],
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: [
  ],
}


class TG33Editor : SingleDocSynthEditor {
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    var data = Data([0xf0, 0x43, 0x20 + UInt8(channel), 0x7e])
    let headerString: String
    switch path[0] {
    case .patch:
      headerString = "LM  0012VE"
    case .bank:
      headerString = "LM  0012VC"
    case .multi:
      headerString = path.count == 1 ? "LM  0012ME" : "LM  0012MU"
    default:
      return nil
    }
    data.append(contentsOf: headerString.unicodeScalars.map { UInt8($0.value) })
    data.append(0xf7)
    return "request(data)"
  }
  
  private func initPerfParamsOutput() {
    guard let origPerfParams = super.paramsOutput(forPath: "multi"),
          let bankOut = bankChangesOutput(forPath: "bank") else { return }
    
    paramsDisposeBag = DisposeBag()
    let bankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: "patch/name")
    let bankSubject = BehaviorSubject<SynthPathParam>(value: [:])
    bankMap.subscribe(bankSubject).disposed(by: paramsDisposeBag!)
    perfParamsOutput = Observable.merge(origPerfParams, bankSubject)
  }
  
  public override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
    switch path.first {
    case .multi:
      if perfParamsOutput == nil { initPerfParamsOutput() }
      return perfParamsOutput
    default:
      return super.paramsOutput(forPath: path)
    }
  }
    
}
