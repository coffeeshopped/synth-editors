
class BassStationIIEditor : SingleDocSynthEditor {
    
  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : ChannelSettingsPatch.self,
      [.patch] : BassStationIIVoicePatch.self,
      [.extra] : BassStationIIOverlayPatch.self,
      [.bank, .patch] : BassStationIIVoiceBank.self,
      [.bank, .extra] : BassStationIIOverlayBank.self,
    ]

    super.init(baseURL: baseURL, sysexMap: map)
  }
    
  // MARK: MIDI I/O

  private func fetchCommand(cmdBytes: [UInt8]) -> RxMidi.FetchCommand {
    return .request(Data(BassStationIIVoicePatch.sysexHeader() + cmdBytes + [0xf7]))
  }
  
  private func overlayFetchCommands() -> [RxMidi.FetchCommand] {
    return Array((0..<25).map { (location) -> [RxMidi.FetchCommand] in
                  [
                    fetchCommand(cmdBytes: [0x4f, UInt8(location)]),
                    .wait(0.03),
                    fetchCommand(cmdBytes: [0x54, UInt8(location)]),
                    .wait(0.03),
                  ] }.joined())
  }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case [.patch]:
      return [fetchCommand(cmdBytes: [0x40])]
    case [.extra]:
      return overlayFetchCommands()
    case [.bank, .patch]:
      return Array((0..<128).map { (location) -> [RxMidi.FetchCommand] in
        [
          .send(Data([0xc0 + UInt8(channel), UInt8(location)])), // pgmChange on global channel
          .wait(0.03),
          fetchCommand(cmdBytes: [0x40]),
          .wait(0.03),
        ] }.joined())
    case [.bank, .extra]:
      return Array((1...8).map {
        return [.send(Data(BassStationIIVoicePatch.sysexHeader() + [0x50, UInt8($0), 0xf7]))] + overlayFetchCommands()
      }.joined())
    default:
      return nil
    }
  }

  override func sysexible(forPath path: SynthPath) -> Sysexible? {
    // used by the overlay popup loader
    guard path.starts(with: [.extra, .key]),
          let overlayBank = sysexible(forPath: [.extra]) as? BassStationIIOverlayPatch,
          let key = overlayBank.subpatches[path.subpath(from: 1)] as? BassStationIIOverlayKeyPatch else { return super.sysexible(forPath: path) }
    return BassStationIIVoicePatch.fromOverlay(key)
    
  }
  
  // make those big multi-msg pushes happen faster!
  override var sendInterval: TimeInterval { return 0.01 }

  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(voiceOut(input: patchStateManager([.patch])!.typedChangesOutput()))
    midiOuts.append(overlayOut(input: patchStateManager([.extra])!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .patch])!.output) {
      guard let patch = $0 as? BassStationIIVoicePatch else { return nil }
      return [patch.sysexData(save: true, location: $1)]
    })

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .extra])!.output) {
      guard let patch = $0 as? BassStationIIOverlayPatch else { return nil }
      return patch.sysexData(bank: $1 + 1)
    })

    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is BassStationIIVoicePatch.Type:
      return [[.bank, .patch]]
    default:
      return [[.bank, .extra]]
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is BassStationIIVoicePatch.Type:
      return ["Voice Bank"]
    default:
      return ["Overlay Bank"]
    }
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    switch path.last {
    case .patch:
      return { "\($0)" }
    default:
      return { "\($0+1)" }
    }
  }
}

// MARK: Midi Out

extension BassStationIIEditor {
  
  func voiceOut(input: Observable<(PatchChange, BassStationIIVoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(50), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      let channel = UInt8(self.channel)
      
      if param.parm < 0 {
        return [patch.sysexData(save: false)]
      }
      
      // type of MIDI msg depends on parameter type (CC, multi-CC, or NRPN)
      let msgs: [MidiMessage]
      if let lsb = param.extra[BassStationIIVoicePatch.LSB] {
        msgs = [
          .cc(channel: channel, number: UInt8(param.parm), value: UInt8(value >> 1)),
          .cc(channel: channel, number: UInt8(lsb), value: value % 2 == 0 ? 0 : 64),
        ]
      }
      else if let nrpn = param.extra[BassStationIIVoicePatch.NRPN] {
        var m: [MidiMessage] =  [
          .cc(channel: channel, number: 99, value: UInt8(param.parm)),
          .cc(channel: channel, number: 98, value: UInt8(nrpn)),
        ]
        if let rangeParam = param as? ParamWithRange,
           rangeParam.range.upperBound > 127 {
          m += [
            .cc(channel: channel, number: 6, value: UInt8(value >> 1)),
            .cc(channel: channel, number: 38, value: UInt8(value & 0x1) << 6)
          ]
        }
        else {
          m += [.cc(channel: channel, number: 6, value: UInt8(value))]
        }
        msgs = m
      }
      else {
        msgs = [
          .cc(channel: channel, number: UInt8(param.parm), value: UInt8(value))
        ]
      }
      
      return msgs.map { Data($0.bytes()) }
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(save: false)]

    }, nameTransform: { (patch, path, name) -> [Data]? in
      return [patch.sysexData(save: false)]

    })
    
  }

  func overlayOut(input: Observable<(PatchChange, BassStationIIOverlayPatch, Bool)>) -> Observable<[Data]?> {
    
    return input.throttle(0.2, scheduler:MainScheduler.instance).map { (change, patch, transmit) in
      guard transmit else { return nil }
      
      switch change {
      case .nameChange(let path, let name):
        guard let index = path.i(1) else { return nil }
        let nameBytes = String(name.unicodeScalars.filter { return $0.isASCII }).bytes(forCount: 16)
        return [BassStationIIOverlayKeyPatch.nameSysexData(location: index, nameBytes: nameBytes)]
      case .replace(_), .push:
        return patch.sysexData()
      case .paramsChange(let params):
        
        if params.count == 1 && params.first?.key.suffix(1) == [.mute] && (params.first?.value ?? 0) > 0 {
          guard let index = params.first?.key.i(1),
                let key = patch.subpatches[[.key, .i(index)]] as? BassStationIIOverlayKeyPatch else { return nil }
          return [key.paramSysexData(location: index)]
        }
        
        // just send the keys that we need to
        var keys = Set<Int>()
        params.forEach { (path, value) in
          guard let key = path.i(1) else { return }
          keys.insert(key)
        }
        return keys.compactMap {
          guard let key = patch.subpatches[[.key, .i($0)]] as? BassStationIIOverlayKeyPatch else { return nil }
          return key.paramSysexData(location: $0)
        }
      case .noop:
        return nil
      }
    }

  }
}
