
//public protocol TX802StyleEditor : DX7StyleEditor {
//  
//}
//
//public class TX802Editor : SingleDocSynthEditor, TX802StyleEditor {
//  
//  var deviceId: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }
//  public var channel: Int { return deviceId }
//
//  public override init(baseURL: URL, sysexMap: [SynthPath : Sysexible.Type], migrationMap: [SynthPath : String]? = nil) {
//    super.init(baseURL: baseURL, sysexMap: sysexMap, migrationMap: migrationMap)
//  }
//  
//  required init(baseURL: URL) {
//    let map: [SynthPath:Sysexible.Type] = [
//      [.global] : ChannelSettingsPatch.self,
//      [.patch] : TX802VoicePatch.self,
//      [.perf] : TX802PerfPatch.self,
//      [.bank, .i(0)] : TX802VoiceBank.self,
//      [.bank, .i(1)] : TX802VoiceBank.self,
//      [.perf, .bank] : TX802PerfBank.self,
//    ]
//
//    let migrationMap: [SynthPath:String] = [
//      [.global] : "Global.json",
//      [.patch] : "Voice.syx",
//      [.perf] : "Performance.syx",
//      [.bank, .i(0)] : "Voice Bank 1.syx",
//      [.bank, .i(1)] : "Voice Bank 2.syx",
//      [.perf, .bank] : "Perf Bank.syx",
//    ]
//
//    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
//  }
//  
//  // MARK: MIDI I/O
//  
//  public override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
//    switch path[0] {
//    case .patch:
//      // request ACED, then VCED
//      return [
//        .request(Data([0xf0, 0x43, 0x20 + UInt8(deviceId), 0x05, 0xf7])),
//        .request(Data([0xf0, 0x43, 0x20 + UInt8(deviceId), 0x00, 0xf7]))
//      ]
//    case .perf:
//      var bytes = [0xf0, 0x43, 0x20 + UInt8(deviceId), 0x7e]
//      // perf, or bank?
//      let fetchString = path.count == 1 ? "LM  8952PE" : "LM  8952PM"
//      bytes.append(contentsOf: fetchString.unicodeScalars.map { UInt8($0.value) })
//      bytes.append(0xf7)
//      return [.request(Data(bytes))]
//    case .bank:
//      guard let bank = path.i(1) else { return nil }
//      return type(of: self).bankFetchCommands(deviceId: deviceId, bank: bank)
//    default:
//      return nil
//    }
//  }
//  
//  public static func bankFetchCommands(deviceId: Int, bank: Int) -> [RxMidi.FetchCommand] {
//    return [
//      // first tell which bank we want
//      .send(Data([0xf0, 0x43, 0x10 + UInt8(deviceId), 0x19, 0x4d, UInt8(bank), 0xf7])),
//      .wait(0.1),
//      .request(Data([0xf0, 0x43, 0x20 + UInt8(deviceId), 0x06, 0xf7])),
//      .request(Data([0xf0, 0x43, 0x20 + UInt8(deviceId), 0x09, 0xf7]))
//    ]
//  }
//  
//  public override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
//    guard path == [.patch], case .paramsChange(let values) = change else {
//      return super.changePatch(forPath: path, change, transmit: transmit)
//    }
//    var newValues = [SynthPath:Int]()
//    // route .voice ... .amp, .mod to .extra .amp, .mod bc of the way we made the ctrlr
//    values.forEach {
//      if $0.key.first == .voice && $0.key.suffix(2) == [.amp, .mod] {
//        newValues[[.extra] + $0.key[1..<$0.key.count]] = $0.value
//      }
//      else {
//        newValues[$0.key] = $0.value
//      }
//    }
//    super.changePatch(forPath: path, .paramsChange(SynthPathIntsMake(newValues)), transmit: transmit)
//  }
//
//  public override func midiOuts() -> [Observable<[Data]?>] {
//    var midiOuts = [Observable<[Data]?>]()
//
//    // put aced first since it should be sent first.
//    let voiceOut: Observable<(PatchChange, TX802VoicePatch, Bool)> = patchStateManager([.patch])!.typedChangesOutput()
//    let extraIn: Observable<(PatchChange, TX802ACEDPatch, Bool)> = voiceOut.map {
//      // this will effectively split out just extra params
//      let pc = $0.0.filtered(forPrefix: [.extra])
//      return (pc, $0.1.subpatches[[.extra]] as! TX802ACEDPatch, $0.2)
//    }
//    midiOuts.append(extra(input: extraIn))
//
//    let voiceIn: Observable<(PatchChange, DX7Patch, Bool)> = voiceOut.map {
//      // this will effectively split out just voice params
//      let pc = $0.0.filtered(forPrefix: [.voice])
//      return (pc, $0.1.subpatches[[.voice]] as! DX7Patch, $0.2)
//    }
//    midiOuts.append(voice(input: voiceIn))
//
//    midiOuts.append(perf(input: patchStateManager([.perf])!.typedChangesOutput()))
//
//    (0..<2).forEach { i in
//      midiOuts.append(GenericMidiOut.wholeBank(input: bankStateManager([.bank, .i(i)])!.output, bankTransform: { [unowned self] in
//        guard let b = $0 as? DX7IIishVoiceBank else { return nil }
//        return b.sysexDataArray(channel: self.channel, bank: i)
//      }))
//    }
//    
//    midiOuts.append(GenericMidiOut.wholeBank(input: bankStateManager([.perf, .bank])!.output, bankTransform: {
//      guard let bank = $0 as? TX802PerfBank else { return nil }
//      return [bank.sysexData(channel: self.deviceId)]
//    }))
//
//    return midiOuts
//  }
//  
//  private var perfParamsOutput: Observable<SynthPathParam>?
//  private var paramsDisposeBag: DisposeBag?
//    
//  private func initPerfParamsOutput() {
//    guard let origPerfParams = super.paramsOutput(forPath: [.perf]) else { return }
//    
//    paramsDisposeBag = DisposeBag()
//
//    var obs = [origPerfParams]
//    (0..<2).forEach { bank in
//      guard let bankOut = bankChangesOutput(forPath: [.bank, .i(bank)]) else { return }
//      let bankMap = EditorHelper.bankNameOptionsMap(output: bankOut, path: [.patch, .name, .i(bank)]) {
//        let i = $0 + 1 + bank * 32
//        return "\(i): \($1)"
//      }
//      let bankSubject = BehaviorSubject<SynthPathParam>(value: [:])
//      bankMap.subscribe(bankSubject).disposed(by: paramsDisposeBag!)
//      obs.append(bankSubject)
//    }
//    perfParamsOutput = Observable.merge(obs)
//  }
//  
//  public override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
//    switch path.first {
//    case .perf:
//      if perfParamsOutput == nil { initPerfParamsOutput() }
//      return perfParamsOutput
//    default:
//      return super.paramsOutput(forPath: path)
//    }
//  }
//
//  
//  public override func midiChannel(forPath path: SynthPath) -> Int {
//    return deviceId
//  }
//  
//  public override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
//    switch patchType {
//    case is TX802VoicePatch.Type:
//      return [[.bank, .i(0)], [.bank, .i(1)]]
//    case is TX802PerfPatch.Type:
//      return [[.perf, .bank]]
//    default:
//      return []
//    }
//  }
//  
//  public override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
//    switch patchType {
//    case is TX802VoicePatch.Type:
//      return ["Voice Bank (1–32)", "Voice Bank (33–64)"]
//    case is TX802PerfPatch.Type:
//      return ["Perf Bank"]
//    default:
//      return []
//    }
//  }
//
//  public override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
//    switch path[0] {
//    case .bank:
//      guard let bankIndex = path.i(1) else { return nil }
//      let offset = bankIndex * 32 + 1
//      return { "\($0 + offset)" }
//    case .perf:
//      return { "\($0 + 1)" }
//    default:
//      return nil
//    }
//  }
//
//  
//}
//
//public extension TX802StyleEditor {
//    
//  /// Transform <channel, patchChange, patch> into MIDI out data
//  func extra(input: Observable<(PatchChange,TX802ACEDPatch, Bool)>) -> Observable<[Data]?> {
//    
//    return GenericMidiOut.patchChange(throttle: .milliseconds(30), input: input, paramTransform: { [weak self] (patch, path, value) -> [Data]? in
//      guard let param = type(of: patch).params[path] else { return nil }
//      guard let self = self else { return nil }
//      let paramAddress = param.parm > 0 ? param.parm : param.byte
//      return [self.acedParamData(paramAddress: paramAddress, value: patch.bytes[param.byte])]
//
//    }, patchTransform: { [weak self] (patch) -> [Data]? in
//      guard let self = self else { return nil }
//      return [patch.sysexData(channel: self.channel)]
//    })
//  }
//
//  func acedParamData(paramAddress: Int, value: UInt8) -> Data {
//    return Data([0xf0, 0x43, 0x10 + UInt8(channel), 0x18, UInt8(paramAddress), value, 0xf7])
//  }
//
//  /// Transform <channel, patchChange, patch> into MIDI out data
//  internal func perf(input: Observable<(PatchChange,TX802PerfPatch, Bool)>) -> Observable<[Data]?> {
//    
//    return GenericMidiOut.patchChange(throttle: .milliseconds(300), input: input, paramTransform: { [weak self] (patch, path, _) -> [Data]? in
//      guard let param = type(of: patch).params[path] else { return nil }
//      guard let self = self else { return nil }
//      let value = patch.bytes[param.byte]
//      if (16...23).contains(param.byte) || (88...95).contains(param.byte) {
//        return [Data([0xf0, 0x43, 0x10 + UInt8(self.channel), 0x1a, UInt8(param.byte),
//                     (value >> 7) & 0xf, value & 0x7f,
//                     0xf7])]
//      }
//      else {
//        return [patch.sysexData(channel: self.channel)]
////        return Data([0xf0, 0x43, 0x10 + UInt8(channel), 0x1a, UInt8(param.byte), value, 0xf7])
//      }
//
//    }, patchTransform: { [weak self] (patch) -> [Data]? in
//      guard let self = self else { return nil }
//      return [patch.sysexData(channel: self.channel)]
//
//    }) { [weak self] (patch, path, name) -> [Data]? in
//      // TODO: shouldn't this send?
//      guard let self = self else { return nil }
//      return [patch.sysexData(channel: self.channel)]
//
//    }
//  }
//  
//}
//
