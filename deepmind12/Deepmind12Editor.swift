
class Deepmind12Editor : SingleDocSynthEditor {
    
  var deviceId: Int { return patch(forPath: [.global])?[[.deviceId]] ?? 0 }
  var channel: Int {
    let mode = patch(forPath: [.mode])?[[.mode]] ?? 0
    let modes: [SynthPathItem] = [.midi, .usb, .wifi]
    guard mode < modes.count else { return 0 }
    let ch = patch(forPath: [.global])?[[modes[mode], .channel, .rcv]] ?? 1
    return ch < 1 ? 0 : ch - 1
  }

  required init(baseURL: URL) {
    super.init(baseURL: baseURL, sysexMap: [
      [.mode] : Deepmind12ConnectPatch.self,
      [.global] : Deepmind12GlobalPatch.self,
      [.patch] : Deepmind12VoicePatch.self,
      [.arp] : Deepmind12ArpPatch.self,
      [.bank, .patch, .i(0)] : Deepmind12VoiceBank.self,
      [.bank, .patch, .i(1)] : Deepmind12VoiceBank.self,
      [.bank, .patch, .i(2)] : Deepmind12VoiceBank.self,
      [.bank, .patch, .i(3)] : Deepmind12VoiceBank.self,
      [.bank, .patch, .i(4)] : Deepmind12VoiceBank.self,
      [.bank, .patch, .i(5)] : Deepmind12VoiceBank.self,
      [.bank, .patch, .i(6)] : Deepmind12VoiceBank.self,
      [.bank, .patch, .i(7)] : Deepmind12VoiceBank.self,
      [.bank, .arp] : Deepmind12ArpBank.self,
    ])
    
//    addMidiInHandler(throttle: 0.1) { [weak self] (msg) in
//      guard let self = self else { return }
//      guard case .cc(let channel, let number, let value) = msg,
//        (80..<88) ~= number,
//        channel == self.channel(forSynth: 0) || channel == self.channel(forSynth: 1) else { return }
//      let part = channel == self.channel(forSynth: 0) ? 0 : 1
//      self.handleMacroCC(part: part, number: number, value: value)
//    }
  }
    
  // MARK: MIDI I/O

  private func fetchCommand(cmdBytes: [UInt8]) -> RxMidi.FetchCommand {
    return .request(Data(Deepmind12.sysexHeader(deviceId: UInt8(deviceId)) + cmdBytes + [0xf7]))
  }
    
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case [.global]:
      return [fetchCommand(cmdBytes: [0x05])]
    case [.patch]:
      return [fetchCommand(cmdBytes: [0x03])]
    case [.arp]:
      return [fetchCommand(cmdBytes: [0x0e])]
    case [.bank, .patch, .i(0)],
         [.bank, .patch, .i(1)],
         [.bank, .patch, .i(2)],
         [.bank, .patch, .i(3)],
         [.bank, .patch, .i(4)],
         [.bank, .patch, .i(5)],
         [.bank, .patch, .i(6)],
         [.bank, .patch, .i(7)]:
      guard let bank = path.i(2) else { return nil }
      return [fetchCommand(cmdBytes: [0x09, UInt8(bank), 0, 127])]
    case [.bank, .arp]:
      return (0..<32).map { fetchCommand(cmdBytes: [0x07, UInt8($0)]) }
    default:
      return nil
    }
  }
  
  
  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    super.changePatch(forPath: path, change, transmit: transmit)
    
    switch path {
    case [.patch]:
      if case let .paramsChange(values) = change {
        values.forEach { pair in
          switch pair.key {
          case [.fx, .routing]:
            let mode = pair.value
            guard mode < Deepmind12FX.routingLevels.count else { return }
            let levels = Deepmind12FX.routingLevels[mode].defaults
            // update levels to defaults for this mode.
            var pcValues: [SynthPath:Int] = [:]
            (0..<4).forEach { pcValues[[.fx, .i($0), .level]] = levels[$0] }
            super.changePatch(forPath: [.patch], .paramsChange(SynthPathIntsMake(pcValues)), transmit: false)
          case [.fx, .i(0), .type], [.fx, .i(1), .type], [.fx, .i(2), .type], [.fx, .i(3), .type]:
            guard let fx = pair.key.i(1) else { return }
            let fxType = pair.value
            guard fxType < Deepmind12FX.paramDefaults.count else { return }
            let defs = Deepmind12FX.paramDefaults[fxType]
            var pcValues: [SynthPath:Int] = [:]
            (0..<12).forEach { pcValues[[.fx, .i(fx), .param, .i($0)]] = defs[$0] }
            super.changePatch(forPath: [.patch], .paramsChange(SynthPathIntsMake(pcValues)), transmit: false)
          default:
            break
          }
        }
      }
    default:
      break
    }
    
//    comparator.check(path: path, change: change)
  }
  
  private let comparator = PatchComparator<Deepmind12VoicePatch>(path: [.patch])

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
  override var sendInterval: TimeInterval { return 0.01 }

  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(globalOut(input: patchStateManager([.global])!.typedChangesOutput()))
    midiOuts.append(voiceOut(input: patchStateManager([.patch])!.typedChangesOutput()))
    midiOuts.append(arpOut(input: patchStateManager([.arp])!.typedChangesOutput()))

    (0..<8).forEach { bank in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .patch, .i(bank)])!.output, patchTransform: {
        guard let patch = $0 as? Deepmind12VoicePatch else { return nil }
        return [patch.sysexData(channel: self.deviceId, bank: bank, program: $1)]
      }))
    }

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .arp])!.output, patchTransform: {
      guard let patch = $0 as? Deepmind12ArpPatch else { return nil }
      return [patch.sysexData(channel: self.deviceId, program: $1)]
    }))

    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is Deepmind12VoicePatch.Type:
      return (0..<8).map { [.bank, .patch, .i($0)] }
    case is Deepmind12ArpPatch.Type:
      return [[.bank, .arp]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is Deepmind12VoicePatch.Type:
      return (0..<8).map { "Voice Bank \(Deepmind12VoiceBank.bankLetter($0))" }
    case is Deepmind12ArpPatch.Type:
      return ["Arp Bank"]
    default:
      return []
    }
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    switch path.last {
    case .patch:
      return { "\($0 + 1)" }
    default:
      return { "\($0+1)" }
    }
  }
}

// MARK: Midi Out

extension Deepmind12Editor {

  func globalOut(input: Observable<(PatchChange, Deepmind12GlobalPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(50), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      let channel = UInt8(self.channel)
      
      let msgs: [MidiMessage] = [
        .cc(channel: channel, number: 99, value: 0x02),
        .cc(channel: channel, number: 98, value: UInt8(param.byte + 44)),
        .cc(channel: channel, number: 6, value: UInt8(value >> 7)),
        .cc(channel: channel, number: 38, value: UInt8(value & 0x7f))
      ]

      return msgs.map { Data($0.bytes()) }
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    })
  }

  func voiceOut(input: Observable<(PatchChange, Deepmind12VoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(50), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      let channel = UInt8(self.channel)
      
      let v: Int
      if let param = param as? ParamWithRange,
         param.range.lowerBound < 0 {
        v = value - param.range.lowerBound
      }
      else {
        v = value
      }
      
      let msgs: [MidiMessage] = [
        .cc(channel: channel, number: 99, value: UInt8(param.byte >> 7)),
        .cc(channel: channel, number: 98, value: UInt8(param.byte & 0x7f)),
        .cc(channel: channel, number: 6, value: UInt8(v >> 7)),
        .cc(channel: channel, number: 38, value: UInt8(v & 0x7f))
      ]

      return msgs.map { Data($0.bytes()) }
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    }, nameTransform: { (patch, path, name) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    })
    
  }
  
  func arpOut(input: Observable<(PatchChange, Deepmind12ArpPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(50), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      let channel = UInt8(self.channel)
      
      let index = param.byte + 123
      let b1: UInt8 = index > 127 ? 7 : 6
      let b2: UInt8 = UInt8(index % 128)
      let msgs: [MidiMessage] = [
        .cc(channel: channel, number: 99, value: b1),
        .cc(channel: channel, number: 98, value: b2),
        .cc(channel: channel, number: 6, value: UInt8(value >> 7)),
        .cc(channel: channel, number: 38, value: UInt8(value & 0x7f))
      ]

      return msgs.map { Data($0.bytes()) }
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    })
  }

}
