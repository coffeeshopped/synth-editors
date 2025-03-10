
//class VolcaFMEditor : SingleDocSynthEditor {
//  
//  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }
//
//  required init(baseURL: URL) {
//    let map: [SynthPath:Sysexible.Type] = [
//      [.global] : ChannelSettingsPatch.self,
//      [.patch] : VolcaFMPatch.self,
//      [.bank] : VolcaFMVoiceBank.self,
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
//    
//  // MARK: MIDI I/O
//  
//  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
//    switch path[0] {
//    case .patch:
//      // always fetching on channel 0
//      return [.request(Data([0xf0, 0x43, 0x20, 0x00, 0xf7]))]
//    case .bank:
//      return [.request(Data([0xf0, 0x43, 0x20, 0x09, 0xf7]))]
//    default:
//      return nil
//    }
//  }
//
//  override func midiOuts() -> [Observable<[Data]?>] {
//    var midiOuts = [Observable<[Data]?>]()
//    
//    midiOuts.append(GenericMidiOut.wholePatchChange(throttle: .milliseconds(300), input: patchStateManager([.patch])!.output, patchTransform: {
//      // send note off on channel 0 after (user said that's needed to get it to respond to CC's?)
//      guard let patch = $0 as? VolcaFMPatch else { return nil }
//      return [patch.sysexData(channel: 0), Data([0x80, 0x40, 0])]
//    }))
//
//    // I *think* channel should always be zero here
//    midiOuts.append(GenericMidiOut.wholeBank(input: bankStateManager([.bank])!.output, bankTransform: {
//      guard let bank = $0 as? VolcaFMVoiceBank else { return nil }
//      return [bank.sysexData(channel: 0)]
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
