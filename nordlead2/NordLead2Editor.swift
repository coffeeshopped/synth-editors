
class NordLead2Editor : SingleDocSynthEditor {
  
  static let slotNames = ["A","B","C","D"]
  
  required init(baseURL: URL) {
    var map: [SynthPath:Sysexible.Type] = [
      [.perf] : NordLead2PerfPatch.self,
    ]
    (0..<4).forEach { map[[.bank, .voice, .i($0)]] = NordLead2VoiceBank.self }

    var migrationMap: [SynthPath:String] = [
      [.perf] : "Performance.syx",
    ]
    (0..<4).forEach { migrationMap[[.bank, .voice, .i($0)]] = "Voice Bank \($0+1)" }

    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
  }
  
  private var perfManager: PatchStateManager? {
    return patchStateManager([.perf])
  }
  
  private var perfPatch: NordLead2PerfPatch? {
    return patch(forPath: [.perf]) as? NordLead2PerfPatch
  }
  
  var deviceId: Int {
    return patch(forPath: [.perf])?[[.deviceId]] ?? 0
  }
  
  override func sysexible(forPath path: SynthPath) -> Sysexible? {
    guard path.first == .part,
      let part = path.i(1) else { return super.sysexible(forPath: path)}
    return perfPatch?.patch(location: part)
  }
  
  override func sysexibleType(path: SynthPath) -> Sysexible.Type? {
    guard path.first == .part else { return super.sysexibleType(path: path) }
    return NordLead2VoicePatch.self
  }

  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    guard path.first == .part, let part = path.i(1) else {
      return super.changePatch(forPath: path, change, transmit: transmit)
    }
    
    let pc: PatchChange
    switch change {
    case .push:
      guard let patch = perfPatch?.patch(location: part) else { return }
      pc = .replace(patch)
    default:
      pc = change
    }
    perfManager?.patchChangesInput.value = (pc.prefixed([.patch, .i(part)]), true)
  }
  
  override func patchChangesOutput(forPath path: SynthPath) -> Observable<(PatchChange,SysexPatch?)>? {
    guard path.first == .part,
      let part = path.i(1) else { return super.patchChangesOutput(forPath: path) }
    return perfManager?.output.map {
      let pc = $0.0.filtered(forPrefix: [.patch, .i(part)])
      let patch = ($0.1 as? NordLead2PerfPatch)?.patch(location: part)
      return (pc, patch)
    }
  }

  // MARK: MIDI I/O
  
  fileprivate var sysexHeader: Data {
    return Data([0xf0, 0x33, UInt8(deviceId), 0x04])
  }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .perf:
      return [.request(sysexHeader + Data([0x28, 0x00, 0xf7]))]
    case .part:
      guard let part = path.i(1) else { return nil }
      return [.request(sysexHeader + Data([0x0a, UInt8(part), 0xf7]))]
    case .bank:
      if path[1] == .voice {
        guard let i = path.i(2) else { return nil }
        return (0..<99).map { .request(sysexHeader + Data([0x0b + UInt8(i), $0, 0xf7])) }
      }
    default:
      return nil
    }
    return nil
  }
    
  private func filteredPerfDocOutput(part: Int) -> Observable<(PatchChange, NordLead2PerfPatch, Bool)> {
    return perfManager!.typedChangesOutput().filter {
      // no-param change is for priming
      guard case let .paramsChange(params) = $0.0 else { return true }
      for (path,_) in params {
        guard path.starts(with: [.patch, .i(part)]) else { return false }
      }
      return true
    }
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(perf(input: perfManager!.typedChangesOutput().filter {
      // no-param change is for priming
      guard case let .paramsChange(params) = $0.0 else { return true }
      for (path,_) in params {
        guard !path.starts(with: [.patch]) else { return false }
      }
      return true
      }))
    
    (0..<4).forEach {
      midiOuts.append(part(location: $0, input: filteredPerfDocOutput(part: $0)))
    }
    
    (0..<4).forEach { i in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .voice, .i(i)])!.output) {
        guard let patch = $0 as? NordLead2VoicePatch else { return nil }
        // note we add 1 to bank since bank: 0 is temp
        return [patch.sysexData(deviceId: self.deviceId, bank: i + 1, location: $1)]
      })
    }

    return midiOuts
  }
  
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return perfPatch?[path + [.channel]] ?? 0
  }
  
  // MARK: Bank Support

  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    return [
      [.bank, .voice, .i(0)],
      [.bank, .voice, .i(1)],
      [.bank, .voice, .i(2)],
      [.bank, .voice, .i(3)],
    ]
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    return ["Voice Bank Int", "Card Bank 1", "Card Bank 2", "Card Bank 3"]
  }
  
}

extension NordLead2Editor {
  
  /// Transform <deviceId,patch> into MIDI out data
  func perf(input: Observable<(PatchChange, NordLead2PerfPatch, Bool)>) -> Observable<[Data]?> {
    return GenericMidiOut.wholePatchChange(input: input) {
      return [$0.sysexData(deviceId: self.deviceId, bank: NordLead2PerfPatch.tempBuffer, location: 0)]
    }
  }
  
  /// Transform <deviceId, location, partChannel, patchChange, patch> into MIDI out data
  func part(location: Int, input: Observable<(PatchChange, NordLead2PerfPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(300), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      if path.subpath(from: 2) == [.filter, .type] && value == 5 {
        // secret filter mode
        return [patch.patchSysexData(deviceId: self.deviceId, location: location)]
      }
      else if param.parm > 0 {
        let partChannel = self.midiChannel(forPath: [.part, .i(location)])
        return [Data([UInt8(0xb0 + partChannel), UInt8(param.parm), UInt8(value)])]
      }
      else {
        // some params can't be sent individually (e.g. velocity sens)
        return [patch.patchSysexData(deviceId: self.deviceId, location: location)]
      }

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.patchSysexData(deviceId: self.deviceId, location: location)]

    })

  }
  
}



class NordLead2XEditor : NordLead2Editor {
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .perf:
      return [.request(sysexHeader + Data([0x28, 0x00, 0xf7]))]
    case .part:
      guard let part = path.i(1) else { return nil }
      // it's 0E(!) for Nord Lead 2X...
      return [.request(sysexHeader + Data([0x0e, UInt8(part), 0xf7]))]
    case .bank:
      if path[1] == .voice {
        guard let i = path.i(2) else { return nil }
        return (0..<99).map { .request(sysexHeader + Data([0x0b + UInt8(i), $0, 0xf7])) }
      }
    default:
      return nil
    }
    return nil
  }

}


