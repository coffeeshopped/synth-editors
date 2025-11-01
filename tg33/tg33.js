

const fetch = cmdBytes => ['truss', ['yamFetch', 'channel', cmdBytes]]
const fetchWithHeader = header => fetch([0x7e, ['enc', `LM  ${header}`]])

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
    ["patch", fetchWithHeader("0012VE")],
    ["bank", fetchWithHeader("0012VC")],
    ["multi", fetchWithHeader("0012ME")],
    ["multi/bank", fetchWithHeader("0012MU")],
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
