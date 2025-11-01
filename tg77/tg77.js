

const fetch = cmdBytes => ['truss', ['yamFetch', 'channel', cmdBytes]]
const fetchWithHeader = (header, bytes) => fetch([0x7a, 
  ['enc', `LM  ${header}`],
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  bytes, 0xf7
])
const fetchTemp = (header) => fetchWithHeader(header, [0x7f, 0x00])
const fetchLocation = (header, loc) => fetchWithHeader(header, [0x00, loc])
const fetchBank = (header) => ['bankTruss', [
  fetchLocation(header, 'b'),
  ['wait', 200],
]]]

const editor = {
  name: "",
  trussMap: [
    ["global", System.patchTruss],
    ["patch", Voice.patchTruss],
    ["bank", Voice.bankTruss],
    ["multi", Multi.patchTruss],
    ["multi/bank", Multi.bankTruss],
    ["pan", Pan.patchTruss],
    ["pan/bank", Pan.bankTruss],
  ],
  fetchTransforms: [    
    ["global", fetchLocation("8101SY", 0)],
    ["patch", fetchTemp("8101VC")],
    ["bank", fetchBank("8101VC")],
    // just sending the request for the "common" patch triggers dump of common + extra on TG77
    ["multi", fetchTemp("8101MU")],
    ["multi/bank", fetchBank("8101MU")],
    ["pan", fetchLocation("8101PN", tempPan)],
    ["pan/bank", ['bankTruss', fetchBank("8101PN")],
  ],

  midiOuts: [
    ["global", System.patchTransform],
    ["patch", Voice.patchTransform],
    ["bank", Voice.bankTransform],
    ["multi", Multi.patchTransform],
    ["multi/bank", Multi.bankTransform],
    ["pan", Pan.patchTransform],
    ["pan/bank", Pan.bankTransform],
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
    ['bank', ['user', i => {
      const banks = ["A","B","C","D"]
      return `${banks[i / 16]}${(i % 16) + 1}`
    }]],
    ['multi/bank', 'userZeroToOne'],
    ['multi/pan', 'userZeroToOne'],
  ],

}



class TG77Editor : SingleDocSynthEditor {
  
  var tempPan: Int = 0
  
  var deviceId: Int { return ((patch(forPath: "global")?["deviceId"] ?? 0) + 15) % 16 }
  var channel: Int { return (patch(forPath: "global")?["rcv/channel"] ?? 0) % 16 }

  let voiceDocInput: Variable<PatchChange> = Variable<PatchChange>(.noop)
  var voiceDocSubscription: Disposable?
  
  // store 4 AFM and AWM elements for when structure switching happens
  var afmBackups = [[SynthPath:Int]](repeating: TG77VoicePatch().values(forElement: 0)!, count: 4)
  var awmBackups = [[SynthPath:Int]](repeating: TG77VoicePatch().values(forElement: 1)!, count: 4)

  required init(baseURL: URL) {
    load { [weak self] in
      guard let protect = self?.patch(forPath: "global")?["protect"],
        protect == 0 else { return }
      
      // delay so that midi is set up
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        self?.changePatch(forPath: "global", .paramsChange(["protect" : 0]), transmit: true)
      }
    }
  }
    
  func initVoiceDocSubscription() {
    voiceDocSubscription = voiceDocInput.asObservable().subscribe(onNext: { [weak self] in
      guard let self = self,
        let voiceManager = self.patchStateManager("patch") else { return }
      
      // if a structure change is happening, store old patch before patch changes are applied
      let backupElements: Bool
      switch $0 {
      case .paramsChange(let change):
        backupElements = change["structure"] != nil
      case .replace:
        backupElements = true
      default:
        backupElements = false
      }
      
      if backupElements,
        let oldPatch = voiceManager.patch as? TG77VoicePatch {
        // make backups of the current elements
        var afmIndex = 0
        var awmIndex = 0
        (0..<oldPatch.elementCount).forEach { elem in
          guard let vals = oldPatch.values(forElement: elem) else { return }
          if oldPatch.isElementFM(elem) {
            self.afmBackups[afmIndex] = vals
            afmIndex += 1
          }
          else {
            self.awmBackups[awmIndex] = vals
            awmIndex += 1
          }
        }
      }
      
      // apply the patch changes
      voiceManager.patchChangesInput.value = ($0, true)
      
      // do anything that should happen as a reaction to param changes (the stuff the synth does internally)
      switch $0 {
      case .paramsChange(let change):
        change.forEach {
          if $0.key.last == .algo,
            // algorithm change
            let elem = $0.key.i(1),
            let pc = TG77VoicePatch.paramChange(forElement: elem, algorithm: $0.value) {
            voiceManager.patchChangesInput.value = (pc, true)
          }
          else if $0.key == "structure",
            let newPatch = voiceManager.patch as? TG77VoicePatch {
            // structure change
            
            // set the appropriate elements
            var afmIndex = 0
            var awmIndex = 0
            var elemDict = [SynthPath:Int]()
            (0..<newPatch.elementCount).forEach { elem in
              if newPatch.isElementFM(elem) {
                elemDict.merge(new: self.afmBackups[afmIndex].prefixed("element/elem"))
                afmIndex += 1
              }
              else {
                elemDict.merge(new: self.awmBackups[awmIndex].prefixed("element/elem"))
                awmIndex += 1
              }
            }
            voiceManager.patchChangesInput.value = (MakeParamsChange(elemDict), true)

            // TODO: need to store drum set data too, really
          }
          else if $0.key.last == .type && $0.key[1] == .chorus,
            $0.value < TG77VoicePatch.chorusParamDefaults.count,
            let chorus = $0.key.i(2) {
            // chorus type change

            let chorusType = $0.value
            var dict = [SynthPath:Int]()
            (0..<4).forEach { param in
              let path: SynthPath = "fx/chorus/chorus/param/param"
              dict[path] = TG77VoicePatch.chorusParamDefaults[chorusType][param]
            }
            voiceManager.patchChangesInput.value = (MakeParamsChange(dict), true)
          }
          else if $0.key.last == .type && $0.key[1] == .reverb,
            $0.value < TG77VoicePatch.reverbParamDefaults.count,
            let reverb = $0.key.i(2) {
            // reverb type change
            
            let reverbType = $0.value
            var dict = [SynthPath:Int]()
            (0..<3).forEach { param in
              let path: SynthPath = "fx/reverb/reverb/param/param"
              dict[path] = TG77VoicePatch.reverbParamDefaults[reverbType][param]
            }
            voiceManager.patchChangesInput.value = (MakeParamsChange(dict), true)
          }
        }
      default:
        break
      }
    })
  }
  
  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    switch path {
    case "patch":
      voiceDocInput.value = change
    case "pan":
      guard case .paramsChange(let values) = change,
            let number = values["number"] else { return super.changePatch(forPath: path, change, transmit: transmit) }
      tempPan = number
      tempPanOut.onNext((.paramsChange(["number" : number]), nil))
      fetch(forPath: "pan")
    default:
      super.changePatch(forPath: path, change, transmit: transmit)
    }
  }
  
  override func patchChangesOutput(forPath path: SynthPath) -> Observable<(PatchChange, SysexPatch?)>? {
    guard path == "pan" else { return super.patchChangesOutput(forPath: path) }
    return panPatchOutput
  }
      
  private func initPerfParamsOutput() {
    perfDisposeBag = DisposeBag()

    if let params = super.paramsOutput(forPath: "multi") {
      let bankOut = bankChangesOutput(forPath: "bank")!
      let patchBankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: "patch/name")
      perfParamsOutput = Observable.merge([patchBankMap, params])
    }
    
    if let params = super.paramsOutput(forPath: "patch") {
      let bankOut = bankChangesOutput(forPath: "pan/bank")!
      let bankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: "pan/name")
      voiceParamsOutput = Observable.merge([bankMap, params])
    }

    if let params = super.paramsOutput(forPath: "pan") {
      let bankOut = bankChangesOutput(forPath: "pan/bank")!
      let bankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: "pan/name")
      panParamsOutput = Observable.merge([bankMap, params])
    }

    if let patchOut = super.patchChangesOutput(forPath: "pan") {
      panPatchOutput = Observable.merge(patchOut, tempPanOut)
    }
  }
  
  override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
    switch path {
    case "patch":
      return voiceParamsOutput
    case "multi":
      return perfParamsOutput
    case "pan":
      return panParamsOutput
    default:
      return super.paramsOutput(forPath: path)
    }
  }

}

extension TG77Editor {
  
  private func paramData(param: TG33Param, value: Int) -> Data {
    return paramData(parm: param.parm, parm2: param.parm2, value: value)
  }
  
  private func paramData(parm: Int, parm2: Int, value: Int) -> Data {
    let t1 = UInt8(parm >> 8)
    let t2 = UInt8(parm & 0xff)
    let n1 = UInt8(parm2 >> 8)
    let n2 = UInt8(parm2 & 0xff)
    let v1 = UInt8((value >> 7) & 0x7f)
    let v2 = UInt8(value & 0x7f)
    return Data([0xf0, 0x43, 0x10 + UInt8(channel), 0x34, t1, t2, n1, n2, v1, v2, 0xf7])
  }
  
}
