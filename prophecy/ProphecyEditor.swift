
class ProphecyEditor : SingleDocSynthEditor {
    
  var channel: Int { patch(forPath: [.global])?[[.channel]] ?? 0 }
  var tempArp = 0

  required init(baseURL: URL) {
    super.init(baseURL: baseURL, sysexMap: [
      [.global] : ProphecyGlobalPatch.self,
      [.patch] : ProphecyVoicePatch.self,
      [.arp] : ProphecyArpPatch.self,
      [.bank, .patch, .i(0)] : ProphecyVoiceBank.self,
      [.bank, .patch, .i(1)] : ProphecyVoiceBank.self,
      [.bank, .arp] : ProphecyArpBank.self,
    ])    
  }
    
  // MARK: MIDI I/O

  private func fetchCommand(cmdBytes: [UInt8]) -> RxMidi.FetchCommand {
    return .request(Data(Prophecy.sysexHeader(deviceId: UInt8(channel)) + cmdBytes + [0xf7]))
  }
    
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case [.global]:
      return [fetchCommand(cmdBytes: [0x0e, 0x00])]
    case [.patch]:
      return [fetchCommand(cmdBytes: [0x10, 0x00])]
    case [.arp]:
      return [fetchCommand(cmdBytes: [0x34, UInt8(tempArp), 0x00])]
    case [.bank, .patch, .i(0)],
         [.bank, .patch, .i(1)]:
      guard let bank = path.i(2) else { return nil }
      return [fetchCommand(cmdBytes: [0x1c, 0x10 + UInt8(bank), 0x00, 0x00])]
    case [.bank, .arp]:
      return [fetchCommand(cmdBytes: [0x34, 0x10, 0x00])]
    default:
      return nil
    }
  }
  
  private var lastOscSelect = 0
  
  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    super.changePatch(forPath: path, change, transmit: transmit)

    switch path {
    case [.patch]:
      if case let .paramsChange(values) = change {
        values.forEach { pair in
          switch pair.key {
          case [.osc, .select]:
            let mode = pair.value
            let lastPair = lastOscSelect < ProphecyVoicePatch.oscPairs.count ? ProphecyVoicePatch.oscPairs[lastOscSelect] : ProphecyVoicePatch.oscPairs[0]
            guard mode < ProphecyVoicePatch.oscPairs.count else { return }
            let oscPair = ProphecyVoicePatch.oscPairs[mode]
            
            var v = [SynthPath:Int]()
            (0..<2).forEach {
              if lastPair[$0] != oscPair[$0],
                 let osc = oscPair[$0],
                 let defaults = ProphecyVoicePatch.oscDefaults[osc] {
                v.merge(new: defaults.prefixed([.osc, .i($0)]))
              }
            }
            if v.count > 0 {
              super.changePatch(forPath: [.patch], .paramsChange(SynthPathIntsMake(v)), transmit: false)
            }
            lastOscSelect = mode
          default:
            break
          }
        }
      }
      else if case let .replace(patch) = change {
        if let mode = patch[[.osc, .select]] {
          lastOscSelect = mode
        }
      }
    case [.arp]:
      guard case .paramsChange(let values) = change,
            let number = values[[.number]] else { return }
      tempArp = number
      fetch(forPath: path)
    default:
      break
    }
  }
  
//  private var tempArpOut = PublishSubject<(PatchChange, SysexPatch?)>()
//  private var arpPatchOutput: Observable<(PatchChange, SysexPatch?)>?
//
//  override func patchChangesOutput(forPath path: SynthPath) -> Observable<(PatchChange, SysexPatch?)>? {
//    guard path == [.arp] else { return super.patchChangesOutput(forPath: path) }
//    if arpPatchOutput == nil, let patchOut = super.patchChangesOutput(forPath: [.arp]) {
//      arpPatchOutput = Observable.merge(patchOut, tempArpOut)
//    }
//    return arpPatchOutput
//  }


////    comparator.check(path: path, change: change)
//  }
//
//  private let comparator = PatchComparator<Deepmind12VoicePatch>(path: [.patch])

//
//  override func sysexible(forPath path: SynthPath) -> Sysexible? {
//    // used by the overlay popup loader
//    guard path.starts(with: [.extra, .key]),
//          let overlayBank = sysexible(forPath: [.extra]) as? BassStationIIOverlayPatch,
//          let key = overlayBank.subpatches[path.subpath(from: 1)] as? BassStationIIOverlayKeyPatch else { return super.sysexible(forPath: path) }
//    return BassStationIIVoicePatch.fromOverlay(key)
//
//  }

  // make those big multi-msg pushes happen faster!
//  override var sendInterval: TimeInterval { return 0.01 }

  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(globalOut(input: patchStateManager([.global])!.typedChangesOutput()))
    midiOuts.append(voiceOut(input: patchStateManager([.patch])!.typedChangesOutput()))
    midiOuts.append(arpOut(input: patchStateManager([.arp])!.typedChangesOutput()))

    (0..<2).forEach { bank in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .patch, .i(bank)])!.output, patchTransform: {
        guard let patch = $0 as? ProphecyVoicePatch else { return nil }
        return [patch.sysexData(channel: self.channel, bank: bank, program: $1)]
      }))
    }

//    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .arp])!.output, patchTransform: {
//      guard let patch = $0 as? Deepmind12ArpPatch else { return nil }
//      return [patch.sysexData(channel: self.deviceId, program: $1)]
//    }))

    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is ProphecyVoicePatch.Type:
      return (0..<2).map { [.bank, .patch, .i($0)] }
    case is ProphecyArpPatch.Type:
      return [[.bank, .arp]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is ProphecyVoicePatch.Type:
      return (0..<2).map { "Voice Bank \(ProphecyVoiceBank.bankLetter($0))" }
    case is ProphecyArpPatch.Type:
      return ["Arp Bank"]
    default:
      return []
    }
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    switch path {
    case [.bank, .patch, .i(0)]:
      return { "A\($0)" }
    case [.bank, .patch, .i(1)]:
      return { "B\($0)" }
    default:
      return { "\($0 + 1)" }
    }
  }
}

// MARK: Midi Out

extension ProphecyEditor {

  func paramChange(group: UInt8, paramId: Int, value: Int) -> [UInt8] {
    return Prophecy.sysexHeader(deviceId: UInt8(channel)) +
      [0x41, group, UInt8(paramId & 0x7f), UInt8((paramId >> 7) & 0x7f),
       UInt8(value & 0x7f), UInt8((value >> 7) & 0x7f), 0xf7]
  }
  
  func globalOut(input: Observable<(PatchChange, ProphecyGlobalPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(50), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      return [Data(self.paramChange(group: 0, paramId: param.parm, value: value))]
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    })
  }

  func voiceOut(input: Observable<(PatchChange, ProphecyVoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(50), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      return [Data(self.paramChange(group: 1, paramId: param.parm, value: value))]
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    }, nameTransform: { (patch, path, name) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    })
    
  }
  
  func arpOut(input: Observable<(PatchChange, ProphecyArpPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(50), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      if path == [.number] {
        return [
          Data(
            Midi.cc(99, value: 0, channel: self.channel) +
            Midi.cc(98, value: 1, channel: self.channel) +
            Midi.cc(6, value: value, channel: self.channel)
          )
        ]
      }
      
      guard let param = type(of: patch).params[path] else { return nil }
      return [Data(self.paramChange(group: 2, paramId: param.parm, value: value))]

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel, program: self.tempArp)]

    })
  }

}
