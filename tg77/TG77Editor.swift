
class TG77Editor : SingleDocSynthEditor {
  
  var tempPan: Int = 0
  
  var deviceId: Int { return ((patch(forPath: [.global])?[[.deviceId]] ?? 0) + 15) % 16 }
  var channel: Int { return (patch(forPath: [.global])?[[.rcv, .channel]] ?? 0) % 16 }

  let voiceDocInput: Variable<PatchChange> = Variable<PatchChange>(.noop)
  var voiceDocSubscription: Disposable?
  
  // store 4 AFM and AWM elements for when structure switching happens
  var afmBackups = [[SynthPath:Int]](repeating: TG77VoicePatch().values(forElement: 0)!, count: 4)
  var awmBackups = [[SynthPath:Int]](repeating: TG77VoicePatch().values(forElement: 1)!, count: 4)

  class var map: [SynthPath:Sysexible.Type] {
    return [
      [.global] : TG77SystemPatch.self,
      [.patch] : TG77VoicePatch.self,
      [.bank] : TG77VoiceBank.self,
      [.multi] : TG77MultiPatch.self,
      [.multi, .bank] : TG77MultiBank.self,
      [.pan] : TG77PanPatch.self,
      [.pan, .bank] : TG77PanBank.self,
    ]
  }

  required init(baseURL: URL) {
    let migrationMap: [SynthPath:String] = [
      [.global] : "System.syx",
      [.patch] : "Voice.syx",
      [.bank] : "Voice Bank.syx",
      [.multi] : "Multi.syx",
      [.multi, .bank] : "Multi Bank.syx",
      [.pan] : "Pan.syx",
      [.pan, .bank] : "Pan Bank.syx",
    ]

    super.init(baseURL: baseURL, sysexMap: Self.map, migrationMap: migrationMap)
    
    load { [weak self] in
      self?.initVoiceDocSubscription()
      self?.initPerfParamsOutput()

      guard let protect = self?.patch(forPath: [.global])?[[.protect]],
        protect == 0 else { return }
      
      // delay so that midi is set up
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        self?.changePatch(forPath: [.global], .paramsChange([[.protect] : 0]), transmit: true)
      }
    }
  }
  
  
  deinit {
    voiceDocSubscription?.dispose()
  }
  
  func initVoiceDocSubscription() {
    voiceDocSubscription = voiceDocInput.asObservable().subscribe(onNext: { [weak self] in
      guard let self = self,
        let voiceManager = self.patchStateManager([.patch]) else { return }
      
      // if a structure change is happening, store old patch before patch changes are applied
      let backupElements: Bool
      switch $0 {
      case .paramsChange(let change):
        backupElements = change[[.structure]] != nil
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
          else if $0.key == [.structure],
            let newPatch = voiceManager.patch as? TG77VoicePatch {
            // structure change
            
            // set the appropriate elements
            var afmIndex = 0
            var awmIndex = 0
            var elemDict = [SynthPath:Int]()
            (0..<newPatch.elementCount).forEach { elem in
              if newPatch.isElementFM(elem) {
                elemDict.merge(new: self.afmBackups[afmIndex].prefixed([.element, .i(elem)]))
                afmIndex += 1
              }
              else {
                elemDict.merge(new: self.awmBackups[awmIndex].prefixed([.element, .i(elem)]))
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
              let path: SynthPath = [.fx, .chorus, .i(chorus), .param, .i(param)]
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
              let path: SynthPath = [.fx, .reverb, .i(reverb), .param, .i(param)]
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
    case [.patch]:
      voiceDocInput.value = change
    case [.pan]:
      guard case .paramsChange(let values) = change,
            let number = values[[.number]] else { return super.changePatch(forPath: path, change, transmit: transmit) }
      tempPan = number
      tempPanOut.onNext((.paramsChange([[.number] : number]), nil))
      fetch(forPath: [.pan])
    default:
      super.changePatch(forPath: path, change, transmit: transmit)
    }
  }
  
  override func patchChangesOutput(forPath path: SynthPath) -> Observable<(PatchChange, SysexPatch?)>? {
    guard path == [.pan] else { return super.patchChangesOutput(forPath: path) }
    return panPatchOutput
  }
  
  
  private var voiceParamsOutput: Observable<SynthPathParam>?
  private var perfParamsOutput: Observable<SynthPathParam>?
  private var panParamsOutput: Observable<SynthPathParam>?
  private var perfDisposeBag: DisposeBag?
  
  private var tempPanOut = PublishSubject<(PatchChange, SysexPatch?)>()
  private var panPatchOutput: Observable<(PatchChange, SysexPatch?)>?
    
  private func initPerfParamsOutput() {
    perfDisposeBag = DisposeBag()

    if let params = super.paramsOutput(forPath: [.multi]) {
      let bankOut = bankChangesOutput(forPath: [.bank])!
      let patchBankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: [.patch, .name])
      perfParamsOutput = Observable.merge([patchBankMap, params])
    }
    
    if let params = super.paramsOutput(forPath: [.patch]) {
      let bankOut = bankChangesOutput(forPath: [.pan, .bank])!
      let bankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: [.pan, .name])
      voiceParamsOutput = Observable.merge([bankMap, params])
    }

    if let params = super.paramsOutput(forPath: [.pan]) {
      let bankOut = bankChangesOutput(forPath: [.pan, .bank])!
      let bankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: [.pan, .name])
      panParamsOutput = Observable.merge([bankMap, params])
    }

    if let patchOut = super.patchChangesOutput(forPath: [.pan]) {
      panPatchOutput = Observable.merge(patchOut, tempPanOut)
    }
  }
  
  override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
    switch path {
    case [.patch]:
      return voiceParamsOutput
    case [.multi]:
      return perfParamsOutput
    case [.pan]:
      return panParamsOutput
    default:
      return super.paramsOutput(forPath: path)
    }
  }
  
  
  
  // MARK: MIDI I/O
  
  func fetchData(forHeader header: String, location: Int) -> Data {
    var data = Data([0xf0, 0x43, 0x20 + UInt8(deviceId), 0x7a])
    data.append(contentsOf: header.unicodeScalars.map { UInt8($0.value) })
    data.append(contentsOf: [UInt8](repeating: 0, count: 14))
    if location < 0 {
      data.append(contentsOf: [0x7f, 0x00, 0xf7])
    }
    else {
      data.append(contentsOf: [0x00, UInt8(location), 0xf7])
    }
    return data
  }

  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .global:
      return [.request(fetchData(forHeader: TG77SystemPatch.headerString, location: 0))]
    case .patch:
      return [.request(fetchData(forHeader: "LM  8101VC", location: -1))]
    case .bank:
      return [RxMidi.FetchCommand]((0..<64).map {
        return [.request(fetchData(forHeader: "LM  8101VC", location: $0)),
                .wait(0.2)]
        }.joined())
    case .multi:
      if path.count == 1 {
        return [.request(fetchData(forHeader: "LM  8101MU", location: -1)),
                .request(fetchData(forHeader: "LM  8104MU", location: -1))]
      }
      else {
        return [RxMidi.FetchCommand]((0..<16).map {
          return [.request(fetchData(forHeader: "LM  8101MU", location: $0)),
                  .wait(0.2),
                  .request(fetchData(forHeader: "LM  8104MU", location: $0)),
                  .wait(0.2)]
          }.joined())
      }
    case .pan:
      if path.count == 1 {
        return [.request(fetchData(forHeader: TG77PanPatch.headerString, location: tempPan))]
      }
      else {
        return [RxMidi.FetchCommand]((0..<32).map {
          return [.request(fetchData(forHeader: TG77PanPatch.headerString, location: $0)),
                  .wait(0.2)]
          }.joined())
      }
    default:
      return nil
    }
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(system(input: patchStateManager([.global])!.typedChangesOutput()))
    midiOuts.append(voice(input: patchStateManager([.patch])!.typedChangesOutput()))
    midiOuts.append(multi(input: patchStateManager([.multi])!.typedChangesOutput()))
    midiOuts.append(pan(input: patchStateManager([.pan])!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank])!.output) {
      guard let patch = $0 as? TG77VoicePatch else { return nil }
      return [patch.sysexData(channel: self.deviceId, location: $1)]
    })

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.multi, .bank])!.output) {
      guard let patch = $0 as? TG77MultiPatch else { return nil }
      return [patch.sysexData(channel: self.deviceId, location: $1)]
    })

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.pan, .bank])!.output) {
      guard let patch = $0 as? TG77PanPatch else { return nil }
      return [patch.sysexData(channel: self.deviceId, location: $1)]
    })

    return midiOuts
  }

  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }

  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is TG77VoicePatch.Type:
      return [[.bank]]
    case is TG77MultiPatch.Type, is TG77MultiCommonPatch.Type:
      return [[.multi, .bank]]
    case is TG77PanPatch.Type:
      return [[.pan, .bank]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is TG77VoicePatch.Type:
      return ["Voice Bank"]
    case is TG77MultiPatch.Type, is TG77MultiCommonPatch.Type:
      return ["Multi Bank"]
    case is TG77PanPatch.Type:
      return ["Pan Bank"]
    default:
      return []
    }
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    switch path[0] {
    case .bank:
      let banks = ["A","B","C","D"]
      return { "\(banks[$0 / 16])\(($0 % 16) + 1)" }
    default:
      // multi, pan
      return { "\($0+1)" }
    }
  }
}

extension TG77Editor {
  
  func voice(input: Observable<(PatchChange, TG77VoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] as? TG33Param else { return nil }
      
      let v: Int
      if param.byte < 0 {
        // op on
        guard let el = path.i(1) else { return nil }
        v = (0..<6).map {
          guard patch[[.element, .i(el), .fm, .op, .i($0), .on]] == 1 else { return 0 }
          return 1 << (5 - $0)
          }.reduce(0, +)
      }
      else if value < 0 {
        let upper = (param as? ParamWithRange)?.range.upperBound ?? 0
        v = -value + upper + 1
      }
      else if param.parm2 == 0x0019 && param.byte > 25 {
        // phase is weird
        var byteIndex = patch.byteIndex(forPath: path)
        if param.bits != nil { byteIndex -= 1 }
        v = Int(((patch.bytes[byteIndex] & 1) << 7) + patch.bytes[byteIndex + 1])
      }
      else if param.bits != nil {
        // grab the whole byte from the patch instead
        let byteIndex = patch.byteIndex(forPath: path)
        let b = param.length == 2 ? ((patch.bytes[byteIndex] & 0x1) << 7) + patch.bytes[byteIndex+1] : patch.bytes[byteIndex]
        v = Int(b)
      }
      else {
        v = value
      }
      return [self.paramData(param: param, value: v)]
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.deviceId)]
      
    }, nameTransform: { (patch, path, name) -> [Data]? in
      return TG77VoicePatch.nameByteRange.map {
        self.paramData(parm: 0x0200, parm2: Int($0), value: Int(patch.bytes[$0]))
        }

    })
    
  }
  
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

  
  
  //  private static func voiceNameData(channel: Int, patch: TX81ZVCEDPatch) -> Data {
  //    return TX81ZVCEDPatch.nameByteRange.map {
  //      vcedParamData(channel: channel, paramAddress: $0, value: patch.bytes[$0])
  //      }.reduce(Data(), +)
  //  }
  
  func multi(input: Observable<(PatchChange, TG77MultiPatch, Bool)>) -> Observable<[Data]?> {

    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).param(path) as? TG33Param else { return nil }
      
      let v: Int
      if param.bits != nil {
        // grab the whole byte from the patch instead
        let byteIndex = param.byte
        let p = patch.subpatches[[.common]] as! TG77MultiCommonPatch
        let b = param.length == 2 ? ((p.bytes[byteIndex] & 0x1) << 7) + p.bytes[byteIndex+1] : p.bytes[byteIndex]
        v = Int(b)
      }
      else {
        v = value
      }
      return [self.paramData(param: param, value: v)]

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.deviceId)]
      
    }, nameTransform: { (patch, path, name) -> [Data]? in
      // TODO: this
      return nil
    })

  }

  func multiCommon(input: Observable<(PatchChange, TG77MultiCommonPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).param(path) as? TG33Param else { return nil }
      
      let v: Int
      if param.bits != nil {
        // grab the whole byte from the patch instead
        let byteIndex = param.byte
        let b = param.length == 2 ? ((patch.bytes[byteIndex] & 0x1) << 7) + patch.bytes[byteIndex+1] : patch.bytes[byteIndex]
        v = Int(b)
      }
      else {
        v = value
      }
      return [self.paramData(param: param, value: v)]
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.deviceId)]
      
    }, nameTransform: { (patch, path, name) -> [Data]? in
      // TODO: this
      return nil
    })
    
  }
  
  func pan(input: Observable<(PatchChange, TG77PanPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] as? TG33Param else { return nil }
      
      let parm = 0x0a00 + self.tempPan
      return [self.paramData(parm: parm, parm2: param.parm2, value: value)]
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.deviceId, location: self.tempPan)]
      
    }, nameTransform: { (patch, path, name) -> [Data]? in
      let parm = 0x0a00 + self.tempPan
      return name.bytes(forCount: 10).enumerated().map {
        self.paramData(parm: parm, parm2: Int($0.offset) + 0x11, value: Int($0.element))
        }
    })
    
  }

  func system(input: Observable<(PatchChange, TG77SystemPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] as? TG33Param else { return nil }
      return [self.paramData(param: param, value: value)]

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.deviceId)]
      
    }, nameTransform: { (patch, path, name) -> [Data]? in
      // TODO: this
      return nil
    })
  }
}
