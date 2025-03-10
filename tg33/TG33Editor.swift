
class TG33Editor : SingleDocSynthEditor {
  
  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : ChannelSettingsPatch.self,
      [.patch] : TG33VoicePatch.self,
      [.bank] : TG33VoiceBank.self,
      [.multi] : TG33MultiPatch.self,
      [.multi, .bank] : TG33MultiBank.self,
    ]

    let migrationMap: [SynthPath:String] = [
      [.global] : "Global.json",
      [.patch] : "Voice.syx",
      [.bank] : "Voice Bank.syx",
      [.multi] : "Multi.syx",
      [.multi, .bank] : "Multi Bank.syx",
    ]

    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
  }

  // MARK: MIDI I/O
  
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
    return [.request(data)]
  }
  
  private var perfParamsOutput: Observable<SynthPathParam>?
  private var paramsDisposeBag: DisposeBag?
    
  private func initPerfParamsOutput() {
    guard let origPerfParams = super.paramsOutput(forPath: [.multi]),
          let bankOut = bankChangesOutput(forPath: [.bank]) else { return }
    
    paramsDisposeBag = DisposeBag()
    let bankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: [.patch, .name])
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
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(voice(input: patchStateManager([.patch])!.typedChangesOutput()))
    
    midiOuts.append(GenericMidiOut.wholeBank(input: bankStateManager([.bank])!.output, bankTransform: {
      guard let bank = $0 as? ChannelizedSysexible else { return nil }
      return [bank.sysexData(channel: self.channel)]
    }))

    midiOuts.append(multi(input: patchStateManager([.multi])!.typedChangesOutput()))
    
    midiOuts.append(GenericMidiOut.wholeBank(input: bankStateManager([.multi, .bank])!.output, bankTransform: {
      guard let bank = $0 as? ChannelizedSysexible else { return nil }
      return [bank.sysexData(channel: self.channel)]
    }))

    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is TG33VoicePatch.Type:
      return [[.bank]]
    case is TG33MultiPatch.Type:
      return [[.multi, .bank]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is TG33VoicePatch.Type:
      return ["Voice Bank"]
    case is TG33MultiPatch.Type:
      return ["Multi Bank"]
    default:
      return []
    }
  }
  
}

extension TG33Editor {
  
  func voice(input: Observable<(PatchChange, TG33VoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] as? TG33Param else { return nil }
      
      // HIDDEN PARAMS
      guard param.parm > 0 else { return [patch.sysexData(channel: self.channel)] }
      
      let adds = RolandAddress(param.parm).sysexBytes(count: 3) +
        RolandAddress(param.parm2).sysexBytes(count: 2)
      var v1 = UInt8((value >> 7) & 0x7f)
      var v2 = UInt8(value & 0x7f)
      var preST: UInt8
      var postST: UInt8
      switch path[0] {
      case .common:
        preST = 0x00
        postST = 0x00
        
        if path.last == .mod {
          v2 = v2 << param.bits!.lowerBound
        }
      case .vector:
        preST = 0x01
        postST = 0x00
      case .element:
        guard let i = path.i(1) else { return nil }
        if path[2] == .env {
          preST = 0x03
          postST = UInt8(i)
          
          if path.last == .delay {
            v1 = value == 0 ? 0 : 1
            v2 = 0
          }
        }
        else {
          preST = 0x02
          postST = UInt8(i)
        }
        
        if path.last == .aftertouch || path.last == .env {
          if value < 0 {
            let v = Int(UInt8(bitPattern: Int8(value))) << param.bits!.lowerBound
            v1 = 0
            v2 = UInt8(v & 0x7f)
          }
          else {
            v2 = v2 << param.bits!.lowerBound
          }
        }
        else if path.last == .velo {
          if value < 0 {
            v2 = UInt8(0x0b + value)
          }
        }
      default:
        return nil
      }
      return [Data([0xf0, 0x43, 0x10 + UInt8(self.channel), 0x26, preST, adds[0], postST, adds[1], adds[2], adds[3], adds[4], v1, v2, 0xf7])]

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]
      
    }, nameTransform: { (patch, path, name) -> [Data]? in
      // TODO: this
      return nil
    })
    
  }
  
  func multi(input: Observable<(PatchChange, TG33MultiPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      
      // HIDDEN PARAMS
      guard param.parm > 0 else { return [patch.sysexData(channel: self.channel)] }
      
      let adds = RolandAddress(param.parm).sysexBytes(count: 5)
      let v1 = UInt8((value >> 7) & 0x7f)
      let v2 = UInt8(value & 0x7f)
      var postST: UInt8
      switch path[0] {
      case .part:
        guard let i = path.i(1) else { return nil }
        postST = UInt8(i)
      default:
        postST = 0
      }
      return [Data([0xf0, 0x43, 0x10 + UInt8(self.channel), 0x26, 0x04, adds[0], postST, adds[1], adds[2], adds[3], adds[4], v1, v2, 0xf7])]
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]
      
    }, nameTransform: { (patch, path, name) -> [Data]? in
      // TODO: this
      return nil
    })
    
  }
  
}
