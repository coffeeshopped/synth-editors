const Virus = require('./virus.js')

const editor = {
  name: "",
  trussMap: ([
    ["global", Global.patchTruss],
    ["patch", Voice.patchTruss],
    ["multi", Multi.patchTruss],
    ["multi/bank", Multi.bankTruss],
  ]).concat(
    (16).map(i => [["part", i], Voice.patchTruss]),
    (2).map(i => [["bank", i], Voice.bankTruss])
  ),
  fetchTransforms: [
    ["global", Virus.fetchCmd([0x35])],
    ["patch", Virus.fetchCmd([0x30, 0x00, 0x40])],
    ["multi", Virus.fetchCmd([0x31, 0x00, 0x00])],
    ["multi/bank", Virus.fetchCmd([0x33, 0x01])],
  ]).concat(
    (16).map(i => [["part", i], Virus.fetchCmd([0x30, 0x00, i])]),
    (2).map(i => [["bank", i], Virus.fetchCmd([0x32, i + 1])])
  ),

  midiOuts: [
    ([
      ["global", Global.patchTransform],
      ["patch", Voice.patchTransform(0x40)],
      ["multi", Multi.patchTransform],
      ["multi/bank", Multi.bankTransform],
    ]).concat(
      (16).map(i => [["part", i], Voice.patchTransform(i)]),
      (2).map(i => [["bank", i], Voice.bankTransform(i)])
    ),
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: ([
    ["multi/bank", 'direct'],
  ]).concat(
    (2).map(i => [["bank", i], ['user', x => {
      const b = ["A", "B"][i]
      return `${b}${x}`
    }]])
  ),
}



class VirusCEditor : SingleDocSynthEditor, VirusEditor {
  
//  override var sendInterval: TimeInterval { return 0.2 }
  
    
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


}
