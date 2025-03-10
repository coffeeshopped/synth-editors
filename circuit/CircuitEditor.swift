
class CircuitEditor : SingleDocSynthEditor {
    
  func channel(forSynth synth: Int) -> Int {
    return patch(forPath: [.global])?[[.channel, .i(synth)]] ?? 0
  }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : CircuitGlobalPatch.self,
      [.patch, .i(0)] : CircuitSynthPatch.self,
      [.patch, .i(1)] : CircuitSynthPatch.self,
      [.bank, .patch] : CircuitSynthBank.self,
    ]

    let migrationMap: [SynthPath:String] = [
      [.global] : "Global.json",
      [.patch, .i(0)] : "Voice 1.syx",
      [.patch, .i(1)] : "Voice 2.syx",
      [.bank, .patch] : "Voice Bank.syx",
    ]

    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
    
    addMidiInHandler(throttle: .milliseconds(100)) { [weak self] (msg) in
      guard let self = self else { return }
      guard case .cc(let channel, let number, let value) = msg,
        (80..<88) ~= number,
        channel == self.channel(forSynth: 0) || channel == self.channel(forSynth: 1) else { return }
      let part = channel == self.channel(forSynth: 0) ? 0 : 1
      self.handleMacroCC(part: part, number: number, value: value)
    }

  }
    
  // MARK: MIDI I/O
  
  private func patchFetchCommand(location: UInt8) -> RxMidi.FetchCommand {
    return .request(Data([0xf0, 0x00, 0x20, 0x29, 0x01, 0x60, 0x40, location, 0xf7]))
  }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path.first! {
    case .patch:
      guard let index = path.i(1) else { return nil }
      return [patchFetchCommand(location: UInt8(index))]
    case .bank:
      return Array((0..<64).map { (location) -> [RxMidi.FetchCommand] in
        [
          .send(Data([0xc0, UInt8(location)])), // pgmChange on chan 1
          .wait(0.03),
          patchFetchCommand(location: 0),
          .wait(0.03),
        ] }.joined())
    default:
      return nil
    }
  }
      
  private func handleMacroCC(part: Int, number: UInt8, value: UInt8) {
    let macro = Int(number - 80)
    let pc: PatchChange = .paramsChange([[.macro, .i(macro), .level] : Int(value)])
    changePatch(forPath: [.patch, .i(part)], pc, transmit: false)
  }

  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    (0..<2).forEach {
      midiOuts.append(voiceOut(location: $0, input: patchStateManager([.patch, .i($0)])!.typedChangesOutput()))
    }
    
    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .patch])!.output) {
      guard let patch = $0 as? CircuitSynthPatch else { return nil }
      return [patch.sysexData(location: $1)]
    })
    
    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    guard let part = path.i(1) else { return 0 }
    return channel(forSynth: part)
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    return [[.bank, .patch]]
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    return ["Synth Bank"]
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    switch path[0] {
    default:
      return { "\($0+1)" }
    }
  }
}

// MARK: Midi Out

extension CircuitEditor {
  
  /// Location: 0 or 1
  func voiceOut(location: Int, input: Observable<(PatchChange, CircuitSynthPatch, Bool)>) -> Observable<[Data]?> {
    let patchOutLocation = -(location + 1)
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      let channel = self.channel(forSynth: location)
      switch param.parm {
      case 0..<10000:
        // CC
        return [Data(Midi.cc(param.parm, value: value, channel: channel))]
      case 10000..<Int.max:
        // NRPN
        let msbCC = (param.parm - 10000) / 1000
        let lsbCC = (param.parm - 10000) % 1000
        let v: Int
        switch lsbCC {
        case 122:
          guard let lfo = path.i(1) else { return nil }
          switch path[2] {
          case .oneShot:
            v = 12 + value + lfo * 10
          case .key:
            v = 14 + value + lfo * 10
          case .common:
            v = 16 + value + lfo * 10
          case .delay:
            v = 18 + value + lfo * 10
          default:
            v = 0
          }
        case 123:
          guard let lfo = path.i(1) else { return nil }
          v = value + lfo * 4
        default:
          v = value
        }
        return [Data(
          Midi.cc(99, value: msbCC, channel: channel) +
          Midi.cc(98, value: lsbCC, channel: channel) +
          Midi.cc(6, value: v, channel: channel)
          )]
      default:
        // Send whole patch
        return [patch.sysexData(location: patchOutLocation)]
      }
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(location: patchOutLocation)]

    }, nameTransform: { (patch, path, name) -> [Data]? in
      return [patch.sysexData(location: patchOutLocation)]

    })
    
  }
  
}
