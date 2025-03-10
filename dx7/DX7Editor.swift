
//public protocol DX7StyleEditor : SingleDocSynthEditor {
//  var channel: Int { get }
//}
//
//class DX7Editor : SingleDocSynthEditor, DX7StyleEditor {
//  
//  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }
//
//  required init(baseURL: URL) {
//    let map: [SynthPath:Sysexible.Type] = [
//      [.global] : ChannelSettingsPatch.self,
//      [.patch] : DX7Patch.self,
//      [.bank] : DX7VoiceBank.self,
//    ]
//
//    let migrationMap: [SynthPath:String] = [
//      [.global] : "Global.json",
//      [.patch] : "Voice.syx",
//      [.bank] : "Voice Bank.syx",
//    ]
//
//    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
//  }
//  
//  // MARK: MIDI I/O
//  
//  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
//    var fetchBytes: [UInt8] = [0xf0, 0x43, 0x20 + UInt8(channel)]
//    switch path[0] {
//    case .patch:
//      fetchBytes.append(0x00)
//    case .bank:
//      fetchBytes.append(0x09)
//    default:
//      return nil
//    }
//    fetchBytes.append(0xf7)
//    return [.request(Data(fetchBytes))]
//  }
//  
//  override func midiOuts() -> [Observable<[Data]?>] {
//    var midiOuts = [Observable<[Data]?>]()
//    
//    midiOuts.append(voice(input: patchStateManager([.patch])!.typedChangesOutput()))
//    
//    midiOuts.append(GenericMidiOut.wholeBank(input: bankStateManager([.bank])!.output, bankTransform: {
//      guard let bank = $0 as? DX7VoiceBank else { return nil }
//      return [bank.sysexData(channel: self.channel)]
//    }))
//
//    return midiOuts
//  }
//  
//  override func midiChannel(forPath path: SynthPath) -> Int {
//    return channel
//  }
//  
//  override func bankPaths(forPatchType: SysexPatch.Type) -> [SynthPath] {
//    return [[.bank]]
//  }
//  
//  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
//    return ["Voice Bank"]
//  }
//  
//}
//
//public extension DX7StyleEditor {
//  
//  /// Transform <channel, patchChange, patch> into MIDI out data
//  func voice(input: Observable<(PatchChange,DX7Patch, Bool)>) -> Observable<[Data]?> {
//    
//    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { [weak self] (patch, path, value) -> [Data]? in
//      guard let param = type(of: patch).params[path] else { return nil }
//      guard let self = self else { return nil }
//      return [self.paramData(param: param, patch: patch)]
//      
//    }, patchTransform: { [weak self] (patch) -> [Data]? in
//      guard let self = self else { return nil }
//      return [patch.sysexData(channel: self.channel)]
//
//    }) { [weak self] (patch, path, name) -> [Data]? in
//      guard let self = self else { return nil }
//      return self.voiceNameData(patch: patch)
//
//    }
//  }
//  
//  func paramData(param: Param, patch: DX7Patch) -> Data {
//    if param.parm == 155 {
//      // op on/off
//      let v = (0..<6).map {
//        guard patch[[.op, .i($0), .on]] == 1 else { return 0 }
//        return 1 << (5 - $0)
//        }.reduce(0,+)
//      return paramData(paramAddress: 155, value: UInt8(v))
//    }
//    else {
//      return paramData(paramAddress: param.byte, value: patch.bytes[param.byte])
//    }
//  }
//  
//  func paramData(paramAddress: Int, value: UInt8) -> Data {
//    return Data([0xf0, 0x43, 0x10 + UInt8(channel), UInt8(paramAddress) >> 7, UInt8(paramAddress) & 0x7f, value, 0xf7])
//  }
//
//  
//  func voiceNameData(patch: DX7Patch) -> [Data] {
//    return DX7Patch.nameByteRange.map {
//      paramData(paramAddress: $0, value: patch.bytes[$0])
//      }
//  }
//  
//}
//
